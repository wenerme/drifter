package me.wener.drifter.drifter;

import android.annotation.SuppressLint;
import android.bluetooth.BluetoothAdapter;
import android.content.Context;
import android.content.pm.PackageManager;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.support.v4.app.ActivityCompat;
import android.telephony.TelephonyManager;
import com.google.android.gms.ads.identifier.AdvertisingIdClient;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener;
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ThreadLocalRandom;
import java.util.logging.Logger;

/** DrifterPlugin */
public class DrifterPlugin implements MethodCallHandler {
  private final Options options = new Options();
  private final DrifterRequestPermissionsResultListener requestPermissionsResultListener =
      new DrifterRequestPermissionsResultListener();
  private final int REQUEST_CODE_LOW = 999999;
  private final Set<Integer> requests =
      Collections.newSetFromMap(new ConcurrentHashMap<Integer, Boolean>());
  private MethodChannel channel;
  private Registrar registrar;
  private Context context;
  private boolean debug = false;

  private static class Options {
    private boolean preferNull = true;
  }

  private final Logger log = Logger.getLogger(DrifterPlugin.class.getCanonicalName());

  private boolean isPreferNull() {
    return options.preferNull;
  }

  private class DrifterRequestPermissionsResultListener
      implements RequestPermissionsResultListener {

    @Override
    public boolean onRequestPermissionsResult(
        int requestCode, String[] permissions, int[] grantResults) {
      if (requests.remove(requestCode)) {

        HashMap<String, Object> map = new HashMap<>();
        map.put("requestCode", requestCode);
        map.put("permissions", permissions);
        map.put(
            "result",
            grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED);

        if (debug) {
          log.fine("onRequestPermissionsResult " + requestCode + " - " + map);
        }
        channel.invokeMethod("requestPermissionsCallback", map);
        return true;
      }

      return false;
    }
  }

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "me.wener.drifter");

    // Setup
    DrifterPlugin plugin = new DrifterPlugin();
    plugin.registrar = registrar;
    plugin.context = registrar.context();
    plugin.channel = channel;

    registrar.addRequestPermissionsResultListener(plugin.requestPermissionsResultListener);

    channel.setMethodCallHandler(plugin);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
        // todo shouldShowRequestPermissionRationale
      case "requestPermissions":
        try {
          List<String> permissions = call.argument("permissions");
          int requestCode = ThreadLocalRandom.current().nextInt();
          registrar.activity().requestPermissions(permissions.toArray(new String[0]), requestCode);
          requests.add(requestCode);
          result.success(requestCode);

          if (debug) {
            log.fine("requestPermissions " + requestCode + " - " + permissions);
          }
        } catch (Throwable e) {
          handleException(result, e);
        }
        break;
      case "hasPermission":
        if (call.argument("permission") instanceof String) {
          String permission = call.argument("permission");
          result.success(
              context.checkCallingOrSelfPermission(permission)
                  == PackageManager.PERMISSION_GRANTED);
          ActivityCompat.requestPermissions(registrar.activity(), new String[] {permission}, 0);
        } else {
          result.success(false);
        }
        break;
      case "debug":
        result.success(debug);
        if (call.argument("debug") != null) {
          debug = Boolean.TRUE.equals(call.argument("debug"));
        }

        if (debug) {
          log.fine("Debug mode enabled");
        }
        break;
      case "option":
        if (call.argument("preferNull") != null) {
          options.preferNull = Boolean.TRUE.equals(call.argument("preferNull"));
        }

        result.success(null);
        break;
      case "generateRandomUuid":
        result.success(UUID.randomUUID().toString());
        break;
      case "getBluetoothAddress":
        try {
          BluetoothAdapter adapter = BluetoothAdapter.getDefaultAdapter();
          if (adapter != null) {
            result.success(adapter.getAddress());
          } else {
            result.success(null);
          }
        } catch (Throwable e) {
          handleException(result, e);
        }
        break;
      case "getWifiMacAddress":
        try {
          WifiManager wifiManager =
              (WifiManager) context.getApplicationContext().getSystemService(Context.WIFI_SERVICE);

          if (wifiManager != null) {
            WifiInfo connectionInfo = wifiManager.getConnectionInfo();
            if (connectionInfo != null) {
              result.success(connectionInfo.getMacAddress());
              break;
            }
          }
          result.success(null);
        } catch (Throwable e) {
          handleException(result, e);
        }
        break;
      case "getMeid":
      case "getImei":
      case "getImsi":
      case "getDeviceId":
        handleTelephonyId(call, result);
        break;
      case "getIdfa":
        try {
          result.success(AdvertisingIdClient.getAdvertisingIdInfo(context).getId());
        } catch (Throwable e) {
          handleException(result, e);
        }
        break;
      case "getIdfv":
        result.success(null);
        break;
      default:
        if (debug) {
          log.warning("Invoke not implemented method: " + call.method);
        }
        if (isPreferNull()) {
          result.success(null);
        } else {
          result.notImplemented();
        }
    }
  }

  @SuppressLint({"MissingPermission", "NewApi"})
  private void handleTelephonyId(MethodCall call, Result result) {
    try {
      TelephonyManager telephonyManager =
          (TelephonyManager)
              context.getApplicationContext().getSystemService(Context.TELEPHONY_SERVICE);

      if (telephonyManager == null) {
        result.success(null);
        return;
      }

      String r = null;
      if ("getImsi".equals(call.method)) {
        r = telephonyManager.getSubscriberId();
      } else if (call.argument("slotIndex") instanceof Number) {
        int slotIndex = ((Number) call.argument("slotIndex")).intValue();
        switch (call.method) {
          case "getMeid":
            r = telephonyManager.getMeid(slotIndex);
            break;
          case "getImei":
            r = telephonyManager.getImei(slotIndex);
            break;
          case "getDeviceId":
            r = telephonyManager.getDeviceId(slotIndex);
            break;
        }
      } else {
        switch (call.method) {
          case "getMeid":
            r = telephonyManager.getMeid();
            break;
          case "getImei":
            r = telephonyManager.getImei();
            break;
          case "getDeviceId":
            r = telephonyManager.getDeviceId();
            break;
        }
      }
      result.success(emptyToNull(r));
    } catch (Throwable e) {
      handleException(result, e);
    }
  }

  private void handleException(Result result, Throwable e) {
    if (debug) {
      ByteArrayOutputStream stream = new ByteArrayOutputStream();
      PrintStream printStream = new PrintStream(stream);
      e.printStackTrace(printStream);
      printStream.flush();
      log.warning("Debug Error: " + new String(stream.toByteArray()));
    }

    // Permission message
    // java.lang.SecurityException: WifiService: Neither user 10079 nor current process has
    // android.permission.ACCESS_WIFI_STATE.
    if (isPreferNull()) {
      result.success(null);
    } else if (e instanceof ClassNotFoundException
        || e instanceof NoClassDefFoundError
        || e instanceof NoSuchMethodError) {
      result.success(null);
    } else if (e instanceof SecurityException) {
      result.error("403", "No Permission", e.getMessage());
    } else {
      result.error("500", "Internal error", e.getMessage());
    }
  }

  private String emptyToNull(String s) {
    if (s != null && s.isEmpty()) {
      return null;
    }
    return s;
  }
}

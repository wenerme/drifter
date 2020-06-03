# Drifter

Drifter is a flutter plugin work with devices.

## Device identifier

Identifier  | iOS   | Android
------------|-------|---------
IDFA        | ✅ | ✅ <br> [Advertising ID](https://support.google.com/googleplay/android-developer/answer/6048248?hl=en) - Need play service
IDFV        | ✅ 
MEID/slot   |   | `android.permission.READ_PHONE_STATE`
IMEI/slot   |   | `android.permission.READ_PHONE_STATE`
IMSI        |   | `android.permission.READ_PHONE_STATE`
DeviceId/slot       |   | `android.permission.READ_PHONE_STATE`
Bluetooth Address   | | `android.permission.BLUETOOTH`<br> `< Android 6`
Wifi Address        | | `android.permission.ACCESS_WIFI_STATE`<br> `< Android 6` othewise always return `02:00:00:00:00:00`



* [Device identifier best practice](https://developer.android.com/training/articles/user-data-ids)
* [What is Instance ID](https://developers.google.com/instance-id/)

## Permission

Identifier  | iOS   | Android
------------|-------|---------
Check permission        | | ✅
Request permission      | | ✅ 

* [App permissions best practices](https://developer.android.com/training/permissions/usage-notes)


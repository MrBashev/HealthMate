@echo off
set APK_PATH=%1
set KEYSTORE=healthmate.keystore
set ALIAS=healthmate
set KEY_PASS= MrBashev
set STORE_PASS= MrBashev 

echo Подписываем %APK_PATH%...

jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 -keystore %KEYSTORE% -storepass %STORE_PASS% -keypass %KEY_PASS% %APK_PATH% %ALIAS%

echo Готово! Проверь подпись:
jarsigner -verify -verbose -certs %APK_PATH%
pause
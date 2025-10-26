@echo off
echo Cleaning up old package structure...

REM Remove old package directory
rmdir /s /q "android\app\src\main\kotlin\com\example"

echo Old package structure removed!
echo.
echo Now rebuild the project:
echo flutter clean
echo flutter pub get  
echo flutter build apk --debug
echo flutter install
pause

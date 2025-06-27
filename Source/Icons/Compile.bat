@echo off

echo.

REM Requires brcc32.exe to be on %PATH%
brcc32.exe .\Icons.rc -fo .\Icons.res
echo.

pause

exit /b 0
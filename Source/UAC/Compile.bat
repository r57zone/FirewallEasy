@echo off

echo.

REM Requires brcc32.exe to be on %PATH%
brcc32.exe .\UAC.rc -fo .\UAC.res
echo.

pause

exit /b
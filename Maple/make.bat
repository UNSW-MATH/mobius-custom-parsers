REM Batch script to create zip files for .ind and .lib files
REM Credit: Generated with the assistance of ChatGPT from OpenAI (May 24 Version)

@echo off
cmaple MaplePreviewCode.mpl

where /q 7z
if %errorlevel% neq 0 (
    echo 7-Zip is not installed or not in the system PATH.
    echo Please install 7-Zip, add it to the enviroment variable path, and try again.
    exit /b 1
)

for %%A in (*.ind) do (
    if exist "%%~nA.lib" (
        7z a "%%~nA.zip" "%%A" "%%~nA.lib"
    )
)

pause
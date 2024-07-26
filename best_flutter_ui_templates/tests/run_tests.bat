@echo off
pip install jinja2
setlocal enabledelayedexpansion

set "logDirectory=tests\test_suites\test_report\template\logs"
set "screenshotDirectory=tests\test_suites\test_report\screenshots"

for %%D in ("%logDirectory%" "%screenshotDirectory%") do (
    pushd "%%~D"
    del *.log *.png 2>nul
    popd
)

set "driverPattern=tests\test_suites\*.dart"

set "printLogsToTerminal=false"
set "args="

REM Process arguments using FOR loop
for %%A in (%*) do (
    set "arg=%%~A"

    REM Check for the --log flag
    if /i "!arg!" == "--log" (
        set "printLogsToTerminal=true"
    ) else (
        set "args=!args! "!arg!""
    )
)

REM If no target files specified, get all _test filenames
if "%args%" == "" (
    for %%I in (%driverPattern%) do (
        set "filename=%%~nI"
        set "args=!args! "!filename!""
    )
)

REM Print the list of files to be run
echo.
echo =========================
echo Test Suites to be run:
for %%A in (%args%) do (
    echo - %%~A.dart
)

REM Run the flutter drive command for each target file
for %%A in (%args%) do (
    echo ========================= 
    echo.
    echo Running %%~A.dart...
    if "%printLogsToTerminal%" == "true" (
        call flutter drive --target=tests\main.dart --driver=tests\test_suites\%%~A.dart -d windows
    ) else (
        call flutter drive --target=tests\main.dart --driver=tests\test_suites\%%~A.dart -d windows > "%logDirectory%\%%~A.log"
    )
)

REM Execute the Python file
python tests\test_suites\test_report\template\generate_report.py

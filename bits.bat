@echo off

IF EXIST C:\Users\%USERNAME%\Desktop\BITS.reg goto initX
ECHO “ BITS.REG file not found on user Desktop, exiting the program. ”
pause

:initX
echo "BITS.REG File found, initiating Script"
echo "Enter 1, if its before system reboot "
echo "Enter 2, if its after system reboot"
set /p val="Enter Value to begin : "

IF %val% EQU 1 goto PreReboot
IF %val% EQU 2 goto PostReboot
echo "invalid value try again "
goto initX

:PreReboot
Title “Rebuilding BITS : Step 1”
ECHO “Stopping Necessary Services From running…”
Net stop bits
Net stop wuauserv
Net stop trustedinstaller
Net stop cryptsvc
Echo “Disabling Windows Modules Installer till Next Reboot…”
Sc config “trustedinstaller” start= disabled
Del "%ALLUSERSPROFILE%\Application Data\Microsoft\Network\Downloader\qmgr*.dat"
Sc delete bits
REG IMPORT C:\Users\%USERNAME%\Desktop\BITS.reg
ECHO " Restarting the Computer, save any un-saved data... "
pause
Shutdown /r /t 5
exit 


:PostReboot 
Title “Rebulilding BITS : Step 2 “
ECHO “Enabling Windows Modules Installer…”
Sc config “trustedinstaller” start= auto

ECHO ”Enabling BITS …”
sc.exe sdset bits D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)
 
net start bits
net start wuauserv
net start trustedinstaller
net start cryptsvc

sc query bits | findstr "RUNNING"
if %errorlevel% EQU 0 echo ">>>>> Sucessfully Fixed Bits <<<<<"
pause
exit
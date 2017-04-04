@echo off

rem DON'T FORGET to Duplicate HumanPawn and PlayerController class code to the SZ_ScrnBalance!

setlocal
set KFDIR=d:\Games\kf
set STEAMDIR=c:\Steam\steamapps\common\KillingFloor
set outputdir=D:\KFOut\ScrnZedManager

echo Removing previous release files...
del /S /Q %outputdir%\ScrnZedManager*
del /S /Q %outputdir%\ScrnVotingHandler*


echo Compiling project...
call make.cmd
if %ERRORLEVEL% NEQ 0 goto end

echo Exporting .int file...
%KFDIR%\system\ucc dumpint ScrnZedManager.u

echo.
echo Copying release files...
mkdir %outputdir%\System
rem mkdir %outputdir%\Textures
mkdir %outputdir%\uz2


copy /y %KFDIR%\system\ScrnZedManager.* %outputdir%\system\
copy /y %KFDIR%\system\ScrnVotingHandlerV4.* %outputdir%\system\
copy /y *.txt  %outputdir%
rem don't suggest to overwrite existing .ini file
copy /y %KFDIR%\ScrnBalanceSrv\ScrnVoting.ini %outputdir%
copy /y %KFDIR%\ScrnZedManager\Zeds.ini %outputdir%


echo Compressing to .uz2...
%KFDIR%\system\ucc compress %KFDIR%\system\ScrnZedManager.u
%KFDIR%\system\ucc compress %KFDIR%\system\ScrnVotingHandlerV4.u

move /y %KFDIR%\system\ScrnZedManager.u.uz2 %outputdir%\uz2
move /y %KFDIR%\system\ScrnVotingHandlerV4.u.uz2 %outputdir%\uz2

echo Release is ready!

endlocal

pause

:end

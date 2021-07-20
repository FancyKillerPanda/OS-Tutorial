@echo off
rem  ===== Date Created: 20 July, 2021 ===== 

set scriptDir=%~dp0
set prjRoot=%scriptDir%\..

if not exist %prjRoot%\bin\ (
	echo There is nothing to run...
) else (
	cls
	bochsdbg -q -f %prjRoot%\tools\bochsrc.bxrc
)

for %%i in ("bin\x64-lua5.3\*")  do (mklink /H "%%~ni%%~xi" %%i)
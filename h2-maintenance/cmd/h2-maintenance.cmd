@echo off
set DIR=%~dp0

rem Be careful when using other driver versions as it may corrupt the database
set DRIVER=h2-1.4.193.jar
set DB=njams
set TARGET=target
set TEMPFILE=export.zip
set CONSOLELOG=1
set USER=
set PWD=

if !%1!==!! (
	goto USAGE
) else (
	set USER=%1
)
if !%2!==!! (
	goto USAGE
) else (
	set PWD=%2
)
if not !%3!==!! (
	set DB=%3
)
set DBFILE=%DB%.mv.db

if not exist %DIR%%DRIVER% (
	echo JDBC driver %DRIVER% not found.
	exit /b 2
)
if not exist %DIR%%DBFILE% (
	echo Database file %DBFILE% not found.
	exit /b 2
)
if not exist %DIR%%TARGET% (
	mkdir %DIR%%TARGET%
)
if exist %DIR%%TARGET%\%DBFILE% (
	echo Target database already exist in: %DIR%%TARGET%
	echo Please remove the files.
	exit /b 10
)
if !"%JAVA_HOME%"!==!""! (
	set JAVA=java
) else (
	set JAVA="%JAVA_HOME%\bin\java"
)
echo Exporting current database... Please be patient...
%JAVA% -cp %DRIVER% org.h2.tools.Script -url "jdbc:h2:%DIR%%DB%;MVCC=true;DB_CLOSE_ON_EXIT=TRUE;AUTO_SERVER=TRUE;TRACE_LEVEL_FILE=2;TRACE_LEVEL_SYSTEM_OUT=%CONSOLELOG%" -user %USER% -password %PWD% -script %TEMPFILE% -options compression zip
set EC=%ERRORLEVEL%
if %EC% NEQ 0 (
	echo Database export failed with code %EC%
	if exist %TEMPFILE% (
	  del %TEMPFILE%
	)
	exit /b %EC%
)

echo Creating fresh database... Please be patient...
%JAVA% -cp %DRIVER% org.h2.tools.RunScript -url "jdbc:h2:%DIR%%TARGET%/%DB%;MVCC=true;DB_CLOSE_ON_EXIT=TRUE;AUTO_SERVER=TRUE;TRACE_LEVEL_FILE=2;TRACE_LEVEL_SYSTEM_OUT=%CONSOLELOG%" -user %USER% -password %PWD% -script %TEMPFILE% -options compression zip
set EC=%ERRORLEVEL%
if %EC% NEQ 0 (
	echo Database import failed with code %EC%
	exit /b %EC%
)
echo Database '%DB%' successfully created in %DIR%%TARGET%
del %TEMPFILE%
exit /b 0

:USAGE
echo usage: %~n0[%~x0] db-user password [db-name]
echo        db-name defaults to: %DB%
exit /b 12
:END

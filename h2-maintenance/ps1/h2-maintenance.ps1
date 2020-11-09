<#
.SYNOPSIS
    Rebuilds H2 database of an nJAMS Server instance.

.DESCRIPTION
    The internal "H2" database of nJAMS Server is a lightweight, efficient and low maintenance relational database management system (RDBMS).
    
    However, from time to time it may be required to compact H2 database file. Especially when nJAMS Server is running continously over weeks or months, the H2 database file may increase significantly. 
    The H2 database is automatically compacted, when closing the database. In order to close and compact H2 database, nJAMS Server must be stopped and restarted.

    This maintenance script goes beyond and rebuilds the H2 database. Rebuilding the database will further reduce the database size, since it will also rebuild the indexes.

    How it works:
    First the script exports the nJAMS H2 database file ("njams.mv.db") into a temporary ZIP file. Secondly a new H2 database file is created based on the export.

    There are basically two options to use the script.
    (a) Manual approach:
    1. Copy the script to a working folder of any Windows, Linux or Mac machine that has sufficient free disk space and has installed Java 8 or higher.
    2. Stop nJAMS Server instance, respectively shutdown WildFly process.
    3. Copy "njams.mv.db" from "<njams-installation>/data/h2/" of your nJAMS Server machine to the working folder of this machine.
    4. Copy H2 JDBC driver jar file from "<njams-installation>/wildfly16/modules/system/layers/base/com/h2database/h2/main/" of your nJAMS Server machine to the working folder.
    5. Open Powershell and CD to the working folder.
    6. Run the script. If applicable, enter the credentials to access nJAMS H2 database by specifying parameters -dbUser and -password.
       -> The new nJAMS H2 database is created in subfolder "target" of your working folder. You will notice, the new file is significantly smaller than the original file.
    8. Replace the original nJAMS H2 database file on nJAMS Server machine with the newly created H2 database file.
    9. Restart nJAMS Server by starting WildFly again.

    (b) Automatic approach:
    1. Copy the script to a working folder of your nJAMS Server machine. Make sure this machine has sufficient free disk space and has installed Java 8 or higher.
    2. Stop nJAMS Server instance, respectively shutdown WildFly process.
    3. Open Powershell and CD to the working folder.
    4. Run the script. Specify credentials to H2 database and specify the path to your nJAMS installation, e,g, "/opt/njams/".
       -> The script copies H2 database file and JDBC driver file from nJAMS installation folder to working folder and replaces the original H2 database file with the newly created file. 
    5. Restart nJAMS Server by starting WildFly again.

    Characteristics:
    - shrinks nJAMS H2 database by rebuilding H2 database file
    - supports H2 database files of nJAMS Server 5.x
    - runs on Windows, Linux, and macOS using PowerShell Core 7 or Windows PowerShell 5

.PARAMETER dbUser
    Enter username of the nJAMS H2 database. This parameter is optional. Default is "admin".

.PARAMETER password
    Enter password of the nJAMS H2 database. This parameter is optional. Default is "admin".
    
.PARAMETER dbName
    Enter name of the nJAMS H2 database. This parameter is optional. Default is "njams.
    
.PARAMETER njamsDir
    Specifies the nJAMS installation directory. If this parameter is given, the script automatically use required files from nJAMS installation and replace H2 database file. 
    This parameter is optional. Default is "njams".
    
.PARAMETER workingDir
    Specifies the working directory. This parameter is optional. Default is current directory.
    
.PARAMETER force
    Executes the script without confirmation prompt. This parameter is optional. Default is off.

.EXAMPLE
    ./h2-maintenance.ps1 
    Rebuilds nJAMS H2 database file in current directory while using default database credentials (admin/admin). nJAMS H2 database file and JDBC driver fie must be present in current directory.

.EXAMPLE
    ./h2-maintenance.ps1 -dbUser "njams" -password "njams"
    Rebuilds nJAMS H2 database file in current directory while using given database credentials. nJAMS H2 database file and JDBC driver fie must be present in current directory.

.EXAMPLE
    ./h2-maintenance.ps1 -njamsDir "/opt/njams"
    Rebuilds nJAMS H2 database file in current directory while using H2 database file and JDBC driver file from specified nJAMS installation directory and while using default database credentials. 
    Replaces original H2 database file in nJAMS installation directory with newly created database file.

.LINK
    https://github.com/integrationmatters/njams-toolbox
    https://www.integrationmatters.com/

.NOTES
    Version:    1.0.0
    Copyright:  (c) Integration Matters
    Date:       October 2020

#>

param (
    [string]$dbUser = "admin",
    [string]$password = "admin",
    [string]$dbName = "njams",
    [string]$njamsDir,
    [string]$workingDir = "./",
    [switch]$force
)

# Trim nJAMS installation directory:
$njamsDir = ($njamsDir -replace '[\\/]?[\\/]$') + '/'
$workingDir = ($workingDir -replace '[\\/]?[\\/]$') + '/'

# Declare variables for usage in Java commands to export and rebuild H2 database file:
$consoleLog = 1
$tempFile = "export.zip"

# Function to determine, if a process is running. Works on Windows and Linux:
function fnCheckRunningProcess ([string]$processName) {

    if ($PSVersionTable.PSEdition -eq "Core") {
        # Linux:
        if ($IsLinux -or $IsMac) {
            $result = ps -ef | grep "$processName"

            if ($result -like "*/$($processName)*") { 

                return $true
            } 
        }
    }
    # Windows:
    $result = get-process -name "*$processName*"

    if ($result) {

        return $true
    }

    return $false
}

# Ask for confirmation to proceed:
if (!$force) {
    if ($PSBoundParameters.ContainsKey('njamsDir')) {
        write-host "This script will rebuild the H2 database of your nJAMS instance."
        write-host "First the H2 database file and JDBC driver are copied from nJAMS installation directory ('$njamsDir') into working directory ('$workingDir')."
        write-host "After rebuilding the database, the original database file in nJAMS installation directory is replaced by the rebuilt database file." 
        write-host "Make sure your nJAMS Server (WildFly) is stopped and H2 database file is not locked." -ForegroundColor Yellow
    }
    else {
        write-host "This script will rebuild the H2 database file in working directory ('$workingDir')." 
        write-host "Please make sure H2 database file and JDBC driver file are present in this directory." -ForegroundColor Yellow
    }

    $userInput = read-host "Do you want to continue? [Y] Yes  [N] No"

    if ($userInput.ToLower() -ne "y" -and $userInput.ToLower() -ne "yes") {
        write-host "Ok. No action has been taken."
    
        Exit
    }
}

# (1) Check working folder:
# If specified working folder does not exist, exit script.
if (-Not (Test-Path $workingDir)) {

    write-host ("Specified working directory '$workingDir' does not exist. Script exits.") -ForegroundColor Yellow

    Exit
}

# (2) Check for H2 database file.
# If '-njamsDir' is specified, copy database file from nJAMS installation folder of this machine.
# If '-njamsDir' is NOT specified and database file does NOT exist in working folder, exit script.
$h2DBFile = $dbName + ".mv.db"
$h2LockFile = $dbName + ".lock.db"
$h2DBPath = "data/h2/"
$workingH2DBFullPath = $workingDir + $h2DBFile
try {
    # If -njamsDir is NOT specified:
    if (-Not ($PSBoundParameters.ContainsKey('njamsDir'))) {

        # If H2 database file does not exist in working folder:
        if (-Not (Test-Path $workingH2DBFullPath -PathType leaf)) {

            write-host "No H2 database file found. Please specify path to nJAMS installation directory or copy '$h2DBFile' manually into working directory." -ForegroundColor Yellow

            Exit
        }
    }
    else {
        # Copy H2 database file from nJAMS installation folder into working folder:
        $sourceH2DBFullPath = $njamsDir + $h2DBPath + $h2DBFile
        if (Test-Path $sourceH2DBFullPath -PathType leaf) {

            # If wildfly process is still running, exit script:
            if (fnCheckRunningProcess("wildfly")) { 

                write-host "H2 database is in use and cannot be rebuilt. Please shutdown WildFly process of your nJAMS Server instance before using h2-maintenance script." -ForegroundColor Yellow

                Exit
            } 
            else {
                write-host "H2 database file '$h2DBFile' will be copied from nJAMS installation directory into working directory..."

                Copy-Item -path $sourceH2DBFullPath $workingDir -ErrorAction Stop

                write-host "H2 database file copied."
            }
        }
        else {
            write-host "No H2 database file found. Please correct path to nJAMS installation directory." -ForegroundColor Yellow

            Exit
        }
    }
}
catch {
    write-host "Unable to copy H2 database file to working directory due to:" -ForegroundColor Red
    write-host "$_.Exception.Message"

    Exit
}

# (3) Check for jdbc driver.
# If '-njamsDir' is specified, copy jdbc driver file from nJAMS installation folder of this machine.
# If '-njamsDir' is NOT specified and jdbc driver file does NOT exist in working folder, exit script.
try {
    $jdbcDriverPath = "wildfly16/modules/system/layers/base/com/h2database/h2/main/"
    $jdbcDriverFilePattern = "h2-*.jar"

    # If -njamsDir is NOT specified:
    if (-Not ($PSBoundParameters.ContainsKey('njamsDir'))) {

        # If jdbc driver file does not exist in working folder:
        $result = Get-ChildItem -Path $($workingDir + $jdbcDriverFilePattern) -ErrorAction Stop | Sort-Object -Property @{ Expression = { $_.name }; Descending = $true }

        if ($result) {
            $jdbcDriverFile = $result[0].Name
        }
        else {

            write-host "No JDBC driver file found. Please specify path to nJAMS installation directory or manually copy JDBC driver file from your nJAMS installation into working directory." -ForegroundColor Yellow
            write-host "Please note: do not use a different version of the JDBC driver, the database file can be corrupted otherwise." -ForegroundColor Yellow

            Exit
        }
    }
    else {
        # Copy jdbc driver file from nJAMS installation folder into working folder:
        $result = Get-ChildItem -Path $($njamsDir + $jdbcDriverPath + $jdbcDriverFilePattern) -ErrorAction Stop | Sort-Object -Property @{ Expression = { $_.name }; Descending = $true }

        if ($result) {
            $jdbcDriverFile = $result[0].Name

            write-host "JDBC driver file '$jdbcDriverFile' will be copied from nJAMS installation directory into working directory..."
            
            Copy-Item -path $($njamsDir + $jdbcDriverPath + $jdbcDriverFile) $workingDir -ErrorAction Stop

            write-host "JDBC driver file copied."
        }
        else {
            write-host "No JDBC driver file found. Please correct path to nJAMS installation directory." -ForegroundColor Yellow

            Exit
        }
    }
}
catch {
    write-host "Unable to copy JDBC driver file to working directory due to:" -ForegroundColor Red
    write-host "$_.Exception.Message"

    Exit
}

# (4) Check for working target folder and its content.
# If working target folder does not exist, create folder:
try {
    $workingTargetDir = "target/"
    $workingTargetPath = $workingDir + $workingTargetDir
    if (-Not (Test-Path $workingTargetPath)) {

        # Create target folder wihtin working folder:
        $result = New-Item -ItemType Directory -Force -Path $workingTargetPath -ErrorAction Stop
    }
    else {

        # Make sure target folder is empty:
        $result = Remove-Item -path $($workingTargetPath + "*.mv.db") -ErrorAction Stop
    }
}
catch {
	write-host "Unable to prepare working target directory due to:" -ForegroundColor Red
    write-host "$_.Exception.Message"

	Exit
}

# (5) Check Java version:
try {

    # Try to check Java version:
    $result = java -version

    if ($result) {

        write-host "Java is not running properly, please make sure Java is installed correctly." -ForegroundColor Yellow

        Exit
    }
}
catch {
	write-host "Unable to find Java on this machine:" -ForegroundColor Red
    write-host "$_.Exception.Message"

	Exit
}

# (6) Export h2 database:
try {
    $workingJDBCUrl = $workingDir + $dbName

    write-host "Exporting H2 database to working directory. Please wait..."

    # This Java command exports the given H2 database into working directory:
    $result = java -cp $jdbcDriverFile org.h2.tools.Script -url "jdbc:h2:$workingJDBCUrl;MVCC=true;DB_CLOSE_ON_EXIT=TRUE;AUTO_SERVER=TRUE;TRACE_LEVEL_FILE=2;TRACE_LEVEL_SYSTEM_OUT=$consoleLog" -user $dbUser -password $password -script $tempFile -options compression zip

    # If Java command line returns (error) message, exit script:
    if ($result) {
        
        write-host "Unable to export h2 database due to:" -ForegroundColor Red
        write-host $result

        Exit
    }

    write-host "H2 database exported successfully."
}
catch {
	write-host "Unable to export h2 database due to:" -ForegroundColor Red
    write-host "$_.Exception.Message"

	Exit
}

# (7) Create new h2 database:
try {
    $workingTargetJDBCUrl = $workingTargetPath + $dbName

    write-host "Creating new H2 database in working target directory. Please wait..."

    # This Java command creates a new H2 database file in working target directory:
    $result = java -cp $jdbcDriverFile org.h2.tools.RunScript -url "jdbc:h2:$workingTargetJDBCUrl;MVCC=true;DB_CLOSE_ON_EXIT=TRUE;AUTO_SERVER=TRUE;TRACE_LEVEL_FILE=2;TRACE_LEVEL_SYSTEM_OUT=$consoleLog" -user $dbUser -password $password -script $tempFile -options compression zip

    # If Java command line returns (error) message, exit script:
    if ($result) {
        
        write-host "Unable to create new h2 database due to:" -ForegroundColor Red
        write-host $result

        Exit
    }

    write-host "H2 database successfully created in working target directory ('$workingTargetPath')."

    # Get file sizes of original and rebuilt h2 database files:
    $originalH2FileSize = [math]::ceiling((Get-Item $($workingDir + $h2DBFile)).length / 1mb)
    $rebuiltH2FileSize = [math]::ceiling((Get-Item $($workingTargetPath + $h2DBFile)).length / 1mb)
    
    write-host "H2 database file shrinks from $originalH2FileSize MB to $rebuiltH2FileSize MB. "
}
catch {
	write-host "Unable to create new h2 database due to:" -ForegroundColor Red
    write-host "$_.Exception.Message"

	Exit
}

# (8) Replace existing H2 database in nJAMS installation folder with currently created new H2 database:
try {
    # Remove tempfile:
    Remove-Item $tempFile -ErrorAction Stop

    # If -njamsDir is specified, move new H2 database file from working target directory to target directory:
    if ($PSBoundParameters.ContainsKey('njamsDir')) {

        write-host "Replacing H2 database file at '$workingH2DBFullPath' with rebuilt database file..."

        Move-Item -path $($workingTargetPath + $h2DBFile) -destination $sourceH2DBFullPath -force -ErrorAction Stop

        write-host "Finished."
        write-host "The H2 datbase has been rebuilt and replaced at nJAMS installation directory. You can now start nJAMS Server again."
    }
    else {
        write-host "Finished. You can now replace the H2 database file in your nJAMS installation directory at '<njams-installation>/$h2DBPath' with the just created new database file in '$workingTargetPath'."
    }
}
catch {
	write-host "Unable replace $sourceH2DBFullPath with just created H2 database file :" -ForegroundColor Red
    write-host "$_.Exception.Message"

	Exit
}


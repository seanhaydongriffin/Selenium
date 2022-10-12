; NOTE!  We can not longer run this as admin
;	Running as admin will make binary Chrome programs (like Janison Replay) also run as admin
;	and this in turn will fail "UI Automation" (Windows UI automation) in scripts which should be running not elevated
;#RequireAdmin
#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>
#include <File.au3>
#include <WinAPISys.au3>
#include <WinAPIProc.au3>

; there is currently a bug in Selenium (v4.0.0 through 4.1.1) where calls to GetDevToolsSession throw an exception if the Selenium Grid is not
;	running on the local IP address of the computer, rather than "localhost" or "127.0.0.1".
;	To workaround this bug we use the local IP address of the computer @IPAddress1 and pass that into the hub config file "hubConfig4444.toml"
;	Bug URL = https://github.com/SeleniumHQ/selenium/issues/9956
;Global $hub_domain = "http://localhost:4444"
;Global $hub_domain = "http://127.0.0.1:4444"
Global $hub_domain = @IPAddress1
Global $hub_config_filename = "hubConfig4444.toml"
Local $node_config_filename = "nodeConfig5555.toml"	; more than one nodeConfig is supported below.  ie. nodeConfig5565.json, nodeConfig5566.json, etc...
Global $log_path = @ScriptDir & "\selenium_grid_control.log"
;Global $selenium_server_jar = "selenium-server-4.0.0-rc-3.jar"
;Global $selenium_server_jar = "selenium-server-4.0.0.jar"
Global $selenium_server_jar = "selenium-server-4.1.4.jar"

; if EnableLUA is not set to 1 then running elevated is a problem, see below...

Local $enable_lua = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "EnableLUA")

if @error = 0 And $enable_lua <> 1 Then

	MsgBox(0, "selenium grid control", "Aborting ""selenium grid control.exe""." & @CRLF & "EnableLUA is set to 0 in the Windows Registry." & @CRLF & "This can force all apps to run elevated and this app must be run as a regular user." & @CRLF & @CRLF & "Run ""regedit.exe"" and change EnableLUA to 1 in the following key and then reboot the computer ..." & @CRLF & @CRLF & "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System")
	_FileWriteLog($log_path, "Aborting.  This program was run as administrator (elevated user).  We cannot run Selenium Grid elevated as the programs (scripts) call it are not running elevated and this causes software like UIA in the scripts to fail.  EnableLUA is not set to 1 in registry key HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System")
	Exit 1
EndIf

; if the OS is Vista (ie. not Windows 7) then running elevated is a problem, see below...

if _WinAPI_IsElevated() = True And _OSVersion() <> 6.1 Then

	MsgBox(0, "selenium grid control", "Aborting ""selenium grid control.exe""." & @CRLF & "It was run with elevation / as admin." & @CRLF & "It must be run as a regular user." & @CRLF & "See ""selenium grid control.log"" for details")
	_FileWriteLog($log_path, "Aborting.  This program was run as administrator (elevated user).  We cannot run Selenium Grid elevated as the programs (scripts) call it are not running elevated and this causes software like UIA in the scripts to fail.  Try again without elevation")
	Exit 1
EndIf


Local $hub_config_str = FileRead("c:\Selenium\" & $hub_config_filename)
$hub_config_str = StringRegExpReplace($hub_config_str, 'host = ".*"', 'host = "' & $hub_domain & '"')
FileDelete("c:\Selenium\" & $hub_config_filename)
FileWrite("c:\Selenium\" & $hub_config_filename, $hub_config_str)

; If running for multiple desktops ...

if $CmdLine[0] > 0 Then

	$hub_domain = $CmdLine[1]

	if $CmdLine[0] <= 2 Then

		$hub_config_filename = ""
		$node_config_filename = $CmdLine[2]
	Else

		$hub_config_filename = $CmdLine[2]
		$node_config_filename = $CmdLine[3]
	EndIf
Else

	; If running for a single desktop (in the simple case), kill any old selenium grids that may already exist first

	for $i = 1 to 40

		if ProcessExists("java.exe") = True Then

			ProcessClose("java.exe")
		Else

			ExitLoop
		EndIf

		if ProcessExists("java.exe") = True Then

			ProcessClose("java.exe")
		Else

			ExitLoop
		EndIf

		Sleep(250)
	Next
EndIf

Global $java_path = ""

if FileExists($java_path) = False or FileGetSize($java_path) = 0 Then

	Local $tmp_path = _FileListToArrayRec("C:\Program Files\Java", "java.exe", 1, 1, 0, 2)

	if @error = 0 Then

		$java_path = $tmp_path[1]
	Else

		Local $tmp_path = _FileListToArrayRec("C:\Program Files (x86)\Java", "java.exe", 1, 1, 0, 2)

		if @error = 0 Then

			$java_path = $tmp_path[1]
		Else

			$java_path = "C:\ProgramData\Oracle\Java\javapath\java.exe"
		EndIf
	EndIf
EndIf

; Include TLSv1 in Java for Team Explorer Everywhere to work ...

Local $java_security_path = $java_path
$java_security_path = StringReplace($java_security_path, "\bin", "")
$java_security_path = StringReplace($java_security_path, "\java.exe", "")
$java_security_path = $java_security_path & "\lib\security\java.security"

if FileExists($java_security_path) = True Then

	Local $java_security_str = FileRead($java_security_path)
	$java_security_str = StringRegExpReplace($java_security_str, "(jdk.tls.disabledAlgorithms=.*)TLSv1,", "$1")

	if @extended > 0 Then

		FileDelete($java_security_path)
		FileWrite($java_security_path, $java_security_str)
	EndIf
EndIf


; selenium hub and nodes

; v3.141.59

if StringLen($hub_config_filename) > 0 Then

	; Selenium Hub

	_FileWriteLog($log_path, "ShellExecute """ & $java_path & """ -Xmx128m -jar c:\Selenium\" & $selenium_server_jar & " hub --session-request-timeout 3600 --config c:\Selenium\" & $hub_config_filename)
	$pid = ShellExecute($java_path, "-Xmx128m -jar c:\Selenium\" & $selenium_server_jar & " hub --session-request-timeout 3600 --config c:\Selenium\" & $hub_config_filename, @ScriptDir, "", @SW_MINIMIZE)
EndIf

; Selenium Node(s)

; If running for multiple desktops ...

;if $CmdLine[0] > 0 Then

	run_selenium_node($node_config_filename)
;Else

;	run_selenium_node($node_config_filename)

;	for $port_num = 5565 to 5665

;		$node_config_filename = "nodeConfig" & $port_num & ".json"
;		Local $node_run = run_selenium_node($node_config_filename)

;		if $node_run = False Then

;			ExitLoop
;		EndIf
;	Next
;EndIf

;move_pid_window($pid, 1950, 500)
;move_pid_window($pid, 2800, 500)


;Function for getting HWND from PID
Func _GetHwndFromPID($PID)
	ProcessWait($pid)

	$hWnd = 0
	$winlist = WinList()
	Do
		For $i = 1 To $winlist[0][0]
			If $winlist[$i][0] <> "" Then
				$iPID2 = WinGetProcess($winlist[$i][1])
				If $iPID2 = $PID Then
					$hWnd = $winlist[$i][1]
					ExitLoop
				EndIf
			EndIf
		Next
	Until $hWnd <> 0
	Return $hWnd
EndFunc;==>_GetHwndFromPID

Func move_pid_window($pid, $new_x, $new_y)

	$hwnd = _GetHwndFromPID($pid)
	WinMove($hwnd, "", $new_x, $new_y)

EndFunc

Func run_minimized($cmd)

	$pid = Run ($cmd, @ScriptDir);, "", @SW_MINIMIZE)
	$hwnd = _GetHwndFromPID($pid)
	WinSetState($hwnd, "", @SW_MINIMIZE)

EndFunc

Func run_selenium_node($node_config_filename)

	Local $node_config_path = "c:\Selenium\" & $node_config_filename

	if FileExists($node_config_path) Then

		Local $webdriver_arg = ""
		local $tmp_config_json = FileRead($node_config_path)
		Local $webdriver_chrome_driver = StringRegExp($tmp_config_json, "\""webdriver.chrome.driver\"":.*\""(.*)\""", 1)

		if @error = 0 Then

			$webdriver_chrome_driver[0] = StringReplace($webdriver_chrome_driver[0], "/", "\")
			$webdriver_chrome_driver[0] = StringReplace($webdriver_chrome_driver[0], "\\", "\")
			$webdriver_arg = "-Dwebdriver.chrome.driver=" & $webdriver_chrome_driver[0] & " "
		EndIf

		_FileWriteLog($log_path, "ShellExecute """ & $java_path & """ " & $webdriver_arg & "-Xmx128m -XX:ActiveProcessorCount=20 -jar c:\Selenium\" & $selenium_server_jar & " node --session-timeout 3600 --config " & $node_config_path)
		$pid = ShellExecute($java_path, $webdriver_arg & "-Xmx128m -XX:ActiveProcessorCount=20 -jar c:\Selenium\" & $selenium_server_jar & " node --session-timeout 3600 --config " & $node_config_path, @ScriptDir, "", @SW_MINIMIZE)
		return True
	EndIf

	Return False

EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _OSVersion
; Description ...: Returns the Windows version as registered in the registry.
; Syntax ........: _OSVersion([$sHostName = @ComputerName])
; Parameters ....: $sHostName - [optional] The host name (or IP address) of the host to retrieve the informatino for.
; Return values .: Success - Returns a numeric decimal value corrsponding to Windows version.
;                  Failure - Returns 0 and sets @error to 1.
; Author ........: orbs
; Modified ......:
; Remarks .......: * Continuously updating list of Windows versions is posted at the MSDN link hereunder. Info as per March 2015:
;                      Operating system                  Version number
;                      -----------------                 --------------
;                      Windows 10 Technical Preview      10.0
;                      Windows Server Technical Preview  10.0
;                      Windows 8.1                        6.3
;                      Windows Server 2012 R2             6.3
;                      Windows 8                          6.2
;                      Windows Server 2012                6.2
;                      Windows 7                          6.1
;                      Windows Server 2008 R2             6.1
;                      Windows Server 2008                6.0
;                      Windows Vista                      6.0
;                      Windows Server 2003 R2             5.2
;                      Windows Server 2003                5.2
;                      Windows XP 64-Bit Edition          5.2
;                      Windows XP                         5.1
;                      Windows 2000                       5.0
;                  * The returned value is numerical, although it is stored in the registry as a string (REG_SZ). This allows for
;                    numerical comparison, for example _OSVersion()<6 means XP/2003 or earlier, _OSVersion()>6.1 means the new
;                    and arguably hideous generation of Windows (featuring the "Metro" crap).
;                  * The relevant registry key is not affected by WOW64 (see 2nd MSDN link hereunder), so no need to use HKLM64.
;                  * The relevant registry branch contains other useful information, e.g. a string representation of the OS name
;                    and Service Pack level. For example:
;                      "Windows 7 Ultimate" data is stored in value "ProductName"
;                      "Service Pack 1" data is stored in value "CSDVersion"
;                  * To retrieve the information for another host over network, adequate connectivity and authorization required.
; Related .......:
; Link ..........: https://msdn.microsoft.com/en-us/library/windows/desktop/ms724832.aspx
;                  https://msdn.microsoft.com/en-us/library/windows/desktop/aa384253(v=vs.85).aspx
;                  http://stackoverflow.com/questions/14648796/currentversion-value-in-registry-for-each-windows-operating-system
; Example .......: No
; ===============================================================================================================================
Func _OSVersion($sHostName = @ComputerName)
    Local $sOSVersion = RegRead('\\' & $sHostName & '\HKLM\Software\Microsoft\Windows NT\CurrentVersion', 'CurrentVersion')
    If @error Then Return SetError(1, 0, 0)
    Return Number($sOSVersion)
EndFunc   ;==>_OSVersion

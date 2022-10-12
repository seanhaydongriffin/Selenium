#RequireAdmin
#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>
#include <File.au3>

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

Local $java_path = "C:\ProgramData\Oracle\Java\javapath\java.exe"

if FileExists($java_path) = False Then

	Local $tmp_path = _FileListToArrayRec("C:\Program Files\Java", "java.exe", 1, 1, 0, 2)

	if @error = 0 Then

		$java_path = $tmp_path[1]
	Else

		Local $tmp_path = _FileListToArrayRec("C:\Program Files (x86)\Java", "java.exe", 1, 1, 0, 2)

		if @error = 0 Then

			$java_path = $tmp_path[1]
		EndIf
	EndIf
EndIf

; selenium hub and nodes

; v3.12.0
;$pid = ShellExecute($java_path, "-Xmx128m -jar selenium-server-standalone-3.12.0.jar -role hub -timeout 3600 -hubConfig hubConfig.json", @ScriptDir, "", @SW_MINIMIZE)
$pid = ShellExecute($java_path, "-Xmx128m -jar selenium-server-standalone-3.12.0.jar -role node -hub http://10.1.1.202:4444/grid/register -nodeConfig nodeConfig.json", @ScriptDir, "", @SW_MINIMIZE)
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

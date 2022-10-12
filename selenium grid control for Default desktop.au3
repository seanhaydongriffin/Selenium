#RequireAdmin
#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>
#include <File.au3>
#include <WinAPISys.au3>
#include <WinAPIProc.au3>

; This app restarts selenium grid on multiple desktops on a computer

;Global $desktop_name[5] = ["Default", "Desktop1", "Desktop2", "Desktop3", "Desktop4"]
Global $hub_domain[5] = ["http://localhost:4444", "http://localhost:4444", "http://localhost:4444", "http://localhost:4444", "http://localhost:4444"]
Global $hub_config_filename[5] = ["hubConfig4444.toml", "", "", "", ""]
Global $node_config_filename[5] = ["nodeConfig5555.toml", "nodeConfig5556.toml", "nodeConfig5557.toml", "nodeConfig5558.toml", "nodeConfig5559.toml"]
Global $log_path = @ScriptDir & "\selenium_grid_control.log"

FileDelete($log_path)

; Default desktop

;$cmd = '"selenium grid control.exe" ' & $hub_domain[0] & " " & $hub_config_filename[0] & " " & $node_config_filename[0]
;ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $cmd = ' & $cmd & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
ShellExecuteWait("selenium grid control.exe", $hub_domain[0] & " " & $hub_config_filename[0] & " " & $node_config_filename[0], "C:\Selenium")
Sleep(1000)

for $i = 5565 to 5665

	Local $node_config_path = "c:\Selenium\nodeConfig" & $i & ".toml"

	if FileExists($node_config_path) Then

;		$cmd = '"selenium grid control.exe" ' & $hub_domain[0] & ' nodeConfig' & $i & '.toml'
;		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $cmd = ' & $cmd & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
		ShellExecuteWait("selenium grid control.exe", $hub_domain[0] & " nodeConfig" & $i & ".toml", "C:\Selenium")
		Sleep(1000)
	Else

		ExitLoop
	EndIf
Next

; Other desktops

;ShellExecute("DesktopSwitcher.exe", "", "C:\Selenium")

;for $desktop_index = 1 to (UBound($desktop_name) - 1)

;	Local $hDesktop1 = _WinAPI_CreateDesktop($desktop_name[$desktop_index], $DESKTOP_ALL_ACCESS)

;	If Not $hDesktop1 Then
;		MsgBox(BitOR($MB_ICONERROR, $MB_SYSTEMMODAL), 'Error', 'Unable to create desktop.')
;		Exit
;	EndIf

	;;;_WinAPI_SetThreadDesktop($hDesktop1)
	;;;_WinAPI_SwitchDesktop($hDesktop1)

;	run_on_desktop($desktop_name[$desktop_index], "C:\Selenium\DesktopSwitcher.exe " & $desktop_name[$desktop_index])
;	run_on_desktop($desktop_name[$desktop_index], "C:\Selenium\selenium grid control.exe " & $hub_domain[$desktop_index] & " " & $hub_config_filename[$desktop_index] & " " & $node_config_filename[$desktop_index])

	;;;_WinAPI_CloseDesktop($hDesktop1)

;Next


func run_on_desktop($desktop_name, $executable_path)

	Local $pText = _WinAPI_CreateString($desktop_name)
	Local $tProcess = DllStructCreate($tagPROCESS_INFORMATION)
	Local $tStartup = DllStructCreate($tagSTARTUPINFO)
	DllStructSetData($tStartup, 'Size', DllStructGetSize($tStartup))
	DllStructSetData($tStartup, 'Desktop', $pText)
	_WinAPI_CreateProcess('', $executable_path, 0, 0, 0, $CREATE_NEW_PROCESS_GROUP, 0, 0, $tStartup, $tProcess)

	;_WinAPI_WaitForInputIdle
	_WinAPI_FreeMemory($pText)
EndFunc


func desktop_exists($desktop_name)

	Local $aData = _WinAPI_EnumDesktops(_WinAPI_GetProcessWindowStation())

	for $i = 1 to $aData[0]

		if StringCompare($desktop_name, $aData[$i]) = 0 Then

			Return True
		EndIf
	Next

	Return False
EndFunc

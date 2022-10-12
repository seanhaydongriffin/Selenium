#RequireAdmin
#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>
#include <File.au3>
#include <WinAPISys.au3>
#include <WinAPIProc.au3>






; This app restarts selenium grid on multiple desktops on a computer

Global $desktop_name[5] = ["Default", "Desktop1", "Desktop2", "Desktop3", "Desktop4"]
Global $hub_domain[5] = ["http://localhost:4444", "http://localhost:4444", "http://localhost:4444", "http://localhost:4444", "http://localhost:4444"]
Global $hub_config_filename[5] = ["defaultHubConfig.json", "defaultHubConfig.json", "", "", ""]
Global $node_config_filename[5] = ["defaultNodeConfig.json", "desktop1NodeConfig.json", "desktop2NodeConfig.json", "desktop3NodeConfig.json", "desktop4NodeConfig.json"]

;Global $hub_domain[5] = ["http://localhost:4444", "http://localhost:4445", "http://localhost:4446", "http://localhost:4447", "http://localhost:4448"]
;Global $hub_config_filename[5] = ["defaultHubConfig.json", "desktop1HubConfig.json", "desktop2HubConfig.json", "desktop3HubConfig.json", "desktop4HubConfig.json"]
;Global $node_config_filename[5] = ["defaultNodeConfig.json", "desktop1NodeConfig.json", "desktop2NodeConfig.json", "desktop3NodeConfig.json", "desktop4NodeConfig.json"]

; Remove any selenium grids, automation adapters and desktop switchers

for $i = 1 to 10

	if ProcessExists("java.exe") = True Then

		ProcessClose("java.exe")
	EndIf

	if ProcessExists("java.exe") = True Then

		ProcessClose("java.exe")
	EndIf

	if ProcessExists("Automation Adapter.exe") = True Then

		ProcessClose("Automation Adapter.exe")
	EndIf

	if ProcessExists("Automation Adapter.exe") = True Then

		ProcessClose("Automation Adapter.exe")
	EndIf

	if ProcessExists("DesktopSwitcher.exe") = True Then

		ProcessClose("DesktopSwitcher.exe")
	EndIf

	if ProcessExists("DesktopSwitcher.exe") = True Then

		ProcessClose("DesktopSwitcher.exe")
	EndIf

	if ProcessExists("java.exe") = False and ProcessExists("Automation Adapter.exe") = False and ProcessExists("DesktopSwitcher.exe") = False Then

		ExitLoop
	EndIf

	Sleep(250)
Next

Exit

; desktops

ShellExecute("DesktopSwitcher.exe", "", "C:\Selenium")

for $desktop_index = 1 to (UBound($desktop_name) - 1)

	Local $hDesktop1 = _WinAPI_CreateDesktop($desktop_name[$desktop_index], $DESKTOP_ALL_ACCESS)

	If Not $hDesktop1 Then
		MsgBox(BitOR($MB_ICONERROR, $MB_SYSTEMMODAL), 'Error', 'Unable to create desktop.')
		Exit
	EndIf

	;_WinAPI_SetThreadDesktop($hDesktop1)
	;_WinAPI_SwitchDesktop($hDesktop1)

;	run_on_desktop($desktop_name[$desktop_index], @WindowsDir & '\explorer.exe')
;	run_on_desktop($desktop_name[$desktop_index], @SystemDir & '\userinit.exe')
;	run_on_desktop($desktop_name[$desktop_index], 'C:\Selenium\selenium_grid_control_auto1.exe')
;	run_on_desktop($desktop_name[$desktop_index], "C:\Windows\explorer.exe")
;	run_on_desktop($desktop_name[$desktop_index], "C:\Windows\explorer.exe")
	run_on_desktop($desktop_name[$desktop_index], "C:\Selenium\DesktopSwitcher.exe " & $desktop_name[$desktop_index])
	run_on_desktop($desktop_name[$desktop_index], "C:\Selenium\selenium grid control.exe " & $hub_domain[$desktop_index] & " " & $hub_config_filename[$desktop_index] & " " & $node_config_filename[$desktop_index])
;	_WinAPI_CloseDesktop($hDesktop1)

Next

; Automation Adapter

run_on_desktop($desktop_name[1], "C:\CoPilot\Automation Adapter.exe")


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


!include nsDialogs.nsh
;!include LogicLib.nsh


; example1.nsi
;
; This script is perhaps one of the simplest NSIs you can make. All of the
; optional settings are left to their default settings. The installer simply 
; prompts the user asking them where to install, and drops a copy of example1.nsi
; there. 

XPStyle on

;--------------------------------

; The name of the installer
Name "Selenium"

; The file to write
OutFile "Selenium setup.exe"

; The default installation directory
InstallDir "C:\Selenium"

; Request application privileges for Windows Vista
RequestExecutionLevel user

;--------------------------------


; Pages

Page directory
Page custom nsDialogsPage nsDialogsPageLeave
Page instfiles


;--------------------------------


Var Checkbox
Var Checkbox_State

Function nsDialogsPage
	nsDialogs::Create 1018
	Pop $0

	${NSD_CreateCheckbox} 0 -50 100% 8u 'Create task "Selenium\Automation Share" to run Selenium Grid On Logon'
	Pop $Checkbox

	nsDialogs::Show
FunctionEnd

Function nsDialogsPageLeave

	${NSD_GetState} $Checkbox $Checkbox_State
	
	${If} $Checkbox_State == ${BST_CHECKED}
		;MessageBox MB_OK checked!
		ExecWait '$SYSDIR\schtasks.exe /CREATE /SC ONLOGON /TN "Seleniun\Automation Share" /TR "C:\Selenium\selenium grid control.exe"'
	${EndIf}

FunctionEnd


;--------------------------------



; The stuff to install
Section "" ;No components page, name is not important

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  
  ; Remove old Assemblies
  RMDir /r $INSTDIR\Assemblies
  
  ; Put new Assemblies
  File /r "Assemblies"

  ; Remove old packages
  RMDir /r "$INSTDIR\packages"
  
  ; Put new packages
  File /r "packages"

  ; Put all other Selenium specific files
  File "chromedriver.exe"
  File "chromedriver-2.44.exe"
  File "chromedriver-83.0.4103.39.exe"
  File "chromedriver-101.0.4951.41.exe"
  File "IEDriverServer.exe"
  File "msedgedriver.exe"
  File "msedgedriver-99.0.1150.46.exe"
  File "geckodriver.exe"
  File "hubConfig4444.toml"
  File "nodeConfig5555.toml"
  File "nodeConfig5556.toml"
  File "nodeConfig5557.toml"
  File "nodeConfig5558.toml"
  File "nodeConfig5559.toml"
  File "nodeConfig5565.toml"
  File "nodeConfig5566.toml"
  File "Selenium Adapter.exe"
  File "selenium grid control for Default desktop.exe"
  File "selenium grid control for Default desktop.au3"
  File "selenium grid control for Desktop1 desktop.exe"
  File "selenium grid control for Desktop1 desktop.au3"
  File "selenium grid control.exe"
  File "selenium grid control.au3"
  File "selenium grid control2.exe"
  File "selenium grid control2.au3"
  File "selenium node for mac.exe"
  File "selenium node for mac.au3"
  File "selenium-server-4.1.4.jar"
  File /r "Firefox"
  File /r "Chrome"


SectionEnd ; end the section


*** Settings ***
Documentation    Opening the application
Library    OperatingSystem
Library    RemoteSwingLibrary   debug=True
#Suite Setup     FileServer.Start
#Suite Teardown    Clean Up
#Force tags      Webstart


*** Variables ***
# ${WEBSTART DIR}=    ${CURDIR}/webstart

*** Test Cases ***
POC
    start application    test-app   javaws C:\\Workspace\\my_swingLibrary\\Test\\twm.jnlp   timeout=60  close_security_dialogs=True
    Set Jemmy Timeouts  15
    Select Main Window
    #Select Context  2
    #Select Context  4
    #Select Context  1
    Type Into Textfield     0   EBASCO
    Type Into Textfield     1   1
    Push Button     0
    Set Jemmy Timeout   WindowWaiter.WaitWindowTimeout  15
    List Windows
    List Components in Context  formatted
    #Push Button     No
    #Label Should Exist   Login name
    #Ensure Application Should Close    5 seconds   Push Button  systemExitButton

*** Keywords ***
Close My App
    System Exit
#    Clean Up
#    FileServer.Stop
    Remove Files  *.png
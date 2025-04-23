*** Settings ***
Documentation     This resource file is created to extend simple keywords from Selenium Library
Library           SeleniumLibrary
Library           BuiltIn
Library           String
Library           OperatingSystem

*** Variables ***


*** Keywords ***
Open Window
    [Documentation]    This keyword is used to open new tab/window in the same browser which is currently active
    [Arguments]        ${url_to_open}=${EMPTY}
    Execute Javascript    window.open('${url_to_open}');






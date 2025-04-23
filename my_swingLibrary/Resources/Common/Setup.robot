*** Settings ***
Documentation     This resource file is used for common setup and teardown robot keyowrds used for Generic Test Automation
Library           SeleniumLibrary
Library           BuiltIn
Library           String
Library           OperatingSystem
Library           DateTime

*** Variables ***
${WEB_BROWSER}             chrome
${DEFAULT_DOWNLOADS_DIR}   ${EXECDIR}/Results
${LOG_LEVEL_STATUS}        INFO
${SELENIUM_SPEED}          0.005s
${SELENIUM_IMPLICIT_WAIT}  0.1s

${PARALLEL_EXECUTION}      1
${ARGUMENT_FILE}           sample_argument_file.txt

*** Keywords ***

##################################
##### USER BROWSER FUNCTIONS #####
##################################

User to Open Browser
    [Documentation]    This keyword is used to open a browser or another browser, default browser to use is chrome
    [Arguments]        ${browser_to_open}=${WEB_BROWSER}    ${browser_alias}=${browser_to_open}
    Set Log Level               level=${LOG_LEVEL_STATUS}
    Open Browser                browser=${browser_to_open}    alias=${browser_alias}
    Set Selenium Speed          ${SELENIUM_SPEED}
    Set Selenium Implicit Wait  ${SELENIUM_IMPLICIT_WAIT}
    Maximize Browser Window

User to Open Browser with preferred options
    [Documentation]             This Keyword is used to specify desired capabilities of a browser and change the default options
    ...                         Option 1: Downloads Directory (Default is Results Folder)
    [Arguments]                 ${preferred_downloads_directory}=${DEFAULT_DOWNLOADS_DIR}
    Set Log Level               level=${LOG_LEVEL_STATUS}
    Set Selenium Speed          ${SELENIUM_SPEED}
    Set Selenium Implicit Wait  ${SELENIUM_IMPLICIT_WAIT}
    Run Keyword If              '${WEB_BROWSER}' in 'googlechrome chrome gc'
    ...                         Open Chrome Browser with preferred options        ${preferred_downloads_directory}

User to Close Browser
    Close Browser

User to Close All Browsers
    Close All Browsers

#############################
##### SUPPORT FUNCTIONS #####
#############################

Open Chrome Browser with preferred options
    [Documentation]       This keyword is using chrome browser and specifies intended capabilities before starting it
    [Arguments]           ${preferred_downloads_directory}=${DEFAULT_DOWNLOADS_DIR}
    ${preferred_downloads_directory}=   Normalize Path    ${preferred_downloads_directory}
    Create Directory      ${preferred_downloads_directory}
    ${chrome_options}=    Evaluate                 sys.modules['selenium.webdriver'].ChromeOptions()       sys, selenium.webdriver
    ${prefs}=             Create Dictionary        download.default_directory=${preferred_downloads_directory}        safebrowsing.enabled=false
    Call Method           ${chrome_options}        add_experimental_option         prefs                   ${prefs}
    ${options}=           Call Method              ${chrome_options}               to_capabilities
    Open Browser          browser=${WEB_BROWSER}   desired_capabilities=${options}
    Maximize Browser Window

Get Test Case Reference Number
    [Documentation]    This keyword is used to generate reference number that a test case will be using
    ...                It will return a unique set of test case reference dependent on date-time and 3 digit test case number
    ...                The Argument should be 3 digit test case number
    [Arguments]        ${tc_number}
    ${current_date}=       Get Current Date      result_format=%y%m%d%H%M%S     exclude_millis=yes
    ${tc_reference_no}=    Set Variable          ${current_date}${tc_number}
    [Return]               ${tc_reference_no}

Get Current Date Today
    [Documentation]    This keyword is used to get the date today
    ...                It will return a date in default format DD/MM/YY
    [Arguments]        ${result_date_format}=%d/%m/%Y
    ${date_today}=     Get Current Date    result_format=${result_date_format}    exclude_millis=yes
    [Return]           ${date_today}

Get Yesterday Date
    [Documentation]    This keyword is used to get the date yesterday
    ...                It will return a date in default format DD/MM/YY
    [Arguments]        ${result_date_format}=%d/%m/%Y
    ${yesterday_date}  Get Current Date    result_format=${result_date_format}    increment=-24:00:00    exclude_millis=yes
    [Return]           ${yesterday_date}

Get Tomorrow Date
    [Documentation]    This keyword is used to get the date yesterday
    ...                It will return a date in default format DD/MM/YY
    [Arguments]        ${result_date_format}=%d/%m/%Y
    ${tomorrow_date}   Get Current Date    result_format=${result_date_format}    increment=+24:00:00    exclude_millis=yes
    [Return]           ${tomorrow_date}

Test Execution Delay Start
    [Documentation]    This keyword is used to setup random delay before starting test execution, useful in parallel execution with intermittency in parallel
    [Tags]             Support_Functions
    Return From Keyword If  '${PARALLEL_EXECUTION}' == '1'  Done
    ${exec_delay_file}=     Set Variable                    ${DEFAULT_DOWNLOADS_DIR}/test_exec_delay_start.txt
    ${test_delay_count}=    Evaluate                        (int(${PARALLEL_EXECUTION}) * 1) - 1
    ${retest_delay_count}=  Evaluate                        (int(${PARALLEL_EXECUTION}) * 2) - 1
    ${delay_count}=         Set Variable If                 'retest' in '${ARGUMENT_FILE}'    ${retest_delay_count}    ${test_delay_count}
    Touch                   ${exec_delay_file}
    ${file_content}=        Get File                        ${exec_delay_file}
    ${line_count}=          Get Line Count                  ${file_content}
    Return From Keyword If  ${line_count} > ${delay_count}  Done
    ${random_delay}=        Generate Random String          1     0123456
    ${delay_time}=          Evaluate                        10 * int(${random_delay})
    Sleep                   ${delay_time}s
    Append To File          ${exec_delay_file}              ${delay_time}s\n


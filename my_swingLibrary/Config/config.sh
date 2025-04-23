#!/bin/bash

#################################################################################################################
#################################################################################################################
###### Purpose: This File is used to create argument file that will be used during Test Execution Build
######          Also, this config script is compatible and tried with Teamcity only
###### Author: Noel Sinsioco
###### Date Created: December 29, 2020
###### Modified by: Noel Sinsioco
###### Last Date Modified: March 15, 2021
###### Usage:
###### In Windows or command prompt, it should be run:
######     >Config\config.sh
###### In Linux or command line, it should be run:
######     $./Config/config.sh
###### In Teamcity Command Line
######     $./Config/config.sh %CONFIG% %BRANCH% %LOG_LEVEL_STATUS% %INCLUSIONS% %EXCLUSIONS% %PARALLEL_EXECUTION% %TEST_CASE%
###### Parameters:
######     1. CONFIG
######            - VALUEWEBB_ERC_CG_QA, VALUEWEBB_ERC_CG_UAT
######     2. BRANCH
######            - master, development or <feature_branches>
######     3. LOG_LEVEL_STATUS
######            - INFO, DEBUG, TRACE
######     4. INCLUSIONS
######            - ALL, Functional_Test, Smoke_Test, Regression_Test, High_Risk, Medium_Risk, Low_Risk
######     5. EXCLUSIONS
######            - none, Functional_Test, Smoke_Test, Regression_Test, High_Risk, Medium_Risk, Low_Risk
######     6. PARALLEL_EXECUTION
######            - 2 or more (depending on the available cores of the team city agent)
######     7. TEST_CASE
######            - ALL or 0001, 0002, 0003, <etc>
#################################################################################################################
#################################################################################################################
echo "Starting Config Script"
#################################################################################################################
#################################################################################################################
## Parameters
echo "Getting the parameters"
CONFIG=${1:-VALUEWEBB_ERC_CG_QA}
BRANCH=${2:-master}
LOG_LEVEL_STATUS=${3:-INFO}
INCLUSIONS=${4:-ALL}
EXCLUSIONS=${5:-none}
PARALLEL_EXECUTION=${6:-2}
TEST_CASE=${7:-ALL}

## Processing of Parameters
echo "Processing the parameters"
test_module="$(echo $CONFIG | cut -d'_' -f2)"
test_country="$(echo $CONFIG | cut -d'_' -f3)"
test_server="$(echo $CONFIG | cut -d'_' -f4)"
test_case_directory="Tests/${test_module}_Module_${test_country}"

## Main Variables that will be used
echo "Setting the parameters"
output_directory="Results"
VALUEWEBB_TEST_MODULE=$test_module
VALUEWEBB_TEST_COUNTRY=$test_country
VALUEWEBB_TEST_SERVER=$test_server

ROBOT_TEST_SETUP_TAG="Test_Setup"
SETUP_FAILED_MESSAGE="Test_Setup_Failed"
SETUP_TEST_RESULT_FILE=${output_directory}/Test_Setup_Results.txt

ROBOT_OBSOLETE_TAG="Obsolete"
QA_TEST_TAG="QA_Test"
UAT_TEST_TAG="UAT_Test"

test_setup_filename="Variables/test_setup_arguments.txt"
test_filename="Variables/test_arguments.txt"
retest_filename="Variables/retest_arguments.txt"
final_filename="Variables/final_arguments.txt"
test_setup_executor="Config/test_setup_executor.sh"
robot_executor="Config/robot_executor.sh"
pabot_executor="Config/pabot_executor.sh"

test_setup_output_xml="output_setup.xml"
test_setup_log_html="log_setup.html"
test_setup_report_html="report_setup.html"
test_setup_debg_log="debug_setup.log"

test_output_xml="${CONFIG}_1_test_output.xml"
test_log_html="${CONFIG}_1_test_log.html"
test_report_html="${CONFIG}_1_test_report.html"
test_debg_log="${CONFIG}_1_test_debug.log"

retest_output_xml="${CONFIG}_2_retest_output.xml"
retest_log_html="${CONFIG}_2_retest_log.html"
retest_report_html="${CONFIG}_2_retest_report.html"
retest_debg_log="${CONFIG}_2_retest_debug.log"

final_output_xml="${CONFIG}_final_output.xml"
final_log_html="${CONFIG}_final_log.html"
final_report_html="${CONFIG}_final_report.html"
final_xunit_xml="${CONFIG}_final_xunit.xml"
#################################################################################################################
## Setup Execution using test_setup_filename
echo "Creating test_setup_arguments.txt"

echo --name ${CONFIG}_Setup > $test_setup_filename
echo --outputdir $output_directory >> $test_setup_filename
echo --variable VALUEWEBB_TEST_MODULE:$VALUEWEBB_TEST_MODULE >> $test_setup_filename
echo --variable VALUEWEBB_TEST_COUNTRY:$VALUEWEBB_TEST_COUNTRY >> $test_setup_filename
echo --variable VALUEWEBB_TEST_SERVER:$VALUEWEBB_TEST_SERVER >> $test_setup_filename
echo --variable BRANCH:$BRANCH >> $test_setup_filename
echo --variable LOG_LEVEL_STATUS:$LOG_LEVEL_STATUS >> $test_setup_filename
echo --variable SETUP_TEST_RESULT_FILE:$SETUP_TEST_RESULT_FILE >> $test_setup_filename
echo --variable SETUP_FAILED_MESSAGE:$SETUP_FAILED_MESSAGE >> $test_setup_filename

echo --include $ROBOT_TEST_SETUP_TAG >> $test_setup_filename

echo --output $test_setup_output_xml >> $test_setup_filename
echo --log $test_setup_log_html >> $test_setup_filename
echo --report $test_setup_report_html >> $test_setup_filename
echo --debugfile $test_setup_debg_log >> $test_setup_filename

#################################################################################################################
## Test Execution using test_filename
echo "Creating test_arguments.txt"

echo --name $CONFIG > $test_filename
echo --outputdir $output_directory >> $test_filename
echo --variable VALUEWEBB_TEST_MODULE:$VALUEWEBB_TEST_MODULE >> $test_filename
echo --variable VALUEWEBB_TEST_COUNTRY:$VALUEWEBB_TEST_COUNTRY >> $test_filename
echo --variable VALUEWEBB_TEST_SERVER:$VALUEWEBB_TEST_SERVER >> $test_filename
echo --variable BRANCH:$BRANCH >> $test_filename
echo --variable LOG_LEVEL_STATUS:$LOG_LEVEL_STATUS >> $test_filename

if [ "$INCLUSIONS" != "ALL" ]; then
    for includes in $(echo $INCLUSIONS | tr "," "\n")
    do
        echo --include $includes >> $test_filename
    done
fi

echo --exclude $ROBOT_TEST_SETUP_TAG >> $test_filename
echo --exclude $ROBOT_OBSOLETE_TAG >> $test_filename
if [ "$test_server" != "QA" ]; then
    echo --exclude $QA_TEST_TAG >> $test_filename
fi
if [ "$test_server" != "UAT" ]; then
    echo --exclude $UAT_TEST_TAG >> $test_filename
fi
if [ "$EXCLUSIONS" != "none" ]; then
    for excludes in $(echo $EXCLUSIONS | tr "," "\n")
    do
        echo --exclude $excludes >> $test_filename
    done
fi

echo --output $test_output_xml >> $test_filename
echo --log $test_log_html >> $test_filename
echo --report $test_report_html >> $test_filename
echo --debugfile $test_debg_log >> $test_filename

if [ "$TEST_CASE" != "ALL" ]; then
    for test_cases in $(echo $TEST_CASE | tr "," "\n")
    do
        test_case_to_execute="Test Case $((10#$test_cases)) [a-zA-Z]*"
        #test_case_to_execute="Test Case $test_cases [a-zA-Z]*"
        echo --test "$test_case_to_execute" >> $test_filename
    done
fi

#################################################################################################################
## Retest Execution using retest_filename
echo "Creating retest_arguments.txt"

echo --name $CONFIG > $retest_filename
echo --outputdir $output_directory >> $retest_filename
echo --variable VALUEWEBB_TEST_MODULE:$VALUEWEBB_TEST_MODULE >> $retest_filename
echo --variable VALUEWEBB_TEST_COUNTRY:$VALUEWEBB_TEST_COUNTRY >> $retest_filename
echo --variable VALUEWEBB_TEST_SERVER:$VALUEWEBB_TEST_SERVER >> $retest_filename
echo --variable BRANCH:$BRANCH >> $retest_filename
echo --variable LOG_LEVEL_STATUS:$LOG_LEVEL_STATUS >> $retest_filename

echo --rerunfailed ${output_directory}/${test_output_xml} >> $retest_filename
echo --output $retest_output_xml >> $retest_filename
echo --log $retest_log_html >> $retest_filename
echo --report $retest_report_html >> $retest_filename
echo --debugfile $retest_debg_log >> $retest_filename

#################################################################################################################
## Merging of 2 Results using final_filename
echo "Creating final_arguments.txt"

echo --name $CONFIG > $final_filename
echo --outputdir $output_directory >> $final_filename
echo --tagstatexclude $QA_TEST_TAG >> $final_filename
echo --tagstatexclude $UAT_TEST_TAG >> $final_filename

echo --output $final_output_xml >> $final_filename
echo --log $final_log_html >> $final_filename
echo --report $final_report_html >> $final_filename
echo --xunit $final_xunit_xml >> $final_filename

#################################################################################################################
#################################################################################################################
echo "Creating test_setup_executor.sh"
echo "#!/bin/bash" > $test_setup_executor
echo "robot -A $test_setup_filename $test_case_directory" >> $test_setup_executor
echo "fail_count=\$(grep -ic '${SETUP_FAILED_MESSAGE}' ${SETUP_TEST_RESULT_FILE})" >> $test_setup_executor
echo "if [ \$fail_count -eq 0 ]" >> $test_setup_executor
echo "then" >> $test_setup_executor
echo "    echo 'Test Setup Passed'" >> $test_setup_executor
echo "    exit 0" >> $test_setup_executor
echo "else" >> $test_setup_executor
echo "    echo 'Test Setup Failed'" >> $test_setup_executor
echo "    exit 1" >> $test_setup_executor
echo "fi" >> $test_setup_executor

echo "Creating robot_executor.sh"
echo "robot -A $test_filename $test_case_directory" > $robot_executor
echo "robot -A $retest_filename $test_case_directory" >> $robot_executor
echo "rebot -A $final_filename --merge ${output_directory}/*output.xml" >> $robot_executor
echo "exit 0" >> $robot_executor

echo "Creating pabot_executor.sh"
echo "pabot --processes $PARALLEL_EXECUTION --pabotlib -A $test_filename $test_case_directory" > $pabot_executor
echo "pabot --processes $PARALLEL_EXECUTION --pabotlib -A $retest_filename $test_case_directory" >> $pabot_executor
echo "rebot -A $final_filename --merge ${output_directory}/*output.xml" >> $pabot_executor
echo "exit 0" >> $pabot_executor
#################################################################################################################
#################################################################################################################
##### Team City Execution Command Line    ### For Linux based Team City Agent Only
##### Step 1. Test Precondition Cleanup
#####      $ git clean -fd
#####      $ new_build_no=%CONFIG%.$(date +"%%y%%m%%d").%build.counter%
#####      $ echo "##teamcity[buildNumber '"$new_build_no"']"
#####      $ curl -H "Content-Type:text/plain" -u "%system.teamcity.auth.userId%:%system.teamcity.auth.password%" --request POST "%teamcity.serverUrl%/app/rest/builds/id:%teamcity.build.id%/tags/" --data %teamcity.build.triggeredBy.username%
##### Step 2. Check Environment Versions
#####      $ export PATH="$PATH:/home/ta/.local/bin/"
#####      $ python --version
#####      $ robot --version
#####      $ rebot --version
#####      $ git --version
#####      $ google-chrome --version
#####      $ pip3 list
#####      $ echo $PATH
##### Step 3. Setup Argument File
#####      $ export PATH="$PATH:/home/ta/.local/bin/"
#####      $ chmod 777 Config/config.sh
#####      $ ./Config/config.sh %CONFIG% %BRANCH% %LOG_LEVEL_STATUS% %INCLUSIONS% %EXCLUSIONS% %PARALLEL_EXECUTION% %TEST_CASE%
##### Step 4. Test Setup Check
#####      $ export PATH="$PATH:/home/ta/.local/bin/"
#####      $ chmod 777 Config/test_setup_executor.sh
#####      $ ./Config/test_setup_executor.sh
##### Step 5. Test Executions
#####      $ export PATH="$PATH:/home/ta/.local/bin/"
#####      $ chmod 777 Config/pabot_executor.sh
#####      $ ./Config/pabot_executor.sh
#####      or
#####      $ export PATH="$PATH:/home/ta/.local/bin/"
#####      $ chmod 777 Config/robot_executor.sh
#####      $ ./Config/robot_executor.sh
#################################################################################################################
#################################################################################################################
##### Artifacts Path
#####      Results/*
#####      Variables/test_arguments.txt
#####      Variables/retest_arguments.txt
#####      Variables/final_arguments.txt
#################################################################################################################
#################################################################################################################
##### XML Report Processing
#####      Results/*xunit.xml
#################################################################################################################
#################################################################################################################
echo "End of Config Script"



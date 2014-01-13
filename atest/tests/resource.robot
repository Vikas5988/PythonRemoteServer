*** Settings ***
Library           OperatingSystem
Library           Process
Library           Collections

*** Variables ***
${INTERPRETER}    python

*** Keywords ***
Start And Import Remote Library
    [Arguments]    ${library}
    Set Pythonpath
    ${port} =    Start Remote Library    ${library}
    Import Library    Remote    http://127.0.0.1:${port}
    Set Log Level    DEBUG

Start Remote Library
    [Arguments]    ${library}    ${port}=0
    ${library} =    Normalize Path    ${CURDIR}/../libs/${library}
    ${port file} =    Normalize Path    ${CURDIR}/../results/server_port.txt
    ${output} =    Normalize Path    ${CURDIR}/../results/server_output.txt
    Start Process    ${INTERPRETER}    ${library}    ${port}    ${port file}
    ...    alias=${library}    stdout=${output}    stderr=STDOUT
    Run Keyword And Return    Read Port File    ${port file}

Read Port File
    [Arguments]    ${path}
    Wait Until Created    ${path}    timeout=30s
    Run Keyword And Return   Get File    ${path}
    [Teardown]    Remove File    ${path}

Set Pythonpath
    ${src} =    Normalize Path    ${CURDIR}/../../src
    Set Environment Variable    PYTHONPATH    ${src}
    Set Environment Variable    JYTHONPATH    ${src}
    Set Environment Variable    IRONPYTHONPATH    ${src}

Stop Remote Library
    [Arguments]    ${library}=${NONE}
    Stop Remote Server
    ${result} =    Wait For Process    ${library}    10s    terminate
    Log    ${result.stdout}
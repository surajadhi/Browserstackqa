*** Settings ***
Library    SeleniumLibrary
Library    Collections
Library    String

*** Variables ***
${wait_time}      10
${short_wait_time}    5
${long_wait_time}    20

*** Keywords ***
Find And Click Element
    [Arguments]
    ...    ${element}
    ...    ${timeout}=${wait_time}
    ...    ${validate_elementvisible}=None
    ...    ${element_goneafterclick}=False
    [Documentation]
    ...    >Element waits to be visible and then clicks on element.
    ...    >Timeout is the amount of time the function waits for the element to be visible.
    ...    >If validate_elementvisible is entered, the function will perform a validation check to
    ...    ensure the expected element is present in the DOM of the page and is also visible.
    ...    >If element_goneafterclick is passed as True, verifies the element is not appearing after click.

    # =========================
    Wait Until Element Is Visible    ${element}    ${timeout}
    Wait Until Keyword Succeeds    2x    1s    Click Element    ${element}
    # =========================
    ${half_timeout}=    Evaluate    ${timeout}/2
    IF    ${element_goneafterclick}
    ...    Wait Until Keyword Succeeds
    ...    2x    1s    Element gone or not visible    ${element}    timeout=${half_timeout}

    IF    '''${validate_elementvisible}'''!='''None'''
    ...    Verify Element On Page    ${validate_elementvisible}

Element gone or not visible
    [Arguments]    ${element}    ${timeout}=${wait_time}
    ${elementgone_firstcheck}=
    ...    Run Keyword And Return Status
    ...    Wait Until Element Is Not Visible    ${element}    ${timeout}
    Run Keyword If    ${elementgone_firstcheck}==False
    ...    Wait Until Page Does Not Contain Element    ${element}    2

Verify Element On Page
    [Arguments]
    ...    ${element}
    ...    ${timeout}=${wait_time}
    # =========================
    ${half_timeout}=    Evaluate    ${timeout}/2
    # =========================
    Wait Until Keyword Succeeds    2x    2s
    ...    Wait Until Page Contains Element   ${element}    ${half_timeout}
    Wait Until Element Is Visible      ${element}    ${timeout}
    Element Should Be Visible          ${element}

Verify Element Not On Page
    [Arguments]
    ...    ${element}
    ...    ${timeout}=${wait_time}

    Wait Until Element Is Not Visible    ${element}    ${timeout}
    Element Should Not Be Visible        ${element}

Clear And Type Into Element
    [Arguments]
    ...    ${field_location}
    ...    ${text_entry}
    ...    ${timeout}=${wait_time}
    ...    ${fast_type_mode}=True
    ...    ${slow_mode_delay}=0.1
    ...    ${click_element}=False
    [Documentation]    This keyword waits until the field_location is visible, clears any text
    ...                in the field_location, then enters the 'text_entry' into it.
    ...                Added option to type into a field_location in "slow mode", as there are 
    ...                some cases where the keyword "Input Text" enters text too quickly for 
    ...                certain fields and causes failures. setting fast_type_mode to False will
    ...                use the slow mode method. You can also control the speed of the typing in
    ...                slow mode by setting slow_mode_delay to a numerical setting in
    ...                seconds/milliseconds.

    Wait Until Element Is Visible         ${field_location}    ${timeout}
    IF    ${click_element}
    ...    Find And Click Element    ${field_location}
    IF    ${fast_type_mode}
    ...    Input Text                     ${field_location}    ${text_entry}
    ...    ELSE    Input Text - Slow Mode    ${field_location}    ${text_entry}    ${slow_mode_delay}

Input Text - Slow Mode
    [Arguments]
    ...    ${field location}
    ...    ${text entry}
    ...    ${slow_mode_delay}=0.1
    [Documentation]    This function is used with "Clear And Type Into Element" function. It can be
    ...                triggered from that function by passing the optional argument
    ...                "fast_type_mode=False" along with the field location and text entry
    ...                arguments.
    ...                Keyword breaks text_entry string into characters, then loops through them,
    ...                simulating a press key for each character. To control the speed of the
    ...                input, slow_mode_delay can be set to whatever number is needed. Defaults to
    ...                1/10 of a second (0.1).
    @{text_characters}=    Split String To Characters    ${text entry}
    FOR    ${char}    IN    @{text_characters}
        Press Key    ${field location}    ${char}
        Sleep    ${slow_mode_delay}
    END
    Log    Entered text '${text entry}' into field ${field location}

Clear And Type Into Element - Secure
    [Arguments]
    ...    ${field location}
    ...    ${password}
    ...    ${timeout}=${wait_time}
    [Documentation]    This keyword waits until the field_location is visible, clears any text
    ...                in the field_location and then enters password into it.

    Wait Until Element Is Visible         ${field location}    ${timeout}
    Clear Element Text    ${field location}
    Input Password                        ${field location}    ${password}

Select dropdown menu answer
    [Documentation]
    ...    >"element" is the main menu element that holds the subelements in it.
    ...    >"option_subelement" is used for counting the number of subelements. It
    ...    defaults to "option" in the jquery string since that is most commonly used
    ...    in the HTML.
    ...    >"select_element_value" can be used if an specific option in the dropdown menu
    ...    wants to be selected instead of a random one by value. Since normally we want a random
    ...    one, this defaults to "None."
    ...    >"select_element_text" can be used if an specific option in the dropdown menu
    ...    wants to be selected instead of a random one by text/label. Since normally we want a random
    ...    one, this defaults to "None."
    ...    >"range_start" is used for selecting where to start when randomizing the 
    ...    subelement selector. Since the "0" subelement is usually a non-selectable 
    ...    option, this defaults to "1."
    ...    >"skip_menu_check" is an option that can skip the menu element visual ID check
    ...    on the page. Normally we want this to make sure it's visible on the page 
    ...    before we interact with it, however in some cases, the literal menu element 
    ...    that houses the subelements is overlapped by an invisible element and can cause
    ...    issues with the automation driver. If this issue arises, setting this to 
    ...    "True" will skip that check. It defaults to "False."
    [Arguments]
    ...    ${element}
    ...    ${option_subelement}=option
    ...    ${select_element_value}=None
    ...    ${select_element_text}=None
    ...    ${range_start}=1
    ...    ${skip_menu_check}=False
    # ====================
    IF   ${skip_menu_check} == False
    ...    Wait Until Element Is Visible    ${element}
    ${element_count}=    Get Element Count    ${element} ${option_subelement}
    # ====================
    ${random}=
    ...    IF    ${element_count} > ${range_start}
    ...    Evaluate
    ...    random.randint(${range_start}, (${element_count}-1))    random
    ...    ELSE    Evaluate    ${element_count}-1
    ${random_int}=
    ...    Convert To String    ${random}
    # ====================
    IF    ${element_count} == 0
    ...    Log To Console    The element you are looking for was not found on the page. The element location may have been changed by the development team or it may have been removed. Check page for more details.
    ...    ELSE IF    
    ...    '${select_element_value}'=='None' and '${select_element_text}'=='None' and ${element_count} > 0
    ...    Select From List By Index    ${element}    ${random_int}
    ...    ELSE IF    
    ...    '${select_element_value}'!='None' and '${select_element_text}'=='None' and ${element_count} > 0
    ...    Select From List By Value    ${element}    ${select_element_value}    
    ...    ELSE IF    
    ...    '${select_element_value}'=='None' and '${select_element_text}'!='None' and ${element_count} > 0
    ...    Select From List By Label     ${element}    ${select_element_text}
    Wait Until Element Is Visible    ${element}
    ${selected_option}=    Get Selected List Label    ${element}
    RETURN    ${selected_option}

Scroll the Page
    [Arguments]    ${element}
    ...    ${timeout}=${short_wait_time}
    [Documentation]    Scroll the page to the specified element
    Wait Until Element Is Visible      ${element}    ${timeout}
    Element Should Be Visible          ${element}
    ${vertical}    Get Vertical Position    ${element}
    ${horizontal}    Get Horizontal Position    ${element}
    Execute Javascript    return window.scrollTo(${vertical},${horizontal})

Compare Web Elements And Field Values
    [Arguments]     ${locator_value}    ${list_value}
    [Documentation]  Validated the Elements on the page against the provided list Values
    ...  locator_value: Provided Locator path to retrieve list
    ...  list_value: Provided list values to compare against retrieve list
    ...  str_to_removed: This value is set if any value to remove for comparison
    ...  remove_str: By default it will be false, If it is set to True then str_to_removed argument need to be set

    @{list}     Create List
    ${fields_names}    Get WebElements   ${locator_value}
    FOR  ${field_name}     IN     @{fields_names} 
        ${str}    Get Text     ${field_name}
        Append To List  ${list}  ${str}
    END
    Log  ${list}
    Compare Two Values Are Equal      ${list_value}    ${list}


Compare Two Values Are Equal
    [Arguments]    ${first_value}    ${second_value}    ${msg}=${EMPTY}    ${ignore_case}=False    
    [Documentation]    Compares two strings or integers or numbers. If both are not matched then captures the screenshot and then fails with generic error message
    ...    first_value: actual value to be compared
    ...    second_value: expected value to be compared
    
    ${is_passed}=    Run Keyword And Return Status
    ...    Should Be Equal    ${first_value}    ${second_value}    ignore_case=${ignore_case}
    IF    ${is_passed}==False    Log    ${first_value} & ${second_value} are not equal. Check whether the error is with data type or data. ${msg}

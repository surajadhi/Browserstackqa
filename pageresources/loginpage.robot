*** Settings ***
Documentation  To create page objects of Login page
Library     SeleniumLibrary
Library     Collections
Library     String

Resource    ../globalresources/globalweb.robot

*** Variables ***
${url}      https://bstackdemo.com/signin
${username}  demouser
${password}  testingisfun99

#loc
${username_fld_loc}  xpath://div[@id='username']//div[contains(@class,'css-yk16xz-control')]
${username_tb_loc}   css=#react-select-2-option-0-0
${password_fld_loc}   xpath://div[@id='password']//div[contains(@class,'css-1hwfws3')]
${password_tb_loc}   css=#react-select-3-option-0-0
${signin_btn_loc}    login-btn

*** Keywords ***
Open the browser with the url
    [Documentation]     To open the browser with the provided url

    Create Webdriver  Chrome
    #Open New Chrome Browser  True
    Go To   ${url}
    Set Browser Implicit Wait    5
    Maximize Browser Window

Login to the application
    [Documentation]  Login to the application

    Find And Click Element   $username_fld_loc
    Find And Click Element   ${username_tb_loc}
    Find And Click Element   ${password_fld_loc} 
    Find And Click Element   ${password_tb_loc}
    Find And Click Element  ${signin_btn_loc}
    Element Text Should Be   css:.username  demouser

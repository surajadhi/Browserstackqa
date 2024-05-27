*** Settings ***
Library    String
*** Variable ***
${add_to_cart_loc}       xpath=//div[@class="shelf-item"]/p[text()="{}"]/following-sibling::div/following-sibling::div
@{list_variable}    ${empty}    some text    ${empty}

*** Keywords ***
Verify ${var} funcationality
   
   Replace String    ${add_to_cart_loc}    {}    test
   
    Log To Console   ${var}
*** Test Case ***
Test
    Verify search funcationality 

Replace a String
    ${cleared_list}=    Evaluate    [x for x in @{list_variable} if x]
    Log    ${cleared_list}




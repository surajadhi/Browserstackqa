*** Settings ***
Documentation  To create page objects of Checkout page
Library     SeleniumLibrary
Library     Collections
Library     String
Library     random
Library     FakerLibrary

Resource    ../globalresources/globalweb.robot

*** Variables ***
${message}        Your Order has been successfully placed.
${firstname_loc}   id=firstNameInput
${lastname_loc}    id=lastNameInput
${address_loc}     id=addressLine1Input
${state_loc}        id=provinceInput
${postalcode_loc}   id=postCodeInput
${submit_btn_loc}   id=checkout-shipping-continue
${confirmation_msg_loc}   id=confirmation-message

*** Keywords ***
Enter The Details In Shipping Address Page
    
    ${first_name} =    FakerLibrary.FirstName
    ${last_name} =     FakerLibrary.LastName
    ${address} =       FakerLibrary.Street Address
    ${state}=          FakerLibrary.State
    ${zip}=            FakerLibrary.Postcode
    Clear And Type Into Element    ${firstname_loc}    ${first_name}
    Clear And Type Into Element    ${lastname_loc}    ${last_name}
    Clear And Type Into Element    ${address_loc}    ${address}
    Clear And Type Into Element    ${state_loc}    ${state}
    Clear And Type Into Element    ${postalcode_loc}    ${zip}
    Find And Click Element    ${submit_btn_loc}
    Element Text Should Be    ${confirmation_msg_loc}    ${message}
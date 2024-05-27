*** Settings ***
Documentation  To create page objects of Login page
Library     SeleniumLibrary
Suite Setup  Open the browser with the url
Suite Teardown  Close Browser

Resource     ../pageresources/loginpage.robot
Resource     ../pageresources/cartpage.robot
Resource     ../pageresources/checkoutpage.robot

*** Test Cases ***
Login to the app with valid creds

    Login to the application

Get List Of Vendors

    Get List Of Vendors
    Get List Count
Validate the Product Price From Lowest To Highest
    
    Filtered Products: Verify Products Are Sorted In Price Low To High

Validate the Product Price Highest To Lowest
    Filtered Products: Verify Products Are Sorted In Price High To Low

Validate the Product Price In Both Ways
    Verify The Options In Select dropdown
    Filtered Products: Alternate way

Validate Product Count Based On Vendor

    Get List Count Based On Vendor


Select Product In List
    Add Selected Product To Cart
    Enter The Details In Shipping Address Page
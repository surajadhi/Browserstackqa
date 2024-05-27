*** Settings ***
Documentation  To create page objects of Cart page
Library     SeleniumLibrary
Library     Collections
Library     String
Library     random
Library    ../helpers/clear.py

Resource    ../globalresources/globalweb.robot

*** Variables ***
${vendor_name}
${cost_of_prod_val}
@{vendors}   Apple  Samsung  Google  OnePlus
@{vendor_match}   iPhone  Galaxy  Pixel  One Plus
${lowertohighest}  lowestprice
${highertolower}   highestprice
${product_name}  
${shippingadd_txt}  Shipping Address
@{order_by_list}     Select   Lowest to highest    Highest to lowest
  
#loc
${products_txt_loc}     //p[@class="shelf-item__title"]
${vendors_tab_loc}      //span[@class='checkmark']
${avl_count_loc}        xpath=//div[@class="shelf-container-header"]//span
${products_loc}         xpath=//div[@class="shelf-item"]
${products_title_loc}   //p[@class='shelf-item__title']
${select_dd_loc}        css=div[class='sort'] select
${price_tag_loc}        //div[@class='shelf-item']//div[@class='val']/b
${add_to_cart_loc}       xpath=//div[@class="shelf-item"]/p[text()="{}"]/following-sibling::div/following-sibling::div
${added_prod_loc}        xpath=//div[@class="shelf-item__details"]/p[text()="{}"]
${checkout_title_loc}    css=p[class='title']
${checkout_btn_loc}      css=.buy-btn
${shippingadd_txt_loc}    css=.form-legend.optimizedCheckout-headingSecondary
${orderby_dd_loc}         //div[@class='shelf-container-header']//option
${cost_of_prod_loc}        //div[@class="shelf-item"]/p[text()="{}"]/following-sibling::div/div[@class="val"]
${cost_of_prod_check_loc}  //div[@class="shelf-item__details"]//p[text()="{}"]/parent::div/following-sibling::div[@class="shelf-item__price"]/p


*** Keywords ***
Get List Of Vendors
    Compare Web Elements And Field Values  ${vendors_tab_loc}  ${vendors}
   
Get List Count

    Sleep  0.5
    ${text}  Get Text  ${avl_count_loc}
    ${words}  Split String    ${text}  ${SPACE}
    ${visible_number}  Convert To Integer  ${words}[0]
    ${count}   Get Element Count  ${products_loc}
    Should Be Equal  ${visible_number}  ${count}

Get List Count Based On Vendor
    
    Select Random Vendor
    Get List Count
    Get Product Names

Select Random Vendor
    ${count}  Get Element Count  ${vendors_tab_loc}
    ${randomNo}    random.Randrange    ${1}    ${count}
    Find And Click Element   (${vendors_tab_loc})[${randomNo}]
    ${vendor_name}   Get Text  (${vendors_tab_loc})[${randomNo}]
    Sleep  5s
    Set Test Variable  ${vendor_name}

Get Product Names   
   
   @{list}     Create List
   ${count}  Get Element Count  ${products_title_loc}
    FOR  ${i}     IN RANGE  1    ${count}+${1} 
        ${str}    Get Text     (${products_title_loc})[${i}]
        Append To List  ${list}  ${str}
        IF  '${vendor_name}'== '${vendors}[0]'   #'Apple'
           Should Contain    ${str}  ${vendor_match}[0]
        ELSE IF  '${vendor_name}'== '${vendors}[1]'
           Should Contain    ${str}  ${vendor_match}[1]
        ELSE IF  '${vendor_name}'== '${vendors}[2]'
            Should Contain    ${str}  ${vendor_match}[2]
        ELSE
          Should Contain    ${str}  ${vendor_match}[3]
        END
    END
    Log  ${list}

Filtered Products: Verify Products Are Sorted In Price Low To High

    Filtered Products: Verify Whether Products Sorted    price_filter=${lowertohighest}    low_to_high=True

Filtered Products: Verify Products Are Sorted In Price High To Low

    Filtered Products: Verify Whether Products Sorted    price_filter=${highertolower}    low_to_high=False

Filtered Products: Verify Whether Products Sorted  
   [Arguments]     ${price_filter}  ${low_to_high}=True
   [Documentation]    Verifies that the products are sorted according to the applied sort by price.
    ...                ${low_to_high}=True indicates Products are sorted by price low to high
    ...                ${low_to_high}=False indicates Products are sorted by price high to low

   Select dropdown menu answer   ${select_dd_loc}   select_element_value=${price_filter}
   Sleep  1s
   @{list}     Create List
   ${count}   Get Element Count  ${products_loc}
   FOR  ${i}     IN RANGE  1    ${count}+${1}
        ${cost}  Get Text   (${price_tag_loc})[${i}]
        ${cost}  Convert To Integer    ${cost}
        Append To List  ${list}  ${cost}
    END
    Log  ${list}
    @{list_sorted}    Create List    @{list}  
    IF  ${low_to_high} 
        Sort List    ${list_sorted}
    ELSE
        Run KeywordS   Sort List  ${list_sorted}  AND  Reverse List    ${list_sorted}
    END
    Log    Products prices after sorting--> ${list_sorted}
    Lists Should Be Equal    ${list}    ${list_sorted}

 Filtered Products: Alternate way
   @{list}    Create List
   ${count}   Get Element Count  ${orderby_dd_loc}
     FOR  ${i}     IN RANGE  1    ${count}+${1}
       ${order_by}   Get Text  (${orderby_dd_loc})[${i}]
       Select dropdown menu answer  ${select_dd_loc}   select_element_text=${order_by}
       Sleep  1s
        FOR  ${j}     IN RANGE  1    ${count}+${1}
            ${cost}  Get Text   (${price_tag_loc})[${j}]
            ${cost}  Convert To Integer    ${cost}
            Append To List  ${list}  ${cost}
        END
        @{list_sorted}    Create List    @{list}  
        Log  ${order_by}
        IF  '${order_by}'=='Lowest to highest'
            Sort List    ${list_sorted}
            Lists Should Be Equal    ${list}    ${list_sorted}
        ELSE IF  '${order_by}'=='Highest to lowest'
            Run KeywordS   Sort List  ${list_sorted}  AND  Reverse List    ${list_sorted}
            Lists Should Be Equal    ${list}    ${list_sorted}
        ELSE
            Log  No Action
        END
        Clear List  ${list}
    END

Verify The Options In Select dropdown
    
    @{list}     Create List
   ${count}   Get Element Count  ${orderby_dd_loc}
   FOR  ${i}     IN RANGE  1    ${count}+${1}
     ${order_by}   Get Text  (${orderby_dd_loc})[${i}]
     Append To List  ${list}  ${order_by}
   END
   Lists Should Be Equal    ${list}    ${order_by_list}

Select Random Product
    
    @{list}     Create List
    ${count}   Get Element Count  ${products_txt_loc}
    FOR  ${i}     IN RANGE  1    ${count}+${1}
        ${prod_name}  Get Text   (${products_txt_loc})[${i}]
        Append To List  ${list}  ${prod_name}
    END
    Log  ${list}
    ${random_prod}=  Evaluate  random.choice($list)  random
    Log  ${random_prod}
    RETURN    ${random_prod}

Add Selected Product To Cart
    ${product_name}  Select Random Product
    Add Random Product To Cart  ${product_name}
    Sleep  2s
    Validate Details In The Bag   ${added_prod_loc}  ${product_name}  ${product_name}
    Validate Cost Details In The Bag    ${cost_of_prod_check_loc}    ${cost_of_prod_val}  ${product_name}
    Verify Element On Page  ${checkout_title_loc}
    Element Text Should Be  ${checkout_title_loc}   ${product_name} 
    Find And Click Element  ${checkout_btn_loc}
    Verify Element On Page  ${shippingadd_txt_loc}
    Element Text Should Be  ${shippingadd_txt_loc}  ${shippingadd_txt}

Validate Details In The Bag
   [Arguments]    ${locator}  ${exp_value}  ${name}
    ${locator}  Replace String  ${locator}  {}  ${name}
    ${act_value}   Get Text    ${locator}
    Compare Two Values Are Equal  ${act_value}  ${exp_value}

Validate Cost Details In The Bag
    [Arguments]    ${locator}  ${exp_value}  ${name}
    ${locator}  Replace String  ${locator}  {}  ${name}
    ${act_value}   Get Text    ${locator}
    ${act_value}    Split String    ${act_value}       $
    ${act_value}  Convert To Number   ${act_value}[1]
    Compare Two Values Are Equal  ${act_value}  ${exp_value}

Add Random Product To Cart
    [Arguments]   ${product_name}
    ${add_to_cart_loc}  Replace String  ${add_to_cart_loc}  {}  ${product_name} 
    ${cost_of_prod_loc}  Replace String     ${cost_of_prod_loc}    {}    ${product_name}
    ${cost_of_prod_val}   Get Text    ${cost_of_prod_loc}
    Find And Click Element  ${add_to_cart_loc}
    ${cost_of_prod_val}    Split String    ${cost_of_prod_val}       $
    ${cost_of_prod_val}  Convert To Number  ${cost_of_prod_val}[1]
    # ${cost_of_prod_val}  Set Variable  ${cost_of_prod_val}[1]
    Set Test Variable    ${cost_of_prod_val}

Validate the Amount Of Selected Product
    ${product_name}  Select Random Product
    ${add_to_cart_loc}  Replace String  ${add_to_cart_loc}  {}  ${product_name}
    ${cost_of_prod_loc}  Replace String    ${cost_of_prod_loc}    {}    ${product_name}
    ${cost_of_prod_check_loc}  Replace String    ${cost_of_prod_check_loc}    {}    ${product_name}
    Find And Click Element  ${add_to_cart_loc}

      


   
   

    



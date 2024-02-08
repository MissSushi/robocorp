*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.Tables
Library           RPA.HTTP
Library           RPA.PDF
Library           RPA.FileSystem     
Library           RPA.Archive

*** Variables ***
${PDF_TEMP_DIR}=    ${OUTPUT_DIR}${/}tmp_pdfs


*** Tasks ***
Orders robots from RobotSpareBin Industries Inc.
    Setup Directory
    Download the order file
    Open the robot order website
    Files to Table
    
    

*** Keywords ***
Open the robot order website
    Open Browser    https://robotsparebinindustries.com/orders#/robot-order    browser=edge

Download the order file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Close the annoying modal
    Click Button    css:button.btn:nth-child(2)

Get orders
    ${orders}=    Read table from CSV    orders.csv    header=True
    RETURN    ${orders}

Files to Table
    ${orders}=    Get orders
    log    ${orders}
    FOR    ${order}    IN    @{orders}
        Fill the form    ${order}
    END
    Create ZIP package from PDF files

Fill the form
    [Arguments]    ${order}
    Close the annoying modal
    Select From List By Value    head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    css:.form-control[type='number']    ${order}[Legs]
    Input Text    address    ${order}[Address]
    Wait Until Keyword Succeeds   30 sec    0.5 sec   Submit Robot Sucessfully
    ${pdf}=    Store the receipt as a PDF file   ${order}
    ${screenshot}=    Take a Screenshot of the Robot    ${order}
    Embed the robot screenshot to the receipt PDF file    ${pdf}    ${screenshot}
    Click Button    order-another


Setup Directory
    Create Directory    ${PDF_TEMP_DIR}

Submit Robot Sucessfully
    Click Button    order
    Element Should Be Visible    receipt

Store the receipt as a PDF file
    [Arguments]    ${order}
    Wait Until Element Is Visible    id:receipt
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt_html}    ${PDF_TEMP_DIR}${/}${order}[Order number].pdf
    RETURN    ${PDF_TEMP_DIR}${/}${order}[Order number].pdf

Take a Screenshot of the Robot
    [Arguments]    ${order}
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}${order}[Order number]robot-preview-image.png
    RETURN    ${OUTPUT_DIR}${/}${order}[Order number]robot-preview-image.png

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${pdf_file}    ${screenshot}
    # Open Pdf    ${pdf_file}
    ${files}=    Create List
    ...    ${pdf_file}
    ...    ${screenshot}
    Add Files To Pdf     ${files}    ${pdf_file}
    # Close Pdf
    
Create ZIP package from PDF files
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/PDFs.zip
    Archive Folder With Zip
    ...    ${PDF_TEMP_DIR}
    ...    ${zip_file_name}




    
    
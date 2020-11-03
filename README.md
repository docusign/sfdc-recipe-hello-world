# SFDC - DocuSign SOAP API: Hello World
This repo enables you to send an envelope for signing from an Apex class on SFDC. 
The Apex class uses the DocuSign SOAP API.

## Installation 

### 1. DocuSign eSignature for Salesforce
Install [DocuSign eSignature for Salesforce from AppExchange](https://appexchange.salesforce.com/listingDetail?listingId=a0N30000001taX4EAI) 

### Authentication via Named Credential
There are multiple ways to set up authentication on Salesforce with DocuSign Signature APIs.

Currently, the DocuSign Signature SOAP API uses DocuSign [Legacy Authentication](https://docs.docusign.com/esign/guide/authentication/legacy_auth.html), with or without SOBO.

For User Applications, it is preferable that each DocuSign sender logs in to use his or her own account. SFDC Named Credentials enable this.
 
### 2. Create the Named Credential
In this step, we create a Named Credential for the DocuSign Demo (Developer Account) environment.
[SFDC Docs](http://help.salesforce.com/apex/HTViewHelpDoc?id=named_credentials_define.htm&language=en_US)

* From Setup, enter name in the Quick Find box, then select Named Credentials.
* Click New Named Credential.
* Label: DocuSign Legacy Demo
* Name: DocuSign_Legacy_Demo (default value)
* URL: https://demo.docusign.net
* In the Authentication section:
  * Certificate: leave blank
  * Identity Type: Per User
  * Authentication Protocol: Password Authentication
  * The form asks for an "Administrative" username and password. It is not clear why since each user will add her own name and password.
  * Administration Username: use a made up name. Eg Jill
  * Administration Password: use a made up password. Eg Jill  
* Callout Options section:
  * Generate Authorization Header: NOT checked
  * Allow Merge Fields in HTTP Header: checked
  * Allow Merge Fields in HTTP Body: NOT checked
  * Click Save

### 3. Grant Access for Users to Update their own DocuSign Credentials
This step applies when your users do not have administrative rights in their SFDC org. As a developer for your
SFDC Developer Environment, this issue does not apply.

See [docs](https://help.salesforce.com/HTViewHelpDoc?id=named_credentials_permsets_profiles.htm&language=en_US)

### 4. Each User: Enable Their DocuSign Authentication
Each user who will use your integration needs to configure their personal access to the Named Credential.

As a developer/administrator, you also need to complete this step for your own access.

* Open your personal Settings (not from Settings), accessed from your name (classic) or picture (Lightning).
* Enter auth in the Quick Find box, then select Authentication Settings for External Systems
* Click New to create a new record. Complete the form:
  * External System Definition: Named Credential
  * Named Credential: DocuSign Legacy Demo
  * User: use the pick list to select yourself
  * Authentication Protocol: Password Authentication
  * Username: enter your email user name from your DocuSign Demo Account 
  * Password: enter your DocuSign Demo password
* Click Save
 
## Install DocuSign Signature SOAP API Access
This is a one time process to create Apex proxy classes from the DocuSign WSDL files.
The result is the addition of a set of classes in your org. 

The same classes, with no changes, are used with both DocuSign Demo and Production environments.

### 5. Create the Apex proxy classes

Salesforce documentation: [Defining a Class from a WSDL Document](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_callouts_wsdl2apex.htm)

* Use a web browser to download ("Save As") the [DSAPI.wsdl](https://www.docusign.net/api/3.0/schema/dsapi.wsdl) 
  file to a local directory. Name it dsapi.wsdl.xml
* In Salesforce, from Setup, enter apex classes in the Quick Find box, then select Apex Classes.
* Click Generate from WSDL.
* Click Choose File and select the dsapi.wsdl.xml file your local hard drive or network.
* Click Parse WSDL
* The results form enables you to change the name of the Apex class. Set it to DocuSignTK. Click Generate Apex Code.
* Salesforce will report that it created two new Apex classes for you: DocuSignTK and AsyncDocuSignTK
* You're now ready to send your first envelope via the API!

### Test Coverage for WSDL-generated classes

The [Apex SOAP Callouts](https://trailhead.salesforce.com/en/apex_integration_services/apex_integration_soap_callouts) provides additional information on adding SOAP callouts to your Apex application. It also discusses how to provide test coverage for a WSDL-generated Apex class. 

The following posts also discuss tests for a WSDL-generated Apex class:

* [Salesforce forum](https://developer.salesforce.com/forums/?id=906F000000090e4IAA)
* [Salesforce forum includes test examples](https://developer.salesforce.com/forums/?id=906F0000000MIwfIAG)
* [Salesforce forum](https://developer.salesforce.com/forums/?id=906F000000090QGIAY)

## 6. Install and configure the Recipe

* Install the Apex class file `DS_Recipe_Send_Env_Email_Controller` from the source file src/classes/DS_Recipe_Send_Env_Email_Controller.cls
  * Update the class with your DocuSign Demo Integration Key and Account ID.
    Remember that you need to use the long form version of the Account ID.
* Install the VisualForce page `DS_Recipe_Send_Env_Email` from the source file src/pages/DS_Recipe_Send_Env_Email.page

## 7. Try it out
Navigate to \[your SFDC org\]/apex/DS_Recipe_Send_Env_Email and try sending a signing request.

## Questions, Problems, Issues
* If you have a question about a DocuSign API, please use the "docusignapi" tag on [StackOverflow](http://www.stackoverflow.com)
* Pull requests and other issues for this repository can be filed with the [repo's Issues list](https://github.com/docusign/sfdc-recipe-hello-world/issues).


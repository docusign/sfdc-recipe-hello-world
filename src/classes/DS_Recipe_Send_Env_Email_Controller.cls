Public class DS_Recipe_Send_Env_Email_Controller {
    // Send an envelope via email for signing
    // Copyright (c) 2016 DocuSign, Inc. 
    // LICENSE: The MIT License, see https://opensource.org/licenses/MIT

    // SETTINGS
    Private static string integration_key = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx';
    Private static string account_id =      'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'; 
        // NOTE: You MUST use the long form of the account id. It's has 32 digits 
        // with 4 dashes (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx). 
        // This version of the account id is shown in the Apps and Keys page
        // of your DocuSign Administration tool


    Public string signer_email {get;set;}   // Required
    Public string signer_name {get;set;}    // Required
    Public string email_message {get;set;}  // Optional
    Public string output {get;set;}
    Public string envelope_id {get;set;}
    Public string error_code {get;set;} // Null means no error
    Public string error_message {get;set;}

    // Using Legacy authentication via an SFDC Named Credential
	Private static string ds_server = 'callout:DocuSign_Legacy_Demo/api/3.0/dsapi.asmx';
    // If you choose to not use a named credential:
	// Private static string ds_server = 'https://demo.docusign.net/api/3.0/dsapi.asmx';
    
    Private static string trace_value = 'SFDC_004_SOAP_email_send'; // Used for tracing API calls
    Private static string trace_key = 'X-ray';
	Private DocuSignTK.APIServiceSoap api_sender = new DocuSignTK.APIServiceSoap();

    Public DS_Recipe_Send_Env_Email_Controller(){}
    
    Public void send(){
		configure_sender();
        do_send();

        if (no_error()) {
            output = '<h2>Envelope Sent!</h2>';
            output += '<p>Envelope ID: ' + envelope_id + '</p>';
            output += '<p></p><p>Signer: ' + signer_name + ' &lt;' + signer_email + '&gt;</p>';
        } else {
            output = '<h3>Problem</h3><p>' + error_message + '</p>';
        }
    }

    Private void configure_sender(){
		api_sender.endpoint_x = ds_server;
		api_sender.inputHttpHeaders_x = new Map<String, String>();
		String auth =   '<DocuSignCredentials><Username>{!$Credential.Username}</Username>' 
		              + '<Password>{!$Credential.Password}</Password>' 
					  + '<IntegratorKey>' + integration_key + '</IntegratorKey></DocuSignCredentials>';

		api_sender.inputHttpHeaders_x.put('X-DocuSign-Authentication', auth);
	}

    Private void do_send() {
        // Sends a signing request to signer_name / signer_email

        // Check input
        if (String.isBlank(signer_email) || String.isBlank(signer_name) || !signer_email.contains('@')) {
            error_message = 'Please fill in the email and name fields';
            error_code = 'INPUT_PROBLEM';
            return;
        }

        // Check configuration
        if (integration_key == 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' ||
            account_id == 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx') { 
            error_message = 'Please configure the Apex class DS_Recipe_Send_Env_Email_Controller with your integration key and account id.';
            error_code = 'CONFIGURATION_PROBLEM';
            return;
        }

        // File contents are provided here
        // The documents array can include multiple documents, of differing types.
        // All documents are converted to pdf prior to signing.
        // The fileExtension field defaults to "pdf".       
        String file_contents = '<html><h1>NDA Document</h1>' + get_lorem() 
            + '<p>&nbsp;</p>' 
            + '<p>Signature: <span style="color:white;">signer1sig</span></p>' 
            + '<p>Date: <span style="color:white;">signer1date</span></p></html>'; 

        DocuSignTK.Document document = new DocuSignTK.Document();
		document.ID = 1;
        document.Name = 'NDA Document';
        document.FileExtension = 'html';
        document.pdfBytes = EncodingUtil.base64Encode(Blob.valueOf(file_contents));
    
        // The signing fields
        //
        // Invisible (white) Anchor field names for the NDA.pdf document:
        //   * signer1sig
        //   * signer1date
        //
		DocuSignTK.Recipient recipient = new DocuSignTK.Recipient();
        recipient.Email = signer_email;
        recipient.UserName = signer_name;
        recipient.ID = 1;
        recipient.Type_x = 'Signer';
        recipient.RoutingOrder = 1;
		
		// The signer tab...
		DocuSignTK.Tab signHereTab = new DocuSignTK.Tab();
        signHereTab.Type_x = 'SignHere';
		signHereTab.AnchorTabItem = new DocuSignTK.AnchorTab();
        signHereTab.AnchorTabItem.AnchorTabString = 'signer1sig'; // Anchored for doc 1
        signHereTab.AnchorTabItem.XOffset = 8;
        signHereTab.RecipientID = 1;
        signHereTab.Name = 'Please sign here';
        signHereTab.ScaleValue = 1;
        signHereTab.TabLabel = 'signer1sig';

		// The dateSigned tab
		DocuSignTK.Tab dateSignedTab = new DocuSignTK.Tab();
 		dateSignedTab.Type_x = 'DateSigned';
 		dateSignedTab.AnchorTabItem = new DocuSignTK.AnchorTab();
        dateSignedTab.AnchorTabItem.AnchorTabString = 'signer1date'; // Anchored for doc 1
        dateSignedTab.AnchorTabItem.YOffset = -6;
        dateSignedTab.FontSize = 'Size12';
        dateSignedTab.RecipientID = 1;
        dateSignedTab.Name = 'Date Signed';
        dateSignedTab.TabLabel = 'date_signed';

		// Create an envelope and fill it in
		DocuSignTK.Envelope envelope = new DocuSignTK.Envelope();
        envelope.Subject = 'Please sign the NDA package'; // Make the subject specific to the request
		    // Since the subject is used to identify the envelope, you may want to include the
		    // key signer's name or org. Eg Please sign the Example Corp - Sender Corp NDA                            
        envelope.AccountId  = account_id; 
		envelope.Tabs = new DocuSignTK.ArrayOfTab();
		envelope.Tabs.Tab = new DocuSignTK.Tab[2];		
		envelope.Tabs.Tab.add(signHereTab);
		envelope.Tabs.Tab.add(dateSignedTab);
        envelope.Recipients = new DocuSignTK.ArrayOfRecipient();
		envelope.Recipients.Recipient = new DocuSignTK.Recipient[1];
		envelope.Recipients.Recipient.add(recipient);
        envelope.Documents = new DocuSignTK.ArrayOfDocument();
        envelope.Documents.Document = new DocuSignTK.Document[1];
		envelope.Documents.Document.add(document);
        if (String.isNotBlank(email_message)) {
            envelope.EmailBlurb = email_message;
        }

        // Make the call
        try {
        	DocuSignTK.EnvelopeStatus result = api_sender.CreateAndSendEnvelope(envelope);
        	envelope_id = result.EnvelopeID;
        	System.debug('Returned successfully, envelope_id = ' + envelope_id );
      	} catch ( CalloutException e) {
			System.debug('Exception - ' + e );
      		error_code = 'Problem: ' + e;
			error_message = error_code;
		}      
	}

    Private Boolean no_error() {
        return (String.isEmpty(error_code));
    }

    Private static String get_lorem(){
        String lorem = '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. In nisi mauris, fermentum eget ultricies non, lobortis vitae sapien. Sed consectetur sem ut leo malesuada rutrum. Suspendisse interdum, lectus et consequat vestibulum, neque sem cursus eros, sagittis pharetra augue nunc sed odio. Integer molestie sed sem vel congue. Vivamus efficitur nunc eros, vitae sodales nulla malesuada vel. Praesent egestas pellentesque ipsum, a bibendum justo ornare nec. Nullam congue rhoncus ex et dignissim. Integer convallis erat at nunc ultricies, eu fringilla nulla aliquet. Vestibulum convallis ullamcorper magna, non interdum ipsum iaculis id. Mauris nunc tellus, dapibus quis ex eget, venenatis facilisis justo. Nullam nibh augue, aliquet ut fringilla at, faucibus quis est. Vivamus non blandit felis, in congue nibh. Donec ultrices sapien a sapien eleifend, non rutrum elit tempor. Maecenas ut urna vitae quam porttitor suscipit.</p>';
        lorem += '<p>Morbi ac nisl non eros sollicitudin consequat sed ac neque. Nunc venenatis, ligula non efficitur viverra, eros turpis mattis ex, eu vestibulum magna dui aliquet est. Fusce tristique nisl in elit scelerisque, sit amet semper nulla tristique. Nullam finibus nibh nec justo vestibulum, ut pulvinar ex fermentum. Ut feugiat turpis ut augue fringilla, et gravida leo dapibus. Aliquam a luctus sem, at dignissim ipsum. Nulla posuere tempus augue quis rhoncus. Ut sollicitudin bibendum ipsum, et laoreet risus tristique ac. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Cras consequat lorem fringilla mauris suscipit vulputate. Duis non finibus lacus. Duis vehicula dictum ligula, a gravida metus scelerisque et. Donec quis dolor eros. Donec eleifend libero ut commodo euismod.</p>';
        lorem += '<p>Nam eget tellus sapien. Aliquam lobortis dui nec malesuada viverra. Praesent faucibus, augue nec elementum vulputate, magna quam iaculis quam, eu bibendum nibh tellus eu elit. Maecenas eu elementum leo, eu posuere velit. Morbi nisi ante, porttitor eu ex in, ultrices bibendum eros. In scelerisque tortor quis elit pulvinar, et interdum est tempor. Morbi at elementum sem. Etiam convallis tristique sapien at vestibulum. Cras nec eros aliquam, pharetra enim sed, eleifend dolor. Proin vestibulum bibendum ante vel maximus. Pellentesque magna ligula, placerat eget purus id, mollis pretium elit. Vivamus tempus malesuada ante, id egestas libero finibus quis. Nulla consequat turpis sit amet leo vehicula, eget ornare est pulvinar. Praesent quam diam, convallis vitae leo a, cursus tempus magna. Pellentesque ornare magna nec est mattis aliquam. Donec vestibulum est et vestibulum faucibus.</p>';
        return lorem;
    }
}

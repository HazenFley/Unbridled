public class avtexEmailSend {
    public void sendEmail(id recId, string phone, string channel, string source, string UTMContent){
        System.debug('avtexEmailSend.sendEmail starting..................................................');
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Messaging.reserveSingleEmailCapacity(2);
        
        //Strings to hold the email addresses to which you are sending the email.
        List<String> sendToList = new List<String>();
        sendToList.add('cicsfintegration@grantham.edu');//Production
        //sendToList.add('cicsfintegrationdev@grantham.edu');//Test
        
        List<String> ccAddresses = new List<String>();
        
        // Assign the addresses for the To and CC lists to the mail object.
        mail.setToAddresses(sendToList);
        mail.setCcAddresses(ccAddresses);

        // Specify the address used when the recipients reply to the email. 
        mail.setReplyTo('salesforce@grantham.edu');
        
        // Specify the name used as the display name.
        mail.setSenderDisplayName('Grantham University');
        
        // Specify the subject line for your email address.
        mail.setSubject('New Lead Created In Salesforce');
        
        // Set to True if you want to BCC yourself on the email.
        mail.setBccSender(false);
        
        // Optionally append the salesforce.com email signature to the email.
        // The email address of the user executing the Apex Code will be used.
        mail.setUseSignature(false);
        
        // Specify the text content of the email.
        mail.setPlainTextBody(recId+' | '+phone+' | '+channel+' | '+source+' | '+UTMContent);
        
        //mail.setHtmlBody('Your case:<b> ' + case.Id +' </b>has been created.<p>'+
        //                 'To view your case <a href=https://yourInstance.salesforce.com/'+case.Id+'>click here.</a>');
        
        System.debug('This message will be sent: '+ mail);
        
        // Send the email you have created.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });        
        
    }
}
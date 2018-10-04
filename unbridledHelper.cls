public class unbridledHelper {
    @future(callout=true)
    public static void sendLead(set<id> unbridledSet){//changed from (lead l)
        System.debug('unbridledHelper.sendLead starting...');
        
        List<Lead> leadList = [SELECT id, X18_Digit_ID__c, FirstName, LastName,
                               LeadSource, Lead_Source_Channel__c, UTM_Campaign__c, UTM_Content__c, Jornaya_Key__c, 
                               Phone, Alternate_Phone__c, Email, TCPA_Acknowledgement__c, SMS_Opt_In__c,
                               company, street, city, state, PostalCode, Degree_Program__c,
                               CreatedDate
                               FROM Lead WHERE id IN :unbridledSet];
        
        System.debug('leadList = ' + leadList);
        
        //Go through each lead and send it
        for(Lead l: leadList){
            
            Map<String, String> f9lead = new Map<String, String>();
            List<IntegrationLog__c> errorLogList = new List<IntegrationLog__c>();
            
            string leadchannel = l.Lead_Source_Channel__c;
            
            //SOQL for metadata that houses list and domain information
            Map<string, Unbridled_List__mdt> metadataMap = new Map<string, Unbridled_List__mdt>([SELECT label, F9CallASAP__c, F9domain__c, F9list__c, client_id__c FROM Unbridled_List__mdt WHERE label=:leadchannel]);
            System.debug('metadataMap = ' + metadataMap);
            
            //set defaults
            string F9domain = 'Unbridled';
            string F9list = 'grantham.qt.rfi';   //Production        
            //string F9list = 'grantham.test';     //Test
            string client_id = 'grantham';
            string F9CallASAP = '1';
            
            //change defaults if metadata is different
            if(metadataMap.containsKey(leadchannel) && metadataMap.get(leadchannel)!=null){
                Unbridled_List__mdt metaRecord = metadataMap.get(leadchannel);
                F9domain = metaRecord.F9domain__c;
                F9list = metaRecord.F9list__c;
                if(metaRecord.F9CallASAP__c==false){F9CallASAP = '0';}
                client_id = metaRecord.client_id__c;
                system.debug('metaRecord= ' + metaRecord);
            }
            
            //get boolean values into string values
            string phonenumber_ewc;
            string phonenumber_smsoptin;
            
            if(L.TCPA_Acknowledgement__c){phonenumber_ewc = '1';}
            if(L.SMS_Opt_In__c){phonenumber_smsoptin = '1';}
            
            //validate that data is not bad and does not exceed the values five9 expects and cut as necessary
            boolean validLead = true;
            string invalidReason;
            
            string valPhone = l.Phone.replaceAll('[^0-9]', '');
            if(valPhone.length()!=10){
                validLead = false;
                invalidReason = 'Phone is not 10 digits';
            }
            if(l.LastName==null || l.FirstName==null){
                validLead = false;
                invalidReason = 'Name is missing';
            }
            if(phonenumber_ewc != '1'){
                validLead = false;
                invalidReason = 'TCPA Acknoledgement not given';
            }
            
            
            
            
            if(validLead){ //put into the f9lead object
                //required information
                f9lead.put('F9domain', F9domain);
                f9lead.put('client_id', client_id);          
                f9lead.put('F9list', F9list);
                f9lead.put('number1', valPhone);
                f9lead.put('F9Key', 'salesforce_id');
                f9lead.put('F9CallASAP', F9CallASAP);            
                f9lead.put('salesforce_id', L.X18_Digit_ID__c);    
                f9lead.put('first_name', L.FirstName);
                f9lead.put('last_name', L.LastName);
                f9lead.put('lead_inquiry_date', string.valueOf(L.CreatedDate.format('MM-dd-yyyy kk:mm')));
                f9lead.put('phonenumber_ewc_date', string.valueOf(L.CreatedDate.format('MM-dd-yyyy kk:mm')));
                f9lead.put('phonenumber_ewc',  phonenumber_ewc);
                f9lead.put('phonenumber_mobile', '0');
                f9lead.put('phonenumber_smsoptin', phonenumber_smsoptin);
                
                //optional information
                f9lead.put('number2', L.Alternate_Phone__c);
                f9lead.put('company', L.company);
                f9lead.put('street', L.street);
                f9lead.put('city', L.city);
                f9lead.put('state', L.state);
                f9lead.put('zip', L.PostalCode);
                f9lead.put('email', L.email);
                
                //Marketing information
                f9lead.put('marketing_1', L.LeadSource);
                f9lead.put('marketing_2', L.Lead_Source_Channel__c);
                f9lead.put('marketing_3', L.UTM_Campaign__c);
                f9lead.put('marketing_4', L.UTM_Content__c);
                f9lead.put('marketing_5', L.Jornaya_Key__c);
                f9lead.put('program', L.Degree_Program__c);
                
                System.debug('f9lead = ' + JSON.serialize(f9lead));
                
                //Instantiate a new F9Web2Campaign object
                F9Web2Campaign f9 = new F9Web2Campaign();
                //Call the doPost method with the lead
                F9Web2CampaignResult res = f9.doPost(f9lead);
                
                //Check the result, look in the documentation
                //for possible error codes, errCode of 0 means success
                System.debug('errCode: ' + res.errCode + ', errDesc: '+res.errDesc);
                //example debug message:
                //USER_DEBUG [16]|DEBUG|errCode: 0, errDesc: "The request was successfully processed"
                
                //error handling
                if(res.errCode!=0){
                    errorLogList.add(new IntegrationLog__c(Data__c = JSON.serialize(f9lead),
                                                           Exception_Message__c = res.errDesc,
                                                           Exception_Stack_Trace__c = string.valueOf(res.errCode),
                                                           Exception_Type__c = 'Failed to post to Unbridled',
                                                           Related_Lead_Record__c = l.X18_Digit_ID__c,
                                                           Source__c = 'Unbridled API'
                                                          ));
                } 
            }
            
            else{
                errorLogList.add(new IntegrationLog__c(Exception_Type__c = 'Lead not able to be sent to Unbridled',
                                                       Related_Lead_Record__c = l.X18_Digit_ID__c,
                                                       Source__c = 'Unbridled API',
                                                       Exception_Message__c = 'This lead failed because it lacked some required information, or that information was formatted incorrectly. ' + invalidReason
                                                      ));
            }
            
            //DML statement for the error log
            if(errorLogList.size()>0){
                System.debug('errorLogList ' + errorLogList);
                Database.SaveResult[] integrationLogList = Database.insert(errorLogList,false);
            }
        }
    }
}
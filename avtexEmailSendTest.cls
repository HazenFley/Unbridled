@isTest
public class avtexEmailSendTest {

    @isTest static void sendEmailTest(){
        List<Lead> leadList = new List<Lead>();
        
        Test.startTest();
        leadList = avtexEmailSendTest.createLead(true, 'Test Phone','5555555555', 'Organic', 'No Source Provided', 'Branded');
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        
        system.assertEquals(1, invocations, 'An email should be sent');
    }
    
    static List<Lead> createLead(boolean bogusUser, string leadName, string tphone, string channel, string tsource, string utmContent){
        System.debug('Creating ' +leadName);
        
        List<Lead> leadList = new List<Lead>();
        
        //get user data
        List<User> UserList = [SELECT id, name FROM User WHERE Bogus_User__c = :bogusUser AND isActive=true];
        id userID = UserList[0].id;
        
        if(!UserList.isEmpty()){
            Lead l = new Lead();
            l.LastName = leadName;
            l.Company = 'assignNewLeadTest';
            l.LeadSource = tsource;
            l.Lead_Source_Channel__c = channel;
            l.Phone = tphone;
            l.OwnerId = userId;  
            l.UTM_Content__c = utmContent;
            leadList.add(l);
                      
        }
            
        System.debug('Inserting Leads: ' + leadList);
        insert leadList;
        return leadList;
    }
}
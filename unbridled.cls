public class unbridled {
    public void sendToUnbridled(Lead[] newLead){
        System.debug('unbridled.sendToUnbridled starting.............................................');
        Set<id> unbridledSet = new Set<id>();
            for(Lead ld: newLead){
                if(ld.Sent_to_Unbridled__c == true){                    
                    unbridledSet.add(ld.id);
                }
            }
        if(unbridledSet.size()>0){
            System.debug('Sending these leads to unbridled: ' + unbridledSet);
            unbridledHelper.sendLead(unbridledSet);
        }else{
            System.debug('Nothing to send to Unbridled.');
        }
        
    }
    
    public void updateStatus(Lead[] newLead){
        for(Lead l: newLead){
            if(l.Unbridled_Disposition__c != null){                
                if(l.Status=='Uncontacted' || l.status == 'New'){
                    switch on l.Unbridled_Disposition__c {
                        when 'Fax' {l.status = 'Uncontacted';l.Invalid_Phone__c = true;}
                        when 'Operator Intercept' {l.status = 'Uncontacted';l.Invalid_Phone__c = true;}
                        when 'Transferred to 3rd Party' {l.status = 'Contacted';}
                        when 'Already Working with Grantham' {l.status = 'Not Qualified (Bad)';l.Status_Reason__c='Duplicate';l.Status_Reason_Explanation__c='Updated by Unbridled';}
                        when 'Claims No Inquiry Made' {l.status = 'Not Qualified (Bad)';l.Status_Reason__c='Other';l.Status_Reason_Explanation__c='Updated by Unbridled';}
                        when 'Deceased' {l.status = 'Not Interested';l.Status_Reason__c='Other';l.Status_Reason_Explanation__c='Updated by Unbridled';}
                        when 'DNC Request' {l.status = 'Not Interested'; l.DoNotCall = true;}
                        when 'Failed Transfer' {l.status = 'Contacted';}
                        when 'Failed Transfer Hang Up' {l.status = 'Contacted';}
                        when 'False Incentive' {l.status = 'Not Qualified (Bad)';l.Status_Reason__c='False Incentive';}
                        when 'Mistaken Inquiry' {l.status = 'Not Qualified (Bad)';l.Status_Reason__c='Other';l.Status_Reason_Explanation__c='Updated by Unbridled';}
                        when 'Non English Speaking' {l.status = 'Not Qualified (Bad)';}
                        when 'No Interest' {l.status = 'Not Interested';l.Status_Reason__c='Other';l.Status_Reason_Explanation__c='Updated by Unbridled';}
                        when 'No Interest Financial' {l.status = 'Not Interested';l.Status_Reason__c='Financing Not Available';}
                        when 'No Interest Time' {l.status = 'Not Interested';l.Status_Reason__c='Other';l.Status_Reason_Explanation__c='Updated by Unbridled';}
                        when 'Objected to Call Recording' {l.status = 'Not Interested';l.Status_Reason__c='Other';l.Status_Reason_Explanation__c='Updated by Unbridled';}
                        when 'Only Available After-Hours' {l.status = 'Contacted';l.Status_Reason__c='Call after hours';}
                        when 'Program Not Offered' {l.status = 'Not Interested';l.Status_Reason__c='Program Not Offered';l.Status_Reason_Explanation__c='Updated by Unbridled';}
                        when 'Prank' {l.status = 'Not Qualified (Bad)';l.Status_Reason__c='Other';l.Status_Reason_Explanation__c='Updated by Unbridled';}
                        when 'F-SafeHarbor DNC' {l.status = 'Uncontacted';l.DoNotCall = true;}
                        when 'Invalid Phone Number' {l.status = 'Uncontacted';l.Invalid_Phone__c = true;}
                        when 'Seeking Employment' {l.status = 'Not Qualified (Bad)';l.Status_Reason__c='False Incentive';}
                        when 'Selected a Different School' {l.status = 'Not Interested';l.Status_Reason__c='Enrolled Elsewhere';}
                        when 'Test Call' {l.status = 'Not Qualified (Bad)';l.Status_Reason__c='Test Record';}
                        when 'Transfer' {l.status = 'Contacted';}
                        when 'Wrong Party' {l.status = 'Uncontacted';l.Invalid_Phone__c = true;}
                        when 'Callback Scheduled' {l.status = 'Contacted';}
                        when 'Poor Connection' {l.status = 'Contacted';}
                        when else {}
                    }
                }
            }
        }
    }
}
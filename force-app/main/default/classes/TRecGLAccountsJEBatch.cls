public with sharing class TRecGLAccountsJEBatch implements Database.Batchable<sObject> {

    public static final String BATCH_NAME = 'TRec GL Accounts JE Batch';
    public static final String SOBJECT_TYPE = 'TREX1__Journal_Entry__c';
    public String strQuery = 'SELECT Id, TREX1__GL_Code__c, GL_Account_Name__c FROM TREX1__Journal_Entry__c WHERE GL_Account_Name__c = NULL AND TREX1__GL_Code__c != NULL ORDER BY TREX1__GL_Code__c ASC';

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(strQuery);
    }

    public void execute(Database.BatchableContext bc, List<TREX1__Journal_Entry__c> lstJEs) {
        bypassTrigger(SOBJECT_TYPE);

        // Get map of gl codes to names from singleton utility
        Map<String, String> mapGlCodeToName = TRecGLAccountUtility.getInstance().mapGlCodeToName;

        // Set je gl account names from map
        for (TREX1__Journal_Entry__c je : lstJEs) {
            je.GL_Account_Name__c = mapGlCodeToName.get(je.TREX1__GL_Code__c);
        }

        // Update jes
        update lstJEs;
    }

    public void finish(Database.BatchableContext bc) {
        // Disable Traction Rec trigger bypass for the sobject type
        disableTriggerBypass(SOBJECT_TYPE);

        AsyncApexJob apexJob = [
            SELECT Id, 
                   Status, 
                   NumberOfErrors, 
                   JobItemsProcessed, 
                   TotalJobItems, 
                   CreatedBy.Email
              FROM AsyncApexJob 
             WHERE Id = :bc.getJobId()
        ];
        
        // Send email to job creator with batch results
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddress = new String[] {apexJob.CreatedBy.Email};
        email.setToAddresses(toAddress);
        email.setSubject(apexJob.Status + ': ' + BATCH_NAME);
        email.setPlainTextBody('The ' + BATCH_NAME + ' ran and processed ' + apexJob.TotalJobItems + ' batches with ' + apexJob.NumberOfErrors + ' failures. Job Id: ' + apexJob.Id);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }

    private void bypassTrigger(String sObjType) {
        // Get custom setting record for sobject
        List<TREX1__Trigger_Bypass__c> lstBypasses = [
            SELECT Id, TREX1__Active__c, TREX1__Expiry__c, TREX1__User_Ids__c, TREX1__Notes__c
              FROM TREX1__Trigger_Bypass__c 
             WHERE TREX1__SObject__c = :sObjType
             LIMIT 1
        ];
        TREX1__Trigger_Bypass__c bypass;
        if (!lstBypasses.isEmpty()) {
            bypass = lstBypasses.get(0);
            // Exit if bypass is valid for more than 15 min
            if (
                bypass.TREX1__Active__c && 
                bypass.TREX1__Expiry__c >= Datetime.now().addMinutes(15) && 
                bypass.TREX1__User_Ids__c.contains(UserInfo.getUserId())
            ) {
                return;
            }

            bypass.TREX1__Active__c = true;
            bypass.TREX1__Expiry__c = Datetime.now().addHours(1);
            bypass.TREX1__User_Ids__c = UserInfo.getUserId();
            bypass.TREX1__Notes__c = BATCH_NAME;
            update bypass;

        } else {
            bypass = new TREX1__Trigger_Bypass__c();
            bypass.Name = sObjType;
            bypass.TREX1__SObject__c = sObjType;
            bypass.TREX1__Active__c = true;
            bypass.TREX1__Expiry__c = Datetime.now().addHours(1);
            bypass.TREX1__User_Ids__c = UserInfo.getUserId();
            bypass.TREX1__Notes__c = BATCH_NAME;
            insert bypass;
        }
    }

    private void disableTriggerBypass(String sObjType) {
        TREX1__Trigger_Bypass__c bypass = [
            SELECT Id, TREX1__Active__c
              FROM TREX1__Trigger_Bypass__c 
             WHERE TREX1__SObject__c = :sObjType
             LIMIT 1
        ];
        bypass.TREX1__Active__c = false;
        try {
            update bypass;
        } catch (Exception e) {
            System.debug('Failed to update bypass: ' + e.getMessage());
        }
    }

}
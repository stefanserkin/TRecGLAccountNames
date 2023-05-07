public with sharing class TRecGLAccountsJEBatch implements Database.Batchable<sObject> {

    public static final String BATCH_NAME = 'TRec GL Accounts JE Batch';
    public String strQuery = 'SELECT Id, TREX1__GL_Code__c, GL_Account_Name__c FROM TREX1__Journal_Entry__c WHERE GL_Account_Name__c = NULL AND TREX1__GL_Code__c != NULL ORDER BY TREX1__GL_Code__c ASC';

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(strQuery);
    }

    public void execute(Database.BatchableContext bc, List<TREX1__Journal_Entry__c> lstJEs) {
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

}

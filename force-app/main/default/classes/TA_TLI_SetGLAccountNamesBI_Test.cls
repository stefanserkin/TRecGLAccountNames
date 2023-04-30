@isTest
private class TA_TLI_SetGLAccountNamesBI_Test {

    private static Id purchaseTLIRecTypeId = 
        Schema.SObjectType.TREX1__Transaction_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Purchase').getRecordTypeId();

    @isTest
    static void testSetGlAccountNames() {
        // Create 4 gl accounts - one for each property of the tli
        List<TREX1__GL_Account__c> lstGlAccounts = TestDataFactory.createGlAccounts(4);
        insert lstGlAccounts;
        // Store results in map for easier access during asserts
        Map<String, String> mapGlCodeToName = new Map<String, String>();
        for (TREX1__GL_Account__c glAcc : lstGlAccounts) {
            mapGlCodeToName.put(glAcc.TREX1__GL_Account_Number__c, glAcc.Name);
        }

        Account acc = TestDataFactory.createHouseholdAccounts(1).get(0);
        insert acc;
        Contact ct = TestDataFactory.createContacts(new List<Account>{ acc }, 1).get(0);
        insert ct;

        TREX1__Transaction__c trans = TestDataFactory.createDraftTransaction(ct);

        // Create tlis with minimum required values to insert
        TREX1__Transaction_Line_Item__c tli = new TREX1__Transaction_Line_Item__c();
        tli.RecordTypeId = purchaseTLIRecTypeId;
        tli.TREX1__Transaction__c = trans.Id;
        tli.TREX1__Contact__c = ct.Id;
        tli.TREX1__Account__c = acc.Id;
        tli.TREX1__GL_Account_Deferred_Primary__c = lstGlAccounts[0].TREX1__GL_Account_Number__c;
        tli.TREX1__GL_Percent_Deferred_Fee_Primary__c = 100;
        tli.TREX1__GL_Account_Deferred_Secondary__c = lstGlAccounts[1].TREX1__GL_Account_Number__c;
        tli.TREX1__GL_Percent_Deferred_Fee_Secondary__c = 0;
        tli.TREX1__GL_Account_Initial_Primary__c = lstGlAccounts[2].TREX1__GL_Account_Number__c;
        tli.TREX1__GL_Percent_Initial_Primary__c = 100;
        tli.TREX1__GL_Account_Initial_Secondary__c = lstGlAccounts[3].TREX1__GL_Account_Number__c;
        tli.TREX1__GL_Percent_Initial_Secondary__c = 0;

        Test.startTest();
        Database.SaveResult sr = Database.insert(tli);
        Test.stopTest();

        System.assert(sr.isSuccess(), 'Should have successfully inserted the tli');

        TREX1__Transaction_Line_Item__c refreshedTli = [
            SELECT TREX1__GL_Account_Deferred_Primary__c, GL_Account_Deferred_Fee_Primary_Name__c, 
                   TREX1__GL_Account_Deferred_Secondary__c, GL_Account_Deferred_Fee_Secondary_Name__c, 
                   TREX1__GL_Account_Initial_Primary__c, GL_Account_Initial_Primary_Name__c, 
                   TREX1__GL_Account_Initial_Secondary__c, GL_Account_Initial_Secondary_Name__c
              FROM TREX1__Transaction_Line_Item__c 
             WHERE TREX1__Transaction__c = :trans.Id 
             LIMIT 1
        ];

        System.assertEquals(
            mapGlCodeToName.get(refreshedTli.TREX1__GL_Account_Deferred_Primary__c), 
            refreshedTli.GL_Account_Deferred_Fee_Primary_Name__c, 
            'Deferred fee primary name does not match gl code'
        );

        System.assertEquals(
            mapGlCodeToName.get(refreshedTli.TREX1__GL_Account_Deferred_Secondary__c), 
            refreshedTli.GL_Account_Deferred_Fee_Secondary_Name__c, 
            'Deferred fee secondary name does not match gl code'
        );

        System.assertEquals(
            mapGlCodeToName.get(refreshedTli.TREX1__GL_Account_Initial_Primary__c), 
            refreshedTli.GL_Account_Initial_Primary_Name__c, 
            'Initial fee primary name does not match gl code'
        );

        System.assertEquals(
            mapGlCodeToName.get(refreshedTli.TREX1__GL_Account_Initial_Secondary__c), 
            refreshedTli.GL_Account_Initial_Secondary_Name__c, 
            'Initial fee secondary name does not match gl code'
        );

    }

}
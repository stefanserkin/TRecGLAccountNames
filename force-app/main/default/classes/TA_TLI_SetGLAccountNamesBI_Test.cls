@isTest
private class TA_TLI_SetGLAccountNamesBI_Test {

    @isTest
    static void testSetGlAccountNames() {
        TREX1__GL_Account__c glAccount = TestDataFactory.createGlAccounts(1).get(0);

        Account acc = TestDataFactory.createHouseholdAccounts(1).get(0);
        insert acc;
        Contact ct = TestDataFactory.createContacts(new List<Account>{ acc }, 1).get(0);
        insert ct;

        Test.startTest();
        TREX1__Transaction__c trans = TestDataFactory.createManualAdjustmentTransaction(
            ct, 
            100, 
            glAccount.TREX1__GL_Account_Number__c, 
            TestDataFactory.ADJUSTMENT_TYPE_CREDIT
        );
        Test.stopTest();

        List<TREX1__Journal_Entry__c> lstJEsToValidate = [
            SELECT Id, TREX1__GL_Code__c, GL_Account_Name__c
              FROM TREX1__Journal_Entry__c
             WHERE TREX1__Transaction__c = :trans.Id
        ];

        System.assert(
            !String.isBlank(lstJEsToValidate[0].GL_Account_Name__c), 
            'GL Account Name should be populated'
        );
        System.assertEquals(
            glAccount.Name,
            lstJEsToValidate[0].GL_Account_Name__c,
            'GL Account Name should equal the original gl account name'
        );

    }

}
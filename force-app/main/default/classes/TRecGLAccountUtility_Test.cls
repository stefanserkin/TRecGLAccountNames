@isTest
private class TRecGLAccountUtility_Test {

    private static final String ASSERT_EXCEPTION_MSG = 'Received incorrect gl account name for gl code';

    @testSetup
    static void makeData() {
        // Create global accounts in custom settings
        TREX1__Global_GL_Accounts__c globalGlAccounts = TestDataFactory.createGlobalGLAccounts();
        // Create gl accounts in custom object
        List<TREX1__GL_Account__c> lstGlAccounts = TestDataFactory.createGlAccounts(20);
        insert lstGlAccounts;        
    }
    
    @isTest
    static void testGetNameFromCustomObject() {
        Map<String, String> mapGlCodeToName = TRecGLAccountUtility.getInstance().mapGlCodeToName;
        List<TREX1__GL_Account__c> lstRefreshedAccounts = [SELECT Name, TREX1__GL_Account_Number__c FROM TREX1__GL_Account__c LIMIT 20];
        for (TREX1__GL_Account__c glAcc : lstRefreshedAccounts) {
            System.assertEquals(
                glAcc.Name, 
                mapGlCodeToName.get(glAcc.TREX1__GL_Account_Number__c), 
                ASSERT_EXCEPTION_MSG
            );
        }
    }

    @isTest
    static void testGetNameFromCustomSetting() {
        Map<String, String> mapGlCodeToName = TRecGLAccountUtility.getInstance().mapGlCodeToName;
        TREX1__Global_GL_Accounts__c refreshedGlobalAccounts = TREX1__Global_GL_Accounts__c.getOrgDefaults();
        DescribeSObjectResult dsor = TREX1__Global_GL_Accounts__c.sObjectType.getDescribe();
        Set<String> setGlobalAccFields = dsor.fields.getMap().keySet();
        // Store each text field in the map with the field value returning the label
        Map<String, String> mapGlobalAccounts = new Map<String, String>();
        for (String fieldName : setGlobalAccFields) {
            Schema.DescribeFieldResult fieldResult = dsor.fields.getMap().get(fieldName).getDescribe();
            if (fieldResult.getType() == Schema.DisplayType.STRING) {
                String strFieldValue = (String) refreshedGlobalAccounts.get(fieldName);
                mapGlobalAccounts.put(strFieldValue, fieldResult.getLabel());
            }
        }

        for (String globalGl : mapGlobalAccounts.keySet()) {
            System.assertEquals(
                mapGlobalAccounts.get(globalGl), 
                mapGlCodeToName.get(globalGl), 
                ASSERT_EXCEPTION_MSG
            );
        }
    }

}
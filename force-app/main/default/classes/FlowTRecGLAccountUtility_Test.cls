@isTest
private class FlowTRecGLAccountUtility_Test {

    @isTest
    static void testGetGlAccountName() {
        TREX1__GL_Account__c glAcc = TestDataFactory.createGlAccounts(1).get(0);
        insert glAcc;
        List<FlowTRecGLAccountUtility.Result> lstResults;
        Test.startTest();
        FlowTRecGLAccountUtility.Request request = new FlowTRecGLAccountUtility.Request();
        request.glCode = glAcc.TREX1__GL_Account_Number__c;
        lstResults = FlowTRecGLAccountUtility.getGlAccountName(
            new List<FlowTRecGLAccountUtility.Request>{ request }
        );
        Test.stopTest();
        System.assertEquals(
            glAcc.Name, 
            lstResults.get(0).glAccountName,
            'Should have received the name of the original gl account'
        );
    }

}
public with sharing class TA_TLI_SetGLAccountNamesBI implements TriggerAction.BeforeInsert {
    
    public void beforeInsert(List<TREX1__Transaction_Line_Item__c> newList) {
        // Get map of gl codes to names from singleton utility
        Map<String, String> mapGlCodeToName = TRecGLAccountUtility.getInstance().mapGlCodeToName;
        for (TREX1__Transaction_Line_Item__c tli : newList) {
            // Deferred account primary
            tli.GL_Account_Deferred_Fee_Primary_Name__c = mapGlCodeToName.get(tli.TREX1__GL_Account_Deferred_Primary__c);
            // Deferred account secondary
            tli.GL_Account_Deferred_Fee_Secondary_Name__c = mapGlCodeToName.get(tli.TREX1__GL_Account_Deferred_Secondary__c);
            // Initial account primary
            tli.GL_Account_Initial_Primary_Name__c = mapGlCodeToName.get(tli.TREX1__GL_Account_Initial_Primary__c);
            // Initial account secondary
            tli.GL_Account_Deferred_Fee_Primary_Name__c = mapGlCodeToName.get(tli.TREX1__GL_Account_Deferred_Primary__c);
        }
    }

}
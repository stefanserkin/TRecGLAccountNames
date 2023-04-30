public class TA_TLI_SetGLAccountNamesBU implements TriggerAction.BeforeUpdate {
    
    public void beforeUpdate(
        List<TREX1__Transaction_Line_Item__c> newList, 
        List<TREX1__Transaction_Line_Item__c> oldList
    ) {
        // Get old map from old list
        Map<Id, TREX1__Transaction_Line_Item__c> oldMap = new Map<Id, TREX1__Transaction_Line_Item__c>(oldList);
        // Filter to tlis with updated gl accounts
        List<TREX1__Transaction_Line_Item__c> lstTLIsToUpdate = new List<TREX1__Transaction_Line_Item__c>();
        for (TREX1__Transaction_Line_Item__c tTli : newList) {
            if (
                tTli.TREX1__GL_Account_Deferred_Primary__c != oldMap.get(tTli.Id).TREX1__GL_Account_Deferred_Primary__c || 
                tTli.TREX1__GL_Account_Deferred_Secondary__c != oldMap.get(tTli.Id).TREX1__GL_Account_Deferred_Secondary__c || 
                tTli.TREX1__GL_Account_Initial_Primary__c != oldMap.get(tTli.Id).TREX1__GL_Account_Initial_Primary__c || 
                tTli.TREX1__GL_Account_Initial_Secondary__c != oldMap.get(tTli.Id).TREX1__GL_Account_Initial_Secondary__c
            ) {
                lstTLIsToUpdate.add(tTli);
            }
        }
        // Update any tli gl account names with changed gl codes
        if (!lstTLIsToUpdate.isEmpty()) {
            // Get map of gl codes to names from singleton utility
            Map<String, String> mapGlCodeToName = TRecGLAccountUtility.getInstance().mapGlCodeToName;
            for (TREX1__Transaction_Line_Item__c tli : lstTLIsToUpdate) {
                // Deferred account primary
                tli.GL_Account_Deferred_Fee_Primary_Name__c = mapGlCodeToName.get(tli.TREX1__GL_Account_Deferred_Primary__c);
                // Deferred account secondary
                tli.GL_Account_Deferred_Fee_Secondary_Name__c = mapGlCodeToName.get(tli.TREX1__GL_Account_Deferred_Secondary__c);
                // Initial account primary
                tli.GL_Account_Initial_Primary_Name__c = mapGlCodeToName.get(tli.TREX1__GL_Account_Initial_Primary__c);
                // Initial account secondary
                tli.GL_Account_Initial_Secondary_Name__c = mapGlCodeToName.get(tli.TREX1__GL_Account_Initial_Secondary__c);
            }
        }

    }

}
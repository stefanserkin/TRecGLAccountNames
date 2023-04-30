public class TA_TRecJE_SetGLAccountNameBI implements TriggerAction.BeforeInsert {
    
    public void beforeInsert(List<TREX1__Journal_Entry__c> newList) {
        // Get map of gl codes to names from singleton utility
        Map<String, String> mapGlCodeToName = TRecGLAccountUtility.getInstance().mapGlCodeToName;
        for (TREX1__Journal_Entry__c je : newList) {
            je.GL_Account_Name__c = mapGlCodeToName.get(je.TREX1__GL_Code__c);
        }
    }
    
}
public class TA_TRecJE_SetGLAccountNameBU implements TriggerAction.BeforeUpdate {
    
    public void beforeUpdate(
        List<TREX1__Journal_Entry__c> newList,
        List<TREX1__Journal_Entry__c> oldList
    ) {
        // Get map of gl codes to names from singleton utility
        Map<String, String> mapGlCodeToName = TRecGLAccountUtility.getInstance().mapGlCodeToName;
        Map<Id, TREX1__Journal_Entry__c> oldMap = new Map<Id, TREX1__Journal_Entry__c>( oldList );
        for (TREX1__Journal_Entry__c je : newList) {
            if (
                String.isBlank(je.GL_Account_Name__c) &&
                !String.isBlank(je.TREX1__GL_Code__c)
            ) {
                je.GL_Account_Name__c = mapGlCodeToName.get(je.TREX1__GL_Code__c);
            }
        }
    }

}
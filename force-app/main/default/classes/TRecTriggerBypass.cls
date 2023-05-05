/***************************************************
 * Bypass Traction Rec triggers
 ***************************************************/
public class TRecTriggerBypass {

    private static final String DEFAULT_NOTES = 'Custom bypass';

    public void bypass(String sObjectType, String notes) {
        // Get custom setting record for sobject
        List<TREX1__Trigger_Bypass__c> lstBypasses = [
            SELECT Id, TREX1__Active__c, TREX1__Expiry__c, TREX1__User_Ids__c, TREX1__Notes__c
              FROM TREX1__Trigger_Bypass__c 
             WHERE TREX1__SObject__c = :sObjectType
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
            bypass.TREX1__Notes__c = notes;
            update bypass;

        } else {
            bypass = new TREX1__Trigger_Bypass__c();
            bypass.Name = sObjectType;
            bypass.TREX1__SObject__c = sObjectType;
            bypass.TREX1__Active__c = true;
            bypass.TREX1__Expiry__c = Datetime.now().addHours(1);
            bypass.TREX1__User_Ids__c = UserInfo.getUserId();
            bypass.TREX1__Notes__c = notes;
            insert bypass;
        }
    }

    public void bypass(String sObjectType) {
        bypass(sObjectType, DEFAULT_NOTES);
    }

    private void disableBypass(String sObjectType) {
        TREX1__Trigger_Bypass__c bypass = [
            SELECT Id, TREX1__Active__c
              FROM TREX1__Trigger_Bypass__c 
             WHERE TREX1__SObject__c = :sObjectType
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
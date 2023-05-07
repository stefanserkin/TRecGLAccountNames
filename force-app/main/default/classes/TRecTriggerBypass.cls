/***************************************************
 * Bypass Traction Rec triggers
 ***************************************************/
public class TRecTriggerBypass {

    // Collection of sobject names to bypass
    private static Set<String> setSObjectNames;
    // The minimum time that must be remaining on an active bypass before it is extended in the request
    private static final Integer MIN_LIMIT_TIME_REMAINING = 15;
    // The amount of minutes to activate the extension for
    private static final Integer EXPIRY_MINUTES = 45;
    // Default notes for updated records where custom notes are not provided
    private static final String DEFAULT_NOTES = 'Custom bypass';

    /***************************************************
     * Activate
     ***************************************************/

    /**
     * Add an sobject to the collection to be bypassed
     * @param String sObjectType - the api name of the sObject to bypass
     * @return void
     */
    public void addObject(String sObjectType) {
        if (setSObjectNames == null) {
            setSObjectNames = new Set<String>();
        }
        setSObjectNames.add(sObjectType);
    }

    /**
     * Activate trigger bypass for all sobjects in the collection. Optionally, provide notes for the custom settings record
     * @param String notes - notes to include on the updated custom setting records
     * @return null
     */
    public void bypassAll() {
        if (setSObjectNames == null) return;
        activateBypasses(setSObjectNames, DEFAULT_NOTES);
    }
    public void bypassAll(String notes) {
        if (setSObjectNames == null) return;
        activateBypasses(setSObjectNames, notes);
    }

    /**
     * Activate trigger bypass for a single sobject. Optionally, provide notes for the custom settings record
     * @param String sObjectType - the api name of the sobject to activate bypasses for
     * @param String notes - notes to include on the updated custom setting records
     * @return null
     */
    public void bypass(String sObjectType) {
        activateBypasses(new Set<String>{sObjectType}, DEFAULT_NOTES);
    }
    public void bypass(String sObjectType, String notes) {
        activateBypasses(new Set<String>{sObjectType}, notes);
    }

    /**
     * Perform upsert on custom setting records for requested sobjects
     * @param Set<String> sObjectTypes - final collection of sobjects to activate bypasses for
     * @param String notes - notes to include on the updated custom setting records
     * @return null
     */
    private void activateBypasses(Set<String> sObjectTypes, String notes) {
        // Create list to upsert
        List<TREX1__Trigger_Bypass__c> lstBypassesToUpsert = new List<TREX1__Trigger_Bypass__c>();
        // Get existing bypasses for requested sobjects
        List<TREX1__Trigger_Bypass__c> lstBypasses = [
            SELECT Id, TREX1__SObject__c, TREX1__Active__c, TREX1__Expiry__c, TREX1__User_Ids__c, TREX1__Notes__c
              FROM TREX1__Trigger_Bypass__c 
             WHERE TREX1__SObject__c IN :sObjectTypes
             LIMIT 1
        ];
        // Store in map to retrieve bypasses based on their sobject api name
        Map<String, TREX1__Trigger_Bypass__c> mapObjNameToBypass = new Map<String, TREX1__Trigger_Bypass__c>();
        for (TREX1__Trigger_Bypass__c tb : lstBypasses) {
            mapObjNameToBypass.put(tb.TREX1__SObject__c, tb);
        }
        // Activate bypasses for each objects and add to list to upsert
        for (String sObj : sObjectTypes) {
            TREX1__Trigger_Bypass__c bypass;
            if (mapObjNameToBypass.containsKey(sObj)) {
                bypass = mapObjNameToBypass.get(sObj);
                // Skip if bypass is currently active for at least another 15 min
                if (
                    bypass.TREX1__Active__c && 
                    bypass.TREX1__Expiry__c >= Datetime.now().addMinutes(MIN_LIMIT_TIME_REMAINING) && 
                    bypass.TREX1__User_Ids__c.contains(UserInfo.getUserId())
                ) {
                    continue;
                }

                bypass.TREX1__Active__c = true;
                bypass.TREX1__Expiry__c = Datetime.now().addMinutes(EXPIRY_MINUTES);
                bypass.TREX1__User_Ids__c = UserInfo.getUserId();
                bypass.TREX1__Notes__c = notes;
            } else { 
                bypass = new TREX1__Trigger_Bypass__c();
                bypass.Name = sObj;
                bypass.TREX1__SObject__c = sObj;
                bypass.TREX1__Active__c = true;
                bypass.TREX1__Expiry__c = Datetime.now().addMinutes(EXPIRY_MINUTES);
                bypass.TREX1__User_Ids__c = UserInfo.getUserId();
                bypass.TREX1__Notes__c = notes;
            }
            lstBypassesToUpsert.add(bypass);
        }

        try {
            upsert lstBypassesToUpsert;
        } catch (Exception e) {
            System.debug('Error attempting to upsert trigger bypass custom settings: ' + e.getMessage());
        }

    }

    /***************************************************
     * Deactivate
     ***************************************************/

    /**
     * Disable trigger bypass for a single sobject
     * @param String sObjectType - the api name of the sobject to activate bypasses for
     * @return null
     */

    public void disableBypass(String sObjectType) {
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

    /**
     * Disable all activate trigger bypasses
     * @return null
     */

    public void disableAllBypasses() {
        List<TREX1__Trigger_Bypass__c> lstBypasses = [
            SELECT Id, TREX1__Active__c 
              FROM TREX1__Trigger_Bypass__c 
             WHERE TREX1__Active__c = true
        ];
        for (TREX1__Trigger_Bypass__c tb : lstBypasses) {
            tb.TREX1__Active__c = false;
        }
        try {
            update lstBypasses;
        } catch (Exception e) {
            System.debug('Failed to update bypasses: ' + e.getMessage());
        }
    }

}
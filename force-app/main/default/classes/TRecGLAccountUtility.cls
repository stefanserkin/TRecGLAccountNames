/********************************************************************
 * Singleton provides a map of gl codes to their gl account names from 
 * the two gl account tables in the Traction Rec managed package
 *   * TREX1__GL_Account__c
 *   * TREX1__Global_GL_Accounts__c
 ********************************************************************/
public class TRecGLAccountUtility {

    private static TRecGLAccountUtility instance;
    public Map<String, String> mapGlCodeToName { get; private set; }

    private TRecGLAccountUtility() {
        mapGlCodeToName = getGlAccountMap();
    }

    public static TRecGLAccountUtility getInstance() {
        if (TRecGLAccountUtility.instance == null) {
            TRecGLAccountUtility.instance = new TRecGLAccountUtility();
        }
        return TRecGLAccountUtility.instance;
    }

    private Map<String, String> getGlAccountMap() {
        Map<String, String> mapToReturn = new Map<String, String>();

        // Store all gl accounts in map
        for (TREX1__GL_Account__c glAcc : [SELECT Id, Name, TREX1__GL_Account_Number__c 
                                             FROM TREX1__GL_Account__c
                                            WHERE TREX1__Active__c = true])
        {
            mapToReturn.put(glAcc.TREX1__GL_Account_Number__c, glAcc.Name);
        }

        // Store global accounts in map from all fields on org default record
        // Get global account org defaults
        TREX1__Global_GL_Accounts__c globalGlAccs = TREX1__Global_GL_Accounts__c.getOrgDefaults();
        // Get describe result for custom setting
        DescribeSObjectResult dsor = TREX1__Global_GL_Accounts__c.sObjectType.getDescribe();
        Set<String> setGlobalAccFields = dsor.fields.getMap().keySet();
        // Store each text field in the map with the field value returning the label
        for (String fieldName : setGlobalAccFields) {
            Schema.DescribeFieldResult fieldResult = dsor.fields.getMap().get(fieldName).getDescribe();
            if (fieldResult.getType() == Schema.DisplayType.STRING) {
                String strFieldValue = (String) globalGlAccs.get(fieldName);
                mapToReturn.put(strFieldValue, fieldResult.getLabel());
            }
        }
        
        return mapToReturn;
    }

}
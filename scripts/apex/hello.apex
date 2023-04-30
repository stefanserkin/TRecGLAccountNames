// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents


TREX1__Global_GL_Accounts__c globalAccs = TREX1__Global_GL_Accounts__c.getOrgDefaults();
DescribeSObjectResult dsor = TREX1__Global_GL_Accounts__c.sObjectType.getDescribe();
Set<String> setGlobalAccFields = dsor.fields.getMap().keySet();
// Store each text field in the map with the field value returning the label
for (String fieldName : setGlobalAccFields) {
    Schema.DescribeFieldResult fieldResult = dsor.fields.getMap().get(fieldName).getDescribe();
    if (fieldResult.getType() == Schema.DisplayType.STRING) {
        String strARFieldLabel = (String) globalAccs.get(fieldName);
        Boolean fieldIsBlank = String.isBlank(strARFieldLabel);
        System.debug('::::: field is blank: ' + fieldIsBlank);
    }
}



// String glCode;
/*
Map<String, String> mapGlCodesToNames = TRecGLAccountUtility.getInstance().mapGlCodeToName;
System.debug('::::::::::: ALL GL CODES AND LABELS ::::::::::::');
for (String glCode : mapGlCodesToNames.keySet()) {
    System.debug(':::: Code: ' + glCode + ' :::: Label: ' + mapGlCodesToNames.get(glCode));
}
*/
// String glAccountName = mapGlCodesToNames.get(glCode);
// System.debug('::::::: gl account name is ' + glAccountName);


/*
TREX1__Global_GL_Accounts__c globalGls = TREX1__Global_GL_Accounts__c.getOrgDefaults();
globalGls.TREX1__Accounts_Receivable__c = '10-10-000-12504';
upsert globalGls;


System.debug(':::: globalGLs: ');
System.debug(globalGls);
*/

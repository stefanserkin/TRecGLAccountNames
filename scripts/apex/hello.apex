// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents


// String glCode;
Map<String, String> mapGlCodesToNames = TRecGLAccountUtility.getInstance().mapGlCodeToName;
System.debug('::::::::::: ALL GL CODES AND LABELS ::::::::::::');
for (String glCode : mapGlCodesToNames.keySet()) {
    System.debug(':::: Code: ' + glCode + ' :::: Label: ' + mapGlCodesToNames.get(glCode));
}
// String glAccountName = mapGlCodesToNames.get(glCode);
// System.debug('::::::: gl account name is ' + glAccountName);


/*
TREX1__Global_GL_Accounts__c globalGls = TREX1__Global_GL_Accounts__c.getOrgDefaults();
globalGls.TREX1__Accounts_Receivable__c = '10-10-000-12504';
upsert globalGls;


System.debug(':::: globalGLs: ');
System.debug(globalGls);
*/
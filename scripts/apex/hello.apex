// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents


String glCode;
Map<String, String> mapGlCodesToNames = TRecGLAccountUtility.getInstance().mapGlCodeToName;
String glAccountName = mapGlCodesToNames.get(glCode);
System.debug('::::::: gl account name is ' + glAccountName);



public class FlowTRecGLAccountUtility {

    @InvocableMethod(
        label='Get GL Account Name' 
        description='Provide a GL code and receive its corresponding GL account name'
        category='Traction Rec')
    public static List<Result> getGlAccountName(
        List<Request> lstRequests
    ) {
        Map<String, String> mapGlCodeToName = TRecGLAccountUtility.getInstance().mapGlCodeToName;
        String strGlCode = lstRequests.get(0).glCode;
        Result result = new Result();
        result.glAccountName = mapGlCodeToName.get(strGlCode);
        return new List<Result>{ result };
    }

    public class Request {
        @InvocableVariable(required=true label='GL Code')
        public String glCode;
    }

    public class Result {
        @InvocableVariable(label='GL Account Name')
        public String glAccountName;
    }
    
}
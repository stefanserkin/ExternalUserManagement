public with sharing class FlowStringParser {

    @InvocableMethod(
        label='Parse Text' 
        description='Provide a semi-colon separated string (such as input from a MSP) and receive a collection of strings' 
        category='Utilities')
    public static List<Result> parseText(List<Request> lstRequests) {
        String input = lstRequests.get(0).input;
        String[] lstStrings = input.normalizeSpace().replace('; ',';').replace(' ;',';').split(';');

        Result result = new Result();
        result.lstStrings = lstStrings;
        List<Result> lstResults = new List<Result>();
        lstResults.add(result);
        return lstResults;
    }

    public class Request {
        @InvocableVariable(required=true)
        public String input;
    }

    public class Result {
        @InvocableVariable
        public List<String> lstStrings;
    }

}
public with sharing class RevenueCloud_UploadUsage_Controller {
    
    @AuraEnabled
    public static List<blng__Usage__c> onProcessBatch(String base64){
        System.debug(base64);
        String decodedCSV = EncodingUtil.base64Decode(base64.split(',')[1]).toString();

        // this will split into a few lines on the system debug! 
        System.debug(decodedCSV);
        List<blng__Usage__c> usages = csvToUsage(decodedCSV);
        return usages;
    }

    public static List<blng__Usage__c> csvToUsage(String csvAsString) {
        List<blng__Usage__c> usageList = new List<blng__Usage__c>();
        String[] csvFileLines = csvAsString.split('\r\n'); 
        System.debug('Number of Lines: ' + csvFileLines.size());
        
        String[] header = csvFileLines[0].split(',');

        /*
        System.debug('Header = ' + header);
        System.debug('Index of Matching ID = ' + header.indexOf('Matching ID'));
        System.debug('Index of Unit Of Measure = ' + header.indexOf('Unit Of Measure'));
        System.debug('Index of Matching Attribute = ' + header.indexOf('Matching Attribute'));
        System.debug('Index of Quantity = ' + header.indexOf('Quantity'));
        System.debug('Index of Start Date = ' + header.indexOf('Start Date'));
        System.debug('Index of End = ' + header.indexOf('End Date'));
        */

        // Starts !AFTER! the first line, expects a header and ignores it.
        for(Integer i=1; i < csvFileLines.size(); i++){
            blng__Usage__c usageLine = new blng__Usage__c();
            
            // Maybe include a validation whereby if csvRecordData.size() then
            // tell the user to make sure it's in CSV format
            String[] csvRecordData = csvFileLines[i].split(',');

            System.debug('CSV: ' + csvRecordData);
            System.debug('Array Size: ' + csvRecordData.size());
            
            usageLine.blng__MatchingId__c = csvRecordData[0];
            usageLine.blng__UnitOfMeasure__c = csvRecordData[header.indexOf('Unit Of Measure')];
            usageLine.blng__MatchingAttribute__c = csvRecordData[header.indexOf('Matching Attribute')];
            usageLine.blng__Quantity__c = Decimal.valueOf(csvRecordData[header.indexOf('Quantity')]);
            
            Date sDate = Date.parse(csvRecordData[header.indexOf('Start Date')]); 
            Date eDate = Date.parse(csvRecordData[header.indexOf('End Date')]);
            
            usageLine.blng__StartDateTime__c = datetime.newInstance(sDate.year(), sDate.Month(), sDate.Day());
            usageLine.blng__EndDateTime__c = datetime.newInstance(eDate.year(), eDate.Month(), eDate.Day());

            usageList.add(usageLine);
        }
        return usageList;
    }

    @AuraEnabled
    public static void saveUsages(List<blng__Usage__c> usageList) {
        try {
            Database.insert(usageList);
            System.debug('Successfully Inserted Usage List: ' + JSON.serializePretty(usageList));
        } catch (DmlException err) {
            System.debug('An Error occured: ' + err);
            throw new AuraHandledException(err.getMessage());
        }
    }
}
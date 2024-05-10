/**
 * @description       : Contains the Utility Method that runs the duplicate rules on a particular record(s) to see if a duplicate record(s) exists.
 * @group             : UnofficialSF
 * @last modified on  : 05-10-2024
 * Modifications Log
 * Ver   Date         Modification
 * 1.0   01-28-2022   Initial Version
 * 2.0   05-10-2024   Adjustments to work with DuplicateResults and returning list of duplicates
**/
public with sharing class DuplicateRecordCheck_Util {
    private final FindDuplicates findDuplicates;

    private DuplicateRecordCheck_Util(){
        FindDuplicatesFactory factory = FindDuplicatesFactory.getFactory();
        this.findDuplicates = factory.getFindDuplicates();
    }

    private static DuplicateRecordCheck_Util self = new DuplicateRecordCheck_Util();

    /**
    * @description Runs the duplicate rules on a particular record(s) to see if a duplicate record(s) exists.
    * @param List<Input> inputs 
    * @return List<Duplicate> 
    **/
    public static List<DuplicateResponse> findDuplicates(List<sObject> records){
        // The documentation states that the max input array for the findDuplicates method is 50.
        // We are instantiating a new list to house the results in case we have to execute the method multiple times.
        List<FindDuplicates.FindDuplicatesResult> results = new List<FindDuplicates.FindDuplicatesResult>();
        List<sObject> listsObjectsToCheck = new List<sObject>();
        for(sObject record : records){
            listsObjectsToCheck.add(record);
            
            // Check to see if the list size equals 50.
            // If so, execute the findDuplicates method and clear the list.
            if(listsObjectsToCheck.size() == 50){
                results.addAll(self.findDuplicates.findDuplicates(listsObjectsToCheck));
                listsObjectsToCheck.clear();
            }
        }

        // Execute the findDuplicates method a final time.
        if(!listsObjectsToCheck.isEmpty()){
            results.addAll(self.findDuplicates.findDuplicates(listsObjectsToCheck));
        }

        // The mapIndexToDuplicate is a map where the key is the index and the value is a List of Duplicate results (if any exist).
        Integer index = 0;
        Map<Integer,DuplicateResponse> mapIndexToDuplicates = new Map<Integer,DuplicateResponse>();
        for(FindDuplicates.FindDuplicatesResult find : results) {
            DuplicateResponse duplicateReponse = new DuplicateResponse(FALSE, records.get(index).Id, records.get(index).getSObjectType().getDescribe().getName(), null, null);
            for(FindDuplicates.DuplicateResult result : find.getDuplicateResults) {
                // result has a bunch of information about the Duplicate Rule being applied.
                for(FindDuplicates.MatchResult match : result.getMatchResults) {
                    // match has a bunch of information about the Matching Rule being applied.
                    
                    // Instantiate a new list of Duplicates with the Duplicates from the map.
                    List<Duplicate> duplicates = new List<Duplicate>();
                    for(FindDuplicates.MatchRecord record : match.getMatchRecords) {
                        Id recordId = record.getRecordId;
                        Double matchConfidence = record.getMatchConfidence == null ? 0 : record.getMatchConfidence;
                        String sObjectType = recordId.getSObjectType().getDescribe().getName();
                        duplicates.add(new Duplicate(recordId,sObjectType,matchConfidence));
                    }
                    
                    // The Duplicate object implements the Comparable interface, so we are sorting the list in a specific way.
                    // The best Duplicate is the first object from the list because it has the highest matchConfidence.
                    duplicates.sort();
                    if(duplicates.size()>0){
                        duplicateReponse.hasDuplicate = TRUE;
                        duplicateReponse.bestMatchDuplicate = duplicates.get(0);                    
                        duplicateReponse.duplicates = duplicates;
                    }
                }
                mapIndexToDuplicates.put(index,duplicateReponse);
            }
            index++;
        }

        return mapIndexToDuplicates.values();
    }
}

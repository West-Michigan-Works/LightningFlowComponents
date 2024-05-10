/**
 * @description       : Duplicate
 * @group             : UnofficialSF
 * @last modified on  : 05-10-2024
 * Modifications Log
 * Ver   Date         Modification
 * 1.0   05-10-2024   Initial Version
**/
public with sharing class DuplicateResponse {
    @AuraEnabled
    public Boolean hasDuplicate;

    @AuraEnabled
    public Id recordId;

    @AuraEnabled
    public String recordObjectType;

    @AuraEnabled
    public List<Duplicate> duplicates;

    @AuraEnabled
    public Duplicate bestMatchDuplicate;
    
    public DuplicateResponse(Boolean hasDuplicate, Id recordId, String recordObjectType, List<Duplicate> duplicates, Duplicate bestMatchDuplicate){
        this.hasDuplicate = hasDuplicate;
        this.recordId = recordId;
        this.recordObjectType = recordObjectType;
        this.duplicates = duplicates;
        this.bestMatchDuplicate = bestMatchDuplicate;
    }
}

public with sharing class OpportunityDA {

    public static Map<Id, Opportunity> getOpportunitiesWithQuote(Set<Id> opportunityIds) {
        return new Map<Id, Opportunity>([
            SELECT Id, Pricebook2Id, SyncedQuoteId
            FROM Opportunity
            WHERE Id IN :opportunityIds
        ]);
    }
    

    public static Boolean hasSyncedQuote(Id opportunityId) {
        Opportunity opp;
        try {
            opp = [
                SELECT SyncedQuoteId
                FROM Opportunity
                WHERE Id = :opportunityId
            ];
        } catch (QueryException e) {
            System.debug('Erro ao consultar oportunidade: ' + e.getMessage());
            return false;
        }

        return !String.isBlank(opp.SyncedQuoteId);
    }

    public static List<OpportunityLineItem> getOpportunityLineItems(Id opportunityId) {
        return [
            SELECT Id, OpportunityId, Product2Id
            FROM OpportunityLineItem
            WHERE OpportunityId = :opportunityId
        ];
    }

    public static List<OpportunityContactRole> getOpportunityContactRoles(Id opportunityId) {
        return [
            SELECT Id, OpportunityId, ContactId
            FROM OpportunityContactRole
            WHERE OpportunityId = :opportunityId
        ];
    }

    public static Boolean getOpportunityWithChecklistApproval(Id opportunityId) {
        if (opportunityId == null) {
            System.debug('OpportunityId is null');
            return false;
        }

        if (!Schema.sObjectType.ProcessInstance.isAccessible() || !Schema.sObjectType.ProcessDefinition.isAccessible()) {
            System.debug('Insufficient permissions to access ProcessInstance or ProcessDefinition.');
            return false;
        }
    
        List<ProcessInstance> processInstances = [
            SELECT Id, ProcessDefinitionId, Status
            FROM ProcessInstance
            WHERE TargetObjectId = :opportunityId
            AND Status = 'Approved'
        ];
    
        Set<Id> processDefinitionIds = new Set<Id>();
    
        for (ProcessInstance pi : processInstances) {
            processDefinitionIds.add(pi.ProcessDefinitionId);
        }
    
        List<ProcessDefinition> processDefinitions = [
            SELECT Id, DeveloperName
            FROM ProcessDefinition
            WHERE Id IN :processDefinitionIds
        ];
    
        for (ProcessDefinition pd : processDefinitions) {
            if (pd.DeveloperName == 'ProcessoAprovacaoChecklist') {
                return true;
            }
        }
    
        return false;
    }
    
}
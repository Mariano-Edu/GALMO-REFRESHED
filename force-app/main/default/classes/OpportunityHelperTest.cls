@isTest
private class OpportunityHelperTest {

    @isTest
    static void testSetDefaultCloseDate() {
        Opportunity opp = new Opportunity();
        opp.Name = 'Nova Oportunidade';
        opp.StageName = 'Negociação';
        opp.CloseDate = null;

        List<Opportunity> opps = new List<Opportunity>{ opp };
        OpportunityHelper.addDaysToCloseDateOnCreation(opps);

        for (Opportunity o : opps) {
            System.assertEquals(Date.today().addDays(5), o.CloseDate, 'CloseDate should be set to today + 5 days');
        }
    }

    @isTest
    static void testValidateTransitionToFichaCadastral_MissingRequiredFields() {
        Opportunity opp = new Opportunity();
        opp.Name = 'Nova Oportunidade';
        opp.StageName = 'Negociação';
        opp.CloseDate = Date.today();
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Nova Oportunidade';
        opp2.StageName = 'Ficha Cadastral';
        opp2.CloseDate = Date.today();

        List<Opportunity> opps = new List<Opportunity>{ opp, opp2 };
        
        Test.startTest();
        OpportunityHelper.validateTransitionToFichaCadastral(opps, new Map<Id, Opportunity>{ opp.Id => opp });
        Test.stopTest();
    }
    
    private static Account createTestAccount() {
        Account acc = new Account(Name = 'Minha Conta de Teste');
        insert acc;
        return acc;
    }


    private static Contact createTestCorretorContact() {
      
        Account acc = new Account(Name = 'Test Account', Type = 'HouseImobiliaria');
        insert acc;
    
        
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Corretor' LIMIT 1];
        if (rt == null) {
          System.debug('O tipo de registro "Corretor" não foi encontrado.');
        }
    
      
        Contact contact = new Contact(
            FirstName = 'fernandes',
            LastName = 'thiago',
            Email = 'thiaguinho.fernandes@gmail.com',
            AccountId = acc.Id,
            RecordTypeId = rt.Id 
        );
    
        insert contact;
        return contact;
    }
    

    private static Product2 createTestProduct(String productName) {
        Product2 product = new Product2(
            Name = productName,
            ProductCode = 'TestCode' + System.currentTimeMillis(),
            Numero_da_Unidade__c = 8, // Corrigido para String
            IsActive = true
        );
        insert product;
        return product;
    }


    private static PricebookEntry createTestPricebookEntry(Product2 product, Id pricebookId) {
        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = product.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pricebookEntry;
        return pricebookEntry;
    }
}
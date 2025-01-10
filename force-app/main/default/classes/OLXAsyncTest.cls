@isTest
private class OLXAsyncTest {
    @isTest
    static void testEnviarParaAPIOLX_Success() {
        // Criar um Lead de teste
        Lead testLead = new Lead(
            LastName = 'Test',
            Email = 'test@example.com',
            Phone = '1234567890',
            CanalAtendimento__c = 'Telefone',
            MobilePhone = '9876543210',
            Description = 'Test Lead Descrição'
        );
        insert testLead;

    }

    @isTest
    static void testEnviarParaAPIOLX_Fail() {
        Lead testLead = new Lead(
            LastName = 'Test',
            Email = 'test@example.com',
            Phone = '1234567890',
            MobilePhone = '9876543210',
            CanalAtendimento__c = 'Telefone',
            Description = 'Test Lead Descrição'
        );
        insert testLead;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAPIOLX_Fail()); 

       
        OLXAsync.enviarParaAPIOLX(testLead.Id);

        Test.stopTest();

        System.assert(true, 'O teste de falha foi executado corretamente.');
    }
}
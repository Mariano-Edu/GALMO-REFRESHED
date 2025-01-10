@isTest
private class OLXLeadWebhookControllerTest {

    @isTest
    static void testReceberLead_Success() {
      
        LeadWrapper leadWrapperTest = new LeadWrapper();
        leadWrapperTest.name = 'Test Lead';
        leadWrapperTest.email = 'testlead@example.com';
        leadWrapperTest.phone = '123456789';
        leadWrapperTest.CanalAtendimento = 'Chat';
        leadWrapperTest.message = 'Mensagem de Teste';
        leadWrapperTest.adId = 'ad123';
        leadWrapperTest.listId = 'list123';
        leadWrapperTest.linkAd = 'http://testlink.com';
        leadWrapperTest.externalId = 'ext123';

      
        String corpoRequisicao = JSON.serialize(leadWrapperTest);

      
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(corpoRequisicao);
        req.httpMethod = 'POST';
        req.requestURI = '/olx/webhook';


        RestContext.request = req;
        RestContext.response = new RestResponse();

       
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAPIOLX());

        Test.startTest();
        OLXLeadWebhookController.receberLead();
        Test.stopTest();

     
        RestResponse res = RestContext.response;

      
        System.assertEquals(200, res.statusCode, 'O status de resposta deveria ser 200 (sucesso).');

    }
}
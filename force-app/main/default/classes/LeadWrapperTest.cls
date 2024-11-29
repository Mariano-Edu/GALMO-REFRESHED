@isTest
private class LeadWrapperTest {

    @isTest
    static void testLeadWrapperSerialization() {
        // Criar um objeto AdsInfoWrapper com dados fictícios
        AdsInfoWrapper adsInfo = new AdsInfoWrapper();
        adsInfo.category = 'Automóveis';
        adsInfo.subject = 'Carro Usado';
        adsInfo.body = 'Carro em ótimo estado';
        adsInfo.price = '35000';
        adsInfo.zipcode = '12345-678';
        adsInfo.vehicle_brand = 'Toyota';
        adsInfo.vehicle_model = 'Corolla';
        adsInfo.vehicle_version = '2022';

        // Criar um objeto LeadWrapper com todos os campos preenchidos
        LeadWrapper leadWrapper = new LeadWrapper();
        leadWrapper.name = 'Test Lead';
        leadWrapper.email = 'testlead@example.com';
        leadWrapper.phone = '123456789';
        leadWrapper.mobilePhone = '987654321';
        leadWrapper.CanalAtendimento = 'Web';
        leadWrapper.message = 'Mensagem de Teste';
        leadWrapper.adId = 'ad123';
        leadWrapper.listId = 'list123';
        leadWrapper.linkAd = 'http://testlink.com';
        leadWrapper.createdAt = '2024-11-28T12:00:00Z';
        leadWrapper.externalId = 'ext123';
        leadWrapper.adsInfo = adsInfo; // Associar AdsInfoWrapper

        // Serializar o objeto LeadWrapper em JSON
        String leadWrapperJson = JSON.serialize(leadWrapper);

        // Verificar se a serialização contém os campos principais
        System.assert(leadWrapperJson.contains('"name":"Test Lead"'));
        System.assert(leadWrapperJson.contains('"email":"testlead@example.com"'));
        System.assert(leadWrapperJson.contains('"vehicle_brand":"Toyota"'));

        // Desserializar o JSON de volta para um LeadWrapper
        LeadWrapper deserializedLeadWrapper = (LeadWrapper)JSON.deserialize(leadWrapperJson, LeadWrapper.class);

        // Verificar se a desserialização mantém os valores corretos
        System.assertEquals('Test Lead', deserializedLeadWrapper.name);
        System.assertEquals('testlead@example.com', deserializedLeadWrapper.email);
        System.assertEquals('Toyota', deserializedLeadWrapper.adsInfo.vehicle_brand);
    }
}
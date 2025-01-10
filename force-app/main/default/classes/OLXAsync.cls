public with sharing class OLXAsync {
    @future(callout=true)
    public static void enviarParaAPIOLX(Id leadId) {
        Lead lead = [SELECT Id, LastName, Email, Phone, MobilePhone, Description FROM Lead WHERE Id = :leadId LIMIT 1];
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://apps.olx.com.br/autoservice/v1/lead');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer seu_access_token');
        req.setHeader('Content-Type', 'application/json');
        Map<String, Object> body = new Map<String, Object>();
        body.put('leadId', lead.Id);
        body.put('nome', lead.LastName);
        body.put('email', lead.Email);
        body.put('telefone', lead.Phone != null ? lead.Phone : lead.MobilePhone);
        body.put('descricao', lead.Description);
        String jsonBody = JSON.serialize(body);
        req.setBody(jsonBody);
        Http http = new Http();
        HttpResponse res = http.send(req);
        if (res.getStatusCode() == 200) {
            System.debug('Lead enviado com sucesso para a API da OLX');
        } else {
            System.debug('Erro ao enviar Lead para a API da OLX: ' + res.getStatusCode() + ' - ' + res.getBody());
        }
    }
}
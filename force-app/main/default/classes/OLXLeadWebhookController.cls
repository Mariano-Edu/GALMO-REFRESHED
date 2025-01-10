@RestResource(urlMapping='/olx/webhook')
global with sharing class OLXLeadWebhookController {

    @HttpPost
    global static void receberLead() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        Long tempoInicio = Datetime.now().getTime();
        
        try {
            // Recebe e processa a requisição
            String corpoRequisicao = req.requestBody.toString();
            
            // Chama a service para processar o lead
            OLXLeadWebhookService.processarLead(corpoRequisicao, res);

        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('Erro interno: ' + e.getMessage());
            System.debug('Erro ao processar lead: ' + e.getMessage());
        }

        Long tempoFim = Datetime.now().getTime();
        if ((tempoFim - tempoInicio) > 5000) {
            System.debug('Tempo limite excedido (5 segundos).');
        }
    }
 }
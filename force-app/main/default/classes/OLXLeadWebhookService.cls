public class OLXLeadWebhookService {

    public static void processarLead(String corpoRequisicao, RestResponse res) {
        LeadWrapper dadosLead = (LeadWrapper) JSON.deserialize(corpoRequisicao, LeadWrapper.class);

        if (leadInvalido(dadosLead)) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('Erro: Campos obrigatórios ausentes ou campo "source" inválido.');
            registrarErro(corpoRequisicao, 'Campos obrigatórios ausentes ou campo "source" inválido.');
            return;
        }

        if (leadDuplicado(dadosLead)) {
            res.statusCode = 409;
            res.responseBody = Blob.valueOf('Falha: Um Lead com o mesmo sobrenome, e-mail ou telefone já existe.');
            return;
        }

      
        if (String.isBlank(dadosLead.phone) && String.isBlank(dadosLead.mobilePhone)) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('Erro: Ao menos um dos campos Phone ou MobilePhone deve ser preenchido.');
            return;
        }

       
        if (dadosLead.phone != null && dadosLead.mobilePhone != null) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('Erro: Não é permitido preencher tanto o campo Phone quanto MobilePhone ao mesmo tempo.');
            return;
        }

        //
        Id recordTypeId = null;
        if (String.isNotBlank(dadosLead.phone)) {
            recordTypeId = getRecordTypeId('Pessoa Jurídica');
        } else if (String.isNotBlank(dadosLead.mobilePhone)) {
            recordTypeId = getRecordTypeId('Pessoa Física');
        }

        // Criando o Lead
        Lead novoLead = new Lead(
            LastName = dadosLead.name,
            Email = dadosLead.email,
            Phone = dadosLead.phone,
            MobilePhone = dadosLead.mobilePhone,
            LeadSource = 'OLX',
            Status = 'Novo',
            RecordTypeId = recordTypeId,  
            Description = dadosLead.message,
            CanalAtendimento__c = dadosLead.CanalAtendimento,
            AdId__c = dadosLead.adId,
            ListId__c = dadosLead.listId,
            LinkAd__c = dadosLead.linkAd,
            AdsInfo__c = JSON.serialize(dadosLead.adsInfo),
            ExternalId__c = dadosLead.externalId
        );

        try {
          
            insert novoLead;

            // Chama o método assíncrono para o envio do lead para a OLX
           OLXAsync.enviarParaAPIOLX(novoLead.Id);

            res.statusCode = 200;
            res.responseBody = Blob.valueOf('Lead criado com sucesso.');
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('Erro interno: ' + e.getMessage());
            System.debug('Erro ao processar Lead: ' + e.getMessage());
        }
    }

    private static Boolean leadInvalido(LeadWrapper dadosLead) {
        if (String.isBlank(dadosLead.CanalAtendimento) || String.isBlank(dadosLead.name) || String.isBlank(dadosLead.email)) {
            return true;
        }
        return false;
    }

    private static Boolean leadDuplicado(LeadWrapper dadosLead) {
        List<Lead> leadsPotenciaisDuplicados;
        leadsPotenciaisDuplicados = [
            SELECT Id, LastName, Email, Phone, MobilePhone
            FROM Lead
            WHERE LastName = :dadosLead.name
            AND (
                Email = :dadosLead.email OR
                Phone = :dadosLead.phone OR
                MobilePhone = :dadosLead.mobilePhone
            )
            LIMIT 1
        ];

        return !leadsPotenciaisDuplicados.isEmpty();
    }

    private static Id getRecordTypeId(String tipoRegistro) {
        Map<String, Id> recordTypeMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Lead']) {
            recordTypeMap.put(rt.Name, rt.Id);
        }
        return recordTypeMap.get(tipoRegistro);
    }

    private static void registrarErro(String corpoRequisicao, String mensagemErro) {
        System.debug('Erro ao processar Lead: ' + mensagemErro);
        System.debug('Payload recebido do Lead: ' + corpoRequisicao);
    }
}
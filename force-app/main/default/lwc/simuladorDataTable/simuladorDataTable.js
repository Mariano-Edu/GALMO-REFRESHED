import { api, LightningElement, track, wire  } from 'lwc';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import TIPO_CONDICAO_FIELD from "@salesforce/schema/SeriePagamentos__c.TipoCondicao__c";



    

export default class CustomDataTable extends LightningElement {
    @api header =[];
    @api series = [];
    @api unidadeSelecionada;

    @track vencimentoParcelaOptions = [];
    tipoCondicoesPickList;

    @track isDropboxSelected = false;
    
    connectedCallback(){
        this.generateDiasVencimentoOptions();
    }

    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: TIPO_CONDICAO_FIELD })
    result({error, data}){
        if(data){
            this.tipoCondicoesPickList = data.values
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.tipoCondicoesPickList = undefined;
          }
    };

    get getColunasHeader(){
        return this.header;
    }
    
    get getSeriesPagamentosObjetos(){
        return this.series;
    }

    generateDiasVencimentoOptions(){
        console.log(JSON.stringify(this.unidadeSelecionada))

        if(!this.unidadeSelecionada.DiasDeVencimentoDaParcela){return}
        let diasVencimento = this.unidadeSelecionada.DiasDeVencimentoDaParcela;
        let diasVencimentoArray = diasVencimento.split(';');


        diasVencimentoArray.forEach(diaDeVencimento => {
            this.vencimentoParcelaOptions.push({
                label: 'Dia ' + diaDeVencimento,
                value: diaDeVencimento
            });
        });
        
    }

    @api
    executarAcaoCustomizadaData() {
        console.log('Método do componente filho - validação dos campos "Dia de Vencimento".');
    
        // Filtrar linhas onde o campo 'vencimentoParcela' não está selecionado
        const linhasNaoSelecionadas = this.series.filter(serie => !serie.vencimentoParcela);
    
        if (linhasNaoSelecionadas.length > 0) {
            console.warn('Nem todos os campos "Dia de Vencimento" foram preenchidos.');
            this.showToast(
                'Erro',
                'Por favor, preencha todos os campos "Dia de Vencimento" antes de continuar.',
                'error'
            );
        } else {
            console.log('Todos os campos "Dia de Vencimento" estão preenchidos.');
            this.showToast('Sucesso', 'Todos os campos "Dia de Vencimento" estão preenchidos!', 'success');
        }
    }

    handleChange(event) {
        console.log('entrei no handle change simulador data table');
        const target = event.currentTarget;
    
        const uid = target.dataset.uid; // Identifica a linha pelo UID
        const fieldName = target.dataset.name; // Nome do campo alterado
        const fieldValue = target.value || null; // Valor selecionado ou null se vazio
    
        console.log(fieldValue + ' valor selecionado');
        console.log(fieldName + '  nome do campo alterado');
    
        // Atualiza a série correspondente na lista
        const updatedSeries = this.series.map(serie => {
            if (serie.uid === uid) {
                return {
                    ...serie,
                    [fieldName]: fieldValue, // Atualiza o campo alterado
                };
            }
            return serie;
        });
    
        this.series = [...updatedSeries];
    
        this.dispatchEvent(new CustomEvent('mudancacondicao', {
            detail: {uid: target.dataset.uid, name: target.dataset.name, type: target.type, value: target.value ? target.value : null, checked: target.checked ? target.checked : null}
        }));
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    handleDelete(event){
        const target = event.currentTarget; 
        this.dispatchEvent(new CustomEvent('deletecondicao', {
            detail: {uid: target.dataset.uid}
        }));
    }

    handleZerar(event){
        const target = event.currentTarget;

        this.dispatchEvent(new CustomEvent('zerarcondicao', {
            detail: {uid: target.dataset.uid}
        }));
    }








}
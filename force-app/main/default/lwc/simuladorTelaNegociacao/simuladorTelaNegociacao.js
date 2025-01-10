import { LightningElement, track, api } from 'lwc';


export default class SimuladorTelaNegociacao extends LightningElement {
    
    @api produtoSelecionado;
    @api propostasCliente;
    @api valorNominalProposta;
    @api valorVplProposta;
    @api infoComplementares;

    @api ultimaTabelaSelecionada;
    @api tabelasDeVendasData;
    @api tabelaVendaVingenteValue;

    
    get getTabelasDeVendasData(){
        return this.tabelasDeVendasData;
    }


    @api
    executarAcaoCustomizada() {
        console.log('Método do componente filho chamado - tela negociação.');

        const simuladorTelaNegPropCliente = this.template.querySelector('c-simulador-tela-negociacao-proposta-cliente');
        console.log(simuladorTelaNegPropCliente + ' simulador tela neg prop cliente');
        if (simuladorTelaNegPropCliente) {
            console.log('if do simulador tela neg prop cliente');
            simuladorTelaNegPropCliente.executarAcaoCustomizadaFilho();
        } else {
            console.warn('Componente c-simulador-tela-negociacao-proposta-cliente ainda não está renderizado');
        }

    }

    setTabelaSelecionada(event){
        this.dispatchEvent(new CustomEvent('settabelaselecionada', {
            detail: event.detail
        }));
    }

    handleIgualarTabelas(){
        this.dispatchEvent(new CustomEvent('handleigualartabelas'));
    }

    handlePagarAVista(){
        this.dispatchEvent(new CustomEvent('handlepagaravista'));
    }

    changeSeriesPagamentoProposta(event){
        this.dispatchEvent(new CustomEvent('changepropostaserie', {
            detail: event.detail
        }));
    }

    handleAdicionarCondicaoData(){
        this.dispatchEvent(new CustomEvent('adicionarcondicao'));
    }

    handleDeleteCondicaoData(event){
        
        this.dispatchEvent(new CustomEvent('deletarcondicao', {
            detail: event.detail
        }));
    }

    handleZerarCondicao(event){
        this.dispatchEvent(new CustomEvent('zerarcondicao', {
            detail: event.detail
        }));
    }



    handleChangeCondicaoData(event){
        
        this.dispatchEvent(new CustomEvent('mudarcondicao', {
            detail: event.detail
        }));
    }

    handleAplicarDesconto(event){
        const descontoEvent = new CustomEvent('aplicardesconto', {
            detail: event.detail
        });

        this.dispatchEvent(descontoEvent); 

    }

    activeSections = ['Selecione uma tabela de vendas', 'Proposta do cliente'];
    


}
# Market-pulse
Projeto focado em opções binárias.

<div align="center"> 
	<h3>
		⚠️ Atenção: não é recomendável o uso dessa ferramenta para operações com dinheiro real. Nada postado aqui deve ser encarado como dica de investimento. O uso dessa ferramenta deve ser feito por pessoas responsáveis e que sabem exatamente o que estão fazendo.
	</h3>
</div>

---

## Como instalar 🛠️

1. **Clonar o Repositório**
   Faça o download ou clone este repositório usando:
   ```bash
   git clone https://github.com/SeuUsuario/Market-pulse.git
   ```

2. **Copiar os Arquivos**
   - Coloque todos os arquivos `.mq4` na pasta `Indicators` do MetaTrader 4.

3. **Compilar os Arquivos**
   Abra o MetaEditor, localize os arquivos copiados e compile-os pressionando **F7**.

4. **Carregar o Indicador**
   No MetaTrader 4, vá na aba "Navegador", selecione "Indicadores Personalizados" e arraste o indicador `MarketPulse` para o gráfico desejado.

---

## Arquivos 📂

- **`MarketPulse.mq4`**: 
  Indicador focado em calcular o melhor ponto possível de reversão de tendências. Ele funciona com base nos seguintes critérios:
  - Calcula a distância entre o preço atual e uma média móvel arbitrária e normaliza o valor de 0 a 100.
  - Aplica o mesmo processo ao volume, identificando níveis notáveis (máximo ponto histórico).
  - Gera sinais quando o volume atinge valores extremos junto com a máxima distância do preço atual em relação à média, partindo da ideia de que o preço sempre tende a retornar à média em algum momento.

- **`utils.mq4`**: 
  Biblioteca compilável contendo funções utilitárias para múltiplos projetos. Inclui:
  - Criação de buffers.
  - Ajustes de arrays temporários.
  - Criação de objetos visuais no gráfico.

---

## Considerações 🤔

O objetivo principal é aprimorar a ideia por trás do `MarketPulse`. Qualquer tipo de colaboração é muito bem-vinda! Sinta-se à vontade para abrir issues ou enviar pull requests.

---

## Contato 📬

Se tiver dúvidas ou sugestões, entre em contato através do Telegram: [@BlueXInd](https://t.me/BlueXInd).


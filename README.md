# FancyWindows - Scripts AutoHotkey para Melhoria do Fluxo de Trabalho no Windows

Este é um conjunto de scripts AutoHotkey v2 que adiciona funcionalidades avançadas de gerenciamento de janelas ao Windows, melhorando significativamente o fluxo de trabalho e produtividade.

## 🎯 Compatibilidade e Integração

Estes scripts foram especialmente **criados para auxiliar e melhorar o fluxo de trabalho** com o **FancyZones do PowerToys**, oferecendo funcionalidades complementares de navegação e controle de janelas. 

No entanto, o sistema funciona **muito bem** também com o **sistema de snap nativo do Windows** e suas janelas, proporcionando uma experiência aprimorada independentemente da ferramenta de gerenciamento de layout utilizada.

## 🚀 Como Usar

Execute o arquivo [`start.ahk`](start.ahk) para iniciar todos os scripts com privilégios de administrador, ou [`startNoAdmin.ahk`](startNoAdmin.ahk) para execução sem privilégios elevados.

## 📋 Funcionalidades e Atalhos

### 🎯 Navegação Entre Janelas (com Previews)

#### 1. **Alternar Entre Janelas da Mesma Aplicação**
![Preview Alternar Janelas Mesmo App](gif/toggleWindowSameApp.gif)

- **Arquivo**: [`toggleWindowSameApp.ahk`](toggleWindowSameApp.ahk)
- **Atalho**: `Win + ` ` (Win + Crase)
- **Função**: Alterna entre todas as janelas abertas do mesmo programa
- **Como usar**: Pressione e segure Win, depois pressione ` múltiplas vezes para navegar. Solte Win para confirmar a seleção

#### 2. **Alternar Entre Janelas na Mesma Região**
![Preview Alternar Janelas Mesma Zona](gif/toggleWindowSameZone.gif)

- **Arquivo**: [`toggleWindowSameZone.ahk`](toggleWindowSameZone.ahk)
- **Atalho**: `Alt + ` ` (Alt + Crase)
- **Função**: Alterna entre janelas que estão na mesma posição/tamanho da tela
- **Como usar**: Ideal para janelas maximizadas ou em posições similares

#### 3. **Navegação Direcional Entre Janelas**
![Preview Navegação Direcional](gif/focusZone.gif)

- **Arquivo**: [`focusZone.ahk`](focusZone.ahk)
- **Atalhos**: 
  - `Win + Shift + →` - Focar janela à direita
  - `Win + Shift + ←` - Focar janela à esquerda  
  - `Win + Shift + ↑` - Focar janela acima
  - `Win + Shift + ↓` - Focar janela abaixo

#### 4. **Centralizar Janela**
![Preview Centralizar Janela](gif/centeredWindow.gif)

- **Arquivo**: [`centeredWindow.ahk`](centeredWindow.ahk)
- **Atalho**: `Win + Enter`
- **Função**: Centraliza a janela ativa ocupando 60% da tela. Pressione novamente para restaurar posição original

### 🪟 Controle de Janelas

#### 5. **Maximizar/Restaurar Janela**
- **Arquivo**: [`maxRestoreWindow.ahk`](maxRestoreWindow.ahk)
- **Atalho**: `Win + Shift + Enter`
- **Função**: Alterna entre maximizar e restaurar a janela ativa

#### 6. **Maximizar/Minimizar Inteligente**
- **Arquivo**: [`maxMinWindow.ahk`](maxMinWindow.ahk)
- **Atalhos**:
  - `Win + Shift + Page Up` - Maximiza janela (ou restaura última minimizada se pressionado rapidamente)
  - `Win + Shift + Page Down` - Minimiza janela maximizada ou apenas minimiza se não maximizada
- **Função**: Sistema inteligente que lembra da última janela minimizada por 1.75 segundos

#### 7. **Fechar Janela com Confirmação**
- **Arquivo**: [`closeWindow.ahk`](closeWindow.ahk)
- **Atalho**: `Win + Q`
- **Função**: Fecha a janela ativa com diálogo de confirmação

### 🎨 Efeitos Visuais

#### 8. **Borda de Foco Temporária**
- **Arquivo**: [`globalFocusBorder.ahk`](globalFocusBorder.ahk)
- **Função**: Adiciona uma borda colorida temporária (250ms) ao redor da janela quando ela recebe foco
- **Cor**: Usa automaticamente a cor de destaque do tema do Windows

#### 9. **Efeito de Destaque por Flash**
- **Arquivo**: [`globalFocusHighlight.ahk`](globalFocusHighlight.ahk)
- **Função**: Aplica um efeito de flash escuro temporário quando uma janela recebe foco

## ⚙️ Configuração e Inicialização

### Arquivos de Inicialização

- **[`start.ahk`](start.ahk)**: Inicia todos os scripts com privilégios de administrador
- **[`startWithAdmin.ahk`](startWithAdmin.ahk)**: Configuração principal com privilégios elevados
- **[`startNoAdmin.ahk`](startNoAdmin.ahk)**: Versão sem privilégios de administrador (funcionalidades limitadas)

### Configurações Personalizáveis

#### Margem de Erro para Detecção de Zona
```ahk
MARGIN_ERROR := 30  ; pixels - ajuste conforme necessário
```

#### Espessura da Borda Visual
```ahk
borderThickness := 2  ; pixels
```

## 🔧 Requisitos

- **AutoHotkey v2.0.2** ou superior
- **Windows 10/11** (testado)
- **Privilégios de administrador** recomendados para funcionalidade completa

## 🎛️ Personalização

Todos os atalhos podem ser modificados editando os respectivos arquivos `.ahk`. As funcionalidades são modulares, permitindo habilitar/desabilitar scripts específicos conforme necessário.

### Exemplo de Modificação de Atalho

Para alterar `Win + Q` para `Ctrl + Q` no [`closeWindow.ahk`](closeWindow.ahk):
```ahk
; Altere esta linha:
#q:: {
; Para:
^q:: {
```

## 📁 Estrutura do Projeto

```
fancyWindows/
├── start.ahk                    # Inicializador principal
├── startWithAdmin.ahk          # Configuração com admin
├── startNoAdmin.ahk            # Configuração sem admin
├── toggleWindowSameApp.ahk     # Alternar janelas mesmo app
├── toggleWindowSameZone.ahk    # Alternar janelas mesma zona
├── focusZone.ahk               # Navegação direcional
├── centeredWindow.ahk          # Centralizar janela
├── maxRestoreWindow.ahk        # Maximizar/restaurar
├── maxMinWindow.ahk            # Maximizar/minimizar
├── closeWindow.ahk             # Fechar com confirmação
├── globalFocusBorder.ahk       # Borda temporária
├── globalFocusHighlight.ahk    # Efeito flash
└── gif/                        # Imagens de preview
    ├── toggleWindowSameApp.gif
    ├── toggleWindowSameZone.gif
    ├── focusZone.gif
    └── centeredWindow.gif
```

## 🤝 Contribuição

Sinta-se livre para modificar, melhorar ou adaptar estes scripts às suas necessidades específicas. Cada módulo foi projetado para ser independente e facilmente personalizável.

## 🙏 Créditos

Parte deste projeto foi desenvolvida e aprimorada com o auxílio do **GitHub Copilot**, que contribuiu significativamente para a criação, otimização e documentação dos scripts.
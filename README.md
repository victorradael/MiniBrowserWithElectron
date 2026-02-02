# Mini Browser With Electron (v2.0)

Um navegador minimalista focado em produtividade. Permite criar "Workspaces" (lista de URLs salvas) e manter a janela sempre no topo ("Always on Top") para facilitar o trabalho com referência cruzada. Inclui uma integração nativa com o Bitwarden via barra lateral.

**Stack Tecnológica:**
- **Core:** Electron
- **Tools:** Vite + electron-vite
- **UI:** React + TailwindCSS + Lucide Icons
- **Persistence:** electron-store

## Funcionalidades

- **Dashboard:** Gerencie suas URLs favoritas de forma persistente.
- **Always on Top:** Mantenha a janela visível sobre outras aplicações com um clique.
- **Bitwarden Sidebar:** Barra lateral retrátil e redimensional para gerenciar suas senhas via Bitwarden Web Vault.
- **Modo Escuro:** Interface otimizada para conforto visual e produtividade.

## Começando

### Pré-requisitos
- Node.js (v18+)
- Yarn (recomendado) ou NPM

### Instalação e Execução

1.  Clone o repositório:
    ```bash
    git clone https://github.com/victorradael/MiniBrowserWithElectron
    cd MiniBrowserWithElectron
    ```
2.  Instale as dependências:
    ```bash
    yarn
    # ou
    npm install
    ```
3.  Inicie a aplicação:
    ```bash
    yarn dev
    # ou
    npm run dev
    ```

## Utilização do Bitwarden

Ao contrário de navegadores convencionais, o Mini Browser utiliza uma **Sidebar de Web Vault** em vez de extensões pesadas:
1.  Clique no ícone de **Escudo (Shield)** ou no botão **Bitwarden**.
2.  Uma barra lateral abrirá à direita carregando o Vault oficial.
3.  Você pode **redimensionar** a barra puxando sua borda esquerda.
4.  Faça login uma vez e suas senhas estarão sempre à mão para copiar e colar.

## Construindo para Produção

Para criar o executável instalável:

```bash
yarn build:linux
# ou para Windows (se estiver no Windows)
yarn build
```

## Licença

Este projeto está licenciado sob a licença MIT. 


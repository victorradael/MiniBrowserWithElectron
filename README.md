# 🖥️ Mini Browser (v2.0)

Um navegador minimalista, elegante e focado em produtividade. O Mini Browser foi desenhado para ser uma ferramenta de referência leve, mantendo-se sempre à mão enquanto você trabalha em outras tarefas.

---

## ✨ Identidade Visual e Experiência
O Mini Browser abandona o visual de navegador padrão para uma experiência de aplicativo nativo moderno:
- **Janela Frameless**: Interface sem bordas ou barras de título do sistema, maximizando o espaço de conteúdo.
*   **Identidade Minimalista**: Ícone personalizado "Monitor" que reflete a proposta de ser sua segunda tela de trabalho.
*   **Favicons Inteligentes**: O cabeçalho e o dashboard exibem automaticamente os ícones dos sites (favicons) com sistema de fallback resiliente.
*   **Título Dinâmico**: O cabeçalho se comporta como uma aba inteligente, atualizando o título conforme você navega.

## 🚀 Funcionalidades Principais
- **Dashboard de Workspaces**: Salve e organize suas URLs frequentes com apelidos (aliases) personalizados.
- **Always on Top**: Fixe a janela sobre outros aplicativos com um clique para referência contínua.
- **Bitwarden Sidebar**: Gerenciador de senhas integrado via barra lateral redimensionável.
- **Elegant Error Handling**: Tela de erro customizada para conexões falhas ou URLs inválidas.
- **Atalhos Rápidos**: Feche instantaneamente a aplicação com `Ctrl + Q`.

---

## 🛠️ Stack Tecnológica
- **Engine**: Electron + Chromium
- **Frontend**: React + Vite
- **Estilização**: Tailwind CSS (Modern Dark Theme)
- **Ícones**: Lucide Icons + Google/DuckDuckGo Favicon Services
- **Persistência**: `electron-store` (JSON-based persistence)

## 📦 Começando

### Instalação para Usuários
Recomendamos baixar a versão oficial compilada para evitar necessidade de compilação:
👉 **[Baixar última versão (GitHub Releases)](https://github.com/victorradael/MiniBrowserWithElectron/releases)**

### Linux

#### Quick Install (Debian/Ubuntu/AppImage)
You can install the latest version of Mini Browser with a single command:
```bash
curl -fsSL https://raw.githubusercontent.com/victorradael/MiniBrowserWithElectron/main/scripts/install.sh | bash
```

To uninstall:
```bash
curl -fsSL https://raw.githubusercontent.com/victorradael/MiniBrowserWithElectron/main/scripts/uninstall.sh | bash
```

#### Manual Installation
- Download the `.deb` or `.AppImage` from the [latest release](https://github.com/victorradael/MiniBrowserWithElectron/releases/latest).

### Para Desenvolvedores
1.  **Clone e Instale**:
    ```bash
    git clone https://github.com/victorradael/MiniBrowserWithElectron
    cd MiniBrowserWithElectron
    yarn
    ```
2.  **Desenvolvimento**: `yarn dev`
3.  **Build Local**: `yarn build:linux`

---

## 🔐 Integração com Bitwarden
Em vez de extensões complexas, usamos o **Web Vault** oficial em uma sidebar:
1.  Abra a sidebar pelo ícone de **Escudo** ou botão na Dashboard.
2.  Redimensione a largura puxando a borda lateral.
3.  Suas credenciais estarão sempre à mão para copiar/colar de forma segura.

## 📄 Licença
Este projeto está licenciado sob a licença MIT. Criado por Victor Radael.


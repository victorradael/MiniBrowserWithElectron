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
curl -fsSL https://raw.githubusercontent.com/victorradael/MiniBrowserWithElectron/master/scripts/install.sh | bash
```

To uninstall:
```bash
curl -fsSL https://raw.githubusercontent.com/victorradael/MiniBrowserWithElectron/master/scripts/uninstall.sh | bash
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

### 🐧 Solução de Problemas (Linux)
Se ao rodar `yarn dev` você encontrar o erro `FATAL:setuid_sandbox_host.cc`, você tem duas opções:

#### 1. Solução Rápida (Bypass)
Execute o comando ignorando o sandbox:
```bash
yarn dev:no-sandbox
```

#### 2. Solução Definitiva (Permissões do Kernel)
O erro ocorre porque muitas distribuições Linux desativam "unprivileged user namespaces" por segurança. Você pode habilitar temporariamente:
```bash
sudo sysctl -w kernel.unprivileged_userns_clone=1
```
Ou tornar permanente adicionando `kernel.unprivileged_userns_clone=1` em `/etc/sysctl.d/99-sysctl.conf`.

#### 3. Diagnóstico Avançado
Se mesmo após o passo acima o erro persistir, verifique estes pontos:

*   **Limite de Namespaces**: Verifique se o limite não é zero:
    ```bash
    sysctl user.max_user_namespaces
    ```
    (Idealmente superior a 10000).
*   **Restrições de AppArmor (Ubuntu 24.04+)**: Algumas distros bloqueiam namespaces para apps não-profileados:
    ```bash
    # Para testar se o AppArmor está bloqueando:
    sudo dmesg | grep apparmor | grep -i "sandbox"
    # Para desativar a restrição (temporário):
    sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0
    ```

> [!CAUTION]
> **Segurança**: Desativar o sandbox ou alterar parâmetros do Kernel reduz o isolamento do sistema. Consulte o [Guia de Instalação](file:///home/radael/Documents/github.com/victorradael/MiniBrowserWithElectron/INSTALL.md#considerações-de-segurança) para entender as implicações antes de aplicar estas mudanças permanentemente.

---

## 🔐 Integração com Bitwarden
Em vez de extensões complexas, usamos o **Web Vault** oficial em uma sidebar:
1.  Abra a sidebar pelo ícone de **Escudo** ou botão na Dashboard.
2.  Redimensione a largura puxando a borda lateral.
3.  Suas credenciais estarão sempre à mão para copiar/colar de forma segura.

## 📄 Licença
Este projeto está licenciado sob a licença MIT. Criado por Victor Radael.


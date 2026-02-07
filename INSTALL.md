# Guia de Instalação e Distribuição

Este documento descreve como gerar os instaláveis do Mini Browser e como instalá-lo em sistemas Linux.

## ⬇️ Download e Instalação (Recomendado)

A maneira mais fácil de instalar é baixando a versão mais recente na página de **Releases** do GitHub:

👉 **[Baixar última versão (Releases)](https://github.com/victorradael/MiniBrowserWithElectron/releases/latest)**

1. Baixe o arquivo `.deb` (para instalação) ou `.AppImage` (para execução direta).
2. Siga as instruções de instalação abaixo.

---

## 🛠️ Gerando os Instaláveis Localmente (Desenvolvimento)

## 📦 Instalação (Ubuntu/Debian)

Se você gerou um arquivo `.deb`, pode instalá-lo via terminal:

### Instalar:
```bash
# Navegue até a pasta dist e instale o pacote gerado
sudo dpkg -i dist/mini-browser_*.deb
# Caso falte dependências:
sudo apt-get install -f
```

### Desinstalar:
```bash
sudo apt remove mini-browser
```

---

## 🚀 Execução via AppImage

O `AppImage` é um formato que não precisa de instalação. Basta dar permissão de execução:

1. Clique com o botão direito no arquivo `dist/mini-browser_*.AppImage`.
2. Vá em **Propriedades** > **Permissões** > Marque **Permitir execução**.
3. Ou via terminal:
   ```bash
   chmod +x dist/mini-browser_*.AppImage
   ./dist/mini-browser_*.AppImage
   ```

---

## 🧹 Limpeza (Desenvolvimento)

Para remover os arquivos temporários de build:
```bash
rm -rf dist/ out/
```

---

## 🔄 Fluxo de Atualização

### Script Automatizado
O script `install.sh` facilitado no README detecta se o Mini Browser já está presente no sistema. Se encontrar uma versão anterior, ele executa automaticamente o desinstalador antes de aplicar a nova versão, garantindo uma transição limpa.

### Notificações In-App
O Mini Browser agora verifica periodicamente novas releases no GitHub. Ao detectar uma versão superior:
1. Uma notificação elegante em **Aço Azul** aparece no canto da tela.
2. Ao clicar em "Atualizar", o link da release é aberto e o comando de instalação rápida é copiado para o seu clipboard por conveniência.

---

## 🐧 Solução de Problemas (Linux Sandbox)

Se o aplicativo falhar ao iniciar com erro de "SUID sandbox helper", você pode:

1. **Rodar sem sandbox (Rápido)**: 
   Adicione `--no-sandbox` ao comando de execução.

2. **Habilitar no Kernel (Recomendado)**:
   ```bash
   sudo sysctl -w kernel.unprivileged_userns_clone=1
   ```

3. **Verificar Limites e AppArmor**:
   *   Certifique-se que `user.max_user_namespaces` não é 0.
   *   Se estiver no Ubuntu 24.04+, pode ser necessário:
       ```bash
       sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0
       ```

---

## 🔐 Considerações de Segurança

Ao utilizar os comandos acima para resolver problemas de sandbox no Linux, esteja ciente das implicações:

| Comando / Flag | Risco | Recomendação |
| :--- | :--- | :--- |
| `--no-sandbox` | Remove o isolamento entre o conteúdo web e seu sistema. | Use apenas para desenvolvimento e com URLs confiáveis. |
| `unprivileged_userns_clone` | Aumenta a superfície de ataque para exploits de Kernel. | Necessário para Docker/Flatpak; mantenha habilitado se usar essas ferramentas. |
| `apparmor_restrict_unprivileged_userns` | Remove uma trava específica do Ubuntu contra exploits de privilégio. | Prefira habilitar perfis específicos do AppArmor se estiver em ambiente de produção. |

> [!IMPORTANT]
> O sandbox é a defesa primária do navegador contra sites maliciosos. Nunca navegue em sites desconhecidos com a flag `--no-sandbox` ativa.

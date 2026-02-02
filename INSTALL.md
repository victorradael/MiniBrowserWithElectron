# Guia de Instalação e Distribuição

Este documento descreve como gerar os instaláveis do Mini Browser e como instalá-lo em sistemas Linux.

## 🛠️ Gerando os Instaláveis (Build)

Para criar os pacotes de distribuição (como `.deb` e `AppImage`), execute o comando abaixo:

```bash
yarn build:linux
```

Após a conclusão, os arquivos serão gerados na pasta `dist/`.

---

## 📦 Instalação (Ubuntu/Debian)

Se você gerou um arquivo `.deb`, pode instalá-lo via terminal:

### Instalar:
```bash
sudo dpkg -i dist/mini-browser_2.0.0_amd64.deb
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

1. Clique com o botão direito no arquivo `dist/mini-browser_2.0.0_amd64.AppImage`.
2. Vá em **Propriedades** > **Permissões** > Marque **Permitir execução**.
3. Ou via terminal:
   ```bash
   chmod +x dist/mini-browser_2.0.0_amd64.AppImage
   ./dist/mini-browser_2.0.0_amd64.AppImage
   ```

---

## 🧹 Limpeza (Desenvolvimento)

Para remover os arquivos temporários de build:
```bash
rm -rf dist/ out/
```

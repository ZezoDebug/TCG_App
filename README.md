# 🃏 TCG App

Aplicativo mobile desenvolvido em **Flutter** para gerenciamento e
visualização de cartas de Trading Card Game (TCG).

O projeto permite listar cartas, visualizar detalhes e gerenciar dados
relacionados a usuários e coleções.

---
## 🚀 Tecnologias utilizadas

-   Flutter
-   Dart
-   Provider (gerenciamento de estado)
-   Android / iOS

---

## 📱 Funcionalidades

-   📋 Listagem de cartas
-   🔍 Visualização de detalhes da carta
-   👤 Sistema básico de usuário
-   📦 Organização por sets (coleções)
-   🔐 Estrutura de autenticação (provider)

---

## 🗂️ Estrutura do projeto

Uma visão simplificada da organização:

    lib/
     ├── models/        # Estruturas de dados (Card, Set, User)
     ├── providers/     # Gerenciamento de estado (Auth, TCG)
     ├── screens/       # Telas do app
     └── main.dart      # Ponto de entrada

### Exemplo

-   `tcg_card.dart` → representa uma carta
-   `tcg_provider.dart` → controla lista de cartas
-   `cards_screen.dart` → tela principal com listagem

---

## ⚙️ Como rodar o projeto

### 1. Clonar o repositório

``` bash
git clone <URL_DO_REPOSITORIO>
cd TCG_App
```

### 2. Instalar dependências

``` bash
flutter pub get
```

### 3. Rodar o app

``` bash
flutter run
```

---

## 📦 Build

Para gerar APK:

``` bash
flutter build apk
```

Para iOS:

``` bash
flutter build ios
```

---

## 🧠 Conceitos aplicados

-   Separação de responsabilidades (Model / Provider / UI)
-   Gerenciamento de estado com Provider
-   Navegação entre telas
-   Estrutura escalável para apps mobile

---
## Informacões Adicionais
### :busts_in_silhouette: Integrantes

- **Nome:** André Luis da Silva Reis | **RA:** 1987363  :man_technologist:
- **Nome:** Daniel Victor Costa | **RA:** 1989218  :man_technologist:
- **Nome:** Gustavo Henrique Vieira da Silva | **RA:** 1992080  :man_technologist:
- **Nome:** Joaquim Fernando Sant'ana Moreira | **RA:** 1993917 :man_technologist:
- **Nome:** José Vitor de Almida Lima | **RA:** 1994104 :man_technologist:

### Informações Acadêmicas
- **Universidade:** UNIMAR - Universidade de Marília :school:
- **Curso:** Analise e Desenvolvimento de Sistemas :mortar_board:
- **Disciplina:** Sistemas Móveis :computer:
- **Docente:** Luiz Carlos Querino Filho :man_teacher:

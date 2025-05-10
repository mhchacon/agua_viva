# Água Viva - Aplicativo de Avaliação de Nascentes

## Descrição

O Água Viva é um aplicativo móvel desenvolvido em Flutter para avaliação e monitoramento de nascentes de água. Ele permite que avaliadores realizem visitas técnicas, registrem dados importantes, tirem fotos e gerem relatórios detalhados sobre as nascentes.

## Funcionalidades Principais

- **Sistema de Avaliação**: Formulário completo para coleta de dados de nascentes
- **Dashboard**: Painel de controle com estatísticas e resumo das avaliações
- **Geração de PDF e XLSX**: Relatórios detalhados em PDF e XLSX das avaliações
- **Modo Offline**: Funcionamento completo mesmo sem conexão com internet
- **Sincronização Automática**: Sincronização de dados quando a conexão é restaurada
- **Compressão de Imagens**: Otimização automática de imagens para melhor performance
- **Testes Automatizados**: Suite de testes unitários, de widget e de integração

## Tecnologias Utilizadas

### Backend
- **Node.js**: Servidor para processamento de dados e API RESTful
- **MongoDB**: Banco de dados NoSQL para armazenamento flexível de dados
- **Express**: Framework web para construção de APIs robustas
- **JWT**: Autenticação segura via tokens

### Aplicativo
- **Flutter**: Framework multiplataforma para desenvolvimento de interfaces nativas
- **Dart**: Linguagem de programação otimizada para UI
- **Geolocator**: Precisão nas coordenadas e validação de localização
- **Camera**: Integração com câmera para captura de imagens
- **Shared Preferences**: Armazenamento local para funcionamento offline
- **Provider**: Gerenciamento de estado da aplicação

### Dashboard
- **Interface web responsiva**: Para visualização de dados pela SEMAS-PE
- **Leaflet/MapBox**: Visualização georreferenciada das nascentes
- **Charts.js**: Geração de gráficos e visualizações estatísticas

## Inovação

O Água Viva se destaca como solução inovadora para o mercado de PSA (Pagamento por Serviços Ambientais) por:

- **Validação automática de coordenadas**: Único aplicativo que valida automaticamente coordenadas em áreas de preservação
- **Funcionamento 100% offline**: Permite avaliações em áreas remotas sem sinal de internet
- **Sincronização inteligente**: Sincroniza dados quando a conexão é restaurada sem intervenção do usuário
- **Integração técnico-proprietário**: Unifica a validação técnica e feedback do proprietário na mesma plataforma
- **Redução de tempo**: Diminui o ciclo de validação de nascentes de semanas para dias
- **Compressão adaptativa**: Otimiza a qualidade de imagens com base nas condições de rede

## Plano de Desenvolvimento (5 Meses)

### Mês 1: Prototipação e API Básica
- **Sprint 1 (Dias 1-15)**
  - Finalização do protótipo interativo no Figma
  - Definição da arquitetura do sistema
  - Setup do ambiente de desenvolvimento
  - Criação do repositório e estrutura inicial do projeto

- **Sprint 2 (Dias 16-30)**
  - Implementação do backend básico (Node.js + MongoDB)
  - Desenvolvimento das primeiras telas do aplicativo
  - Configuração do sistema de autenticação
  - Criação dos modelos de dados iniciais

### Mês 2: Desenvolvimento Core e Sistema Offline
- **Sprint 3 (Dias 31-45)**
  - Implementação do formulário de avaliação
  - Desenvolvimento do gerenciamento de usuários
  - Criação do mecanismo de armazenamento local
  - Integração com câmera e sistema de fotos

- **Sprint 4 (Dias 46-60)**
  - Implementação completa do sistema offline
  - Desenvolvimento do mecanismo de sincronização
  - Criação da lógica de validação de dados
  - Testes unitários para componentes críticos

### Mês 3: Testes em Campo e Ajustes
- **Sprint 5 (Dias 61-75)**
  - Lançamento da versão beta para testes internos
  - Correção de bugs e melhorias de performance
  - Implementação de feedback visual para ações
  - Criação do sistema de notificações

- **Sprint 6 (Dias 76-90)**
  - Testes em campo com agricultores em diferentes regiões
  - Coleta e análise de feedback dos usuários
  - Ajustes na interface com base nos testes
  - Otimização da performance em dispositivos mais antigos

### Mês 4: Relatórios e Melhorias
- **Sprint 7 (Dias 91-105)**
  - Implementação do sistema de geração de relatórios
  - Desenvolvimento de indicadores e estatísticas
  - Melhorias na validação georreferenciada
  - Testes de integração completos

- **Sprint 8 (Dias 106-120)**
  - Desenvolvimento do dashboard administrativo
  - Implementação de filtros e busca avançada
  - Criação de gráficos e visualizações
  - Testes de usabilidade com stakeholders

### Mês 5: Integração e Lançamento
- **Sprint 9 (Dias 121-135)**
  - Integração com sistemas da SEMAS-PE
  - Desenvolvimento de APIs para interoperabilidade
  - Testes de segurança e proteção de dados
  - Criação de documentação técnica e manuais

- **Sprint 10 (Dias 136-150)**
  - Revisão final e correções de última hora
  - Preparação do ambiente de produção
  - Treinamento para equipes técnicas
  - Lançamento oficial do sistema

## Melhorias Recentes

### 1. Testes Automatizados
- Testes unitários para serviços e classes essenciais
- Testes de widget para componentes de UI
- Testes de integração para fluxos completos
- Scripts para execução automatizada dos testes

### 2. Melhorias de UX
- Feedback visual quando o aplicativo está em modo offline
- Banner informativo com status da conexão
- Notificações sobre sincronização de dados

### 3. Robustez
- Sincronização automática quando a conexão é restaurada
- Compressão de imagens antes do upload para reduzir consumo de dados
- Sistema de tentativas múltiplas de conexão com o servidor
- Armazenamento local robusto para dados offline

### 4. Dashboard Aprimorado
- Estatísticas detalhadas por município e estado das nascentes
- Gráficos e indicadores visuais de status
- Geração de relatórios consolidados
- Visualização rápida das últimas avaliações

## Como Executar o Projeto

### Pré-requisitos
- Flutter 3.0.0 ou superior
- Dart 3.0.0 ou superior
- Node.js 14.0.0 ou superior (para o servidor backend)
- MongoDB (para o armazenamento de dados)

### Instalação

1. Clone o repositório:
```
git clone https://github.com/seu-usuario/agua-viva.git
cd agua-viva
```

2. Instale as dependências:
```
flutter pub get
```

3. Execute o aplicativo:
```
flutter run
```

### Servidor Backend

Para iniciar o servidor de desenvolvimento:
```
python start_services.py
```

## Testes

Para executar os testes automatizados:

```
# Windows
run_tests.bat

# Linux/macOS
chmod +x run_tests.sh
./run_tests.sh
```

Para mais informações sobre os testes, consulte o arquivo [TESTING.md](TESTING.md).

## Estrutura do Projeto

```
lib/
  ├── config/           # Configurações da aplicação
  ├── models/           # Modelos de dados
  ├── screens/          # Telas da aplicação
  ├── services/         # Serviços (API, autenticação, etc.)
  ├── themes/           # Temas e estilos
  ├── utils/            # Utilitários e helpers
  ├── widgets/          # Widgets reutilizáveis
  └── main.dart         # Ponto de entrada da aplicação

test/
  ├── services/         # Testes unitários
  ├── widgets/          # Testes de widget 
  └── integration/      # Testes de integração
```

## Contribuição

Para contribuir com o projeto, por favor:

1. Faça um fork do repositório
2. Crie uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. Adicione testes para sua implementação
4. Faça commits das suas alterações (`git commit -am 'Adiciona nova funcionalidade'`)
5. Faça push para a branch (`git push origin feature/nova-funcionalidade`)
6. Abra um Pull Request

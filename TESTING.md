# Testes Automatizados - Água Viva

Este documento descreve os testes automatizados implementados no aplicativo Água Viva para garantir a qualidade e robustez do código.

## Tipos de Testes

O aplicativo possui três níveis de testes:

1. **Testes Unitários**: Testam componentes individuais e isolados da aplicação
2. **Testes de Widget**: Testam componentes de UI e sua interação
3. **Testes de Integração**: Testam fluxos completos da aplicação

## Estrutura de Diretórios

```
test/
  ├── services/                 # Testes unitários para serviços
  │   ├── assessment_service_test.dart
  │   └── api_service_test.dart
  ├── widgets/                  # Testes de widgets
  │   ├── offline_banner_test.dart
  │   └── dashboard_test.dart
  └── integration/              # Testes de integração
      └── app_flow_test.dart
```

## Executando os Testes

### Pré-requisitos
- Flutter SDK instalado
- Dependências do projeto instaladas (`flutter pub get`)

### Executando Todos os Testes

Para Windows:
```
run_tests.bat
```

Para Linux/macOS:
```
chmod +x run_tests.sh
./run_tests.sh
```

### Executando Testes Específicos

Testes unitários:
```
flutter test test/services/assessment_service_test.dart
flutter test test/api_service_test.dart
```

Testes de widgets:
```
flutter test test/widgets/offline_banner_test.dart
flutter test test/widgets/dashboard_test.dart
```

Testes de integração:
```
flutter test test/integration/app_flow_test.dart
```

## Recursos Testados

### Testes Unitários

1. **AssessmentService**
   - Carregamento de avaliações do servidor
   - Salvamento de avaliações offline
   - Sincronização quando conectado
   - Obtenção de avaliações por CPF do proprietário

2. **ApiService**
   - Verificação de conexão com o servidor
   - Alternância entre URLs de conexão
   - Requisições GET/POST
   - Funcionamento do modo offline

### Testes de Widget

1. **OfflineBanner**
   - Visibilidade condicional do banner
   - Texto e aparência do banner
   - Comportamento do botão de reconexão

2. **Dashboard**
   - Carregamento de estatísticas
   - Exibição correta de dados
   - Indicador de carregamento
   - Mensagem quando não há dados

### Testes de Integração

1. **Fluxo de Login**
   - Login e redirecionamento para o dashboard
   - Autenticação persistente

2. **Fluxo Offline**
   - Exibição do banner offline
   - Sincronização ao restaurar conexão
   - Persistência de dados offline

## Manutenção dos Testes

Ao adicionar novas funcionalidades ao aplicativo, desenvolva os testes correspondentes para garantir que o código permaneça robusto. Siga estas diretrizes:

1. **Testes Unitários**: Adicione para qualquer nova classe ou método
2. **Testes de Widget**: Adicione para novos componentes visuais
3. **Testes de Integração**: Atualize para incluir novos fluxos

Mantenha os mocks atualizados executando:
```
flutter pub run build_runner build
``` 
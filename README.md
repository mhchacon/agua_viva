# Água Viva - Aplicativo de Avaliação de Nascentes

## Descrição

O Água Viva é um aplicativo móvel desenvolvido em Flutter para avaliação e monitoramento de nascentes de água. Ele permite que avaliadores realizem visitas técnicas, registrem dados importantes, tirem fotos e gerem relatórios detalhados sobre as nascentes.

## Funcionalidades Principais

- **Sistema de Avaliação**: Formulário completo para coleta de dados de nascentes
- **Dashboard**: Painel de controle com estatísticas e resumo das avaliações
- **Geração de PDF**: Relatórios detalhados em PDF das avaliações
- **Modo Offline**: Funcionamento completo mesmo sem conexão com internet
- **Sincronização Automática**: Sincronização de dados quando a conexão é restaurada
- **Compressão de Imagens**: Otimização automática de imagens para melhor performance
- **Testes Automatizados**: Suite de testes unitários, de widget e de integração

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

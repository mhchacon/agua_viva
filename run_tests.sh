#!/bin/bash

echo "=== Executando testes para o aplicativo Água Viva ==="
echo ""

echo "Gerando arquivos mock..."
flutter pub run build_runner build --delete-conflicting-outputs

echo ""
echo "=== Executando testes unitários ==="
flutter test test/services/assessment_service_test.dart test/api_service_test.dart

echo ""
echo "=== Executando testes de widget ==="
flutter test test/widgets/offline_banner_test.dart test/widgets/dashboard_test.dart

echo ""
echo "=== Executando testes de integração ==="
flutter test test/integration/app_flow_test.dart

echo ""
echo "=== Teste completo ==="
flutter test

echo ""
echo "=== Testes concluídos ===" 
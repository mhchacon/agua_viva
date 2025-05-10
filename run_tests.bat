@echo off
echo === Executando testes para o aplicativo Agua Viva ===
echo.

echo Gerando arquivos mock...
call flutter pub run build_runner build --delete-conflicting-outputs

echo.
echo === Executando testes unitarios ===
call flutter test test/services/assessment_service_test.dart test/api_service_test.dart

echo.
echo === Executando testes de widget ===
call flutter test test/widgets/offline_banner_test.dart test/widgets/dashboard_test.dart

echo.
echo === Executando testes de integracao ===
call flutter test test/integration/app_flow_test.dart

echo.
echo === Teste completo ===
call flutter test

echo.
echo === Testes concluidos ===
pause 
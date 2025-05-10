import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../models/proprietario.dart';
import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';

class CadastroProprietarioScreen extends StatefulWidget {
  const CadastroProprietarioScreen({super.key});

  @override
  State<CadastroProprietarioScreen> createState() => _CadastroProprietarioScreenState();
}

class _CadastroProprietarioScreenState extends State<CadastroProprietarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _apiService = ApiService();
  final _logger = Logger('CadastroProprietarioScreen');
  
  // Controllers para os campos de texto
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _carController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  
  // Variáveis de estado
  bool _temNascente = false;
  int? _quantidadeNascentes;
  String _disponibilidadeAgua = 'o ano todo';
  final List<String> _usosNascente = [];
  String _vegetacaoAoRedor = 'muita';
  bool _temProtecao = false;
  bool _testeVazaoRealizado = false;
  double? _valorVazao;
  DateTime? _dataVazao;
  bool _analiseQualidadeRealizada = false;
  String? _parametrosAnalise;
  DateTime? _dataAnalise;
  String _corAgua = 'transparente';
  bool _obscureText = true;
  bool _obscureConfirmText = true;
  bool _isLoading = false;
  
  // Localização
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requestPermission = await Geolocator.requestPermission();
        if (requestPermission == LocationPermission.denied) {
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      _logger.severe('Erro ao obter localização: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nomeController.dispose();
    _cpfController.dispose();
    _carController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final proprietario = Proprietario(
          id: const Uuid().v4(),
          nomeCompleto: _nomeController.text,
          cpf: _cpfController.text,
          numeroCAR: _carController.text,
          dadosPropriedade: 'Latitude: $_latitude, Longitude: $_longitude',
          temNascente: _temNascente,
          quantidadeNascentes: _quantidadeNascentes,
          disponibilidadeAgua: _disponibilidadeAgua,
          usosNascente: _usosNascente,
          vegetacaoAoRedor: _vegetacaoAoRedor,
          temProtecao: _temProtecao,
          testeVazaoRealizado: _testeVazaoRealizado,
          valorVazao: _valorVazao,
          dataVazao: _dataVazao,
          analiseQualidadeRealizada: _analiseQualidadeRealizada,
          parametrosAnalise: _parametrosAnalise,
          dataAnalise: _dataAnalise,
          corAgua: _corAgua,
          email: _emailController.text,
          senha: _senhaController.text,
        );

        await _apiService.post('/proprietarios', proprietario.toJson());
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cadastro realizado com sucesso!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao realizar cadastro: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Proprietário'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cabeçalho com instruções
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: AppTheme.primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Como preencher este cadastro:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Preencha todos os campos marcados com *\n'
                            '• Se não souber alguma informação, deixe em branco\n'
                            '• A localização será capturada automaticamente\n'
                            '• Sua senha deve ter 8 números',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Dados Pessoais
                    _buildSectionTitle('1. Dados Pessoais'),
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome Completo *',
                        hintText: 'Digite seu nome completo',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu nome completo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cpfController,
                      decoration: const InputDecoration(
                        labelText: 'CPF *',
                        hintText: 'Digite apenas os números do CPF',
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 11,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu CPF';
                        }
                        if (value.length != 11) {
                          return 'O CPF deve ter 11 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _carController,
                      decoration: const InputDecoration(
                        labelText: 'Número do CAR *',
                        hintText: 'Digite o número do CAR da sua propriedade',
                        prefixIcon: Icon(Icons.home),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 41,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o número do CAR';
                        }
                        if (value.length != 41) {
                          return 'O número do CAR deve ter 41 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_latitude != null && _longitude != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Localização capturada com sucesso!',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Informações sobre Nascente
                    _buildSectionTitle('2. Informações sobre Nascente'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SwitchListTile(
                              title: const Text(
                                'Tem nascente na propriedade?',
                                style: TextStyle(fontSize: 16),
                              ),
                              subtitle: const Text('Marque se você tem nascente'),
                              value: _temNascente,
                              onChanged: (value) {
                                setState(() {
                                  _temNascente = value;
                                  if (!value) {
                                    _quantidadeNascentes = null;
                                  }
                                });
                              },
                            ),
                            if (_temNascente) ...[
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Quantidade de Nascentes',
                                  hintText: 'Digite quantas nascentes você tem',
                                  prefixIcon: Icon(Icons.water_drop),
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (_temNascente && (value == null || value.isEmpty)) {
                                    return 'Por favor, insira a quantidade de nascentes';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _quantidadeNascentes = int.tryParse(value);
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _disponibilidadeAgua,
                                decoration: const InputDecoration(
                                  labelText: 'Quando a água está disponível?',
                                  prefixIcon: Icon(Icons.calendar_today),
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'o ano todo', child: Text('O ano todo')),
                                  DropdownMenuItem(value: 'alguns meses', child: Text('Alguns meses')),
                                  DropdownMenuItem(value: 'quando chove', child: Text('Quando chove')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _disponibilidadeAgua = value!;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Para que você usa a água da nascente?',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              CheckboxListTile(
                                title: const Text('Para irrigação de plantação'),
                                value: _usosNascente.contains('irrigacao'),
                                onChanged: (value) {
                                  setState(() {
                                    if (value!) {
                                      _usosNascente.add('irrigacao');
                                    } else {
                                      _usosNascente.remove('irrigacao');
                                    }
                                  });
                                },
                              ),
                              CheckboxListTile(
                                title: const Text('Para os animais'),
                                value: _usosNascente.contains('animais'),
                                onChanged: (value) {
                                  setState(() {
                                    if (value!) {
                                      _usosNascente.add('animais');
                                    } else {
                                      _usosNascente.remove('animais');
                                    }
                                  });
                                },
                              ),
                              CheckboxListTile(
                                title: const Text('Para consumo próprio'),
                                value: _usosNascente.contains('consumo'),
                                onChanged: (value) {
                                  setState(() {
                                    if (value!) {
                                      _usosNascente.add('consumo');
                                    } else {
                                      _usosNascente.remove('consumo');
                                    }
                                  });
                                },
                              ),
                              CheckboxListTile(
                                title: const Text('Não uso a água'),
                                value: _usosNascente.contains('nenhum'),
                                onChanged: (value) {
                                  setState(() {
                                    if (value!) {
                                      _usosNascente.add('nenhum');
                                    } else {
                                      _usosNascente.remove('nenhum');
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _vegetacaoAoRedor,
                                decoration: const InputDecoration(
                                  labelText: 'Como está a vegetação ao redor?',
                                  prefixIcon: Icon(Icons.forest),
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'muita', child: Text('Muita vegetação')),
                                  DropdownMenuItem(value: 'pouca', child: Text('Pouca vegetação')),
                                  DropdownMenuItem(value: 'nenhuma', child: Text('Sem vegetação')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _vegetacaoAoRedor = value!;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              SwitchListTile(
                                title: const Text(
                                  'A nascente tem proteção?',
                                  style: TextStyle(fontSize: 16),
                                ),
                                subtitle: const Text('Por exemplo: cerca, muro, etc.'),
                                value: _temProtecao,
                                onChanged: (value) {
                                  setState(() {
                                    _temProtecao = value;
                                  });
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Testes e Análises
                    _buildSectionTitle('3. Testes e Análises'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SwitchListTile(
                              title: const Text(
                                'Já fez teste de vazão?',
                                style: TextStyle(fontSize: 16),
                              ),
                              subtitle: const Text('Teste que mede a quantidade de água'),
                              value: _testeVazaoRealizado,
                              onChanged: (value) {
                                setState(() {
                                  _testeVazaoRealizado = value;
                                  if (!value) {
                                    _valorVazao = null;
                                    _dataVazao = null;
                                  }
                                });
                              },
                            ),
                            if (_testeVazaoRealizado) ...[
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Valor da Vazão',
                                  hintText: 'Digite o valor encontrado no teste',
                                  prefixIcon: Icon(Icons.speed),
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    _valorVazao = double.tryParse(value);
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              ListTile(
                                title: const Text('Data do Teste'),
                                subtitle: Text(_dataVazao?.toString() ?? 'Toque para escolher a data'),
                                leading: const Icon(Icons.calendar_today),
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _dataVazao = date;
                                    });
                                  }
                                },
                              ),
                            ],
                            const SizedBox(height: 16),
                            SwitchListTile(
                              title: const Text(
                                'Já fez análise da água?',
                                style: TextStyle(fontSize: 16),
                              ),
                              subtitle: const Text('Análise que verifica a qualidade da água'),
                              value: _analiseQualidadeRealizada,
                              onChanged: (value) {
                                setState(() {
                                  _analiseQualidadeRealizada = value;
                                  if (!value) {
                                    _parametrosAnalise = null;
                                    _dataAnalise = null;
                                  }
                                });
                              },
                            ),
                            if (_analiseQualidadeRealizada) ...[
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'O que foi analisado?',
                                  hintText: 'Digite o que foi verificado na análise',
                                  prefixIcon: Icon(Icons.science),
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                                onChanged: (value) {
                                  setState(() {
                                    _parametrosAnalise = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              ListTile(
                                title: const Text('Data da Análise'),
                                subtitle: Text(_dataAnalise?.toString() ?? 'Toque para escolher a data'),
                                leading: const Icon(Icons.calendar_today),
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _dataAnalise = date;
                                    });
                                  }
                                },
                              ),
                            ],
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _corAgua,
                              decoration: const InputDecoration(
                                labelText: 'Como está a cor da água?',
                                prefixIcon: Icon(Icons.color_lens),
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'transparente',
                                  child: Text('Clara (dá pra ver o fundo)'),
                                ),
                                DropdownMenuItem(
                                  value: 'suja',
                                  child: Text('Meio suja (amarelada, barrenta)'),
                                ),
                                DropdownMenuItem(
                                  value: 'muito_suja',
                                  child: Text('Muito suja (marrom escuro, preta)'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _corAgua = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Dados de Acesso
                    _buildSectionTitle('4. Dados de Acesso'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'E-mail *',
                                hintText: 'Digite seu e-mail para login',
                                prefixIcon: Icon(Icons.email),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira seu e-mail';
                                }
                                if (!value.contains('@')) {
                                  return 'Por favor, insira um e-mail válido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _senhaController,
                              decoration: InputDecoration(
                                labelText: 'Senha *',
                                hintText: 'Digite 8 números para sua senha',
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              obscureText: _obscureText,
                              keyboardType: TextInputType.number,
                              maxLength: 8,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira sua senha';
                                }
                                if (value.length != 8) {
                                  return 'A senha deve ter 8 números';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmarSenhaController,
                              decoration: InputDecoration(
                                labelText: 'Confirmar Senha *',
                                hintText: 'Digite a mesma senha novamente',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmText ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmText = !_obscureConfirmText;
                                    });
                                  },
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              obscureText: _obscureConfirmText,
                              keyboardType: TextInputType.number,
                              maxLength: 8,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, confirme sua senha';
                                }
                                if (value != _senhaController.text) {
                                  return 'As senhas não são iguais';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Botão de Cadastro
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.save, size: 28),
                        label: const Text(
                          'Salvar Cadastro',
                          style: TextStyle(fontSize: 20),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryColor,
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
} 
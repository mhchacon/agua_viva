import 'package:flutter/material.dart';
import '../theme.dart';

class CadastroProprietarioScreen extends StatefulWidget {
  const CadastroProprietarioScreen({Key? key}) : super(key: key);

  @override
  _CadastroProprietarioScreenState createState() => _CadastroProprietarioScreenState();
}

class _CadastroProprietarioScreenState extends State<CadastroProprietarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Controllers para os campos de texto
  final _nomeController = TextEditingController();
  final _carController = TextEditingController();
  final _dadosPropriedadeController = TextEditingController();
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

  @override
  void dispose() {
    _scrollController.dispose();
    _nomeController.dispose();
    _carController.dispose();
    _dadosPropriedadeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implementar lógica de cadastro
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Proprietário'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dados Pessoais
              _buildSectionTitle('Dados Pessoais'),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
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
                controller: _carController,
                decoration: const InputDecoration(
                  labelText: 'Número do CAR',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o número do CAR';
                  }
                  if (value.length != 41) {
                    return 'O número do CAR deve ter 41 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dadosPropriedadeController,
                decoration: const InputDecoration(
                  labelText: 'Dados da Propriedade',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira os dados da propriedade';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Informações sobre Nascente
              _buildSectionTitle('Informações sobre Nascente'),
              SwitchListTile(
                title: const Text('Tem nascente?'),
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
                    labelText: 'Disponibilidade de Água',
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
                const Text('Usos da Nascente:'),
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
                  title: const Text('Para animais'),
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
                  title: const Text('Não há uso'),
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
                    labelText: 'Vegetação ao Redor',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'muita', child: Text('Muita')),
                    DropdownMenuItem(value: 'pouca', child: Text('Pouca')),
                    DropdownMenuItem(value: 'nenhuma', child: Text('Nenhuma')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _vegetacaoAoRedor = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Tem proteção ao redor?'),
                  value: _temProtecao,
                  onChanged: (value) {
                    setState(() {
                      _temProtecao = value;
                    });
                  },
                ),
              ],
              const SizedBox(height: 24),

              // Testes e Análises
              _buildSectionTitle('Testes e Análises'),
              SwitchListTile(
                title: const Text('Teste de Vazão Realizado'),
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
                  subtitle: Text(_dataVazao?.toString() ?? 'Selecione a data'),
                  trailing: const Icon(Icons.calendar_today),
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
                title: const Text('Análise de Qualidade Realizada'),
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
                    labelText: 'Parâmetros Analisados',
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
                  subtitle: Text(_dataAnalise?.toString() ?? 'Selecione a data'),
                  trailing: const Icon(Icons.calendar_today),
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
                  labelText: 'Cor da Água',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'transparente',
                    child: Text('Transparente (clara, dá pra ver o fundo)'),
                  ),
                  DropdownMenuItem(
                    value: 'suja',
                    child: Text('Suja (meio barrenta, amarelada, não dá pra ver o fundo)'),
                  ),
                  DropdownMenuItem(
                    value: 'muito_suja',
                    child: Text('Muito suja (marrom escuro, preta, cheiro ruim)'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _corAgua = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Dados de Acesso
              _buildSectionTitle('Dados de Acesso'),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
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
                  labelText: 'Senha',
                  border: const OutlineInputBorder(),
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
                ),
                obscureText: _obscureText,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua senha';
                  }
                  if (value.length != 8) {
                    return 'A senha deve ter exatamente 8 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmarSenhaController,
                decoration: InputDecoration(
                  labelText: 'Confirmar Senha',
                  border: const OutlineInputBorder(),
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
                ),
                obscureText: _obscureConfirmText,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, confirme sua senha';
                  }
                  if (value != _senhaController.text) {
                    return 'As senhas não coincidem';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botão de Cadastro
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cadastrar',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
} 
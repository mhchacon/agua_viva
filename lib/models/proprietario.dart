class Proprietario {
  final String id;
  final String nomeCompleto;
  final String numeroCAR;
  final String dadosPropriedade;
  final bool temNascente;
  final int? quantidadeNascentes;
  final String disponibilidadeAgua;
  final List<String> usosNascente;
  final String vegetacaoAoRedor;
  final bool temProtecao;
  final bool testeVazaoRealizado;
  final double? valorVazao;
  final DateTime? dataVazao;
  final bool analiseQualidadeRealizada;
  final String? parametrosAnalise;
  final DateTime? dataAnalise;
  final String corAgua;
  final String email;
  final String senha;

  Proprietario({
    required this.id,
    required this.nomeCompleto,
    required this.numeroCAR,
    required this.dadosPropriedade,
    required this.temNascente,
    this.quantidadeNascentes,
    required this.disponibilidadeAgua,
    required this.usosNascente,
    required this.vegetacaoAoRedor,
    required this.temProtecao,
    required this.testeVazaoRealizado,
    this.valorVazao,
    this.dataVazao,
    required this.analiseQualidadeRealizada,
    this.parametrosAnalise,
    this.dataAnalise,
    required this.corAgua,
    required this.email,
    required this.senha,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomeCompleto': nomeCompleto,
      'numeroCAR': numeroCAR,
      'dadosPropriedade': dadosPropriedade,
      'temNascente': temNascente,
      'quantidadeNascentes': quantidadeNascentes,
      'disponibilidadeAgua': disponibilidadeAgua,
      'usosNascente': usosNascente,
      'vegetacaoAoRedor': vegetacaoAoRedor,
      'temProtecao': temProtecao,
      'testeVazaoRealizado': testeVazaoRealizado,
      'valorVazao': valorVazao,
      'dataVazao': dataVazao?.toIso8601String(),
      'analiseQualidadeRealizada': analiseQualidadeRealizada,
      'parametrosAnalise': parametrosAnalise,
      'dataAnalise': dataAnalise?.toIso8601String(),
      'corAgua': corAgua,
      'email': email,
      'senha': senha,
    };
  }

  factory Proprietario.fromJson(Map<String, dynamic> json) {
    return Proprietario(
      id: json['id'],
      nomeCompleto: json['nomeCompleto'],
      numeroCAR: json['numeroCAR'],
      dadosPropriedade: json['dadosPropriedade'],
      temNascente: json['temNascente'],
      quantidadeNascentes: json['quantidadeNascentes'],
      disponibilidadeAgua: json['disponibilidadeAgua'],
      usosNascente: List<String>.from(json['usosNascente']),
      vegetacaoAoRedor: json['vegetacaoAoRedor'],
      temProtecao: json['temProtecao'],
      testeVazaoRealizado: json['testeVazaoRealizado'],
      valorVazao: json['valorVazao'],
      dataVazao: json['dataVazao'] != null ? DateTime.parse(json['dataVazao']) : null,
      analiseQualidadeRealizada: json['analiseQualidadeRealizada'],
      parametrosAnalise: json['parametrosAnalise'],
      dataAnalise: json['dataAnalise'] != null ? DateTime.parse(json['dataAnalise']) : null,
      corAgua: json['corAgua'],
      email: json['email'],
      senha: json['senha'],
    );
  }
} 
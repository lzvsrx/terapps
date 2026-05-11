import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:tera_assistente/data/models.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  Database? _db;

  static final List<ProfessionPreset> _professionPresets = [
    ProfessionPreset(name: 'Administrador', category: 'Gestao', description: 'Planejamento, indicadores e processos.'),
    ProfessionPreset(name: 'Advogado', category: 'Juridico', description: 'Pecas, prazos, contratos e atendimento legal.'),
    ProfessionPreset(name: 'Arquiteto', category: 'Construcao', description: 'Projetos, memoriais, cronogramas e clientes.'),
    ProfessionPreset(name: 'Assistente Administrativo', category: 'Gestao', description: 'Documentos, agenda e operacoes internas.'),
    ProfessionPreset(name: 'Biomedico', category: 'Saude', description: 'Laudos, protocolos e controle laboratorial.'),
    ProfessionPreset(name: 'Cientista de Dados', category: 'Tecnologia', description: 'Analise, modelos e metricas de negocio.'),
    ProfessionPreset(name: 'Comerciante', category: 'Vendas', description: 'Estoque, pedidos, fluxo de caixa e clientes.'),
    ProfessionPreset(name: 'Contador', category: 'Financas', description: 'Balancos, impostos e conformidade fiscal.'),
    ProfessionPreset(name: 'Dentista', category: 'Saude', description: 'Prontuario, atendimento e planejamento clinico.'),
    ProfessionPreset(name: 'Designer', category: 'Criativo', description: 'Briefing, entregas, revisoes e portfolio.'),
    ProfessionPreset(name: 'Desenvolvedor de Software', category: 'Tecnologia', description: 'Codigo, backlog, bugs e releases.'),
    ProfessionPreset(name: 'Economista', category: 'Financas', description: 'Projecoes, analises e relatorios economicos.'),
    ProfessionPreset(name: 'Educador Fisico', category: 'Saude', description: 'Treinos, evolucao e orientacao de alunos.'),
    ProfessionPreset(name: 'Eletricista', category: 'Servicos Tecnicos', description: 'Ordens de servico, materiais e seguranca.'),
    ProfessionPreset(name: 'Enfermeiro', category: 'Saude', description: 'Escalas, cuidados, protocolos e registros.'),
    ProfessionPreset(name: 'Engenheiro Civil', category: 'Construcao', description: 'Obra, medicao, custos e seguranca.'),
    ProfessionPreset(name: 'Engenheiro de Producao', category: 'Industria', description: 'Eficiencia, qualidade e cadeia produtiva.'),
    ProfessionPreset(name: 'Farmaceutico', category: 'Saude', description: 'Dispensacao, controle e legislacao tecnica.'),
    ProfessionPreset(name: 'Fotografo', category: 'Criativo', description: 'Ensaios, contratos, agenda e arquivos.'),
    ProfessionPreset(name: 'Garcom', category: 'Atendimento', description: 'Pedidos, mesas, prioridades e controle.'),
    ProfessionPreset(name: 'Gestor de RH', category: 'Gestao', description: 'Recrutamento, pessoas e desempenho.'),
    ProfessionPreset(name: 'Jornalista', category: 'Comunicacao', description: 'Pautas, fontes, entrevistas e publicacao.'),
    ProfessionPreset(name: 'Mecanico', category: 'Servicos Tecnicos', description: 'Diagnostico, pecas, revisoes e historico.'),
    ProfessionPreset(name: 'Medico', category: 'Saude', description: 'Anamnese, exames, prescricao e retorno.'),
    ProfessionPreset(name: 'Motorista', category: 'Logistica', description: 'Rotas, entregas, combustivel e manutencao.'),
    ProfessionPreset(name: 'Nutricionista', category: 'Saude', description: 'Planos alimentares, evolucao e metas.'),
    ProfessionPreset(name: 'Pedagogo', category: 'Educacao', description: 'Planos de aula, desenvolvimento e avaliacao.'),
    ProfessionPreset(name: 'Policial', category: 'Seguranca', description: 'Ocorrencias, rondas e relatorios.'),
    ProfessionPreset(name: 'Professor', category: 'Educacao', description: 'Turmas, planos, notas e acompanhamentos.'),
    ProfessionPreset(name: 'Psicologo', category: 'Saude', description: 'Atendimentos, evolucao e planejamento clinico.'),
    ProfessionPreset(name: 'Publicitario', category: 'Comunicacao', description: 'Campanhas, midias e performance.'),
    ProfessionPreset(name: 'Soldador', category: 'Industria', description: 'Ordens, medidas, seguranca e qualidade.'),
    ProfessionPreset(name: 'Tecnico de Enfermagem', category: 'Saude', description: 'Cuidados e registros assistenciais.'),
    ProfessionPreset(name: 'Tecnico em Informatica', category: 'Tecnologia', description: 'Suporte, inventario e manutencao.'),
    ProfessionPreset(name: 'Tradutor', category: 'Linguas', description: 'Projetos, prazos e memoria terminologica.'),
    ProfessionPreset(name: 'Vendedor', category: 'Vendas', description: 'Leads, propostas, funil e pos-venda.'),
    ProfessionPreset(name: 'Outro', category: 'Geral', description: 'Profissao personalizada escolhida pelo usuario.'),
  ];

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'tera_assistente.db');

    return openDatabase(path, version: 1, onCreate: (database, version) async {
      await database.execute('CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL,email TEXT NOT NULL UNIQUE,profession TEXT NOT NULL,password_hash TEXT NOT NULL,created_at TEXT NOT NULL)');
      await database.execute('CREATE TABLE professions(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL UNIQUE,category TEXT NOT NULL,description TEXT NOT NULL)');
      await database.execute('CREATE TABLE records(id INTEGER PRIMARY KEY AUTOINCREMENT,user_id INTEGER NOT NULL,profession TEXT NOT NULL,type TEXT NOT NULL,title TEXT NOT NULL,content TEXT NOT NULL,created_at TEXT NOT NULL,FOREIGN KEY(user_id) REFERENCES users(id))');

      for (final p in _professionPresets) {
        await database.insert('professions', {'name': p.name, 'category': p.category, 'description': p.description});
      }
    });
  }

  String _hash(String value) => sha256.convert(value.codeUnits).toString();

  Future<bool> registerUser({required String name, required String email, required String profession, required String password}) async {
    final database = await db;
    try {
      await database.insert('users', {
        'name': name,
        'email': email.trim().toLowerCase(),
        'profession': profession,
        'password_hash': _hash(password),
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<User?> login({required String email, required String password}) async {
    final database = await db;
    final rows = await database.query('users', where: 'email = ? AND password_hash = ?', whereArgs: [email.trim().toLowerCase(), _hash(password)], limit: 1);
    if (rows.isEmpty) return null;
    final row = rows.first;
    return User(id: row['id'] as int, name: row['name'] as String, email: row['email'] as String, profession: row['profession'] as String);
  }

  Future<List<ProfessionPreset>> getProfessions() async {
    final database = await db;
    final rows = await database.query('professions', orderBy: 'name ASC');
    return rows.map((r) => ProfessionPreset(name: r['name'] as String, category: r['category'] as String, description: r['description'] as String)).toList();
  }

  Future<void> addRecord({required int userId, required String profession, required String type, required String title, required String content}) async {
    final database = await db;
    await database.insert('records', {
      'user_id': userId,
      'profession': profession,
      'type': type,
      'title': title,
      'content': content,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<WorkRecord>> getRecords(int userId) async {
    final database = await db;
    final rows = await database.query('records', where: 'user_id = ?', whereArgs: [userId], orderBy: 'created_at DESC');
    return rows
        .map((r) => WorkRecord(
              id: r['id'] as int,
              userId: r['user_id'] as int,
              profession: r['profession'] as String,
              type: r['type'] as String,
              title: r['title'] as String,
              content: r['content'] as String,
              createdAt: DateTime.parse(r['created_at'] as String),
            ))
        .toList();
  }
}

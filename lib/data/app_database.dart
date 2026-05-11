import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:tera_assistente/data/models.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  Database? _db;

  static final List<ProfessionPreset> _professionPresets = [
    ProfessionPreset(name: 'Administrador', category: 'Gestão', description: 'Planejamento, indicadores e processos.'),
    ProfessionPreset(name: 'Advogado', category: 'Jurídico', description: 'Peças, prazos, contratos e atendimento legal.'),
    ProfessionPreset(name: 'Arquiteto', category: 'Construção', description: 'Projetos, memoriais, cronogramas e clientes.'),
    ProfessionPreset(name: 'Assistente Administrativo', category: 'Gestão', description: 'Documentos, agenda e operações internas.'),
    ProfessionPreset(name: 'Biomédico', category: 'Saúde', description: 'Laudos, protocolos e controle laboratorial.'),
    ProfessionPreset(name: 'Cientista de Dados', category: 'Tecnologia', description: 'Análise, modelos e métricas de negócio.'),
    ProfessionPreset(name: 'Comerciante', category: 'Vendas', description: 'Estoque, pedidos, fluxo de caixa e clientes.'),
    ProfessionPreset(name: 'Contador', category: 'Finanças', description: 'Balanços, impostos e conformidade fiscal.'),
    ProfessionPreset(name: 'Dentista', category: 'Saúde', description: 'Prontuário, atendimento e planejamento clínico.'),
    ProfessionPreset(name: 'Designer', category: 'Criativo', description: 'Briefing, entregas, revisões e portfólio.'),
    ProfessionPreset(name: 'Desenvolvedor de Software', category: 'Tecnologia', description: 'Código, backlog, bugs e releases.'),
    ProfessionPreset(name: 'Economista', category: 'Finanças', description: 'Projeções, análises e relatórios econômicos.'),
    ProfessionPreset(name: 'Educador Físico', category: 'Saúde', description: 'Treinos, evolução e orientação de alunos.'),
    ProfessionPreset(name: 'Eletricista', category: 'Serviços Técnicos', description: 'Ordens de serviço, materiais e segurança.'),
    ProfessionPreset(name: 'Enfermeiro', category: 'Saúde', description: 'Escalas, cuidados, protocolos e registros.'),
    ProfessionPreset(name: 'Engenheiro Civil', category: 'Construção', description: 'Obra, medição, custos e segurança.'),
    ProfessionPreset(name: 'Engenheiro de Produção', category: 'Indústria', description: 'Eficiência, qualidade e cadeia produtiva.'),
    ProfessionPreset(name: 'Farmacêutico', category: 'Saúde', description: 'Dispensação, controle e legislação técnica.'),
    ProfessionPreset(name: 'Fotógrafo', category: 'Criativo', description: 'Ensaios, contratos, agenda e arquivos.'),
    ProfessionPreset(name: 'Garçom', category: 'Atendimento', description: 'Pedidos, mesas, prioridades e controle.'),
    ProfessionPreset(name: 'Gestor de RH', category: 'Gestão', description: 'Recrutamento, pessoas e desempenho.'),
    ProfessionPreset(name: 'Jornalista', category: 'Comunicação', description: 'Pautas, fontes, entrevistas e publicação.'),
    ProfessionPreset(name: 'Mecânico', category: 'Serviços Técnicos', description: 'Diagnóstico, peças, revisões e histórico.'),
    ProfessionPreset(name: 'Médico', category: 'Saúde', description: 'Anamnese, exames, prescrição e retorno.'),
    ProfessionPreset(name: 'Motorista', category: 'Logística', description: 'Rotas, entregas, combustível e manutenção.'),
    ProfessionPreset(name: 'Nutricionista', category: 'Saúde', description: 'Planos alimentares, evolução e metas.'),
    ProfessionPreset(name: 'Pedagogo', category: 'Educação', description: 'Planos de aula, desenvolvimento e avaliação.'),
    ProfessionPreset(name: 'Policial', category: 'Segurança', description: 'Ocorrências, rondas e relatórios.'),
    ProfessionPreset(name: 'Professor', category: 'Educação', description: 'Turmas, planos, notas e acompanhamentos.'),
    ProfessionPreset(name: 'Psicólogo', category: 'Saúde', description: 'Atendimentos, evolução e planejamento clínico.'),
    ProfessionPreset(name: 'Publicitário', category: 'Comunicação', description: 'Campanhas, mídias e performance.'),
    ProfessionPreset(name: 'Soldador', category: 'Indústria', description: 'Ordens, medidas, segurança e qualidade.'),
    ProfessionPreset(name: 'Técnico de Enfermagem', category: 'Saúde', description: 'Cuidados e registros assistenciais.'),
    ProfessionPreset(name: 'Técnico em Informática', category: 'Tecnologia', description: 'Suporte, inventário e manutenção.'),
    ProfessionPreset(name: 'Tradutor', category: 'Línguas', description: 'Projetos, prazos e memória terminológica.'),
    ProfessionPreset(name: 'Vendedor', category: 'Vendas', description: 'Leads, propostas, funil e pós-venda.'),
    ProfessionPreset(name: 'Outro', category: 'Geral', description: 'Profissão personalizada escolhida pelo usuário.'),
  ];

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'tera_assistente.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (database, version) async {
        await _createTables(database);
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await database.execute('ALTER TABLE records ADD COLUMN updated_at TEXT');
          await database.execute('ALTER TABLE records ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0');
        }
      },
    );
  }

  Future<void> _createTables(Database database) async {
    await database.execute('CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL,email TEXT NOT NULL UNIQUE,profession TEXT NOT NULL,password_hash TEXT NOT NULL,created_at TEXT NOT NULL)');
    await database.execute('CREATE TABLE professions(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL UNIQUE,category TEXT NOT NULL,description TEXT NOT NULL)');
    await database.execute('CREATE TABLE records(id INTEGER PRIMARY KEY AUTOINCREMENT,user_id INTEGER NOT NULL,profession TEXT NOT NULL,type TEXT NOT NULL,title TEXT NOT NULL,content TEXT NOT NULL,created_at TEXT NOT NULL,updated_at TEXT,is_favorite INTEGER NOT NULL DEFAULT 0,FOREIGN KEY(user_id) REFERENCES users(id))');

    for (final p in _professionPresets) {
      await database.insert('professions', {'name': p.name, 'category': p.category, 'description': p.description});
    }
  }

  String _hash(String value) => sha256.convert(value.codeUnits).toString();

  Future<bool> registerUser({required String name, required String email, required String profession, required String password}) async {
    final database = await db;
    try {
      await database.insert('users', {
        'name': name.trim(),
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
      'title': title.trim(),
      'content': content.trim(),
      'created_at': DateTime.now().toIso8601String(),
      'is_favorite': 0,
    });
  }

  Future<void> updateRecord({required int id, required String profession, required String type, required String title, required String content}) async {
    final database = await db;
    await database.update(
      'records',
      {
        'profession': profession,
        'type': type,
        'title': title.trim(),
        'content': content.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteRecord(int id) async {
    final database = await db;
    await database.delete('records', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> toggleFavorite(int id, bool isFavorite) async {
    final database = await db;
    await database.update('records', {'is_favorite': isFavorite ? 1 : 0, 'updated_at': DateTime.now().toIso8601String()}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<WorkRecord>> getRecords(int userId, {String query = '', bool onlyFavorites = false}) async {
    final database = await db;
    final q = query.trim();
    final whereParts = <String>['user_id = ?'];
    final args = <Object>[userId];

    if (q.isNotEmpty) {
      whereParts.add('(title LIKE ? OR content LIKE ? OR profession LIKE ? OR type LIKE ?)');
      args.addAll(['%$q%', '%$q%', '%$q%', '%$q%']);
    }
    if (onlyFavorites) {
      whereParts.add('is_favorite = 1');
    }

    final rows = await database.query(
      'records',
      where: whereParts.join(' AND '),
      whereArgs: args,
      orderBy: 'is_favorite DESC, created_at DESC',
    );

    return rows
        .map(
          (r) => WorkRecord(
            id: r['id'] as int,
            userId: r['user_id'] as int,
            profession: r['profession'] as String,
            type: r['type'] as String,
            title: r['title'] as String,
            content: r['content'] as String,
            createdAt: DateTime.parse(r['created_at'] as String),
            updatedAt: r['updated_at'] == null ? null : DateTime.parse(r['updated_at'] as String),
            isFavorite: (r['is_favorite'] as int? ?? 0) == 1,
          ),
        )
        .toList();
  }

  Future<String> exportUserSnapshotJson(int userId) async {
    final database = await db;
    final users = await database.query('users', where: 'id = ?', whereArgs: [userId], limit: 1);
    final records = await database.query('records', where: 'user_id = ?', whereArgs: [userId], orderBy: 'created_at DESC');

    final payload = {
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'user': users.isEmpty ? null : users.first,
      'records': records,
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }
}

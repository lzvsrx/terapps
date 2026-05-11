import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/github_backup_service.dart';
import 'data/models.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(ChangeNotifierProvider(create: (_) => AppState()..init(), child: const TeraApp()));
}

class TeraApp extends StatelessWidget {
  const TeraApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (_, app, __) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(app.textScale)),
        child: MaterialApp(
          title: 'TERA Assistente',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.buildTheme(highContrast: app.highContrast),
          home: app.user == null ? const LoginScreen() : const HomeScreen(),
        ),
      ),
    );
  }
}

class NeonBackground extends StatelessWidget {
  const NeonBackground({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppTheme.bgA, AppTheme.bgB, Color(0xFF0A1A33)]),
      ),
      child: Stack(
        children: [
          Positioned(top: -90, left: -50, child: _glow(AppTheme.neonPurple.withValues(alpha: 0.45), 240)),
          Positioned(bottom: -80, right: -40, child: _glow(AppTheme.neonBlue.withValues(alpha: 0.45), 220)),
          child,
        ],
      ),
    );
  }

  Widget _glow(Color color, double size) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: color, blurRadius: 90, spreadRadius: 20)]));
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NeonBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.asset('assets/images/logo.png', height: 120, semanticLabel: 'Logo da TERA'),
                        const SizedBox(height: 10),
                        Text('TERA', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 6),
                        const Text('Seu assistente pessoal de serviço', textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
                        const SizedBox(height: 12),
                        TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Senha')),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loading
                              ? null
                              : () async {
                                  setState(() => _loading = true);
                                  final ok = await context.read<AppState>().login(_email.text, _password.text);
                                  setState(() => _loading = false);
                                  if (!ok && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login inválido. Confira email e senha.')));
                                  }
                                },
                          child: Text(_loading ? 'Entrando...' : 'Entrar'),
                        ),
                        TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())), child: const Text('Criar conta')),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _profession;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: NeonBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nome completo')),
                      const SizedBox(height: 12),
                      TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _profession,
                        decoration: const InputDecoration(labelText: 'Profissão principal'),
                        items: app.professions.map((p) => DropdownMenuItem(value: p.name, child: Text('${p.name} (${p.category})'))).toList(),
                        onChanged: (value) => setState(() => _profession = value),
                      ),
                      const SizedBox(height: 12),
                      TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Senha')),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loading
                            ? null
                            : () async {
                                if (_name.text.isEmpty || _email.text.isEmpty || _password.text.length < 6 || _profession == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha todos os campos. Senha mínima: 6 caracteres.')));
                                  return;
                                }
                                setState(() => _loading = true);
                                final ok = await context.read<AppState>().register(name: _name.text, email: _email.text, profession: _profession!, password: _password.text);
                                setState(() => _loading = false);
                                if (!context.mounted) return;
                                if (!ok) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível cadastrar. Email pode já existir.')));
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cadastro concluído. Faça login.')));
                                Navigator.pop(context);
                              },
                        child: Text(_loading ? 'Salvando...' : 'Cadastrar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  final _search = TextEditingController();
  String _type = 'Informação';
  String? _profession;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final user = app.user!;
    final kit = app.toolkit;
    _profession ??= user.profession;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TERA Android'),
        actions: [
          IconButton(tooltip: 'Acessibilidade', onPressed: () => _showAccessibility(context, app), icon: const Icon(Icons.accessibility_new)),
          IconButton(tooltip: 'Backup GitHub', onPressed: () => _showBackupSettings(context, app), icon: const Icon(Icons.cloud_upload)),
          IconButton(tooltip: 'Sair', onPressed: () => context.read<AppState>().logout(), icon: const Icon(Icons.logout)),
        ],
      ),
      body: NeonBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => context.read<AppState>().refreshRecords(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Image.asset('assets/images/logo.png', width: 42, height: 42),
                        const SizedBox(width: 12),
                        Expanded(child: Text('Olá, ${user.name}', style: Theme.of(context).textTheme.titleLarge)),
                      ]),
                      const SizedBox(height: 8),
                      Text('Profissão: ${user.profession}'),
                      Text('Área: ${kit?.category ?? '-'}'),
                    ]),
                  ),
                ),
                if (kit != null) _toolkitCard(app, kit),
                _tasksCard(app),
                const SizedBox(height: 10),
                TextField(controller: _search, onChanged: context.read<AppState>().setSearchQuery, decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Buscar no histórico')),
                SwitchListTile(value: app.onlyFavorites, onChanged: app.setOnlyFavorites, title: const Text('Mostrar só favoritos')),
                _newRecordCard(context, app),
                const SizedBox(height: 12),
                Text('Histórico', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...app.records.map((r) => _recordCard(context, r)),
                if (app.records.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(14), child: Text('Nenhum registro encontrado.'))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolkitCard(AppState app, ProfessionToolkit kit) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Ferramentas e funções da profissão', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _chips('Ferramentas', kit.tools),
          _chips('Documentos', kit.documents, onTap: (v) => app.addQuickTemplateRecord(v, 'Arquivo')),
          _chips('Métricas', kit.metrics, onTap: (v) => app.addQuickTemplateRecord('Métrica: $v', 'Informação')),
          const SizedBox(height: 6),
          const Text('Toque em Documento/Métrica para gerar template rápido no histórico.'),
        ]),
      ),
    );
  }

  Widget _tasksCard(AppState app) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Rotina operacional diária', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...app.dailyTasks.map((t) => CheckboxListTile(
                value: t.done,
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(t.title),
                onChanged: (v) => app.setTaskDone(t, v ?? false),
              )),
          if (app.dailyTasks.isEmpty) const Text('Nenhuma rotina carregada para esta profissão.'),
        ]),
      ),
    );
  }

  Widget _newRecordCard(BuildContext context, AppState app) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Novo registro profissional', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _profession,
            decoration: const InputDecoration(labelText: 'Profissão do registro'),
            items: app.professions.map((p) => DropdownMenuItem(value: p.name, child: Text(p.name))).toList(),
            onChanged: (v) => setState(() => _profession = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Tipo'),
            items: const [
              DropdownMenuItem(value: 'Informação', child: Text('Informação')),
              DropdownMenuItem(value: 'Arquivo', child: Text('Arquivo')),
              DropdownMenuItem(value: 'Checklist', child: Text('Checklist')),
              DropdownMenuItem(value: 'Lembrete', child: Text('Lembrete')),
            ],
            onChanged: (v) => setState(() => _type = v ?? 'Informação'),
          ),
          const SizedBox(height: 12),
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Título')),
          const SizedBox(height: 12),
          TextField(controller: _content, maxLines: 4, decoration: const InputDecoration(labelText: 'Conteúdo / descrição')),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              if (_profession == null || _title.text.isEmpty || _content.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha profissão, título e conteúdo.')));
                return;
              }
              await context.read<AppState>().addRecord(profession: _profession!, type: _type, title: _title.text, content: _content.text);
              _title.clear();
              _content.clear();
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro salvo no banco local.')));
            },
            child: const Text('Salvar'),
          ),
        ]),
      ),
    );
  }

  Widget _chips(String title, List<String> items, {void Function(String)? onTap}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title),
      const SizedBox(height: 6),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: items
            .map((e) => ActionChip(
                  label: Text(e),
                  onPressed: onTap == null ? null : () => onTap(e),
                ))
            .toList(),
      ),
      const SizedBox(height: 8),
    ]);
  }

  Widget _recordCard(BuildContext context, WorkRecord record) {
    return Card(
      child: ListTile(
        leading: IconButton(icon: Icon(record.isFavorite ? Icons.star : Icons.star_border), onPressed: () => context.read<AppState>().toggleFavorite(record)),
        title: Text(record.title),
        subtitle: Text('${record.profession} • ${record.type}\n${record.content}'),
        trailing: PopupMenuButton<String>(
          onSelected: (v) async {
            if (v == 'edit') await _editRecord(context, record);
            if (v == 'delete' && context.mounted) await context.read<AppState>().deleteRecord(record.id);
          },
          itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Editar')), PopupMenuItem(value: 'delete', child: Text('Excluir'))],
        ),
        isThreeLine: true,
      ),
    );
  }

  Future<void> _editRecord(BuildContext context, WorkRecord record) async {
    final title = TextEditingController(text: record.title);
    final content = TextEditingController(text: record.content);
    String selectedType = record.type;
    String selectedProfession = record.profession;
    final professions = context.read<AppState>().professions;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgB,
        title: const Text('Editar registro'),
        content: StatefulBuilder(
          builder: (ctx, setStateDialog) => SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<String>(
                initialValue: selectedProfession,
                items: professions.map((p) => DropdownMenuItem(value: p.name, child: Text(p.name))).toList(),
                onChanged: (v) => setStateDialog(() => selectedProfession = v ?? selectedProfession),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                items: const [
                  DropdownMenuItem(value: 'Informação', child: Text('Informação')),
                  DropdownMenuItem(value: 'Arquivo', child: Text('Arquivo')),
                  DropdownMenuItem(value: 'Checklist', child: Text('Checklist')),
                  DropdownMenuItem(value: 'Lembrete', child: Text('Lembrete')),
                ],
                onChanged: (v) => setStateDialog(() => selectedType = v ?? selectedType),
              ),
              const SizedBox(height: 10),
              TextField(controller: title, decoration: const InputDecoration(labelText: 'Título')),
              const SizedBox(height: 10),
              TextField(controller: content, maxLines: 3, decoration: const InputDecoration(labelText: 'Conteúdo')),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await context.read<AppState>().updateRecord(id: record.id, profession: selectedProfession, type: selectedType, title: title.text, content: content.text);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAccessibility(BuildContext context, AppState app) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgB,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Acessibilidade', style: Theme.of(context).textTheme.titleMedium),
          SwitchListTile(value: app.highContrast, onChanged: app.toggleContrast, title: const Text('Alto contraste')),
          const SizedBox(height: 8),
          Text('Tamanho da fonte: ${app.textScale.toStringAsFixed(1)}x'),
          Slider(value: app.textScale, min: 0.9, max: 1.6, divisions: 7, onChanged: app.setScale),
        ]),
      ),
    );
  }

  Future<void> _showBackupSettings(BuildContext context, AppState app) async {
    final cfg = await GitHubBackupService.readConfig();
    final enabled = ValueNotifier<bool>(cfg.enabled);
    final owner = TextEditingController(text: cfg.owner);
    final repo = TextEditingController(text: cfg.repo);
    final branch = TextEditingController(text: cfg.branch);
    final path = TextEditingController(text: cfg.path);
    final token = TextEditingController();
    double minutes = cfg.intervalMinutes.toDouble();
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgB,
        title: const Text('Backup GitHub'),
        content: StatefulBuilder(
          builder: (ctx, setStateDialog) => SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ValueListenableBuilder<bool>(valueListenable: enabled, builder: (_, v, __) => SwitchListTile(value: v, onChanged: (nv) => enabled.value = nv, title: const Text('Ativar backup periódico'))),
              TextField(controller: owner, decoration: const InputDecoration(labelText: 'Owner GitHub (ex: lzvsrx)')),
              const SizedBox(height: 8),
              TextField(controller: repo, decoration: const InputDecoration(labelText: 'Repo (ex: terapps)')),
              const SizedBox(height: 8),
              TextField(controller: branch, decoration: const InputDecoration(labelText: 'Branch (ex: main)')),
              const SizedBox(height: 8),
              TextField(controller: path, decoration: const InputDecoration(labelText: 'Arquivo backup (ex: backups/db.json)')),
              const SizedBox(height: 8),
              TextField(controller: token, obscureText: true, decoration: const InputDecoration(labelText: 'Token GitHub (PAT)')),
              const SizedBox(height: 8),
              Text('Intervalo (min): ${minutes.toInt()}'),
              Slider(min: 5, max: 120, divisions: 23, value: minutes, onChanged: (v) => setStateDialog(() => minutes = v)),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
          ElevatedButton(
            onPressed: () async {
              final newConfig = BackupConfig(enabled: enabled.value, owner: owner.text, repo: repo.text, branch: branch.text.isEmpty ? 'main' : branch.text, path: path.text.isEmpty ? 'backups/tera-db-snapshot.json' : path.text, intervalMinutes: minutes.toInt());
              await app.saveBackupConfig(newConfig, token.text);
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configuração de backup salva.')));
            },
            child: const Text('Salvar config'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await app.backupNow();
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup enviado ao GitHub com sucesso.')));
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro no backup: $e')));
              }
            },
            child: const Text('Backup agora'),
          ),
        ],
      ),
    );
  }
}

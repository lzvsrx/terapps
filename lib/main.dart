import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'data/models.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: const TeraApp(),
    ),
  );
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.bgA, AppTheme.bgB, Color(0xFF0A1A33)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            left: -50,
            child: _glow(AppTheme.neonPurple.withValues(alpha: 0.45), 240),
          ),
          Positioned(
            bottom: -80,
            right: -40,
            child: _glow(AppTheme.neonBlue.withValues(alpha: 0.45), 220),
          ),
          child,
        ],
      ),
    );
  }

  Widget _glow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 90, spreadRadius: 20)],
      ),
    );
  }
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
                        const Text('Seu assistente pessoal de servico', textAlign: TextAlign.center),
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Login invalido. Confira email e senha.')),
                                    );
                                  }
                                },
                          child: Text(_loading ? 'Entrando...' : 'Entrar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                          child: const Text('Criar conta'),
                        ),
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
    final professions = app.professions;

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
                        value: _profession,
                        decoration: const InputDecoration(labelText: 'Profissao principal'),
                        items: professions
                            .map((p) => DropdownMenuItem(value: p.name, child: Text('${p.name} (${p.category})')))
                            .toList(),
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Preencha todos os campos. Senha minima: 6 caracteres.')),
                                  );
                                  return;
                                }
                                setState(() => _loading = true);
                                final ok = await context.read<AppState>().register(
                                  name: _name.text,
                                  email: _email.text,
                                  profession: _profession!,
                                  password: _password.text,
                                );
                                setState(() => _loading = false);
                                if (!context.mounted) return;
                                if (!ok) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Nao foi possivel cadastrar. Email pode ja existir.')),
                                  );
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Cadastro concluido. Fa�a login.')),
                                );
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
  String _type = 'Informacao';
  String? _profession;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final user = app.user!;
    final professions = app.professions;
    _profession ??= user.profession;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TERA Android'),
        actions: [
          IconButton(
            tooltip: 'Acessibilidade',
            onPressed: () => _showAccessibility(context, app),
            icon: const Icon(Icons.accessibility_new),
          ),
          IconButton(
            tooltip: 'Sair',
            onPressed: () => context.read<AppState>().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: NeonBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => context.read<AppState>().refreshRecords(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset('assets/images/logo.png', width: 42, height: 42),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text('Ol�, ${user.name}', style: Theme.of(context).textTheme.titleLarge),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Profissao: ${user.profession}'),
                        const SizedBox(height: 4),
                        const Text('Salve arquivos e informacoes de trabalho no banco local com historico.'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Novo registro profissional', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _profession,
                          decoration: const InputDecoration(labelText: 'Profissao do registro'),
                          items: professions.map((p) => DropdownMenuItem(value: p.name, child: Text(p.name))).toList(),
                          onChanged: (v) => setState(() => _profession = v),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _type,
                          decoration: const InputDecoration(labelText: 'Tipo'),
                          items: const [
                            DropdownMenuItem(value: 'Informacao', child: Text('Informacao')),
                            DropdownMenuItem(value: 'Arquivo', child: Text('Arquivo')),
                            DropdownMenuItem(value: 'Checklist', child: Text('Checklist')),
                            DropdownMenuItem(value: 'Lembrete', child: Text('Lembrete')),
                          ],
                          onChanged: (v) => setState(() => _type = v ?? 'Informacao'),
                        ),
                        const SizedBox(height: 12),
                        TextField(controller: _title, decoration: const InputDecoration(labelText: 'Titulo')),
                        const SizedBox(height: 12),
                        TextField(controller: _content, maxLines: 4, decoration: const InputDecoration(labelText: 'Conteudo / descricao')),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () async {
                            if (_profession == null || _title.text.isEmpty || _content.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Preencha profissao, titulo e conteudo.')),
                              );
                              return;
                            }
                            await context.read<AppState>().addRecord(
                                  profession: _profession!,
                                  type: _type,
                                  title: _title.text,
                                  content: _content.text,
                                );
                            _title.clear();
                            _content.clear();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Registro salvo no banco local.')),
                              );
                            }
                          },
                          child: const Text('Salvar'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Historico', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...app.records.map((r) => _recordCard(r)).toList(),
                if (app.records.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(14),
                      child: Text('Nenhum registro ainda. Crie o primeiro acima.'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _recordCard(WorkRecord record) {
    return Card(
      child: ListTile(
        title: Text(record.title),
        subtitle: Text('${record.profession} � ${record.type}\n${record.content}'),
        trailing: Text(DateFormat('dd/MM HH:mm').format(record.createdAt)),
      ),
    );
  }

  Future<void> _showAccessibility(BuildContext context, AppState app) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgB,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Acessibilidade', style: Theme.of(context).textTheme.titleMedium),
              SwitchListTile(
                value: app.highContrast,
                onChanged: (v) => app.toggleContrast(v),
                title: const Text('Alto contraste'),
              ),
              const SizedBox(height: 8),
              Text('Tamanho da fonte: ${app.textScale.toStringAsFixed(1)}x'),
              Slider(
                value: app.textScale,
                min: 0.9,
                max: 1.6,
                divisions: 7,
                onChanged: app.setScale,
              ),
            ],
          ),
        );
      },
    );
  }
}


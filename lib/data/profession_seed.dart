import 'dart:convert';

import 'models.dart';

final List<ProfessionPreset> kProfessionPresets = [
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

ProfessionToolkit toolkitFor(ProfessionPreset p) {
  final c = p.category;
  final toolsByCategory = {
    'Gestão': ['Agenda estratégica', 'Kanban de demandas', 'Controle de custos', 'Painel de metas'],
    'Jurídico': ['Controle de prazos', 'Gestor de contratos', 'Checklist de audiência', 'Banco de jurisprudência'],
    'Construção': ['Planejamento de obra', 'Medição de serviços', 'Controle de materiais', 'Checklist de segurança'],
    'Saúde': ['Prontuário resumido', 'Protocolos clínicos', 'Checklist de atendimento', 'Acompanhamento de evolução'],
    'Tecnologia': ['Backlog técnico', 'Registro de incidentes', 'Checklist de deploy', 'Inventário de ativos'],
    'Finanças': ['Fluxo de caixa', 'Conciliação', 'Calendário fiscal', 'Indicadores financeiros'],
    'Vendas': ['Pipeline', 'Follow-up diário', 'Registro de propostas', 'Metas comerciais'],
    'Criativo': ['Briefings', 'Planejamento de produção', 'Checklist de entrega', 'Banco de referências'],
    'Atendimento': ['Fila de atendimento', 'Checklist de abertura', 'Controle de pedidos', 'Feedback do cliente'],
    'Comunicação': ['Pauta editorial', 'Calendário de publicação', 'Checklist de aprovação', 'Métricas de alcance'],
    'Serviços Técnicos': ['Ordem de serviço', 'Diagnóstico técnico', 'Lista de peças', 'Checklist de qualidade'],
    'Logística': ['Roteirização', 'Controle de entregas', 'Checklist de veículo', 'Indicador de prazo'],
    'Educação': ['Plano de aula', 'Registro de turma', 'Avaliações', 'Evolução de alunos'],
    'Segurança': ['Registro de ocorrência', 'Rota de patrulha', 'Checklist operacional', 'Relatório de turno'],
    'Indústria': ['Plano de produção', 'Controle de qualidade', 'Registro de manutenção', 'Segurança operacional'],
    'Línguas': ['Memória terminológica', 'Gestão de projetos', 'Controle de revisão', 'Checklist de entrega'],
    'Geral': ['Agenda', 'Tarefas', 'Notas rápidas', 'Checklist diário'],
  };

  final docsByCategory = {
    'Gestão': ['Plano de ação', 'Ata de reunião', 'Relatório gerencial'],
    'Jurídico': ['Minuta de contrato', 'Petição padrão', 'Relatório de caso'],
    'Construção': ['Diário de obra', 'Memorial descritivo', 'Relatório de inspeção'],
    'Saúde': ['Registro de atendimento', 'Plano terapêutico', 'Evolução'],
    'Tecnologia': ['Relatório de incidente', 'Documento técnico', 'Checklist de release'],
    'Finanças': ['DRE simplificada', 'Fechamento mensal', 'Relatório tributário'],
    'Vendas': ['Proposta comercial', 'Registro de visita', 'Relatório de funil'],
    'Criativo': ['Briefing', 'Cronograma criativo', 'Checklist de entrega'],
    'Atendimento': ['Checklist de turno', 'Resumo de atendimento', 'Registro de problema'],
    'Comunicação': ['Plano editorial', 'Roteiro de conteúdo', 'Relatório de campanha'],
    'Serviços Técnicos': ['Ordem de serviço', 'Laudo técnico', 'Checklist pós-serviço'],
    'Logística': ['Manifesto de entrega', 'Checklist de rota', 'Relatório de ocorrências'],
    'Educação': ['Plano de aula', 'Relatório pedagógico', 'Avaliação'],
    'Segurança': ['Boletim', 'Relatório de ronda', 'Registro de evento'],
    'Indústria': ['Relatório de produção', 'Checklist de manutenção', 'Controle de não conformidade'],
    'Línguas': ['Memória de tradução', 'Relatório de revisão', 'Checklist final'],
    'Geral': ['Relatório diário', 'Checklist semanal', 'Registro de atividades'],
  };

  final routinesByCategory = {
    'Gestão': ['Planejar prioridades do dia', 'Revisar indicadores', 'Encerrar com retrospectiva'],
    'Jurídico': ['Revisar prazos do dia', 'Atualizar andamento dos casos', 'Preparar peças prioritárias'],
    'Construção': ['Inspeção de campo', 'Atualizar cronograma', 'Validar segurança da equipe'],
    'Saúde': ['Triagem inicial', 'Registrar evolução', 'Revisar condutas'],
    'Tecnologia': ['Triagem de backlog', 'Executar tarefas críticas', 'Documentar decisões'],
    'Finanças': ['Conferir entradas e saídas', 'Validar pendências fiscais', 'Atualizar projeções'],
    'Vendas': ['Prospectar leads', 'Executar follow-ups', 'Revisar taxa de conversão'],
    'Criativo': ['Definir prioridades criativas', 'Produzir entregáveis', 'Coletar feedback'],
    'Atendimento': ['Checar fila', 'Atender prioridades', 'Consolidar feedbacks'],
    'Comunicação': ['Planejar publicações', 'Produzir conteúdo', 'Monitorar resultados'],
    'Serviços Técnicos': ['Abrir ordens de serviço', 'Executar diagnósticos', 'Registrar encerramentos'],
    'Logística': ['Conferir rotas', 'Acompanhar entregas', 'Tratar ocorrências'],
    'Educação': ['Preparar aula', 'Aplicar atividades', 'Registrar evolução'],
    'Segurança': ['Briefing de turno', 'Executar rondas', 'Finalizar relatório'],
    'Indústria': ['Checar linha', 'Controlar qualidade', 'Registrar produtividade'],
    'Línguas': ['Planejar lote de tradução', 'Executar tradução', 'Revisar qualidade final'],
    'Geral': ['Definir 3 prioridades', 'Executar tarefas críticas', 'Registrar progresso'],
  };

  final metricsByCategory = {
    'Gestão': ['Cumprimento de metas', 'Lead time de demandas', 'Custo operacional'],
    'Jurídico': ['Prazos cumpridos', 'Casos ativos', 'Tempo médio por peça'],
    'Construção': ['Avanço físico', 'Desvio de custo', 'Incidentes de segurança'],
    'Saúde': ['Tempo de atendimento', 'Aderência a protocolo', 'Retorno de paciente'],
    'Tecnologia': ['Bugs abertos/fechados', 'Lead time de entrega', 'Disponibilidade'],
    'Finanças': ['Margem', 'Inadimplência', 'Fechamento no prazo'],
    'Vendas': ['Conversão', 'Ticket médio', 'Receita mensal'],
    'Criativo': ['Entregas no prazo', 'Retrabalho', 'Satisfação do cliente'],
    'Atendimento': ['Tempo de resposta', 'NPS', 'Resolução no primeiro contato'],
    'Comunicação': ['Alcance', 'Engajamento', 'Conversão por campanha'],
    'Serviços Técnicos': ['Tempo por ordem', 'Retrabalho', 'Aproveitamento de peças'],
    'Logística': ['OTIF', 'Custo por entrega', 'Ocorrências por rota'],
    'Educação': ['Participação', 'Evolução média', 'Aderência ao plano'],
    'Segurança': ['Ocorrências por turno', 'Tempo de resposta', 'Conformidade operacional'],
    'Indústria': ['OEE', 'Refugo', 'Paradas não planejadas'],
    'Línguas': ['Palavras/dia', 'Taxa de revisão', 'Pontualidade de entrega'],
    'Geral': ['Tarefas concluídas', 'Prazo médio', 'Produtividade diária'],
  };

  return ProfessionToolkit(
    profession: p.name,
    category: p.category,
    tools: toolsByCategory[c] ?? toolsByCategory['Geral']!,
    documents: docsByCategory[c] ?? docsByCategory['Geral']!,
    routines: routinesByCategory[c] ?? routinesByCategory['Geral']!,
    metrics: metricsByCategory[c] ?? metricsByCategory['Geral']!,
  );
}

String encodeList(List<String> data) => jsonEncode(data);
List<String> decodeList(String data) => (jsonDecode(data) as List).map((e) => e.toString()).toList();

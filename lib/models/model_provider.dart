enum AIProvider {
  gemini('Google Gemini', 'gemini'),
  claude('Anthropic Claude', 'claude'),
  openai('OpenAI GPT', 'openai'),
  openjarvisLocal('OpenJarvis Local Engine', 'openjarvis_local');

  final String label;
  final String id;
  const AIProvider(this.label, this.id);
}

class AIModelInfo {
  final String id;
  final String name;
  final AIProvider provider;
  final String description;
  final bool isDefault;

  const AIModelInfo({
    required this.id,
    required this.name,
    required this.provider,
    required this.description,
    this.isDefault = false,
  });

  static const List<AIModelInfo> availableModels = [
    // Gemini
    AIModelInfo(
      id: 'gemini-3.8-flash',
      name: 'Gemini 3.8 Flash',
      provider: AIProvider.gemini,
      description: 'Frontier high-speed multimodal reasoning & agent engine',
      isDefault: true,
    ),
    AIModelInfo(
      id: 'gemini-3.7-flash',
      name: 'Gemini 3.7 Flash',
      provider: AIProvider.gemini,
      description: 'High-speed reasoning and deterministic tool calling',
    ),
    AIModelInfo(
      id: 'gemini-3.5-flash',
      name: 'Gemini 3.5 Flash',
      provider: AIProvider.gemini,
      description: 'Foundational multi-step execution model',
    ),
    AIModelInfo(
      id: 'gemini-3.1-pro-preview',
      name: 'Gemini 3.1 Pro',
      provider: AIProvider.gemini,
      description: 'SOTA frontier reasoning, deep logic & coding intelligence',
    ),

    // Claude
    AIModelInfo(
      id: 'claude-3-5-sonnet-20241022',
      name: 'Claude 3.5 Sonnet',
      provider: AIProvider.claude,
      description: 'Nuanced coding, natural speech, elite logic',
    ),
    AIModelInfo(
      id: 'claude-3-5-haiku-20241022',
      name: 'Claude 3.5 Haiku',
      provider: AIProvider.claude,
      description: 'Speed-optimized, high concurrency assistant',
    ),

    // OpenAI
    AIModelInfo(
      id: 'gpt-4o',
      name: 'GPT-4o Omnimodal',
      provider: AIProvider.openai,
      description: 'General intelligence flagship multimodal model',
    ),
    AIModelInfo(
      id: 'gpt-4o-mini',
      name: 'GPT-4o Mini',
      provider: AIProvider.openai,
      description: 'Fast, cost-effective daily task runner',
    ),

    // OpenJarvis / Local Server
    AIModelInfo(
      id: 'openjarvis-local-default',
      name: 'OpenJarvis Engine (Local)',
      provider: AIProvider.openjarvisLocal,
      description: 'On-device / LAN LLM via Ollama or OpenJarvis daemon',
    ),
    AIModelInfo(
      id: 'qwen2.5-coder:7b',
      name: 'Qwen 2.5 Coder (Ollama)',
      provider: AIProvider.openjarvisLocal,
      description: 'Local code and task execution specialist',
    ),
    AIModelInfo(
      id: 'llama3.2:3b',
      name: 'Llama 3.2 3B (Ollama)',
      provider: AIProvider.openjarvisLocal,
      description: 'Ultra-compact on-device assistant',
    ),
  ];
}

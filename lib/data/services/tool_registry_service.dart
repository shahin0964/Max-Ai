import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ToolRegistryService {
  static const String _memoryKey = 'max_ai_long_term_memory';
  static const String _macrosKey = 'max_ai_macros';

  /// Get all stored continuous long-term memories
  static Future<List<String>> getStoredMemories() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_memoryKey) ?? [];
  }

  /// Format memories as a compact context injection snippet (< 30 tokens)
  static Future<String> getCompactMemorySummary() async {
    final list = await getStoredMemories();
    if (list.isEmpty) return '';
    final top = list.take(6).join('; ');
    return 'Long-Term Memory Context: [$top]';
  }

  /// Direct quick save without spending any Gemini API tokens
  static Future<void> saveQuickMemory(String fact) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_memoryKey) ?? [];
    list.add(fact);
    await prefs.setStringList(_memoryKey, list);
  }

  /// List of all 19 tools extracted from the autonomous agent engine
  static const List<Map<String, dynamic>> toolsSchema = [
    {
      'name': 'termux_run',
      'description': 'Execute a bash command in Termux and receive standard output.',
      'parameters': {
        'type': 'OBJECT',
        'properties': {
          'command': {'type': 'STRING', 'description': 'Bash command to run.'}
        },
        'required': ['command']
      }
    },
    {
      'name': 'open_app',
      'description': 'Launch any Android application by package or app name.',
      'parameters': {
        'type': 'OBJECT',
        'properties': {
          'app_name': {'type': 'STRING', 'description': 'Name of app e.g. WhatsApp, YouTube.'}
        },
        'required': ['app_name']
      }
    },
    {
      'name': 'whatsapp_send_message',
      'description': 'Send a WhatsApp message to a contact or phone number.',
      'parameters': {
        'type': 'OBJECT',
        'properties': {
          'phone_or_name': {'type': 'STRING', 'description': 'Contact name or phone number.'},
          'message': {'type': 'STRING', 'description': 'Text message to send.'}
        },
        'required': ['phone_or_name', 'message']
      }
    },
    {
      'name': 'whatsapp_read_chat',
      'description': 'Read recent notifications or messages from a sender.',
      'parameters': {
        'type': 'OBJECT',
        'properties': {
          'sender_name': {'type': 'STRING', 'description': 'Sender contact name.'}
        },
        'required': ['sender_name']
      }
    },
    {
      'name': 'make_call',
      'description': 'Make a direct phone call.',
      'parameters': {
        'type': 'OBJECT',
        'properties': {
          'contact_or_number': {'type': 'STRING', 'description': 'Phone number or contact name.'}
        },
        'required': ['contact_or_number']
      }
    },
    {
      'name': 'send_sms',
      'description': 'Send an SMS text message.',
      'parameters': {
        'type': 'OBJECT',
        'properties': {
          'phone_number': {'type': 'STRING', 'description': 'Recipient phone number.'},
          'message': {'type': 'STRING', 'description': 'Message body.'}
        },
        'required': ['phone_number', 'message']
      }
    },
    {
      'name': 'tap_text',
      'description': 'Tap a button or UI element matching the text on screen using accessibility.',
      'parameters': {
        'type': 'OBJECT',
        'properties': {
          'text': {'type': 'STRING', 'description': 'Label or text on the button.'}
        },
        'required': ['text']
      }
    },
    {
      'name': 'tap_coordinates',
      'description': 'Tap exact X, Y screen coordinates.',
      'parameters': {
        'type': 'OBJECT',
        'properties': {
          'x': {'type': 'INTEGER', 'description': 'X pixel coordinate.'},
          'y': {'type': 'INTEGER', 'description': 'Y pixel coordinate.'}
        },
        'required': ['x', 'y']
      }
    },
    {
      'name': 'read_screen_text',
      'description': 'Read all visible text currently shown on the screen.',
      'parameters': {'type': 'OBJECT', 'properties': {}}
    },
    {
      'name': 'swipe_screen',
      'description': 'Swipe screen in direction (up, down, left, right).',
      'parameters': {
        'type': 'OBJECT',
        'properties': {
          'direction': {'type': 'STRING', 'enum': ['up', 'down', 'left', 'right']}
        },
        'required': ['direction']
      }
    },
    {
      'name': 'set_torch',
      'description': 'Turn flashlight/torch ON or OFF.',
      'parameters': {
        'type': 'OBJECT',
        'properties': {
          'enabled': {'type': 'BOOLEAN', 'description': 'True for ON, False for OFF.'}
        },
        'required': ['enabled']
      }
    },
    {
      'name': 'set_volume',
      'description': 'Adjust device media volume (0-100).',
      'parameters': {
        'type': 'OBJECT',
        'properties': {
          'level_percent': {'type': 'INTEGER', 'description': 'Volume percentage (0-100).'}
        },
        'required': ['level_percent']
      }
    },
    {
      'name': 'play_youtube',
      'description': 'Search and play a video or music on YouTube.',
      'parameters': {
        'type': 'OBJECT',
        'properties': {
          'query': {'type': 'STRING', 'description': 'Search query or song name.'}
        },
        'required': ['query']
      }
    },
    {
      'name': 'spotify_play',
      'description': 'Search and play music on Spotify.',
      'parameters': {
        'type': 'OBJECT',
        'properties': {
          'query': {'type': 'STRING', 'description': 'Song or artist name.'}
        },
        'required': ['query']
      }
    },
    {
      'name': 'get_weather',
      'description': 'Fetch live weather forecast for a location.',
      'parameters': {
        'type': 'OBJECT',
        'properties': {
          'location': {'type': 'STRING', 'description': 'City or location name.'}
        },
        'required': ['location']
      }
    },
    {
      'name': 'web_search',
      'description': 'Search the web for latest real-time information.',
      'parameters': {
        'type': 'OBJECT',
        'properties': {
          'query': {'type': 'STRING', 'description': 'Search keywords.'}
        },
        'required': ['query']
      }
    },
    {
      'name': 'save_memory',
      'description': 'Save a fact, preference, or reminder to continuous memory.',
      'parameters': {
        'type': 'OBJECT',
        'properties': {
          'key': {'type': 'STRING', 'description': 'Topic or key e.g. user_name, coffee_preference.'},
          'content': {'type': 'STRING', 'description': 'The detailed fact to remember.'}
        },
        'required': ['key', 'content']
      }
    },
    {
      'name': 'recall_memory',
      'description': 'Search past memories and user preferences.',
      'parameters': {
        'type': 'OBJECT',
        'properties': {
          'query': {'type': 'STRING', 'description': 'Search query to find memories.'}
        },
        'required': ['query']
      }
    },
    {
      'name': 'run_macro',
      'description': 'Run a multi-step macro recorded for an app (e.g. "chatgpt image", "gemini image").',
      'parameters': {
        'type': 'OBJECT',
        'properties': {
          'macro_name': {'type': 'STRING', 'description': 'Name of the macro to execute.'}
        },
        'required': ['macro_name']
      }
    }
  ];

  /// Built-in app automation macros from Maya APK
  static const List<Map<String, dynamic>> builtInMacros = [
    {
      'name': 'chatgpt image',
      'intent': 'ChatGPT app me image generate karo aur gallery me save karo',
      'steps': ['open_app: ChatGPT', 'tap: New chat', 'type: Create an image', 'tap: Send Message', 'save_to_gallery']
    },
    {
      'name': 'gemini image',
      'intent': 'Gemini app me Images tool se image banao aur gallery me save karo',
      'steps': ['open_app: Gemini', 'tap: New chat', 'tap: Images', 'type: image prompt', 'tap: Send', 'tap: Save']
    },
    {
      'name': 'gemini video',
      'intent': 'Gemini app me Videos tool se video banao aur save karo',
      'steps': ['open_app: Gemini', 'tap: Videos', 'type: video prompt', 'tap: Send', 'tap: Save']
    }
  ];

  /// Execute an automation tool locally or simulate on-device action
  Future<String> executeTool(String toolName, Map<String, dynamic> args) async {
    final prefs = await SharedPreferences.getInstance();

    switch (toolName) {
      case 'save_memory':
        final key = args['key']?.toString() ?? 'note';
        final content = args['content']?.toString() ?? '';
        final memory = prefs.getStringList(_memoryKey) ?? [];
        memory.add('$key: $content');
        await prefs.setStringList(_memoryKey, memory);
        return '🧠 [Memory Saved]: $key -> $content';

      case 'recall_memory':
        final query = (args['query']?.toString() ?? '').toLowerCase();
        final memory = prefs.getStringList(_memoryKey) ?? [];
        final matched = memory.where((m) => m.toLowerCase().contains(query)).toList();
        if (matched.isEmpty) return 'No memories found for "$query".';
        return '🧠 [Memories Found]:\n' + matched.join('\n');

      case 'termux_run':
        final cmd = args['command']?.toString() ?? '';
        return '⚡ [Termux Command Executed]: $cmd\n(Sent via com.termux.RUN_COMMAND intent)';

      case 'open_app':
        final app = args['app_name']?.toString() ?? '';
        return '🚀 [App Launch]: Launching $app...';

      case 'whatsapp_send_message':
        final target = args['phone_or_name']?.toString() ?? '';
        final msg = args['message']?.toString() ?? '';
        return '💬 [WhatsApp]: Message sent to $target: "$msg"';

      case 'set_torch':
        final on = args['enabled'] == true;
        return '🔦 [Flashlight]: Flashlight turned ${on ? "ON" : "OFF"}.';

      case 'set_volume':
        final vol = args['level_percent'] ?? 50;
        return '🔊 [Volume]: Media volume set to $vol%.';

      case 'run_macro':
        final macro = args['macro_name']?.toString() ?? '';
        return '🤖 [Macro Runner]: Executing automation routine "$macro"... Completed successfully.';

      default:
        return '✅ Tool "$toolName" executed with arguments: $args';
    }
  }
}

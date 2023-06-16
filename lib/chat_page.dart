import 'package:flutter/material.dart';
import 'package:laboratorio5_consumo_ia/widgets/message_composer.dart';
import 'package:laboratorio5_consumo_ia/widgets/message_bubble.dart';

import 'api/chat_api.dart';
import 'models/chat_message.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    required this.chatApi,
    Key? key,
  }) : super(key: key);

  final ChatApi chatApi;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messages = <ChatMessage>[
    ChatMessage(
        "Hola, este chat te permite configurar un mensaje de acuerdo a tus gustos."
        "Luego de que termines de configurarlo envía el mensaje con el botón en la esquina inferior derecha y "
        "recibirás un mensaje de la IA con 5 mensajes motivacionales de acuerdo a tus gustos.",
        false),
  ];
  var _awaitingResponse = false;
  var tema = '';
  var estilo = '';
  var lexico = '';
  var extension = '';
  var enfoque = '';
  var _selectedTemaIndex = -1;
  var _selectedEstiloIndex = -1;
  var _selectedLexicoIndex = -1;
  var _selectedExtensionIndex = -1;
  var _selectedEnfoqueIndex = -1;

  var _isExpanded = false;

  final List<String> _checkboxTema = [
    'Naturaleza',
    'Vida',
  ];
  final List<String> _checkboxEstilo = [
    'Poetico',
    'Alegre',
  ];
  final List<String> _checkboxLexico = [
    'Simple',
    'Culto',
  ];
  final List<String> _checkboxExtension = [
    'Pequeña',
    'Mediana',
  ];
  final List<String> _checkboxEnfoque = [
    'Realista',
    'Reflexivo',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Motivacional')),
      body: Column(
        children: [
          SingleChildScrollView(
            child: ListTile(
              title: const Text('Configure su mensaje'),
              trailing:
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          if (_isExpanded)
            Column(
              children: _buildCheckboxes(),
            ),
          if (!_isExpanded)
            Expanded(
              child: ListView(
                children: [
                  ..._messages.map(
                    (msg) => MessageBubble(
                      content: msg.content,
                      isUserMessage: msg.isUserMessage,
                    ),
                  ),
                ],
              ),
            ),
          if (!_isExpanded)
            MessageComposer(
              onSubmitted: _onSubmitted,
              awaitingResponse: _awaitingResponse,
            ),
        ],
      ),
    );
  }

  List<Widget> _buildCheckboxes() {
    Widget buildCheckboxListTile(
        List<String> items, int selectedIndex, Function(int) onChanged) {
      return Column(
        children: [
          for (var index = 0; index < items.length; index++)
            CheckboxListTile(
              dense: true,
              title: Text(
                items[index],
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              value: selectedIndex == index,
              onChanged: (value) {
                onChanged(value! ? index : -1);
              },
            ),
        ],
      );
    }

    return [
      const Text('Selecciona un tema:'),
      buildCheckboxListTile(_checkboxTema, _selectedTemaIndex, (index) {
        setState(() {
          _selectedTemaIndex = index;
          tema = index != -1 ? _checkboxTema[index] : '';
        });
      }),
      const Text('Selecciona un estilo de las frases:'),
      buildCheckboxListTile(_checkboxEstilo, _selectedEstiloIndex, (index) {
        setState(() {
          _selectedEstiloIndex = index;
          estilo = index != -1 ? _checkboxEstilo[index] : '';
        });
      }),
      const Text('Selecciona el lexico de las frases:'),
      buildCheckboxListTile(_checkboxLexico, _selectedLexicoIndex, (index) {
        setState(() {
          _selectedLexicoIndex = index;
          lexico = index != -1 ? _checkboxLexico[index] : '';
        });
      }),
      const Text('Selecciona la extensión de las frases:'),
      buildCheckboxListTile(_checkboxExtension, _selectedExtensionIndex,
          (index) {
        setState(() {
          _selectedExtensionIndex = index;
          extension = index != -1 ? _checkboxExtension[index] : '';
        });
      }),
      const Text('Selecciona el enfoque de las frases:'),
      buildCheckboxListTile(_checkboxEnfoque, _selectedEnfoqueIndex, (index) {
        setState(() {
          _selectedEnfoqueIndex = index;
          enfoque = index != -1 ? _checkboxEnfoque[index] : '';
        });
      }),
    ];
  }

  Future<void> _onSubmitted(String _) async {
    if (tema != "") {
      String mensaje =
          "Genera una lista de 5 mensajes motivacionales sobre la ";
      mensaje += tema.toLowerCase();
      if (estilo != "") {
        mensaje += " con estilo ${estilo.toLowerCase()}";
      }
      if (lexico != "") {
        mensaje += " y con lexico ${lexico.toLowerCase()}";
      }
      if (extension != "") {
        mensaje += " de ${extension.toLowerCase()} extensión";
      }
      if (enfoque != "") {
        mensaje += " con enfoque ${enfoque.toLowerCase()}.";
      }
      setState(() {
        _messages.add(ChatMessage(mensaje, true));
        _awaitingResponse = true;
      });
      try {
        final response = await widget.chatApi.completeChat(_messages);
        setState(() {
          _messages.add(ChatMessage(response, false));
          _awaitingResponse = false;
        });
      } catch (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Ha ocurrido un error, intentanlo más tarde.')),
        );
        setState(() {
          _awaitingResponse = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Debe seleccionar un tema para generar un mensaje.')),
      );
      setState(() {
        _awaitingResponse = false;
      });
    }
  }
}

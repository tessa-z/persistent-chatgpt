import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const chat_context = {"role": "system", "content": "You are a happy person who loves life."};

var previous_messages = [
  chat_context,
];

class AIHandler {
  final _openAI = OpenAI.instance.build(
    token: dotenv.env['OPENAI_APIKEY'],
    baseOption: HttpSetup(
      receiveTimeout: const Duration(seconds: 60),
      connectTimeout: const Duration(seconds: 60),
    ),
  );

  Future<String> getResponse(String message) async {
    try {
      final outgoing_message = {"role": "user", "content": message};
      previous_messages.add(outgoing_message);
      final request = ChatCompleteText(
          messages: previous_messages,
          maxToken: 200,
          model: kChatGptTurbo0301Model);

      final response = await _openAI.onChatCompletion(request: request);
      if (response != null) {
        final incoming_message = {
          "role": "assistant",
          "content": response.choices[0].message.content
        };
        previous_messages.add(incoming_message);
        return response.choices[0].message.content;
      }

      return 'Something went wrong';
    } catch (e) {
      return 'Bad response';
    }
  }

  void dispose() {
    _openAI.close();
  }
}

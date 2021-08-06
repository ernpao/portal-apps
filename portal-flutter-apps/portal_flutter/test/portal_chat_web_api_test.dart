import 'package:flutter_test/flutter_test.dart';
import 'package:glider_portal/glider_portal.dart';

void main() {
  test("Portal Chat", () async {});

  test("Portal Chat - ChatMessage Parsing", () async {
    const chatMessageListString = ''
        '['
        ' {'
        '   "id": 941,'
        '     "sender": {'
        '     "username": "John_Doe",'
        '     "first_name": "John",'
        '     "last_name": "Doe",'
        '     "avatar": "https://api-chat-engine-io-dev.s3.amazonaws.com/avatars/Screen_Shot_2020-12-15_at_7.42.34_AM.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAZA5RH3ECSKRVH2UM%2F20210504%2Fca-central-1%2Fs3%2Faws4_request&X-Amz-Date=20210504T155211Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=b9b9d3c4798f07705ea7988de72afbcf8e4f2827bbccf4d6fa236450c78cb9c2",'
        '     "custom_json": {},'
        '     "is_online": false'
        '   },'
        ' "created": "2021-05-04 15:51:35.540919+00:00",'
        ' "attachments": [],'
        ' "sender_username": "John_Doe",'
        ' "text": "Hello world!",'
        ' "custom_json": {'
        '   "gif": "https://giphy.com/clips/ufc-4eZuG5kNYvDrGc6gYk"'
        '   }'
        ' }'
        ']';

    final messages = Message.parseList(chatMessageListString);
    final message = messages[0];

    assert(message.created.year == 2021);
    assert(message.text == "Hello world!");

    final sender = message.sender;
    assert(sender.isOnline == false);
    assert(sender.username == "John_Doe");
    assert(sender.firstName == "John");
    assert(sender.lastName == "Doe");
  });
  test("Portal Chat - ChatUser Parsing", () async {
    const userJsonString = ''
        '{'
        ' "username": "John_Doe",'
        ' "first_name": "John",'
        ' "last_name": "Doe",'
        ' "avatar": "https://api-chat-engine-io-dev.s3.amazonaws.com/avatars/Screen_Shot_2020-12-15_at_7.42.34_AM.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAZA5RH3ECSKRVH2UM%2F20210504%2Fca-central-1%2Fs3%2Faws4_request&X-Amz-Date=20210504T155211Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=b9b9d3c4798f07705ea7988de72afbcf8e4f2827bbccf4d6fa236450c78cb9c2",'
        ' "is_online": false'
        '}';

    final user = ChatEngineUser.parse(userJsonString);
    assert(user.isOnline == false);
    assert(user.username == "John_Doe");
    assert(user.firstName == "John");
    assert(user.lastName == "Doe");
    assert(
      user.avatar ==
          "https://api-chat-engine-io-dev.s3.amazonaws.com/avatars/Screen_Shot_2020-12-15_at_7.42.34_AM.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAZA5RH3ECSKRVH2UM%2F20210504%2Fca-central-1%2Fs3%2Faws4_request&X-Amz-Date=20210504T155211Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=b9b9d3c4798f07705ea7988de72afbcf8e4f2827bbccf4d6fa236450c78cb9c2",
    );
  });

  test("Portal Chat - ChatMessage Parsing", () async {
    const messageJsonString = ''
        '{'
        ' "id": 353,'
        ' "sender": {'
        '   "username": "wendy_walker",'
        '   "first_name": null,'
        '   "last_name": null,'
        '   "avatar": null,'
        '   "is_online": false'
        ' },'
        ' "created": "2021-01-28 02:45:27.747970+00:00",'
        ' "attachments": [],'
        ' "text": "Hello world!"'
        '}';

    final parsedMessage = Message.parse(messageJsonString);
    final parsedSender = parsedMessage.sender;
    assert(parsedMessage.id == 353);
    assert(parsedMessage.attachments.isEmpty);
    assert(parsedSender.username == "wendy_walker");
    assert(parsedSender.avatar == null);
  });
}

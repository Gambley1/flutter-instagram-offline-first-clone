import 'package:chats_repository/chats_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatsRepository extends Mock implements ChatsRepository {}

void main() {
  group('ChatsRepository', () {
    late ChatsRepository chatsRepository;

    setUp(() {
      chatsRepository = MockChatsRepository();
    });
    test('can be instantiated', () {
      expect(chatsRepository, isNotNull);
    });
  });
}

// manifest: startProject
import 'package:serverpod/serverpod.dart';
import '../../generated/protocol.dart';

mixin AuthContextMixin on Endpoint {
  Future<({int userId, UuidValue customerId})> getAuthenticatedUserContext(
    Session session,
  ) async {
    final authInfo = await session.authenticated;
    final userId = authInfo?.authId;

    if (userId == null) {
      throw Exception('Пользователь не авторизован.');
    }

    final customerUser = await CustomerUser.db.findFirstRow(
      session,
      where: (cu) => cu.userId.equals(int.parse(userId)),
    );

    // Теперь это настоящая ошибка, а не повод для заглушки
    if (customerUser == null) {
      throw Exception('Пользователь $userId не привязан ни к одному клиенту (customer).');
    }

    return (
      userId: int.parse(userId),
      customerId: customerUser.customerId,
    );
  }
}
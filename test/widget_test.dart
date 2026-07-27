import 'package:flutter_test/flutter_test.dart';
import 'package:patronaje_app/main.dart';

void main() {
  testWidgets('muestra la pantalla principal de medidas', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Medidas'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
    expect(find.text('Guardar medidas'), findsOneWidget);
    expect(find.text('Cargar medidas'), findsOneWidget);
  });
}

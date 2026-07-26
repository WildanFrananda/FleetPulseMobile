part of '../../screens/order_screen.dart';

class _CancelledView extends StatelessWidget {
  const _CancelledView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Order cancelled'),
          const SizedBox(height: 12),
          FilledButton(onPressed: onBack, child: const Text('Back')),
        ],
      ),
    );
  }
}

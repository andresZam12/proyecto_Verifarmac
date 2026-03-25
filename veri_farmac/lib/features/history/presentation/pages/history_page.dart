// Pantalla de historial con lista paginada y filtros.
// TODO: implementar lista, filtros por estado y búsqueda

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../providers/history_provider.dart';
import '../widgets/history_entry_tile.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  @override
  void initState() {
    super.initState();
    // Carga el historial al entrar a la pantalla
    Future.microtask(() => ref.read(historyProvider.notifier).cargar());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _FiltroEstado(
            filtroActual: state.filtro,
            alCambiar: (filtro) =>
                ref.read(historyProvider.notifier).filtrar(filtro),
          ),
        ),
      ),
      body: Builder(
        builder: (context) {
          // Cargando
          if (state.cargando) {
            return const AppLoading(mensaje: 'Cargando historial...');
          }

          // Error
          if (state.error != null) {
            return AppErrorWidget(
              mensaje: state.error!,
              alReintentar: () =>
                  ref.read(historyProvider.notifier).cargar(),
            );
          }

          // Sin entradas
          if (state.entradasFiltradas.isEmpty) {
            return const AppEmptyState(
              titulo: 'Sin registros',
              descripcion: 'Los medicamentos escaneados aparecerán aquí',
            );
          }

          // Lista del historial
          return ListView.separated(
            itemCount: state.entradasFiltradas.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entrada = state.entradasFiltradas[index];
              return HistoryEntryTile(
                entrada: entrada,
                alEliminar: () => _confirmarEliminar(context, entrada.id),
              );
            },
          );
        },
      ),
    );
  }

  // Muestra un diálogo de confirmación antes de eliminar
  void _confirmarEliminar(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar registro'),
        content: const Text('¿Seguro que quieres eliminar este registro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(historyProvider.notifier).eliminar(id);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// Chips de filtro por estado
class _FiltroEstado extends StatelessWidget {
  const _FiltroEstado({
    required this.filtroActual,
    required this.alCambiar,
  });

  final String?                  filtroActual;
  final ValueChanged<String?>    alCambiar;

  @override
  Widget build(BuildContext context) {
    final filtros = [
      (label: 'Todos',       valor: null),
      (label: 'Vigentes',    valor: 'vigente'),
      (label: 'Vencidos',    valor: 'vencido'),
      (label: 'Inválidos',   valor: 'invalido'),
      (label: 'Sospechosos', valor: 'sospechoso'),
    ];

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: filtros.map((f) {
          final seleccionado = filtroActual == f.valor;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(f.label),
              selected: seleccionado,
              onSelected: (_) => alCambiar(f.valor),
            ),
          );
        }).toList(),
      ),
    );
  }
}
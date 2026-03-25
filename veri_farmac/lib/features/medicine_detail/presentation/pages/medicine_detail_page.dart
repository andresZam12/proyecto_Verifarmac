// Pantalla de resultado del medicamento.
// TODO: mostrar StatusBadge, nombre, registro, laboratorio y detalles

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/confidence_bar.dart';
import '../../domain/entities/medicine.dart';
import '../providers/medicine_provider.dart';
import '../widgets/status_badge.dart';

class MedicineDetailPage extends ConsumerStatefulWidget {
  const MedicineDetailPage({super.key, required this.medicineId});
  final String medicineId;

  @override
  ConsumerState<MedicineDetailPage> createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState extends ConsumerState<MedicineDetailPage> {
  @override
  void initState() {
    super.initState();
    // Carga el medicamento al entrar a la pantalla
    Future.microtask(() =>
        ref.read(medicineProvider.notifier).cargarPorBarcode(widget.medicineId));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicineProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: switch (state.estado) {
        EstadoMedicina.cargando => const AppLoading(mensaje: 'Consultando INVIMA...'),
        EstadoMedicina.error    => AppErrorWidget(
            mensaje: state.error ?? 'Error al cargar el medicamento',
            alReintentar: () => ref
                .read(medicineProvider.notifier)
                .cargarPorBarcode(widget.medicineId),
          ),
        EstadoMedicina.noEncontrado => const AppEmptyState(
            titulo: 'Medicamento no encontrado',
            descripcion: 'No se encontró información en la base de datos del INVIMA.',
          ),
        EstadoMedicina.cargado => _Detalle(
            medicamento: state.medicamento!,
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

// Contenido principal cuando el medicamento se cargó correctamente
class _Detalle extends StatelessWidget {
  const _Detalle({required this.medicamento});
  final Medicamento medicamento;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estado del medicamento — lo más importante
          Center(
            child: StatusBadge(estado: medicamento.estado, grande: true),
          ),

          const SizedBox(height: 20),

          // Nombre
          Text(
            medicamento.nombre,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),

          const SizedBox(height: 20),

          // Barra de confianza del análisis
          const ConfidenceBar(confianza: 0.95),

          const SizedBox(height: 24),

          // Información del registro
          _SeccionInfo(titulo: 'Registro sanitario', children: [
            _FilaInfo(etiqueta: 'Código',      valor: medicamento.registroSanitario),
            _FilaInfo(etiqueta: 'Estado',      valor: medicamento.estado.etiqueta),
            _FilaInfo(etiqueta: 'Laboratorio', valor: medicamento.laboratorio),
            if (medicamento.titular != null)
              _FilaInfo(etiqueta: 'Titular', valor: medicamento.titular!),
          ]),

          const SizedBox(height: 16),

          // Información del medicamento
          _SeccionInfo(titulo: 'Información del medicamento', children: [
            if (medicamento.ingredienteActivo != null)
              _FilaInfo(etiqueta: 'Principio activo', valor: medicamento.ingredienteActivo!),
            if (medicamento.concentracion != null)
              _FilaInfo(etiqueta: 'Concentración', valor: medicamento.concentracion!),
            if (medicamento.formaFarmaceutica != null)
              _FilaInfo(etiqueta: 'Forma farmacéutica', valor: medicamento.formaFarmaceutica!),
          ]),

          const SizedBox(height: 24),

          // Alerta si el medicamento no es seguro
          if (!medicamento.estado.esSeguro)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_rounded, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Este medicamento no debería comercializarse. '
                      'Reporta este caso al INVIMA.',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Sección con título y filas de información
class _SeccionInfo extends StatelessWidget {
  const _SeccionInfo({required this.titulo, required this.children});
  final String       titulo;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}

// Fila de etiqueta y valor
class _FilaInfo extends StatelessWidget {
  const _FilaInfo({required this.etiqueta, required this.valor});
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              etiqueta,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
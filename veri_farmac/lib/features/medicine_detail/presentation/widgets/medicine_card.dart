// Card con resumen del medicamento para listas.
// TODO: mostrar nombre, registro, laboratorio y StatusBadge

import 'package:flutter/material.dart';

import '../../domain/entities/medicine.dart';
import 'status_badge.dart';

// Tarjeta que muestra un resumen del medicamento.
// Se usa en el historial y en resultados de búsqueda.
class MedicineCard extends StatelessWidget {
  const MedicineCard({
    super.key,
    required this.medicamento,
    this.alPresionar,
  });

  final Medicamento   medicamento;
  final VoidCallback? alPresionar;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: alPresionar,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior: nombre y badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del medicamento
                  Expanded(
                    child: Text(
                      medicamento.nombre,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Badge de estado
                  StatusBadge(estado: medicamento.estado),
                ],
              ),

              const SizedBox(height: 8),

              // Registro sanitario
              _InfoRow(
                icono: Icons.verified_outlined,
                texto: medicamento.registroSanitario,
              ),

              const SizedBox(height: 4),

              // Laboratorio
              _InfoRow(
                icono: Icons.business_outlined,
                texto: medicamento.laboratorio,
              ),

              // Ingrediente activo (si existe)
              if (medicamento.ingredienteActivo != null) ...[
                const SizedBox(height: 4),
                _InfoRow(
                  icono: Icons.science_outlined,
                  texto: '${medicamento.ingredienteActivo}'
                      '${medicamento.concentracion != null ? ' ${medicamento.concentracion}' : ''}',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Fila de información con ícono y texto
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icono, required this.texto});

  final IconData icono;
  final String   texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icono,
          size: 14,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            texto,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6),
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
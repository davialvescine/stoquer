/*
 * TELA DE GESTÃO DE MANUTENÇÕES
 * 
 * Gerencia agendamento, execução e histórico de manutenções.
 * Permite controle preventivo e corretivo de ativos.
 */

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  final _technicianController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _selectedAsset;
  String _maintenanceType = 'preventiva';
  String _priority = 'media';
  DateTime _scheduledDate = DateTime.now();

  @override
  void dispose() {
    _descriptionController.dispose();
    _costController.dispose();
    _technicianController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveMaintenance() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedAsset == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione um ativo')),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance.collection('maintenances').add({
          'assetId': _selectedAsset,
          'type': _maintenanceType,
          'priority': _priority,
          'description': _descriptionController.text,
          'cost': double.tryParse(_costController.text) ?? 0,
          'technician': _technicianController.text,
          'notes': _notesController.text,
          'scheduledDate': _scheduledDate.toIso8601String(),
          'status': 'scheduled',
          'createdAt': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Manutenção agendada com sucesso!')),
          );
          _clearForm();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao agendar manutenção: $e')),
          );
        }
      }
    }
  }

  void _clearForm() {
    _descriptionController.clear();
    _costController.clear();
    _technicianController.clear();
    _notesController.clear();
    setState(() {
      _selectedAsset = null;
      _maintenanceType = 'preventiva';
      _priority = 'media';
      _scheduledDate = DateTime.now();
    });
  }

  Future<void> _completeMaintenance(String maintenanceId, String assetId) async {
    try {
      await FirebaseFirestore.instance
          .collection('maintenances')
          .doc(maintenanceId)
          .update({
        'status': 'completed',
        'completedDate': DateTime.now().toIso8601String(),
      });

      await FirebaseFirestore.instance
          .collection('assets')
          .doc(assetId)
          .update({'status': 'disponivel'});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Manutenção concluída!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao concluir manutenção: $e')),
        );
      }
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baixa':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getMaintenanceIcon(String type) {
    return type == 'preventiva' ? Icons.schedule : Icons.build;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manutenções'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Agendar', icon: Icon(Icons.add_task)),
              Tab(text: 'Em Andamento', icon: Icon(Icons.pending_actions)),
              Tab(text: 'Histórico', icon: Icon(Icons.history)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildScheduleTab(),
            _buildOngoingTab(),
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleTab() {
    return Row(
      children: [
        Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          color: Colors.grey[100],
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Agendar Manutenção',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  
                  // Asset Selection
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('assets')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final assets = snapshot.data!.docs;
                      return DropdownButtonFormField<String>(
                        value: _selectedAsset,
                        decoration: const InputDecoration(
                          labelText: 'Ativo',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.devices),
                        ),
                        items: assets.map((asset) {
                          final data = asset.data() as Map<String, dynamic>;
                          return DropdownMenuItem(
                            value: asset.id,
                            child: Text('${data['titulo'] ?? 'Sem nome'} - ${asset.id}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAsset = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) return 'Selecione um ativo';
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Type and Priority
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _maintenanceType,
                          decoration: const InputDecoration(
                            labelText: 'Tipo',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'preventiva',
                              child: Text('Preventiva'),
                            ),
                            DropdownMenuItem(
                              value: 'corretiva',
                              child: Text('Corretiva'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _maintenanceType = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _priority,
                          decoration: const InputDecoration(
                            labelText: 'Prioridade',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'baixa',
                              child: Text('Baixa'),
                            ),
                            DropdownMenuItem(
                              value: 'media',
                              child: Text('Média'),
                            ),
                            DropdownMenuItem(
                              value: 'alta',
                              child: Text('Alta'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _priority = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite uma descrição';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Cost and Technician
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _costController,
                          decoration: const InputDecoration(
                            labelText: 'Custo Estimado',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _technicianController,
                          decoration: const InputDecoration(
                            labelText: 'Técnico',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Notes
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Observações',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  
                  // Date Picker
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _scheduledDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        if (!mounted) return;
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_scheduledDate),
                        );
                        if (time != null) {
                          setState(() {
                            _scheduledDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data e Hora Agendada',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(_scheduledDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Submit Button
                  ElevatedButton(
                    onPressed: _saveMaintenance,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      'Agendar Manutenção',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Calendar View
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Próximas Manutenções',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('maintenances')
                        .where('status', isEqualTo: 'scheduled')
                        .orderBy('scheduledDate')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final maintenances = snapshot.data!.docs;

                      if (maintenances.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_available, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Nenhuma manutenção agendada',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: maintenances.length,
                        itemBuilder: (context, index) {
                          final maintenance = maintenances[index];
                          final data = maintenance.data() as Map<String, dynamic>;
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: Icon(
                                _getMaintenanceIcon(data['type']),
                                color: _getPriorityColor(data['priority']),
                              ),
                              title: Text(data['description'] ?? ''),
                              subtitle: Text(
                                'Agendada para: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(data['scheduledDate']))}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: () => _completeMaintenance(maintenance.id, data['assetId']),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOngoingTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('maintenances')
          .where('status', isEqualTo: 'scheduled')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final maintenances = snapshot.data!.docs;
        if (maintenances.isEmpty) {
          return const Center(
            child: Text(
              'Nenhuma manutenção em andamento',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: maintenances.length,
          itemBuilder: (context, index) {
            final maintenance = maintenances[index];
            final data = maintenance.data() as Map<String, dynamic>;
            
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getPriorityColor(data['priority']).withValues(alpha: 0.2),
                  child: Icon(
                    _getMaintenanceIcon(data['type']),
                    color: _getPriorityColor(data['priority']),
                  ),
                ),
                title: Text(data['description'] ?? ''),
                subtitle: Text(data['type'] == 'preventiva' ? 'Preventiva' : 'Corretiva'),
                trailing: ElevatedButton(
                  onPressed: () => _completeMaintenance(maintenance.id, data['assetId']),
                  child: const Text('Concluir'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('maintenances')
          .where('status', isEqualTo: 'completed')
          .orderBy('completedDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final maintenances = snapshot.data!.docs;
        if (maintenances.isEmpty) {
          return const Center(
            child: Text('Nenhum histórico de manutenção'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: maintenances.length,
          itemBuilder: (context, index) {
            final maintenance = maintenances[index];
            final data = maintenance.data() as Map<String, dynamic>;
            
            return Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.check, color: Colors.white),
                ),
                title: Text(data['description'] ?? ''),
                subtitle: Text(
                  'Concluída: ${data['completedDate'] != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(data['completedDate'])) : 'Data não disponível'}',
                ),
                trailing: Chip(
                  label: Text(data['type'] == 'preventiva' ? 'Preventiva' : 'Corretiva'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
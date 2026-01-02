import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/google_sheets_service.dart';

class FatigueTrackerScreen extends StatefulWidget {
  const FatigueTrackerScreen({super.key});

  @override
  State<FatigueTrackerScreen> createState() => _FatigueTrackerScreenState();
}

class _FatigueTrackerScreenState extends State<FatigueTrackerScreen> {
  double _fatigueLevel = 0.0;
  double _capacityLevel = 0.0;
  int? _suspensionReason; // 1, 2, 3, o 4
  bool _isLoading = false;
  final TextEditingController _userIdController = TextEditingController();
  
  final GoogleSheetsService _sheetsService = GoogleSheetsService();

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  String _getFatigueLabel() {
    if (_fatigueLevel <= 10) {
      return 'Nada cansado';
    } else if (_fatigueLevel <= 40) {
      return 'Algo cansado';
    } else if (_fatigueLevel <= 70) {
      return 'Muy cansado';
    } else {
      return 'Muy muy cansado';
    }
  }

  String _getCapacityLabel() {
    if (_capacityLevel <= 10) {
      return 'Muy fácil';
    } else if (_capacityLevel <= 40) {
      return 'Con algo de esfuerzo';
    } else if (_capacityLevel <= 70) {
      return 'Con mucho esfuerzo';
    } else {
      return 'No hubiera podido';
    }
  }

  Color _getFatigueColor() {
    if (_fatigueLevel <= 10) {
      return const Color(0xFF10B981); // Green
    } else if (_fatigueLevel <= 40) {
      return const Color(0xFF3B82F6); // Blue
    } else if (_fatigueLevel <= 70) {
      return const Color(0xFFF59E0B); // Orange
    } else {
      return const Color(0xFFEF4444); // Red
    }
  }

  Color _getCapacityColor() {
    if (_capacityLevel <= 10) {
      return const Color(0xFF10B981); // Green
    } else if (_capacityLevel <= 40) {
      return const Color(0xFF3B82F6); // Blue
    } else if (_capacityLevel <= 70) {
      return const Color(0xFFF59E0B); // Orange
    } else {
      return const Color(0xFFEF4444); // Red
    }
  }

  // Redondear a 1 dígito (0-10)
  int _getRoundedValue(double value) {
    return (value / 10).round();
  }

  Future<void> _saveRecord() async {
    // Validar que el identificador tenga entre 1 y 4 letras
    final userId = _userIdController.text.trim().toUpperCase();
    
    if (userId.isEmpty || userId.length > 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Por favor, ingresa un identificador de 1 a 4 letras',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Validar que solo contenga letras
    if (!RegExp(r'^[A-Za-z]+$').hasMatch(userId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'El identificador solo puede contener letras',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Validar que haya seleccionado un motivo de suspensión
    if (_suspensionReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Por favor, selecciona el motivo de suspensión',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Enviar los tres valores (0-100, 0-100, 1-4) y el identificador
      final success = await _sheetsService.sendFatigueData(
        fatigueLevel: _fatigueLevel.toInt(),
        capacityLevel: _capacityLevel.toInt(),
        suspensionReason: _suspensionReason!,
        userId: userId,
      );
      
      if (!mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '¡Registro guardado! Usuario: $userId',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Reset todo después de guardar
        setState(() {
          _fatigueLevel = 0.0;
          _capacityLevel = 0.0;
          _suspensionReason = null;
          _userIdController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error al guardar. Verifica la configuración.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error de conexión: $e',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ========== HEADER CON IDENTIFICADOR ==========
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF6366F1),
                      const Color(0xFF8B5CF6),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    
                    // App Logo Icon - Persona corriendo en pendiente
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.directions_run,
                        size: 45,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // User ID Input Field
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _userIdController,
                        decoration: const InputDecoration(
                          labelText: 'Identificador de Usuario',
                          hintText: 'Ingresa 1-4 letras (ej: ABC)',
                          prefixIcon: Icon(Icons.person, color: Color(0xFF6366F1)),
                          border: InputBorder.none,
                          counterText: '',
                        ),
                        maxLength: 4,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                          UpperCaseTextFormatter(),
                        ],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              
              // ========== PREGUNTA 1: FATIGA (Fondo azul claro) ==========
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF), // Azul muy claro
                ),
                child: Column(
                  children: [
                    const Text(
                      '¿Qué tan cansado te sentiste al terminar el ejercicio?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Fatigue Level Display
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                      decoration: BoxDecoration(
                        color: _getFatigueColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getFatigueColor().withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${_getRoundedValue(_fatigueLevel)}',
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: _getFatigueColor(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getFatigueLabel(),
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: _getFatigueColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Slider 1
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: _getFatigueColor(),
                        inactiveTrackColor: _getFatigueColor().withValues(alpha: 0.2),
                        thumbColor: _getFatigueColor(),
                        overlayColor: _getFatigueColor().withValues(alpha: 0.2),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 16.0,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 28.0,
                        ),
                        trackHeight: 8.0,
                      ),
                      child: Slider(
                        value: _fatigueLevel,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        onChanged: (value) {
                          setState(() {
                            _fatigueLevel = value;
                          });
                        },
                      ),
                    ),
                    
                    // Slider 1 Labels
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '0',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '10',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // ========== PREGUNTA 2: CAPACIDAD (Fondo verde claro) ==========
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4), // Verde muy claro
                ),
                child: Column(
                  children: [
                    const Text(
                      '¿Podrías haber continuado 1-2 minutos más?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Capacity Level Display
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                      decoration: BoxDecoration(
                        color: _getCapacityColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getCapacityColor().withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${_getRoundedValue(_capacityLevel)}',
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: _getCapacityColor(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getCapacityLabel(),
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: _getCapacityColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Slider 2
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: _getCapacityColor(),
                        inactiveTrackColor: _getCapacityColor().withValues(alpha: 0.2),
                        thumbColor: _getCapacityColor(),
                        overlayColor: _getCapacityColor().withValues(alpha: 0.2),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 16.0,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 28.0,
                        ),
                        trackHeight: 8.0,
                      ),
                      child: Slider(
                        value: _capacityLevel,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        onChanged: (value) {
                          setState(() {
                            _capacityLevel = value;
                          });
                        },
                      ),
                    ),
                    
                    // Slider 2 Labels
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '0',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '10',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // ========== PREGUNTA 3: MOTIVO DE SUSPENSIÓN (Fondo naranja claro) ==========
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED), // Naranja muy claro
                ),
                child: Column(
                  children: [
                    const Text(
                      '¿Cuál fue el motivo para suspender la prueba?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 25),
                    
                    // Opción 1: Falta de aire
                    _buildOptionCard(
                      value: 1,
                      title: 'Falta de aire',
                      icon: Icons.air,
                      color: const Color(0xFF3B82F6),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Opción 2: Fatiga en las piernas
                    _buildOptionCard(
                      value: 2,
                      title: 'Fatiga en las piernas',
                      icon: Icons.accessibility_new,
                      color: const Color(0xFFF59E0B),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Opción 3: Ambas
                    _buildOptionCard(
                      value: 3,
                      title: 'Ambas',
                      icon: Icons.warning,
                      color: const Color(0xFFEF4444),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Opción 4: Otra razón
                    _buildOptionCard(
                      value: 4,
                      title: 'Otra razón',
                      icon: Icons.help_outline,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ],
                ),
              ),
              
              // ========== BOTÓN GUARDAR (Fondo blanco) ==========
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    // Save Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveRecord,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: _isLoading ? 0 : 4,
                        backgroundColor: const Color(0xFF6366F1),
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: SpinKitCircle(
                                color: Colors.white,
                                size: 24,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save, size: 24, color: Colors.white),
                                SizedBox(width: 12),
                                Text(
                                  'Guardar Registro',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                    
                    const SizedBox(height: 15),
                    
                    // Info Text
                    Text(
                      'Se guardarán las 3 respuestas en Google Sheets',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required int value,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _suspensionReason == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _suspensionReason = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? color : Colors.grey[800],
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}

// Formatter para convertir texto a mayúsculas automáticamente
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

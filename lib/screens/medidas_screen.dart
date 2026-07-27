import 'package:flutter/material.dart';
import 'elegir_prenda_screen.dart';
import '../models/medidas.dart';
import 'guardar_medidas_screen.dart';
import 'historial_screen.dart';
import 'seleccionar_perfil_screen.dart';

class MedidasScreen extends StatefulWidget {
  final Medidas? medidasCargadas; // Medidas cargadas desde un perfil

  const MedidasScreen({super.key, this.medidasCargadas});

  @override
  State<MedidasScreen> createState() => _MedidasScreenState();
}

class _MedidasScreenState extends State<MedidasScreen> {
  // Controladores para los campos de texto
  final TextEditingController _contornoCuelloController =
      TextEditingController();
  final TextEditingController _contornoBustoController =
      TextEditingController();
  final TextEditingController _contornoCinturaController =
      TextEditingController();
  final TextEditingController _contornoCaderaController =
      TextEditingController();
  final TextEditingController _contornoSisaController = TextEditingController();
  final TextEditingController _contornoPunoController = TextEditingController();
  final TextEditingController _contornoMangaController =
      TextEditingController();
  final TextEditingController _contornoRodillaController =
      TextEditingController();
  final TextEditingController _contornoTobilloController =
      TextEditingController();
  final TextEditingController _largoTalleController = TextEditingController();
  final TextEditingController _largoPinzaController = TextEditingController();
  final TextEditingController _largoBustoController = TextEditingController();
  final TextEditingController _largoBlusaController = TextEditingController();
  final TextEditingController _largoCodoController = TextEditingController();
  final TextEditingController _largoMangaCortaController =
      TextEditingController();
  final TextEditingController _largoManga34Controller = TextEditingController();
  final TextEditingController _largoEscoteDelanteroController =
      TextEditingController();
  final TextEditingController _largoEscoteEspaldaController =
      TextEditingController();
  final TextEditingController _largoCaderaController = TextEditingController();
  final TextEditingController _largoFaldaController = TextEditingController();
  final TextEditingController _largoPantalonController =
      TextEditingController();
  final TextEditingController _largoTiroController = TextEditingController();
  final TextEditingController _caidaBustoController = TextEditingController();
  final TextEditingController _separacionBustoController =
      TextEditingController();
  final TextEditingController _anchoPechoController = TextEditingController();
  final TextEditingController _anchoHombrosController = TextEditingController();
  final TextEditingController _anchoEspaldaController = TextEditingController();

  late final List<TextEditingController> _controllers;
  late final Map<TextEditingController, FocusNode> _focusNodes;

  // Clave global para el formulario
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controllers = [
      _contornoCuelloController,
      _contornoBustoController,
      _contornoCinturaController,
      _contornoCaderaController,
      _contornoSisaController,
      _contornoPunoController,
      _contornoMangaController,
      _contornoRodillaController,
      _contornoTobilloController,
      _largoTalleController,
      _largoPinzaController,
      _largoBustoController,
      _largoBlusaController,
      _largoCodoController,
      _largoMangaCortaController,
      _largoManga34Controller,
      _largoEscoteDelanteroController,
      _largoEscoteEspaldaController,
      _largoCaderaController,
      _largoFaldaController,
      _largoPantalonController,
      _largoTiroController,
      _caidaBustoController,
      _separacionBustoController,
      _anchoPechoController,
      _anchoHombrosController,
      _anchoEspaldaController,
    ];
    _focusNodes = {
      for (var index = 0; index < _controllers.length; index++)
        _controllers[index]: FocusNode(debugLabel: 'medida_$index'),
    };

    // Si hay medidas cargadas, rellenar los campos
    if (widget.medidasCargadas != null) {
      _rellenarCampos(widget.medidasCargadas!);
    }
  }

  // Rellenar los campos de texto con las medidas cargadas
  void _rellenarCampos(Medidas medidas) {
    _contornoCuelloController.text = medidas.contornoCuello.toString();
    _contornoBustoController.text = medidas.contornoBusto.toString();
    _contornoCinturaController.text = medidas.contornoCintura.toString();
    _contornoCaderaController.text = medidas.contornoCadera.toString();
    _contornoSisaController.text = medidas.contornoSisa.toString();
    _contornoPunoController.text = medidas.contornoPuno.toString();
    _contornoMangaController.text = medidas.contornoManga.toString();
    _contornoRodillaController.text = medidas.contornoRodilla.toString();
    _contornoTobilloController.text = medidas.contornoTobillo.toString();
    _largoTalleController.text = medidas.largoTalle.toString();
    _largoPinzaController.text = medidas.largoPinza.toString();
    _largoBustoController.text = medidas.largoBusto.toString();
    _largoBlusaController.text = medidas.largoBlusa.toString();
    _largoCodoController.text = medidas.largoCodo.toString();
    _largoMangaCortaController.text = medidas.largoMangaCorta.toString();
    _largoManga34Controller.text = medidas.largoManga34.toString();
    _largoEscoteDelanteroController.text = medidas.largoEscoteDelantero
        .toString();
    _largoEscoteEspaldaController.text = medidas.largoEscoteEspalda.toString();
    _largoCaderaController.text = medidas.largoCadera.toString();
    _largoFaldaController.text = medidas.largoFalda.toString();
    _largoPantalonController.text = medidas.largoPantalon.toString();
    _largoTiroController.text = medidas.largoTiro.toString();
    _caidaBustoController.text = medidas.caidaBusto.toString();
    _separacionBustoController.text = medidas.separacionBusto.toString();
    _anchoPechoController.text = medidas.anchoPecho.toString();
    _anchoHombrosController.text = medidas.anchoHombros.toString();
    _anchoEspaldaController.text = medidas.anchoEspalda.toString();
  }

  @override
  void dispose() {
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }

    // Liberar controladores
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _continuarSiguientePantalla() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Revisa el formulario: completa todas las medidas con valores '
            'numéricos mayores que cero.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final medidas = Medidas(
      contornoCuello: double.parse(_contornoCuelloController.text),
      contornoBusto: double.parse(_contornoBustoController.text),
      contornoCintura: double.parse(_contornoCinturaController.text),
      contornoCadera: double.parse(_contornoCaderaController.text),
      contornoSisa: double.parse(_contornoSisaController.text),
      contornoPuno: double.parse(_contornoPunoController.text),
      contornoManga: double.parse(_contornoMangaController.text),
      contornoRodilla: double.parse(_contornoRodillaController.text),
      contornoTobillo: double.parse(_contornoTobilloController.text),
      largoTalle: double.parse(_largoTalleController.text),
      largoPinza: double.parse(_largoPinzaController.text),
      largoBusto: double.parse(_largoBustoController.text),
      largoBlusa: double.parse(_largoBlusaController.text),
      largoCodo: double.parse(_largoCodoController.text),
      largoMangaCorta: double.parse(_largoMangaCortaController.text),
      largoManga34: double.parse(_largoManga34Controller.text),
      largoEscoteDelantero: double.parse(_largoEscoteDelanteroController.text),
      largoEscoteEspalda: double.parse(_largoEscoteEspaldaController.text),
      largoCadera: double.parse(_largoCaderaController.text),
      largoFalda: double.parse(_largoFaldaController.text),
      largoPantalon: double.parse(_largoPantalonController.text),
      largoTiro: double.parse(_largoTiroController.text),
      caidaBusto: double.parse(_caidaBustoController.text),
      separacionBusto: double.parse(_separacionBustoController.text),
      anchoPecho: double.parse(_anchoPechoController.text),
      anchoHombros: double.parse(_anchoHombrosController.text),
      anchoEspalda: double.parse(_anchoEspaldaController.text),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ElegirPrendaScreen(medidas: medidas),
      ),
    );
  }

  // Navegar a la pantalla para guardar medidas
  void _guardarMedidas() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Revisa el formulario: completa todas las medidas con valores '
            'numéricos mayores que cero.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final medidas = Medidas(
      contornoCuello: double.parse(_contornoCuelloController.text),
      contornoBusto: double.parse(_contornoBustoController.text),
      contornoCintura: double.parse(_contornoCinturaController.text),
      contornoCadera: double.parse(_contornoCaderaController.text),
      contornoSisa: double.parse(_contornoSisaController.text),
      contornoPuno: double.parse(_contornoPunoController.text),
      contornoManga: double.parse(_contornoMangaController.text),
      contornoRodilla: double.parse(_contornoRodillaController.text),
      contornoTobillo: double.parse(_contornoTobilloController.text),
      largoTalle: double.parse(_largoTalleController.text),
      largoPinza: double.parse(_largoPinzaController.text),
      largoBusto: double.parse(_largoBustoController.text),
      largoBlusa: double.parse(_largoBlusaController.text),
      largoCodo: double.parse(_largoCodoController.text),
      largoMangaCorta: double.parse(_largoMangaCortaController.text),
      largoManga34: double.parse(_largoManga34Controller.text),
      largoEscoteDelantero: double.parse(_largoEscoteDelanteroController.text),
      largoEscoteEspalda: double.parse(_largoEscoteEspaldaController.text),
      largoCadera: double.parse(_largoCaderaController.text),
      largoFalda: double.parse(_largoFaldaController.text),
      largoPantalon: double.parse(_largoPantalonController.text),
      largoTiro: double.parse(_largoTiroController.text),
      caidaBusto: double.parse(_caidaBustoController.text),
      separacionBusto: double.parse(_separacionBustoController.text),
      anchoPecho: double.parse(_anchoPechoController.text),
      anchoHombros: double.parse(_anchoHombrosController.text),
      anchoEspalda: double.parse(_anchoEspaldaController.text),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuardarMedidasScreen(medidas: medidas),
      ),
    );
  }

  // Navegar a la pantalla para seleccionar y cargar un perfil
  Future<void> _cargarMedidas() async {
    final medidasCargadas = await Navigator.of(context).push<Medidas>(
      MaterialPageRoute(builder: (context) => const SeleccionarPerfilScreen()),
    );

    if (!mounted || medidasCargadas == null) {
      return;
    }

    _rellenarCampos(medidasCargadas);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medidas cargadas correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Navegar a la pantalla con el historial de patrones generados
  void _verHistorial() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistorialScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Medidas')),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sección de Contornos
              const Text(
                'Contornos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildTextField('Contorno de cuello', _contornoCuelloController),
              _buildTextField('Contorno de busto', _contornoBustoController),
              _buildTextField(
                'Contorno de cintura',
                _contornoCinturaController,
              ),
              _buildTextField('Contorno de cadera', _contornoCaderaController),
              _buildTextField('Contorno de sisa', _contornoSisaController),
              _buildTextField('Contorno de puño', _contornoPunoController),
              _buildTextField('Contorno de manga', _contornoMangaController),
              _buildTextField(
                'Contorno de rodilla',
                _contornoRodillaController,
              ),
              _buildTextField(
                'Contorno de tobillo',
                _contornoTobilloController,
              ),

              const SizedBox(height: 24),

              // Sección de Largos
              const Text(
                'Largos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildTextField('Largo de talle', _largoTalleController),
              _buildTextField('Largo de pinza', _largoPinzaController),
              _buildTextField('Largo de busto', _largoBustoController),
              _buildTextField('Largo de blusa', _largoBlusaController),
              _buildTextField('Largo de codo', _largoCodoController),
              _buildTextField(
                'Largo de manga corta',
                _largoMangaCortaController,
              ),
              _buildTextField('Largo de manga 3/4', _largoManga34Controller),
              _buildTextField(
                'Largo de escote delantero',
                _largoEscoteDelanteroController,
              ),
              _buildTextField(
                'Largo de escote espalda',
                _largoEscoteEspaldaController,
              ),
              _buildTextField('Largo de cadera', _largoCaderaController),
              _buildTextField('Largo de falda', _largoFaldaController),
              _buildTextField('Largo de pantalón', _largoPantalonController),
              _buildTextField('Largo de tiro', _largoTiroController),

              const SizedBox(height: 24),

              // Sección de Otros
              const Text(
                'Otros',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildTextField('Caída de busto', _caidaBustoController),
              _buildTextField(
                'Separación de busto',
                _separacionBustoController,
              ),
              _buildTextField('Ancho de pecho', _anchoPechoController),
              _buildTextField('Ancho de hombros', _anchoHombrosController),
              _buildTextField('Ancho de espalda', _anchoEspaldaController),

              const SizedBox(height: 32),

              // Botón para continuar
              ElevatedButton(
                onPressed: _continuarSiguientePantalla,
                child: const Text('Continuar'),
              ),

              const SizedBox(height: 12),

              // Botón para guardar medidas
              ElevatedButton.icon(
                onPressed: _guardarMedidas,
                icon: const Icon(Icons.save),
                label: const Text('Guardar medidas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 12),

              // Botón para cargar medidas
              ElevatedButton.icon(
                onPressed: _cargarMedidas,
                icon: const Icon(Icons.folder_open),
                label: const Text('Cargar medidas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 12),

              // Botón para ver el historial de patrones generados
              ElevatedButton.icon(
                onPressed: _verHistorial,
                icon: const Icon(Icons.history),
                label: const Text('Historial de patrones'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    final fieldIndex = _controllers.indexOf(controller);
    final isLastField = fieldIndex == _controllers.length - 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        focusNode: _focusNodes[controller],
        enabled: true,
        readOnly: false,
        canRequestFocus: true,
        autofocus: false,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: isLastField
            ? TextInputAction.done
            : TextInputAction.next,
        enableInteractiveSelection: true,
        onFieldSubmitted: (_) {
          if (isLastField) {
            _focusNodes[controller]?.unfocus();
            return;
          }

          _focusNodes[_controllers[fieldIndex + 1]]?.requestFocus();
        },
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixText: 'cm',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          // Validar que sea un número válido
          final number = double.tryParse(value);
          if (number == null) {
            return 'Ingrese solo números';
          }
          if (number <= 0) {
            return 'El valor debe ser mayor a 0';
          }
          return null;
        },
      ),
    );
  }
}

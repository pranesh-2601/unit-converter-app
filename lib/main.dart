import 'package:flutter/material.dart';

void main() => runApp(const ConverterApp());

class ConverterApp extends StatelessWidget {
  const ConverterApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Unit Converter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563A8)),
          scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        ),
        home: const ConverterHomePage(),
      );
}

enum ConverterKind { length, weight, temperature }

class UnitOption {
  const UnitOption(this.name, this.symbol, {this.factor = 1});
  final String name;
  final String symbol;
  final double factor;
}

const lengthUnits = [
  UnitOption('Meters', 'm'),
  UnitOption('Kilometers', 'km', factor: 1000),
  UnitOption('Centimeters', 'cm', factor: 0.01),
  UnitOption('Feet', 'ft', factor: 0.3048),
];
const weightUnits = [
  UnitOption('Grams', 'g'),
  UnitOption('Kilograms', 'kg', factor: 1000),
  UnitOption('Pounds', 'lb', factor: 453.59237),
  UnitOption('Ounces', 'oz', factor: 28.349523125),
];
const temperatureUnits = [
  UnitOption('Celsius', '°C'),
  UnitOption('Fahrenheit', '°F'),
  UnitOption('Kelvin', 'K'),
];

class ConverterHomePage extends StatelessWidget {
  const ConverterHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      (ConverterKind.length, 'Length', 'Convert meters, kilometers, feet', Icons.straighten),
      (ConverterKind.weight, 'Weight', 'Convert grams, kilograms, pounds', Icons.scale_outlined),
      (ConverterKind.temperature, 'Temperature', 'Convert Celsius, Fahrenheit, Kelvin', Icons.thermostat),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Unit Converter'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('What would you like to convert?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 18),
                for (final item in categories)
                  Card(
                    color: Colors.white,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(14),
                      leading: CircleAvatar(child: Icon(item.$4)),
                      title: Text(item.$2, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(item.$3),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ConverterPage(kind: item.$1),
                      )),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key, required this.kind});
  final ConverterKind kind;

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final _inputController = TextEditingController(text: '1');
  late UnitOption _from;
  late UnitOption _to;

  List<UnitOption> get _units => switch (widget.kind) {
        ConverterKind.length => lengthUnits,
        ConverterKind.weight => weightUnits,
        ConverterKind.temperature => temperatureUnits,
      };

  String get _title => switch (widget.kind) {
        ConverterKind.length => 'Length',
        ConverterKind.weight => 'Weight',
        ConverterKind.temperature => 'Temperature',
      };

  @override
  void initState() {
    super.initState();
    _from = _units.first;
    _to = _units[1];
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  double? _convert(double value) {
    if (widget.kind == ConverterKind.temperature) {
      final celsius = switch (_from.symbol) {
        '°C' => value,
        '°F' => (value - 32) * 5 / 9,
        'K' => value - 273.15,
        _ => value,
      };
      return switch (_to.symbol) {
        '°C' => celsius,
        '°F' => celsius * 9 / 5 + 32,
        'K' => celsius + 273.15,
        _ => celsius,
      };
    }
    return value * _from.factor / _to.factor;
  }

  @override
  Widget build(BuildContext context) {
    final value = double.tryParse(_inputController.text.trim());
    final result = value == null ? null : _convert(value);
    return Scaffold(
      appBar: AppBar(title: Text('$_title Converter')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _inputController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          decoration: const InputDecoration(labelText: 'Value', border: OutlineInputBorder()),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 18),
                        Row(children: [
                          Expanded(child: _unitDropdown(_from, (unit) => setState(() => _from = unit!))),
                          IconButton(
                            tooltip: 'Swap units',
                            onPressed: () => setState(() { final oldFrom = _from; _from = _to; _to = oldFrom; }),
                            icon: const Icon(Icons.swap_horiz),
                          ),
                          Expanded(child: _unitDropdown(_to, (unit) => setState(() => _to = unit!))),
                        ]),
                        const SizedBox(height: 24),
                        if (result == null)
                          const Text('Enter a valid number to convert.', style: TextStyle(color: Colors.deepOrange))
                        else
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('RESULT', style: TextStyle(letterSpacing: 1.3, fontWeight: FontWeight.w700, color: Colors.blueGrey)),
                            const SizedBox(height: 6),
                            Text('${result.toStringAsFixed(4)} ${_to.symbol}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Tip: use the swap button to reverse the conversion.', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _unitDropdown(UnitOption selected, ValueChanged<UnitOption?> onChanged) =>
      DropdownButtonFormField<UnitOption>(
        value: selected,
        isExpanded: true,
        decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
        items: _units.map((unit) => DropdownMenuItem(value: unit, child: Text(unit.symbol))).toList(),
        onChanged: onChanged,
      );
}


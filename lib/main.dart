import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_shared_preferences/model/my_models.dart';

Future<Map<String, dynamic>> verileriOku() async {
  final preferences = await SharedPreferences.getInstance();
  final isim = preferences.getString('isim') ?? '';
  final ogrenci = preferences.getBool('ogrenci') ?? false;
  final cinsiyet = Cinsiyet.values[preferences.getInt('cinsiyet') ?? 0];
  final programlamaDilleri =
      preferences.getStringList('programlamaDilleri') ?? <String>[];
  return {
    'isim': isim,
    'ogrenci': ogrenci,
    'cinsiyet': cinsiyet,
    'programlamaDilleri': programlamaDilleri,
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final data = await verileriOku();
  runApp(MyApp(data: data));
}

class MyApp extends StatefulWidget {
  final Map<String, dynamic> data;
  const MyApp({super.key, required this.data});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Cinsiyet _secilenCinsiyet;
  late List<String> _secilenProgramlamaDilleri;
  late bool _ogrenciMi;
  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.data['isim'];
    _ogrenciMi = widget.data['ogrenci'];
    _secilenCinsiyet = widget.data['cinsiyet'];
    _secilenProgramlamaDilleri = widget.data['programlamaDilleri'];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Center(child: const Text('Shared Preferences Demo')),
        ),
        body: ListView(
          children: [
            ListTile(
              title: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Adınızı giriniz',
                ),
              ),
            ),
            for (var item in Cinsiyet.values)
              _buildRadioListTiles(item.name, item),
            for (var item in ProgramlamaDilleri.values)
              _buildCheckboxListTiles(item),
            SwitchListTile(
              title: Text('Öğrenci misin?'),
              value: _ogrenciMi,
              onChanged: (value) {
                setState(() {
                  _ogrenciMi = value;
                });
              },
            ),
            TextButton(onPressed: verileriKaydet, child: Text('Kaydet'))
          ],
        ),
      ),
    );
  }

  CheckboxListTile _buildCheckboxListTiles(
      ProgramlamaDilleri programlamaDilleri) {
    return CheckboxListTile(
      title: Text(programlamaDilleri.name),
      value: _secilenProgramlamaDilleri.contains(programlamaDilleri.name),
      onChanged: (deger) {
        if (deger == false) {
          _secilenProgramlamaDilleri.remove(programlamaDilleri.name);
        } else {
          _secilenProgramlamaDilleri.add(programlamaDilleri.name);
        }
        setState(() {});
        debugPrint(_secilenProgramlamaDilleri.toString());
      },
    );
  }

  RadioListTile<Cinsiyet> _buildRadioListTiles(String name, cinsiyet) {
    return RadioListTile(
      title: Text(name),
      value: cinsiyet,
      groupValue: _secilenCinsiyet,
      onChanged: (secilmisCinsiyet) {
        _secilenCinsiyet = secilmisCinsiyet!;
        setState(() {});
      },
    );
  }

  Future<void> verileriKaydet() async {
    final _name = _nameController.text;
    final preferences = await SharedPreferences.getInstance();
    preferences.setString('isim', _name);
    preferences.setBool('ogrenci', _ogrenciMi);
    preferences.setInt('cinsiyet', _secilenCinsiyet.index);
    preferences.setStringList('programlamaDilleri', _secilenProgramlamaDilleri);
  }
}

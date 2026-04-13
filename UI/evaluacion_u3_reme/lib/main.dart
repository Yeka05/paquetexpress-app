import 'package:flutter/material.dart';
import 'agentes.dart';
import 'paquetes.dart';
import 'entregas.dart';
import 'autenticacion.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

// ================= LOGIN =================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final email = TextEditingController();
  final pass = TextEditingController();

  void login() async {
    if (email.text.isEmpty || pass.text.isEmpty) {
      msg("Ingresa email y contraseña");
      return;
    }

    bool ok = await AuthService.login(email.text, pass.text);

    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      msg("Credenciales incorrectas");
    }
  }

  void msg(String m) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("LOGIN", style: TextStyle(fontSize: 24)),

            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: "Email"),
            ),

            TextField(
              controller: pass,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: login,
              child: const Text("Entrar"),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= Menu =================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  int index = 0;

  final pages = [
    const Agentes(),
    const Paquetes(),
    const Entregas(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paquetería")),

      body: pages[index],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Agentes"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Paquetes"),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: "Entregas"),
        ],
      ),
    );
  }
}
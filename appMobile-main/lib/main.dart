import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth
import 'screens/homePage.dart'; // Home separada

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // Web precisa de config extra
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyB1vI8yyPR-d9MYvrliuYHqVpucU9PB0mo", // sua apiKey
        authDomain: "appmobile-2bbcb.firebaseapp.com", // seu authDomain
        projectId: "appmobile-2bbcb", // seu projectId
        storageBucket: "appmobile-2bbcb.appspot.com", // seu storageBucket
        messagingSenderId: "851102593535", // seu messagingSenderId
        appId: "1:851102593535:web:adcdef123456", // seu appId
        measurementId: "G-851102593535", // seu measurementId
      ),
    );
  } else {
    await Firebase.initializeApp();
    // inicializa Firebase
  }
  runApp(const telaLogin());
}

// ignore: camel_case_types
class telaLogin extends StatelessWidget {
  const telaLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tela de Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color.fromARGB(255, 29, 185, 9),
        useMaterial3: true,
      ),
      routes: {
        '/login': (_) => const LoginPage(),
        '/home': (_) => const HomePage(),
      },
      initialRoute: '/login',
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

//_emailCtrl e _passCtrl: Controlam o texto digitado nos campos de e-mail e senha.
//_formKey: Usado para validar e gerenciar o estado do formulário.
//_emailFocus e _passFocus: Gerenciam o foco dos campos, permitindo, por exemplo, mudar o cursor do e-mail para a senha automaticamente.
class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  //_obscure: Define se o campo de senha está oculto (com "●●●"). Se for true, a senha aparece escondida; se for false, aparece visível.
  //_submitting: Indica se o formulário está sendo enviado (por exemplo, ao clicar em "Entrar" e aguardar resposta)
  //_canSubmit: Indica se os campos do formulário estão válidos para permitir o envio.
  bool _obscure = true;
  bool _submitting = false;
  bool _canSubmit = false;

  //Chama o método da classe pai (super.initState())
  //Adiciona um "ouvinte" (listener) aos controladores de texto do e-mail e da senha.
  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(_updateCanSubmit);
    _passCtrl.addListener(_updateCanSubmit);

    // (opcional) loga mudanças de auth pra debug
    FirebaseAuth.instance.authStateChanges().listen((user) {
      debugPrint('authStateChanges -> ${user?.uid}');
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  //Pega o texto dos campos de e-mail e senha.
  //Usa os métodos de validação para checar se ambos estão corretos.
  //Se o resultado mudou, atualiza o estado do widget para habilitar/desabilitar o botão "Entrar".
  void _updateCanSubmit() {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final ok = _isEmailValid(email) && _isPasswordValid(pass);
    if (ok != _canSubmit) {
      setState(() => _canSubmit = ok);
    }
  }

  bool _isEmailValid(String value) {
    if (value.isEmpty) return false;
    final emailReg = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');
    return emailReg.hasMatch(value);
  }

  bool _isPasswordValid(String value) => value.length >= 8;

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() => _submitting = true);

    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    try {
      // >>> Login real no Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login realizado com sucesso!')),
      );

      // >>> Navega para a Home e substitui a tela de login
      Navigator.of(context).pushReplacementNamed('/home');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);

      String msg = 'Erro ao entrar';
      switch (e.code) {
        case 'invalid-email':
          msg = 'E-mail inválido';
          break;
        case 'user-not-found':
          msg = 'Usuário não encontrado';
          break;
        case 'wrong-password':
          msg = 'Senha incorreta';
          break;
        case 'operation-not-allowed':
          msg = 'Login por e-mail/senha está desativado no Firebase';
          break;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      debugPrint('FirebaseAuthException code=${e.code} message=${e.message}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha inesperada. Tente novamente.')),
      );
      debugPrint('Erro inesperado: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.1, 0.9],
            colors: [
              cs.primary.withOpacity(0.15),
              cs.secondary.withOpacity(0.15),
            ],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      Icon(Icons.lock_outline, size: 56, color: cs.primary),
                      const SizedBox(height: 12),
                      Text(
                        'Entrar',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _emailCtrl,
                        focusNode: _emailFocus,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          hintText: 'seu@email.com',
                          prefixIcon: Icon(Icons.mail_outline),
                          border: OutlineInputBorder(),
                        ),
                        onFieldSubmitted: (_) => _passFocus.requestFocus(),
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) return 'Informe seu e-mail';
                          if (!_isEmailValid(v)) return 'E-mail inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Senha
                      TextFormField(
                        controller: _passCtrl,
                        focusNode: _passFocus,
                        textInputAction: TextInputAction.done,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          hintText: 'Mínimo 8 caracteres',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip: _obscure
                                ? 'Mostrar senha'
                                : 'Ocultar senha',
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        onFieldSubmitted: (_) => _submit(),
                        validator: (value) {
                          final v = value ?? '';
                          if (v.isEmpty) return 'Informe sua senha';
                          if (!_isPasswordValid(v))
                            return 'Senha deve ter ao menos 8 caracteres';
                          return null;
                        },
                      ),

                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Recuperação de senha não implementada.',
                                ),
                              ),
                            );
                          },
                          child: const Text('Esqueci minha senha'),
                        ),
                      ),

                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: (_canSubmit && !_submitting)
                              ? _submit
                              : null,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _submitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Entrar'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Não tem conta?'),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cadastro não implementado.'),
                                ),
                              );
                            },
                            child: const Text('Criar conta'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

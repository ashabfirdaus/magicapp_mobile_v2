import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../config/routes.dart';
import '../models/login_response_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // State variables
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _usePhoneNumber = false;
  bool _accountChecked = false;
  bool _accountExists = false;
  String? _currentUsername;
  bool _isEmailLogin = false;

  // OTP state
  bool _otpLoading = false;
  String? _otpReference;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _resetForm() {
    _usernameController.clear();
    _passwordController.clear();
    setState(() {
      _accountChecked = false;
      _accountExists = false;
      _currentUsername = null;
      _isEmailLogin = false;
      _otpReference = null;
    });
  }

  Future<void> _checkAccount() async {
    if (_usernameController.text.isEmpty) {
      _showErrorSnackbar('Masukkan username, email, atau nomor telepon');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await authService.checkAccount(_usernameController.text);
      if (response.success) {
        setState(() {
          _accountChecked = true;
          _accountExists = response.isLogin;
          _currentUsername = response.input;
          _isEmailLogin = response.isEmail;
        });

        if (!response.isLogin) {
          _showErrorSnackbar(
            'Akun tidak ditemukan. Silakan daftar terlebih dahulu.',
          );
          setState(() => _accountChecked = false);
        }
      } else {
        _showErrorSnackbar(response.message ?? 'Gagal memeriksa akun');
        setState(() => _accountChecked = false);
      }
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogin() async {
    if (_passwordController.text.isEmpty) {
      _showErrorSnackbar('Masukkan password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await authService.login(
        username: _currentUsername ?? '',
        password: _passwordController.text,
        isEmail: _isEmailLogin,
      );

      if (response.success) {
        _showSuccessSnackbar('Login berhasil!');
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      } else {
        print(response.message);
        _showErrorSnackbar(response.message ?? 'Login gagal');
      }
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendOtp() async {
    String loginType = _usePhoneNumber ? 'phone' : 'email';

    setState(() => _otpLoading = true);

    try {
      final response = await authService.sendOtp(
        input: _currentUsername ?? '',
        type: loginType,
        isEmail: _isEmailLogin,
      );
      print(response.success);
      if (response.success) {
        setState(() => _otpReference = response.reference);
        _showSuccessSnackbar('Kode OTP telah dikirim ke WhatsApp Anda');
        _showOtpDialog();
      } else {
        _showErrorSnackbar(response.message ?? 'Gagal mengirim OTP');
      }
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      setState(() => _otpLoading = false);
    }
  }

  void _showOtpDialog() {
    final otpController = TextEditingController();
    bool otpLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Verifikasi OTP'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Masukkan kode OTP yang telah dikirim'),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Kode OTP',
                  hintText: '000000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: otpLoading
                  ? null
                  : () async {
                      if (otpController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Masukkan kode OTP')),
                        );
                        return;
                      }

                      setDialogState(() => otpLoading = true);

                      try {
                        final response = await authService.verifyOtp(
                          code: otpController.text,
                          input: _currentUsername ?? '',
                          isEmail: _isEmailLogin,
                        );

                        if (response.success) {
                          Navigator.pop(context);
                          _showSuccessSnackbar('Login berhasil!');
                          // Navigate to home page after successful verification
                          Navigator.of(
                            context,
                          ).pushReplacementNamed(AppRoutes.home);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                response.message ?? 'Verifikasi OTP gagal',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        setDialogState(() => otpLoading = false);
                      }
                    },
              child: otpLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Verifikasi'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo/Title
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.local_laundry_service,
                        size: 40,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Magic Laundry',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Masuk ke akun Anda',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Login Type Selection
              if (!_accountChecked) ...[
                const Text(
                  'Pilih Metode Login',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _usePhoneNumber = false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: !_usePhoneNumber
                                  ? Colors.deepPurple
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: !_usePhoneNumber
                                ? Colors.deepPurple.shade50
                                : Colors.transparent,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.person,
                                color: !_usePhoneNumber
                                    ? Colors.deepPurple
                                    : Colors.grey,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Username/Email',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: !_usePhoneNumber
                                      ? Colors.deepPurple
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _usePhoneNumber = true);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _usePhoneNumber
                                  ? Colors.deepPurple
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: _usePhoneNumber
                                ? Colors.deepPurple.shade50
                                : Colors.transparent,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.phone,
                                color: _usePhoneNumber
                                    ? Colors.deepPurple
                                    : Colors.grey,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Nomor Telepon',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _usePhoneNumber
                                      ? Colors.deepPurple
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Username/Phone TextField
                    if (!_accountChecked) ...[
                      TextFormField(
                        controller: _usernameController,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          labelText: _usePhoneNumber
                              ? 'Nomor Telepon'
                              : 'Username/Email',
                          hintText: _usePhoneNumber
                              ? '+62812345678'
                              : 'nama@email.com atau username',
                          prefixIcon: Icon(
                            _usePhoneNumber ? Icons.phone : Icons.person,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.deepPurple,
                              width: 2,
                            ),
                          ),
                        ),
                        keyboardType: _usePhoneNumber
                            ? TextInputType.phone
                            : TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      // Check Account Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _checkAccount,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.deepPurple,
                          disabledBackgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Lanjutkan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ] else if (_accountExists) ...[
                      // Display checked account info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          border: Border.all(color: Colors.green.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _currentUsername ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Password TextField
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Masukkan password Anda',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.deepPurple,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Login Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.deepPurple,
                          disabledBackgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Masuk',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      const SizedBox(height: 12),
                      // Back Button
                      OutlinedButton(
                        onPressed: _isLoading ? null : _resetForm,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.deepPurple),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Kembali',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // OTP/WhatsApp Login Section
              if (_accountChecked && _accountExists) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.grey.shade300, thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Atau',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey.shade300, thickness: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // OTP via WhatsApp Button
                ElevatedButton.icon(
                  onPressed: _isLoading || _otpLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.green,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _otpLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.sms, color: Colors.white),
                  label: const Text(
                    'Login dengan Kode OTP WhatsApp',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ] else if (!_accountChecked) ...[
                const SizedBox(height: 24),
              ],

              // Sign Up Link
              if (!_accountChecked) ...[
                const SizedBox(height: 32),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Belum punya akun? ',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Navigasi ke halaman daftar'),
                            ),
                          );
                        },
                        child: const Text(
                          'Daftar di sini',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'user_session.dart';
import 'home_page.dart';

/// 注册页（单页面）
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  bool _obscure = true;

  @override
  void dispose() {
    _accountCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFFFFE6D7), Color(0xFFFFF3EC)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 顶部小返回
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 标识与标题，风格与登录页保持一致
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.25),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.85),
                        width: 3,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 44,
                        color: Color(0xFFFF7A59),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ShaderMask(
                    shaderCallback: (rect) => const LinearGradient(
                      colors: [Color(0xFFFA7C3B), Color(0xFFFF6E7F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(rect),
                    child: const Text(
                      '创建账号',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '仅需账号与密码即可注册',
                    style: TextStyle(
                      color: Color(0xCC6E5B57),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '账号',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B6B6B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _accountCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration('请输入手机号或邮箱'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? '请输入账号' : null,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '密码',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B6B6B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _pwdCtrl,
                          obscureText: _obscure,
                          decoration: _inputDecoration('请输入密码，至少6位').copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(_obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return '请输入密码';
                            if (v.length < 6) return '密码至少6位';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // 注册按钮（渐变）
                        SizedBox(
                          height: 48,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF8A5C), Color(0xFFFF6E7F)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x4DFF6E7F),
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: _onRegister,
                                child: const Center(
                                  child: Text(
                                    '注册',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('已有账号？'),
                            TextButton(
                              onPressed: () => Navigator.of(context).maybePop(),
                              child: const Text(
                                '去登录',
                                style: TextStyle(
                                  color: Color(0xFFFF7A59),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onRegister() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final account = _accountCtrl.text.trim();
    final password = _pwdCtrl.text.trim();

    // 显示加载提示
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF7A59),
        ),
      ),
    );

    try {
      // 注册用户
      final userId = await DatabaseHelper.instance.registerUser(account, password);

      if (!mounted) return;
      Navigator.pop(context); // 关闭加载提示

      // 获取用户信息并登录
      final user = await DatabaseHelper.instance.getUserById(userId);
      if (user != null) {
        await UserSession.instance.login(user);

        // 注册成功，直接进入首页
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('注册成功！'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // 关闭加载提示

      String errorMsg = '注册失败';
      if (e.toString().contains('账号已存在')) {
        errorMsg = '账号已存在，请使用其他账号';
      } else {
        errorMsg = '注册失败：$e';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF8A5C), width: 1.5),
      ),
    );
  }
}


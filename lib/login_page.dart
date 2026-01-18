import 'package:flutter/material.dart';
import 'register_page.dart';
import 'home_page.dart';
import 'database_helper.dart';
import 'user_session.dart';

/// 登录页（单页面）
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  bool _remember = false;
  bool _obscure = true;

  @override
  void dispose() {
    _userCtrl.dispose();
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
                  // 顶部 Logo 圆形
                  Container(
                    width: 96,
                    height: 96,
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
                        Icons.tag_faces_rounded,
                        size: 48,
                        color: Color(0xFFFF7A59),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 渐变主标题
                  ShaderMask(
                    shaderCallback: (rect) => const LinearGradient(
                      colors: [Color(0xFFFA7C3B), Color(0xFFFF6E7F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(rect),
                    child: const Text(
                      '融意',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '沟通无界限',
                    style: TextStyle(
                      color: Color(0xCC6E5B57),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 表单
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
                          controller: _userCtrl,
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
                          decoration: _inputDecoration('请输入密码').copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(_obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? '请输入密码' : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Checkbox(
                              value: _remember,
                              onChanged: (v) => setState(() => _remember = v ?? false),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            const Text('记住我'),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('忘记密码（示例）')),
                                );
                              },
                              child: const Text(
                                '忘记密码？',
                                style: TextStyle(color: Color(0xFFFF7A59)),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        // 登录按钮（渐变）
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
                                onTap: _onLogin,
                                child: const Center(
                                  child: Text(
                                    '登录',
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
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('没有账号？'),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                '立即注册',
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

  void _onLogin() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final account = _userCtrl.text.trim();
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
      // 验证用户登录
      final user = await DatabaseHelper.instance.loginUser(account, password);

      if (!mounted) return;
      Navigator.pop(context); // 关闭加载提示

      if (user != null) {
        // 登录成功，保存会话
        await UserSession.instance.login(user);

        // 进入首页
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
        );
      } else {
        // 登录失败
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('账号或密码错误，请检查后重试'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // 关闭加载提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('登录失败：$e'),
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

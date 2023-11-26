import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:the_movie_db/theme/app_button_style.dart';
import 'package:the_movie_db/ui/navigation/main_navigation.dart';
import 'package:the_movie_db/widgets/auth/auth_view_cubit.dart';

class _AuthDataStorage {
  String login = '';
  String password = '';
}

class AuthWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthViewCubit, AuthViewCubitState>(
      listener: _onAuthViewCubitStateChange,
      child: Provider(
        create: (_) => _AuthDataStorage(),
        child: Scaffold(
          appBar: AppBar(
            title: Text('Войти в свою учётную запись'),
          ),
          body: ListView(
            children: [
              _HeaderWidget(),
            ],
          ),
        ),
      ),
    );
  }

  void _onAuthViewCubitStateChange(
    BuildContext context,
    AuthViewCubitState state,
  ) {
    if (state is AuthViewCubitAuthSuccessState) {
      MainNavigation.resetNavigation(context);
    }
  }
}

class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget({Key? key}) : super(key: key);

  final customTextStyle = const TextStyle(fontSize: 16, color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 25.0),
          _FormWidget(),
          SizedBox(height: 25.0),
          Text(
            'Чтобы пользоваться правкой и возможностями рейтинга TMDB, а также получить персональные рекомендации, необходимо войти в свою учётную запись. Если у вас нет учётной записи, её регистрация является бесплатной и простой.',
            style: customTextStyle,
          ),
          TextButton(
              onPressed: () {},
              style: AppButtonStyle.linkButton,
              child: Text('Регистрация')),
          SizedBox(height: 25.0),
          Text(
            'Если Вы зарегистрировались, но не получили письмо для подтверждения, нажмите здесь, чтобы отправить письмо повторно.',
            style: customTextStyle,
          ),
          TextButton(
              onPressed: () {},
              style: AppButtonStyle.linkButton,
              child: Text('Верификация')),
        ],
      ),
    );
  }
}

class _FormWidget extends StatelessWidget {
  const _FormWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authDataStorage = context.read<_AuthDataStorage>();

    final customTextStyle = const TextStyle(
      fontSize: 16,
      color: Colors.black,
    );
    final textFieldDecorator = const InputDecoration(
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 12.0,
      ),
      isCollapsed: true,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.red,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.green,
          width: 2.0,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ErrorMessageWidget(),
        Text(
          'Пользователь',
          style: customTextStyle,
          textAlign: TextAlign.left,
        ),
        SizedBox(height: 5.0),
        TextField(
          decoration: textFieldDecorator,
          onChanged: (text) => authDataStorage.login = text,
        ),
        SizedBox(height: 20.0),
        Text(
          'Пароль',
          style: customTextStyle,
          textAlign: TextAlign.left,
        ),
        SizedBox(height: 5.0),
        TextField(
          decoration: textFieldDecorator,
          obscureText: true,
          onChanged: (text) => authDataStorage.password = text,
        ),
        SizedBox(height: 25.0),
        Row(
          children: [
            const _AuthButtonWidget(),
            SizedBox(width: 20.0),
            TextButton(
                onPressed: () {},
                style: AppButtonStyle.linkButton,
                child: Text('Reset password')),
          ],
        )
      ],
    );
  }
}

class _AuthButtonWidget extends StatelessWidget {
  const _AuthButtonWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<AuthViewCubit>();
    final authDataStorage = context.read<_AuthDataStorage>();
    final color = const Color(0xff01b4e4);
    final canStartAuth = cubit.state is AuthViewCubitFormFillInProgressState ||
        cubit.state is AuthViewCubitErrorState;
    final onPressed = canStartAuth
        ? () => cubit.auth(
            login: authDataStorage.login, password: authDataStorage.password)
        : null;
    final child = cubit.state is AuthViewCubitAuthProgressState
        ? const SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
        : const Text('Login');
    return ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(color),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            textStyle: MaterialStateProperty.all(
                TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            padding: MaterialStateProperty.all(
                EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0))),
        child: child);
  }
}

class _ErrorMessageWidget extends StatelessWidget {
  const _ErrorMessageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final errorMessage = context.select((AuthViewCubit c) {
      final state = c.state;
      return state is AuthViewCubitErrorState ? state.errorMessage : null;
    });

    if (errorMessage == null) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Text(
        errorMessage,
        style: TextStyle(
          color: Colors.red,
          fontSize: 17,
        ),
      ),
    );
  }
}

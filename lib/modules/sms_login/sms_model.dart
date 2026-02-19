import 'dart:convert';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flux_interface/flux_interface.dart';
import 'package:http/http.dart' as http;
import 'package:inspireui/inspireui.dart';

import '../../../../models/entities/user.dart';
import '../../../../services/services.dart';
import '../../models/phone_user_model.dart';

enum SMSModelState { loading, complete }

class SMSModel extends ChangeNotifier {
  var _state = SMSModelState.complete;

  SMSModelState get state => _state;
  final String _verificationId = '';
  String _smsCode = '';
  String _phoneNumber = '';
  CountryCode _countryCode = CountryCode();
  int? _resendToken;

  /// Computed
  String get smsCode => _smsCode;

  String get phoneNumber => _phoneNumber;

  String get phoneNumberWithoutZero => _phoneNumber.removeLeadingZeros();

  // String get dialPhoneNumber => _countryCode.dialCode! + phoneNumberWithoutZero;
  String get dialPhoneNumber => phoneNumberWithoutZero;

  String get dialPhoneNumberWithoutPlus => dialPhoneNumber.replaceAll('+', '');

  String get countryDialCode => _countryCode.dialCode ?? '';

  CountryCode get country => _countryCode;

  String get flagUri => _countryCode.flagUri ?? '';

  String get countryName => _countryCode.name ?? 'Unknown';

  bool get isValidPhoneNumber => _phoneNumber.isNotEmpty;

  void updateCountryCode(CountryCode countryCode) {
    _countryCode = countryCode;
    notifyListeners();
  }

  /// Update state
  void _updateState(state) {
    _state = state;
    notifyListeners();
  }

  // Future<void> sendOTP({
  //   VoidCallback? onPageChanged,
  //   Function(FirebaseErrorException)? onMessage,
  //   VoidCallback? onVerify,
  // }) async {
  //   print('SENDING CODE');
  //   try {
  //     _updateState(SMSModelState.loading);
  //     await Services().firebase.verifyPhoneNumber(
  //           forceResendingToken: _resendToken,
  //           phoneNumber: dialPhoneNumber,
  //           verificationCompleted: (String? smsCode) {
  //             _smsCode = smsCode!;
  //             onVerify?.call();
  //           },
  //           verificationFailed: (FirebaseErrorException e) {
  //             onMessage?.call(e);
  //             _updateState(SMSModelState.complete);
  //           },
  //           codeSent: (String verificationId, int? resendToken) {
  //             _verificationId = verificationId;
  //             _resendToken = resendToken;
  //             onPageChanged?.call();
  //             _updateState(SMSModelState.complete);

  //             ///Test with number +84764555949
  //             // Future.delayed(Duration(seconds: 3)).then((value) {
  //             //   _smsCode = '123456';
  //             //   onVerify();
  //             // });
  //           },
  //           codeAutoRetrievalTimeout: (String verificationId) {},
  //         );
  //   } catch (err) {
  //     printLog(err.toString());
  //     _updateState(SMSModelState.complete);
  //   }
  // }

  Future<bool> sendOTP({
    VoidCallback? onPageChanged,
    Function(FirebaseErrorException)? onMessage,
    VoidCallback? onVerify,
    String actionType = 'login',
  }) async {
    print('SENDING CODE to - $dialPhoneNumber');
    try {
      _updateState(SMSModelState.loading);
      final url = Uri.parse(
        'https://agratix.com/psdemo/wp-json/ploginotp/v1/send-otp',
      );

      final response = await http.post(
        url,
        headers: const {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'mobile': dialPhoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('OTP SENT - $responseData');
        // Success callback
        onMessage?.call(
          FirebaseErrorException(
            message: 'OTP sent successfully',
            code: 'otp_sent',
          ),
        );

        // Navigate to OTP screen
        onPageChanged?.call();

        // Optional verification trigger
        // onVerify?.call();
        _updateState(SMSModelState.complete);
        return true;
      } else {
        onMessage?.call(
          FirebaseErrorException(
            message: 'Failed to send OTP. Please try again.',
            code: 'otp_failed',
          ),
        );
        _updateState(SMSModelState.complete);
        return false;
      }
    } catch (e) {
      onMessage?.call(
        FirebaseErrorException(
          message: 'Something went wrong. Please check your network.',
          code: 'exception',
        ),
      );
      _updateState(SMSModelState.complete);
      return false;
    }
  }

  // Future<bool> smsVerify(Function showMessage) async {
  //   _updateState(SMSModelState.loading);
  //   try {
  //     final credential = Services().firebase.getFirebaseCredential(verificationId: _verificationId, smsCode: _smsCode);

  //     final user = await Services().firebase.loginFirebaseCredential(credential: credential);
  //     if (user != null) {
  //       _phoneNumber = _phoneNumber.replaceAll('+', '').replaceAll(' ', '');
  //       return true;
  //     }
  //   } on FirebaseErrorException catch (err) {
  //     printLog(err.toString());
  //     showMessage(err);
  //   }
  //   _updateState(SMSModelState.complete);
  //   return false;
  // }
  // Future<bool> smsVerify(Function showMessage) async {
  //   try {
  //     _updateState(SMSModelState.loading);
  //     final url = Uri.parse(
  //       'https://agratix.com/psdemo/wp-json/ploginotp/v1/verify-otp',
  //     );

  //     final response = await http.post(
  //       url,
  //       headers: const {
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode({
  //         'mobile': phoneNumber,
  //         'otp': _smsCode,
  //       }),
  //     );
  //     print('OTP IS - $_smsCode');
  //     if (response.statusCode == 200) {
  //       final responseData = jsonDecode(response.body);
  //       print('VERYFIED OTP - $responseData');
  //       _updateState(SMSModelState.complete);
  //       return true;
  //     } else {
  //       showMessage('Invalid OTP. Please try again.');
  //       _updateState(SMSModelState.complete);
  //       return false;
  //     }
  //   } catch (e) {
  //     showMessage('Invalid OTP. Please try again.');
  //     _updateState(SMSModelState.complete);
  //     return false;
  //   }
  // }
  Future<PhoneUserModel?> smsVerify(Function(String) showMessage) async {
    try {
      _updateState(SMSModelState.loading);

      final url = Uri.parse(
        'https://agratix.com/psdemo/wp-json/ploginotp/v1/verify-otp',
      );

      final response = await http.post(
        url,
        headers: const {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'mobile': phoneNumber,
          'otp': _smsCode,
        }),
      );

      print('OTP IS - $_smsCode');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        print('VERIFIED OTP - $responseData');

        final phoneUserModel = PhoneUserModel.fromJson(responseData);

        if (phoneUserModel.success) {
          _updateState(SMSModelState.complete);
          return phoneUserModel;
        } else {
          showMessage(phoneUserModel.message);
          _updateState(SMSModelState.complete);
          return null;
        }
      } else {
        showMessage('Invalid OTP. Please try again.');
        _updateState(SMSModelState.complete);
        return null;
      }
    } catch (e) {
      showMessage('Invalid OTP. Please try again.');
      _updateState(SMSModelState.complete);
      return null;
    }
  }

  Future<bool> isPhoneNumberExisted() async {
    final result = await Services().api.isUserExisted(phone: dialPhoneNumber);
    print('isPhoneNumberExisted - $result');
    if (!result) {
      _updateState(SMSModelState.complete);
    }
    return result;
  }

  Future<bool> isUserExisted(String username) async {
    _updateState(SMSModelState.loading);
    final result = await Services().api.isUserExisted(username: username);
    print('isUserExisted - $result');

    if (result) {
      _updateState(SMSModelState.complete);
    }
    return result;
  }

  Future<User?> login() async {
    print('SMS MODEL - LOGIN SMS');
    try {
      final result = await Services().api.loginSMS(token: dialPhoneNumberWithoutPlus);
      if (result == null) {
        _updateState(SMSModelState.complete);
      }
      _smsCode = '';
      return result;
    } catch (e) {
      _updateState(SMSModelState.complete);
      rethrow;
    }
  }

  Future<User?> createUser(data) async {
    print('SMS MODEL - CREATE USER');
    try {
      final user = await Services().api.createUser(
          phoneNumber: data['phoneNumber'],
          firstName: data['firstName'],
          lastName: data['lastName'],
          email: data['email'],
          password: data['password']);
      _updateState(SMSModelState.complete);
      return user;
    } catch (e) {
      _updateState(SMSModelState.complete);
      rethrow;
    }
  }

  void updatePhoneNumber(val) {
    _phoneNumber = val;
    notifyListeners();
  }

  void updateSMSCode(val) {
    _smsCode = val;
    notifyListeners();
  }
}

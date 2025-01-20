import 'package:car_rental_project/constants.dart';
import 'package:dio/dio.dart';

class PaymobManager {
  Future<String> getPaymentKey(double amount, String currency) async {
    try {
      // Convert double amount to cents, handling decimal places
      int amountInCents = (amount * 100).round();
      
      String authenticationToken = await _getAuthenticationToken();
      int orderId = await _getOrderId(
          authenticationToken: authenticationToken,
          amount: amountInCents.toString(),
          currency: currency);
      String paymentKey = await _getPaymentKey(
          authenticationToken: authenticationToken,
          amount: amountInCents.toString(),
          currency: currency,
          orderId: orderId.toString());

      return paymentKey;
    } catch (e) {
      print("exception--------------------------------------");
      throw Exception();
    }
  }

  Future<String> _getAuthenticationToken() async {
    final Response response =
        await Dio().post("https://accept.paymob.com/api/auth/tokens", data: {
      "api_key": Constants.api_key,
    });
    return response.data["token"];
  }

  Future<int> _getOrderId({
    required String authenticationToken,
    required String amount,
    required String currency,
  }) async {
    final Response response = await Dio()
        .post("https://accept.paymob.com/api/ecommerce/orders", data: {
      "auth_token": authenticationToken,
      "amount_cents": amount,
      "currency": currency,
      "delivery_needed": "false",
      "items": [],
    });
    return response.data["id"];
  }

  Future<String> _getPaymentKey({
    required String authenticationToken,
    required String orderId,
    required String amount,
    required String currency,
  }) async {
    final Response response = await Dio()
        .post("https://accept.paymob.com/api/acceptance/payment_keys", data: {
      "expiration": 3600,
      "auth_token": authenticationToken,
      "order_id": orderId,
      "integration_id": Constants.integration_id,
      "amount_cents": amount,
      "currency": currency,
      "billing_data": {
        "first_name": "rana",
        "last_name": "mohamed",
        "email": "rana.abulkassem@gmail.com",
        "phone_number": "+201004222194",
        "apartment": "NA",
        "floor": "NA",
        "street": "NA",
        "building": "NA",
        "shipping_method": "NA",
        "postal_code": "NA",
        "city": "NA",
        "country": "NA",
        "state": "NA"
      },
    });
  String paymentKey = response.data["token"]; // This is what you need to continue with payment
  return paymentKey;  }
}
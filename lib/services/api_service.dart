import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_consts.dart'; // Ensure this file contains the BASE_URL and API_KEY constants.

class ApiService {
  static Future<void> postUserFinancialData() async {
    try {
      var response = await http.post(
        Uri.parse('$BASE_URL//chat/completions'),
       // Uri.parse('https://api.openai.com/v1/chat/completions'),


        // https://api.openai.com/v1/chat/completions
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $API_KEY'
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "user",
              "content": "User's Financial Data:\n- Current Monthly Income: \$1000.\n- Monthly Expenses:\n  1. Rent/Mortgage: \$25.\n  2. Utilities: \$300\n  3. Groceries: \$400\n  4. Transportation: \$100\n  5. Entertainment: \$20\n\n- Budget Goal:\n  - Financial Goal: saving for 1k in a year\n  - Target Amount: \$1000 or Timeline: 1 year\n\n- Additional Information:\n  - Existing Savings/Investments: none\n  - Upcoming Expenses/Changes: none"
            }
          ],
          "temperature": 0.7
        }),
      );

      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print("jsonResponse $jsonResponse");
      print("the baseurl is: $BASE_URL");
    } catch (error) {
      print("error $error");
    }
  }
}
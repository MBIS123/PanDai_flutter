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

  static Future<http.Response> scratchAssessment({
    required String purpose,
    required double amount,
    required int months,
    required int years,
    required double monthlyExpense,
    required double monthlyIncome,
    required double extraTarget,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $API_KEY',
        },
        body: jsonEncode({
          "model": "gpt-4-turbo",
          "messages": [
            {
              "role": "user",
              "content": "User's Financial Data:Here's my new financial data forgot the previous data\n"
                  "- Current Monthly Income: $monthlyIncome.\n"
                  "- Monthly Expenses: $monthlyExpense\n\n"
                  "- Budget Goal:\n"
                  "  - Financial Goal: $purpose\n"
                  "  - Target Amount: $amount\n"
                  "    Timeline: $years years and $months months\n\n"
                  "- Additional Information:\n"
                  "  - Existing Savings/Investments: none\n"
                  "  - Upcoming Expenses/Changes: Targeting extra savings of $extraTarget per month\n\n"
                  "Provide an Assessment:\n"
                  "- Can the user reach the target amount based on their current monthly surplus, which is income minus expenses multiply month and year time 12?\n"
                  "- Calculate the number of months needed to reach the target by dividing the target amount by the monthly surplus. Present the result as 'It will take X months to reach the target.'\n"
                  "- If the user cannot reach their target within the desired timeline, suggest a new realistic timeline based on their financial data.\n"
                  "- Keep the assessment concise, within 30-40 words, and base the timeline estimation strictly on the monthly surplus calculation. change the \$ to RM. "
            }
          ],
          "temperature": 0.7
        }
        ),

      );
      return response;
    } catch (error) {
      print("error $error");
      throw error; // You can rethrow the error or handle it as needed
    }
  }


  static Future<http.Response> scratchFinancialAdvice({
    required String purpose,
    required double amount,
    required int months,
    required int years,
    required double monthlyExpense,
    required double monthlyIncome,
    required double extraTarget,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $API_KEY',
        },
        body: jsonEncode({
          "model": "gpt-4-turbo",
          "messages": [
            {
              "role": "user",
              "content": "I am seeking financial advice to achieve a budget goal. Here's my new financial data forgot the previous data:\n"
                  "- Current Monthly Income: \$$monthlyIncome\n"
                  "- Monthly Expenses: \$$monthlyExpense\n"
                  "- Budget Goal for $purpose: \$$amount in $years years and $months months\n"
                  "- Additional goals: Increase monthly savings by \$$extraTarget\n\n"
                  "Based on this, what practical steps should I take to realistically achieve my budget goal within the specified timeline? "
                  "Please provide concise financial advice in bullet points, not exceeding 40 words, considering the feasibility of the goal and my current financial situation. change the \$ to RM"
            }
          ],
          "temperature": 0.7,
        }),
      );
      return response;
    } catch (error) {
      print("error $error");
      throw error; // You can rethrow the error or handle it as needed
    }
  }



  static Future<http.Response> scratchSuccessScore({
    required String purpose,
    required double amount,
    required int months,
    required int years,
    required double monthlyExpense,
    required double monthlyIncome,
    required double extraTarget,
  }) async {
    try {
      // Calculate monthly surplus
      double monthlySurplus = monthlyIncome - monthlyExpense;

      // Calculate achievable timeline
      double achievableTimeline = amount / monthlySurplus;
      int achievableMonths = (achievableTimeline.ceil()).toInt();
      print("The achievable months is:" + achievableMonths.toString());

      final response = await http.post(
        Uri.parse('$BASE_URL/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $API_KEY',
        },
        body: jsonEncode({
          "model": "gpt-4-turbo",
          "messages": [
            {
              "role": "user",
              "content": "User's Financial Data:Here's my new financial data forgot the previous datainput\n"
                  "- Current Monthly Income: RM$monthlyIncome.\n"
                  "- Monthly Expenses: RM$monthlyExpense\n\n"
                  "- Budget Goal:\n"
                  "  - Financial Goal: $purpose\n"
                  "  - Target Amount: RM$amount\n"
                  "    Given Timeline: $years years and $months months\n\n"
                  "- Additional Information:\n"
                  "  - Existing Savings/Investments: none\n"
                  "  - Upcoming Expenses/Changes: Targeting extra savings of RM$extraTarget per month\n\n"
                  "- Achievable Timeline: $achievableMonths\n"
                  "Assess the Plan and Give a Success Score:\n"
                  "- Calculate the monthly surplus by subtracting monthly expenses from monthly income.\n"
                  "- Score the plan from 1 - 100 in which the score is higher if the Given Timeline is  lower but closer with the Achievable Timeline\n"
                  "- Set the score to 100 if the GivenTimeline is more than Achievable Timeline\n"


                  " Provide only the score as the response in format of Score:X%, no need give explanation"
            }

          ],
          "temperature": 0.7,
        }),
      );
      return response;
    } catch (error) {
      print("error $error");
      throw error; // You can rethrow the error or handle it as needed
    }
  }







}
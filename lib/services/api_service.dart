import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_consts.dart'; // Ensure this file contains the BASE_URL and API_KEY constants.

class ApiService {
  // static Future<http.Response> scratchSuccessScore({
  //   required String purpose,
  //   required double amount,
  //   required int months,
  //   required int years,
  //   required double monthlyExpense,
  //   required double monthlyIncome,
  //   required double extraTarget,
  //   required String gptModel, // Add parameter for GPT model
  // }) async {
  //   try {
  //     // Calculate monthly surplus
  //     double monthlySurplus = monthlyIncome - monthlyExpense;
  //
  //     // Calculate achievable timeline
  //     double achievableTimeline = amount / monthlySurplus;
  //     int achievableMonths = (achievableTimeline.ceil()).toInt();
  //     print("The achievable months is:" + achievableMonths.toString());
  //
  //     final response = await http.post(
  //       Uri.parse('$BASE_URL/chat/completions'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $API_KEY',
  //       },
  //       body: jsonEncode({
  //         "model": gptModel, // Use the provided GPT model
  //         "messages": [
  //           {
  //             "role": "user",
  //             "content": "User's Financial Data:Here's my new financial data forgot the previous datainput\n"
  //                 "- Current Monthly Income: RM$monthlyIncome.\n"
  //                 "- Monthly Expenses: RM$monthlyExpense\n\n"
  //                 "- Budget Goal:\n"
  //                 "  - Financial Goal: $purpose\n"
  //                 "  - Target Amount: RM$amount\n"
  //                 "    Given Timeline: $years years and $months months\n\n"
  //                 "- Additional Information:\n"
  //                 "  - Existing Savings/Investments: none\n"
  //                 "  - Upcoming Expenses/Changes: Targeting extra savings of RM$extraTarget per month\n\n"
  //                 "- Achievable Timeline: $achievableMonths\n"
  //                 "Assess the Plan and Give a Success Score:\n"
  //                 "- Calculate the monthly surplus by subtracting monthly expenses from monthly income.\n"
  //                 "- Score the plan from 1 - 100 based on the following expanded criteria:\n"
  //                 "  - If the achievable timeline is less than or equal to 10% of the given timeline, set the score between 90 and 100.\n"
  //                 "  - If the achievable timeline is between 10% and 50% of the given timeline, set the score between 70 and 89.\n"
  //                 "  - If the achievable timeline is between 50% and 75% of the given timeline, set the score between 50 and 69.\n"
  //                 "  - If the achievable timeline is between 75% and 100% of the given timeline, set the score between 30 and 49.\n"
  //                 "- Provide only the score in response"
  //           }
  //         ],
  //         "temperature": 0.7,
  //         // Include achievable timeline and given timeline in the request payload
  //         "achievableTimeline": achievableMonths,
  //         "givenTimeline": (years * 12) + months,
  //       }),
  //     );
  //     return response;
  //   } catch (error) {
  //     print("error $error");
  //     throw error; // You can rethrow the error or handle it as needed
  //   }
  // }

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
              "content":
              "User's Financial Data:\n- Current Monthly Income: \$1000.\n- Monthly Expenses:\n  1. Rent/Mortgage: \$25.\n  2. Utilities: \$300\n  3. Groceries: \$400\n  4. Transportation: \$100\n  5. Entertainment: \$20\n\n- Budget Goal:\n  - Financial Goal: saving for 1k in a year\n  - Target Amount: \$1000 or Timeline: 1 year\n\n- Additional Information:\n  - Existing Savings/Investments: none\n  - Upcoming Expenses/Changes: none"
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
        }),
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
      throw error;
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
                  " Provide only the score as the response in format of Score:X%, no need give  at all"
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

//   static Future<http.Response> customisedAssessment({
//     required String purpose,
//     required double amount,
//     required int months,
//     required int years,
//     required double monthlyExpense,
//     required double monthlyIncome,
//     required double extraTarget,
//     required List<Map<String, dynamic>> incomeDataList,
//     required List<Map<String, dynamic>> budgetDataList,
//     required List<Map<String, dynamic>> transactionDataList,
//   }) async {
//     String content = """
// User's Financial Data: Here's my new financial data, forgot the previous data
// - Current Monthly Income: RM$monthlyIncome.
//
// - Income Data:""";
//     for (Map<String, dynamic> item in incomeDataList) {
//       content += "\n  - Income Type: ${item['type']}";
//       content += "\n  - Amount: RM${item['amount']}";
//     }
//
//     content += """
// - Monthly Expenses: RM$monthlyExpense
//
// - Budget Goal:
//   - Financial Goal: RM$purpose
//   - Target Amount: RM$amount
//   Timeline: $years years and $months months
//
// - Budget Data:""";
//     for (Map<String, dynamic> item in budgetDataList) {
//       content += "\n  - Category: ${item['category']}";
//       content += "\n    - Limit: RM${item['limit']}";
//       content += "\n    - Amount Spent: RM${item['spent']}";
//     }
//
//     content += """
// - Transaction History:""";
//     for (Map<String, dynamic> item in transactionDataList) {
//       content += "\n  - Expense Type: ${item['expensetype']}";
//       content += "\n    - Expense Amount: RM${item['transactionAmt']}";
//     }
//
//     content += """
// - Additional Information:
//   - Existing Savings/Investments: none
//   - Upcoming Expenses/Changes: Targeting extra savings of RM$extraTarget per month
//
// Provide an Assessment:
// - Give a short description within 50 words summarizing the Income Type and highlighting whether the user fulfills their budget goal.
// - Can the user reach the target amount based on their current monthly surplus (income minus expenses multiplied by 12)?
// - Calculate the number of months needed to reach the target by dividing the target amount by the monthly surplus. Present the result as 'It will take X months to reach the target.'
// - If the user cannot reach their target within the desired timeline, suggest a new realistic timeline based on their financial data.
// - Keep the assessment concise, within 30-40 words, and base the timeline estimation strictly on the monthly surplus calculation. Change the \$ to RM.
// """;
//
//
//     print("The content is:" + content);
//     try {
//       final response = await http.post(
//         Uri.parse('$BASE_URL/chat/completions'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $API_KEY',
//         },
//         body: jsonEncode({
//           "model": "gpt-4-turbo",
//           "messages": [
//             {"role": "user", "content": content}
//           ],
//           "temperature": 0.7
//         }),
//       );
//       return response;
//     } catch (error) {
//       print("error $error");
//       throw error; // You can rethrow the error or handle it as needed
//     }
//   }

  static Future<http.Response> customisedAssessment({
    required String purpose,
    required double amount,
    required int months,
    required int years,
    required double monthlyExpense,
    required double monthlyIncome,
    required double extraTarget,
    required List<Map<String, dynamic>> incomeDataList,
    required List<Map<String, dynamic>> budgetDataList,
    required List<Map<String, dynamic>> transactionDataList,
  }) async {
    String content = """
User's Financial Data: Here's my new financial data, forgot the previous data
- Current Monthly Income: RM$monthlyIncome.

- Income Data:""";
    for (Map<String, dynamic> item in incomeDataList) {
      content += "\n  - Income Type: ${item['type']}";
      content += "\n  - Amount: RM${item['amount']}";
    }

    content += """
- Monthly Expenses: RM$monthlyExpense

- Budget Goal:
  - Financial Goal: RM$purpose
  - Target Amount: RM$amount
  Timeline: $years years and $months months

- Budget Data:""";
    for (Map<String, dynamic> item in budgetDataList) {
      content += "\n  - Category: ${item['category']}";
      content += "\n    - Limit: RM${item['limit']}";
      content += "\n    - Amount Spent: RM${item['spent']}";
    }

    content += """\n
 Transaction History:""";
    for (Map<String, dynamic> item in transactionDataList) {
      content += "\n  - Expense Type: ${item['expensetype']}";
      content += "\n    - Expense Amount: RM${item['transactionAmt']}";
    }

    content += """
- Additional Information:
  - Existing Savings/Investments: none
  - Upcoming Expenses/Changes: Targeting extra savings of RM$extraTarget per month

Provide an Assessment:
-calculate their current monthly surplus (monthly income minus monthly expenses)
- Keep the assessment concise, within 10 words, and base the timeline estimation strictly on the monthly surplus calculation. Change the \$ to RM. Just say something like You can or cannot arhieve the targeted amount to save in the original timeline ( )
- If the user cannot reach their target within the desired timeline, suggest a new realistic timeline. Just give the response as Adjusted Month: X  , dont provide explanation at all
""";


    print("The content is:" + content);
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
            {"role": "user", "content": content}
          ],
          "temperature": 0.7
        }),
      );
      return response;
    } catch (error) {
      print("error $error");
      throw error; // You can rethrow the error or handle it as needed
    }
  }

  static Future<http.Response> customizedFinancialAdvice({
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

  static Future<http.Response> customizedSuccessScore({
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
                  "- Score the plan from 1 - 100 in which the score is higher if the Given Timeline is  lower than expected time but closer with the Achievable Timeline\n"
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


  static Future<http.Response> customizedBudgetExpenseAdjustment({
    required String purpose,
    required double amount,
    required int months,
    required int years,
    required double monthlyExpense,
    required double monthlyIncome,
    required double extraTarget,
    required List<Map<String, dynamic>> incomeDataList,
    required List<Map<String, dynamic>> budgetDataList,
    required List<Map<String, dynamic>> transactionDataList,
  }) async {
    String content = """
User's Financial Data: Here's my new financial data, forgot the previous data
- Current Monthly Income: RM$monthlyIncome.

- Income Data:""";
    for (Map<String, dynamic> item in incomeDataList) {
      content += "\n  - Income Type: ${item['type']}";
      content += "\n  - Amount: RM${item['amount']}";
    }

    content += """
- Monthly Expenses: RM$monthlyExpense

- Budget Goal:
  - Financial Goal: RM$purpose
  - Target Amount: RM$amount
  Timeline: $years years and $months months

- Budget Data:""";
    for (Map<String, dynamic> item in budgetDataList) {
      content += "\n  - Category: ${item['category']}";
      content += "\n    - Limit: RM${item['limit']}";
      content += "\n    - Amount Spent: RM${item['spent']}";
    }

    content += """\n
 Transaction History:""";
    for (Map<String, dynamic> item in transactionDataList) {
      content += "\n  - Expense Type: ${item['expensetype']}";
      content += "\n    - Expense Amount: RM${item['transactionAmt']}";
    }

    content += """
- Additional Information:
  - Existing Savings/Investments: none
  - Upcoming Expenses/Changes: Targeting extra savings of RM$extraTarget per month

Provide an Budget And Expenses Adjustment:
-the budget amount spent is actually the sum of all transaction per category.
-calculate their current monthly surplus (income minus expenses)
-  if the monthly surplus is not enough to reach the target amount in the timeline , suggest to lower to the budgetset for some category , give response in format of  BudgetType -15 % RM RM575-> RM500
- If the user cannot reach their target within the desired timeline, suggest to reduce Expenses,  give response in format of  ExpenseType -15 % RM RM575-> RM500
-Make each response short and precise total of not more than 30 words

""";


    print("The content is:" + content);
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
            {"role": "user", "content": content}
          ],
          "temperature": 0.7
        }),
      );
      return response;
    } catch (error) {
      print("error $error");
      throw error; // You can rethrow the error or handle it as needed
    }
  }



}

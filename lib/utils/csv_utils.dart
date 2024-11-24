import 'dart:io';
import 'dart:convert'; // Import this to use utf8
import 'package:csv/csv.dart';




// A simple map of keywords to categories
Map<String, String> keywordCategoryMap = {
  'grocery': 'Groceries',
  'supermarket': 'Groceries',
  'restaurant': 'Dining',
  'dining': 'Dining',
  'fuel': 'Transportation',
  'gas': 'Transportation',
  'subscription': 'Entertainment',
  'rent': 'Housing',
  'utility': 'Utilities',
};

Future<List<Map<String, dynamic>>> processCsvFile(String path) async {
  List<List<dynamic>> csvData = await readCsvFile(path);
  if (csvData.isEmpty) {
    print('CSV file is empty');
    return [];
  }

  // Check the header row
  List<dynamic> header = csvData[0];
  int categoryIndex = header.indexOf('Category');
  int descriptionIndex = header.indexOf('Description');

  // Debugging: Print the header and indexes
  print('CSV Header: $header');
  print('Category column index: $categoryIndex');
  print('Description column index: $descriptionIndex');

  List<Map<String, dynamic>> parsedData = [];
  for (int i = 1; i < csvData.length; i++) {
    Map<String, dynamic> row = {};
    for (int j = 0; j < header.length; j++) {
      row[header[j]] = csvData[i][j];
    }

    // Check if the category field is present
    if (categoryIndex == -1) {
      // Infer category from the description
      String description = row['Description']?.toString().toLowerCase() ?? '';
      String inferredCategory = 'Uncategorized'; // Default category

      for (String keyword in keywordCategoryMap.keys) {
        if (description.contains(keyword)) {
          inferredCategory = keywordCategoryMap[keyword] ?? 'Uncategorized';

          break; // Stop after the first match
        }
      }

      row['Category'] = inferredCategory;
    }

    parsedData.add(row);
  }

  // Debugging: Print parsed data
  print('Parsed CSV Data with inferred categories:');
  print(parsedData);

  return parsedData;
}


// 

Future<List<List<dynamic>>> readCsvFile(String path) async {
  // Open the file and read the raw bytes
  final input = File(path).openRead();

  // Debugging: Print a message when starting to read the file
  print('Reading CSV file from path: $path');

  // Convert the raw bytes into a list of CSV rows
  final fields = await input
      .transform(utf8.decoder)  // Decode the bytes as UTF-8
      .transform(CsvToListConverter(eol: '\n'))  // Force line breaks to '\n'
      .toList();

  // Debugging: Print the raw parsed CSV data before any processing
  print('Raw parsed CSV data:');
  print(fields);

  // Clean up each value by trimming spaces for each field
  // We manually remove extra spaces after each comma
  for (int i = 0; i < fields.length; i++) {
    fields[i] = fields[i].map((field) {
      if (field is String) {
        // Strip out leading and trailing spaces, and any extra internal spaces
        return field.replaceAll(RegExp(r'\s+'), ' ').trim();
      }
      return field; // If it's not a String, we leave it unchanged
    }).toList();
  }

  // Debugging: Print the data after manual cleanup
  print('Parsed CSV data after removing extra spaces:');
  print(fields);

  return fields;
}


Map<String, double> analyzeExpenses(List<Map<String, dynamic>> csvData) {
  Map<String, double> categoryTotals = {};

  for (int i = 0; i < csvData.length; i++) {
    try {
      // Extract necessary fields
      String type = csvData[i]['Type']?.toString().trim() ?? '';
      String category = csvData[i]['Category']?.toString().trim() ?? 'Uncategorized';
      String amountString = csvData[i]['Amount']?.toString().trim() ?? '0';

      // Exclude rows where the type is 'Payment'
      if (type.toLowerCase() == 'payment') {
        print('Skipping row $i: Type is Payment');
        continue;
      }

      // Convert the amount to a double and take its absolute value
      double amount = double.tryParse(amountString) ?? 0.0;
      amount = amount.abs();

      // Add the amount to the corresponding category
      if (amount != 0) {
        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
      } else {
        print('Skipping row $i: Invalid or zero amount');
      }
    } catch (e) {
      print('Error processing row $i: ${csvData[i]} - Exception: $e');
    }
  }

  // Debugging: Print analysis results
  print('Analysis Results:');
  categoryTotals.forEach((key, value) {
    print('$key: \$${value.toStringAsFixed(2)}');
  });

  return categoryTotals;
}

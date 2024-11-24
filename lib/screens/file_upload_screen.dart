import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../utils/csv_utils.dart';
import '../widgets/budget_bar_chart.dart';


class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  _FileUploadScreenState createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  String? filePath;
  Map<String, double>? analysisResult;

  Future<void> pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );

  if (result != null && result.files.single.path != null) {
    setState(() {
      filePath = result.files.single.path;
    });

    try {
      // Read and print CSV data for verification
      // List<List<dynamic>> csvData = await readCsvFile(filePath!);
      // print('Parsed CSV Data: $csvData');

      // Call processCsvFile to parse the CSV
        List<Map<String, dynamic>> csvData = await processCsvFile(filePath!);
        print('Parsed CSV Data: $csvData');

      // Perform analysis
      Map<String, double> analysis = analyzeExpenses(csvData);
      setState(() {
        analysisResult = analysis;
      });
    } catch (e) {
      print('Error reading or analyzing CSV file: $e');
    }
  }
  }

  Future<void> pickAndProcessFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      try {
        // Process the CSV and analyze expenses
        List<Map<String, dynamic>> data = await processCsvFile(filePath);
        Map<String, double> analysis = analyzeExpenses(data);
        setState(() {
          analysisResult = analysis;
        });
      } catch (e) {
        print('Error processing file: $e');
      }
    } else {
      print('No file selected');
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Credit Card Gut Check'),
      backgroundColor: Colors.transparent, // Transparent background
      elevation: 4, // No shadow for a flat look
      iconTheme: IconThemeData(color: Colors.blue), // Icon color (e.g., back button)
      titleTextStyle: TextStyle(
        color: const Color.fromARGB(255, 104, 107, 110), // Text color for the title
        fontSize: 20, // Font size for the title
        fontWeight: FontWeight.w700, // Lighter font weight for minimalism
      ),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: pickAndProcessFile,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.blue, padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), 
              backgroundColor: Colors.transparent, // Text color
              side: BorderSide(color: Colors.blue), // Border color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Rounded corners
              ),
              elevation: 0, // Remove elevation for flat look
            ),
            child: const Text('Pick CSV File'),
          ),
          if (filePath != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Selected file: $filePath'),
            ),
          if (analysisResult != null)
            Expanded( // Ensures the chart gets appropriate space
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: BudgetBarChart(data: analysisResult!),
              ),
            ),
        ],
      ),
    ),
  );
}


  void showAnalysis(BuildContext context, Map<String, double> analysis) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Budget Analysis'),
          content: SingleChildScrollView(
            child: Column(
              children: analysis.entries
                  .map((entry) => Text('${entry.key}: \$${entry.value.toStringAsFixed(2)}'))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

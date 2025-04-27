import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../data/services/fallback_provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  bool _isLoading = false;
  
  // Placeholder method to make main.dart happy
  void capturePhoto() {
    // Just show a message during testing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera functionality is disabled during connection testing'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Alternatively, run the connection test when capture is attempted
    // testVMConnection();
  }

  // Test function to check VM connectivity
  void testVMConnection() async {
    setState(() {
      _isLoading = true;
    });
    
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Testing VM connection...'),
        duration: Duration(seconds: 1),
      ),
    );
    
    final provider = FallbackProvider();
    
    try {
      // Test the connection
      final result = await provider.testConnection();
      
      // Show success message with the response
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection successful!\nResponse: ${result.toString().substring(0, min(100, result.toString().length))}...'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );
      
      print('Full response: $result');
      
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection failed: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper function for string truncation
  int min(int a, int b) => a < b ? a : b;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryBeige,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'VM Connection Test',
          style: TextStyle(
            color: AppTheme.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Info text
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Test the connection to your VM and OpenAI',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // VM configuration display
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'VM Configuration',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Text('VM IP: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('35.201.20.109'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Text('Port: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('3000 (Node.js server)'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Text('Endpoint: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('/api/openai-proxy'),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Test button
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: testVMConnection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.cloud_sync),
                        SizedBox(width: 12),
                        Text(
                          'Test VM Connection',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
            
            const SizedBox(height: 20),
            
            // Additional info text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'This test will send a simple question to your VM, which should forward it to OpenAI and return the response.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
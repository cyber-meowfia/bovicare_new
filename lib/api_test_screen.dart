import 'package:flutter/material.dart';
import 'bovicare_api_service.dart';
import 'models/milk_prediction_request.dart';
import 'models/milk_prediction_response.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final api = BoviCareApiService();
  bool loading = false;
  bool isServerOnline = false;
  String result = 'Tap the button below to test the Python FastAPI service.';
  MilkPredictionResponse? responseData;

  // Default sample values from dataset
  final tempController = TextEditingController(text: '35.38');
  final phController = TextEditingController(text: '6.49');
  final condController = TextEditingController(text: '4.68');
  final sccController = TextEditingController(text: '148');
  final yieldController = TextEditingController(text: '17.3');
  final urlController = TextEditingController(text: 'https://ubxlxbdmtgxcsfqujwsy.supabase.co');

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  Future<void> _checkServer() async {
    api.supabaseUrl = urlController.text.trim();
    final online = await api.checkHealth();
    if (mounted) {
      setState(() {
        isServerOnline = online;
      });
    }
  }

  Future<void> testApi() async {
    setState(() {
      loading = true;
      result = 'Sending milk measurements to inference backend...';
      responseData = null;
    });

    try {
      api.supabaseUrl = urlController.text.trim();
      final request = MilkPredictionRequest(
        milkTemperature: double.tryParse(tempController.text) ?? 35.38,
        milkPh: double.tryParse(phController.text) ?? 6.49,
        milkConductivity: double.tryParse(condController.text) ?? 4.68,
        somaticCellCount: double.tryParse(sccController.text) ?? 148.0,
        milkYield: double.tryParse(yieldController.text) ?? 17.3,
      );

      final response = await api.predict(request);

      setState(() {
        responseData = response;
        isServerOnline = true;
        result = 'Prediction: ${response.prediction} (Confidence: ${(response.confidence * 100).toStringAsFixed(1)}%)';
      });
    } catch (e) {
      setState(() {
        result = 'Connection note: $e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F4),
      appBar: AppBar(
        title: const Text('BoviCare Supabase ML API', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _checkServer,
            tooltip: 'Check Server Health',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8ECE4)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                       shape: BoxShape.circle,
                      color: isServerOnline ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isServerOnline
                          ? 'Supabase ML Backend Active (ubxlxbdmtgxcsfqujwsy.supabase.co)'
                          : 'Connecting to Supabase Cloud ML...',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isServerOnline ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Base URL input
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Supabase Project URL',
                hintText: 'https://ubxlxbdmtgxcsfqujwsy.supabase.co',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (_) => _checkServer(),
            ),
            const SizedBox(height: 16),

            const Text(
              'Sensor Milk Measurements',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1B2E21)),
            ),
            const SizedBox(height: 10),

            _inputRow('Milk Temperature (°C)', tempController),
            _inputRow('Milk pH', phController),
            _inputRow('Conductivity (mS/cm)', condController),
            _inputRow('Somatic Cell Count (cells/ml)', sccController),
            _inputRow('Milk Yield (L)', yieldController),

            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: loading ? null : testApi,
                icon: const Icon(Icons.analytics_rounded),
                label: Text(loading ? 'Running Inference...' : 'Predict via Supabase ML'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF176B45),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Results Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8ECE4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Result & Diagnosis Protocol',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF20352A)),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    result,
                    style: TextStyle(
                      fontSize: 13,
                      color: responseData != null
                          ? (responseData!.riskTier == 'High' ? const Color(0xFFC62828) : const Color(0xFF2E7D32))
                          : const Color(0xFF6B7B6D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (responseData != null) ...[
                    const SizedBox(height: 10),
                    Text('Recommendation: ${responseData!.recommendation}', style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('Source: ${responseData!.source}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

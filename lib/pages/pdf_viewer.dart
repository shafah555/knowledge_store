import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;

class PDFViewerPage extends StatefulWidget {
  final String assetPath;
  final String title;
  final bool isNetwork;
  
  const PDFViewerPage({
    super.key, 
    required this.assetPath, 
    required this.title,
    this.isNetwork = false,
  });

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _finalUrl = '';

  @override
  void initState() {
    super.initState();
    if (widget.isNetwork) {
      _validateAndLoadUrl();
    } else {
      _isLoading = false;
      _finalUrl = widget.assetPath;
    }
  }

  Future<void> _validateAndLoadUrl() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // For Google Drive links, try to get the direct download URL
      String url = widget.assetPath;
      if (url.contains('drive.google.com')) {
        url = _getDirectDriveLink(url);
      }

      // Test if the URL returns a PDF
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';
        if (contentType.contains('application/pdf') || 
            contentType.contains('binary/octet-stream') ||
            url.contains('.pdf') ||
            url.contains('drive.google.com/uc?export=download')) {
          setState(() {
            _finalUrl = url;
            _isLoading = false;
          });
        } else {
          // If it's not a PDF, show error
          setState(() {
            _hasError = true;
            _errorMessage = 'The URL does not point to a valid PDF file. Content-Type: $contentType';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Please wait...';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = '';
        _isLoading = false;
      });
    }
  }

  String _getDirectDriveLink(String url) {
    final regExp = RegExp(r'd/([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(url);
    if (match != null) {
      final fileId = match.group(1);
      return 'https://drive.google.com/uc?export=download&id=$fileId';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading PDF...'),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const SizedBox(height: 16),
              const Text(
                'Loading pdf...',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                  });
                  _validateAndLoadUrl();
                },
                child: const Text('please wait'),
              ),
              const SizedBox(height: 16),
              if (widget.assetPath.contains('drive.google.com'))
                const Text(
                  '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return widget.isNetwork
        ? SfPdfViewer.network(
            _finalUrl,
            onDocumentLoadFailed: (details) {
              setState(() {
                _hasError = true;
                _errorMessage = 'Failed to load PDF: ${details.description}';
              });
            },
            onDocumentLoaded: (details) {
              // PDF loaded successfully
            },
          )
        : SfPdfViewer.asset(_finalUrl);
  }
}

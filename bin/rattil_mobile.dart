import 'dart:async';
import 'dart:io';
import 'package:mcp_server/mcp_server.dart';

void main(List<String> args) async {
  // MCP STDIO Mode (for LLM integration)
  if (args.contains('--mcp-stdio-mode')) {
    await startMcpServer(mode: 'stdio');
  } else {
    // SSE Mode (for web browser testing)
    int port = 8999;
    await startMcpServer(mode: 'sse', port: port);
  }
}

Future<void> startMcpServer({required String mode, int port = 8080}) async {
  try {
    // Create and start server with unified API
    final serverResult = await McpServer.createAndStart(
      config: McpServer.simpleConfig(
        name: 'Rattil Mobile MCP Server',
        version: '1.0.0',
        enableDebugLogging: true,
      ),
      transportConfig: mode == 'stdio'
          ? TransportConfig.stdio()
          : TransportConfig.sse(
              endpoint: '/sse',
              messagesEndpoint: '/message',
              host: 'localhost',
              port: port,
            ),
    );

    await serverResult.fold(
      (server) async {
        // Register tools
        _registerTools(server);

        // Set up transport closure handling
        server.onDisconnect.listen((_) {
          print('Client disconnected, shutting down.');
          exit(0);
        });

        // Send initial log message
        server.sendLog(McpLogLevel.info, 'Rattil Mobile MCP Server started successfully');

        if (mode == 'sse') {
          print('SSE Server is running on:');
          print('- SSE endpoint:     http://localhost:$port/sse');
          print('- Message endpoint: http://localhost:$port/message');
          print('Press Ctrl+C to stop the server');
        } else {
          print('STDIO Server initialized and connected to transport');
        }

        // Keep server running
        await Future.delayed(const Duration(hours: 24));
      },
      (error) {
        print('Error initializing MCP server: $error');
        exit(1);
      },
    );
  } catch (e, stackTrace) {
    print('Error initializing MCP server: $e');
    print(stackTrace.toString());
    exit(1);
  }
}

void _registerTools(Server server) {
  // Echo tool
  server.addTool(
    name: 'echo',
    description: 'Echo back the input text',
    inputSchema: {
      'type': 'object',
      'properties': {
        'text': {
          'type': 'string',
          'description': 'Text to echo back'
        }
      },
      'required': ['text']
    },
    handler: (args) async {
      final text = args['text'] as String;
      return CallToolResult(content: [TextContent(text: 'Echo: $text')]);
    },
  );

  // Mobile app info tool
  server.addTool(
    name: 'getMobileInfo',
    description: 'Get mobile app information',
    inputSchema: {
      'type': 'object',
      'properties': {},
      'required': []
    },
    handler: (args) async {
      final info = {
        'app_name': 'Rattil Mobile',
        'version': '1.0.0',
        'platform': Platform.operatingSystem,
        'dart_version': Platform.version,
      };
      return CallToolResult(content: [TextContent(text: info.toString())]);
    },
  );
}

import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
// Mark: flutter/material 與 vector_math/vector_math_64 的 Colors 會互相衝突
import 'package:vector_math/vector_math_64.dart' hide Colors;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root cof your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ARKitController arkitController;
  double positionYstake = 0;
  List<ARKitNode> arKitNodeList = [];

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('ARKit in Flutter')),
        body: ARKitSceneView(onARKitViewCreated: onARKitViewCreated),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () => _addTextARKitNode('addText'),
              child: const Text('add text'),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () => _addARKitNode(),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              child: const Icon(Icons.remove),
              onPressed: () => _removeARKitNode(),
            ),
          ],
        ),
      );

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    arkitController.onARTap = (hits) => _addTextARKitNode('onARTap');
    arkitController.onNodeTap = (nodes) => _addTextARKitNode('onNodeTap');
  }

  void _addARKitNode() {
    if (arKitNodeList.isEmpty) {
      final node = ARKitNode(
          geometry: ARKitSphere(radius: 0.05),
          // Mark: - Vector3.z 如果為 0，會因為距離太近而看不到物件
          position: Vector3(0, positionYstake, -0.5));
      arKitNodeList.add(node);
      arkitController.add(node);
    } else {
      final lastARKitNode = arKitNodeList.last;
      final node = ARKitNode(
          geometry: ARKitSphere(radius: 0.05),
          position: Vector3(0, lastARKitNode.position.y + 0.1, -0.5));
      arKitNodeList.add(node);
      arkitController.add(node);
    }
  }

  void _removeARKitNode() {
    if (arKitNodeList.isEmpty) {
      return;
    }
    arkitController.remove(arKitNodeList.last.name);
    arKitNodeList.removeLast();
  }

  void _addTextARKitNode(String content) {
    final text = ARKitText(text: content, extrusionDepth: 0);
    final node = ARKitNode(
      geometry: text,
      position: Vector3(0, 0, -0.4),
      scale: Vector3(0.01, 0.01, 0.01),
    );
    arkitController.add(node);
    showDialog<void>(
      context: context,
      builder: (BuildContext context) =>
          AlertDialog(content: Text('onNodeTap on $content')),
    );
  }
}

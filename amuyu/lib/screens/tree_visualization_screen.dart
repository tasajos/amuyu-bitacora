// lib/screens/tree_visualization_screen.dart
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:amuyu/models/person_model.dart';

class TreeVisualizationScreen extends StatefulWidget {
  final List<Person> allPeople;

  const TreeVisualizationScreen({super.key, required this.allPeople});

  @override
  State<TreeVisualizationScreen> createState() => _TreeVisualizationScreenState();
}

class _TreeVisualizationScreenState extends State<TreeVisualizationScreen> {
  final Graph graph = Graph();
  late SugiyamaConfiguration builder;

  @override
  void initState() {
    super.initState();
    
    _buildGraph();

    builder = SugiyamaConfiguration()
      ..nodeSeparation = (30)
      ..levelSeparation = (50)
      ..orientation = (SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM);
  }

  void _buildGraph() {
    final Map<String, Node> personNodeMap = {};

    for (var person in widget.allPeople) {
      final node = Node.Id(person.id);
      personNodeMap[person.id] = node;
      graph.addNode(node);
    }

    for (var person in widget.allPeople) {
      final personNode = personNodeMap[person.id]!;
      for (var relationship in person.relationships) {
        final relatedNode = personNodeMap[relationship.personId];
        if (relatedNode != null) {
          // --- ESTA ES LA LÓGICA CORREGIDA ---
          // Solo dibujamos las líneas para relaciones jerárquicas.
          // La relación de cónyuge se ignora aquí para no romper el layout.
          switch (relationship.type) {
            case RelationshipType.hijo:
            case RelationshipType.hija:
              graph.addEdge(relatedNode, personNode); // Padre -> Hijo
              break;
            case RelationshipType.nieto:
            case RelationshipType.nieta:
              graph.addEdge(relatedNode, personNode); // Abuelo -> Nieto
              break;
            case RelationshipType.bisnieto:
            case RelationshipType.bisnieta:
              graph.addEdge(relatedNode, personNode); // Bisabuelo -> Bisnieto
              break;
            default:
              // No se dibuja ninguna otra línea.
              break;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualización del Árbol'),
      ),
      body: InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(100),
        minScale: 0.1,
        maxScale: 1.5,
        child: GraphView(
          graph: graph,
          algorithm: SugiyamaAlgorithm(builder),
          paint: Paint()
            ..color = Colors.teal
            ..strokeWidth = 1.5
            ..style = PaintingStyle.stroke,
          builder: (Node node) {
            String personId = node.key!.value as String;
            final person = widget.allPeople.firstWhere((p) => p.id == personId);
            return _buildPersonNode(person);
          },
        ),
      ),
    );
  }
  
  // El widget del nodo muestra la información del cónyuge en texto.
  Widget _buildPersonNode(Person person) {
    String? spouseName;
    try {
      final spouseRelationship = person.relationships.firstWhere((rel) => rel.type == RelationshipType.conyuge);
      final spouse = widget.allPeople.firstWhere((p) => p.id == spouseRelationship.personId);
      spouseName = spouse.name;
    } catch (e) {
      spouseName = null;
    }

    return Container(
      width: 150,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: person.isAlive ? Colors.white : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.teal.shade200, width: 2),
         boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            person.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          if (spouseName != null)
            Text(
              "($spouseName)",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}
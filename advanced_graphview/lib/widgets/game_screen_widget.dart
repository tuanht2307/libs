import 'dart:math';

import 'package:advanced_graphview/advanced_graphview/advanced_graphview_controller.dart';
import 'package:advanced_graphview/graph_node.dart';
import 'package:advanced_graphview/widgets/node_module_image_renderer_widget.dart';
import 'package:advanced_graphview/world_map.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../advanced_graphview/advanced_graphview_flame.dart';
import '../graph_data_structure.dart';
import '../image_loader.dart';

/// [AdvancedGraphviewWidget] will create tree structured nodes
class AdvancedGraphviewWidget<T extends GraphNode> extends StatefulWidget {
  /// [nodeSize] represents the size of the node

  // final GraphNode head;
  final double nodeSize;

  /// [nodeSize] represents padding between the nodes
  final double nodePadding;

  /// [nodeSize] this is the Head of the tree(first parent of the tree)
  final GraphNode graphNode;

  /// [isDebug] will show the wireframe
  final bool isDebug;

  /// [isDebug] decide the paint needed to draw the line
  final Paint? Function(T lineFrom, T lineTwo)? onDrawLine;

  /// [builder] pass the widget that has to be rendered in tree children
  /// note : Only static widget can be passed animating or widget which keeps
  /// changing its state will not be rendered.
  final Widget Function(T graphNode) builder;

  /// [advancedGraphviewController] will give you the control to handle state
  final AdvancedGraphviewController? advancedGraphviewController;

  /// set the background color of the canvas
  final Color? backgroundColor;

  /// pixel ratio sets the widget pixel ratio
  final double pixelRatio;

  /// action when you tap a node
  final Function(GraphNode)? onNodeTap;
  final VoidCallback? onLoadCompleted;

  /// [AdvancedGraphviewWidget] will create tree structured nodes
  const AdvancedGraphviewWidget({
    super.key,
    required this.nodePadding,
    required this.nodeSize,
    required this.graphNode,
    required this.builder,
    this.isDebug = false,
    this.advancedGraphviewController,
    this.onDrawLine,
    this.backgroundColor,
    this.pixelRatio = 1,
    this.onNodeTap,
    this.onLoadCompleted,
  });
  static late BuildContext context;
  @override
  State<AdvancedGraphviewWidget> createState() =>
      _AdvancedGraphviewWidgetState();
}

class _AdvancedGraphviewWidgetState extends State<AdvancedGraphviewWidget> {
  bool loader = true;
  late FlameGame myGame;
  late GraphDataStructure graphDataStructure;
  late int length;
  int countLoading = 0; //false
  @override
  void initState() {
    super.initState();
    AdvancedGraphviewWidget.context = context;
    startLoadingImage();
  }

  /// The image will start loading once loaded it starts caching the data
  void startLoadingImage() async {
    await loadImage();
    graphDataStructure = GraphDataStructure(graphNode: widget.graphNode);
    widget.advancedGraphviewController!.cachedGraphNode = widget.graphNode;

    // if (widget.advancedGraphviewController?.cachedGraphNode != null) {
    //   print('$runtimeType,advancedGraphviewController_0.');
    //   graphDataStructure = GraphDataStructure(
    //       graphNode: widget.advancedGraphviewController!.cachedGraphNode!);
    // } else {
    //   print('$runtimeType,advancedGraphviewController_1.');
    //   graphDataStructure = GraphDataStructure(graphNode: widget.graphNode);
    //   if (widget.advancedGraphviewController != null) {
    //     widget.advancedGraphviewController!.cachedGraphNode = widget.graphNode;
    //   }
    // }

    Set<String> items = graphDataStructure.getListOfItems();
    length = sqrt(items.length).ceil();
    CanvasMap.size = (widget.nodeSize + (widget.nodePadding * 2)) * length;
    if (widget.advancedGraphviewController != null) {
      widget.advancedGraphviewController?.maxScrollExtent = CanvasMap.size;
    }
    setState(() {
      loader = false;
      countLoading = 1; //true
    });
    print('$runtimeType, startLoadingImage');
    Future.delayed(Duration(milliseconds: 2000), () {
      setState(() {
        countLoading = 2; //false
        widget.onLoadCompleted?.call();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loader) return const SizedBox();
    return Stack(
      children: [
        if (countLoading == 1)
          ...graphDataStructure.getList().map(
            (e) {
              return NodeModuleImageRenderer(
                graphDataStructure: graphDataStructure,
                graphNode: e,
                nodeSize: Vector2(widget.nodeSize, widget.nodeSize),
                pixelRatio: widget.pixelRatio,
                child: widget.builder(e),
              );
              // return SizedBox();
            },
          ),

        GameWidget(
          game: AdvancedGraphviewFlame(
            nodePadding: widget.nodePadding,
            graphDataStructure: graphDataStructure,
            nodeSize: widget.nodeSize,
            context: context,
            isDebug: widget.isDebug,
            onDrawLine: widget.onDrawLine,
            flameBackgroundColor: widget.backgroundColor,
            advancedGraphviewController: widget.advancedGraphviewController,
            pixelRatio: widget.pixelRatio,
            onNodeTap: widget.onNodeTap,
          ),
        ),

        //const PickerScreen(pickerScreenDataFirst: ,)
      ],
    );
  }
}

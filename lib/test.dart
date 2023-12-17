// import 'dart:developer';

// import 'package:enhance_stepper/enhance_stepper.dart';
// import 'package:flutter/material.dart';
// import 'package:tuple/tuple.dart';

// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key? key, required this.title}) : super(key: key);

//   final String title;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int groupValue = 0;

//   StepperType _type = StepperType.vertical;

//   List<Tuple2> tuples = [
//     Tuple2(
//       Icons.directions_bike,
//       StepState.indexed,
//     ),
//     Tuple2(
//       Icons.directions_bus,
//       StepState.complete,
//     ),
//     Tuple2(
//       Icons.directions_railway,
//       StepState.complete,
//     ),
//     Tuple2(
//       Icons.directions_boat,
//       StepState.disabled,
//     ),
//     Tuple2(
//       Icons.directions_car,
//       StepState.error,
//     ),
//   ];

//   int _index = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//         actions: [
//           TextButton(
//               onPressed: () {
//                 log("change");
//                 setState(() {
//                   _type = _type == StepperType.vertical
//                       ? StepperType.horizontal
//                       : StepperType.vertical;
//                 });
//               },
//               child: Icon(
//                 Icons.change_circle_outlined,
//                 color: Colors.white,
//               )),
//         ],
//       ),
//       body: buildStepperCustom(context),
//     );
//   }

//   void go(int index) {
//     if (index == -1 && _index <= 0) {
//       log("it's first Step!");
//       return;
//     }

//     if (index == 1 && _index >= tuples.length - 1) {
//       log("it's last Step!");
//       return;
//     }

//     setState(() {
//       _index += index;
//     });
//   }

//   Widget buildStepperCustom(BuildContext context) {
//     return EnhanceStepper(
//         stepIconSize: 70,
//         type: _type,
//         horizontalTitlePosition: HorizontalTitlePosition.bottom,
//         horizontalLinePosition: HorizontalLinePosition.top,
//         currentStep: _index,
//         physics: BouncingScrollPhysics(),
//         steps: tuples
//             .asMap()
//             .entries
//             .map((e) => EnhanceStep(
//                   icon: Icon(
//                     e.value.item1,
//                     color: _index == e.key ? Colors.blue : Colors.grey,
//                     size: 30,
//                   ),
//                   state: StepState.values[tuples.indexOf(e.value)],
//                   isActive: _index == tuples.indexOf(e.value),
//                   title: Text("step ${tuples.indexOf(e.value)}"),
//                   subtitle: Text(
//                     "${e.value.item2.toString().split(".").last}",
//                   ),
//                   content: Text("Content for Step ${tuples.indexOf(e.value)}"),
//                 ))
//             .toList(),
//         onStepCancel: () {
//           go(-1);
//         },
//         onStepContinue: () {
//           go(1);
//           tuples[_index - 1] = tuples[_index - 1].withItem2(StepState.complete);
//           setState(() {});
//         },
//         onStepTapped: (index) {
//           log(index.toString());
//           setState(() {
//             _index = index;
//           });
//         },
//         controlsBuilder:
//             (BuildContext context, ControlsDetails controlsDetails) {
//           return Row(
//             children: [
//               SizedBox(
//                 height: 30,
//               ),
//               ElevatedButton(
//                 onPressed: controlsDetails.onStepContinue,
//                 child: const Text("Next"),
//               ),
//               SizedBox(
//                 width: 8,
//               ),
//               TextButton(
//                 onPressed: controlsDetails.onStepCancel,
//                 child: Text("Back"),
//               ),
//             ],
//           );
//         });
//   }
// }

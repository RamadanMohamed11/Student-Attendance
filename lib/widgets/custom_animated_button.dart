// import 'package:flutter/material.dart';
// import 'package:progress_state_button/progress_button.dart';
// import 'package:progress_state_button/iconed_button.dart';

// class CustomAnimatedButton extends StatefulWidget {
//   const CustomAnimatedButton({super.key});

//   @override
//   State<CustomAnimatedButton> createState() => _CustomAnimatedButtonState();
// }

// class _CustomAnimatedButtonState extends State<CustomAnimatedButton> {

//   void onPressedIconWithText() {
//     switch(stateTextWithIcon)
//     {
//       case ButtonState.idle:
//       stateTextWithIcon = ButtonState.loading;
      
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//         child: ProgressButton.icon(iconedButtons: const {
//       ButtonState.idle: IconedButton(
//         color: Colors.red,
//         text: 'Add Subject',
//         icon: Icon(
//           Icons.add,
//           color: Colors.white,
//         ),
//       ),
//       ButtonState.loading: IconedButton(
//         color: Colors.blue,
//         text: 'Loading',
//         icon: Icon(
//           Icons.refresh,
//           color: Colors.white,
//         ),
//       ),
//       ButtonState.fail: IconedButton(
//         color: Colors.red,
//         text: 'Subject does not exist',
//         icon: Icon(
//           Icons.cancel,
//           color: Colors.white,
//         ),
//       ),
//       ButtonState.success: IconedButton(
//         color: Colors.green,
//         text: 'Success',
//         icon: Icon(
//           Icons.done,
//           color: Colors.white,
//         ),
//       ),
//     }, state: stateOnlyText, onPressed: () {


//     }));
//   }
// }

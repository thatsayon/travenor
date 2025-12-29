// import 'package:flutter/material.dart';

// class OnboardingItem extends StatelessWidget {
//   final String image;
//   final String title;
//   final String highlight;
//   final String description;

//   const OnboardingItem({
//     super.key,
//     required this.image,
//     required this.title,
//     required this.highlight,
//     required this.description,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           flex: 6,
//           child: ClipRRect(
//             borderRadius: const BorderRadius.vertical(
//               bottom: Radius.circular(28),
//             ),
//             child: Image.asset(
//               image,
//               fit: BoxFit.cover,
//               width: double.infinity,
//             ),
//           ),
//         ),
//         const SizedBox(height: 108),

//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: RichText(
//             textAlign: TextAlign.center,
//             text: TextSpan(
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.black,
//               ),
//               children: [
//                 TextSpan(text: '$title '),
//                 TextSpan(
//                   text: highlight,
//                   style: const TextStyle(color: Color(0xFF0A6CFF)),
//                 ),
//               ],
//             ),
//           ),
//         ),

//         const SizedBox(height: 12),

//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 32),
//           child: Text(
//             description,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Colors.grey,
//               height: 1.5,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';

class OnboardingItem extends StatelessWidget {
  final String image;
  final String title;
  final String highlight;
  final String description;

  const OnboardingItem({
    super.key,
    required this.image,
    required this.title,
    required this.highlight,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(28),
            ),
            child: Image.asset(
              image,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
        
        const Spacer(flex: 1),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
                height: 1.3,
              ),
              children: [
                TextSpan(text: '$title '),
                TextSpan(
                  text: highlight,
                  style: const TextStyle(
                    color: Color(0xFF0A6CFF),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        
        const Spacer(flex: 1),
      ],
    );
  }
}
// import 'package:flutter/material.dart';
//
// class PopupMenuWidget extends StatelessWidget {
//   final Future<void> Function() onShare;
//   final Future<void> Function() onSave;
//   final Future<void> Function() onEdit;
//   final Future<void> Function() onDelete;
//
//   const PopupMenuWidget({
//     required this.onShare,
//     required this.onSave,
//     required this.onEdit,
//     required this.onDelete,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return PopupMenuButton<String>(
//       onSelected: (value) async {
//         switch (value) {
//           case 'share':
//             await onShare();
//             break;
//           case 'save':
//             await onSave();
//             break;
//           case 'edit':
//             await onEdit();
//             break;
//           case 'delete':
//             await onDelete();
//             break;
//         }
//       },
//       itemBuilder: (context) => [
//         const PopupMenuItem(value: 'share', child: Text('Share')),
//         const PopupMenuItem(value: 'save', child: Text('Save')),
//         const PopupMenuItem(value: 'edit', child: Text('Edit')),
//         const PopupMenuItem(value: 'delete', child: Text('Delete')),
//       ],
//     );
//   }
// }

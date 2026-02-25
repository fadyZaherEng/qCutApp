import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:q_cut/core/utils/widgets/custom_app_bar.dart';
import 'package:q_cut/modules/customer/features/settings/chat_feature/chat_with_us_view_body.dart';
import 'package:q_cut/modules/customer/features/settings/chat_feature/message_input.dart';

class ChatWithUsView extends StatefulWidget {
  const ChatWithUsView({super.key});

  @override
  State<ChatWithUsView> createState() => _ChatWithUsViewState();
}

class _ChatWithUsViewState extends State<ChatWithUsView> {
  final _chatBodyKey = GlobalKey<ChatWithUsViewBodyState>();
  final ImagePicker _picker = ImagePicker();

  void _handleSendMessage(String message) {
    _chatBodyKey.currentState?.sendMessage(message);
  }

  Future<void> _handleImageSelection() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      // Send image to chat controller
      _chatBodyKey.currentState?.sendImage(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Chat with us".tr),
      body: ChatWithUsViewBody(key: _chatBodyKey),
      bottomNavigationBar: SingleChildScrollView(
        padding:
            //check if keyboard is open and add extra padding to avoid being covered by keyboard
            keyboardIsOpen(context)
                ? EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom-10)
                : EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 30),
        child: MessageInput(
          onSendMessage: _handleSendMessage,
          onCameraTap: _handleImageSelection,
        ),
      ),
    );
  }

  bool keyboardIsOpen(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'package:q_cut/modules/customer/features/settings/chat_feature/models/message_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatController extends GetxController {
  final NetworkAPICall _apiCall = NetworkAPICall();
  RxList<MessageModel> messages = <MessageModel>[].obs;
  RxBool isLoading = true.obs;

  late IO.Socket socket;

  // Add new loading state for sending messages
  final RxBool isSending = false.obs;

  // Add pagination variables
  final int _limit = 20;
  final RxInt _currentPage = 1.obs;
  RxBool hasMoreMessages = true.obs;
  RxBool isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    connectSocket();
    fetchChatData();
  }

  Map<String, dynamic> _safeParseMessage(dynamic data) {
    try {
      if (data is String) {
        return json.decode(data);
      } else if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      throw FormatException('Invalid message format');
    } catch (e) {
      print('Error parsing message: $e');
      throw FormatException('Failed to parse message data');
    }
  }

  Map<String, dynamic> _buildMessageData(
    String message, {
    String mediaType = 'text',
    String? mediaUrl,
    bool adminReply = false,
    String? createdAt,
  }) {
    return {
      "message": message.trim(),
      "mediaType": mediaType,
      "mediaUrl": mediaType == 'text' ? '' : (mediaUrl ?? ''),
      "adminReply": adminReply,
      "createdAt": createdAt ?? DateTime.now().toIso8601String(),
      "client": {"userType": "user", "id": ""} // Add proper client structure
    };
  }

  void connectSocket() {
    print("Connecting to socket...");
    socket = IO.io(
      'ws://QcutEnv-env.eba-iynfw5mb.us-east-1.elasticbeanstalk.com',
      //   'ws://qcut-env.eba-turffyr8.us-east-1.elasticbeanstalk.com',
        <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': true,
          'extraHeaders': {'Authorization': '123 $token'}
        });

    socket.connect();

    socket.onConnect((_) {
      debugPrint('Socket.IO Connected successfully');
      print('Socket instance: ${socket.id}');
    });

    // Enhanced message receiving handler
    socket.on('receiveMessage', (data) {
      try {
        print('Received new message: $data');
        final messageData = _safeParseMessage(data);

        // Ensure consistent data structure
        final formattedData = {
          'message': messageData['message'],
          'mediaType': messageData['mediaType'],
          'mediaUrl': messageData['mediaUrl'],
          'adminReply': messageData['adminReply'],
          'client': messageData['client'],
          'name': messageData['name'],
          'profilePicture': messageData['profilePicture'],
          'createdAt':
              messageData['createdAt'] ?? DateTime.now().toIso8601String(),
        };

        final message = MessageModel.fromJson(formattedData);
        messages.insert(0, message);
      } catch (e) {
        print('Error processing received message: $e');
      }
    });

    socket.on('adminSendMessage', (data) {
      print('Received admin message: $data');
      final message = MessageModel.fromJson(data);
      messages.add(message);
    });

    socket.on('messageSent', (data) {
      try {
        final Map<String, dynamic> messageData;
        if (data is String) {
          messageData = json.decode(data);
        } else if (data is Map) {
          messageData = Map<String, dynamic>.from(data);
        } else {
          return;
        }

        if (messageData['client'] != null) {
          messageData['client'] = messageData['client'].toString();
        }

        print('Message sent confirmation: $messageData');
      } catch (e) {
        print('Error processing messageSent: $e');
      }
    });

    socket.on('errorMessage', (error) {
      try {
        final errorData = _safeParseMessage(error);
        final errorMessage = errorData['message'] ?? 'Unknown error occurred';
        ShowToast.showError(message: errorMessage);
      } catch (e) {
        ShowToast.showError(message: 'Error processing message');
      }
    });

    socket.on('sendMessage', (data) {
      try {
        print('Raw message data received: $data');
        final messageData = data is String ? json.decode(data) : data;

        if (messageData is! Map) {
          print('Invalid message format received');
          return;
        }

        final Map<String, dynamic> formattedData = {
          'message': messageData['message'] ?? '',
          'mediaType': messageData['mediaType'] ?? 'text',
          'mediaUrl': messageData['mediaUrl'] ?? '',
          'adminReply': messageData['adminReply'] ?? false,
          'createdAt':
              messageData['createdAt'] ?? DateTime.now().toIso8601String(),
          'client': messageData['client'] ?? {"userType": "user", "id": ""}
        };

        messages.add(MessageModel.fromJson(formattedData));
      } catch (e) {
        print('Error processing message: $e');
      }
    });

    socket.onConnectError((error) {
      print('Socket Connect Error: $error');
    });

    socket.onDisconnect((_) {
      print('Socket.IO Disconnected. Reason: ${socket.disconnected}');
    });

    socket.onError((error) {
      print('Socket Error Details:');
      print('Error: $error');
      print('Connection state: ${socket.connected}');
    });
  }

  Future<void> sendMessage(String message,
      {String mediaType = 'text', String? mediaUrl}) async {
    if (message.trim().isEmpty) {
      ShowToast.showError(message: 'Message cannot be empty');
      return;
    }

    if (!socket.connected) {
      ShowToast.showError(message: 'No connection. Trying to reconnect...');
      socket.connect();
      return;
    }

    isSending.value = true;
    final currentTime = DateTime.now().toIso8601String();

    try {
      final messageData = _buildMessageData(message,
          mediaType: mediaType, mediaUrl: mediaUrl, createdAt: currentTime);

      // Add message locally first
      messages.insert(0, MessageModel.fromJson(messageData));

      // Emit as raw message
      socket.emit('sendMessage', messageData);

      // API call
      await _apiCall.addData(messageData, '${Variables.baseUrl}messages/send');
      print('Message sent successfully: $messageData');
      print('Current messages count: ${messages.length}');
      print('Current messages: ${messages.map((m) => m.message).toList()}');
    } catch (e) {
      print('Error sending message: $e');
      messages
          .removeWhere((msg) => msg.createdAt.toIso8601String() == currentTime);
      ShowToast.showError(message: 'Failed to send message');
    } finally {
      isSending.value = false;
    }
  }

  Future<void> sendImageMessage(String imagePath) async {
    isSending.value = true;
    final currentTime = DateTime.now().toIso8601String();

    try {
      // Upload image to storage and get URL
      String imageUrl = await _uploadImageToServer(imagePath);

      if (imageUrl.isNotEmpty) {
        // Create message with image
        final messageData = _buildMessageData(
          '', // Empty text or caption can be added later
          mediaType: 'image',
          mediaUrl: imageUrl,
          createdAt: currentTime,
        );

        // Add message locally first
        messages.insert(0, MessageModel.fromJson(messageData));

        // Emit to socket
        socket.emit('sendMessage', messageData);

        // API call
        await _apiCall.addData(
            messageData, '${Variables.baseUrl}messages/send');
      } else {
        ShowToast.showError(message: 'Failed to upload image');
      }
    } catch (e) {
      print('Error sending image message: $e');
      messages
          .removeWhere((msg) => msg.createdAt.toIso8601String() == currentTime);
      ShowToast.showError(message: 'Failed to send image');
    } finally {
      isSending.value = false;
    }
  }

  Future<String> _uploadImageToServer(String imagePath) async {
    try {
      // Create FormData for file upload
      var formData = FormData({
        'file': MultipartFile(File(imagePath), filename: 'image.jpg'),
      });

      // Upload the file
      final response = await _apiCall.uploadFileToPresignedUrl(
        formData as String,
        '${Variables.baseUrl}messages/upload' as List<int>,
        "0",
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['url'] ?? '';
      }
      return '';
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Future<void> retryMessage(MessageModel message) async {
    messages.remove(message);
    await sendMessage(message.message);
  }

  @override
  void onClose() {
    socket.disconnect();
    socket.dispose();
    super.onClose();
  }

  Future<void> fetchChatData({bool loadMore = false}) async {
    if (loadMore) {
      if (!hasMoreMessages.value || isLoadingMore.value) return;
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
      _currentPage.value = 1;
    }

    try {
      final response = await _apiCall.getData(
        '${Variables.baseUrl}messages/my-conversations?page=${_currentPage.value}&limit=$_limit',
      );
      print('Response: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> responseBody = json.decode(response.body);

        // Check if we have more messages
        hasMoreMessages.value = responseBody.length >= _limit;

        if (responseBody.isNotEmpty) {
          final newMessages =
              responseBody.map((json) => MessageModel.fromJson(json)).toList();

          if (loadMore) {
            messages.addAll(newMessages);
            _currentPage.value++;
          } else {
            messages.value = newMessages;
          }
        } else if (!loadMore) {
          messages.value = [];
        }
      }
    } catch (e) {
      print('Error fetching messages: $e');
      if (!loadMore) messages.value = [];
    } finally {
      if (loadMore) {
        isLoadingMore.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  // Method to load more messages
  void loadMoreMessages() {
    fetchChatData(loadMore: true);
  }
}

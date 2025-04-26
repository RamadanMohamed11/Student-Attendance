import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:student_attendance/colors.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  static const String id = 'chat_page';

  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  // Initialize Gemini
  late final Gemini gemini;

  // DashChat users
  final ChatUser _currentUser = ChatUser(id: '1', firstName: 'User');
  final ChatUser _botUser = ChatUser(id: '2', firstName: 'Gemini AI');

  // DashChat messages
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();

    // Initialize Gemini API
    Gemini.init(apiKey: 'AIzaSyDk5p9Kv_Bt029EwLObNdA3uRGy5OodeW8');
    gemini = Gemini.instance;

    // Add welcome message
    _messages.add(
      ChatMessage(
        user: _botUser,
        createdAt: DateTime.now(),
        text: 'Hello! I am your AI assistant. How can I help you today?',
      ),
    );
  }

  Future<void> _sendMessage(ChatMessage message) async {
    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
    });

    try {
      // Send message to Gemini API
      final geminiResponse = await gemini.text(message.text);

      if (mounted) {
        setState(() {
          _isTyping = false;
        });

        if (geminiResponse != null) {
          final responseText = geminiResponse.output ??
              "I'm sorry, I couldn't generate a response. Please try again.";
          setState(() {
            _messages.insert(
              0,
              ChatMessage(
                user: _botUser,
                createdAt: DateTime.now(),
                text: responseText,
              ),
            );
          });
        } else {
          setState(() {
            _messages.insert(
              0,
              ChatMessage(
                user: _botUser,
                createdAt: DateTime.now(),
                text:
                    "I'm sorry, I couldn't generate a response. Please try again.",
              ),
            );
          });
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.insert(
            0,
            ChatMessage(
              user: _botUser,
              createdAt: DateTime.now(),
              text: "Sorry, there was an error: $error",
            ),
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildSettingsButton() {
    return IconButton(
      icon: Icon(Icons.settings),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('AI Settings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Clear Chat History'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _messages.clear();
                      _messages.add(
                        ChatMessage(
                          user: _botUser,
                          createdAt: DateTime.now(),
                          text:
                              "Chat history cleared. How can I help you with attendance tracking today?",
                        ),
                      );
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Assistant',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        actions: [
          _buildSettingsButton(),
        ],
      ),
      body: Column(
        children: [
          // Chat header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[850] : kPrimaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10.r,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [kSecondaryColor, Colors.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.blue[300],
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gemini AI',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      _isTyping ? 'Typing...' : 'Online',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: _isTyping
                            ? Colors.green
                            : (isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main chat area using DashChat
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
              child: DashChat(
                currentUser: _currentUser,
                onSend: _sendMessage,
                messages: _messages,
                inputOptions: InputOptions(
                  inputDecoration: InputDecoration(
                    hintText: 'Ask a question...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.r),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  ),
                  sendButtonBuilder: (onSend) => IconButton(
                    icon: Icon(Icons.send_rounded,
                        color: isDarkMode ? Colors.white : Colors.black),
                    onPressed: onSend,
                    style: IconButton.styleFrom(
                      backgroundColor: kSecondaryColor,
                      padding: EdgeInsets.all(8.sp),
                    ),
                  ),
                ),
                messageOptions: MessageOptions(
                  showTime: true,
                  timeFormat: DateFormat('HH:mm'),
                  containerColor: kSecondaryColor,
                  textColor: Colors.white,
                  timeFontSize: 14.sp,
                  messagePadding: EdgeInsets.all(14.sp),
                  messageDecorationBuilder:
                      (message, previousMessage, nextMessage) {
                    // Use different colors for bot vs user messages
                    return BoxDecoration(
                      color: message.user.id == _botUser.id
                          ? Colors.blue[700]
                          : kSecondaryColor,
                      borderRadius: BorderRadius.circular(18.0),
                    );
                  },
                  messageTextBuilder: (message, previousMessage, nextMessage) {
                    return Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    );
                  },
                ),
                messageListOptions: MessageListOptions(
                  showDateSeparator: true,
                  dateSeparatorFormat: DateFormat('MMM d, yyyy'),
                ),
                typingUsers: _isTyping ? [_botUser] : [],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

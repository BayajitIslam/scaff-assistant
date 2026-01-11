import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/constants/icon_paths.dart';
import 'package:scaffassistant/core/services/local_storage/user_info.dart';
import 'package:scaffassistant/core/services/local_storage/user_status.dart';
import 'package:scaffassistant/core/utils/dynamic_size.dart';
import 'package:scaffassistant/feature/home/controllers/chat_controller.dart';
import 'package:scaffassistant/feature/home/controllers/chat_session_controller.dart';
import 'package:scaffassistant/routing/route_name.dart';
import '../widgets/s_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ChatController chatController = Get.put(ChatController());
  final ChatSessionController chatSessionController = Get.put(
    ChatSessionController(),
  );

  final ScrollController scrollController = ScrollController();

  final List<String> chips = [
    'Safety',
    'Tools',
    'Load',
    'Inspection',
    'Training',
    'More',
  ];

  @override
  void initState() {
    super.initState();
    chatSessionController.fetchChatSessions();

    // if (UserStatus.getIsLoggedIn()) {
    //   chatController.fetchChatMessages('f9823124-a613-466f-bb28-9224ce8e3399');
    // }
  }

  // MARKDOWN-LIKE DECORATOR
  List<TextSpan> decorateText(String message) {
    final baseStyle = AppTextStyles.subHeadLine().copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    );

    List<TextSpan> parseInline(String text, TextStyle style) {
      final parts = <TextSpan>[];
      final regex = RegExp(r'\*\*(.+?)\*\*|`(.+?)`|\b\d+\b');
      int last = 0;
      for (final m in regex.allMatches(text)) {
        if (m.start > last) {
          parts.add(
            TextSpan(text: text.substring(last, m.start), style: style),
          );
        }

        final bold = m.group(1);
        final code = m.group(2);
        final matchText = text.substring(m.start, m.end);

        if (bold != null) {
          parts.add(
            TextSpan(
              text: bold,
              style: style.copyWith(fontWeight: FontWeight.bold),
            ),
          );
        } else if (code != null) {
          parts.add(
            TextSpan(
              text: code,
              style: style.copyWith(
                fontFamily: 'monospace',
                backgroundColor: Colors.grey,
              ),
            ),
          );
        } else {
          parts.add(
            TextSpan(
              text: matchText,
              style: style.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          );
        }
        last = m.end;
      }
      if (last < text.length) {
        parts.add(TextSpan(text: text.substring(last), style: style));
      }
      return parts;
    }

    final spans = <TextSpan>[];
    final lines = message.split('\n');
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final isLastLine = i == lines.length - 1;

      // Headings
      final headingMatch = RegExp(r'^\s*(#{1,6})\s*(.*)').firstMatch(line);
      if (headingMatch != null) {
        final level = headingMatch.group(1)!.length;
        final content = headingMatch.group(2) ?? '';
        spans.addAll(
          parseInline(
            content,
            baseStyle.copyWith(
              fontSize: 22 - (level * 2),
              fontWeight: FontWeight.w700,
            ),
          ),
        );
        if (!isLastLine) spans.add(TextSpan(text: '\n'));
        continue;
      }

      // Horizontal rule
      if (line.trim() == '---' || line.trim() == '***') {
        spans.add(
          TextSpan(
            text: '\u2014\u2014\u2014\n',
            style: baseStyle.copyWith(color: Colors.grey),
          ),
        );
        continue;
      }

      // Bullet list
      final listMatch = RegExp(r'^\s*([-*])\s+(.*)').firstMatch(line);
      if (listMatch != null) {
        spans.add(TextSpan(text: '• ', style: baseStyle));
        spans.addAll(
          parseInline(
            listMatch.group(2) ?? '',
            baseStyle.copyWith(color: AppColors.textSecondary),
          ),
        );
        if (!isLastLine) spans.add(TextSpan(text: '\n'));
        continue;
      }

      spans.addAll(parseInline(line, baseStyle));
      if (!isLastLine) spans.add(TextSpan(text: '\n'));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: SvgPicture.asset(IconPath.logoIconSvg),
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Image(image: AssetImage(IconPath.menuIcon)),
          ),
        ),
        actions: [
          if (UserStatus.getIsLoggedIn())
            Padding(
              padding: EdgeInsets.only(
                right: DynamicSize.horizontalMedium(context),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.toNamed(RouteNames.notificationScreen),

                    child: Image.asset(IconPath.notificationIcon, height: 34),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Get.toNamed(RouteNames.profile),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.borderFocused,
                      child: Text(
                        UserInfo.getUserName()[0].toUpperCase(),
                        style: AppTextStyles.subHeadLine().copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ElevatedButton(
              onPressed: () => Get.toNamed(RouteNames.login),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                backgroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Sign up',
                style: AppTextStyles.headLine().copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          SizedBox(width: DynamicSize.horizontalMedium(context)),
        ],
      ),
      drawer: SDrawer(chatHistory: chatSessionController.chatSessions),
      body: UserStatus.getIsLoggedIn()
          ? Obx(() {
              if (chatController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (chatController.chatHistory.isEmpty) {
                return NewChat(chips: chips);
              }

              // Auto scroll
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (scrollController.hasClients) {
                  scrollController.jumpTo(
                    scrollController.position.maxScrollExtent,
                  );
                }
              });

              return Obx(
                () => ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.all(DynamicSize.medium(context)),
                  itemCount: chatController.chatHistory.length,
                  itemBuilder: (context, index) {
                    final message = chatController.chatHistory[index];
                    final isUser = message.role == 'user';

                    return Container(
                      margin: EdgeInsets.only(
                        bottom: DynamicSize.medium(context),
                        left: isUser ? DynamicSize.horizontalLarge(context) : 0,
                        right: isUser
                            ? 0
                            : DynamicSize.horizontalLarge(context),
                      ),
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(DynamicSize.medium(context)),
                        decoration: BoxDecoration(
                          color: isUser ? Color(0xFFD1E7FF) : Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: RichText(
                          text: TextSpan(
                            children: decorateText(message.content),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            })
          : NewChat(chips: chips),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          width: double.infinity,
          color: AppColors.primary,
          padding: EdgeInsets.fromLTRB(
            DynamicSize.medium(context),
            DynamicSize.medium(context),
            DynamicSize.medium(context),
            DynamicSize.large(context),
          ),
          child: TextField(
            controller: chatController.messageController,
            minLines: 1,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Type a message',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 5,
              ),
              suffixIcon: Obx(
                () => IconButton(
                  icon: chatController.isSending.value
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send),
                  onPressed: chatController.isSending.value
                      ? null
                      : () {
                          chatController.sendMessage();
                        },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NewChat extends StatelessWidget {
  const NewChat({super.key, required this.chips});

  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'What can I help with?',
            style: AppTextStyles.subHeadLine().copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: DynamicSize.large(context)),
          GridView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(
              horizontal: DynamicSize.horizontalLarge(context),
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: DynamicSize.medium(context),
              mainAxisSpacing: DynamicSize.medium(context),
              childAspectRatio: 4 / 1.5,
            ),
            children: List.generate(chips.length, (index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderColor, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.white,
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    chips[index],
                    style: AppTextStyles.subHeadLine().copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

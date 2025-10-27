import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/const/size_const/dynamic_size.dart';
import 'package:scaffassistant/core/const/string_const/icon_path.dart';
import 'package:scaffassistant/core/const/string_const/image_path.dart';
import 'package:scaffassistant/core/local_storage/user_info.dart';
import 'package:scaffassistant/core/local_storage/user_status.dart';
import 'package:scaffassistant/core/theme/SColor.dart';
import 'package:scaffassistant/core/theme/text_theme.dart';
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
  final ChatSessionController chatSessionController = Get.put(ChatSessionController());

  final List<String> chips = [
    'Safety',
    'Tools',
    'Load',
    'Inspection',
    'Training',
    'More',
  ];

  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    chatSessionController.fetchChatSessions();
    if (UserStatus.getIsLoggedIn()) {
      // Replace with your actual session id
      chatController.fetchChatMessages('f9823124-a613-466f-bb28-9224ce8e3399');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: SColor.primary,
        title: Image(image: AssetImage(ImagePath.logoIcon)),
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Image(image: AssetImage(IconPath.menuIcon)),
          ),
        ),
        actions: [
          UserStatus.getIsLoggedIn()
              ? Padding(
            padding: EdgeInsets.only(
                right: DynamicSize.horizontalMedium(context)),
            child: GestureDetector(
              onTap: () => Get.toNamed(RouteNames.profile),
              child: CircleAvatar(
                backgroundColor: SColor.textPrimary,
                child: Text(
                  UserInfo.getUserName()[0],
                  style: STextTheme.headLine().copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: SColor.primary,
                  ),
                ),
              ),
            ),
          )
              : ElevatedButton(
            onPressed: () => Get.toNamed(RouteNames.login),
            style: ElevatedButton.styleFrom(
              padding:
              EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              backgroundColor: SColor.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Sign up',
              style: STextTheme.headLine().copyWith(
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

        // Auto scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController
                .jumpTo(scrollController.position.maxScrollExtent);
          }
        });

        return ListView.builder(
          controller: scrollController,
          padding: EdgeInsets.all(DynamicSize.large(context)),
          itemCount: chatController.chatHistory.length,
          itemBuilder: (context, index) {
            final chat = chatController.chatHistory[index];
            final isUser = chat.role == 'user';

            return Align(
              alignment:
              isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.symmetric(
                    vertical: DynamicSize.small(context)),
                padding: EdgeInsets.all(DynamicSize.medium(context)),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                decoration: BoxDecoration(
                  color: isUser
                      ? SColor.primary.withOpacity(0.4)
                      : SColor.borderColor.withOpacity(0.2),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(15),
                    topRight: const Radius.circular(15),
                    bottomLeft:
                    Radius.circular(isUser ? 15 : 0),
                    bottomRight:
                    Radius.circular(isUser ? 0 : 15),
                  ),
                ),
                child: Text(
                  chat.content,
                  style: STextTheme.subHeadLine().copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: SColor.textPrimary,
                  ),
                ),
              ),
            );
          },
        );
      })
          : NewChat(chips: chips),
      bottomSheet: Container(
        width: double.infinity,
        color: SColor.primary,
        padding: EdgeInsets.fromLTRB(
          DynamicSize.medium(context),
          DynamicSize.medium(context),
          DynamicSize.medium(context),
          DynamicSize.large(context) + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: TextField(
          minLines: 1,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Type a message',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: SColor.borderColor, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: SColor.borderColor),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            suffixIcon: Icon(Icons.send, color: SColor.textPrimary),
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
            style: STextTheme.subHeadLine().copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: SColor.textPrimary,
            ),
          ),
          SizedBox(height: DynamicSize.large(context)),
          GridView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(
                horizontal: DynamicSize.horizontalLarge(context)),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: DynamicSize.medium(context),
              mainAxisSpacing: DynamicSize.medium(context),
              childAspectRatio: 4 / 1.5,
            ),
            children: List.generate(chips.length, (index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: SColor.borderColor, width: 1.5),
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
                    style: STextTheme.subHeadLine().copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: SColor.textSecondary,
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

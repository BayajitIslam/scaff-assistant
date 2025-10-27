import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/const/size_const/dynamic_size.dart';
import 'package:scaffassistant/core/const/string_const/icon_path.dart';
import 'package:scaffassistant/core/const/string_const/image_path.dart';
import 'package:scaffassistant/core/local_storage/user_info.dart';
import 'package:scaffassistant/core/local_storage/user_status.dart';
import 'package:scaffassistant/core/theme/SColor.dart';
import 'package:scaffassistant/core/theme/text_theme.dart';
import 'package:scaffassistant/feature/home/controllers/chat_session_controller.dart';
import 'package:scaffassistant/routing/route_name.dart';

import '../widgets/s_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final ChatSessionController chatSessionController = Get.put(ChatSessionController());

  @override
  void initState() {
    chatSessionController.fetchChatSessions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final List<String> chips = [
      'Safety',
      'Tools',
      'Load',
      'Inspection',
      'Training',
      'More',
    ];

    final List<Map<String, dynamic>> demoChat = [
      {
        'isUser': true,
        'message': 'How to erect a scaffold?',
      },
      {
        'isUser': false,
        'message': 'To erect a scaffold, follow these steps:\n\n1. Plan the Scaffold: Determine the type of scaffold needed, the height, and the load requirements. Ensure compliance with local regulations and safety standards.\n\n2. Prepare the Site: Clear the area where the scaffold will be erected. Ensure the ground is level and stable.\n\n3. Assemble the Base: Lay out the base plates or mudsills to distribute the load evenly. Use adjustable base jacks if necessary.\n\n4. Erect the Frame: Start assembling the scaffold frame by connecting the vertical standards and horizontal ledgers. Use proper locking mechanisms to secure connections.\n\n5. Install Cross Bracing: Add cross braces to enhance stability and prevent swaying. Ensure they are securely fastened.\n\n6. Add Platforms: Place scaffold planks or platforms on the ledgers, ensuring they are properly supported and secured.\n\n7. Install Guardrails: For scaffolds above a certain height, install guardrails, midrails, and toeboards to prevent falls.\n\n8. Inspect the Scaffold: Before use, conduct a thorough inspection to ensure all components are secure and in good condition.\n\n9. Use Safely: Follow safety protocols while using the scaffold, including wearing personal protective equipment (PPE) and avoiding overloading.\n\n10. Dismantle Safely: When dismantling, reverse the erection process carefully, ensuring stability at all times.',
      },
      {
        'isUser': true,
        'message': 'What are some scaffold safety tips?',
      },
      {
        'isUser': false,
        'message': 'Here are some essential scaffold safety tips:\n\n1. Proper Training: Ensure that all workers involved in erecting, using, or dismantling scaffolds are adequately trained in scaffold safety procedures.\n\n2. Inspection: Regularly inspect scaffolds before each use and after any modifications or adverse weather conditions. Look for damaged components, loose connections, and stability issues.\n\n3. Load Capacity: Do not exceed the maximum load capacity of the scaffold. Consider the weight of workers, tools, and materials when calculating loads.\n\n4. Guardrails and Toeboards: Install guardrails, midrails, and toeboards.',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: SColor.primary,
        title: Image(
          image: AssetImage(ImagePath.logoIcon),
        ),
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: Image(image: AssetImage(IconPath.menuIcon)),
          ),
        ),
        actions: [
          UserStatus.getIsLoggedIn()
              ? Padding(
            padding: EdgeInsets.only(right: DynamicSize.horizontalMedium(context)),
            child: GestureDetector(
              onTap: () {
                Get.toNamed(RouteNames.profile);
              },
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
            onPressed: () {
              Get.toNamed(RouteNames.login);
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
          SizedBox(width: DynamicSize.horizontalMedium(context),),
        ],
      ),
      // body: NewChat(chips: chips),
      body: UserStatus.getIsLoggedIn() ? Container(
        margin: EdgeInsets.only(bottom: DynamicSize.large(context) + 70),
        child: StatefulBuilder(
          builder: (context, setState) {
            final scrollController = ScrollController();

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (scrollController.hasClients) {
                scrollController.jumpTo(scrollController.position.maxScrollExtent);
              }
            });

            return ListView.builder(
              controller: scrollController,
              padding: EdgeInsets.all(DynamicSize.large(context)),
              itemCount: demoChat.length,
              itemBuilder: (context, index) {
                final chat = demoChat[index];
                return Align(
                  alignment: chat['isUser'] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: DynamicSize.small(context)),
                    padding: EdgeInsets.all(DynamicSize.medium(context)),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: chat['isUser'] ? SColor.primary.withOpacity(0.4) : SColor.borderColor.withOpacity(0.2),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(chat['isUser'] ? 15 : 0),
                        bottomRight: Radius.circular(chat['isUser'] ? 0 : 15),
                      ),
                    ),
                    child: Text(
                      chat['message'],
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
          },
        ),
      ) : NewChat(chips: chips),
      bottomSheet: Container(
        width: double.infinity,
        color: SColor.primary,
        padding: EdgeInsets.fromLTRB(
            DynamicSize.medium(context),
            DynamicSize.medium(context),
            DynamicSize.medium(context),
            DynamicSize.large(context) + MediaQuery.of(context).viewInsets.bottom
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
                borderSide: BorderSide(color: SColor.borderColor, width: 1)
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: SColor.borderColor),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            suffixIcon: Icon(Icons.send, color: SColor.textPrimary,),
          ),
        ),
      ),
      drawer: SDrawer(
        chatHistory: chatSessionController.chatSessions,
      ),
    );
  }
}

class NewChat extends StatelessWidget {
  const NewChat({
    super.key,
    required this.chips,
  });

  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'What can I help with ?',
            style: STextTheme.subHeadLine().copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: SColor.textPrimary,
            ),
          ),
          SizedBox(height: DynamicSize.large(context),),
          GridView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: DynamicSize.horizontalLarge(context)),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: DynamicSize.medium(context),
              mainAxisSpacing: DynamicSize.medium(context),
              childAspectRatio: 4/1.5,
            ),
            children: List.generate(chips.length, (index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: SColor.borderColor, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
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


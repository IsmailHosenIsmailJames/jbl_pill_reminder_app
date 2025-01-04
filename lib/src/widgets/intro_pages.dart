import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../theme/colors.dart';
import '../theme/const_values.dart';

class AppIntroPages extends StatelessWidget {
  final PageController pageController;
  const AppIntroPages({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: PageView(
        controller: pageController,
        children: List.generate(
          listOfPagesInfo.length,
          (index) => Container(
            width: double.infinity,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: MyAppColors.shadedMutedColor,
              borderRadius: BorderRadius.circular(borderRadius),
              image: DecorationImage(
                image: AssetImage(
                  listOfPagesInfo[index]["img"],
                ),
                fit: BoxFit.fitHeight,
                opacity: 0.3,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listOfPagesInfo[index]["title"],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(5),
                Text(
                  listOfPagesInfo[index]["text"],
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<Map<String, dynamic>> listOfPagesInfo = [
  {
    "img": "assets/img/vision.png",
    "title": "Welcome to JBL Pill Reminder App",
    "text":
        "We're so excited that you're joining our JBL Pill Reminder App. And like a family, we're here to support you, in sickness and in health.",
  },
  {
    "img": "assets/img/10767676_4538245.png",
    "title": "Take care of family",
    "text":
        "We are here to help you in taking care of a loved one, including medicine uptake, as well as be a source of inspiration when needed.",
  },
  {
    "img": "assets/img/product-roadmap-services.png",
    "title": "Track Medication",
    "text":
        "Keeping track of medications can be overwhelming sometimes. So let us do the organizing for you - customized to your personal schedule and dosages.",
  }
];

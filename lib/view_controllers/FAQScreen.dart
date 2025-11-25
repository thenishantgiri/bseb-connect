import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utilities/CustomColors.dart';
import 'ContactScreen.dart';

class FAQscreen extends StatefulWidget {
  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQscreen> {
  List<bool> isOpen = [];
  List<bool> isBSEBOpen = [];

  // ✅ App-related FAQs
  final List<Map<String, String>> appFaqs = [
    {
      "question": "question_1".tr,
      "answer": "answer_1".tr
    },
    {
      "question": "question_2".tr,
      "answer": "answer_2".tr
    },
    {
      "question": "question_3".tr,
      "answer": "answer_3".tr
    },
    {
      "question": "question_4".tr,
      "answer": "answer_4".tr
    },
    {
      "question": "question_5".tr,
      "answer": "answer_5".tr
    },
    {
      "question": "question_6".tr,
      "answer": "answer_6".tr
    },
    {
      "question": "question_7".tr,
      "answer": "answer_7".tr
    },
    {
      "question": "question_8".tr,
      "answer": "answer_8".tr
    },
    {
      "question": "question_9".tr,
      "answer": "answer_9".tr
    },
    {
      "question": "question_10".tr,
      "answer": "answer_10".tr
    },
  ];


  // ✅ BSEB FAQs
  final List<Map<String, String>> bsebFaqs = [
    {
      "question": "question_12".tr,
      "answer": "answer_13".tr
    },
    {
      "question": "question_14".tr,
      "answer": "answer_15".tr
    },
    {
      "question": "question_16".tr,
      "answer": "answer_17".tr
    },
    {
      "question": "question_18".tr,
      "answer": "answer_19".tr
    },
    {
      "question": "question_20".tr,
      "answer": "answer_21".tr
    },
    {
      "question": "question_22".tr,
      "answer": "answer_23".tr
    },
    {
      "question": "question_24".tr,
      "answer": "answer_25".tr
    },
    {
      "question": "question_26".tr,
      "answer": "answer_27".tr
    },
    {
      "question": "question_28".tr,
      "answer": "answer_29".tr
    },
    {
      "question": "question_30".tr,
      "answer": "answer_31".tr,
    "link": "https://biharboardonline.bihar.gov.in/pdf/marksheet-correction-process.pdf"

    },
    {
      "question":"question_32".tr,
      "answer": "answer_33".tr,
      // "link": "https://biharboardonline.bihar.gov.in/pdf/marksheet-correction-process.pdf"

    },
  ];

  @override
  void initState() {
    super.initState();
    isOpen = List.generate(appFaqs.length, (index) => false);
    isBSEBOpen = List.generate(bsebFaqs.length, (index) => false);
  }

  void toggleAppFAQ(int index) {
    setState(() {
      isOpen[index] = !isOpen[index];
    });
  }

  void toggleBSEBFAQ(int index) {
    setState(() {
      isBSEBOpen[index] = !isBSEBOpen[index];
    });
  }


  Widget buildFAQList(
      String title,
      List<Map<String, String>> faqList,
      List<bool> openState,
      Function(int) toggle,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          color: Colors.white,
          child: Text(
            title,
            style: const TextStyle(
              color: Color(CustomColors.theme_orange),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: faqList.length,
          itemBuilder: (context, index) {
            final faq = faqList[index];

            return Column(
              children: [
                GestureDetector(
                  onTap: () => toggle(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${index + 1}. ${faq["question"]}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(CustomColors.theme_orange),
                            ),
                          ),
                        ),
                        Icon(
                          openState[index] ? Icons.remove : Icons.add,
                          color: const Color(CustomColors.theme_orange),
                        ),
                      ],
                    ),
                  ),
                ),
                if (openState[index])
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.grey.shade100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          faq["answer"] ?? "",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        if (faq["link"] != null) ...[
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () async {
                              // final Uri url = Uri.parse(faq["link"]!);
                              // if (await canLaunchUrl(url)) {
                              //   await launchUrl(url, mode: LaunchMode.externalApplication);
                              // }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PdfViewerScreen(title: "Effective exam techniques", path: "assets/pdfs/Marksheet_certification_correction.pdf"),
                                ),
                              );
                            },
                            child: const Text(
                              "📄 View Document",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("faqs_title".tr, style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(CustomColors.theme_orange),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildFAQList("application_faqs".tr, appFaqs, isOpen, toggleAppFAQ),
            buildFAQList("bseb_support".tr, bsebFaqs, isBSEBOpen, toggleBSEBFAQ),
          ],
        ),
      ),
    );
  }
}

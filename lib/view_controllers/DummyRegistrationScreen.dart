import 'package:bseb/utilities/CustomColors.dart';
import 'package:flutter/material.dart';

class DummyRegistrationScreen extends StatelessWidget {
  const DummyRegistrationScreen({super.key});

  Widget _underline(String text) {
    return Text(
      text,
      style: const TextStyle(
        decoration: TextDecoration.underline,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(CustomColors.theme_orange), // replace with CustomColors.theme_orange if needed
        title: const Text(
          "Dummy Registration",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "BIHAR SCHOOL EXAMINATION BOARD\n"
                  "ONLINE REGISTRATION/PERMISSION APPLICATION FORM\n"
                  "FOR THE SECONDARY EXAM, 2027 (SESSION 2026-27)\n\n"
                  "DECLARATION FORM / घोषणा पत्र\n"
                  "1. PERSONAL DETAILS",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // School details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("SCHOOL CODE & NAME: "),
                Expanded(
                  child: _underline("11004 - GOVT GIRLS HIGH SCHOOL PURNEA"),
                ),
              ],
            ),
            Row(children: [
              const Text("APPLICATION NO: "),
              _underline("110040000032"),
            ]),
            Row(children: [
              const Text("APAAR ID: "),
              _underline(""),
            ]),
            Row(children: [
              const Text("STUDENT NAME: "),
              _underline("AAYUSH SINHA"),
            ]),
            Row(children: [
              const Text("MOTHER NAME: "),
              _underline("TEST MOTHER"),
            ]),
            Row(children: [
              const Text("FATHER NAME: "),
              _underline("TEST FATHER"),
            ]),
            Row(children: [
              const Text("EMAIL: "),
              _underline("TEST@GMAIL.COM"),
            ]),
            Row(children: [
              const Text("GENDER: "),
              _underline("MALE"),
            ]),
            Row(children: [
              const Text("DATE OF BIRTH: "),
              _underline("09-10-2009"),
              const Text("   MOBILE NO: "),
              _underline("9874566322"),
            ]),
            Row(children: [
              const Text("AADHAR NO: "),
              _underline("1234-5678-9123"),
              const Text("   CASTE: "),
              _underline("GENERAL"),
            ]),
            Row(children: [
              const Text("CATEGORY: "),
              _underline("REGULAR"),
              const Text("   RELIGION: "),
              _underline("HINDU"),
            ]),
            Row(children: [
              const Text("MARITAL STATUS: "),
              _underline("UNMARRIED"),
              const Text("   AREA: "),
              _underline("RURAL"),
            ]),
            Row(children: [
              const Text("MEDIUM: "),
              _underline("HINDI"),
              const Text("   NATIONALITY: "),
              _underline("INDIAN"),
            ]),
            Row(children: [
              const Text("DIFFERENTLY ABLED: "),
              _underline("NO"),
              const Text("   VISUALLY IMPAIRED: "),
              _underline("NO"),
            ]),
            Row(children: [
              const Text("IDENTIFICATION MARK 1: "),
              _underline("TEST MARK"),
            ]),
            Row(children: [
              const Text("IDENTIFICATION MARK 2: "),
              _underline("TEST MARK"),
            ]),

            const SizedBox(height: 16),
            const Text("2. ADDRESS DETAILS", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(children: [
              const Text("ADDRESS: "),
              _underline("TEST ADDRESS"),
            ]),
            Row(children: [
              const Text("TOWN/CITY: "),
              _underline("PATNA"),
              const Text("   DISTRICT: "),
              _underline("PATNA"),
              const Text("   PINCODE: "),
              _underline("800001"),
            ]),

            const SizedBox(height: 16),
            const Text("3. BANK DETAILS", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(children: [
              const Text("BANK NAME: "),
              _underline(""),
            ]),
            Row(children: [
              const Text("STUDENT A/C NO.: "),
              _underline(""),
              const Text("   IFSC CODE: "),
              _underline(""),
            ]),

            const SizedBox(height: 16),
            const Text("4. SUBJECTS OFFERED", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(children: [
              const Text("MIL: "),
              _underline("HINDI"),
              const Text("   SIL: "),
              _underline("SANSKRIT"),
            ]),
            Row(children: [
              const Text("COMPULSORY 1: "),
              _underline("MATHEMATICS"),
            ]),
            Row(children: [
              const Text("COMPULSORY 2: "),
              _underline("SCIENCE"),
            ]),
            Row(children: [
              const Text("COMPULSORY 3: "),
              _underline("SOCIAL SCIENCE"),
            ]),
            Row(children: [
              const Text("COMPULSORY 4: "),
              _underline("ENGLISH"),
            ]),
            Row(children: [
              const Text("OPTIONAL: "),
              _underline(""),
              const Text("   VOCATIONAL: "),
              _underline(""),
            ]),

            const SizedBox(height: 24),
            const Text(
              "घोषणा (DECLARATION)\n\n"
                  "प्रमािणत िकया जाता है िक इस आवेदन पत्र म� दी गई सूचनाएँ पूरी तरह से सही एवं शुद्ध ह� "
                  "और इसम� कही ंपर भी िकसी प्रकार के संशोधन की आवश्यकता नही ंहै। जो भी सुधार एवं संशोधन थे, सब कर िलए गए ह�।",
            ),
            const SizedBox(height: 16),
            const Text(
              "Signature Of Parent/Guardian             Student’s Signature In Hindi             Student’s Signature In English",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text(
              "प्रमािणत िकया जाता है िक ऊपर िदए गए सभी िववरणी का िमलान िव�ालय के सभी "
                  "अिभलेखो ंसे पूण�रूपेण कर िलया गया है। तदनुसार उक्त परी�ाथ� का पंजीयन आवेदन पत्र �ीकार िकया जाए।",
            ),
            const SizedBox(height: 16),
            const Text(
              "Signature & Seal Of Principal",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

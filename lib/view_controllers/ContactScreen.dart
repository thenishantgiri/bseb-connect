import 'package:bseb/utilities/Utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../utilities/CustomColors.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({Key? key}) : super(key: key);

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (url.startsWith('mailto:')) {
        final Uri fallbackUri = Uri(
          scheme: 'mailto',
          path: uri.path,
          query: uri.query,
        );

        if (await canLaunchUrl(fallbackUri)) {
          await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        } else {
          print('Could not launch $fallbackUri');
        }
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(CustomColors.theme_orange),
        title:  Text("contact_screen_title".tr,
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ContactCard(
              icon: Icons.email,
              title: "email_title".tr,
              subtitle: "bsebsehelpdesk@gmail.com",
              onTap: () => {_launchURL("mailto:bsebsehelpdesk@gmail.com")},
            ),
            ContactCard(
              icon: Icons.language,
              title: "website_title".tr,
              subtitle: "www.biharboardonline.com",
              onTap: () => Utils.openUrl("https://biharboardonline.com/"),
            ),
            ContactCard(
              icon: Icons.phone,
              title: "helpline_title".tr,
              subtitle: "+91-0612-2232074, 8757241924",
              onTap: () => _launchURL("tel:+918757241924"),
            ),
            ContactCard(
              icon: Icons.location_on,
              title: "office_address_title".tr,
              subtitle: "office_address_subtitle".tr,
              onTap: () {
                // Add map navigation if needed
              },
            ),
            // ✅ New Button for Other Contacts PDF
            ContactCard(
              icon: Icons.picture_as_pdf,
              title: "regional_offices_title".tr,
              subtitle: "regional_offices_subtitle".tr,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>  PdfViewerScreen(
                      title: "regional_offices_title".tr,
                      path: "assets/pdfs/other_contacts.pdf",
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ContactCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Color(CustomColors.theme_orange),
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitle),
        ),
      ),
    );
  }
}

class PdfViewerScreen extends StatelessWidget {
  final String title;
  final String path;

  const PdfViewerScreen({
    super.key,
    required this.title,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(CustomColors.theme_orange),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SfPdfViewer.asset(path),
    );
  }
}

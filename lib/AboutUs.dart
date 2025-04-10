import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About Us',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 24, 16, 133),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo and Name
            const CircleAvatar(
              radius: 60,
              backgroundImage:
                  AssetImage('assets/logo.png'), // Replace with your logo
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 20),
            const Text(
              'LaptopHarbor',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 24, 16, 133),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your One-Stop Laptop Marketplace',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 30),

            // App Description
            const Text(
              'About LaptopHarbor',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'LaptopHarbor is a comprehensive platform for buying laptops. '
              'We provide a trusted marketplace where users can find the best deals on new and refurbished laptops '
              'from various brands. Our mission is to make laptop shopping easy, transparent, and affordable for everyone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),

            // Team Section
            const Text(
              'Our Team',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Team Members - Replace with your actual team
            _buildTeamMember(
              context,
              'Mahnoor Zia',
              'Lead Developer',
              'assets/images/woman.png', // Replace with actual image
              'https://github.com/tahamahmood004',
            ),
            const SizedBox(height: 20),
            _buildTeamMember(
              context,
              'Taha Mahmood',
              'Developer',
              'assets/images/man.png', // Replace with actual image
              'https://github.com/tahamahmood004',
            ),
            const SizedBox(height: 20),
            _buildTeamMember(
              context,
              'Aiman Hasan',
              'Developer',
              'assets/images/woman.png', // Replace with actual image
              'https://github.com/janesmith',
            ),
            const SizedBox(height: 20),
            _buildTeamMember(
              context,
              'Daniyal Ghori',
              'Developer',
              'assets/images/man.png', // Replace with actual image
              'https://github.com/johndoe',
            ),
            const SizedBox(height: 20),
            _buildTeamMember(
              context,
              'Misbah Hasan',
              'Developer',
              'assets/images/man.png', // Replace with actual image
              'https://github.com/johndoe',
            ),
            const SizedBox(height: 30),

            // Contact Information
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _buildContactOption(
                Icons.email, 'Email', 'support@laptopharbor.com'),
            const SizedBox(height: 10),
            _buildContactOption(Icons.phone, 'Phone', '+1 (123) 456-7890'),
            const SizedBox(height: 10),
            _buildContactOption(Icons.location_on, 'Address',
                '123 Tech Street, Silicon Valley, CA'),
            const SizedBox(height: 30),

            // App Version
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMember(BuildContext context, String name, String role,
      String imagePath, String githubUrl) {
    return GestureDetector(
      onTap: () => _launchURL(githubUrl),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(imagePath),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactOption(IconData icon, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Color.fromARGB(255, 24, 16, 133)),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:student_attendance/colors.dart';
import 'package:student_attendance/pages/team_member_details_page.dart';
import 'package:student_attendance/widgets/theme_mode_button.dart';

class AboutPage extends StatelessWidget {
  static const String id = 'about_page';

  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if we're in dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white, size: 30.sp),
        centerTitle: true,
        backgroundColor: kAppBarColor,
        title: Text(
          'About Us',
          style: TextStyle(
              color: kTextColor, fontWeight: FontWeight.w700, fontSize: 22.sp),
        ),
        actions: const [ThemeModeButton()],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0.sp),
          child: Column(
            children: [
              // App Logo and Name
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 24.h),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[850] : kPrimaryColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.school_rounded,
                      size: 80.sp,
                      color: kSecondaryColor,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Student Attendance',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: kSecondaryColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              // Team Title
              Text(
                'Meet Our Team',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),

              SizedBox(height: 8.h),

              Text(
                'The brilliant minds behind this application',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                ),
              ),

              SizedBox(height: 24.h),

              // Team Members
              _buildTeamMember(
                context,
                name: 'Ramadan Mohamed',
                avatarPlaceholder: 'RM',
                imagePath: 'assets/images/Ramadan.jpg',
                role: 'Electrical Engineer',
                linkedinUrl:
                    'https://www.linkedin.com/in/ramadan-mohamed-31624a220/',
                facebookUrl: 'https://www.facebook.com/elking.medo611',
                whatsappNumber: '+201065728564',
                portfolioUrl: 'https://ramadan-mohamed-portfolio.netlify.app/',
              ),

              SizedBox(height: 16.h),

              _buildTeamMember(
                context,
                name: 'Hesham Ahmed',
                avatarPlaceholder: 'HA',
                imagePath: 'assets/images/Hesham.jpg',
                role: 'Electrical Engineer',
                linkedinUrl: 'https://www.linkedin.com/in/hesham-ahmed/',
                facebookUrl: 'https://www.facebook.com/hesham.ahmed',
                whatsappNumber: '+201208073136',
              ),

              SizedBox(height: 16.h),

              _buildTeamMember(
                context,
                name: 'Haitham Salah',
                avatarPlaceholder: 'HS',
                role: 'Electrical Engineer',
                whatsappNumber: '+201212633931',
              ),
              SizedBox(height: 16.h),

              _buildTeamMember(
                context,
                name: 'Saad Mohamed',
                avatarPlaceholder: 'SM',
                role: 'Electrical Engineer',
                whatsappNumber: '+201557401222',
              ),

              SizedBox(height: 32.h),

              // App Description
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.sp),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About the App',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Student Attendance is a comprehensive solution designed to streamline the attendance tracking process for educational institutions. Our application makes it easy for professors to mark attendance and for students to view their attendance records.',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              // Contact Section
              Text(
                'Get in Touch',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),

              SizedBox(height: 16.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(
                    context,
                    icon: Icons.email,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Email functionality not available')));
                    },
                  ),
                  SizedBox(width: 16.w),
                  _buildSocialButton(
                    context,
                    icon: Icons.language,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('Website functionality not available')));
                    },
                  ),
                  SizedBox(width: 16.w),
                  _buildSocialButton(
                    context,
                    icon: Icons.phone,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Phone functionality not available')));
                    },
                  ),
                ],
              ),

              SizedBox(height: 32.h),

              // Copyright
              Text(
                '© ${DateTime.now().year} Student Attendance App',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[700],
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMember(
    BuildContext context, {
    required String name,
    required String avatarPlaceholder,
    String? imagePath,
    String? linkedinUrl,
    String? facebookUrl,
    String? whatsappNumber,
    String? portfolioUrl,
    String? bio,
    String? role,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeamMemberDetailsPage(
              name: name,
              avatarPlaceholder: avatarPlaceholder,
              imagePath: imagePath,
              linkedinUrl: linkedinUrl,
              facebookUrl: facebookUrl,
              whatsappNumber: whatsappNumber,
              portfolioUrl: portfolioUrl,
              bio: bio,
              role: role ?? 'Team Member',
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Hero(
              tag: name,
              child: Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [kSecondaryColor, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kSecondaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(40.r),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Text(
                          avatarPlaceholder,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(width: 16.w),
            // Name and Role
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16.sp,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            role ?? 'Team Member',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16.sp,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        width: 60.w,
        height: 60.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDarkMode ? Colors.grey[850] : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 24.sp,
          color: kSecondaryColor,
        ),
      ),
    );
  }

  // URL launching functionality removed
  // Will be implemented when url_launcher package is added
}

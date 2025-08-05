import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:student_attendance/colors.dart';
import 'package:student_attendance/utils/url_launcher.dart';

class TeamMemberDetailsPage extends StatelessWidget {
  final String name;
  final String avatarPlaceholder;
  final String? imagePath;
  final String? linkedinUrl;
  final String? facebookUrl;
  final String? whatsappNumber;
  final String? portfolioUrl;
  final String? bio;
  final String? role;

  const TeamMemberDetailsPage({
    super.key,
    required this.name,
    required this.avatarPlaceholder,
    this.imagePath,
    this.linkedinUrl,
    this.facebookUrl,
    this.whatsappNumber,
    this.portfolioUrl,
    this.bio,
    this.role,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Hero Animation
          SliverAppBar(
            expandedHeight: 300.h,
            floating: false,
            pinned: true,
            backgroundColor: isDarkMode ? Colors.grey[850] : kPrimaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          kSecondaryColor,
                          Colors.blue,
                        ],
                      ),
                    ),
                  ),
                  // Profile image
                  Center(
                    child: Hero(
                      tag: name,
                      child: Container(
                        width: 180.w,
                        height: 180.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4.w,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(90.r),
                          child: imagePath != null
                              ? Image.asset(
                                  imagePath!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: kSecondaryColor,
                                  child: Center(
                                    child: Text(
                                      avatarPlaceholder,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 50.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Role
                  if (role != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: kSecondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        role!,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: kSecondaryColor,
                        ),
                      ),
                    ),

                  SizedBox(height: 24.h),

                  // Bio
                  if (bio != null) ...[
                    Text(
                      'About',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      bio!,
                      style: TextStyle(
                        fontSize: 16.sp,
                        height: 1.6,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 32.h),
                  ],

                  // Social Links
                  if (linkedinUrl != null ||
                      facebookUrl != null ||
                      whatsappNumber != null ||
                      portfolioUrl != null) ...[
                    Text(
                      'Connect',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // LinkedIn
                        if (linkedinUrl != null)
                          _buildSocialButton(
                            context,
                            icon: FontAwesomeIcons.linkedin,
                            color: const Color(0xFF0077B5),
                            onTap: () => myLaunchUrl(linkedinUrl!),
                          ),

                        // Facebook
                        if (facebookUrl != null)
                          _buildSocialButton(
                            context,
                            icon: FontAwesomeIcons.facebook,
                            color: const Color(0xFF1877F2),
                            onTap: () => myLaunchUrl(facebookUrl!),
                          ),

                        // WhatsApp
                        if (whatsappNumber != null)
                          _buildSocialButton(
                            context,
                            icon: FontAwesomeIcons.whatsapp,
                            color: const Color(0xFF25D366),
                            onTap: () => myLaunchUrl(
                                'https://wa.me/${whatsappNumber!.replaceAll(RegExp(r'[^0-9]'), '')}'),
                          ),

                        // Portfolio
                        if (portfolioUrl != null)
                          _buildSocialButton(
                            context,
                            icon: FontAwesomeIcons.globe,
                            color: Colors.purple,
                            onTap: () => myLaunchUrl(portfolioUrl!),
                          ),
                      ],
                    ),
                  ],

                  SizedBox(height: 40.h),

                  // Contact Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (whatsappNumber != null) {
                          myLaunchUrl(
                              'https://wa.me/${whatsappNumber!.replaceAll(RegExp(r'[^0-9]'), '')}');
                        } else if (linkedinUrl != null) {
                          myLaunchUrl(linkedinUrl!);
                        } else if (facebookUrl != null) {
                          myLaunchUrl(facebookUrl!);
                        } else if (portfolioUrl != null) {
                          myLaunchUrl(portfolioUrl!);
                        }
                      },
                      icon: const Icon(Icons.email_outlined),
                      label: Text(
                        'Contact Me',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSecondaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.w,
                          vertical: 16.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
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
          size: 30.sp,
          color: color,
        ),
      ),
    );
  }
}

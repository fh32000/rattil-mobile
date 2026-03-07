import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('عن التطبيق'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // App logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              AppConstants.appName,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'الإصدار ${AppConstants.appVersion} · ${AppConstants.appReleaseDate}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),

            const SizedBox(height: 28),

            // Description
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('تعريف بالتطبيق', theme),
                  const SizedBox(height: 12),
                  Text(
                    'تطبيق ورتِّله هو تطبيق للاستماع إلى تلاوات القرآن الكريم، '
                    'يوفر تجربة استماع سهلة ومريحة مع مشغل صوتي متكامل يعمل '
                    'حتى عند تشغيل التطبيق في الخلفية.',
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.8),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('الهدف من التطبيق', theme),
                  const SizedBox(height: 12),
                  _buildBullet(
                    'توفير تجربة استماع سهلة ومريحة للقرآن الكريم',
                    theme,
                  ),
                  _buildBullet('مشغل صوتي متكامل يشبه تطبيقات الموسيقى', theme),
                  _buildBullet(
                    'تمكين المستخدم من متابعة التلاوة بسهولة',
                    theme,
                  ),
                  _buildBullet('حفظ آخر موضع توقف لكل مقطع', theme),
                  _buildBullet('تنظيم المقاطع للتصفح والبحث', theme),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Developer info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('معلومات المطور', theme),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.person,
                    'المطور',
                    AppConstants.developerName,
                    theme,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.work,
                    'التخصص',
                    AppConstants.developerTitle,
                    theme,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.school,
                    'التعليم',
                    AppConstants.developerUniversity,
                    theme,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.business,
                    'الشركة',
                    AppConstants.developerCompany,
                    theme,
                  ),

                  const SizedBox(height: 16),

                  // Contact tiles
                  _buildContactTile(
                    icon: Icons.email,
                    title: 'البريد الإلكتروني',
                    subtitle: AppConstants.developerEmail,
                    color: AppColors.primaryLight,
                    onTap: () => _launchUrl(
                      'mailto:${AppConstants.developerEmail}?subject=ورتِّله - تواصل',
                    ),
                    theme: theme,
                  ),
                  _buildContactTile(
                    icon: Icons.chat,
                    title: 'تواصل عبر الواتساب',
                    subtitle: AppConstants.developerPhone,
                    color: const Color(0xFF25D366),
                    onTap: () => _launchUrl(
                      'https://wa.me/${AppConstants.developerWhatsApp}',
                    ),
                    theme: theme,
                  ),
                  _buildContactTile(
                    icon: Icons.phone,
                    title: 'تواصل عبر الاتصال',
                    subtitle: AppConstants.developerPhone,
                    color: AppColors.accent,
                    onTap: () =>
                        _launchUrl('tel:+${AppConstants.developerWhatsApp}'),
                    theme: theme,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Text(
              '﷽',
              style: TextStyle(
                fontSize: 28,
                color: AppColors.accent,
                fontFamily: 'Amiri',
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBullet(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryLight),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
      ],
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color.withValues(alpha: 0.1),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.15),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/update_provider.dart';

class UpdatesScreen extends ConsumerStatefulWidget {
  const UpdatesScreen({super.key});

  @override
  ConsumerState<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends ConsumerState<UpdatesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(updateProvider.notifier).checkForUpdates(isSilent: false);
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر فتح الرابط')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(updateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('التحديثات'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.system_update, size: 80, color: Colors.grey),
              const SizedBox(height: 24),
              Text(
                'الإصدار الحالي: ${updateState.currentVersionStr.isNotEmpty ? updateState.currentVersionStr : "جاري التحقق..."}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 32),
              if (updateState.status == UpdateStatus.checking)
                const Center(child: CircularProgressIndicator())
              else if (updateState.status == UpdateStatus.upToDate)
                Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 60,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'تطبيقك محدث لآخر إصدار',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: Colors.green),
                    ),
                  ],
                )
              else if (updateState.status == UpdateStatus.error)
                Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'حدث خطأ أثناء التحقق من التحديثات. يرجى التأكد من اتصالك بالإنترنت والمحاولة لاحقاً.',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.redAccent),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => ref
                          .read(updateProvider.notifier)
                          .checkForUpdates(isSilent: false),
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة المحاولة'),
                    ),
                  ],
                )
              else if (updateState.status == UpdateStatus.updateAvailable &&
                  updateState.latestVersion != null)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.new_releases,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'تحديث جديد متاح!',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'الإصدار: ${updateState.latestVersion!.latestVersion}+${updateState.latestVersion!.buildNumber}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (updateState.latestVersion!.releaseDate.isNotEmpty)
                          Text(
                            'تاريخ الإصدار: ${updateState.latestVersion!.releaseDate}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        const Divider(height: 32),
                        Text(
                          'ملاحظات الإصدار:',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          updateState.latestVersion!.releaseNotes.isNotEmpty
                              ? updateState.latestVersion!.releaseNotes
                              : 'تحسينات عامة وإصلاحات للأخطاء.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => _launchUrl(
                              updateState.latestVersion!.updateUrl,
                            ),
                            icon: const Icon(Icons.download),
                            label: const Text('تحديث الآن'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 48),
              if (updateState.status != UpdateStatus.checking)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => ref
                        .read(updateProvider.notifier)
                        .checkForUpdates(isSilent: false),
                    icon: const Icon(Icons.refresh),
                    label: const Text('التحقق من وجود تحديثات'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

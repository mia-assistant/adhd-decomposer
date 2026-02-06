import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PaywallScreen extends StatefulWidget {
  final VoidCallback? onPurchaseComplete;
  final VoidCallback? onSkip;
  final bool showSkip;
  
  const PaywallScreen({
    super.key,
    this.onPurchaseComplete,
    this.onSkip,
    this.showSkip = true,
  });

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _isYearlySelected = true;
  bool _isLoading = false;
  
  static const double monthlyPrice = 4.99;
  static const double yearlyPrice = 29.99;
  
  double get yearlySavings => (monthlyPrice * 12) - yearlyPrice;
  double get yearlyMonthlyEquiv => yearlyPrice / 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            if (widget.showSkip)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: widget.onSkip,
                    child: const Text('Skip'),
                  ),
                ),
              ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (!widget.showSkip) const SizedBox(height: 32),
                    
                    // Header
                    _buildHeader(context),
                    
                    const SizedBox(height: 32),
                    
                    // Premium features
                    _buildFeatures(context),
                    
                    const SizedBox(height: 32),
                    
                    // Pricing cards
                    _buildPricingCards(context),
                    
                    const SizedBox(height: 24),
                    
                    // Purchase button
                    _buildPurchaseButton(context),
                    
                    const SizedBox(height: 16),
                    
                    // Restore purchases
                    TextButton(
                      onPressed: _restorePurchases,
                      child: const Text('Restore Purchases'),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Terms
                    Text(
                      'Cancel anytime. Subscription auto-renews.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.tertiary,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.workspace_premium,
            size: 40,
            color: Colors.white,
          ),
        )
            .animate()
            .scale(duration: 600.ms, curve: Curves.elasticOut)
            .fadeIn(),
        
        const SizedBox(height: 24),
        
        Text(
          'Unlock Tiny Steps Pro',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(delay: 100.ms)
            .slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 8),
        
        Text(
          'Get unlimited task breakdowns and more',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(delay: 200.ms)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }
  
  Widget _buildFeatures(BuildContext context) {
    final features = [
      (icon: Icons.all_inclusive, text: 'Unlimited task decompositions'),
      (icon: Icons.volume_up, text: 'All celebration sounds'),
      (icon: Icons.palette, text: 'Premium themes'),
      (icon: Icons.block, text: 'No ads, ever'),
      (icon: Icons.rocket_launch, text: 'Priority AI processing'),
    ];
    
    return Column(
      children: features.asMap().entries.map((entry) {
        final index = entry.key;
        final feature = entry.value;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  feature.icon,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                feature.text,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: Duration(milliseconds: 300 + index * 50))
            .slideX(begin: -0.1, end: 0);
      }).toList(),
    );
  }
  
  Widget _buildPricingCards(BuildContext context) {
    return Row(
      children: [
        // Monthly
        Expanded(
          child: _PricingCard(
            title: 'Monthly',
            price: '\$$monthlyPrice',
            period: '/month',
            isSelected: !_isYearlySelected,
            onTap: () => setState(() => _isYearlySelected = false),
          )
              .animate()
              .fadeIn(delay: 500.ms)
              .slideY(begin: 0.3, end: 0),
        ),
        
        const SizedBox(width: 12),
        
        // Yearly
        Expanded(
          child: _PricingCard(
            title: 'Yearly',
            price: '\$$yearlyPrice',
            period: '/year',
            subtitle: '\$${yearlyMonthlyEquiv.toStringAsFixed(2)}/mo',
            badge: 'BEST VALUE',
            savingsText: 'Save \$${yearlySavings.toStringAsFixed(0)}',
            isSelected: _isYearlySelected,
            onTap: () => setState(() => _isYearlySelected = true),
          )
              .animate()
              .fadeIn(delay: 600.ms)
              .slideY(begin: 0.3, end: 0),
        ),
      ],
    );
  }
  
  Widget _buildPurchaseButton(BuildContext context) {
    final price = _isYearlySelected ? yearlyPrice : monthlyPrice;
    final period = _isYearlySelected ? 'year' : 'month';
    
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _isLoading ? null : _purchase,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text('Continue — \$$price/$period'),
      ),
    )
        .animate()
        .fadeIn(delay: 700.ms)
        .slideY(begin: 0.5, end: 0);
  }
  
  Future<void> _purchase() async {
    setState(() => _isLoading = true);
    
    // TODO: Implement actual RevenueCat purchase
    // For now, simulate a purchase
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() => _isLoading = false);
    
    // Show success (in real implementation, check purchase result)
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('IAP not yet implemented - unlock coming soon!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);
    
    // TODO: Implement actual RevenueCat restore
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() => _isLoading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No purchases found to restore'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final String? subtitle;
  final String? badge;
  final String? savingsText;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _PricingCard({
    required this.title,
    required this.price,
    required this.period,
    this.subtitle,
    this.badge,
    this.savingsText,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                const SizedBox(height: 20),
              
              const SizedBox(height: 8),
              
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 4),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      period,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
              
              if (savingsText != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    savingsText!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

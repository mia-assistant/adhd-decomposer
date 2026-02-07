import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../data/services/purchase_service.dart';

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
  bool _isLoadingPackages = true;
  String? _errorMessage;
  
  // Fallback prices if packages can't be loaded
  static const double fallbackMonthlyPrice = 4.99;
  static const double fallbackYearlyPrice = 29.99;
  
  @override
  void initState() {
    super.initState();
    _loadPackages();
  }
  
  Future<void> _loadPackages() async {
    setState(() {
      _isLoadingPackages = true;
      _errorMessage = null;
    });
    
    try {
      final purchaseService = Provider.of<PurchaseService>(context, listen: false);
      await purchaseService.getOfferings();
    } catch (e) {
      // Don't show error for loading - just use fallback prices
      debugPrint('Error loading packages: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingPackages = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PurchaseService>(
      builder: (context, purchaseService, _) {
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
                        onPressed: _isLoading ? null : widget.onSkip,
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
                        
                        // Error message
                        if (_errorMessage != null)
                          _buildErrorBanner(context),
                        
                        // Pricing cards
                        if (_isLoadingPackages)
                          _buildLoadingPricing()
                        else
                          _buildPricingCards(context, purchaseService),
                        
                        const SizedBox(height: 24),
                        
                        // Purchase button
                        _buildPurchaseButton(context, purchaseService),
                        
                        const SizedBox(height: 16),
                        
                        // Restore purchases
                        TextButton(
                          onPressed: _isLoading ? null : () => _restorePurchases(purchaseService),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Restore Purchases'),
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
                        
                        const SizedBox(height: 8),
                        
                        // Links
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                // TODO: Navigate to privacy policy
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              child: Text(
                                'Privacy Policy',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            Text('•', style: Theme.of(context).textTheme.bodySmall),
                            TextButton(
                              onPressed: () {
                                // TODO: Navigate to terms
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              child: Text(
                                'Terms of Service',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
  
  Widget _buildErrorBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => setState(() => _errorMessage = null),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingPricing() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPricingCards(BuildContext context, PurchaseService purchaseService) {
    // Get packages from service or use fallback
    final monthlyPackage = purchaseService.monthlyPackage;
    final yearlyPackage = purchaseService.yearlyPackage;
    
    // Determine prices to show
    final monthlyPrice = monthlyPackage != null
        ? purchaseService.getFormattedPrice(monthlyPackage)
        : '\$${fallbackMonthlyPrice.toStringAsFixed(2)}';
    
    final yearlyPrice = yearlyPackage != null
        ? purchaseService.getFormattedPrice(yearlyPackage)
        : '\$${fallbackYearlyPrice.toStringAsFixed(2)}';
    
    // Calculate savings
    final savings = purchaseService.getYearlySavings() ?? 
        ((fallbackMonthlyPrice * 12) - fallbackYearlyPrice);
    
    final monthlyEquiv = purchaseService.getYearlyMonthlyEquivalent() ??
        (fallbackYearlyPrice / 12);
    
    return Row(
      children: [
        // Monthly
        Expanded(
          child: _PricingCard(
            title: 'Monthly',
            price: monthlyPrice,
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
            price: yearlyPrice,
            period: '/year',
            subtitle: '\$${monthlyEquiv.toStringAsFixed(2)}/mo',
            badge: 'BEST VALUE',
            savingsText: 'Save \$${savings.toStringAsFixed(0)}',
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
  
  Widget _buildPurchaseButton(BuildContext context, PurchaseService purchaseService) {
    final selectedPackage = _isYearlySelected 
        ? purchaseService.yearlyPackage 
        : purchaseService.monthlyPackage;
    
    // Button text
    String buttonText;
    if (_isLoading) {
      buttonText = 'Processing...';
    } else if (selectedPackage != null) {
      buttonText = 'Continue — ${purchaseService.getFormattedPrice(selectedPackage)}';
    } else {
      final price = _isYearlySelected ? fallbackYearlyPrice : fallbackMonthlyPrice;
      final period = _isYearlySelected ? 'year' : 'month';
      buttonText = 'Continue — \$${price.toStringAsFixed(2)}/$period';
    }
    
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _isLoading || _isLoadingPackages 
            ? null 
            : () => _purchase(purchaseService),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(buttonText),
      ),
    )
        .animate()
        .fadeIn(delay: 700.ms)
        .slideY(begin: 0.5, end: 0);
  }
  
  Future<void> _purchase(PurchaseService purchaseService) async {
    final selectedPackage = _isYearlySelected 
        ? purchaseService.yearlyPackage 
        : purchaseService.monthlyPackage;
    
    if (selectedPackage == null) {
      setState(() {
        _errorMessage = 'Subscription not available. Please try again later.';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final success = await purchaseService.purchasePackage(selectedPackage);
      
      if (success && mounted) {
        // Purchase successful!
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome to Tiny Steps Pro! 🎉'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        
        widget.onPurchaseComplete?.call();
      }
    } on PurchaseException catch (e) {
      if (mounted) {
        if (e.type == PurchaseErrorType.userCancelled) {
          // User cancelled - don't show as error
          debugPrint('User cancelled purchase');
        } else if (e.type == PurchaseErrorType.alreadyPurchased) {
          // Already premium - treat as success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You already have an active subscription! 🎉'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
            ),
          );
          widget.onPurchaseComplete?.call();
        } else {
          setState(() {
            _errorMessage = e.userMessage;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Something went wrong. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _restorePurchases(PurchaseService purchaseService) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final success = await purchaseService.restorePurchases();
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchases restored successfully! 🎉'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
            ),
          );
          widget.onPurchaseComplete?.call();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No previous purchases found'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } on PurchaseException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.userMessage;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not restore purchases. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                  Flexible(
                    child: Text(
                      price,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
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

class SplashConfig {
  final Duration animationDuration;
  final Duration splashDelay;
  
  const SplashConfig({
    this.animationDuration = const Duration(seconds: 2),
    this.splashDelay = const Duration(seconds: 3),
  });
}

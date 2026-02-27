import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:balaji_points/l10n/app_localizations.dart';
import 'package:balaji_points/config/theme.dart' as LegacyTheme;
import 'package:balaji_points/core/theme/design_token.dart';

class CompleteProfileCard extends StatelessWidget {
  const CompleteProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: DesignToken.paddingHorizontalLG,
      decoration: BoxDecoration(
        // Thin gradient border to match home header & bottom bar
        gradient: LinearGradient(
          colors: DesignToken.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: DesignToken.borderRadiusLG,
      ),
      child: Container(
        margin: const EdgeInsets.all(1.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              DesignToken.orangeShade400,
              DesignToken.deepOrangeShade500,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: DesignToken.borderRadiusLG,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: DesignToken.orange.withValues(alpha: 0.3),
              blurRadius: DesignToken.elevationXL,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: DesignToken.transparent,
          child: InkWell(
            onTap: () => context.push('/edit-profile'),
            borderRadius: DesignToken.borderRadiusLG,
            child: Padding(
              padding: DesignToken.paddingAllLG,
              child: Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(DesignToken.paddingMD),
                    decoration: BoxDecoration(
                      color: DesignToken.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1,
                      color: DesignToken.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: DesignToken.widthLG),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.completeProfile,
                          style: LegacyTheme.AppTextStyles.nunitoBold.copyWith(
                            fontSize: DesignToken.fontSizeLG,
                            color: DesignToken.white,
                          ),
                        ),
                        const SizedBox(height: DesignToken.heightXS),
                        Text(
                          l10n.completeProfileDetails,
                          style: LegacyTheme.AppTextStyles.nunitoRegular
                              .copyWith(
                            fontSize: DesignToken.fontSizeMD,
                            color: DesignToken.white.withValues(alpha: 0.95),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: DesignToken.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


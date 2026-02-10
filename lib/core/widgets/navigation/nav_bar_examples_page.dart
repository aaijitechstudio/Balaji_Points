import 'package:flutter/material.dart';
import 'package:balaji_points/core/widgets/navigation/balaji_top_nav_bar.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/core/theme/design_token_extensions.dart';

/// Example page demonstrating all BalajiTopNavBar variations
/// This page can be used as a reference for implementing navigation bars
class NavBarExamplesPage extends StatelessWidget {
  const NavBarExamplesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BalajiTopNavBar(
        titleText: 'NavBar Examples',
        backgroundColor: context.colors.primary,
        iconColor: context.colors.white,
        titleStyle: context.text.heading5.copyWith(
          color: context.colors.white,
        ),
      ),
      body: ListView(
        padding: DesignToken.paddingAllLG,
        children: [
          _buildSection(
            context,
            'Standard Variations',
            [
              _ExampleCard(
                title: '1. Standard with Back Button',
                description: 'Default configuration with back button',
                onTap: () => _showExample(context, _StandardExample()),
              ),
              _ExampleCard(
                title: '2. With Actions',
                description: 'Navigation bar with action buttons',
                onTap: () => _showExample(context, _ActionsExample()),
              ),
              _ExampleCard(
                title: '3. No Back Button',
                description: 'Perfect for home/dashboard pages',
                onTap: () => _showExample(context, _NoBackExample()),
              ),
              _ExampleCard(
                title: '4. Custom Title Widget',
                description: 'Use any widget as title',
                onTap: () => _showExample(context, _CustomTitleExample()),
              ),
            ],
          ),
          
          context.spacing.heightXL2,
          
          _buildSection(
            context,
            'Styled Variations',
            [
              _ExampleCard(
                title: '5. Gradient Background',
                description: 'Beautiful gradient navigation',
                onTap: () => _showExample(context, _GradientExample()),
              ),
              _ExampleCard(
                title: '6. Primary Color',
                description: 'Using brand primary color',
                onTap: () => _showExample(context, _PrimaryExample()),
              ),
              _ExampleCard(
                title: '7. Transparent',
                description: 'For pages with custom backgrounds',
                onTap: () => _showExample(context, _TransparentExample()),
              ),
              _ExampleCard(
                title: '8. With Elevation',
                description: 'Navigation bar with shadow',
                onTap: () => _showExample(context, _ElevatedExample()),
              ),
            ],
          ),
          
          context.spacing.heightXL2,
          
          _buildSection(
            context,
            'Advanced Variations',
            [
              _ExampleCard(
                title: '9. With Search Bar',
                description: 'Bottom widget with search',
                onTap: () => _showExample(context, _SearchExample()),
              ),
              _ExampleCard(
                title: '10. Custom Leading',
                description: 'Custom leading widget (avatar)',
                onTap: () => _showExample(context, _CustomLeadingExample()),
              ),
              _ExampleCard(
                title: '11. Modal Style',
                description: 'For bottom sheets and dialogs',
                onTap: () => _showExample(context, _ModalExample()),
              ),
              _ExampleCard(
                title: '12. With Bottom Border',
                description: 'Subtle border separation',
                onTap: () => _showExample(context, _BorderExample()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.text.heading4.copyWith(
            color: context.colors.primary,
          ),
        ),
        context.spacing.heightMD,
        ...children,
      ],
    );
  }

  void _showExample(BuildContext context, Widget example) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => example),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ExampleCard({
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: context.spacing.md),
      child: ListTile(
        title: Text(title, style: context.text.labelLarge),
        subtitle: Text(description, style: context.text.bodySmall),
        trailing: Icon(Icons.arrow_forward_ios, size: context.icons.sm),
        onTap: onTap,
      ),
    );
  }
}

// Example implementations

class _StandardExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BalajiTopNavBar(
        titleText: 'Standard NavBar',
      ),
      body: _ExampleContent(
        title: 'Standard Navigation Bar',
        description: 'This is the default configuration with automatic back button detection.',
        code: '''
BalajiTopNavBar(
  titleText: 'Standard NavBar',
)
''',
      ),
    );
  }
}

class _ActionsExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BalajiTopNavBar(
        titleText: 'With Actions',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: _ExampleContent(
        title: 'Navigation Bar with Actions',
        description: 'Action buttons appear on the right side of the navigation bar.',
        code: '''
BalajiTopNavBar(
  titleText: 'With Actions',
  actions: [
    IconButton(
      icon: Icon(Icons.search),
      onPressed: () {},
    ),
    IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: () {},
    ),
  ],
)
''',
      ),
    );
  }
}

class _NoBackExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BalajiTopNavBarPresets.noBack(
        title: 'Home',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: _ExampleContent(
        title: 'No Back Button',
        description: 'Perfect for home or dashboard pages where back button is not needed.',
        code: '''
BalajiTopNavBarPresets.noBack(
  title: 'Home',
  actions: [
    IconButton(
      icon: Icon(Icons.notifications),
      onPressed: () {},
    ),
  ],
)
''',
      ),
    );
  }
}

class _CustomTitleExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BalajiTopNavBar(
        titleWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: DesignToken.amber),
            const SizedBox(width: 8),
            const Text('Premium'),
          ],
        ),
      ),
      body: _ExampleContent(
        title: 'Custom Title Widget',
        description: 'You can use any widget as the title, not just text.',
        code: '''
BalajiTopNavBar(
  titleWidget: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.star, color: DesignToken.amber),
      SizedBox(width: 8),
      Text('Premium'),
    ],
  ),
)
''',
      ),
    );
  }
}

class _GradientExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BalajiTopNavBarPresets.gradient(
        title: 'Gradient Style',
      ),
      body: _ExampleContent(
        title: 'Gradient Background',
        description: 'Beautiful gradient background using design tokens.',
        code: '''
BalajiTopNavBarPresets.gradient(
  title: 'Gradient Style',
)
''',
      ),
    );
  }
}

class _PrimaryExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BalajiTopNavBarPresets.primary(
        title: 'Primary Color',
      ),
      body: _ExampleContent(
        title: 'Primary Color Background',
        description: 'Using the brand primary color for the navigation bar.',
        code: '''
BalajiTopNavBarPresets.primary(
  title: 'Primary Color',
)
''',
      ),
    );
  }
}

class _TransparentExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: DesignToken.successGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: BalajiTopNavBarPresets.transparent(
            title: 'Transparent',
          ),
          body: _ExampleContent(
            title: 'Transparent Navigation Bar',
            description: 'Perfect for pages with custom backgrounds or gradients.',
            code: '''
BalajiTopNavBarPresets.transparent(
  title: 'Transparent',
)
''',
            textColor: DesignToken.white,
          ),
        ),
      ],
    );
  }
}

class _ElevatedExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BalajiTopNavBar(
        titleText: 'With Elevation',
        elevation: 4,
        backgroundColor: DesignToken.white,
      ),
      body: _ExampleContent(
        title: 'Navigation Bar with Elevation',
        description: 'Adding elevation creates a shadow effect for depth.',
        code: '''
BalajiTopNavBar(
  titleText: 'With Elevation',
  elevation: 4,
  backgroundColor: DesignToken.white,
)
''',
      ),
    );
  }
}

class _SearchExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BalajiTopNavBar(
        titleText: 'Search',
        bottom: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: DesignToken.grey50,
            ),
          ),
        ),
        bottomHeight: 72,
      ),
      body: _ExampleContent(
        title: 'With Search Bar',
        description: 'Add a search bar or any widget below the navigation bar.',
        code: '''
BalajiTopNavBar(
  titleText: 'Search',
  bottom: TextField(...),
  bottomHeight: 72,
)
''',
      ),
    );
  }
}

class _CustomLeadingExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BalajiTopNavBar(
        titleText: 'Profile',
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: DesignToken.primary,
            child: const Text('JD'),
          ),
        ),
        leadingWidth: 56,
      ),
      body: _ExampleContent(
        title: 'Custom Leading Widget',
        description: 'Replace the back button with any custom widget.',
        code: '''
BalajiTopNavBar(
  titleText: 'Profile',
  leading: CircleAvatar(...),
  leadingWidth: 56,
)
''',
      ),
    );
  }
}

class _ModalExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BalajiTopNavBarPresets.modal(
        title: 'Filter Options',
        onClose: () => Navigator.pop(context),
      ),
      body: _ExampleContent(
        title: 'Modal Style',
        description: 'Perfect for bottom sheets and modal screens with close button.',
        code: '''
BalajiTopNavBarPresets.modal(
  title: 'Filter Options',
  onClose: () => Navigator.pop(context),
)
''',
      ),
    );
  }
}

class _BorderExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BalajiTopNavBar(
        titleText: 'With Border',
        showBottomBorder: true,
      ),
      body: _ExampleContent(
        title: 'With Bottom Border',
        description: 'A subtle border line separates the navigation bar from content.',
        code: '''
BalajiTopNavBar(
  titleText: 'With Border',
  showBottomBorder: true,
)
''',
      ),
    );
  }
}

class _ExampleContent extends StatelessWidget {
  final String title;
  final String description;
  final String code;
  final Color? textColor;

  const _ExampleContent({
    required this.title,
    required this.description,
    required this.code,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? context.colors.textDark;
    
    return SingleChildScrollView(
      padding: DesignToken.paddingAllLG,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.text.heading3.copyWith(color: color),
          ),
          context.spacing.heightMD,
          Text(
            description,
            style: context.text.bodyLarge.copyWith(color: color),
          ),
          context.spacing.heightXL2,
          Text(
            'Code:',
            style: context.text.heading6.copyWith(color: color),
          ),
          context.spacing.heightSM,
          Container(
            padding: DesignToken.paddingAllMD,
            decoration: BoxDecoration(
              color: context.colors.grey900.withValues(alpha: 0.9),
              borderRadius: context.radius.borderMD,
            ),
            child: SelectableText(
              code,
              style: TextStyle(
                fontFamily: 'monospace',
                color: DesignToken.greenShade300,
                fontSize: context.text.sm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

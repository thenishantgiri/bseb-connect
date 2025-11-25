# Reusable Widgets

This directory contains reusable UI components for the BSEB Connect app. All widgets are designed for consistency, type safety, and ease of use across the application.

## Available Widgets

### 1. Buttons (`custom_button.dart`)

#### CustomButton
A reusable button widget with consistent styling and loading states.

```dart
CustomButton(
  text: 'Login',
  onPressed: () => _handleLogin(),
  isLoading: _isLoading,
  icon: Icons.login,
)
```

**Properties:**
- `text` (required): Button label
- `onPressed`: Callback when pressed
- `isLoading`: Shows loading spinner when true
- `backgroundColor`: Custom background color (defaults to theme orange)
- `textColor`: Custom text color (defaults to white)
- `width`: Custom width (defaults to full width)
- `height`: Custom height (defaults to 50)
- `icon`: Optional icon to display before text
- `borderRadius`: Border radius (defaults to 8.0)

---

### 2. Text Fields (`custom_text_field.dart`)

#### CustomTextField
Reusable text field with consistent styling and validation support.

```dart
CustomTextField(
  controller: _emailController,
  labelText: 'Email',
  hintText: 'Enter your email',
  prefixIcon: Icons.email,
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value?.isEmpty ?? true) return 'Email required';
    return null;
  },
)
```

**Properties:**
- `controller`: TextEditingController
- `labelText`: Field label
- `hintText`: Placeholder text
- `errorText`: Error message to display
- `prefixIcon`: Icon at the start
- `suffixIcon`: Widget at the end
- `obscureText`: Hide text (for passwords)
- `keyboardType`: Keyboard type
- `inputFormatters`: Input formatters
- `validator`: Validation function
- `onChanged`: Callback on text change
- `onTap`: Callback on tap
- `readOnly`: Make field read-only
- `maxLines`: Maximum lines (defaults to 1)
- `maxLength`: Maximum character length
- `enabled`: Enable/disable field
- `textCapitalization`: Text capitalization mode

#### PhoneTextField
Specialized text field for 10-digit Indian phone numbers.

```dart
PhoneTextField(
  controller: _phoneController,
  onChanged: (value) => print(value),
)
```

**Features:**
- Automatically limits to 10 digits
- Only accepts numeric input
- Built-in validation for 10-digit numbers
- Phone icon prefix

---

### 3. Loading Indicators (`loading_indicator.dart`)

#### LoadingIndicator
Centered loading spinner with optional message.

```dart
LoadingIndicator(
  message: 'Loading your data...',
  size: 50.0,
)
```

**Properties:**
- `message`: Optional text below spinner
- `size`: Spinner size (defaults to 50)
- `color`: Custom spinner color (defaults to theme orange)

#### LoadingOverlay
Full-screen loading overlay with semi-transparent background.

```dart
LoadingOverlay(
  message: 'Please wait...',
)
```

**Use case:** Display over existing content while loading

#### SmallLoadingIndicator
Compact inline loading spinner for buttons or small spaces.

```dart
SmallLoadingIndicator(
  color: Colors.white,
)
```

**Properties:**
- `color`: Spinner color (defaults to theme orange)
- Fixed 20x20 size

---

### 4. Empty States (`empty_state.dart`)

#### EmptyState
Generic empty state widget for "no data" scenarios.

```dart
EmptyState(
  icon: Icons.search_off,
  title: 'No Results',
  message: 'Try adjusting your filters',
  actionText: 'Retry',
  onAction: () => _retry(),
)
```

**Properties:**
- `icon` (required): Icon to display
- `title` (required): Main title
- `message`: Optional description
- `actionText`: Optional button text
- `onAction`: Optional button callback

#### Pre-built Empty States

**NoNotificationsState**
```dart
NoNotificationsState()
```
Shows: "No Notifications" with appropriate icon and message

**NoResultsState**
```dart
NoResultsState()
```
Shows: "No Results Found" for search/filter scenarios

**NoDataState**
```dart
NoDataState(
  message: 'Custom message here', // optional
)
```
Shows: Generic "No Data Available" state

---

### 5. Cards (`custom_card.dart`)

#### CustomCard
Base card widget with consistent styling.

```dart
CustomCard(
  padding: EdgeInsets.all(16),
  margin: EdgeInsets.all(8),
  onTap: () => _handleTap(),
  child: Text('Card content'),
)
```

**Properties:**
- `child` (required): Card content
- `padding`: Internal padding (defaults to 16)
- `margin`: External margin (defaults to horizontal: 16, vertical: 8)
- `color`: Background color (defaults to white)
- `elevation`: Shadow elevation (defaults to 2)
- `onTap`: Optional tap callback
- `borderRadius`: Border radius (defaults to 12)

#### MenuCard
Specialized card for home screen menu items with icon + label.

```dart
MenuCard(
  icon: Icons.person,
  label: 'My Profile',
  onTap: () => Get.to(() => ProfileScreen()),
  iconColor: Colors.blue,
  backgroundColor: Colors.blue,
)
```

**Properties:**
- `icon` (required): Icon to display
- `label` (required): Text below icon
- `onTap` (required): Tap callback
- `iconColor`: Icon color (defaults to theme primary)
- `backgroundColor`: Background color for icon container (defaults to theme primary)

**Layout:**
- Circular icon container with 10% opacity background
- Centered layout
- Max 2 lines for label with ellipsis overflow

#### InfoCard
Card for displaying key-value information pairs.

```dart
InfoCard(
  title: 'Roll Number',
  value: '123456789',
  icon: Icons.badge,
)
```

**Properties:**
- `title` (required): Label text (smaller, grey)
- `value` (required): Value text (larger, bold)
- `icon`: Optional icon at the start

**Layout:**
- Horizontal layout with optional icon
- Title in grey, value in bold dark text
- Consistent spacing and typography

---

## Usage Guidelines

### 1. Importing Widgets

```dart
import 'package:bseb_connect/widgets/custom_button.dart';
import 'package:bseb_connect/widgets/custom_text_field.dart';
import 'package:bseb_connect/widgets/loading_indicator.dart';
import 'package:bseb_connect/widgets/empty_state.dart';
import 'package:bseb_connect/widgets/custom_card.dart';
```

### 2. Consistency
Always use these widgets instead of creating one-off UI elements. This ensures:
- Consistent styling across the app
- Easier maintenance
- Centralized updates (change once, applies everywhere)
- Better UX

### 3. Customization
All widgets support customization through parameters. Only customize when necessary to maintain consistency.

### 4. Examples

#### Login Form
```dart
Form(
  child: Column(
    children: [
      CustomTextField(
        controller: _phoneController,
        labelText: 'Phone Number',
        prefixIcon: Icons.phone,
      ),
      SizedBox(height: 16),
      CustomButton(
        text: 'Login',
        onPressed: _isValid ? () => _login() : null,
        isLoading: _isLoading,
      ),
    ],
  ),
)
```

#### List with Empty State
```dart
Widget build(BuildContext context) {
  if (_isLoading) {
    return LoadingIndicator(message: 'Loading notifications...');
  }

  if (_notifications.isEmpty) {
    return NoNotificationsState();
  }

  return ListView.builder(
    itemCount: _notifications.length,
    itemBuilder: (context, index) => CustomCard(
      child: ListTile(/* ... */),
    ),
  );
}
```

#### Home Screen Grid
```dart
GridView.count(
  crossAxisCount: 2,
  children: [
    MenuCard(
      icon: Icons.person,
      label: 'My Profile',
      onTap: () => Get.to(() => ProfileScreen()),
    ),
    MenuCard(
      icon: Icons.school,
      label: 'Results',
      onTap: () => Get.to(() => ResultsScreen()),
    ),
    // ... more menu items
  ],
)
```

---

## Design Tokens

All widgets use consistent design tokens from the app theme:

- **Primary Color**: Orange (`CustomColors.theme_orange`)
- **Card Radius**: 12px
- **Button Radius**: 8px
- **Input Radius**: 8px
- **Card Elevation**: 2
- **Standard Padding**: 16px
- **Standard Margin**: horizontal: 16, vertical: 8

---

## Migration Guide

If you're updating existing screens to use these widgets:

### Before:
```dart
ElevatedButton(
  onPressed: () => _login(),
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(CustomColors.theme_orange),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: Text('Login'),
)
```

### After:
```dart
CustomButton(
  text: 'Login',
  onPressed: () => _login(),
)
```

**Benefits:**
- 10 lines → 3 lines
- Consistent styling automatically
- Built-in loading state support

---

## Contributing

When adding new widgets to this directory:

1. **Follow the pattern:** Widget class + documentation + usage examples
2. **Use dartdoc comments:** Document all public properties with `///`
3. **Provide examples:** Include usage examples in comments
4. **Keep it simple:** Widgets should do one thing well
5. **Type safety:** Use proper types, avoid `dynamic`
6. **Consistent naming:** Use descriptive names (e.g., `CustomButton`, not `MyButton`)

---

## Testing

All widgets have been tested and verified:
```bash
flutter analyze lib/widgets/
# Result: No errors, only minor const optimization suggestions
```

---

## Questions?

For implementation questions or suggestions, refer to:
- Individual widget files for detailed documentation
- `ARCHITECTURE.md` for overall app structure
- Existing screen implementations for usage examples

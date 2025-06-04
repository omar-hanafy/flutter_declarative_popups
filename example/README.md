# Flutter Declarative Popups Example

This example demonstrates how to use the `flutter_declarative_popups` package.

## Features Demonstrated

### Material Design Popups
- **DialogPage** - Shows various dialog styles
- **ModalBottomSheetPage** - Bottom sheets with different configurations
- **Scrollable Bottom Sheets** - Using DraggableScrollableSheet

### Cupertino (iOS) Style Popups
- **CupertinoModalPopupPage** - Action sheets and modal popups
- **CupertinoSheetPage** - Full iOS-style sheet presentations

### Custom Implementations
- **RawDialogPage** - Completely custom popup designs
- **Nested Navigation** - Multi-step forms within sheets

### Extension Methods
- **showDeclarativeDialog** - Imperative-style dialog showing
- **showDeclarativeModalBottomSheet** - Imperative-style bottom sheet
- **createDialogPage** - Creating pages for declarative navigation

## Running the Example

1. Clone the repository
2. Navigate to the example directory:
   ```bash
   cd example
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Code Structure

The example app demonstrates:

1. **Declarative Navigation** - Using Navigator 2.0 with pages
2. **Extension Methods** - Convenient ways to show popups
3. **State Management** - Managing popup state declaratively
4. **Result Handling** - Getting results from popups

## Key Files

- `lib/main.dart` - Main example app with all demonstrations
- Shows both declarative and imperative approaches
- Demonstrates proper state management with popups

## Screenshots

The example app shows:
- A home screen with buttons to trigger different popup types
- Result display showing the last action taken
- Various popup styles from both Material and Cupertino libraries

## Learn More

For more information about using the package, see the [main package documentation](https://pub.dev/packages/flutter_declarative_popups).

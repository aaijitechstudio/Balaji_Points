# 📝 Logger Usage Guide

## Quick Reference

### Import
```dart
import 'package:balaji_points/core/utils/logger.dart';
```

### Log Levels

#### 1. Debug (Logger.d) 
**When to use:** Development debugging only  
**Behavior:** Auto-disabled in production

```dart
Logger.d('User data loaded');
Logger.d('Response received', data: response);
```

#### 2. Info (Logger.i)
**When to use:** Important user actions and events  
**Behavior:** Always logged

```dart
Logger.i('User logged in successfully');
Logger.i('Bill submitted', data: billId);
Logger.i('Profile updated');
```

#### 3. Warning (Logger.w)
**When to use:** Potential issues or deprecated usage  
**Behavior:** Always logged

```dart
Logger.w('Missing optional field', data: fieldName);
Logger.w('API deprecated endpoint used');
```

#### 4. Error (Logger.e)
**When to use:** Errors and exceptions  
**Behavior:** Always logged with full stack trace

```dart
try {
  // risky operation
} catch (e, stackTrace) {
  Logger.e('Operation failed', error: e, stackTrace: stackTrace);
}

// Shorter version (without stack trace)
Logger.e('API call failed', error: errorMessage);
```

---

## Migration Examples

### Before (using print)
```dart
// ❌ Debug prints
print('🔍 [DEBUG] User exists');
print('Response: $response');

// ❌ Error prints
print('Error: $e');
print('❌ ERROR: Failed to load data');

// ❌ Info prints
print('✅ User logged in');
```

### After (using Logger)
```dart
// ✅ Debug logs (auto-disabled in production)
Logger.d('User exists');
Logger.d('Response received', data: response);

// ✅ Error logs
Logger.e('Error occurred', error: e, stackTrace: stackTrace);
Logger.e('Failed to load data', error: errorMessage);

// ✅ Info logs
Logger.i('User logged in successfully');
```

---

## Best Practices

### ✅ DO

1. **Use appropriate log level**
   ```dart
   Logger.d('Debugging info');      // Development only
   Logger.i('Important event');      // Production
   Logger.w('Potential issue');      // Production
   Logger.e('Error', error: e);      // Production with stack trace
   ```

2. **Include context in error logs**
   ```dart
   try {
     await submitBill(billId);
   } catch (e, stackTrace) {
     Logger.e('Failed to submit bill', error: e, stackTrace: stackTrace);
   }
   ```

3. **Use data parameter for additional context**
   ```dart
   Logger.i('User action completed', data: {
     'userId': userId,
     'action': 'bill_submit',
     'billId': billId,
   });
   ```

### ❌ DON'T

1. **Don't use print() anymore**
   ```dart
   // ❌ Wrong
   print('User logged in');
   
   // ✅ Correct
   Logger.i('User logged in');
   ```

2. **Don't log sensitive data**
   ```dart
   // ❌ Wrong - exposes PIN
   Logger.d('PIN entered: $pin');
   
   // ✅ Correct - no sensitive data
   Logger.d('PIN validation started');
   ```

3. **Don't overuse debug logs**
   ```dart
   // ❌ Wrong - too verbose
   Logger.d('Step 1');
   Logger.d('Step 2');
   Logger.d('Step 3');
   
   // ✅ Correct - meaningful logs only
   Logger.d('Bill submission started');
   Logger.d('Bill submission completed');
   ```

4. **Don't use debug logs for production events**
   ```dart
   // ❌ Wrong - important event should be Logger.i
   Logger.d('Payment received');
   
   // ✅ Correct
   Logger.i('Payment received', data: amount);
   ```

---

## Common Patterns

### Pattern 1: API Calls
```dart
Future<User> getUser(String userId) async {
  try {
    Logger.d('Fetching user data', data: userId);  // Debug only
    
    final response = await api.getUser(userId);
    
    Logger.i('User data loaded', data: userId);  // Production
    return response;
    
  } catch (e, stackTrace) {
    Logger.e('Failed to fetch user', error: e, stackTrace: stackTrace);
    rethrow;
  }
}
```

### Pattern 2: User Actions
```dart
Future<void> submitBill(Bill bill) async {
  Logger.i('Bill submission started', data: {
    'carpenterId': bill.carpenterId,
    'amount': bill.amount,
  });
  
  try {
    await billService.submit(bill);
    Logger.i('Bill submitted successfully', data: bill.id);
  } catch (e, stackTrace) {
    Logger.e('Bill submission failed', error: e, stackTrace: stackTrace);
    rethrow;
  }
}
```

### Pattern 3: State Changes
```dart
void _onAuthStateChanged(AuthState state) {
  if (state is AuthenticatedState) {
    Logger.i('User authenticated', data: state.user.id);
  } else if (state is AuthErrorState) {
    Logger.e('Authentication failed', error: state.message);
  } else {
    Logger.d('Auth state changed: ${state.runtimeType}');
  }
}
```

---

## Production Behavior

### Debug Mode (Development)
```dart
Logger.d('Debug message');  // ✅ Logged
Logger.i('Info message');   // ✅ Logged
Logger.w('Warning');        // ✅ Logged
Logger.e('Error', error: e); // ✅ Logged
```

### Release Mode (Production)
```dart
Logger.d('Debug message');  // ❌ Not logged (auto-disabled)
Logger.i('Info message');   // ✅ Logged
Logger.w('Warning');        // ✅ Logged
Logger.e('Error', error: e); // ✅ Logged
```

---

## Configuration

The Logger is configured in `lib/core/utils/logger.dart`:

```dart
static final log_pkg.Logger _logger = log_pkg.Logger(
  printer: log_pkg.PrettyPrinter(
    methodCount: 0,          // Don't show method stack
    errorMethodCount: 5,     // Show 5 methods for errors
    lineLength: 80,          // Wrap at 80 chars
    colors: true,            // Use colors
    printEmojis: true,       // Use emojis for levels
    printTime: false,        // Don't print timestamp
  ),
  level: kDebugMode 
    ? log_pkg.Level.debug    // Show all logs in debug
    : log_pkg.Level.warning, // Only warnings/errors in release
);
```

---

## Troubleshooting

### Issue: Logger not found
**Solution:** Add import
```dart
import 'package:balaji_points/core/utils/logger.dart';
```

### Issue: Named parameter error
**Solution:** Use named parameters for Logger.e()
```dart
// ❌ Wrong
Logger.e('Error message', error);

// ✅ Correct
Logger.e('Error message', error: error, stackTrace: stackTrace);
```

### Issue: Too many logs in production
**Solution:** Use Logger.d() instead of Logger.i() for debug info
```dart
// ❌ Wrong - logs in production
Logger.i('Debug information');

// ✅ Correct - auto-disabled in production
Logger.d('Debug information');
```

---

## Summary

| Log Level | Method | Production | Use Case |
|-----------|--------|-----------|----------|
| Debug | `Logger.d()` | ❌ Disabled | Development debugging |
| Info | `Logger.i()` | ✅ Enabled | Important events |
| Warning | `Logger.w()` | ✅ Enabled | Potential issues |
| Error | `Logger.e()` | ✅ Enabled | Errors & exceptions |

**Remember:** Logger.d() is your friend for debugging - it automatically disappears in production! 🎯

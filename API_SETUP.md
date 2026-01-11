# API Configuration Setup

## Getting Your Gemini API Key

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the generated API key

## Setting Up the API Key

### Option 1: Environment Variable (Recommended)
1. Create a `.env` file in the project root
2. Add: `GEMINI_API_KEY=your_actual_api_key_here`
3. Run with: `flutter run --dart-define-from-file=.env`

### Option 2: Direct Configuration
1. Open `lib/services/gemini_service.dart`
2. Replace `YOUR_GEMINI_API_KEY_HERE` with your actual API key
3. **Warning**: Don't commit this to version control

## Testing the API
The app will use fallback responses if the API key is not configured or if there are connection issues.
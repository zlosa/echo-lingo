# Context-Aware Translation Feature Design

## Overview
Add contextual intelligence to EchoLingo's translation engine, allowing users to specify the situation or purpose of their communication to receive more appropriate, nuanced translations.

## Current vs Enhanced Flow

### Current Flow
```
User Audio → Transcription → Direct Translation → TTS → Output Audio
```

### Enhanced Flow
```
Context Input → User Audio → Transcription → Context-Aware Translation → TTS → Output Audio
```

## Feature Requirements

### Core Functionality
- **Context Input**: Allow users to specify the communication context
- **Enhanced Translation**: Use context to improve translation quality and appropriateness
- **Context Persistence**: Remember last used context for convenience
- **Context History**: Track most-used contexts for quick access

### User Experience Goals
- **Simple Setup**: Easy to set context without disrupting current workflow
- **Smart Suggestions**: Provide common context templates
- **Quick Access**: Fast switching between different contexts
- **Visual Clarity**: Clear indication when context is active

## Technical Design

### 1. Context Data Structure

```typescript
interface TranslationContext {
  id: string;
  name: string;
  description: string;
  category: ContextCategory;
  prompt: string;
  isCustom: boolean;
  usageCount: number;
  lastUsed: Date;
}

enum ContextCategory {
  SOCIAL = "social",
  BUSINESS = "business", 
  TRAVEL = "travel",
  ROMANTIC = "romantic",
  EMERGENCY = "emergency",
  CUSTOM = "custom"
}
```

### 2. Pre-defined Context Templates

#### Social Contexts
- **Casual Conversation**: "Make this sound friendly and conversational"
- **Compliment**: "Help me give a genuine, appropriate compliment"
- **Apology**: "Help me express a sincere apology"
- **Small Talk**: "Make this appropriate for light, casual conversation"

#### Romantic Contexts
- **Pickup Line**: "Help me craft a charming, respectful pickup line"
- **Date Conversation**: "Make this appropriate for a romantic date"
- **Flirting**: "Help me flirt in a tasteful, culturally appropriate way"

#### Business Contexts
- **Meeting**: "Make this professional and meeting-appropriate"
- **Negotiation**: "Help me communicate diplomatically in business"
- **Presentation**: "Make this clear and professional for a presentation"
- **Email Tone**: "Convert this to professional email language"

#### Travel Contexts
- **Ordering Food**: "Help me order food politely at a restaurant"
- **Asking Directions**: "Help me ask for directions clearly"
- **Hotel/Accommodation**: "Make this appropriate for hotel interactions"
- **Emergency Help**: "Help me communicate an urgent need for help"

### 3. Backend Integration

#### Enhanced Translation Service

```python
# backend/src/services/translation.py

async def translate_text_with_context(
    text: str, 
    target_language: str,
    context: str = None
) -> str:
    """
    Translate text using context-aware prompting
    """
    if context:
        # Create context-enhanced prompt
        prompt = f"""
        Context: {context}
        
        Translate the following text to {target_language}, 
        taking into account the context provided. 
        Make the translation culturally appropriate and 
        suitable for the given situation.
        
        Text to translate: "{text}"
        
        Provide only the translation, no explanation.
        """
    else:
        # Fallback to simple translation
        prompt = f"Translate to {target_language}: {text}"
    
    # Use existing provider with enhanced prompt
    provider = get_translation_provider()
    return await provider.translate_with_prompt(prompt, target_language)
```

#### API Route Updates

```python
# backend/src/api/routes/audio.py

@router.post("/process", response_model=AudioResponse)
async def process_audio(
    # ... existing parameters ...
    context: Optional[str] = Query(None, description="Translation context for enhanced results"),
):
    # ... existing transcription logic ...
    
    # Enhanced translation with context
    if should_translate:
        translated_text = await translation.translate_text_with_context(
            transcribed_text, target_language, context
        )
    
    # ... rest of existing logic ...
```

### 4. Frontend Implementation

#### Context Selector Component

```typescript
// mobile/app/components/ContextSelector.tsx

interface ContextSelectorProps {
  selectedContext: TranslationContext | null;
  onContextChange: (context: TranslationContext | null) => void;
}

export function ContextSelector({ selectedContext, onContextChange }: ContextSelectorProps) {
  return (
    <View style={styles.container}>
      {/* Context Input Field */}
      <TextInput 
        placeholder="Describe your situation (e.g., 'help me order food')"
        value={customContext}
        onChangeText={setCustomContext}
        style={styles.contextInput}
      />
      
      {/* Quick Context Buttons */}
      <ScrollView horizontal style={styles.quickContexts}>
        {PREDEFINED_CONTEXTS.map(context => (
          <Pressable 
            key={context.id}
            style={[
              styles.contextButton,
              selectedContext?.id === context.id && styles.selectedContext
            ]}
            onPress={() => onContextChange(context)}
          >
            <Text style={styles.contextButtonText}>{context.name}</Text>
          </Pressable>
        ))}
      </ScrollView>
      
      {/* Clear Context Button */}
      {selectedContext && (
        <Pressable 
          style={styles.clearButton}
          onPress={() => onContextChange(null)}
        >
          <Text style={styles.clearButtonText}>Clear Context</Text>
        </Pressable>
      )}
    </View>
  );
}
```

#### Main Screen Integration

```typescript
// mobile/app/(tabs)/index.tsx - Key additions

export default function TranslateScreen() {
  // ... existing state ...
  const [selectedContext, setSelectedContext] = useState<TranslationContext | null>(null);
  const [showContextSelector, setShowContextSelector] = useState(false);

  // Enhanced processAudio function
  const processAudio = async (uri: string, originalAudioUri: string) => {
    // ... existing setup ...
    
    const response = await axios.post(`${API_URL}/api/audio/process`, formData, {
      params: {
        target_language: selectedLanguage.name,
        voice_provider: voiceProviderSettings.provider,
        voice_id: currentVoiceId,
        context: selectedContext?.prompt || undefined, // Add context
      },
      // ... rest of config
    });
    
    // ... rest of existing logic ...
  };

  return (
    <View style={styles.container}>
      {/* Context Selector */}
      <Pressable 
        style={styles.contextToggle}
        onPress={() => setShowContextSelector(!showContextSelector)}
      >
        <Ionicons name="settings-outline" size={20} color="#4CAF50" />
        <Text style={styles.contextToggleText}>
          {selectedContext ? selectedContext.name : "Add Context"}
        </Text>
      </Pressable>

      {showContextSelector && (
        <ContextSelector 
          selectedContext={selectedContext}
          onContextChange={setSelectedContext}
        />
      )}

      {/* Existing UI components */}
      {/* ... */}
    </View>
  );
}
```

## Implementation Plan

### Phase 1: Core Context System
1. **Backend Context Processing**
   - Enhance translation service with context parameter
   - Update API route to accept context
   - Add context-aware prompting to LLM calls

2. **Basic Frontend Integration**
   - Add context input field to main screen
   - Implement context state management
   - Test with custom context strings

### Phase 2: Predefined Contexts
1. **Context Template System**
   - Create predefined context library
   - Implement context categories
   - Add context storage/persistence

2. **Enhanced UI**
   - Quick context selection buttons
   - Context history and favorites
   - Visual context indicators

### Phase 3: Advanced Features
1. **Smart Context Suggestions**
   - ML-based context recommendation
   - Learning from user patterns
   - Auto-context detection

2. **Context Analytics**
   - Usage tracking and insights
   - Context effectiveness measurement
   - A/B testing for translation quality

## Data Storage

### AsyncStorage Keys
```typescript
const CONTEXT_STORAGE_KEYS = {
  SELECTED_CONTEXT: '@selected_context',
  CUSTOM_CONTEXTS: '@custom_contexts', 
  CONTEXT_HISTORY: '@context_history',
  CONTEXT_USAGE_STATS: '@context_usage_stats'
};
```

### Context Persistence
- Save last used context for quick reuse
- Store custom user-created contexts
- Track context usage statistics for optimization

## Success Metrics

### User Experience
- **Adoption Rate**: % of users who try context feature
- **Retention Rate**: % of users who continue using context
- **Context Usage**: Average contexts used per session

### Translation Quality  
- **User Satisfaction**: Rating improvements with context vs without
- **Context Accuracy**: How often context improves translation appropriateness
- **Error Reduction**: Decrease in translation complaints/corrections

## Example Use Cases

### Scenario 1: Restaurant Visit
```
Context: "Help me order food politely at a restaurant"
User says: "I want chicken"
Without context: "私は鶏肉が欲しいです" (Direct: I want chicken)
With context: "鶏肉料理をお願いします" (Polite: I would like a chicken dish, please)
```

### Scenario 2: Business Meeting
```
Context: "Make this professional for a business meeting"
User says: "That's not good"
Without context: "それは良くない" (Casual: That's not good)  
With context: "その点について懸念があります" (Professional: I have concerns about that point)
```

### Scenario 3: Romantic Context
```
Context: "Help me flirt in a tasteful way"
User says: "You're pretty"
Without context: "あなたはきれいです" (Direct: You are pretty)
With context: "とても素敵ですね" (Charming: You look absolutely lovely)
```

## Technical Considerations

### Performance
- Cache frequently used contexts
- Optimize LLM prompts for speed
- Implement context preprocessing

### Privacy
- Store contexts locally when possible
- Encrypt sensitive context data
- Allow context deletion/clearing

### Localization
- Translate context templates to user's native language
- Ensure cultural appropriateness across regions
- Adapt contexts for different cultural norms

## Future Enhancements

### AI-Powered Features
- **Auto-Context Detection**: Analyze audio tone/content to suggest context
- **Context Learning**: Learn user preferences for automatic context application
- **Conversation Context**: Maintain context across multiple translations in a conversation

### Social Features
- **Context Sharing**: Share effective contexts with community
- **Context Marketplace**: User-generated context templates
- **Context Collaboration**: Team/family shared context sets

### Advanced Personalization
- **Voice-Context Matching**: Different voices for different contexts
- **Style Preferences**: Personal style profiles within contexts
- **Cultural Adaptation**: Context templates adapted to user's cultural background
#!/bin/bash

# Configuration
# This uses a free/open API for a "Smart Explain" effect.
# You can later replace this with Ollama (local) or OpenAI API.

word=$(wl-paste -p 2>/dev/null || wl-paste 2>/dev/null)

if [ -z "$word" ]; then
    notify-send "AI Quick Ask" "No text selected to explain."
    exit 1
fi

notify-send "AI Thinking..." "Analyzing: \"${word:0:30}...\""

# For now, we'll use a sophisticated "Smart Lookup" that combines 
# dictionary and thesaurus for context.
# We'll use your existing define.sh logic but expand it for better display.

response=$(curl -s "https://api.dictionaryapi.dev/api/v2/entries/en_US/$word")

if [[ "$response" == *"No Definitions Found"* ]]; then
    # Fallback: Just search online
    notify-send "AI Quick Ask" "Could not find definition. Opening search..."
    xdg-open "https://www.google.com/search?q=what+is+$word" &
else
    # Extract definition and example
    definition=$(echo "$response" | jq -r '.[0].meanings[0].definitions[0].definition')
    example=$(echo "$response" | jq -r '.[0].meanings[0].definitions[0].example')
    
    # Show in a nice notification
    if [ "$example" != "null" ]; then
        notify-send -t 15000 "AI Explanation: $word" "<b>Definition:</b>\n$definition\n\n<b>Example:</b>\n<i>$example</i>"
    else
        notify-send -t 15000 "AI Explanation: $word" "<b>Definition:</b>\n$definition"
    fi
fi

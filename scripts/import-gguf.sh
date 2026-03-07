#!/usr/bin/env bash
set -e

if [ -z "$1" ]; then
    echo "Usage: import-gguf <path-to-model.gguf> [model-name]"
    echo "Example: import-gguf ~/Downloads/llama3.gguf llama3-local"
    exit 1
fi

GGUF_FILE=$(realpath "$1")
MODEL_NAME=${2:-$(basename "$GGUF_FILE" .gguf)}

if [ ! -f "$GGUF_FILE" ]; then
    echo "Error: File $GGUF_FILE not found."
    exit 1
fi

echo "📦 Importing $GGUF_FILE into Ollama as '$MODEL_NAME'..."

TMP_MODELFILE=$(mktemp)
echo "FROM \"$GGUF_FILE\"" > "$TMP_MODELFILE"

# Create the model in Ollama
ollama create "$MODEL_NAME" -f "$TMP_MODELFILE"

rm -f "$TMP_MODELFILE"

echo ""
echo "✅ Model '$MODEL_NAME' successfully imported!"
echo "🌐 You can now select it in Open WebUI at http://localhost:8080"

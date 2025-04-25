#!/bin/bash

echo "--- Starting Ollama Setup Script ---"

# Variables (adjust if needed, but should match Modelfile/notebook)
BASE_MODEL_TAG="artifish/llama3.2-uncensored"
CUSTOM_MODEL_TAG="artifish/llama3.2-uncensored-8k"
MODELFILE_NAME="IncreaseContext.Modelfile" # Assumes it's downloaded to current dir

# 1. Install Ollama
echo "[1/4] Installing Ollama..."
curl -fsSL https://ollama.ai/install.sh | sh

# 2. Start Ollama server in background
echo "[2/4] Starting Ollama server in background..."
ollama serve &
SERVER_PID=$!
echo "Server started with PID: ${SERVER_PID}. Waiting 10 seconds..."
sleep 10

# Check if server is running
if ! kill -0 ${SERVER_PID} > /dev/null 2>&1; then
    echo "ERROR: Ollama server failed to start."
    exit 1
fi

# 3. Pull base model
echo "[3/4] Pulling base model ${BASE_MODEL_TAG}..."
ollama pull ${BASE_MODEL_TAG}

# 4. Create custom model
echo "[4/4] Creating custom model ${CUSTOM_MODEL_TAG}..."
if [ -f "${MODELFILE_NAME}" ]; then
  ollama create ${CUSTOM_MODEL_TAG} -f ${MODELFILE_NAME}
  CREATE_STATUS=$?
  if [ ${CREATE_STATUS} -ne 0 ]; then
    echo "ERROR: 'ollama create' failed with status ${CREATE_STATUS}."
    exit 1
  fi
  # Optional: Verify parameters
  echo "Verifying parameters:"
  ollama show --modelfile ${CUSTOM_MODEL_TAG} | grep "PARAMETER num_"
else
  echo "ERROR: Modelfile ${MODELFILE_NAME} not found in current directory."
  exit 1
fi

echo "--- Ollama Setup Complete ---"
echo "Leave this xterm window open to keep the server running."
echo "Open a second xterm and run: ollama run ${CUSTOM_MODEL_TAG}"

# Keep the script alive (and thus the xterm) so the server doesn't die
# Or just instruct the user to leave the xterm open
# sleep infinity

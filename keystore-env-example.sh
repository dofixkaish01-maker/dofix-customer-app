# Environment Variables for Keystore (Recommended for CI/CD)
# Set these in your environment or CI/CD system

export STORE_PASSWORD=qwerty123
export KEY_PASSWORD=qwerty123
export KEY_ALIAS=key0
export STORE_FILE=../../uploadkeystore.jks

# Then modify your key.properties to read from env vars:
# storePassword=${STORE_PASSWORD}
# keyPassword=${KEY_PASSWORD}
# keyAlias=${KEY_ALIAS}
# storeFile=${STORE_FILE}

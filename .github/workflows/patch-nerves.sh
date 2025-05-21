#!/bin/bash
set -e

# This script patches Nerves to work with clutch_nerves_system_br
# It's to be run during CI before building

# Create the symlink if it doesn't exist
mkdir -p deps
if [ ! -e deps/nerves_system_br ] && [ -d deps/clutch_nerves_system_br ]; then
  echo "Creating symlink from deps/nerves_system_br to deps/clutch_nerves_system_br"
  ln -sf $(realpath deps/clutch_nerves_system_br) deps/nerves_system_br
fi

# Patch the Nerves code directly - find the br.ex file
BR_FILE=$(find deps -name br.ex | grep nerves/lib/nerves/system/br.ex)

if [ -n "$BR_FILE" ]; then
  echo "Found $BR_FILE - creating backup"
  cp "$BR_FILE" "${BR_FILE}.bak"
  
  # Patch the file using sed
  echo "Patching $BR_FILE to look for clutch_nerves_system_br"
  # Replace "Nerves.Env.package(:nerves_system_br)" with more flexible code
  sed -i 's/Nerves.Env.package(:nerves_system_br)/Nerves.Env.package(:nerves_system_br) || Nerves.Env.package(:clutch_nerves_system_br)/g' "$BR_FILE"
  
  echo "Patch applied successfully"
else
  echo "Could not find br.ex file - is nerves installed?"
  exit 1
fi

echo "Nerves patched to work with clutch_nerves_system_br" 
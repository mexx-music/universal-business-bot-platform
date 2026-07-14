#!/usr/bin/env bash
set -euo pipefail

if [ ! -d "build/web" ]; then
  echo "build/web does not exist. Run flutter build web --release first." >&2
  exit 1
fi

cp web/_redirects build/web/_redirects

test -f build/web/index.html
test -f build/web/manifest.json
test -f build/web/flutter_service_worker.js
test -f build/web/icons/Icon-192.png
test -f build/web/icons/Icon-512.png
grep -Fx "/* /index.html 200" build/web/_redirects

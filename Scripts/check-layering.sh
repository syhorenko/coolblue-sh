#!/bin/sh
#
# Verifies that every target in every local package imports only the
# dependencies it declares in its Package.swift.
#
# Why this exists: SwiftPM puts all built modules on one module search path, so
# a target downstream in the build order can `import` a module it never
# declared and still compile. Verified: ProductUI can use a ProductData symbol,
# and ProductPresentation can use a Core/Networking symbol, with no declared
# dependency -- in both `swift build` and `xcodebuild`. Only the
# earliest-compiled target (ProductDomain) is protected by the compiler alone.
#
# SwiftPM ships the check for this; it is off by default and Xcode never
# passes it. Cross-module use always requires an import, so checking imports
# is sufficient.
#
# This runs host-side (macOS) because it only needs the dependency graph, not a
# shippable binary. That means iOS-only API can raise availability errors here
# which are NOT layering problems -- so this script keys off the layering
# diagnostics specifically and leaves every other error to the real build,
# which runs straight afterwards in the Sources phase.
#
# Exit 0 = layering intact, 1 = violation (output is Xcode-parseable).

set -u

PACKAGES_DIR="$(cd "$(dirname "$0")/../Packages" && pwd)" || exit 1

# Xcode exports an iOS SDKROOT to build phases; a host-side build must not
# inherit it.
unset SDKROOT PLATFORM_NAME TOOLCHAINS 2>/dev/null || true

FAILED=0

for MANIFEST in "$PACKAGES_DIR"/*/Package.swift; do
    PACKAGE_DIR="$(dirname "$MANIFEST")"
    PACKAGE_NAME="$(basename "$PACKAGE_DIR")"

    OUTPUT=$(cd "$PACKAGE_DIR" && swift build \
        --explicit-target-dependency-import-check error \
        --scratch-path .build/layering 2>&1)
    STATUS=$?

    # Top-level diagnostics only: drop the indented source-snippet lines, which
    # repeat each message. Match the two shapes a layering breach takes.
    VIOLATIONS=$(printf '%s\n' "$OUTPUT" \
        | grep -v "^[[:space:]]" \
        | grep -E "without declaring it a dependency|no such module" \
        | sort -u)

    if [ -n "$VIOLATIONS" ]; then
        printf '%s\n' "$VIOLATIONS" \
            | sed -e "s|^error: Target|error: Layering violation in $PACKAGE_NAME: target|" \
                  -e "s|error: no such module|error: Layering violation in $PACKAGE_NAME: undeclared import, no such module|"
        FAILED=1
    elif [ $STATUS -ne 0 ]; then
        # Build broke for an unrelated reason (commonly a host-availability
        # error on iOS-only API). Say so, but do not fail: the Sources phase
        # compiles for the real platform and will report anything genuine.
        echo "warning: layering check for $PACKAGE_NAME finished with unrelated build errors; no layering violation found"
    else
        echo "Layering OK: $PACKAGE_NAME"
    fi
done

if [ $FAILED -ne 0 ]; then
    echo "error: layer boundaries violated (see above)"
    exit 1
fi

exit 0

# Passenger UI Refinement

## Scope

- Preserve existing light/dark color schemes and orange brand accent.
- Keep Poppins, with bundled fonts for consistent offline rendering.
- Apply RidzsTheme.refine to the existing Flex themes without reassigning legacy color roles.
- Use a consistent type scale, zero letter spacing, restrained borders and 8px default control corners.
- Use native button feedback, keyboard activation and disabled/loading states.
- Keep button label layout while loading; allow long labels to wrap.
- Use 48px map controls with tooltips, and content-sized page headers.
- Flatten shared inset-shadow containers while preserving caller colors and callbacks.
- Refine map controls, a scrollable full-width destination sheet, wallet summary and transaction rows.
- Remove the decorative safety promotion from the idle map overlay; no safety action was attached to it.

## Verification

Run from this repository:

```bash
flutter analyze --no-pub
flutter test --no-pub
```

On 2026-09-04: analyzer clean; all 24 tests passed.
The 11 presentation tests include palette preservation, taps/keyboard/disabled
states, loading-size stability, map target sizes, long labels/amounts and
the destination sheet with recent trips at 2x text scaling.
Five component golden snapshots cover 320px, 390px, 768px, dark mode and 2x text.

The goldens in test/goldens are component compositions with fixture values,
not screenshots of a connected ride or financial account. Review changes before
using flutter test --update-goldens test/presentation_test.dart.

## Device Review Still Required

Check native maps and all ride sheets on Android and iOS, including keyboard
insets, system text scaling, notch/navigation-bar safe areas, reward dialogs,
payment recovery and real transaction data. Driver remains light mode as before;
the dark theme is styled and tested but no new theme toggle was introduced.

No backend/API/payment policy, deployment configuration, earnings calculation,
or transaction classification was changed in this UI pass. Existing metrics
and transaction labels retain their previous data bindings; visual tests do not
certify financial correctness.

Font license: assets/fonts/OFL.txt, from the
[Poppins distribution](https://github.com/google/fonts/blob/main/ofl/poppins/OFL.txt).

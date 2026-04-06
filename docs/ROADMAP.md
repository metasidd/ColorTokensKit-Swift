# ColorTokensKit Critique & Improvement Roadmap

## Context

ColorTokensKit is an LCH-based color token library for Apple platforms. After a thorough code review and comparison with industry-leading libraries (culori, chroma.js, Color.js, Radix Colors, Tailwind v4, Adobe Leonardo), we've identified gaps ranging from correctness issues to missing table-stakes features. The library's core math is sound, but it lags behind the ecosystem in gamut handling, accessibility, modern color science (OKLCH), test coverage, and performance.

Below is a prioritized breakdown from most important to least important.

---

## Critical (fix now)

### 1. Zero test coverage
- The only test (`MarketingTests.swift`) generates marketing PNGs — no actual assertions
- No round-trip conversion accuracy tests (RGB -> XYZ -> LAB -> LCH -> LAB -> XYZ -> RGB)
- No interpolation tests (hue wrapping at 359->1, edge cases)
- No ramp generation determinism tests
- **Why it matters:** Every other issue on this list could silently regress without tests
- **Action:** Add test suites for conversions, interpolation, ramp generation, and edge cases

### 2. No gamut clamping
- `RGBColor` stores raw CGFloat values with no clamping to [0, 1]
- High-chroma LCH colors (saturated yellows, cyans) produce negative or >1 RGB values
- SwiftUI may silently clamp, causing uncontrolled hue shifts and lightness distortion
- **Files:** `XYZColor+Conversions.swift` (toRGB output), `RGBColor.swift`
- **Action:** At minimum, clamp RGB output to [0, 1]. Ideally, implement chroma reduction that preserves hue (reduce chroma until in-gamut)

### 3. ColorRampGenerator performance — new instance on every stop access
- `LCHColor.getColor(at:)` creates a new `ColorRampGenerator()` on every call
- Accessing `_50` through `_1000` (20 stops) = 20 instances created
- `getPrimaryColor(forHue:)` has the same issue
- **Files:** `LCHColor+Manipulation.swift` lines 28-34, 37-49
- **Action:** Make `ColorRampGenerator` a singleton or use a shared static instance

### 4. Thread safety on static cache
- `ColorRampGenerator.interpolatedRamps` is a static `[String: [LCHColor]]` with no synchronization
- Race condition if accessed from multiple threads (e.g., SwiftUI background rendering)
- **File:** `ColorRampGenerator.swift` lines 20-21
- **Action:** Use `NSLock`, `DispatchQueue`, or make the cache an actor

---

## High (address soon)

### 5. Add WCAG contrast ratio utility
- Every major color library provides this — it's table stakes for a design token library
- Simple formula: relative luminance from sRGB, then `(L1 + 0.05) / (L2 + 0.05)`
- Companies like Linear, Stripe, Slack all use contrast-based token selection
- **Action:** Add `contrastRatio(with:)` on `LCHColor` and/or `Color`

### 6. Consider OKLCH support
- CIELab has known hue linearity problems — blue hues (270-330 degrees) shift toward purple when chroma changes
- OKLCH fixes this; it's now the standard in CSS Color Level 4, Tailwind v4, and modern design tools
- Not necessarily a replacement (CIELab is still valid), but offering OKLCH as an option would modernize the library significantly
- **Action:** Add `OKLABColor` and `OKLCHColor` types with conversions. Could be a follow-up release

### 7. Rounding accumulation in ramp generation
- Rounding to 2-3 decimal places happens at multiple stages in `ColorRampGenerator`:
  - Hue angles (2 dp), interpolation t (3 dp), lerp results (2 dp), progress values (4 dp)
- Cumulative rounding can cause visible banding in subtle color transitions
- **Action:** Defer rounding to the final output step only, use full precision internally

### 8. Sendable conformance
- None of the color types (RGBColor, LABColor, XYZColor, LCHColor) conform to `Sendable`
- These are immutable value types — conformance is trivial and enables safe async/await usage
- **Action:** Add `: Sendable` to all four color space structs

---

## Medium (improve when touching these areas)

### 9. Add Delta E (color difference) API
- Standard perceptual color difference metric (CIE76 is simplest: Euclidean distance in Lab)
- CIEDE2000 is the gold standard but complex — CIE76 is a good starting point
- Useful for: color matching, deduplication, testing ramp uniformity
- **Action:** Add `deltaE(to:)` on `LABColor` and `LCHColor`

### 10. Non-linear lightness curves in ramp generation
- Linear interpolation in LCH produces mathematically even steps but perceptually uneven ramps
- Industry approach: lighter shades need faster falloff, midtones compress for vibrancy, dark stops shift saturation
- chroma.js offers `correctLightness()`; Tailwind hand-tunes curves; Leonardo targets contrast ratios
- **Action:** Allow optional easing/curve function parameter in ramp generation

### 11. Semantic token layer
- Current system: primitive stops (`_50` to `_1000`) + ad-hoc tokens in test target
- Mature systems use 3 tiers: Primitive (blue-500) -> Semantic (color-bg-primary) -> Component (button-bg)
- Radix uses 12 steps with defined purposes (app bg, subtle bg, UI element, borders, solid, text)
- **Action:** Promote the token definitions from test target to the main library, with a structured API

### 12. Error handling improvements
- `ColorRampGenerator.init()` calls `fatalError` if palette JSON fails to load
- `LCHColor.init(lchString:)` uses `try!` on NSRegularExpression
- **Action:** Use throwing init or provide fallback colors instead of crashing

---

## Low (nice to have)

### 13. Code deduplication — interpolation pattern
- `lerp()` is copy-pasted identically across RGB, LAB, XYZ interpolation extensions
- Could unify via a protocol like `Interpolatable`
- **Impact:** Maintainability, not functionality

### 14. Additional color space support
- HSL/HSV conversions (common user request)
- Display P3 gamut awareness (relevant for modern Apple devices)

### 15. Color blindness simulation
- Brettel/Vienot algorithms for protanopia, deuteranopia, tritanopia
- Increasingly expected in accessibility-focused libraries

### 16. Documentation
- No inline docs on conversion math
- No references to CIE standards or academic sources
- No design rationale (why 20 stops? why D65? why these precision constants?)

---

## Summary table

| # | Issue | Severity | Effort |
|---|-------|----------|--------|
| 1 | Test coverage | Critical | Large |
| 2 | Gamut clamping | Critical | Small |
| 3 | Ramp generator performance | Critical | Small |
| 4 | Thread safety | Critical | Small |
| 5 | WCAG contrast ratio | High | Small |
| 6 | OKLCH support | High | Large |
| 7 | Rounding accumulation | High | Medium |
| 8 | Sendable conformance | High | Trivial |
| 9 | Delta E API | Medium | Small |
| 10 | Non-linear lightness curves | Medium | Medium |
| 11 | Semantic token layer | Medium | Medium |
| 12 | Error handling | Medium | Small |
| 13 | Code dedup | Low | Small |
| 14 | HSL/HSV/P3 | Low | Medium |
| 15 | Color blindness sim | Low | Medium |
| 16 | Documentation | Low | Medium |

# Design System Documentation: The Competitive Kineticist

## 1. Overview & Creative North Star: "The Digital Arena"
This design system moves away from the "toy-like" nostalgia often associated with the franchise, pivoting instead toward a **High-End Editorial Sports Aesthetic**. Our North Star is **The Digital Arena**: a space that feels like a premium broadcast for competitive analytics—think Formula 1 telemetry meets elite athletic journals.

We break the "standard grid" template by utilizing **Intentional Asymmetry**. Large-scale typography may bleed off the edge of containers, and Pokemon profile cards utilize overlapping elements (images breaking the frame) to create a sense of kinetic energy. We avoid static, centered layouts in favor of dynamic, left-aligned compositions that feel fast and professional.

## 2. Colors & Surface Architecture
The palette is rooted in the iconic Red/Blue/White triadic, but executed with sophisticated tonal ranges to avoid a "primary school" feel.

### The Palette (Material Design 3 Logic)
*   **Primary (#bb0100):** Our "Competitive Red." Used for high-action triggers and critical brand moments.
*   **Secondary (#425a93):** Our "Tactical Blue." Used for technical UI elements, navigation, and data visualization.
*   **Tertiary (#705900):** A sophisticated Gold for "Elite" status, mastery, or legendary-tier data points.
*   **Surface Hierarchy:** We utilize the `surface-container` tokens to create depth without lines.

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders for sectioning. 
*   **Method:** Define boundaries through background color shifts. A `surface-container-low` section should sit on a `surface` background. 
*   **The Glass & Gradient Rule:** For main CTAs or "Type-Specific" hero sections, use a subtle linear gradient from `primary` to `primary-container`. This adds "soul" and depth. For floating analytics panels, use **Glassmorphism**: semi-transparent surface colors with a `20px` backdrop-blur.

## 3. Typography: High-Contrast Editorial
We pair the technical precision of **Space Grotesk** with the high-readability of **Manrope**.

*   **Display (Space Grotesk):** Large, bold, and aggressive. Used for Pokemon names or win-rate percentages. Use negative letter-spacing (-2%) at display sizes to increase the "premium" feel.
*   **Headline/Title (Space Grotesk):** Sets the tone for technical sections.
*   **Body (Manrope):** Clean and neutral. Manrope’s geometric qualities provide a modern "tech" feel while ensuring competitive stats are legible at small sizes.
*   **Labels (Plus Jakarta Sans):** Used for micro-data (e.g., EV/IV spreads). The slightly wider stance of Jakarta Sans ensures clarity in dense data tables.

## 4. Elevation & Depth: Tonal Layering
Traditional drop shadows are largely replaced by **Tonal Layering**.

*   **The Layering Principle:** Depth is achieved by "stacking."
    *   *Base:* `surface`
    *   *Section:* `surface-container-low`
    *   *Card:* `surface-container-lowest` (This creates a soft "lift").
*   **Ambient Shadows:** If a card must float (e.g., a modal), use a shadow with a `32px` blur, `4%` opacity, tinted with the `secondary` color. Never use pure black shadows.
*   **The "Ghost Border":** For accessibility in dark modes or high-data density, use a `1px` border using `outline-variant` at **15% opacity**. It should be felt, not seen.

## 5. Components & Pattern Library

### Elemental Type Badges (The "Signature" Component)
Instead of flat bubbles, Type Badges use a **Glass-morphic Tonal Shift**.
*   **Fire:** Background of `primary-container` at 20% opacity, a 1px "Ghost Border" of `primary`, and `on-primary-container` text.
*   **Water:** Background of `secondary-container` at 20% opacity, a 1px "Ghost Border" of `secondary`, and `on-secondary-container` text.
*   *Note:* Badges use `rounded-full` (9999px) for a sleek, pill-shaped look.

### Pokemon Profile Cards
*   **Structure:** No dividers. Use `surface-container-highest` for the header area and `surface-container-low` for the stats body.
*   **The "Bleed" Effect:** The Pokemon sprite should overlap the top-left edge of the card, breaking the container boundary.
*   **Typography:** Use `headline-sm` for the name and `label-md` for the Pokedex number.

### Buttons
*   **Primary:** `primary` fill with `on-primary` text. `rounded-md` (0.375rem).
*   **Secondary:** `secondary-container` fill with `on-secondary-container` text. 
*   **States:** On hover, apply a `primary-fixed-dim` overlay.

### Input Fields & Data Tables
*   **Inputs:** Use `surface-container-highest` as the fill. No bottom line. Use a `2px` `primary` left-accent bar only when the field is focused.
*   **Lists/Tables:** Forbid divider lines. Use alternating row colors (zebra striping) with `surface` and `surface-container-low`.

## 6. Do’s and Don’ts

### Do:
*   **Do** use extreme vertical whitespace (32px, 48px, 64px) to separate major data clusters.
*   **Do** use `secondary` (Deep Blue) for all "Actionable" UI icons (edit, share, filter).
*   **Do** utilize `tertiary` (Gold) sparingly—only for 1st place rankings or "Perfect IV" indicators.

### Don’t:
*   **Don’t** use the color Green for anything other than the "Grass" type badge. Use Blue/Red for the primary UI to maintain the "Arena" brand.
*   **Don’t** use default Material Design shadows. They are too heavy for this editorial aesthetic.
*   **Don’t** center-align long blocks of data. Keep it left-aligned to mimic professional telemetry dashboards.
*   **Don’t** use 100% opaque borders. They clutter the UI and distract from the high-contrast typography.
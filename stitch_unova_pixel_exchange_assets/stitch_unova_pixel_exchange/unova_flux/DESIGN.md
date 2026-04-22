```markdown
# Design System Strategy: The Neo-Unova Interface

## 1. Overview & Creative North Star
The Creative North Star for this design system is **"Digital Brutalism: High-Bit Precision."** 

This system rejects the soft, organic "bubble" aesthetics of modern mobile OSs in favor of the rigid, high-resolution architecture of the Unova region. We are blending the nostalgia of 8-bit logic with the sophistication of a high-end fintech or aerospace terminal. The goal is a "Tech-meets-Pokémon" interface that feels like a high-performance Pokédex developed by a luxury tech conglomerate. 

We break the "template" look through **intentional asymmetry**, absolute **0px corner radii**, and **high-contrast typography scales**. Elements do not just sit on a grid; they are "slotted" into a digital mainframe, utilizing overlapping surfaces and vibrant neon accents to guide the eye through complex data.

---

## 2. Colors: The High-Voltage Palette
The palette is rooted in deep blacks (`surface`) and electric, high-chroma accents. It is designed to feel like a glowing screen in a dark lab.

*   **Primary Foundation:** Use `primary` (#8fabff) and `primary_dim` (#336ced) for navigational anchors.
*   **Neon Utility:** 
    *   `secondary` (#38fa5f) is "Plasma Green," reserved for "Syncing" states, success confirmations, and active energy.
    *   `tertiary` (#f4ffc6) is "Electric Yellow," used for high-priority alerts or "Offline" fail-safe warnings when the system is in a precarious state.
*   **The "No-Line" Rule:** 1px solid borders are strictly prohibited for sectioning content. Boundaries must be defined through background color shifts. A `surface_container_low` card sitting on a `surface` background creates a hard, digital edge without the clutter of lines.
*   **Surface Hierarchy & Nesting:** Treat the UI as a series of physical layers. Use `surface_container_lowest` for the deepest background and `surface_container_highest` for the most prominent interactive modules.
*   **Signature Textures:** For hero elements or main CTAs, use a linear gradient transitioning from `primary` to `primary_container` at a 135-degree angle. This mimics the "retro-modern" shimmer of rare digital items.

---

## 3. Typography: The Digital Editorial
We utilize two distinct typefaces to balance "Tech" and "Readability."

*   **Display & Headlines (Space Grotesk):** This is our "Digital" voice. The wide, geometric stance of Space Grotesk provides a subtle pixel-grid feel without sacrificing legibility. Use `display-lg` (3.5rem) with tight tracking (-0.02em) for high-impact editorial moments.
*   **Body & Titles (Manrope):** Our "Professional" voice. Manrope provides a clean, modern contrast to the sharp headlines. It ensures that long-form data—essential for a Pokémon-inspired tech interface—is comfortable to consume.
*   **Hierarchy as Brand:** Use extreme scale differences. A `display-md` headline should often be paired with a `label-sm` in all-caps to create an "Information Terminal" aesthetic.

---

## 4. Elevation & Depth: Tonal Layering
Since the roundedness scale is set to **0px**, we cannot rely on rounded corners to imply "objectness." We use Tonal Layering.

*   **The Layering Principle:** Depth is achieved by stacking. Place a `surface_container_high` module over a `surface_dim` base. The sharp 90-degree corners will create a "staircase" effect that feels structural and architectural.
*   **Ambient Shadows:** Floating elements (like Modals) must use a highly diffused shadow: `box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4)`. The shadow should not be grey, but a tinted version of the background to maintain the "glow" of the neon accents.
*   **The "Ghost Border" Fallback:** If a container needs more definition, use the `outline_variant` token at **15% opacity**. This creates a "hairline" effect that suggests a border without the heaviness of a solid line.
*   **Glassmorphism:** For top navigation or floating toolbars, use `surface` at 70% opacity with a `backdrop-filter: blur(12px)`. This allows the neon accents of the content to bleed through as the user scrolls, creating a premium, layered depth.

---

## 5. Components: Functional Primitives

### Buttons
*   **Primary:** `primary` background with `on_primary` text. No border. 0px radius. Use a subtle `primary_fixed_dim` 2px bottom "step" (inset shadow) to give it a physical, button-press feel.
*   **Secondary (Plasma):** `secondary_container` background with `on_secondary_container` text. Used specifically for "Sync" or "Action" triggers.

### Status Tokens (The Fail-Safe Features)
*   **Syncing State:** A dedicated chip using `secondary_fixed` background and `on_secondary_fixed` text. Incorporate a 2-frame "glitch" animation or a simple pixel-square pulse.
*   **Offline State:** Use `error_dim` (#d7383b) for the container and `on_error` for text. The "Tech-meets-Pokémon" aesthetic treats "Offline" as a critical system interruption (Power Outage style).

### Input Fields
*   Background: `surface_container_highest`. 
*   Active State: No glow; instead, use a 2px solid `primary` bottom-border (the only exception to the No-Line rule).
*   Typography: All input text should be `body-md` in `on_surface`.

### Cards & Lists
*   **Zero Dividers:** Forbid the use of divider lines. Separate list items using alternating background shifts (`surface_container_low` vs `surface_container_lowest`) or a 16px vertical spacing gap.
*   **Asymmetric Layouts:** Shift card content so that images/icons are top-aligned and labels are bottom-aligned, breaking the standard "centered" card template.

---

## 6. Do's and Don'ts

### Do:
*   **Do** embrace the 0px radius. Every element must be perfectly rectangular.
*   **Do** use `tertiary` (Electric Yellow) sparingly as a "high-voltage" accent for notifications or data highlights.
*   **Do** use "Pixel-Gaps." When separating two primary sections, use a 4px or 8px gap of the `background` color to simulate the "grid-lines" of a high-res screen.

### Don't:
*   **Don't** use actual Pokémon images. Use abstract shapes, data visualizations, or pixel-art patterns to evoke the theme.
*   **Don't** use soft gradients. Gradients should be "stepped" or high-contrast linear transitions.
*   **Don't** use standard "drop shadows" on cards. Rely on color-blocking for hierarchy. If a shadow is used, it must be massive and atmospheric, never tight or muddy.

---

## 7. Signature Interaction: The "Boot-Up" Motion
To solidify the high-end feel, all screen transitions should mimic a digital terminal boot-up. Elements should not fade in; they should "scan" in vertically using a fast, linear motion-path, reinforcing the tech-heavy Unova inspiration.
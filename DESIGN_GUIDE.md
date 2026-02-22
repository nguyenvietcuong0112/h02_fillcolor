# SVG Creation Guidelines for Coloring App

To ensure your SVG designs work perfectly with the coloring algorithms (Paint Bucket & Brush), please follow these technical specifications.

## 1. File Structure (Critical)

The app looks for a specific group to identify colorable areas.

```xml
<svg ...>
  <!-- Background/Reference layers (Optional, won't be colorable) -->
  <g id="background">...</g>

  <!-- IMPORTANT: All colorable parts must be inside this group -->
  <g id="fill-areas">
      <!-- Each shape must be a separate path with a unique ID -->
      <path id="area_face" d="..." stroke="black" stroke-width="2" fill="white"/>
      <path id="area_nose" d="..." stroke="black" stroke-width="2" fill="white"/>
  </g>
  
  <!-- Outlines (Optional, if you want lines on top of colors) -->
  <!-- <g id="outlines">...</g> -->
</svg>
```

## 2. Path Requirements

- **Convert Elements to Paths**: Do not use `<rect>`, `<circle>`, `<ellipse>`, `<line>`, or `<polyline>`. All shapes must be converted to `<path>` elements.
    - *In Illustrator*: Object -> Compound Path -> Make / Object -> Expand.
- **Closed Paths**: Every path must be a closed loop (ends with `Z` or `z`). Open paths cannot be filled correctly.
- **No Self-Intersections**: A single path ID should represent a single contiguous region. Avoid complex "8" shapes in one path if they are meant to be colored separately.

## 3. ID Naming Convention

- **Unique IDs**: Every `<path>` inside `#fill-areas` MUST have a unique `id`.
- **Recommended Prefix**: Use descriptive names like `id="area_eye_left"`, `id="area_flower_petal_1"`.
- **Avoid Duplicates**: Duplicate IDs will cause the coloring engine to confuse regions.

## 4. Export Settings (Adobe Illustrator / Inkscape)

- **Styling**: Use "Presentation Attributes" (e.g., `fill="white"`) instead of "Style Elements" (`style="fill:white"`) or CSS classes. The parser reads attributes more reliably.
- **Transforms**: NOT RECOMMENDED. Try to "Flatten Transforms" so that all coordinate data is baked into the `d="..."` values. Nested group transforms can sometimes cause hit-testing offsets.
- **Minify**: You can use SVGO to clean up the file, but ensure it doesn't strip `id`s or merge paths excessively.

## 5. Troubleshooting Common Issues

| Problem | Cause | Solution |
|BC | | |
| **Tap passes through** | Path is not closed | Ensure path ends with `Z`. |
| **Color fills wrong area** | Duplicate IDs | Check XML for duplicate `id` attributes. |
| **Cannot tap area** | Shape is `<circle>` not `<path>` | Convert object to path in vector tool. |
| **Offset/Misplaced** | Complex transforms (`matrix(...)`) | Flatten transforms before exporting. |

## Checklist for Design Team
- [ ] Root group named `fill-areas` exists?
- [ ] All shapes converted to `<path>`?
- [ ] No complex transforms on groups?
- [ ] All paths have unique IDs?

Create a new Astro component named `$ARGUMENTS` in `frontend/src/components/`.

## Rules

1. **Filename:** Use PascalCase with `.astro` extension (e.g., `TestimonialCard.astro`).
2. **Location:** Always inside `frontend/src/components/`.
3. **Do NOT** modify any existing file — only create the new component.

## Structure

Follow this exact skeleton, adapting props and markup to the component's purpose:

```astro
---
interface Props {
  // Define props relevant to this component
}

const { /* destructured props */ } = Astro.props;
---

<section id="component-name" class="py-20">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <!-- Component markup using TailwindCSS -->
  </div>
</section>
```

## Design system to follow

- **Background:** `bg-slate-900` for cards, `brand-dark` (#0B1426) for page-level.
- **Borders:** `border border-slate-800` on cards, `rounded-xl`.
- **Headings:** `text-white font-bold`, sizes `text-3xl md:text-4xl` for section titles.
- **Subheadings:** `text-emerald-400 font-semibold`.
- **Body text:** `text-slate-400` or `text-slate-300`.
- **Accents/CTAs:** Emerald (`bg-emerald-500`, `hover:bg-emerald-600`, `text-emerald-400`).
- **Container:** Always wrap in `max-w-7xl mx-auto px-4 sm:px-6 lg:px-8`.
- **Spacing:** `py-20` for sections, `gap-8` for grids, `mb-6`/`mb-12` for vertical rhythm.
- **Animations:** Use existing Tailwind animations from `tailwind.config.mjs`: `animate-fade-in`, `animate-fade-in-up`, `animate-slide-up`.

## After creating the file

1. Confirm the file was created at the correct path.
2. Show the full contents of the new component.
3. Suggest where to import and use it (which page and position).

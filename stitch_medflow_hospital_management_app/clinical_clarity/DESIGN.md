---
name: Clinical Clarity
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#3e484b'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#6e797c'
  outline-variant: '#bec8cb'
  surface-tint: '#006877'
  primary: '#006574'
  on-primary: '#ffffff'
  primary-container: '#1c8090'
  on-primary-container: '#f8fdff'
  inverse-primary: '#7ed3e5'
  secondary: '#006c49'
  on-secondary: '#ffffff'
  secondary-container: '#6cf8bb'
  on-secondary-container: '#00714d'
  tertiary: '#4f5d71'
  on-tertiary: '#ffffff'
  tertiary-container: '#67758b'
  on-tertiary-container: '#fdfcff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#a4eeff'
  primary-fixed-dim: '#7ed3e5'
  on-primary-fixed: '#001f25'
  on-primary-fixed-variant: '#004e5a'
  secondary-fixed: '#6ffbbe'
  secondary-fixed-dim: '#4edea3'
  on-secondary-fixed: '#002113'
  on-secondary-fixed-variant: '#005236'
  tertiary-fixed: '#d5e3fc'
  tertiary-fixed-dim: '#b9c7df'
  on-tertiary-fixed: '#0d1c2e'
  on-tertiary-fixed-variant: '#3a485b'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.04em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.25rem
  space-xl: 2rem
---

## Brand & Style

This design system embodies modern clinical precision, human warmth, and operational efficiency for high-velocity hospital ecosystems. The visual language balances institutional dependability with approachable, responsive mobility. It delivers immediate cognitive ease for medical staff, administrative coordinators, and patients under time-critical conditions.

Drawing from modern clinical minimalism and soft functionalism, the interface prioritizes high legibility, generous breathing room, and instantaneous triage recognition. Clean structural surfaces reduce visual exhaustion during lengthy shifts, while refined semantic accents provide unambiguous operational cues. The emotional tone is authoritative, serene, and immaculately organized.

## Colors

The palette establishes an atmosphere of hygienic clarity and steady professional care. 

- **Primary (`#2E8B9C` - Deep Clinical Teal):** Used for authoritative interactive targets, active states, key navigation hubs, and primary calls-to-action.
- **Secondary (`#10B981` - Calming Emerald):** Signifies available status, completed triage sequences, active shifts, and stable physiological parameters.
- **Tertiary (`#475569` - Slate Blue):** Governs structural boundaries, secondary interactive elements, and grounded informational headers.
- **Neutral (`#F8FAFC` - Clinical Frost White):** Supplies a sterile, high-comfort backdrop that mitigates glare and eye fatigue in hospital lighting.

### Status & Semantic Color Logic
- **Operational Amber (`#F59E0B`):** Denotes busy clinical resources, pending laboratory results, or moderate patient delays.
- **Urgent Crimson (`#EF4444`):** Flags critical vitals, emergency department escalations, ICU alerts, and off-duty/unavailable statuses.
- **Surface Layering:** Card surfaces sit on pure `#FFFFFF`, outlined by subtle `#E2E8F0` borders, elevated over the primary `#F8FAFC` canvas.

## Typography

Plus Jakarta Sans provides geometric clarity balanced with warm, open counters, maintaining superior legibility on high-density mobile screens across dynamic ward environments.

Numerical clinical values, bed numbers, and dosage readings rely on medium-to-bold weights with tabular formatting where applicable to prevent visual shifting during live telemetry updates. Sub-labels and medical metadata utilize `label-sm` with slight positive tracking to ensure fast scanning during acute assessments.

## Layout & Spacing

The layout uses a fluid single-column structure on mobile devices, transitioning to a flexible 4-to-8 column system on clinical tablets. A strict 4px/8px incremental spatial rhythm preserves systematic order across dense medical data forms and schedule overviews.

- **Mobile Viewports (<600px):** 16px screen margins (`margin: 1rem`) maximize usable canvas for patient charts and triage lists. Internal component gaps lean on `space-sm` (8px) and `space-md` (16px).
- **Tablet & Clinical Carts (600px–1024px):** Margins expand to 24px (`1.5rem`), with multi-pane master-detail views splitting triage directories from clinical workflows via 16px gutters.
- **Vertical Rhythm:** Clinical cards and patient rosters stack with consistent 12px or 16px spacing, preventing dense visual clumps and ensuring decisive touch targets (minimum 48px hit area).

## Elevation & Depth

Visual hierarchy uses a refined blend of crisp, low-contrast containment strokes and subtle, ambient-tinted shadows. This approach preserves clinical sterility without visually flattening crucial interactive layers.

- **Level 0 (Canvas Base):** Pure `#F8FAFC`. Completely unshadowed, grounding all structural data views.
- **Level 1 (Clinical Cards & List Items):** Pure `#FFFFFF` fill framed by a 1px solid border in `#E2E8F0`. Soft ambient drop shadow: `0px 2px 8px -2px rgba(46, 139, 156, 0.06)`.
- **Level 2 (Modals, Triage Sheets, Pinned Headers):** `#FFFFFF` surface with an elevated shadow: `0px 10px 24px -4px rgba(15, 23, 42, 0.08), 0px 4px 8px -2px rgba(15, 23, 42, 0.04)`.
- **Pulsing Status Elevation:** Active indicators (e.g., emerald green available indicators) incorporate a subtle animated outer aura (`box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.2)`) that gently pulses to signal live telemetry connectivity.

## Shapes

The interface embraces a tailored rounded aesthetic (`roundedness: 2`), applying 16px corner radii to cards and bottom sheets, with 20px radii reserved for prominent triage dashboard modules.

Interactive components like chips, triage tags, and action buttons utilize fully circular or pill-shaped geometries (9999px) to communicate soft tactile safety. Form fields, operational dropdowns, and alert cards use 12px to 16px corner radii to fit cleanly within compact layouts.

## Components

### Buttons & Quick Actions
- **Primary:** `#2E8B9C` teal fill, white text, 12px vertical padding, 12px to 16px corner radius. High contrast, distinct hover and active states (`#257280`).
- **Secondary / Ghost:** Transparent background, 1.5px `#2E8B9C` border, `#2E8B9C` typography.
- **Emergency Action:** Solid crimson (`#EF4444`) with high-contrast white text, reserved for rapid trauma dispatch, code blue calls, or immediate patient escalations.

### Status Badges & Availability Tags
- **Available:** Pill shape, `#ECFDF5` background, `#065F46` label, paired with an 8px emerald dot featuring a subtle breathing keyframe pulse.
- **Busy / In Surgery:** Pill shape, `#FFFBEB` background, `#92400E` label, static 8px amber indicator.
- **Urgent / Off-Duty:** Pill shape, `#FEF2F2` background, `#991B1B` label, static 8px crimson dot.

### Cards & Patient Roster Units
- **Container:** Pure `#FFFFFF` surface, 16px border-radius, 1px border (`#E2E8F0`), padded with 16px padding.
- **Header:** Displays patient/physician name in `headline-sm`, right-aligned status pill, and secondary demographic or bed-number metadata in `body-sm` (`#64748B`).

### Form Controls & Clinical Inputs
- **Input Fields:** 48px height, `#FFFFFF` background, 1px `#CBD5E1` border, 12px radius. Focused state transitions to a 2px `#2E8B9C` stroke with no heavy outer halo.
- **Checkboxes & Radios:** 20px squares/circles, primary teal active states with distinct interior white checks/dots. Minimum 44px touch targets.

### Medical Iconography
- Rendered using crisp, rounded Material Symbols styles at 20px and 24px bounding boxes. Strokes are maintained at a uniform 1.75px optical weight in tertiary slate (`#475569`) or primary teal (`#2E8B9C`).
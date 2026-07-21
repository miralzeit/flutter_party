# Dashboard Changes - Plan

## Information Gathered

1. **Dashboard Screen**: `lib/vendor/screens/dashboard_screen.dart` - Main dashboard with:
   - `_StatusCard` - Business name, status pill, verification badge, profile completion bar, Listing Status & Recent Activity buttons
   - `QualityScoreHeaderCard` - Profile health score card
   - `QualityChecklist` - Checklist of missing items
   - `_RecommendedNextStep` - Current "Upload More Photos" recommendation
   - Market Comparison section - `_competitorCard` rows showing ranked competitors
   - `QuickActionGrid` - Manage Your Business section at the bottom

2. **Quality Score Service**: `lib/vendor/services/quality_score_service.dart`
   - Has `ChecklistItem` for: Business Info, Services, Photos, Contact, Pricing, Packages, Hours, Cover Video, FAQs, Capacity, Parking, Outdoor, Generator, Accessibility Features
   - Generator and Accessibility both use `QualityAction.manageFeatures`
   - Cover Video is a separate checklist item using `QualityAction.businessDetails`

3. **Theme**: AppColors, AppTextStyles, AppTheme in `lib/vendor/theme/`

## Plan

### Step 1: Remove Dashboard Sections
- **Remove Listing Status & Recent Activity buttons** from `_StatusCard` - replace the two-button row with a compact "Edit Your Information" action
- Keep the notification bell icon and `_showNotifications` method
- Balance layout after removal

### Step 2: Improve Recommended Next Steps
- In `quality_score_service.dart`:
  - Remove the `Cover Video` checklist item entirely (point 5, "Add Cover Video" recommendation)
  - Remove the `Generator` checklist item (keep `Accessibility Features` since it's more general)
- In dashboard: Replace `_RecommendedNextStep` with a large, prominent **"Add Features"** call-to-action card that encourages vendors to add more details for better search visibility

### Step 3: Move Manage Your Business
- **Remove** the `QuickActionGrid` section from the bottom of `_content`
- **Add** a compact "Edit Your Information" action near the top (below `_StatusCard`), clean and compact

### Step 4: Redesign Market Comparison
- Replace plain competitor cards with **modern, visually engaging cards** featuring:
  - Gradient headers for "You" highlight
  - Progress bars comparing metrics (ratings, reviews, pricing)
  - Visual comparison indicators (better/worse/same icons)
  - Icons, better spacing, professional typography
  - At-a-glance understanding of how the vendor compares

### Step 5: Clean up unused imports and methods

## Files to be Edited
1. `lib/vendor/screens/dashboard_screen.dart` - Main changes
2. `lib/vendor/services/quality_score_service.dart` - Remove duplicate/cover video items
3. Potentially: `lib/vendor/widgets/quality_score_card.dart` if needed

## Follow-up Steps
1. Run `flutter analyze` to check for errors
2. Verify the app builds successfully


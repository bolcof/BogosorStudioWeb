# BogosorStudio Web Assets

Place exported Steam assets here. The site already references these paths:

## Title asset convention

For each title, create a folder using the same TitleId as the detail page:

```text
docs/games/<TitleId>.html
docs/assets/games/<TitleId>/
```

Use these asset names inside the folder:

- `KeyArt.png` - full-bleed title page background
- `LibraryCapsule.png` - home grid capsule image, 600x900
- `LibraryHero.png` - slideshow/title background image, ideally 3840x1240
- `ScreenShot01.png` - large visual on the title detail page
- `ScreenShot02.png` - secondary visual on the title detail page
- `ScreenShot03.png` - secondary visual on the title detail page
- `OgImage.png` - optional social share image for the title detail page

Example:

```text
docs/games/Reversi2048.html
docs/assets/games/Reversi2048/KeyArt.png
docs/assets/games/Reversi2048/LibraryCapsule.png
```

`LibraryCupsule.png` was an old misspelling. Use `LibraryCapsule.png` going forward.

- `studio/logo.png` - studio logo or wordmark for the header
- `studio/hero.jpg` - slideshow image for the title list slide
- `studio/news.jpg` - slideshow image for the update/news slide
- `studio/og-image.jpg` - social share image, ideally 1200x630
- `games/SakWinik/LibraryCapsule.png` - Sak Winik home grid capsule image
- `games/SakWinik/LibraryHero.png` - Sak Winik slideshow/title background image
- `games/SakWinik/KeyArt.png` - Sak Winik full-bleed title page background
- `games/SakWinik/OgImage.png` - Sak Winik social share image
- `games/SakWinik/ScreenShot01.png` - Sak Winik large visual
- `games/SakWinik/ScreenShot02.png` - Sak Winik secondary visual
- `games/SakWinik/ScreenShot03.png` - Sak Winik secondary visual
- `games/Reversi2048/LibraryCapsule.png` - REVERSI 2048 home grid capsule image
- `games/Reversi2048/LibraryHero.png` - REVERSI 2048 slideshow/title background image
- `games/Reversi2048/KeyArt.png` - REVERSI 2048 full-bleed title page background
- `games/Reversi2048/ScreenShot01.png` - REVERSI 2048 large visual
- `games/Reversi2048/ScreenShot02.png` - REVERSI 2048 secondary visual
- `games/Reversi2048/ScreenShot03.png` - REVERSI 2048 secondary visual
- `games/SkillHockey/LibraryCapsule.png` - Skill Hockey home grid capsule image
- `games/SkillHockey/LibraryHero.png` - Skill Hockey title background image
- `games/NyctoType/LibraryCapsule.png` - NyctoType home grid capsule image
- `games/NyctoType/LibraryHero.png` - NyctoType title background image
- `games/HappyRunner/LibraryCapsule.jpg` - Happy Runner home grid capsule image

The page works without these files, but it is designed so the real Steam art can be dropped in without changing HTML.

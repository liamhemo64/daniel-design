# סטודיו דניאל — דף נחיתה Scrollytelling (לפני / אחרי)

דף נחיתה בקובץ בודד (`index.html`) לעסק עיצוב פנים. אפקט גלילה
(scroll-scrubbing) שעובר בין "לפני" ל"אחרי" בכל חדר — בסגנון
**Image Sequence** (וידאו שמתנגן לפי הגלילה).

🔗 **חי באוויר:** https://liamhemo64.github.io/daniel-design/

---

## מה יש עכשיו

- מבנה: Hero → 4 פרקים (מטבח, סלון, חדר שינה, חדר רחצה) → CTA/WhatsApp.
- מנוע גלילה גנרי שמקבל **מערך פריימים** לכל פרק (`frames`).
- כרגע: 2 פריימים לחדר (תמונות Unsplash, "לפני"=שחור-לבן דהוי, "אחרי"=צבע)
  + אפקט **Ken Burns** (זום/pan עדין) שנותן תחושת וידאו.
- נגישות: `prefers-reduced-motion` → תצוגת "לפני | אחרי" סטטית.
- ללא build, ללא framework. מעלים כמו שהוא.

---

## לשדרג ל-Image Sequence אמיתי (כמו בריל)

הרעיון (3 שלבים):

**1. יוצרים את הווידאו (כלים חיצוניים — לא בקוד):**
   - פריים פתיחה ("לפני") + פריים סיום ("אחרי") — למשל ב-Midjourney / DALL·E.
   - וידאו קצר (2–4 שניות) שעובר מהפתיחה לסיום — למשל Kling / Runway / Veo.

**2. מפרקים את הווידאו לפריימים** (דורש `ffmpeg`):
   ```powershell
   # Windows
   .\scripts\extract-frames.ps1 -Video "kitchen.mp4" -Room "kitchen" -Count 30
   ```
   ```bash
   # macOS / Linux / Git-Bash
   bash scripts/extract-frames.sh kitchen.mp4 kitchen 30
   ```
   נוצר: `frames/kitchen/frame-001.jpg ... frame-030.jpg`.

   > אין ffmpeg? התקנה: `winget install Gyan.FFmpeg`

**3. מחליפים בקוד** (`index.html`, במערך `CHAPTERS`) — במקום זוג `roomPhoto`:
   ```js
   frames: sequence("kitchen", 30)
   ```
   זהו. המנוע לא משתנה. כשהמערך > 2, אפקט ה-Ken Burns נכבה אוטומטית
   (התנועה כבר בתוך הפריימים).

---

## פריטים להחלפה (מסומנים `// TODO: SWAP PLACEHOLDER`)

- **מספר WhatsApp** — כרגע `972500000000` (דמה). פורמט: קידומת בינ"ל בלי `+` וללא `0`.
- **שם העסק** — "סטודיו דניאל" (ב-`<title>`, ב-Hero וב-footer).
- **תמונות** — Unsplash כרגע; להחליף לרצף אמיתי לפי ההוראות למעלה.

---

## פרסום עדכונים

הדף מתארח ב-GitHub Pages. כל דחיפה מעדכנת את האתר החי (~דקה):

```bash
git add -A
git commit -m "עדכון"
git push
```

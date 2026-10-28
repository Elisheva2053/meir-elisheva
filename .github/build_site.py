# בונה את האתר לתיקייה _site: מעתיק את הדף, התמונות והשירים, ויוצר media.js עם רשימת הקבצים.
# עושה ב-GitHub את מה ש-START.cmd עושה במחשב.
import json
import shutil
from pathlib import Path
from urllib.parse import quote

ROOT = Path(__file__).resolve().parent.parent
SITE = ROOT / "_site"
IMAGE_EXT = {".jpg", ".jpeg", ".jfif", ".png", ".webp", ".gif", ".bmp", ".avif", ".svg"}
MUSIC_EXT = {".mp3", ".wav", ".m4a", ".aac", ".ogg", ".flac", ".wma"}


def media(folder, exts):
    base = ROOT / folder
    if not base.is_dir():
        return []
    files = sorted(p for p in base.rglob("*") if p.is_file() and p.suffix.lower() in exts)
    return ["./" + "/".join(quote(part) for part in p.relative_to(ROOT).parts) for p in files]


if SITE.exists():
    shutil.rmtree(SITE)
SITE.mkdir()
shutil.copy2(ROOT / "index.html", SITE / "index.html")
for folder in ("images", "music"):
    if (ROOT / folder).is_dir():
        shutil.copytree(ROOT / folder, SITE / folder)

data = {"images": media("images", IMAGE_EXT), "music": media("music", MUSIC_EXT)}
(SITE / "media.js").write_text("window.MEDIA_LIST = " + json.dumps(data, ensure_ascii=False) + ";\n", encoding="utf-8")
print(f"{len(data['images'])} images, {len(data['music'])} tracks")

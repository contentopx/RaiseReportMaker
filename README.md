# 📈 RaiseReportMaker

A lightweight toolkit for mapping PDFs to **RAISE tags** using keyword and course content metadata.

---
## 🗂 What's Inside

| File | Purpose | Output Columns |
|------|---------|----------------|
| `course_contentsmap.csv` | Master mapping of all K–12 lesson content to RAISE metadata. | `content_id`, `section`, `activity_name`, `lesson_page`, `url`, `visible` |
| `map_keywordstoraise.sh` | Scans `.html` lesson files for instructional keywords like “write an equation” or “constraint” and maps them to RAISE metadata using `course_contentsmap.csv`. | `Keywords`, `section`, `activity_name`, `lesson_page`, `url` |
| `map_pdftoraise.sh` | Extracts PDF URLs from `k12_url_resource.csv`, finds where they appear in lesson HTML files, and maps them to course metadata using `course_contentsmap.csv`. | `URL`, `visible`, `Name`, `section`, `activity_name`, `lesson_page`, `url` |

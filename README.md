# 📈 RaiseReportMaker

A lightweight toolkit for mapping PDFs to **RAISE tags** using keyword and course content metadata.

---

## 🗂 What's Inside

| File | Purpose |
|------|---------|
| `course_contentsmap.csv` | A master spreadsheet mapping each course, unit, and lesson to corresponding **RAISE tags** and optional **keywords**. |
| `map_keywordstoraise.sh` | A shell script that parses PDFs using a keyword list and auto-maps them to appropriate **RAISE tags** using `course_contentsmap.csv`. |
| `map_pdftoraise.sh` | A higher-level script that lists the **URL and location** of all matched PDFs for documentation or integration using `course_contentsmap.csv`. |

---

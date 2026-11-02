# Talks

Slide sources and PDFs, served at <https://slides.lukasburk.de>.
The curated list of talks lives at <https://lukasburk.de/talks>.

## Layout

Talks live in `YYYY/MM-slug/`.
Published URLs are permanent (QR codes, website links), so published files are never moved or renamed.

Typst talks from November 2026 onward use the shared `talk.mk` and produce:

- `burk-YYYY-MM-slug.pdf`: handout without pauses, the default for sharing and the QR target
- `burk-YYYY-MM-slug-present.pdf`: version with pauses for presenting

Older talks keep their original file names.

## Usage

```sh
make                 # list root targets
make new TALK=slug   # scaffold YYYY/MM-slug/ (this month) from template/
cd YYYY/MM-slug
make help            # list talk targets
make                 # build both PDFs
```

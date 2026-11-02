#import "@preview/bypst:0.6.0": *

#let me = "Lukas Burk"
#let talk-title = [Title]
#let talk-subtitle = [Subtitle]

#show: bips-theme.with(
  config-info(
    title: talk-title,
    subtitle: talk-subtitle,
    author: me,
    date: datetime(day: {{DAY}}, month: {{MONTH}}, year: {{YEAR}}).display(),
  ),
  logo: image("bips-logo.png"),
  base-size: 16pt,
)

#title-slide(
  title: talk-title,
  subtitle: talk-subtitle,
  author: me,
  institution: bips-en,
  occasion: [Occasion],
)

#bips-slide(title: [Slide title])[
  - Point #pause
  - Another point
]

#thanks-slide(
  contact-author: me,
  email: "burk@leibniz-bips.de",
  qr-url: sys.inputs.at("url", default: "https://slides.lukasburk.de"),
)

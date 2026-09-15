#let t = toml("/templates.toml")
#set text(font: t.fonts.serif, size: 10pt)
#set par(leading: 0.75em)
#show: block.with(stroke: (bottom: 1pt), inset: (bottom: 0.5em))
#show: upper

#context [
  #if here().page() == 1 {
    return
  }
  #grid(
    columns: (auto, 1fr),
    column-gutter: 0.5cm,
    align: horizon,
    image("/static/logo.png", height: 2.5em),
    [HO CHI MINH CITY UNIVERSITY OF TECHNOLOGY\
     FACULTY OF COMPUTER SCIENCE AND ENGINEERING],
  )
]

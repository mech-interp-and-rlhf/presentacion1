#import "@preview/touying:0.6.1": *
#import themes.university: *
#import "@preview/cetz:0.3.2"
#import "@preview/fletcher:0.5.4" as fletcher: diagram, node, edge
#import fletcher.shapes: house, hexagon
#import "@preview/numbly:0.1.0": numbly
#import "@preview/theorion:0.3.2": *
#import cosmos.clouds: *
#show: show-theorion

#set text(lang: "es")
#let transparent = black.transparentize(100%)

#let blob(pos, label, tint: white, hidden:false, ..args) = node(
  pos, align(center,
    if hidden {text(fill: black.transparentize(100%), label)} else {label}
  ),
  width: 175pt,
  fill: if hidden {transparent} else {tint.lighten(60%)},
  stroke: if hidden {transparent} else {1pt + tint.darken(20%)},
  corner-radius: 10pt,
  ..args,
)

#let plusnode(pos, ..args) = node(pos, $ plus.circle $, inset:-5pt, ..args)

#let edge-hidden(hidden: false, ..args) = {
  if hidden {edge(stroke: transparent, ..args)}
  else {edge(..args)}
}

// cetz and fletcher bindings for touying
#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

#set text(font: "New Computer Modern")

#show: university-theme.with(
  aspect-ratio: sys.inputs.at("aspect-ratio", default:"16-9"),
  align: horizon,
  config-common(handout: sys.inputs.at("handout", default:"false") == "true"),
  config-common(frozen-counters: (theorem-counter,)),  // freeze theorem counter for animation
  config-info(
    title: [Exploración de modelos Transformers y su Interpretabilidad
        Mecanicista],
    subtitle: [Parte 1. Interpretabilidad Mecanicista],
    author: [Hernández Peralta Sergio Antonio, Juan Emmanuel Cuéllar Lugo, \
    Julia López Diego, Nathael Ramos Cabrera],
    logo: box(image("Logo_de_la_UAM_no_emblema.svg", width:36pt)),
  ),
  footer-a: [Sergio, Juan, Julia, Nathael],
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()

== Índice <touying:hidden>

#components.adaptive-columns(outline(title: none, indent: 1em, depth:1))

= Introducción

== A

Las redes neuronales son modelos matemáticos que actualmente poseen capacidades
impresionantes. Desde Traducción, generación de videos, creación de programas,
etc.

== Realizado
// No me gusta, cambiar púnto
- Entrenamos una red neuronal para la "ingeniería inversa" de un
  gran modelo de lenguaje.
- Creamos un sitio web con cuadernos digitales educativos

== Motivación

Black box, etc




= Formulación matemática

== Redes neuronales artificiales

#definition[
  Una _Red neuronal_ es una función paramétrica. Sus componentes principales con
  funciones lineales, y funciones de "activación", como $f(x) = max(0, x)$,
  $tanh(x)$, y entre otras. Sus entradas suelen ser vectores y las funciones de
  activación se suelen aplicar componente por componente.
]
#example[
  llama3.2, dalle, etc
]

== Perceptrones multicapa

Parámetros: $W^((l)), b^((l))$
$
  a^((0)) &= x \
  z^((l)) &= W^((l)) a^((l-1)) + b^((l)) && quad "(preactivaciónes)" \
  #pause
  a^((l)) &= sigma(z^((l))) && quad "(activaciónes)"
$

#pause
- Término genérico

== Entrenamiento

Para entrenar una red neuronal, usamos optimización de primer orden, es decir,
basandonos en el gradiente#pause

- Tomar la derivada de programas#pause

#pagebreak(weak:true)

Una primera idea es hacer un pequeño cambio  en cada dimensión en el espacio de
sus parámetros, pero eso costaría tantas evaluaciones como hay parámetros.
- Redes neuronales actuales tienes billones de parámetros.

#pagebreak(weak:true)

Otra idea es calcular la derivada a lapiz y papel, y luego hacer un programa
para evaluar la expresión resultante.

- Explosión en exponencial en complejidad al repetir operaciones


== Retropropagación

- Grafo asíclico dirigido

Fwd:
- Cada nodo calcula su resultado, guarda un estado interno

#pagebreak(weak:true)
Bkw:
- Multiplicación vector matriz, la matriz no se materializa siempre
- El nodo recive gradiente respecto a su salida
- Lo usa para calcular el gradiente respecto a cada entrada
- Pasa cada el $i$ esimo por su arista de entrada $i$ esimo

#pagebreak(weak:true)
#theorem[
  Sea $f: RR^n -> RR$ una función escalar computada usando un grafo
  computacional que es evaluada usando un total de $T$ operaciones elementales.

  #pause
  Entonces la retropropagación computa $gradient f$ usando no mas de $6T$
  operaciones.
]

#pause

#remark[
  En la práctica, se observa de $2T$ a $3T$ en vez de $6T$.
]

== ADAM

#slide(repeat: 3, self => {
  align(center, cetz-canvas(length: 7.5cm, {
    import cetz.draw: *
    let arrow-style = fill => (
      mark: (end: "triangle", fill:fill, scale:1.1),
      stroke: 2.7pt+fill
    )

    set-transform(cetz.matrix.transform-rotate-dir(
      (1, 0.4, 0),
      (0,   0, 1),
    ))

    let n-circles = 6
    let target-opacity = 0.6
    let r = calc.root(1 - target-opacity, n-circles)
    let reduction = calc.round(r, digits: 2) * 100%
    let final_y = -0.55

    for i in range(n-circles) {
      let progress = i / (n-circles - 1)
      let size = 1-progress
      circle(
        ((1-progress)*0.14, (1- progress) * final_y),
        radius: (0.5 * size, 1.2 * size),
        fill: blue.transparentize(reduction),
        stroke: blue.transparentize(40%),
      )
    }

    let gd_color   = purple
    let sgd_color  = orange
    let adam_color = red

    let gd_points = (
      (0.1, -1.65),
      (0.09, -1.50),
      (0.07, -1.30),
      (0.04, -1.10),
      (0.0, -0.90),
      (-0.03, -0.70),
      (-0.02, -0.50),
      (0.01, -0.30),
      (0.03, -0.15),
      (0.0, 0.0)
    )
    let batch_sgd_points = (
      (0.1, -1.65),
      (0.05, -1.46),
      (-0.252, -1.20),
      (0.182, -1.00),
      (0.28, -0.80),
      (0.0, -0.60),
      (-0.14, -0.40),
      (0.0, -0.20),
      (0.14, -0.10)
    )
    let adam_points = (
      (0.1, -1.65),
      (0.05, -1.46),
      (-0.1, -1.06),
      (0.05, -0.78),
      (0.0, -0.50),
      (0.0, -0.30),
      (0.00, -0.20),
      (0.06, -0.13),
      (0.04, -0.06)
    )

    for i in range(gd_points.len() - 1) {
      line(
      gd_points.at(i),
      gd_points.at(i+1),
      ..arrow-style(
          gd_color.darken(10%).transparentize(
            if self.subslide < 1 {
              100%
            } else if self.subslide == 1 {
              0%
            } else {60%}
          )
        )
      )
    }

    for i in range(batch_sgd_points.len() - 1) {
      line(
      batch_sgd_points.at(i),
      batch_sgd_points.at(i+1),
      ..arrow-style(
          sgd_color.darken(10%).transparentize(
            if self.subslide < 2 {
              100%
            } else if self.subslide == 2 {
              0%
            } else {60%}
          )
        )
      )
    }

    for i in range(adam_points.len() - 1) {
      line(
      adam_points.at(i),
      adam_points.at(i+1),
      ..arrow-style(
          adam_color.darken(10%).transparentize(
            if self.subslide < 3 {
              100%
            } else if self.subslide == 3 {
              0%
            } else {60%}
          )
        )
      )
    }

    content((1.1,0.2), anchor: "north-west", [

      #text(fill:gd_color, [$->$ Descenso de gradiente])

      #text(
        fill:sgd_color.transparentize(if self.subslide < 2 {100%} else {0%}),
        [ $->$ Descenso de gradiente\
          #text(fill:black.transparentize(100%), $->$) Estocástico],
      )

      #text(
        fill:adam_color.transparentize(if self.subslide < 3 {100%} else {0%}),
        [$->$ ADAM],
      )
    ])

  }))
})

#speaker-note[
  - Calcular el gradiente tiene complejidad *lineal* con respecto a la cantidad
    de datos

  - Descenso de gradiente estocástico actualiza los parámetros basado en un
    gradiente calculado con solo algunos datos

  - ADAM incorpora una media movil de los momentos del gradiente
    - NO momentos como en estadística,
    - momentos en el sentído de la física
      - velocidad
      - aceleración
]


== Transformers

#slide(
  repeat: 3,
  self => [
    #let (only, uncover, alternatives) = utils.methods(self)

    #let edge-corner-radius = 10pt
    #let branch-off-offset = edge-corner-radius*1.4
    #let second-col-offset = 100pt
    #let before-branch = 10pt
    #fletcher-diagram(
      edge-corner-radius: edge-corner-radius,
      edge-stroke: 0.9pt,

      node((0,0), name: <xi>),
      plusnode((rel:(0pt, 117pt), to:<xi>),        name: <xip>),
      plusnode((rel:(0pt, 117pt), to:<xip.north>), name: <xipp>),

      edge((rel:(0pt, -25pt), to:<xi>), <xi>, "--|>"),
      edge(<xi>, <xip>, "-|>",
        label: $x_i$,
        label-pos: -9pt,
        label-side: right,
        label-sep: 18pt,
      ),
      edge(
        <xip>,
        <xipp>,
        label: $x_(i+1) #uncover("2-", $= x_i + sum_h h(x_i|"contexto")$)$,
        label-side: right,
        label-pos: -12pt,
        label-sep: 18pt,
        "-|>",
      ),
      edge(
        <xipp>,
        (rel:(0pt, 25pt), to:<xipp.north>),
        label: $x_(i+2) #uncover("3-", $= x_(i+1) + m(x_(i+1))$)$,
        label-side: right,
        label-pos: -10pt,
        label-sep: 18pt,
        "--|>",
      ),

      node(
        enclose: (<xi>, <xip>, <xipp>, <mha>, <mlp>),
        fill: green.transparentize(70%),
        snap: false,
        corner-radius: 10pt,
        inset: 10pt,
        stroke: green.darken(20%),
      ),

      {
        let hidden = self.subslide < 2
        node(
          (rel:(-second-col-offset, branch-off-offset), to:<xi>),
          name:<mha-pre>,
        )
        edge-hidden(
          (<xi>, "|-", (rel:(0pt, -edge-corner-radius), to:<mha-pre>)),
          (<xi>, "|-", <mha-pre>),
          <mha-pre>,
          <mha>, "-|>",
          hidden:hidden,
        )
        blob(
          (<mha-pre>, 50%, (<mha-pre>, "|-", <xip>)),
          [Autoatención\ multicabezal],
          tint: orange,
          name: <mha>,
          hidden: hidden,
        )
        edge-hidden(<mha>, (<mha>, "|-", <xip>), <xip>, "-|>",
          hidden: hidden,
        )
      },

      {
        let hidden = self.subslide < 3
        node(
          (rel:(-second-col-offset, branch-off-offset), to:<xip.north>),
          name:<mlp-pre>,
        )
        edge-hidden(
          (<xip>, "|-", (rel:(0pt, -edge-corner-radius), to: <mlp-pre>)),
          (<xip>, "|-", <mlp-pre>),
          <mlp-pre>,
          <mlp>,
          hidden:hidden,
          "-|>",
        )
        blob(
          (<mlp-pre>, 50%, (<mlp-pre>, "|-", <xipp>)),
          [Perceptrón\ Multicapa],
          tint: blue,
          name: <mlp>,
          hidden: hidden,
        )
        edge-hidden(
          <mlp>,
          (<mlp>, "|-", <xipp>),
          <xipp>,
          hidden: hidden,
          "-|>",
        )
      },

    )
  ]
)


#fletcher-diagram(
  edge-corner-radius: 10pt,
  edge-stroke: 0.9pt,
  blob((0,0),  none, height:50pt, tint:green),
  blob((0,-1), none, height:50pt, tint:green),
)

= Interpretabilidad mecanicista

== Fenómenos

Esta parte de aquí explica varias neuronas monosemánticas, mencionando como
ejemplo las neuronas de inception y clip.

#speaker-note[
  En esta nota al precentador, se explica detalladamente, con mucho texto
]

== Hipótesis de reprecentaciónes Lineales

Esta parte menciona los resultados de word2vec para introducir la hipótesis de
reprecentaciones lineales, usa terminos como componente y dirección (en el
sentido de dirección de vector), también mensiona los latent-space walk,
mostrando imágenes (gif?), mostrando visualmente como se puede usar para
resultados tipo word2vec al modificar por ejemplo la edad de una persona

Recordemos que: poco texto aquí, mucho texto en las speaker-notes


#speaker-note[
  a
]

== Compressed sensing

#lemma(title:"Johnson-Lindenstrauss")[
  #lorem(40)
]

== Autoencoders Dispersos
#lorem(2)

== auto-interpretabilidad
#lorem(3)




= Aprendizaje de Diccionario en llama 3.2 1B

== xd

Se entrenó un autoencoder disperso sobre las salidas del perceptrón multicapa
medio de llama3.2 1B.

Esto usando el procedimiento documentado en "GemmaScope"


== JumpReLU SAE

- Optimización con restricciones
- gradientes de esperanza
- Cosine annealing learning rate


== El SAE

#slide(composer: (1fr, 1fr))[
  $
    "JumpReLU" (accent(z, arrow) | accent(theta, arrow))
    = accent(z, arrow) dot.circle H(accent(z, arrow) - accent(theta, arrow))\
  $

  $
    diff/(diff theta) EE_(x tilde X) [cal(L)(x | theta)]
  $

  $
    cancel(diff)/(cancel(diff) theta) H(accent(z, arrow) - accent(theta, arrow))
    = 1/epsilon K((accent(z, arrow) - accent(theta, arrow))/epsilon)
  $
][
  - $(beta_1, beta_2) = (0, 0.999)$

  - Cosine schedule, warmup
  - Columnas normalizadas
  - Columnas normalizadas
  - $b = 4096$
]

#import "@preview/bypst:0.5.0": *

#let me = "Lukas Burk"
#let talk-title = [Feature Importance for Applied Research]
#let talk-subtitle = [From model inspection to statistical inference]
#let to = sym.arrow
#let indep = math.class("relation", $perp #h(-5pt) perp$)

#show: bips-theme.with(
  config-info(
    title: talk-title,
    subtitle: talk-subtitle,
    author: me,
    date: datetime(day: 26, month: 10, year: 2026).display("[day] [month repr:long] [year]"),
  ),
  logo: image("bips-logo.png"),
  base-size: 17pt,
  code-inline-scale: 1,
  // handout: true,
)

// ---- Helpers -----------------------------------------------------------------

// R code block; `hl` marks lines that changed from the previous slide.
// Slide code is a simplified copy of R/run.R, not executed verbatim.
#let code(src, hl: (), size: 1.3em) = block(
  width: 100%,
  fill: luma(248),
  inset: (y: 6pt),
  radius: 3pt,
  text(size: size, stack(
    ..src
      .trim()
      .split("\n")
      .enumerate()
      .map(((i, l)) => block(
        width: 100%,
        inset: (x: 8pt, y: 3pt),
        spacing: 0pt,
        fill: if (i + 1) in hl { rgb("#FA8537").lighten(75%) },
        // empty raw() has no height, keep blank lines
        raw(if l == "" { " " } else { l }, lang: "r"),
      )),
  )),
)

// $importance() output for one method, ranger, as on the console
#let fi-table(method, path: "results/bike.csv") = {
  let rows = csv(path, row-type: dictionary)
    .filter(r => r.learner == "ranger" and r.method == method)
    .sorted(key: r => -float(r.importance))
  table(
    columns: 2,
    align: (left, right),
    stroke: none,
    inset: (x: 8pt, y: 3.5pt),
    table.hline(),
    table.header([*Feature*], [*#method*]),
    table.hline(stroke: 0.5pt),
    ..rows.map(r => (raw(r.feature), str(calc.round(float(r.importance))))).flatten(),
    table.hline(),
  )
}

// lm() coefficient rows, as in summary()
#let lm-table(path: "results/bike-lm.csv", terms: ("hour", "temperature", "humidity", "windspeed")) = {
  let rows = csv(path, row-type: dictionary).filter(r => r.term in terms)
  let num(x, d) = str(calc.round(float(x), digits: d))
  table(
    columns: 4,
    align: (left, right, right, right),
    stroke: none,
    inset: (x: 10pt, y: 5pt),
    table.hline(),
    table.header([*Term*], [*Estimate*], [*SE*], [*p*]),
    table.hline(stroke: 0.5pt),
    ..rows
      .map(r => (
        raw(r.term),
        num(r.estimate, 1),
        num(r.se, 1),
        if float(r.p) < 0.001 [< 0.001] else { num(r.p, 3) },
      ))
      .flatten(),
    table.hline(),
  )
}

#let ci-table(path: "results/inference.csv") = {
  let rows = csv(path, row-type: dictionary).sorted(key: r => -float(r.importance))
  table(
    columns: 5,
    align: (left, right, right, right, right),
    stroke: none,
    inset: (x: 8pt, y: 3.5pt),
    table.hline(),
    table.header([*Feature*], [*CFI*], [*SE*], [*Lower 95%*], [*p (BH)*]),
    table.hline(stroke: 0.5pt),
    ..rows.map(r => (raw(r.feature), r.label, r.se_label, r.lower_label, r.p_label)).flatten(),
    table.hline(),
  )
}

// ---- Slides ------------------------------------------------------------------

#title-slide(
  title: talk-title,
  subtitle: talk-subtitle,
  author: me,
  institution: [#bips-en \ Bremen, Germany],
  occasion: [DKFZ, Heidelberg],
  author-size: 22pt,
)

// == Motivation (~5 min) =======================================================

// #bips-slide(title: "A matter of interpretation", content-align: horizon + center)[
//   #image("img/blot04.jpg", height: 100%)
// ]

#bips-slide(title: [Why feature importance?], content-align: horizon)[
  - Feature _selection_: which candidate predictors carry most signal?
  - _Sanity_ check: does a model rely on plausible signal? #pause
  - _Hypothesis_ generation
  - _Inference_ on the data-generating process #pause
  - *Caveat*: FI #sym.eq.not causal effect, but associations are still informative #sideref(<ewald2024guidefeatureb>) #pause

  #pause
  #vfill

  #callout-important[
    "Importance" is not a single quantity #to _method choice_ defines the answer
  ]
]

#bips-slide(title: [Which features matter?], content-align: horizon)[
  #two-columns(columns: (1fr, 1.5fr))[
    #lm-table()
    #small[`lm(count ~ .)` on bike-sharing data (more later)]
  ][
    - Linear model: compare $|hat(beta)_j|$, t-test $p$-values #pause
    - Random forest, XGBoost, neural net: no $beta$ to read #pause
    - Feature importance (FI) generalizes into that gap
  ]
  #pause
  #vfill
  #callout-note[*But*: Important _for what_, and _how_ is it measured?]
]

#bips-slide(title: [Importance #sym.eq.not effect])[
  #two-columns(columns: (1fr, 1.2fr))[
    == Effect
    - "What happens to $hat(y)$ _when $X_j$ changes_?"
    - Linear model: $beta_j$
    - _Signed_, in units of $X_j$
    - For arbitrary prediction methods:
      - Partial dependence (_PDP_)
      - Accumulated local effects (_ALE_)
  ][
    #pause
    == Importance
    - "_How much_ does the model / learner rely on $X_j$?"
    - Linear model: $|beta_j|$ #small[(eyeballing)], t-test
    - Unsigned #small[(generally)], one number per feature
    - Extends to nonlinear effects + interactions (depending on learner)
    - Scale depends on the loss #to read as a _ranking_
  ]
]


// == Taxonomy & estimand (~4 min) ==============================================
#section-slide([Taxonomy & Estimands])

#bips-slide(
  title: [A rough taxonomy of interpretibility methods],
  subtitle: [Today: model-agnostic, loss-based, global],
  content-align: center,
)[
  #three-columns[
    #callout()[
      == Model-specific
      (G)LM coefficients, Gini impurity, gradient-based
    ]

    #vfill
    #line(angle: 90deg, end: none, length: 1em)
    vs.
    #line(angle: 90deg, end: none, length: 1em)
    #vfill

    #callout()[
      == Model-agnostic
      supports any learner
    ]
  ][
    #pause
    #callout()[
      == Prediction-based
      How much do predictions change without a feature?
    ]

    #vfill
    #line(angle: 90deg, end: none, length: 1em)
    vs.
    #line(angle: 90deg, end: none, length: 1em)
    #vfill

    #callout()[
      == Loss-based
      how much "worse" does the model get without a feature?
    ]
  ][
    #pause

    #callout()[
      == Local
      One observation's prediction (e.g., SHAP)
    ]

    #vfill
    #line(angle: 90deg, end: none, length: 1em)
    vs.
    #line(angle: 90deg, end: none, length: 1em)
    #vfill

    #callout()[
      == Global
      the model as a whole, feature-specific
    ]
  ]
]

#bips-slide(title: [What are we estimating?])[
  #two-columns(columns: (1fr, 1.1fr))[
    == Which question?
    - *Marginal* ("crude"): $X_j cancel(indep) Y$ \
      Is $X_j$ related to $Y$ at all? #pause
    - *Conditional* ("adjusted"): $X_j cancel(indep) Y | X_(-j)$ \
      Does $X_j$ add information _given the others_?
  ][
    #pause
    == Which target?
    - *Model*: this one fitted model
    - *Learner*: the fitting procedure, across datasets
    - *Data-generating process* #sideref(<williamson2023generalframeworkb>)
  ]
  #pause
  #vfill
  #callout-warning[
    Most methods estimate _model_ importance, research questions usually target the _data_ \
    Linear model: $t$-test for $beta_j$ is the closest analogue, not the same thing
  ]
]

#section-slide([Feature Importance Methods])


// == Methods (~9 min) ==========================================================

#bips-slide(title: [Why not just refit?], subtitle: [Leave-one-covariate-out (LOCO)])[
  #two-columns(columns: (1fr, 1.5fr))[
    == Calculation
    + Fit model $hat(f)$ with all features
    + Refit $hat(f)_(-j)$ without $X_j$
    + Compare test loss
    $ "LOCO"_j = L(hat(f)_(-j)) - L(hat(f)) $
  ][
    #pause
    - Effectively: one step of backward selection
    - Groups: leave-one-_group_-out (LOGO)
    - Leave-one-covariate-_in_ (LOCI): univariate association #pause
    - _Cost_: one refit per feature #to expensive for
      - Complex algorithms / tuning
      - Huge datasets
  ]
  // #meanwhile
  #vfill
  #callout-note(title: [Test loss, e.g. mean squared error])[
    $L(hat(f)) = 1/n sum_(i=1)^n (y_i - hat(f)(x_i))^2$ #h(1em) #to importance is on the scale of the _loss_
  ]
]

#bips-slide(title: [Don't refit, perturb], subtitle: [Permutation feature importance (PFI)])[
  #two-columns(columns: (1fr, 1.4fr))[
    == Calculation
    + Fit model $hat(f)$ once
    + Shuffle $X_j$ in the test data: $tilde(x)_j$
    + Compare test loss before and after
      $ "PFI"_j = L(hat(f), tilde(x)_j) - L(hat(f)) $
    + Repeat $k$ times for stability

  ][
    #pause
    - No refits, works with any learner
    - Breaks the link to $Y$ _and_ to the other features #pause
    - Correlated features #to implausible combinations
      - Ex. A 20-year-old with 30 years of smoking history
  ]
]

#bips-slide(
  title: [Shuffling leaves the data],
  subtitle: [Model is evaluated where it has never seen data #sideref(<hooker2021unrestrictedpermutationb>)],
  content-align: horizon + center,
)[
  #image("img/pfi-extrapolation.png", height: 100%)
]

#bips-slide(title: [Perturb, but keep the dependence], subtitle: [Conditional feature importance (CFI)])[
  - Sample replacement values $tilde(x)_j$ from $X_j | X_(-j)$ instead of marginal shuffling
  - Removes only the part of $X_j$ _not_ explained by the others
  - Stays on the data manifold
  - Otherwise: Same procedure as PFI:
  $ "CFI"_j = L(hat(f); tilde(x)_j) - L(hat(f)), quad tilde(x)_j tilde X_j | X_(-j) $

  #pause
  #vfill
  #pause
  #callout-important[Needs samples from $X_j | X_(-j)$, which are not easy to get]
]

#bips-slide(
  title: [Between PFI and CFI],
  subtitle: [Relative feature importance (RFI) #sideref(<konig2021relativefeatured>)],
)[
  Sample $X_j$ from $X_j | X_G$ for a chosen _conditioning set_ $G$
  #v(1em)
  #three-columns[
    == $G = emptyset$
    - PFI
    - "Does the model use $X_j$?"
  ][
    == $G = {"age", "sex"}$
    - RFI
    - "Beyond age and sex?"
  ][
    == $G = -j$
    - CFI
    - "Beyond all other features?"
  ]
]

#bips-slide(title: [Where do conditional samples come from?])[
  - _Gaussian_: fast, continuous features only
  - _Knockoff_ framework #sideref(<candes2018panninggoldd>)
  - Tabular data is usually _mixed_: continuous, categorical, missing values

  #pause
  #v(3em)
  #callout-tip(title: "Adversarial random forests (ARF)")[
    - Generative model for tabular data #sideref(<watson2023adversarialrandom>)
    - Mixed types, missing values
    - Sampler for CFI and RFI in `{xplainfi}` #sideref(<blesch2025conditionalfeaturea>)
  ]

]

#bips-slide(title: [Is it more than noise?], subtitle: [Inference for CFI])[
  - CFI is a mean of per-observation loss differences, $tilde(x)_i$: $x_i$ with $x_(i j)$ resampled
    $ Delta_i = (y_i - hat(f)(tilde(x)_i))^2 - (y_i - hat(f)(x_i))^2, quad "CFI"_j = overline(Delta) = 1/n sum_(i=1)^n Delta_i $
  - One-sided paired test on $overline(Delta)$ (e.g., t-test, Wilcoxon)
    - _CPI_: conditional predictive impact #sideref(<watson2021testingconditional>)
    - _cARFi_: same test with ARF sampling #sideref(<blesch2025conditionalfeaturea>) #pause
  
  #vfill

  #two-columns[
    #callout-tip[Holdout set, model fixed\ #to _model_ importance]
  ][
    #callout-note[Many features:\ Control FWER or FDR\ (Holm, Benjamini--Hochberg, ...)]
  ]
]

#bips-slide(title: [And now for some game theory], subtitle: [Shapley Additive Global importancE (SAGE)])[
    - Value of a feature set $S$: loss reduction when only features in $S$ are known
      $ v(S) = L(f_emptyset) - L(f_S) $
      #pause
    - *Shapley value*: average gain from adding $j$ #sideref(<shapley1953value>, gap: 1em)
      $ phi_j = sum_(S subset.eq D without {j}) (|S|! (p - |S| - 1)!) / p! [v(S union {j}) - v(S)] $

    #pause
    
    - Unknown features: MC integration over marginal or conditional samples, like PFI vs. CFI
    
    #pause

    #callout-note(title: "SAGE vs. SHAP")[
      #two-columns(columns: (1fr, 1.1fr))[

      SAGE: _global_, explains the loss\ #sideref(<covert2020understandingglobalb>, gap: 0em)
      ][

      SHAP: _local_, explains one prediction\ #sideref(<lundberg2017unifiedapproacha>, gap: 0em)
      ]
    ]
  
]

#section-slide([Application Example])

// == Application (~10 min) =====================================================

#bips-slide(title: [The bike sharing dataset], subtitle: [Capital Bikeshare, Washington, D.C., 2011--2012])[
  #two-columns(columns: (2fr, 3fr))[
    - _Outcome_: bike rentals per hour
    - 3000 hours sampled from \~17k
    - Random forest (`ranger`) and `lm`
    - Holdout: 80% train, 20% test
  ][
    #callout(title: "9 features")[
      - *Calendar*: hour, weekday, working day, season, year
      - *Weather*: temperature, humidity, wind speed, weather type
    ]
  ]

#pause

    #code(
    size: 1.2em,
    "
library(xplainfi)
library(mlr3learners)

task <- tsk(\"bike_sharing\")
learner <- lrn(\"regr.ranger\", num.trees = 1000)
measure <- msr(\"regr.mse\")
resampling <- rsmp(\"holdout\", ratio = 0.8)
",
  )
]

#bips-slide(title: [PFI], content-align: horizon)[
  #two-columns(columns: (2fr, 1fr))[
    #code(
      "
pfi <- PFI$new(
  task, learner, measure,
  resampling = resampling,
  n_repeats = 10
)
pfi$compute()
pfi$importance()
",
    )
  ][
    #fi-table("PFI")
  ]
]

#bips-slide(title: [CFI],  content-align: horizon)[
  #two-columns(columns: (2fr, 1fr))[
    #code(
      hl: (1, 5),
      "
cfi <- CFI$new(
  task, learner, measure,
  resampling = resampling,
  n_repeats = 10,
  sampler = ConditionalARFSampler$new(task)
)
cfi$compute()
cfi$importance()
",
    )
  ][
    #fi-table("CFI")
  ]
]

#bips-slide(title: [LOCO], content-align: horizon)[
  #two-columns(columns: (2fr, 1fr))[
    #code(
      hl: (1,),
      "
loco <- LOCO$new(
  task, learner, measure,
  resampling = resampling
)
loco$compute()
loco$importance()
",
    )
  ][
    #fi-table("LOCO")
  ]
]

#bips-slide(title: [SAGE])[
  #two-columns(columns: (2.2fr, 1fr))[
    #code(
      hl: (1, 4, 5),
      "
sage <- MarginalSAGE$new(
  task, learner, measure,
  resampling = resampling,
  estimator = \"kernel\",
  n_coalitions = 16384
)
sage$compute()
sage$importance()
",
    )
  ][
    #fi-table("SAGE")
  ]
]

#bips-slide(
  title: [SAGE adds up],
  subtitle: [Loss without features #to loss of the model, one step per feature],
  content-align: horizon + center,
)[
  #image("img/sage-waterfall.png", height: 100%)
]

#bips-slide(title: [Comparing methods and learners], content-align: horizon + center)[
  #image("img/bike-methods.png", height: 100%)
]

#bips-slide(title: [Inference], subtitle: [CFI with CPI, 600 held-out hours])[
  #code("cfi$importance(ci_method = \"cpi\", p_adjust = \"BH\")")
  #two-columns(columns: (1.5fr, 1fr))[
    #ci-table()
  ][
    #pause
    - `hour`, `year`, `temperature` clearly important
    - `windspeed`, `holiday`: no evidence
  ]
]

// == Close (~2 min) ============================================================

#bips-slide(title: [Summary])[
  #table(
    columns: 3,
    stroke: none,
    inset: (x: 8pt, y: 6pt),
    table.hline(),
    table.header([*Question*], [*Method*], [*Watch out for*]),
    table.hline(stroke: 0.5pt),
    [Does the model use $X_j$?], [PFI], [extrapolation],
    table.cell(rowspan: 2, align: horizon)[Information beyond the others?], [CFI: perturb], [conditional sampler],
    [LOCO: refit], [refits, learner tuning],
    [Share of the explained loss?], [SAGE], [cost, estimator noise],
    table.hline(),
  )
  - CFI and LOCO: near-identical estimands, different estimation #sideref(<ewald2024guidefeatureb>)
  #vfill
  #callout-important[Pick the method by the question, then check the estimand]
]

#bips-slide(title: [Where to go next])[
  + `install.packages("xplainfi")`
  + Documentation: #link("https://mlr-org.github.io/xplainfi")
  + `xplainfi` and practical guidance: \
    #link(
      "https://doi.org/10.48550/arXiv.2603.15306",
    )[_xplainfi: Feature Importance and Statistical Inference for Machine Learning in R_] \
    #small[Burk et al. (2026), arXiv:2603.15306]
  + Methodological background: \
    #link(
      "https://doi.org/10.1007/978-3-031-63797-1_22",
    )[_A Guide to Feature Importance Methods for Scientific Inference_] \
    #small[Ewald et al. (2024), Explainable Artificial Intelligence (xAI 2024)]
]

#thanks-slide(
  contact-author: me,
  email: "burk@leibniz-bips.de",
  qr-url: "https://slides.lukasburk.de/2026/10-dkfz/slides-handout.pdf",
)

// == Backup ====================================================================

#section-slide([Backup])

#bibliography-slide(
  title: "References",
  text-size: 11pt,
  bib: read("refs.bib"),
  full: true,
)

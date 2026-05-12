#import "@preview/bypst:0.2.0": *
#show: bips-theme.with(
  logo: image("bips-logo.png"),
  base-size: 17pt,
  code-inline-scale: 1,
)

#let me = "Lukas Burk"
#let to = sym.arrow
#let indep = math.class("relation", $perp #h(-2pt) perp$)


#title-slide(
  title: [Identifying Post-COVID Risk Factors\ with Model-Agnostic Feature Importance],
  subtitle: [using the `xplainfi` R package on the German national cohort (NAKO)],
  author: me,
  author-size: 24pt,
  institute: [#bips-en \ Bremen, Germany],
  date: datetime(day: 19, month: 5, year: 2026).display(),
  occasion: [CEN 2026],
)

#bips-slide(
  title: "A matter of interpretation",
  content-align: horizon + center,
)[
  // #figure(image("img/blot04.jpg", height: 69%), caption: [Rohrschach inkblot (Public domain)])
  #image("img/blot04.jpg", height: 69%)
  
  // #align(bottom + center)[
  //   #tiny[Rohrschach inkblot test (public domain)]
  // ]

]

#bips-slide(
  title: [Post-COVID condition (PCC)],
  subtitle: ["Long- / Post-COVID"],
)[
  - Persistent / recurring symptoms long after SARS-CoV-2 infection
  - Clinically heterogenous (symptoms & severity) #pause
  - Working definition #small[@mikolajczyk2024likelihoodpostcovid]:
    - "Any" PCC: at least *1*, "severe" PCC: at least *9*
    - ... symptoms persistent *4+ months after* infection
  #pause
  - Many open questions: risk factors, causal factors, subgroups? #pause
  
  #to *RESOLVE-PCC* project funded by the German BMFTR\ #h(21em) #pause #tiny[(Federal Ministry of Research, Technology and Space)]
]

#bips-slide(
  title: [Why feature importance?],
  subtitle: [What it can and can't tell us about PCC],
)[
  - Predictive models use many candidate risk factors
  - Which ones actually drive predictions? #pause
  - Applications:
    - Feature selection #emoji.hands.shake feature importance #pause
    - Hypothesis generation (e.g. for causal analyses) #pause
    - Communicate model behavior to collaborators #pause
    - Sanity check: is the model relying on plausible signal? #pause
  #pause
  - *FI $eq.not$ causal effect* but associations still informative #tiny[@ewald2024guidefeatureb]
  - "Importance" itself is not a single quantity #pause #to _method choice_ defines the answer
]

#bips-slide(
  title: [Common FI methods],
  subtitle: [How "important" is feature $X_j$?],
)[
  #pause
  #two-columns(columns: (1fr, 1fr))[
    *Perturbation* of $X_j$
    1. Fit full model
    2. Measure performance on... #pause
      - a) all test data #pause
      - b) same data where $X_j$ is _randomly permuted_
    3. Compare performance #pause
    4. (Repeat $k$ times for stability)
    #vfill
    Permutation feature importance (_PFI_)
  ][
    #pause
    *Refitting* without feature $X_j$
    1. Fit full model
    2. Fit model without $X_j$
    3. Compare performance
    4. (Repeat $k$ times for stability)
    #vfill
    Leave-one-covariate-out (_LOCO_)
  ]
]

#bips-slide(
  title: [Conditional FI],
  subtitle: [Permute, but respect feature dependence],
)[
  - PFI permutes $X_j$ marginally #to implausible combinations #tiny[@hooker2021unrestrictedpermutationb]
  - E.g.: "20-year-old with 30 years smoking history"
  #pause
  - CFI: perturbation _conditional_ on other features
    - PFI: $tilde(X)_j tilde F_(X_j)$, with $tilde(X)_j indep (X_(-j), Y)$
    - CFI: $tilde(X)_j tilde F_(X_j | X_(-j))$, with $tilde(X)_j indep Y | X_(-j)$
  #pause
  - Requires _conditional sampling_, some options:
    - Conditional Gaussian #to fast, but only continuous data
    - Adversarial random forests (ARF) #to handles mixed data, computationally heavier
]

#bips-slide(
  title: [What are we explaining?],
  subtitle: [Fixed model, learning algorithm, data-generating process?],
)[
  - *Model-level*: explain a single fitted model
    - One or many permutations (*PFI/CFI*) on a held-out set
  #pause
  - *Learner-level FI*: explain the _prediction method_, not one fit
    - *LOCO* automatically refits, includes learner variability #pause
    - *Any method*: Repeat across resampling (e.g. 15 subsampling iters)
    - Captures variability from data sampling and learner stochasticity
  #pause
  - Estimand should match the research question
    - "Why does _this_ model predict X?" #to model-level
    - "Which features does _this prediction algorithm_ rely on?" #to learner-level
]

// #bips-slide(
//   title: [Stability through repetition],
//   subtitle: [Different sources of variance],
// )[
//   - PFI/CFI are stochastic via the permutation step
//     - Repeat permutations on the same fitted model #to cheap
//   - LOCO requires a refit per feature
//     - Stochastic only if the learner is (random forests, NN init, ...)
//   #pause
//   - Learner-level estimands wrap _all_ of this in an outer resampling loop
//     - Honest uncertainty, but cost multiplies
// ]

#bips-slide(
  title: [Analysis dataset: NAKO],
  subtitle: [German National Cohort],
)[
  - $N approx 66250$ participants reporting $gt.eq 1$ SARS-CoV-2 infection
  - $approx 24%$ classified as *"any PCC"* #h(1em)#small[("Severe PCC" much rarer #to not shown today)]
  #pause
  - Mix of _survey_ + _in-person assessment_:
    - demographics, anthropometrics, socioeconomic
    - comorbidities, smoking history,  biomarker labs (where available)
    - mental-health questionnaires
  #pause
  - $approx 150$ features used (dropping near-constant / near-fully-missing)
  - Rare-event indicators retained despite low prevalence
]

#bips-slide(
  title: [Analysis: Any PCC prediction],
  subtitle: [Preliminary, exploratory],
)[
  - Learners: Gradient boosting (`XGBoost`), random forest (`ranger`)
  - Tuned on *PR-AUC* (due to imbalance) #pause
    - #to general performance  *42--44% PR-AUC* (baseline = 24%)
  - PFI, CFI (+ARF), LOCO computed via `xplainfi` #pause
  - FI here on test set (i.e. *model importance*)
  - FI scores on scale of metric, hard to interpret #pause
    - #to Scaled such that 100 = most important feature
    - Noteworthy: Do rankings change between methods, learners?
]

#bips-slide(
  title: [Results: PFI],
  subtitle: [Top 10 features],
  content-align: horizon + center,
)[
  #image("img/plot-pfi-1.png", height: 75%)
]

#bips-slide(
  title: [Results: CFI],
  subtitle: [Top 10 features],
  content-align: horizon + center,
)[
  #image("img/plot-cfi-1.png", height: 75%)
]

#bips-slide(
  title: [Results: LOCO],
  subtitle: [Top 10 features],
  content-align: horizon + center,
)[
  #image("img/plot-loco-1.png", height: 75%)
]

#bips-slide(
  title: [Same features, different rankings],
  subtitle: [What changes between methods?],
)[
  - Top-ranked features under PFI not always top under CFI / LOCO
    - CFI _should_ de-value importance of correlated features
    - PFI can over-credit features that are easy to extrapolate around
  #pause
  - *Ranks are often more interpretable than raw values*
    - Raw PFI/CFI/LOCO are on the scale of the evaluation metrics
    - Magnitudes hard to compare across methods
]

#bips-slide(
  title: [Cocnlusion],
  subtitle: [Everything is complicated, always],
)[
  - Feature importance is useful, but *not a single number*
  - Each method answers a slightly different question
    - PFI: marginal, model-faithful but extrapolation-prone
    - CFI: conditional, more faithful to joint, sampling-dependent
    - LOCO: refit-based, expensive but assumption-light
  #pause
  - Match the *estimand* to the *research question*
  - Compare methods #to robustness check, not contradiction
  - `xplainfi` provides a unified interface for all of the above #small[@burk2026xplainfifeature]
]

#thanks-slide(
  contact-author: me,
  email: "burk@leibniz-bips.de",
  qr-url: "https://slides.lukasburk.de/2026/05-cen/slides.pdf",
)

#bibliography-slide(
  title: "References",
  text-size: 12pt,
)[
  #bibliography(
    "refs.bib",
    title: none,
    style: "apa",
    full: true,
  )
]

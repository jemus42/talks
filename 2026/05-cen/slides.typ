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
  #image("img/blot04.jpg", height: 69%)
]

#bips-slide(
  title: [Post-COVID condition (PCC)],
  subtitle: ["Long- / Post-COVID"],
)[
  - Persistent or recurring symptoms long after SARS-CoV-2 infection
  - Clinically heterogenous, wide range of symptoms & severity
  - Working definition #small[@mikolajczyk2024likelihoodpostcovid]:
    - "Any" PCC: at least *1*, "severe" PCC: at least *9*
    - ... symptoms persistent *4+ months after* infection
  #pause
  - Many open questions: causal factors? therapeutic benefits? subgroups?
  - #to *RESOLVE-PCC* project funded by the German BMFTR #tiny[(Federal Ministry of Research, Technology and Space)]
]

#bips-slide(
  title: [Why feature importance?],
  subtitle: [What can it tell us about PCC?],
)[
  - Predictive models use many candidate risk factors
  - Which ones actually drive predictions?
  - Several uses:
    - Hypothesis generation for downstream causal analyses
    - Communicating model behavior to clinical collaborators
    - Sanity check: is the model relying on plausible signal?
  #pause
  - *FI $eq.not$ causal effect* — but associations can still be informative @ewald2024guidefeatureb
]

#bips-slide(
  title: [Feature importance is not objective],
  subtitle: [Same data, same model — different stories],
)[
  - "How important is feature $X_j$?" has several reasonable answers
  - Each method encodes different assumptions about
    - what is held fixed,
    - what is varied,
    - and what the resulting drop in performance _means_
  #pause
  - Choice of method shapes the conclusion
  - #to interpretability concept itself requires interpretation
]

#bips-slide(
  title: [Common FI methods],
  subtitle: [How "important" is feature $X_j$?],
)[
  #two-columns(columns: (1fr, 1fr))[
    *Perturbation* of $X_j$
    1. Fit full model
    2. Measure performance on
      - all test data
      - test data where $X_j$ is _randomly permuted_
    3. Compare performance
    4. Repeat $k$ times for stability
    #vfill
    Permutation feature importance (_PFI_)
  ][
    #pause
    *Refitting*
    1. Fit full model
    2. Fit model without $X_j$
    3. Compare performance
    4. Repeat $k$ times for stability
    #vfill
    Leave-one-covariate-out (_LOCO_)\
    Leave-one-group-out (_LOGO_)
  ]
]

#bips-slide(
  title: [PFI and the extrapolation problem],
  subtitle: [Permuting can break the joint distribution],
)[
  - PFI permutes $X_j$ marginally #to breaks dependence with other features
  - Model is forced to predict on _implausible_ feature combinations
  #pause
  - Toy example:
    - $X_1$: age, $X_2$: years smoking
    - Permuting $X_1$ #to "20-year-old with 20 years smoking history"
    - Model extrapolates far outside training support
  #pause
  - Inflates or distorts importance for correlated features @hooker2021unrestrictedpermutationb
]

#bips-slide(
  title: [Conditional FI],
  subtitle: [Permute, but respect the joint distribution],
)[
  - Conditional feature importance (CFI):
    - Same idea as PFI, but perturbation is _conditional_ on other features
    - PFI: $tilde(X)_j tilde F_(X_j)$, with $tilde(X)_j indep (X_(-j), Y)$
    - CFI: $tilde(X)_j tilde F_(X_j | X_(-j))$, with $tilde(X)_j indep Y | X_(-j)$
  #pause
  - Requires _conditional sampling_ machinery
    - Adversarial random forests (ARF) handle mixed-type data well
  #pause
  - Trade-off: more faithful to the joint, but computationally heavier
]

#bips-slide(
  title: [What are we explaining?],
  subtitle: [A fixed model, or the learning algorithm?],
)[
  - *Model-PFI / -CFI / -LOCO*: explain a single fitted model
    - One refit (LOCO) or many permutations (PFI/CFI) on a held-out set
  #pause
  - *Learner-level FI*: explain the _prediction method_, not one fit
    - Repeat across resampling iterations (e.g.\ 15 subsamples)
    - Captures variability from data sampling and learner stochasticity
  #pause
  - Estimand should match the research question
    - "Why does _this_ model predict X?" #to model-level
    - "Which features does _this approach_ rely on?" #to learner-level
]

#bips-slide(
  title: [Stability through repetition],
  subtitle: [Different sources of variance],
)[
  - PFI/CFI are stochastic via the permutation step
    - Repeat permutations on the same fitted model #to cheap
  - LOCO requires a refit per feature
    - Stochastic only if the learner is (random forests, NN init, ...)
  #pause
  - Learner-level estimands wrap _all_ of this in an outer resampling loop
    - Honest uncertainty, but cost multiplies
]

#bips-slide(
  title: [Analysis: RESOLVE-PCC],
  subtitle: [Preliminary, exploratory],
)[
  - Study population: NAKO participants with prior SARS-CoV-2 infection (N $approx$ 66{,}250)
  - Outcomes: "any" PCC and "severe" PCC (binary)
  - Candidate features: demographics, comorbidities, lifestyle, vaccination, infection-related variables
  #pause
  - Learner: gradient boosting (others compared in full analysis)
  - Loss: Brier score on held-out data
  - 15 subsampling iterations #to learner-level FI
  - PFI, CFI (ARF-based), LOCO computed via `xplainfi` @burk2026xplainfifeature
  #pause
  - Showing results for *"any PCC"* — "severe PCC" much harder to model
]

#bips-slide(title: [Results — PFI])[
  // TODO: insert PFI plot
  #image("img/blot04.jpg", height: 75%) // placeholder
]

#bips-slide(title: [Results — CFI])[
  // TODO: insert CFI plot
  #image("img/blot04.jpg", height: 75%) // placeholder
]

#bips-slide(title: [Results — LOCO])[
  // TODO: insert LOCO plot
  #image("img/blot04.jpg", height: 75%) // placeholder
]

#bips-slide(
  title: [Same features, different rankings],
  subtitle: [What changes between methods?],
)[
  - Top-ranked features under PFI not always top under CFI / LOCO
    - Correlated risk factors share importance under CFI
    - PFI can over-credit features that are easy to extrapolate around
  #pause
  - *Ranks are often more interpretable than raw values*
    - Raw PFI/CFI/LOCO are on the scale of the loss (here: Brier score)
    - Magnitudes hard to compare across methods, ranks easier
]

#bips-slide(
  title: [Takeaways],
)[
  - Feature importance is useful, but _not_ a single number
  - Each method answers a slightly different question
    - PFI: marginal, model-faithful but extrapolation-prone
    - CFI: conditional, more faithful to joint, sampling-dependent
    - LOCO: refit-based, expensive but assumption-light
  #pause
  - Match the *estimand* to the *research question*
  - Compare methods #to robustness check, not contradiction
  - `xplainfi` provides a unified interface for all of the above @burk2026xplainfifeature
]

#thanks-slide(
  contact-author: me,
  email: "burk@leibniz-bips.de",
  qr-url: "https://slides.lukasburk.de/2026/05-cen/slides.pdf",
)

#bibliography-slide(
  title: "References",
  text-size: 16pt,
)[
  #bibliography(
    "refs.bib",
    title: none,
    style: "apa",
    full: true,
  )
]

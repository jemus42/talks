#import "@preview/bypst:0.2.0": *
#show: bips-theme.with(
  logo: image("bips-logo.png"),
  base-size: 17pt,
  code-inline-scale: 1,
)

#let me = "Lukas Burk"
#let to = sym.arrow
#let indep = math.class("relation", $perp #h(-2pt) perp$)

#let sideref(body, size: "tiny", gap: 2em) = {
  h(gap)
  if size == "small" { small(body) } else { tiny(body) }
}


#title-slide(
  title: [Identifying Post-COVID Risk Factors\ with Model-Agnostic Feature Importance],
  subtitle: [using the `xplainfi` R package with the German national cohort (NAKO)],
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
  subtitle: [Not to be confused with "long COVID"],
)[
  - Persistent / recurring symptoms long after SARS-CoV-2 infection
  - Clinically heterogenous (symptoms & severity) #pause
  - Working definition: #sideref(size: "small")[@mikolajczyk2024likelihoodpostcovid] #pause
    - "Any" PCC: at least *1* symptom persistent *4+ months after* infection #pause
    - "Severe" PCC: at least *9*
  #pause
  - Many open questions: risk factors, causal factors, subgroups? #pause

  #to *RESOLVE-PCC* project funded by the German BMFTR #h(2em) #pause #box[#align(horizon + center)[#tiny[Federal Ministry of\ Research, Technology and Space]]]
]

#bips-slide(
  title: [Why feature importance?],
  subtitle: [What it can and can't tell us about PCC],
)[
  - Predictive machine learning models use many candidate risk factors
  - Which ones actually drive predictions? #pause
  - Applications:
    - Feature selection #emoji.hands.shake feature importance #pause
    - Sanity check: is the model relying on plausible signal? #pause
    - Hypothesis generation #pause
    - *FI $eq.not$ causal effect* but associations still informative #sideref[@ewald2024guidefeatureb] #pause
  - "Importance" itself is not a single quantity #pause #to _method choice_ defines the answer
]

#bips-slide(
  title: [Common FI methods],
  subtitle: [How "important" is feature $X_j$ for prediction?],
)[
  #pause
  #two-columns(columns: (1fr, 1.3fr))[
    *Refitting* without feature $X_j$
    1. Fit full model
    2. Fit model without $X_j$
    3. Compare performance #pause
    4. (Repeat $k$ times for stability) #pause
    #vfill
    Leave-one-covariate-out (_LOCO_)
  ][
    #pause
    *Perturbation* of $X_j$
    1. Fit full model
    2. Measure performance on... #pause
      - a) all test data #pause
      - b) same data where $X_j$ is _randomly permuted_
    3. Compare performance #pause
    4. (Repeat $k$ times for stability) #pause
    #vfill
    Permutation feature importance (_PFI_)
  ]
]

#bips-slide(
  title: [Conditional FI],
  subtitle: [Permute, but respect feature dependence],
)[
  - PFI permutes $X_j$ marginally #to implausible combinations #sideref[@hooker2021unrestrictedpermutationb]
  - E.g.: "20-year-old with 30 years smoking history"
  #pause
  - CFI: perturbation *conditional* on other features
  // - PFI: $tilde(X)_j tilde F_(X_j)$, with $tilde(X)_j indep (X_(-j), Y)$
  // - CFI: $tilde(X)_j tilde F_(X_j | X_(-j))$, with $tilde(X)_j indep Y | X_(-j)$
  #pause
  - Requires _conditional sampling_ $tilde(X)_j tilde F_(X_j | X_(-j))$, some options: #pause
    - Conditional Gaussian #to fast, but only continuous data #pause
    - Adversarial random forest (ARF) #sideref[@blesch2025conditionalfeaturea] #pause \
      #to handles _mixed_ data, _missing values_, computationally more expensive
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
    - *Any method*: Repeat across resampling (e.g. bootstrap, subsampling, CV)
    - Captures variability from data sampling and learner stochasticity
  // #pause
  // - Estimand should match the research question
  //   - "Why does _this_ model predict X?" #to model-level
  //   - "Which features does _this prediction algorithm_ rely on?" #to learner-level
]


#bips-slide(
  title: [Analysis dataset: NAKO],
  subtitle: [German National Cohort],
)[
  - $N approx 66.000$ participants reporting $gt.eq 1$ SARS-CoV-2 infection
  - #blue[$approx 24%$ classified as "any PCC"] #h(1em)#small[("Severe PCC" much rarer #to not shown today)] #pause
  - #to *Goal*: Predict "any PCC" vs. "no PCC" (binary classif)
  #pause
  - Mix of _survey_ + _in-person assessment_:
    - demographics, anthropometrics, socioeconomic
    - comorbidities, smoking history,  biomarker labs (where available)
    - mental-health questionnaires
  #pause
  - $approx$ 50 features used
]

#bips-slide(
  title: [Analysis: 'Any PCC' prediction],
  subtitle: [Preliminary, exploratory],
)[
  - Learners: Gradient boosting (`XGBoost`), random forest (`ranger`)
  - Tuned on *PR-AUC* (baseline = 24%) #pause
  - General performance:
    - PR-AUC $approx$ 43%
    - ROC-AUC $approx$ 64% #pause
  - *PFI*, *CFI* (+ARF), *LOCO* computed on _test set_ (model importance)
]

#bips-slide(
  title: [Results: Permutation Feature Importance (PFI)],
  subtitle: [Top 10 features (between RF + XGBoost)],
  content-align: horizon + center,
)[
  #image("img/top10_pfi_narrow.png", height: 75%)
]

#bips-slide(
  title: [Results: Conditional Feature Importance (CFI)],
  subtitle: [Top 10 features, one-sided 95% CIs],
  content-align: horizon + center,
)[
  #image("img/top10_cfi_narrow.png", height: 75%)
]

#bips-slide(
  title: [Results: Leave-one-covariate-out (LOCO)],
  subtitle: [Top 10 features, one-sided 95% CIs],
  content-align: horizon + center,
)[
  #image("img/top10_loco_narrow.png", height: 75%)
]

#bips-slide(
  title: [Conclusion],
  subtitle: [Everything is complicated, always],
)[
  - Feature importance is useful, but *not a single number*
  - Each method answers a slightly different question #pause
    - *PFI*: marginal, model-faithful but extrapolation issue #pause
    - *CFI*: conditional, more faithful to joint distr., sampling-dependent #pause
    - *LOCO*: refit-based, expensive but assumption-light #pause
  - Don't forget the role of the *learner*
  - Compare methods #to robustness check, not contradiction #pause
  - `xplainfi` provides a unified interface for all of the above #pause #sideref(size: "small")[@burk2026xplainfifeature]
]

#thanks-slide(
  contact-author: me,
  email: "burk@leibniz-bips.de",
  qr-url: "https://slides.lukasburk.de/2026/05-cen/20260519_1345_Machine_learning_1_Burk_Identifying_risk.pdf",
)

#bibliography-slide(
  title: "References",
  text-size: 13pt,
)[
  #bibliography(
    "refs.bib",
    title: none,
    style: "springer-basic-author-date",
    full: true,
  )
]

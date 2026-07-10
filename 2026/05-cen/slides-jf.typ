#import "@preview/bypst:0.4.0": *
#show: bips-theme.with(
  logo: image("bips-logo.png"),
  base-size: 17pt,
  code-inline-scale: 1,
  handout: false,
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
  date: [#datetime(day: 19, month: 5, year: 2026).display() / #datetime(day: 10, month: 7, year: 2026).display()],
  occasion: [Originally at CEN 2026, adapted for RESOLVE-PCC Jour Fixe],
)


#bips-slide(
  title: [Post-COVID condition (PCC)],
  subtitle: [Sometimes used interchangibly with "long COVID"],
)[
  - Persistent / recurring symptoms long after SARS-CoV-2 infection
  - Clinically heterogenous (symptoms & severity) #pause
  - Working definition based on symptom catalogue (using grouped sympoms):
    - "Any" PCC: at least *1* symptom persistent *4+ months after* infection #pause
    - "Severe" PCC: at least *9*
]

#bips-slide(
  title: [Why feature importance?],
  subtitle: [What it can and can't tell us about PCC],
)[
  - Predictive machine learning algorithms use many candidate risk factors
  - Which ones actually drive predictions? #pause
  - Applications:
    - Feature selection #emoji.hands.shake feature importance
    - Sanity check: is the model relying on plausible signal?
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
    3. Compare performance (post - pre)
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
    3. Compare performance
    4. (Repeat $k$ times for stability) #pause
    #vfill
    Permutation feature importance (_PFI_)
  ]
]

#bips-slide(
  title: [Conditional FI],
  subtitle: [Permute, but respect feature dependence],
)[
  - *PFI* permutes $X_j$ marginally #to implausible combinations #sideref[@hooker2021unrestrictedpermutationb]
    - E.g.: "20-year-old with 30 years smoking history"
  #pause
  - *CFI*: perturbation *conditional* on other features
  // - PFI: $tilde(X)_j tilde F_(X_j)$, with $tilde(X)_j indep (X_(-j), Y)$
  // - CFI: $tilde(X)_j tilde F_(X_j | X_(-j))$, with $tilde(X)_j indep Y | X_(-j)$
  #pause
  - Requires _conditional sampling_ $tilde(X)_j tilde F_(X_j | X_(-j))$ #to hard, some options: #pause
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
  - *Learner-level FI*: explain the _prediction algorithm_, not one fit
    - *LOCO* automatically refits, includes learner variability #pause
    - *Any method*: Repeat across resampling (e.g. subsampling, CV)
    - Captures variability from the _data_ and _learner stochasticity_
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
  - #to *Goal*: Predict _"any PCC" vs. "no PCC"_ (binary classif)
  #pause

  == Featurers used

  - $approx$ 50 features from _survey_ + _in-person assessment_ blocks:
    - demographics, anthropometrics, socioeconomic
    - comorbidities, smoking history,
    - mental-health questionnaires (PHQ, GAD)

  #pause

]

#bips-slide(
  title: [Analysis: 'Any PCC' prediction],
  subtitle: [Preliminary, exploratory],
)[
  - Learners: Gradient boosting (`XGBoost`), random forest (`ranger`)
  - Tuned on *PR-AUC* (baseline performance = 24%) #pause
  - Cross-validated performance #small[(nested resampling)]:
    - PR-AUC $approx$ 43%
    - ROC-AUC $approx$ 64% #pause
    - Not great, but comparable with literature for cohort data with baseline features
  - *PFI*, *CFI* (+ARF), *LOCO* computed on _test set_ (model importance)
]

#bips-slide(
  title: [Results: Permutation Feature Importance (PFI)],
  subtitle: [Top 10 features (between RF + XGBoost)],
  content-align: horizon + center,
)[
  #image("img/top10_pfi_narrow.png", height: 100%)
]

#bips-slide(
  title: [Results: Conditional Feature Importance (CFI)],
  subtitle: [Top 10 features, one-sided 95% CIs],
  content-align: horizon + center,
)[
  #image("img/top10_cfi_narrow.png", height: 100%)
]

#bips-slide(
  title: [Results: Leave-one-covariate-out (LOCO)],
  subtitle: [Top 10 features, one-sided 95% CIs],
  content-align: horizon + center,
)[
  #image("img/top10_loco_narrow.png", height: 100%)
]

#bips-slide(
  title: [Intermediate conclusion],
  subtitle: [Everything is complicated, always],
)[
  - Feature importance is useful, but *not a single number*
  - Each method answers a slightly different question #pause
    - *PFI*: marginal, model-faithful but extrapolation issue #pause
    - *CFI*: conditional, more faithful to joint distr., sampling-dependent
    - *LOCO*: refit-based, expensive but assumption-light
  - Don't forget the role of the *learner*
  - Compare methods #to robustness check, not contradiction
  - `xplainfi` provides a unified interface for all of the above #sideref(gap: 1fr, size: "small")[@burk2026xplainfifeature]
]



#bips-slide(
  title: [Next steps],
  subtitle: [Improve prediction + extend interpretibility],
)[
  == Predictive performance weak
  - Currently weak #to lessens generalizability of conclusions
  - Integrate additional features and compare two feature sets
    - New *"Baseline"*: Current baseline + COVID vaccination
    - *"Acute"*: New baseline + feature related to acute infection #small[(likely large influence based on lit.)]
  - *Target*: Use "raw" NAKO symptom count rather than coarse "Any" / "Severe" PCC endpoints?

  #pause
  == Interpretability:
  - Apply local explanations (e.g. _SHAP_) to notable participants with high / low risk
  - Apply regional feature importance (_GADGET_):
    - Idea: Detect feature importance heterogeneity by subgroups
]

#thanks-slide(
  contact-author: me,
  email: "burk@leibniz-bips.de",
  // qr-url: "https://slides.lukasburk.de/2026/05-cen/20260519_1345_Machine_learning_1_Burk_Identifying_risk.pdf",
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

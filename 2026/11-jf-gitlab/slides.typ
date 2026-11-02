#import "@preview/bypst:0.6.0": *

#let me = "Lukas Burk"
#let talk-title = [An exceedingly brief introduction\ to GitLab and the cluster]
#let talk-subtitle = [Hey look we have a GitLab isn't that cool oh also a cluster neat]
#let to = sym.arrow


#show: bips-theme.with(
  config-info(
    title: talk-title,
    subtitle: talk-subtitle,
    author: me,
    date: datetime(day: 02, month: 11, year: 2026).display(),
  ),
  logo: image("bips-logo.png"),
  base-size: 16pt,
  code-inline-scale: 1,
  // handout: false,
)

// ---- Slides ------------------------------------------------------------------

#title-slide(
  title: talk-title,
  subtitle: talk-subtitle,
  author: me,
  institution: bips-en,
  occasion: [Jour Fixe],
  author-size: 22pt,
)

#section-slide([`git` and GitLab])

#bips-slide(
  title: [What is `git` and GitLab],
  subtitle: [],
  composer: (1fr, 1.1fr)
)[
  == `git`
  - Version control program for *code* / plain text
  - #blue[Standard development practice] #pause
  - Installed on your computer and wherever else #small[(workstations, cluster, termserv)]
  - A folder using `git` is a *repository* #pause
    - Saves the changes between code versions #pause
    - Each "checkpoint" is a *commit* #pause
    - Retains *complete history* of a project #pause
  - Can by synchronized with a *server*, such as...

][
  #pause
  == GitLab
  - GitLab.com $approx$ GitHub.com alternative
  - Private BIPS server at #large[#blue[`srvgit.bips.eu`]] #pause
  - Supplements existing (public) use of GitHub.com #pause
  - Hosts `git` repositories: typically code / analyses #pause
  - Adds: *Project management and collaboration*
    - issue boards (e.g., todo list), discussions
    - Work on same code (merge requests)
    - `@`-tagging users you collaborate with
  - View results if produced in RMarkdown/Quarto!

]

#bips-slide(title: [GitLab: Example repository], content-align: horizon + center)[
  #image("img/gitlab-repo-example.png", height: 100%)
]

#bips-slide(title: [GitLab: Per-line code history], content-align: horizon + center)[
  #image("img/gitlab-blame.png", height: 100%)
]

#bips-slide(
  title: [Where repositories live],
  subtitle: [],
  composer: (1fr, 1fr),
)[
  - Users belong to *groups*, which share access
  - Repositories should be _created under a group_
  - Everyone here: Member of the *BIPS group* #pause
  - #to Central group ensures collaboration
  - Groups can have nested subgroups
    - Entities like *NAKO*, *IDEFICS/I.Family*
    - Research units
    - Topic groups
    - ...

  #pause

  #callout-note()[We will flexibly adapt this going forward]

][
  == Example repository hierarchy
  - `BIPS`
    - `HPC`
      - `bips-cluster-user-docs`
    - `FG ML`
      - `kukuk-shiny`
    - `NAKO`
      - ...
    - `IDEFCS/I.Family`
      - ...
  - `burk`
    - `gitlab-intro` 
]



#bips-slide(title: [GitLab: BIPS Group], content-align: horizon + center)[
  #image("img/gitlab-overview.png", height: 100%)
]


#bips-slide(title: [GitLab: Activity feed], content-align: horizon + center)[
  #alternatives()[
    #image("img/gitlab-activity-mine.png", height: 100%)
  ][
    #image("img/gitlab-activity-other.png", height: 100%)
  ]
]

#bips-slide(title: [GitLab: Project issues], content-align: horizon + center)[
  #alternatives()[
    #image("img/gitlab-example-issues.png", height: 100%)
  ][
    #image("img/gitlab-example-issues-single.png", height: 100%)
  ]
]


#bips-slide(title: [GitLab: We're still getting started!], content-align: horizon)[

  #two-columns(columns: (1fr, 1.8fr))[
    == What stays

    - `G:\` remains generic file storage
    - OX-Drive remains
    - Word, Excel, PDF, datasets: unchanged
    - Public R packages and paper supplements stay on _GitHub_

  ][
    #pause
    == What changes

    - Analysis code is `git`-versioned on GitLab rather than manually
    - Collaboration via *issues* and *merge requests* #pause
    - Trackable _who_ changed _what_, _when_, and _why_
    - Older versions can be restored and compared #small[(thanks to `git`)] #pause
    - Analysis results #to RMarkdown/Quarto #to viewable live \ 
      (accessible also for non-coders)
  ]

  #pause
  #vfill
  
  #callout-important(title: [There will be trainings])[
    Different scopes for PhDs, supervisors, programmers, ... \ #pause
    Planned next steps will be _announced via e-mail_!\ #pause
    *Optional*: _Reach out to me_ for dedicated sessions 
  ]
]


// #bips-slide(
//   title: [Continuous integration (CI/CD)],
//   subtitle: [Killer features of GitHub, GitLab & friends],
//   composer: (1fr, 1fr),
// )[
//   == Code _artifacts_
//   - Built program
//   - Computational output
//   - Compiled document

//   #pause
//   == Workflow:
//   - Push changes to GitLab
//   - GitLab kicks off pre-defined steps
//   - Run in _constrained_ and server environment
//   - Output can be downloaded or viewed
// ][
//   #pause
//   == Examples:
//   - Software #to compiled binary
//   - LaTeX documents #to compiled PDF
//   - RMarkdown or Quarto: Rendered website
// ]

#section-slide([The BIPS HPC cluster])

#bips-slide(
  title: [What's in a cluster],
  subtitle: [],
)[
  Many ways to shave a yak, and now you have one more!
  #v(1em)

  #three-columns(
    columns: (0.8fr, 1fr, 1.4fr),
    gutter: 0.2em,
  )[
    #pause
    == Your PC/laptop
    - You know it
    - Shorter tasks
    - Not so powerful
    - Completely your own
    - Convenience: #emoji.nails.polish
  ][
    #pause
    == Server
    - TermServ / workstations
    - Run _looong_ tasks
    - 1 powerful computer
    - _Shared_
    - Convenience: Mixed
  ][
    #pause
    == HPC Cluster
    - Many powerful computers connected
    - >1000 CPU cores, 2 GPUs, terabytes of RAM
    - Access via _head node_
    - _Shared_ (resources managed via scheduler) #pause
    - Convenience:
      - Learning curve (Linux, Slurm, ...)
      - You'll get there
  ]

]

#bips-slide(
  title: [Cluster docs rendered via GitLab CI],
  subtitle: [Deployed to GitLab Pages, viewable in institute network],
  content-align: horizon + center)[
    #two-columns(columns: (1fr, 2fr))[
    http://pages-gitlab.bips.eu/bips/hpc/bips-cluster-user-docs
    ][
    #image("img/cluster-docs.png", height: 100%)
    ]
]

#bips-slide(
  title: [Cluster],
  subtitle: [Get access & learn more],
  content-align: horizon, code-inline-scale: 1.2
)[

  1. _Ask me for an account_, I will send you login credentials (#blue[`burk`])
  2. Bookmark the dashboard (current cluster usage):
    - #link("http://srvcluster.bips.de/")[http://srvcluster.bips.de/] (no https!)
  3. Read (and bookmark) the docs:
    - #link("http://pages-gitlab.bips.eu/bips/hpc/bips-cluster-user-docs")[http://pages-gitlab.bips.eu/bips/hpc/bips-cluster-user-docs] 
  4. Try demos / usage examples for `batchtools`, and others on GitLab:
    - #link("https://srvgit.bips.eu/bips/bips-cluster-demos")[http://srvgit.bips.eu/bips/bips-cluster-demos]
]

#thanks-slide(
  contact-author: me,
  email: "burk@leibniz-bips.de",
  qr-url: sys.inputs.at("url", default: "https://slides.lukasburk.de"),
)

#import "@local/bips-typst:0.1.1": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#show: bips-theme.with(
  base-size: 18pt, // Smaller base text
  slide-title-size: 22pt, // Smaller slide titles
  slide-subtitle-size: 16pt, // Smaller slide subtitles
)

#title-slide(
  title: "Hey look we have a cluster now isn't that cool what does it do does it do stuff yes it does it's cool",
  subtitle: [Doing cluster stuff for fun and #strike[profit] science],
  author: "Lukas Burk",
  institute: bips_en,
  date: datetime.today().display(),
  occasion: "BioWiMium",
)

#bips-slide(
  title: "We have a new cluster",
  subtitle: [You might have _*heard*_],
)[

  #two-columns()[
    == What we cover today:

    - What is it
    - How does it work (Slurm)
    - How do *you* do stuff on it
    - I know it's noisy stop throwing stuff #emoji.face.cry

  ][
    #pause
    == We *don't* cover

    - How to Linux (from the command line)
    - How to use `batchtools` or targets
    - How to setup a simulation study
  ]

]

#bips-slide(
  title: "What is a cluster",
  subtitle: "And why should you care",
)[
  #set list(spacing: 0.3em)

  Many ways to shave a yak, and now you have one more!
  #v(1em)

  #three-columns(
    columns: (0.7fr, 1fr, 1fr),
    gutter: 0.2em,
  )[
    #pause
    == Your PC/laptop
    - You know it
    - Shorter tasks
    - Not so powerful
    - Convenience: #emoji.nails.polish
  ][
    #pause
    == Workstation / Server
    - TermServ, Bertha
    - Run looong tasks unsupervised
    - Powerful
    - Shared
    - Convenience: Mixed
  ][
    #pause
    == HPC ("Cluster")
    - Many powerful computers
    - Access indirectly (head node)
    - Shared (job management)
    - Convenience: You'll get there

  ]
]


#bips-slide(
  title: "What does it look like?",
  subtitle: "Kind of like this",
  content-align: horizon + center,
)[

  #image("img/stock-rack.jpg", height: 70%)
]

#bips-slide(
  title: "Cluster topology",
  subtitle: "It only looks weird because it is",
  content-align: horizon + center,
)[
  #diagram(
    node-stroke: 1pt,
    spacing: (4em, 1em),
    // You
    node((0, 0), [#emoji.laptop I need to\ compute stuff], corner-radius: 2pt, extrude: (0, 3)),
    edge("-|>", [SSH]),
    // Head node
    node((1, 0), align(center)[#emoji.computer Head Node], corner-radius: 2pt),
    edge("-|>", [Slurm]),
    // Slurm scheduler
    node((2, 0), align(center)[#emoji.gear Slurm\ Scheduler], corner-radius: 2pt, fill: rgb("#cce0ff")),
    // Branching to compute nodes
    edge((2, 0), (3, -1), "-|>"),
    edge((2, 0), (3, 0), "-|>"),
    edge((2, 0), (3, 1), "-|>"),
    // Compute nodes
    node((3, -1), align(center)[#emoji.computer Node 01], corner-radius: 2pt, fill: rgb("#ccf2cc")),
    node((3, 0), align(center)[#emoji.computer Node 02], corner-radius: 2pt, fill: rgb("#ccf2cc")),
    node((3, 1), align(center)[#emoji.computer Node 03], corner-radius: 2pt, fill: rgb("#ccf2cc")),
  )
]

#bips-slide(
  title: "Terminology",
  subtitle: "Just to make sure you're confused",
)[

  - The cluster has 12 compute *nodes* (self-contained computer)
    - Each node has 1 *CPU* (physical processor)
    - Each processor is made up of independent 96 *cores*
    - Each core can handle 2 *threads* (_not_ independent)

  #pause
  - Terminology here weird and confusing because history
    - Until the 90s: 1 CPU = 1 core = 1 thread
    - Here: 1 Node = 1 CPU = 96 Cores = 192 threads
  #pause
  #callout(type: "warning")[
    *Slurm*: When you want 10 *threads* you request 10 "cpus"
  ]
]


#bips-slide(
  title: "HPC Workflow",
  subtitle: "",
)[

  1. Log in (land in *head node*)
  2. Start your *job*(s)

]

#bips-slide(
  title: "Logging in",
  subtitle: "Different environments for different tasks",
)[

  Connect to the cluster *head node* via SSH in one of two ways

  #two-columns(gutter: 2em, columns: (1fr, 1.2fr))[
    == Terminal
    #compact[
      - Definitely cool and normal
      - 1337 h4xX0r feeling
    ]

    #align(center)[
      #image("img/terminal.png", height: 40%)
    ]
  ][
    #pause
    == VScode / Positron

    - Uses SSH for communication with head node
    - GUI like on your own device
    - All content is on the head node
    - Edit files conveniently
    - VSCode / Positron runs *on your device*
    - Terminal / R console runs *on head node*

  ]
]


#bips-slide(
  title: "How are resources allocated?",
  subtitle: "Slurm manages resources on the cluster",
)[

  - Example: You need  *20 threads* for *6 hours* and *4GB of RAM* for `analysis.R`

  #two-columns()[
    == Interactive

    ```
    salloc --cpus-per-task=20 --mem=4G --time=06:00:00

    ```

    ```
    salloc: Granted job allocation 137031
    salloc: Nodes node01 are ready for job

    # start R session
    R

    # Run your script
    source("analysis.R")
    ```

  ][
    #pause
    == Batch job
    - Write an `analysis.sh` wrapper script

    ```
    #!/bin/bash
    #SBATCH --job-name=my-analysis
    #SBATCH --output=job_%j.out
    #SBATCH --cpus-per-task=20
    #SBATCH --mem=4096M
    #SBATCH --time=06:00:00

    Rscript analysis.R
    ```

    - Run `sbatch analysis.sh` and go home

  ]
]


#bips-slide(
  title: "Software is managed differently",
  subtitle: "Environment modules",
)[

  - Common on HPC systems: Hundreds of users who need dozens of programs
  - Programs exist in dozens of versions (R, Python, specialized tools)
  #pause
  - Different users need different versions of different things
    - _Example_: I needed *R 4.4* for survival benchmark, *R 4.5* for other projects
  - Can't have everything loaded all the time simulataneously
  #pause
  - Common solution: environment modules
    - Log in on head node: R not available
    - Run `module load R/4.4.3` #sym.arrow R v4.4.3 is available
  - Log in, load modules, _then_ run `salloc`, `sbatch` etc.
]

#thanks-slide(
  contact-author: "Lukas Burk",
  email: "burk@leibniz-bips.de",
)

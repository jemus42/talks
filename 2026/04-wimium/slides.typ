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
  date: datetime.today().display("[year]-[month]-[day]"),
  occasion: "BioWiMium",
)

#bips-slide(
  title: "We have a new cluster",
  subtitle: [You might have _*heard*_],
)[

  #two-columns()[
    == What we cover today:
    
    - What is it
    - How does it work (using R / Python, Slurm)
    - How do *you* do stuff on it
  
  ][
    #pause
    == We *don't* cover
    
    - How to Linux (from the command line)
    - How to use `batchtools` (or `targets`)
    - How to setup a simulation study
  ]
  #pause
  #vfill
  #callout(type: "note", icon: emoji.face.cry)[
    I know it's noisy stop throwing stuff
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
    - 1 powerful computer
    - Shared
    - Convenience: Mixed
  ][
    #pause
    == HPC ("Cluster")
    - Many powerful computers
    - Access indirectly (head node)
    - Shared (job management) #pause
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
    edge("-|>", [sbatch\ salloc]),
    // Slurm scheduler
    node((2, 0), align(center)[#emoji.gear Slurm\ Scheduler], corner-radius: 2pt, fill: rgb("#cce0ff")),
    // Branching to compute nodes
    edge(
      (2, 0),
      (3, -1),
      "-|>",
      [jobs],
      label-angle: 20deg,
      label-pos: 60%,
      label-anchor: "base",
    ),
    edge((2, 0), (3, 0), "-|>", [jobs], label-angle: 1deg, label-pos: 60%, label-anchor: "base"),
    edge((2, 0), (3, 1), "-|>", [jobs], label-angle: -20deg, label-pos: 60%, label-anchor: "base"),
    // Compute nodes
    node((3, -1), align(center)[#emoji.computer Node 01], corner-radius: 2pt, fill: rgb("#ccf2cc")),
    node((3, 0), align(center)[#emoji.computer Node 02], corner-radius: 2pt, fill: rgb("#ccf2cc")),
    node((3, 1), align(center)[#emoji.computer Node 03], corner-radius: 2pt, fill: rgb("#ccf2cc")),
  )
]

#bips-slide(
  title: "Terminology",
  subtitle: "Just to make sure you're confused",
  text-size: 16pt,
)[
  
  #two-columns(columns: (2fr, 1fr))[
  - The cluster has 12 compute *nodes* (self-contained computer)
    - Each node has 1 *CPU* (physical processor)
    - Each processor is made up of independent 96 *cores*
    - Each core can handle 2 *threads* #pause
  - Terminology here weird and confusing because history #emoji.person.shrug
    - Until the 90s: *1* CPU = *1* core = *1* thread #pause
    - Then: Hyperthreading: *1* CPU = *1* core = *2* threads #pause
    - *Now*: *1* CPU = *96* cores = *192* threads #pause
    *Slurm*: When you want 10 *threads* you request 10 "cpus"
  // #callout(type: "warning")[
  //   *Slurm*: When you want 10 *threads* you request 10 "cpus"
  // ] 
][
  #set text(size: 10pt)
  #let thread-box = rect(
    fill: rgb("#e8d5f5"),
    radius: 2pt,
    inset: 4pt,
    width: 100%,
    align(center)[T],
  )
  #let core-box(n) = rect(
    fill: rgb("#ccf2cc"),
    radius: 3pt,
    inset: 5pt,
    width: 100%,
    [*Core #n*
      #grid(
        columns: 2,
        gutter: 3pt,
        thread-box, thread-box,
      )],
  )
  #rect(
    stroke: 1.5pt,
    radius: 4pt,
    inset: 8pt,
    width: 100%,
    [*Node 01*
      #rect(
        fill: rgb("#cce0ff"),
        radius: 3pt,
        inset: 6pt,
        width: 100%,
        [*CPU*
          #grid(
            columns: 2,
            gutter: 4pt,
            core-box(1), core-box(2),
            core-box("n"), core-box(96),
          )],
      )],
  )
]
  

]

#bips-slide(
  title: "But what is Slurm even",
)[
  - Slurm is the job management system
  - Every CPU, every Byte of RAM on the compute nodes is _kept track of_
  
  #pause
  #sym.arrow *You can only use resources allocated to you*
  
  #pause
  
  == Things that _do not _happen on a cluster:
  
  - "My job took too much RAM so your jobs got killed alongside mine sorry"
  #pause
  - "I used 2374123 threads but only meant to use 10 sorry your jobs are smothered"
]


#bips-slide(
  title: "HPC Workflow",
  subtitle: "",
)[

  1. Log in (land in *head node*) #pause
  2. Start your *job*(s) #pause
  3. Monitor jobs with `squeue` and other commands #pause
  4. Log out, check back later #pause
  5. If jobs failed, debug & resubmit #pause
  6. Repeat until #strike("insane") done

]

#bips-slide(
  title: "Logging in",
  subtitle: "Different environments for different tasks",
)[

  Connect to the cluster *head node* via SSH in one of two ways: #pause

  #two-columns(gutter: 2em, columns: (1fr, 1.2fr))[
    == Terminal
    #compact[
      - Definitely cool and normal
      - 1337 h4xX0r feeling
    ]

    #align(center)[
      #image("img/terminal.png", height: 30%)
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
  title: "Software is managed differently",
  subtitle: "Environment modules",
)[
  
  - Common on HPC systems: Hundreds of users need dozens of programs
  - Programs exist in dozens of versions (R, Python, specialized tools) #pause
  - Different users need different versions of different things #pause
  
  == Solution: *Environment modules*
  - Log in on head node: R not available
  - Run `module load R/4.4.3` #sym.arrow R v4.4.3 is available
  - Log in, load modules, _then_ run `salloc`, `sbatch` etc.
]

#bips-slide(
  title: "How are resources allocated?",
  subtitle: "Slurm manages resources on the cluster",
)[

  - Example: You need  *20 threads* for *6 hours* and *4GB of RAM* for `analysis.R` #pause

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
    
    # Do work or run script
    ranger::ranger(foo ~ ., data = bar)
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
  title: "Slurm resource allocation",
  subtitle: "A job is not a job",
)[
  - Slurm is very generic and supports diverse types of jobs
  - Easiest us: 1 job = 1 R/py process = Some number of threads on 1 node
  - Slurm allocates *cores*, not *threads*
  - You only care about threads
  - You need 1 thread, you ask for `cpus-per-task=`*`1`*, you get *1* core reserved

]

#bips-slide(
  title: "Efficiently using a node",
)[
  == If your goal is to fully utilize 1 node, you can... #pause
  - 1 job with 192 threads #emoji.checkmark.box #pause
  - 96 jobs with 2 threads #emoji.checkmark.box #pause
  - 8 jobs with 24 threads #emoji.checkmark.box #pause
  
  - 192 jobs with 1 thread #emoji.crossmark #pause
  

]


#bips-slide(
  title: "Further reading",
  text-size: 22pt,
)[
  - Documentation:
    - #link("https://cluster.bips.coffee")[cluster.bips.coffee] (public)
  - Dashboard (current usage):
    - #link("http://srvcluster.bips.de/")[http://srvcluster.bips.de/] (no https!)
  - Demos / usage examples for `batchtools`, `mirai`, `targets`:
    - #link("https://srvgit.bips.eu/bips/bips-cluster-demos")[srvgit.bips.eu/bips/bips-cluster-demos]
]

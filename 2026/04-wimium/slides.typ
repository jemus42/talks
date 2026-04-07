#import "@local/bypst:0.2.0": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#show: bips-theme.with(
  base-size: 18pt, // Smaller base text
  slide-title-size: 26pt, // Smaller slide titles
  slide-subtitle-size: 20pt, // Smaller slide subtitles
  code-inline-scale: 1,
)

#title-slide(
  title: "Hey look we have a cluster now isn't that cool what does it do does it do stuff yes it does it's cool",
  subtitle: [Doing cluster stuff for fun and #strike[profit] science],
  author: "Lukas Burk",
  institute: bips-en,
  date: datetime.today().display(),
  occasion: "BioWiMium",
)

#bips-slide(
  title: "We have a new cluster",
  subtitle: [You might have _heard_],
)[

#two-columns()[
  == What we cover today:
  
  - What is this cluster thing
  - How does it work (using R / Python, Slurm)
  - How do *you* do stuff on it in general

][
  #pause
  == We *don't* cover
  
  - How to Linux (from the command line)
  - How to use `batchtools` (or `targets`)
  - Everything you ever need to know
]
  #pause
  #vfill
  #callout(type: "note", icon: emoji.face.cry)[
    I know it's noisy and no I don't know when that is fixed
  ]

]

#bips-slide(
  title: "What is a cluster?",
  subtitle: "And why should you care",
)[
  #set list(spacing: 0.3em)
  
  Many ways to shave a yak, and now you have one more!
  #v(1em)
  
  #three-columns(
    columns: (0.8fr, 1fr, 1fr),
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
    - Bertha / new GePaRD server
    - Run looong tasks
    - 1 powerful computer
    - Shared
    - Convenience: Mixed
  ][
    #pause
    == HPC Cluster
    - Many computers connected
    - Access via _head node_
    - Shared (scheduling: _Slurm_) #pause
    - Convenience: You'll get there
  ]
]


#bips-slide(
  title: "What does it look like?",
  subtitle: "Kind of like this",
  content-align: horizon + center,
)[
  #pause
  #image("img/stock-rack.jpg", height: 70%)
]

#bips-slide(
  title: "The HPC workflow",
  subtitle: "It's a freight truck, not a bicycle",
)[
  
  You don't hop on the cluster for a quick ride, you *submit work* to it #pause
  
  #two-columns(gutter: 2em)[
    == What you are used to
    - Open RStudio / VSCode / Positron
    - Write code, run it, see results
    - Everything is _interactive_
    - One computer does it all
  ][
    #pause
    == How HPC works
    - Prepare your code on the _head node_
    - *Submit* it as a job (it gets _queued_)
    - Go make coffee #emoji.coffee
    - Come back, check results
    - Debug if needed, resubmit
  ]
  
  #pause
  #vfill
  #callout(type: "tip")[
    There's a learning curve, but the payoff is huge
  ]
]

#bips-slide(
  title: "HPC Workflow",
  subtitle: "The typical cycle",
)[
  
  1. Log in (land on *head node*) #pause
  2. Load software (`module load R/4.5.3`) #pause
  3. Move to your project (`git` helps) #pause
  4. Submit your *job*(s) via `sbatch` #small[(or `salloc` for interactive work)] #pause
  5. Monitor with `squeue --me` #pause
  6. Log out, check back later #pause
  7. If jobs failed, debug & resubmit #pause
  8. Repeat until #strike("insane") done

]

#bips-slide(
  title: "Cluster topology",
  subtitle: "Partitions",
  content-align: horizon + center,
)[
  #let node-cell(n) = rect(
    fill: rgb("#e6f5e6"),
    radius: 2pt,
    inset: 4pt,
    stroke: 0.5pt,
    align(center)[#emoji.computer #n],
  )
  #let compute-content = [*compute*: #h(1fr) 12 nodes
    #grid(
      columns: 6,
      gutter: 4pt,
      ..range(1, 13).map(n => node-cell(if n < 10 { "0" + str(n) } else { str(n) })),
    )]
  #let gpu-content = [*gpu*: 1 node
    #grid(
      columns: 1,
      gutter: 4pt,
      rect(
        fill: rgb("#ffe6b3"),
        radius: 2pt,
        inset: 4pt,
        stroke: 0.5pt,
        align(center)[#emoji.computer gpu01],
      ),
    )]
  #diagram(
    node-stroke: 1pt,
    spacing: (5em, 1em),
    node((0, 0), align(center)[#emoji.computer Head Node], corner-radius: 2pt, name: <head>),
    edge(<head>, <compute>, "-|>"),
    node((1, -1), compute-content, corner-radius: 4pt, fill: rgb("#ccf2cc"), inset: 8pt, name: <compute>),
    edge(<head>, <gpu>, "-|>"),
    node((1, 1), gpu-content, corner-radius: 4pt, fill: rgb("#fff2cc"), inset: 8pt, shape: rect, name: <gpu>),
  )
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
    node((0, 0), [#emoji.laptop I need to\ compute stuff], corner-radius: 2pt, extrude: (0, 3), name: <you>),
    edge(<you>, <head>, "-|>", [SSH]),
    // Head node
    node((1, 0), align(center)[#emoji.computer Head Node], corner-radius: 2pt, name: <head>),
    edge(<head>, <slurm>, "-|>", [sbatch\ salloc]),
    // Slurm scheduler
    node((2, 0), align(center)[#emoji.gear Slurm\ Scheduler], corner-radius: 2pt, fill: rgb("#cce0ff"), name: <slurm>),
    // Branching to compute nodes
    edge(
      <slurm>,
      <node01>,
      "-|>",
      [jobs],
      label-angle: 20deg,
      label-pos: 60%,
      label-anchor: "base",
    ),
    edge(<slurm>, <node02>, "-|>", [jobs], label-angle: 1deg, label-pos: 60%, label-anchor: "base"),
    edge(<slurm>, <node03>, "-|>", [jobs], label-angle: -20deg, label-pos: 60%, label-anchor: "base"),
    // Compute nodes
    node((3, -1), align(center)[#emoji.computer Node 01], corner-radius: 2pt, fill: rgb("#ccf2cc"), name: <node01>),
    node((3, 0), align(center)[#emoji.computer Node 02], corner-radius: 2pt, fill: rgb("#ccf2cc"), name: <node02>),
    node((3, 1), align(center)[#emoji.computer Node 03], corner-radius: 2pt, fill: rgb("#ccf2cc"), name: <node03>),
  )
]

#bips-slide(
  title: "The head node",
  subtitle: "Your gateway",
)[
  
  The head node is where you land when you log in #pause
  
  #two-columns(gutter: 2em)[
    == Do #emoji.checkmark
    - Install R / Python packages
    - Edit scripts and code
    - Submit and monitor jobs
    - Use `git`
  ][
    #pause
    == Don't #emoji.crossmark
    - Run heavy computations
    - Launch long-running scripts
    - Load huge datasets into memory
  ]
  
  #pause
  #vfill
  #callout(type: "warning")[
    The head node is shared by _everyone_. Heavy processes will be _terminated_.
  ]
]

#bips-slide(
  title: "Terminology",
  subtitle: "Just to make sure you're confused",
  text-size: 17pt,
)[
  
  #two-columns(columns: (2fr, 1fr))[
    #compact(spacing: 1em)[
      - The cluster has 12 compute *nodes* #tiny[(self-contained computer)] #pause
        - Each node has 1 *CPU* #tiny[(physical processor)] #pause
        - Each processor is made up of 96 *cores* #tiny[(independent units)] #pause
        - Each core can juggle 2 *threads* #tiny[(e.g. R processes)] #pause
      - Terminology here weird / confusing because: _history_ #emoji.person.shrug
        - Until the 90s: *1* CPU = *1* core = *1* thread #pause
        - Then: "Hyperthreading": *1* CPU = *1* core = *2* threads #pause
        - Then: "Dual core": *1* CPU = *2* cores = *4* threads #pause
        - *Now*: *1* CPU = *96* cores = *192* threads #pause
    ]
    #vfill
    #callout(type: "warning")[
      *Slurm*: You need 10 *threads* #sym.arrow you request 10 *"cpus"*
    ]
  ][
    #meanwhile
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
          columns: 3,
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
              columns: 3,
              gutter: 4pt,
              core-box(1), core-box(2), core-box(3),
              core-box("..."), core-box(95), core-box(96),
            )],
        )],
    )
  ]
  

]

#bips-slide(
  title: "But what is Slurm even",
)[
  - Slurm is the job management system #small[(see #link("https://slurm.schedmd.com/documentation.html")[slurm.schedmd.com])]
  - Every CPU _core_, every Byte of _RAM_ on the compute nodes is _kept track of_
  
  // #v(1em)
  #pause 
  #large[#blue[#sym.arrow You can only use resources allocated to you]]
  // #v(1em)
  
  #pause 
  
  ==== Things that _do not_ happen on a cluster:
  
  - "My job took too much RAM so your jobs got killed alongside mine sorry"
  #pause
  - "I used 1000 threads but only meant to use 10 sorry your jobs are smothered"
  #pause
  #sym.arrow It's impossible to "endanger" other people's compute jobs
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
      #image("img/terminal.jpeg", height: 30%)
    ]
  ][
    #pause
    == Positron (VScode)

    - Uses SSH for communication with head node
    - GUI on your own device (PC, laptop)
    - Terminal / R console runs *on head node*
    - All files you see are on the head node
    - #emoji.face.cool Edit files conveniently
  ]
]

#bips-slide(
  title: "The first thing you see when you log in",
  subtitle: "Trying to point you in the right direction",
  content-align: center + horizon,
)[
  #image("img/motd.png", height: 74%)
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
  - Run `module load R/4.5.3` #sym.arrow R v4.5.3 is available
  - Load modules *before* running `salloc` or `sbatch` --- they inherit your environment #pause
  - (Python: Use `uv`, no need for modules: #small[(#link("https://docs.astral.sh/uv/")[docs.astral.sh/uv])])
]

#bips-slide(
  title: "How are resources allocated?",
  subtitle: "Slurm manages resources on the cluster",
)[

  - Example: You need  *20 threads* for *6 hours* and *4GB of RAM* for `analysis.R` #pause
  #vfill
  #two-columns()[
    == Interactive: `salloc`

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
    == Batch job: `sbatch`
    - Write an `analysis.sh` wrapper script

    ```
    #!/bin/bash
    #SBATCH --job-name=my-analysis
    #SBATCH --output=logs/%x_%j.out
    #SBATCH --cpus-per-task=20
    #SBATCH --mem=4G
    #SBATCH --time=06:00:00

    Rscript analysis.R
    ```

    - Run `sbatch analysis.sh` and go home

  ]
]

#bips-slide(
  title: "Slurm resource allocation",
  subtitle: "Partitions and QoS",
)[
  - Slurm groups hardware in _partitions_
  - 2 partitions: #blue[`compute`] (12 nodes, _default_) and #blue[`gpu`] (1 node)
  - Prioritization is done in _Quality of Service_ (QoS) queues: #pause
  - Different queues have different constraints (time, how many jobs per user)
    - *interactive*: 3 days, 2 per user #small[(auto-applies to `salloc`)] #pause
  - For `sbatch` or `#SBATCH --qos=<name>`:
    
    #three-columns()[
      *short*: 1 hour
    ][
      *medium* #tiny[(default)]: 1 day
    ][
      *long*: 7 days
    ]
]

#bips-slide(
  title: "Slurm resource allocation",
  subtitle: "A job is not a job",
)[
  - Slurm is very generic and supports diverse types of jobs
  - Slurm also has concept of "tasks": #pause For us *1 task == 1 job*  #pause
  - Easiest use: 1 job = 1 R/py process = Some number of threads on 1 node #pause
  - Technically possible to have 1 job spanning multiple nodes #sym.arrow headache country  #pause
  - Slurm allocates *cores*, not *threads* #pause
  - But: You only care about threads #pause
  - You need 1 thread, you ask for `cpus-per-task=`*`1`*, you get *1* core reserved #pause
  - #sym.arrow More efficient to just ask for 2 "cpus" and 1 full core
]

#bips-slide(
  title: "Example: Efficiently using a node",
  subtitle: "If your goal is to fully utilize 1 node (96 cores, 192 threads)",
)[
  
  #two-columns(columns: (1fr, 1.7fr))[
    == What works
    - 1 job with 192 threads #emoji.checkmark.box #pause
    - 96 jobs with 2 threads #emoji.checkmark.box #pause
    - 8 jobs with 24 threads #emoji.checkmark.box #pause
  ][
    == What does *not* work
    - 192 jobs with 1 thread #emoji.crossmark #pause
    - Each job reserves 1 *core*
    - #sym.arrow 192 jobs allocate 192 cores, but a node only has 96!
  
  ]
  #vfill
  #pause
  #callout(type: "warning")[
    If you're used to `batchtools`, you probably default to single-threaded jobs
  ]
]

#bips-slide(
  title: "Did it work?",
  subtitle: "Checking on your jobs",
  text-size: 17pt,
)[
  
  #two-columns(gutter: 2em)[
    While running:
    - `squeue --me`: list your jobs
    - `tail -f logs/job_12345.out`: watch output
    - `scancel <jobid>`: cancel a job
  ][
    After completion:
    - Check your output files (e.g. `logs/`)
    - `sacct --starttime=today`: job history
    - `sacct -j <jobid> --format=JobID,State,Elapsed,MaxRSS`
  ]
  
  #pause
  // #v(1em)
  Common failure modes
  - *TIMEOUT*: job ran out of time, request more with `--time`
  - *OUT_OF_MEMORY*: request more RAM with `--mem`
  - *FAILED*: your script has a bug, check the log output #small[(_did you load modules?_)]
]

#bips-slide(
  title: "Where does your stuff live?",
  subtitle: "Two storage tiers",
)[
  
  #two-columns(gutter: 2em)[
    == Home directory
    `/srv/home/<user>`
    - Fast
    - Limited space, also shared with software
    - Scripts, code, _active_ projects
  ][
    #pause
    == Archive storage
    `/mnt/sas/users/<user>`
    - Large capacity
    - Slower
    - Big datasets, _inactive_ projects
  ]
  
  #pause
  #vfill
  - Both are *shared across all nodes* (head + compute) via internal network
  - Compute nodes also have fast *local scratch* (`$TMPDIR`, auto-cleaned after job)
  #pause
  #callout(type: "warning")[
    There are *no backups*. Use `git` for code, be careful with data.
  ]
]

#bips-slide(
  title: "User utilities",
  subtitle: "Command-line aliases/functions",
)[
  
  - I have prepared a few shorthand tools based on things I need often
  - On head node, get info with `slurm_user_help`:
  
  
  ```sh
  ❯ slurm_user_help
  === Slurm User Helper Functions ===
  
  JOB MONITORING:
    sq              - Enhanced squeue with better formatting
    sqm             - My jobs queue
    sqs             - Job status summary with colors
  [...]
  
  JOB ACCOUNTING:
    slac              - Enhanced sacct
    slac1h/1d/3d/1w   - Jobs from last hour/day/3days/week (excludes PENDING)
      State filters:  -a (all), -p (pending), -c (completed), -f (failed), -r (running)
    sltoday           - Jobs submitted today
  
  ```

]


#bips-slide(
  title: "Getting started",
  subtitle: "And further reading material",
  text-size: 21pt,
)[

1. Ask me for an account, I will send you login credentials
2. Read (and bookmark) the docs:
  - #link("https://cluster.bips.coffee")[cluster.bips.coffee] (public)
3. Bookmark the dashboard (current cluster usage):
  - #link("http://srvcluster.bips.de/")[http://srvcluster.bips.de/] (no https!)
4. Try demos / usage examples for `batchtools`, `mirai`, `targets`:
  - #link("https://srvgit.bips.eu/bips/bips-cluster-demos")[srvgit.bips.eu/bips/bips-cluster-demos]
]

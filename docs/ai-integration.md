---
layout: single
title: "Why AI Isn't Helping Your Research as Much as It Should"
permalink: /ai-integration/
author_profile: true
---


<!-- Source for docs/ai-integration.md ("My AI Integration").
     Adapted from a LinkedIn article. Build with data-raw/scripts/render.R. -->

*Adapted from my [LinkedIn
article](https://www.linkedin.com/in/francis-tsiboe-02b97248/), May 21,
2026.*

If you have used AI on your research and walked away thinking *that was
useful, but not life-changing*, you are not alone.

Most economists I talk to describe a similar experience. They paste a
script into a chat window. They ask for help cleaning data, debugging a
regression, or drafting a function. They get back something reasonable,
but generic. They tweak it, paste it back, repeat. It saves time. It
does not feel transformative. Then they read about AI agents writing
entire codebases overnight and wonder what they are missing. Here is
what I think is missing: structure.

The more I work with AI in applied research, the more convinced I am
that AI’s usefulness depends almost entirely on what you give it to work
with. A chat window with a few pasted snippets is a very different
environment from a well-organized repository with reusable functions,
clean data pipelines, and version-controlled history.

If you are an economist not already practicing functional coding, you
may be underusing AI without realizing it. Functional coding is no
longer just good programming practice. It is becoming the harness that
makes AI genuinely useful for research.

## Before AI, functional coding was just good discipline

Long before AI became part of my daily work, I had already developed the
habit of writing functions I could reuse across projects. At the time, I
thought I was simply being organized:

- If I had to clean similar datasets more than once, I wrote a function.
- If I had to produce the same type of summary table for different
  commodities, years, or regions, I wrote a function.
- If I had to generate the same figures repeatedly, I turned the process
  into a reusable workflow.

It was rarely glamorous. Most of those functions appeared only after I
had made the same mistake two or three times and finally admitted that
copy-and-paste was not a long-term research strategy. But over time,
they paid off. They helped me move faster, reduce errors, and make my
work more reproducible. What I did not realize at the time is that I was
also building something AI would later need: a research workflow that
something else, a collaborator, a future version of me, or eventually an
AI agent, could understand. That is the part most economists never get
to, and it is why AI feels underwhelming when it shows up.

## GitHub repositories as research infrastructure

Over the past few years, I have increasingly organized my research
around GitHub repositories. Each repository is not just a place to store
code. It is a structured workspace built around a specific research
purpose. A few examples from my current public-facing work illustrate
the idea.

- [USFarmSafetyNetLab](https://github.com/ftsiboe/USFarmSafetyNetLab):
  my broader research infrastructure for U.S. agricultural safety net
  programs. It centralizes outputs, analytical tools, and resources
  related to the Federal Crop Insurance Program, Price Loss Coverage,
  Agriculture Risk Coverage, and disaster assistance programs, and is
  designed for researchers, policy analysts, graduate students,
  policymakers, extension professionals, and agricultural stakeholders.
- [fcipDemand](https://github.com/ftsiboe/fcipDemand): focused more
  narrowly on estimating demand for the Federal Crop Insurance Program,
  building on past work with Dylan Turner ([Tsiboe and Turner,
  2023a](https://doi.org/10.1016/j.foodpol.2023.102505); [Tsiboe and
  Turner, 2023b](https://doi.org/10.1017/age.2023.13)). I think of it as
  the specialized toolkit for studying how producers respond to crop
  insurance options, subsidies, price changes, and related program
  features.
- [okwaayeli](https://github.com/ftsiboe/okwaayeli): supports my work on
  agricultural productivity in Ghana. Its core question is whether
  observed production shortfalls are driven by farmer technical
  inefficiency, technology gaps, or both. A very different research
  setting from U.S. crop insurance, but the coding lesson is identical:
  once the workflow is structured, the research becomes easier to
  extend, document, and audit.
- [makola](https://github.com/ftsiboe/makola): another Ghana-focused
  project, providing tools for market integration analysis, including
  price transmission, market comovement, cointegration, threshold
  adjustment, and nonlinear time-series dynamics in paired market data.
  It turns repeated market-integration tasks into reusable analytical
  workflows.

I also want to highlight Dylan Turner’s work, because it shows how
well-built research tools can make scattered public data genuinely
usable. [rfcip](https://github.com/dylan-turner25/rfcip) provides access
to publicly available Federal Crop Insurance Program data, including
Summary of Business and Actuarial Data Master datasets. It is
essentially a structured wrapper around data that are public but spread
across URLs, files, portals, and formats.
[rfsa](https://github.com/dylan-turner25/rfsa) does something similar
for USDA Farm Service Agency data, with cleaned and aggregated datasets
for ARC, PLC, individual payment files, and crop acreage data.

Together, these repositories make a larger point: good research code is
not about getting one paper done. It is about building infrastructure
that can support repeated analysis, new questions, collaboration, and
now, AI-assisted improvement. This is also where the gap shows up. If
your research lives in a folder of loose scripts with hard-coded paths
and no documentation, AI has nothing to work with except whatever you
can fit in a single message. That is why it has been underperforming for
you.

## What changes when AI has a real project to work in

Over the last couple of weeks, I ran an experiment. I cloned one of my
repositories locally and turned an AI agent loose on it. The local clone
was connected to large public datasets stored inside the project
directory. Some of those datasets were intentionally not pushed to
GitHub. Large raw data often belongs locally, especially when it is too
large, too messy, or simply not appropriate to version inside a public
repository. (Also, nothing says *bad Monday* like accidentally pushing
half the USDA data universe to a public repo.)

The results were phenomenal. The agent could inspect the repository
structure, read functions, trace how scripts connected, and suggest
concrete improvements to documentation and reproducibility. It worked
confidently within the boundaries the repository defined. This was a
completely different experience from pasting snippets into a chat
window. The agent was not guessing at context. It had the context. It
could see the whole project.

And here is the key point: the AI was not useful because it was *smart*.
It was useful because the project already had structure. The functions,
folder conventions, scripts, data locations, documentation, and stated
research purpose gave the AI something meaningful to build on. That is
the difference between AI as a clever autocomplete and AI as a research
collaborator.

## The real answer: AI needs a harness

AI is not underperforming because the models are bad. They are
remarkable. AI is underperforming in research because most research
workflows do not give it anything solid to grip. GitHub repositories and
local project clones are becoming the harness through which I use AI:

- The repository defines the research problem.
- The functions define the logic.
- The folder structure defines the workflow.
- The local datasets provide the empirical fuel.
- The AI helps improve, test, document, and extend the work.

Without that structure, AI can still be helpful, but it is much more
likely to produce isolated suggestions, disconnected code, or answers
that require significant cleanup, the exact experience most economists
describe when they say AI is *fine, but not transformative*. With that
structure, AI behaves like a research assistant working inside a
well-organized lab. A reusable function is no longer just a convenience,
and a well-organized repository is no longer just good housekeeping.
Together, they become infrastructure for AI-augmented research.

## Version control is the other half of the harness

Structure tells AI what to work on. Version control tells you what AI
did. When working with AI, GitHub is not just a convenience. It is a
safeguard. AI can suggest improvements quickly, but not every suggestion
belongs in the main workflow. Some changes are useful, some are
incomplete, and some look elegant but quietly break something important.
(Sometimes AI writes code with the confidence of a senior developer and
the judgment of a caffeinated intern.)

That is where GitHub earns its keep. With version control, I can see
exactly what the AI changed, review edits line by line, compare modified
files against the originals, and decide whether the changes actually
improve the workflow. More importantly, I can isolate AI work on
experimental branches. Instead of letting AI modify the main workflow
directly, I ask it to work on a separate branch. That branch becomes a
testing space where documentation can be improved, functions refactored,
tests added, and data-processing scripts cleaned up, all without risking
the stable version of the project. Only after I have reviewed, tested,
and understood the changes do they get committed and merged into the
official workflow.

That process matters for research. In applied economics, our workflows
produce estimates, tables, figures, and policy-relevant conclusions, and
we need to know where those outputs came from and how they changed over
time. GitHub gives us that audit trail. It lets me ask what the AI
changed, why the change was made, whether the results changed, whether
the code became more reproducible, and whether I can roll back if
something went wrong. That auditability is why I treat GitHub as part of
the AI research infrastructure, not just a backup system. AI can
accelerate the work; version control keeps the researcher in charge.

## Why this hits economists especially hard

Economists work with repeated analyses, large public datasets,
simulations, administrative records, policy scenarios, and long-running
research projects. These are exactly the workflows where the absence of
structure costs the most, and where AI has the most to offer if
structure is in place. If you repeatedly download data, clean variables,
merge files, estimate models, produce tables, or generate figures, your
workflow is already asking to be functionalized. You have just been
paying the cost of not doing it as a copy-paste tax for years. AI did
not create that problem; it is just making the cost visible. Once the
harness is in place, the picture flips:

- When your workflow is built around reusable functions, AI can help
  improve those functions.
- When your project is organized as a repository, AI can understand the
  broader structure.
- When your analysis is reproducible, AI can help diagnose problems
  without forcing you to rebuild everything from scratch.
- When your work is version controlled, AI-assisted changes can be
  audited before they become part of the official record.

The result is not just faster coding. It is better research
infrastructure.

## AI should improve the workflow, not become it

The answer to the title’s question is not *use more AI*. My goal is not
to hand the work over to AI. The goal is to build workflows that AI can
improve, but that I can still run, understand, audit, and reproduce
without AI. I do not want a research pipeline that only works because an
AI model happens to be available. I want a pipeline that is sound on its
own, and becomes easier to maintain and improve with AI assistance.

Because if AI becomes prohibitively expensive in the future, I do not
want my research pipeline to greet me with *please upgrade your plan to
reproduce Table 3*. That is meant to be funny, but the point is serious.
Reproducibility should not depend on access to a specific AI provider.
Research workflows should be portable, auditable, and durable.

## The path forward

If AI has not been pulling its weight in your research, the answer
probably is not a better model. It is a better harness. For me, that
means:

1.  Build better functions.
2.  Organize research into reproducible repositories.
3.  Use GitHub version control to audit AI-assisted changes.
4.  Run AI-generated modifications on experimental branches before
    committing them.
5.  Keep large datasets safely local when needed.
6.  Document workflows clearly.
7.  Use AI as an accelerator, not as the foundation.

This approach lets me benefit from AI while staying independent of any
single platform or provider, and it helps ensure my research workflows
remain usable even as the AI landscape shifts. AI is powerful, but
structure is what makes it useful. For economists, that structure
increasingly comes from functional coding, reproducible research
repositories, and disciplined version control. In the AI era, good code
organization is not just a technical habit. It is the harness that
finally lets AI do real research work.

# `scribe`

**`scribe`** is a minimalist, opinionated $\LaTeX$ document class for academic and technical writing. It is designed to provide clean defaults, professional typography, and convenient commands for research papers, systematic literature reviews, and technical reports. It is partially inspired by the `acmart` class.

<!-- [![One-column preview](docs/onecolumn.png)](example/onecolumn.pdf) -->
<!-- [![Two-column preview](docs/twocolumns.png)](example/twocolumns.pdf) -->
<!-- [![Two-column preview with abstract](docs/twocolumnabstract.png)](example/twocolumnabstract.pdf) -->

<p align="center">
  <a href="example/onecolumn.pdf">
    <img src="docs/onecolumn.png" alt="One-column preview" width="250"/>
  </a>
  &nbsp;&nbsp;&nbsp;
  <a href="example/twocolumn.pdf">
    <img src="docs/twocolumn.png" alt="Two-column preview" width="250"/>
  </a>
  &nbsp;&nbsp;&nbsp;
  <a href="example/twocolumnabstract.pdf">
    <img src="docs/twocolumnabstract.png" alt="Two-column preview with abstract" width="250"/>
  </a>
</p>


---

## Features

- **Minimalist Design**: Focuses on content with a clean, professional layout.
- **Full support** for all standard `article` class options.
- **Index Terms**: Use `\begin{indexterms}` to define keywords for indexing.
- **Line Numbers**: Optional line numbering for easy reference and review.
- **Citation style**:
    - Compact numeric citations (e.g., [1–3,5])
    - Sorted in order of **first appearance**, not numerically
- **Named inline comments (toggleable)**: 
    - Define with `\scribedefinecomment{name}{color}`
    - Use with `\namecomment{...}`
    - Disable globally with `\scribeshowcommentsfalse`
- **Custom header mark**: `\scribesetrightmark{...}` sets right-side header text
- **Typography**:
    - Serif: **Libertine**
    - Monospace: **Bera Mono**

---

## Usage

An example of a paper using the `scribe` class is provided in the `example` folder. 
Below is a minimal setup to have a one-column abstract in a two-column layout, with line numbers.

### 1. Add `scribe.cls` to your project folder.

### 2. In your main `.tex` file:

```latex
\documentclass[
    lineno, % Enable line numbers.
    letterpaper, % Use 'a4paper' for A4 size.
    twocolumn, % Uncomment for two-column layout.
]{scribe} 

% Set right header mark (e.g., your name)
\scribesetrightmark{Federico Bruzzone} 

% Define different aliases (along with colors) for comments
\scribedefinecomment{fb}{orange}
% \scribedefinecomment{yourcolleague}{red}

% Uncomment the following line to hide comments in the final document.
% \scribeshowcommentsfalse 

\title{\textbf{An example paper using the scribe document class}}

\author{
    Federico Bruzzone \orcidlink{0000-0002-8701-8853} \\
    Computer Science Department \\
    Università degli Studi di Milano \\
    \href{mailto:federico.bruzzone@unimi.it}{\texttt{federico.bruzzone@unimi.it}} \\
    \url{https://federicobruzzone.github.io/} 
}

\date{September 2025}

\begin{document}

\twocolumn[
	\maketitle

	\begin{abstract}
        % Abstract text goes here. This is a brief summary of the document's content, highlighting the main objectives, methods, and findings.
	\end{abstract}

	\begin{indexterms}
        % Index terms for indexing purposes. These are keywords that help categorize the document's content.
	\end{indexterms}
]


% ==============================
% ========== Sections ==========
% ==============================
\input{sects/introduction}
\input{sects/background}


\bibliography{local}

\end{document}
```

--- 

This repository follows the [standard-commit](https://github.com/standard-commits/standard-commits) message format. 

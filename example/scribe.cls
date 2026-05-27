%%----------------------------------------------------------------------
%% scribe.cls
%% author: Federico Bruzzone (30-06-2025) last update: (30-06-2025)
%%----------------------------------------------------------------------

\def\filename{scribe}
\def\fileversion{v0.1.0 (author: Federico Bruzzone)}
\def\filedate{2025/06/30}

\NeedsTeXFormat{LaTeX2e}
\ProvidesPackage{\filename}[\filedate{} \fileversion]
\typeout{Class file \filename', \fileversion, <\filedate>}

% =====================================
% ========== Class options ============
% =====================================
\newif\if@scribelineno
\@scribelinenofalse

\DeclareOption{lineno}{\@scribelinenotrue}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

% =====================================
% ========== Load base class ==========
% =====================================
\LoadClass[
	11pt,
]{article}

% ==================================================
% ========== Custom packages and settings ==========
% ==================================================
\RequirePackage[top=2.5cm,bottom=2.5cm,left=2.5cm,right=2.5cm]{geometry} % Geometry is used to set the margins
\RequirePackage[numbers,sort&compress]{natbib} % Natbib for bibliography management
\setlength{\bibsep}{2pt} % Adjust space between bibliography entries
\RequirePackage[greek,english]{babel} % Language support. Greek is usually used for math and technical documents.

% ===========================
% ========== Fonts ==========
% ===========================
\RequirePackage[T1]{fontenc} % Font encoding. That is, how the text is encoded in the font.
\RequirePackage[utf8]{inputenc} % Input encoding. That is, how the text is encoded in the file.
\RequirePackage{libertine} % Libertine font for text
\RequirePackage[scaled=0.85]{beramono} % Bera Mono for monospace text

% ==================================
% ========== Line numbers ==========
% ==================================
\if@scribelineno % Conditional for line numbers
	\if@twocolumn
		\RequirePackage[switch]{lineno} % Symmetric line numbers for two columns
	\else
		\RequirePackage[left]{lineno}   % Line numbers on the left in one column
	\fi
	\renewcommand\linenumberfont{\normalfont\footnotesize\color{red}} % Style for line numbers
\fi

% ================================================
% ========== Listings, math, and layout ==========
% ================================================
\RequirePackage{listings} % Listings package for code formatting
\RequirePackage{amsmath,amssymb,amsthm,mathtools} % AMS packages for math
\RequirePackage[inline]{enumitem} % For customizing lists
\setlist[itemize]{noitemsep, topsep=0pt} % Remove space around itemize lists
\setlist[enumerate]{noitemsep, topsep=0pt, label=\arabic*.} % Remove space around enumerate lists and set label style to arabic numbers
\setlist*[enumerate]{label=(\roman*)}


% ============================
% ========== Tables ==========
% ============================
\usepackage{booktabs} % Booktabs package for better tables
\usepackage{array} % Array package for advanced table formatting

% ==============================
% ========== Graphics ==========
% ==============================
\RequirePackage[dvipsnames]{xcolor} % Color package for text and comments

\RequirePackage{graphicx} % Graphics package for including images
\RequirePackage{float} % Float package for controlling figure placement
\RequirePackage{caption} % Caption package for customizing captions
\RequirePackage{subcaption} % Subcaption package for subfigures
\RequirePackage{pmboxdraw} % This enables graphical glyps, e.g., ├── └──
\RequirePackage{multicol} % Multicol package for multiple columns in figures
% Caption style
\captionsetup{
	font=sf, % 'sf' for sans-serif, 'rm' for serif
	labelfont=bf, % make 'Figure 1:' bold
	% textfont=it, % make caption text italic
	labelsep=colon, % adds a colon after Figure X
	justification=centering % center caption text
}

\RequirePackage[
	colorlinks=true,
	linkcolor=MidnightBlue,
	citecolor=MidnightBlue,
	urlcolor=MidnightBlue
]{hyperref} % Hyperref package for clickable links in the document and lots of other features

% Colored dingbats
\RequirePackage{pifont}
\newcommand{\dingred}[1]{{\color{Red}\ding{#1}}}
\newcommand{\dinggreen}[1]{{\color{Green}\ding{#1}}}
\newcommand{\dingblue}[1]{{\color{Blue}\ding{#1}}}

% ===========================
% ========== ORCID ==========
% ===========================
\RequirePackage{orcidlink}

% =====================================
% ========== Headers/footers ==========
% =====================================
\RequirePackage{fancyhdr} % Fancyhdr package for custom headers and footers
\pagestyle{fancy} % Set the page style to fancy
\fancyhf{} % Clear all header and footer fields
\fancyhead[L]{\leftmark} % Set left header to the left mark (section or chapter title)
\fancyhead[R]{\scriberightmark} % Set right header to the right mark (subsection or subsection title)
\fancyfoot[C]{\thepage} % Set page number in the footer (centered)
\renewcommand{\headrulewidth}{0pt} % No line in header

% ==============================
% ========== Commands ==========
% ==============================
% Optional: toggle comments on/off
\newif\ifscribeshowcomments
\scribeshowcommentstrue % or \scribeshowcommentsfalse to hide all comments

% Core macro to define new named comment commands
\newcommand{\scribedefinecomment}[2]{%
	\expandafter\newcommand\csname #1comment\endcsname[1]{%
		\ifscribeshowcomments%
			\textcolor{#2}{[\textbf{#1}] \textit{##1}}%
		\fi%
	}%
}

% Define a command to set the right mark in the header
\newcommand{\scriberightmark}{}
\newcommand{\scribesetrightmark}[1]{%
	\renewcommand{\scriberightmark}{#1}%
}

% Define a command to set the divider line with a dingbat in the middle
% Something like this:
% ---------- ✧ ----------
\newcommand{\scribedivider}{%
	\par\medskip
	\noindent
	\makebox[\linewidth]{%
		\hspace{2em}%
		\makebox[0pt][l]{\rule[0.75ex]{\dimexpr0.5\linewidth - 3em}{0.5pt}}%
		\hfill\ding{71}\hfill
		\makebox[0pt][r]{\rule[0.75ex]{\dimexpr0.5\linewidth - 3em}{0.5pt}}%
		\hspace{2em}%
	}%
	\par\medskip
}


% ==============================================
% ========== Abstract and Index Terms ==========
% ==============================================
\renewenvironment{abstract}{
	\begin{center}
		\begin{minipage}{0.93\linewidth}
			\noindent\textbf{Abstract}---%\hspace{0.5em}
			\itshape
			}{%
		\end{minipage}
	\end{center}
}

\newenvironment{indexterms}{
	\begin{center}
		\begin{minipage}{0.93\linewidth}
			\noindent\textbf{Index Terms}---%\hspace{0.5em}
			\itshape
			}{%
		\end{minipage}
	\end{center}
}

\AtEndEnvironment{indexterms}{%
	\scribedivider
}

% =====================================
% ========== AtBeginDocument ==========
% =====================================
% Set up the document to use BibTeX
\AtBeginDocument{%
	\providecommand\BibTeX{{%
				Bib\TeX}}}

% Set the bibliography style to unsrt (unsorted). That is, the order of the references will be the order in which they are cited in the document.
% Alternatively, we can use:
% 1. `plainnat` to use the plain style, which sorts the references alphabetically by author.
% 2. `alpha` to use the alpha style, which uses the first letter of the author's name and the year of publication.
% More info: https://www.overleaf.com/learn/latex/Bibtex_bibliography_styles
\AtBeginDocument{%
	\bibliographystyle{unsrt}%
}

% Enable line numbers if the option is set
\AtBeginDocument{%
	\if@scribelineno
		\linenumbers
	\fi
}

% =============================
% ========== Aliases ==========
% =============================
\newcommand{\tool}[1]{\textsc{#1}} % Command for tool names

% =============================
% ========== Patches ==========
% =============================

\RequirePackage{etoolbox} % For patching commands


% Patch \maketitle to remove vertical space before the title (latexdef \@maketitle)
\patchcmd{\@maketitle}
{\begin{center}}               % Look for this token in \maketitle
{\vspace{-1.5cm}\begin{center}} % Insert negative vspace before the center environment
{}{} % success and failure code, do nothing

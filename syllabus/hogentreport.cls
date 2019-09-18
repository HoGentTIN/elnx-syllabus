%% University College Ghent (HoGent) thesis class
%%
%% hogentreport  .cls
%%
%% Based on the TU Delft LaTeX template for reports and theses.
%% (https://www.tudelft.nl/en/tu-delft-corporate-design/downloads/)
%%
%% Inspired by the LaTeX template for the Bachelor of Applied
%% Computer Science of the Faculty of Business and Information Management
%% at the University College Ghent, authored by Bert Van Vreckem.
%% (https://github.com/HoGentTIN/bachproef-latex-sjabloon)
%%
%% Best suited for compiling using XeLaTeX or LuaTeX,
%% but there is support for native fonts, automatically when using
%% LaTeX/PDFLaTeX, or forced by specifying the 'nativefonts' option.
%%
%% Author: Pieter van der Kloet (pvdkloet at gmail.com)
%%
%% License: MIT license
%% (See LICENSE for more information)
%%

\NeedsTeXFormat{LaTeX2e}
\def\@classname{hogentreport}
\ProvidesClass{hogentreport}[2019/05/19 v1.0 Hogeschool Gent report class]

\RequirePackage{xkeyval}
\RequirePackage{iflang}

\RequirePackage[hyphens]{url}
\RequirePackage{amsmath}
\RequirePackage{amssymb}

%% Ensure the variables can be checked with \ifx\@variable\@empty
\let\@author\@empty
\let\@title\@empty
\let\@supervisor\@empty
\let\@cosupervisor\@empty
\let\@institution\@empty
\let\@academicyear\@empty
\let\@examperiod\@empty
\let\@degreesought\@empty

\let\@faculty\@empty
\let\@faculty@nr\@empty

\newcommand{\academicyear}[1]{\def\@academicyear{#1}}
\newcommand{\degreesought}[1]{\def\@degreesought{#1}}

\define@choicekey*+{hogentreport}{faculty}[\@faculty\@faculty@nr]
{fbo,fmw,fnt,soa}{}{%
    \ClassError{\@classname}{The faculty parameter is undefined}
    {One of the following options for the faculty must be added to the class%
        options: fbo, fmw, fnt or soa}}

\def\@DeclareFaculty#1{\DeclareOptionX{#1}{\setkeys{hogentreport}{faculty=#1}}}
\@DeclareFaculty{fbo}
\@DeclareFaculty{fmw}
\@DeclareFaculty{fnt}
\@DeclareFaculty{soa}

%% Redefine the title command to accept an optional subtitle
\renewcommand*\title[2][]{%
    \def\@title{#2}%
    \def\@subtitle{#1}%
}

%% Check the variables that need to be defined for the title page
\newcommand{\@checkvariables}{%

    \ifx\@title\@empty{%
        \ClassError{\@classname}{Author is undefined!}%
        {Use the \author command to define it}
    }\fi

    \ifx\@title\@empty{%
        \ClassError{\@classname}{Document title is undefined!}%
            {Use the \title command to define it}
    }\fi
%    \ifx\@supervisor\@empty{%
%        \ClassError{\@classname}{Student supervisor is undefined!}%
%            {Use the \supervisor command to define it}
%    }\fi
    \ifx\@academicyear\@empty{%
        \ClassError{\@classname}{Academic year is undefined!}%
            {Use the \academicyear command to define it}
    }\fi
%    \ifx\@examperiod\@empty{%
%        \ClassError{\@classname}{Exam period is undefined!}%
%            {Use the \examperiod command to define it}
%    }\fi
    \ifx\@degreesought\@empty{%
        \ClassError{\@classname}{Degree sought is undefined!}%
            {Use the \degreesought command to define it}
    }\fi

    %% Since the input is there, set the PDF info
    \hypersetup{%
        pdftitle=\@title,
        pdfauthor=\@author
    }
}

\newif\if@dutch
\newif\if@english
\DeclareOptionX{dutch}{\@dutchtrue\@englishfalse}
\DeclareOptionX{english}{\@dutchfalse\@englishtrue}
\ExecuteOptionsX{english} %% Default language

\newif\if@partial
\define@boolkey+{hogentreport}{partial}[false]{%
    \ifKV@hogentreport@partial
        \@partialtrue
    \else
        \@partialfalse
    \fi
}{%
    \ClassWarning{\@classname}{Input not boolean, ignored}
}
\DeclareOptionX{partial}{\setkeys{\@classname}{partial}}
%% Allows the partial boolean to be set with a command
\newcommand{\partialthesis}[1]{\setkeys{\@classname}{partial=#1}}

\newif\if@nativefonts
\DeclareOptionX{nativefonts}{\@nativefontstrue}

\newif\if@print
\DeclareOptionX{print}{\@printtrue}

\DeclareOption{twocolumn}{
    \OptionNotUsed
    \ClassError{\@classname}{Only single column documents supported!}%
        {Please remove the option 'twocolumn'}
}

%% Pass the unknown options to the class
\DeclareOptionX*{\PassOptionsToClass{\CurrentOption}{book}}

\ProcessOptionsX\relax
\LoadClass[11pt]{book}

%% English is the default language, but this can be changed to Dutch by
%% specifying the 'dutch' option to the document class
\if@dutch
    \RequirePackage[dutch]{babel}
    \RequirePackage[style=apa,natbib,backend=biber]{biblatex}
    \DeclareLanguageMapping{dutch}{dutch-apa}
\else
    %% We need Dutch for English theses, e.g. on the translated title page
    \RequirePackage[main=english,dutch]{babel}
    \RequirePackage[backend=biber,style=apa]{biblatex}
    \DeclareLanguageMapping{english}{british-apa}
\fi

\RequirePackage[small,bf,nooneline,footnotesize]{caption}
\RequirePackage[flushmargin,hang]{footmisc}
\RequirePackage{ifpdf}
\RequirePackage{ifxetex}
\RequirePackage{ifluatex}

\ifxetex
    \RequirePackage[xetex]{geometry}
    \RequirePackage[xetex]{graphicx}
    \RequirePackage[xetex,plainpages=false,breaklinks=true]{hyperref}
    \RequirePackage[no-math]{fontspec}
    \RequirePackage[mathrm=sym]{unicode-math}
    \unimathsetup{math-style=ISO,bold-style=ISO,sans-style=upright,mathrm=sym}
    \RequirePackage{realscripts}
    \defaultfontfeatures{Ligatures=TeX}
\else
    \ifluatex
        \RequirePackage[luatex]{geometry}
        \RequirePackage[luatex]{graphicx}
        \RequirePackage[luatex,plainpages=false,breaklinks]{hyperref}
        \RequirePackage[no-math]{fontspec}

        \RequirePackage[mathrm=sym]{unicode-math}
        \unimathsetup{math-style=ISO,bold-style=ISO,sans-style=upright,
        mathrm=sym}
        \RequirePackage{lualatex-math}
        \RequirePackage{realscripts}
    \else
        \@nativefontstrue %% Force native font rendering
        \ifpdf
            \RequirePackage[pdftex]{geometry}
            \RequirePackage[pdftex]{graphicx}
            \RequirePackage[pdftex,plainpages=false,breaklinks]{hyperref}
        \else
            \RequirePackage[dvips]{geometry}
            \RequirePackage[dvips]{graphicx}
            \RequirePackage[hypertex,plainpages=false,breaklinks]{hyperref}
        \fi
    \fi
\fi

\graphicspath{{img/}}

\if@print
    \RequirePackage[gray]{xcolor}
\else
    \RequirePackage[dvipsnames]{xcolor}
\fi

\RequirePackage{tikz}
\usetikzlibrary{backgrounds}
\usetikzlibrary{positioning}
\RequirePackage[noindentafter]{titlesec}
\RequirePackage{titletoc}
\RequirePackage[nottoc]{tocbibind}
\RequirePackage{fancyhdr}

%% Define the HoGent style colors
%% Faculties:
\definecolor{hogent-fbo}{RGB}{0,147,208} % Business and Information Management
\definecolor{hogent-fmw}{RGB}{0,168,143} % Education, Health and Social Work
\definecolor{hogent-fnt}{RGB}{255,0,0}   % Faculty of Science and Technology
\definecolor{hogent-soa}{RGB}{0,0,0}     % School of Arts

%% Accent colors:
\definecolor{hogent-darkgreen}{RGB}{22,176,165}
\definecolor{hogent-pink}{RGB}{241,157,160}
\definecolor{hogent-ochre}{RGB}{250,188,50}
\definecolor{hogent-orange}{RGB}{239,135,103}
\definecolor{hogent-purple}{RGB}{187,144,189}
\definecolor{hogent-blue}{RGB}{76,162,213}
\definecolor{hogent-lightgreen}{RGB}{165,202,114}
\definecolor{hogent-brown}{RGB}{216,176,131}
\definecolor{hogent-grey}{RGB}{195,187,175}
\definecolor{hogent-yellow}{RGB}{244,222,0}

\colorlet{links}{hogent-blue} %% The color to be used for urls and references

%% These are the colors specified in the previous styling guide
%\definecolor{hogent-darkred}{RGB}{0,111,184}
%\definecolor{hogent-red}{RGB}{244,52,69}
%\definecolor{hogent-green}{RGB}{0,156,124}
%\definecolor{hogent-altpink}{RGB}{239,170,162}
%\definecolor{hogent-darkgrey}{RGB}{150,150,150}
%\definecolor{hogent-altyellow}{RGB}{255,218,0}

%% Setting of the faculty text and title color based on the class option
\ifx\@faculty\@empty{%
    \ClassError{\@classname}{Faculty parameter is undefined!}%
    {One of the following options must be added to the class options:%
        'fbo', 'fmw', 'fnt' or 'soa'}%
}\fi

\ifcase\@faculty@nr%
\relax %fbo
    \colorlet{title}{hogent-fbo}%
\or %fmw
    \colorlet{title}{hogent-fmw}%
\or %fnt
    \colorlet{title}{hogent-fnt}%
\else %soa
    \colorlet{title}{hogent-soa}%
\fi

\newcommand{\@facultyname}{%
    \ifcase\@faculty@nr%
    \relax %fbo
        \IfLanguageName{dutch}{Faculteit Bedrijf en Organisatie}%
            {Faculty of Business and Information Management}%
    \or %fmw
        \IfLanguageName{dutch}{Faculteit Mens en Welzijn}%
            {Faculty of Education, Health and Social Work}
    \or %fnt
        \IfLanguageName{dutch}{Faculteit Natuur en Techniek}%
            {Faculty of Science and Technology}
    \else %soa
        School of Arts%
    \fi
}

%% No title and link colors in print mode
\if@print
    \colorlet{title}{black}
    \colorlet{links}{black}
\fi



%% Font setup
\if@nativefonts
    \let\titlefont\@undefined
    \let\subtitlefont\@undefined
    \let\tocfont\@undefined

    \ClassInfo{\@classname}{Option 'nativefonts' set or
        not running XeLaTeX/LuaLaTeX: using native fonts}

    \RequirePackage[defaultfam,tabular,lining]{montserrat}
    \RequirePackage{inconsolata}
    \RequirePackage{sfmath} % Fallback sans serif math font

    \RequirePackage[T1]{fontenc}
    \renewcommand*\oldstylenums[1]{{\fontfamily{Montserrat-TOsF}\selectfont #1}}

    \def\titlefont{\fontseries{k}\selectfont} %% Set the black family for titles
    \def\subtitlefont{\fontseries{eb}\selectfont}
    \def\tocfont{\fontseries{m}\selectfont}   %% In the table of contents, use normal weighted text
    \def\titlestyle{\titlefont\bfseries}
\else
    %% Using fontspec for font rendering, first check system paths
    %% for font availability, if not fall back to local .otf files
    \IfFontExistsTF{Montserrat}{%
        \newfontfamily\montserratblack{Montserrat}[BoldFont={Montserrat Black}]
        \newfontfamily\montserratextrabold{Montserrat}%
            [BoldFont={Montserrat ExtraBold}]

        \def\titlefont{\montserratblack\bfseries}
        \def\subtitlefont{\montserratextrabold\bfseries}
        \def\tocfont{\montserratblack}

        \setmainfont{Montserrat}
        \setsansfont{Montserrat}
    }{%
        \newfontfamily\titlefont{Montserrat}[
            Path = fonts/Montserrat/,
            Extension = .otf,
            UprightFont = *-Black, %% Force black
            BoldFont=*-Black,
            ItalicFont=*-BlackItalic,
            BoldItalicFont= *-BlackItalic]

        \newfontfamily\subtitlefont{Montserrat}[
            Path = fonts/Montserrat/,
            Extension = .otf,
            UprightFont = *-ExtraBold, %% Force extra bold
            BoldFont=*-ExtraBold,
            ItalicFont=*-ExtraBoldItalic,
            BoldItalicFont= *-ExtraBoldItalic]

        \newfontfamily\subtitlefont{Montserrat}[
            Path = fonts/Montserrat/,
            Extension = .otf,
            UprightFont = *-Regular, %% Force extra bold
            BoldFont=*-Bold,
            ItalicFont=*-Italic,
            BoldItalicFont= *-BoldItalic]

        \setmainfont{Montserrat}[
            Path = fonts/Montserrat/,
            Extension = .otf,
            UprightFont = *-Regular,
            BoldFont=*-Bold,
            ItalicFont=*-Italic,
            BoldItalicFont= *-BoldItalic]

        \setsansfont{Montserrat}[
            Path = fonts/Montserrat/,
            Extension = .otf,
            UprightFont = *-Regular,
            BoldFont=*-Bold,
            ItalicFont=*-Italic,
            BoldItalicFont= *-BoldItalic]
    }

    \IfFontExistsTF{Inconsolata}{%
            \setmonofont{inconsolata}[StylisticSet={1,3},Scale=1.1]
            %% Shapely l, upright quotes, striked zeroes

    }{%
            \setmonofont{Inconsolata}[
                Path = fonts/Inconsolata/,
                Extension = .otf,
                UprightFont = *-Regular,
                BoldFont=*-Bold,
                ItalicFeatures = FakeSlant,
                BoldItalicFeatures = FakeSlant,
                Scale = 1.1]
    }

    % Use a unicode-compliant sans serif math font
    \IfFontExistsTF{Fira Math Regular}{%
        \setmathfont{Fira Math Regular}[BoldFont=Fira Math Bold]
        \setmathfont{Fira Math Regular}[FakeSlant, range={bfit->it}]
    }{%
        \setmathfont{FiraMath-Regular.otf}[
            Path = fonts/FiraMath/,
            BoldFont=FiraMath-Bold.otf]
        \setmathfont{FiraMath-Regular.otf}[
            Path = fonts/FiraMath/,
            FakeSlant,
            range={bfit->it}]
    }

    \def\titlestyle{\titlefont\bfseries}

\fi

%% Use the length of the 'HO' part of the logo to set the padding of the logo
\newsavebox{\logopart}
\savebox{\logopart}{\includegraphics[height=2cm]{logopart}}

%% We use A4 paper with slightly smaller margins than the default (scale = 0.7)
\geometry{a4paper,hscale=0.75,vscale=0.8,headheight=14pt,asymmetric}

%% Redefine maketitle for our custom title page
\if@titlepage%
    \renewcommand{\maketitle}{\thispagestyle{empty}\begin{titlepage}%
    \@checkvariables

    %% Change the geometry so the notes section doesn't bother us
    \newgeometry{top=2cm,bottom=\wd\logopart,left=1.5cm,right=1.5cm}

        %% Add whitespace at the top
        \addvspace{10\bigskipamount}

        \begingroup
            %% Print the title in the faculty color
            \titlefont\color{title}\Huge\@title\@addpunct{.}\\
            %% Optionally print a subtitle
            \ifx\@subtitle\@empty\else
                \bigskip
                \subtitlefont\LARGE\@subtitle\@addpunct{.}
            \fi
            \hrule
        \endgroup
        \bigskip
        \begingroup
            %% Print the name of the author
            \subtitlefont\Large\bfseries \@author\@addpunct{.}
        \endgroup


        \vfill

        \begingroup
        \IfLanguageName{dutch}{%
            %Scriptie voorgedragen tot het bekomen van de graad van\\
            \@degreesought\\
        }{%
            %Thesis submitted in \if@partial{partial }\fi
            %fulfilment of the requirements for the degree of\\
            \@degreesought\\
        }
        \endgroup

    \bigskip
    \bigskip



%    \begingroup
%    \begin{tabular}{ll}
%        \IfLanguageName{dutch}{%
%            \textbf{Promotor:}}{\textbf{Supervisor:}} & \@supervisor\\
%        \ifx\@cosupervisor\@empty\else
%        \IfLanguageName{dutch}{%
%            \textbf{Co-promotor:}}{%
%            \textbf{Co-Supervisor:}} & \@cosupervisor\\
%        \fi
%        \ifx\@institution\@empty\else
%        \IfLanguageName{dutch}{%
%            \textbf{Instelling:}}{\textbf{Institution:}} & \@institution\\
%        \fi
%    \end{tabular}
%
%    \bigskip
%
%
    \begin{tabular}{ll}
        \IfLanguageName{dutch}{%
            \textbf{Academiejaar:}}{\textbf{Academic year:}} & \@academicyear\\
%        \textbf{%
%        \ifcase\@examperiod
%        \or
%        \IfLanguageName{dutch}{Eerste}{First}
%        \or
%        \IfLanguageName{dutch}{Tweede}{Second}
%        \else
%        \IfLanguageName{dutch}{Derde}{Third}
%        \fi
%        \IfLanguageName{dutch}{examenperiode}{exam period} } & \\
%
    \end{tabular}
%    \endgroup


     %% Insert the HoGent logo
    \begin{tikzpicture}[remember picture, overlay]
        \node [anchor=south east, shift={(-\the\wd\logopart, \the\wd\logopart)}, inner sep=0, outer sep=0] (logo) at (current page.south east)%
        {%
            \includegraphics[height=\the\ht\logopart]{hogent_logo}%
        };%
    \end{tikzpicture}

    \bigskip
    \begingroup
        \subtitlefont\bfseries\@facultyname\@addpunct{.}
    \endgroup

    \end{titlepage}%

    \thispagestyle{empty}
    \null\clearpage\restoregeometry
    }
\fi

%% Page style for title pages
\fancypagestyle{plain}{%
    \fancyhf{}
    \renewcommand*\headrulewidth{0pt}
    \renewcommand*\footrulewidth{0pt}
    \fancyfoot[C]{\titlefont\thepage}
}

%% Fancy style for the main matter
\fancypagestyle{mainmatter}{%
    \fancyhf{}
    %% Page numbers on the top left and top right
    \fancyhead[LE,RO]{\titlefont\thepage}
    %% Chapter name on the left (even) page
    \fancyhead[RE]{\titlefont\bfseries\nouppercase{\leftmark}}
    %% Section name on the right (odd) page
    \fancyhead[LO]{\titlefont\bfseries\nouppercase{\rightmark}}
}

%% The mainmatter style is default for normal pages
\pagestyle{mainmatter}

%% Print the current chapter and section at the top of the page
\renewcommand*\chaptermark[1]{\markboth{\thechapter.\ \color{title}#1}{}}
\renewcommand*\sectionmark[1]{\markright{\thesection.\ \color{title}#1}}

%% The setheader command can be used to print the title of unnumbered chapters
%% in the page header
\newcommand*\setheader[1]{\markboth{\color{title}#1}{\color{title}#1}}

%% Change the headrule command (from fancyhdr.sty) to draw the line below the
%% header in the title color
\renewcommand*\headrule{%
    \if@fancyplain%
        \let\headrulewidth\plainheadrulewidth%
    \fi%
    {\color{title}\hrule\@height\headrulewidth\@width\headwidth}%
    \vskip-\headrulewidth%
}

%% Change the style of paragraphs, normally text comes directly after the
%% paragraph title
\titleformat{\paragraph}[hang]{\normalfont\normalsize\bfseries}{\theparagraph}
{0pt}{}
\titlespacing\paragraph{0pt}{\baselineskip}{0pt}

%% Draw the line above a footnote in the title color as well
\renewcommand*\footnoterule{%
    \vspace*{-3pt}%
    {\color{title}\hrule width 0.5\textwidth height 0.4pt}%
    \vspace*{2.6pt}%
}

%% A part title starts with a huge (96pt) bold black number, flushed to the
%% right, followed by the part name on the next line in the title color
\titleformat{\part}[display]
    {\flushright\titlestyle}
    {\fontsize{96pt}{96pt}\selectfont\bfseries\thepart}
    {0pt}
    {\Huge\color{title}}
%% Separate the title from the text by two empty lines
\titlespacing{\part}{0pt}{0pt}{2\baselineskip}
%% In the table of contents, the part name is preceded by an empty line, printed
%% in bold, and not followed by a line of dots
\dottedcontents{part}[0em]{%
    \vspace{\baselineskip}\subtitlefont\bfseries}{1.5em}{0pc}

%% Chapter titles have the same layout as parts
\titleformat{\chapter}[display]
    {\flushright\titlestyle}
    {\fontsize{96pt}{96pt}\selectfont\bfseries\thechapter}
    {0pt}
    {\Huge\color{title}}
\titlespacing{\chapter}{0pt}{0pt}{2\baselineskip}
%% In the table of contents, a chapter is similar to a part, except that it is
%% preceded by half an empty line
\dottedcontents{chapter}[1.5em]{%
    \vspace{0.5\baselineskip}\subtitlefont\bfseries}{1.5em}{0pc}

%% Section titles start with the number in bold, followed by the name printed
%% in the title color
\titleformat{\section}
    {\Large\titlestyle}
    {\bfseries\thesection.\ }
    {0pt}
    {\color{title}}
%% Sections are preceded by an empty line.
\titlespacing{\section}{0pt}{\baselineskip}{3pt}
%% In the table of contents, section names are followed by a line of dots 8pt
%% apart
\dottedcontents{section}[3.8em]{\tocfont}{2.3em}{8pt}

%% Subsection titles have the same layout as section titles, except in a smaller
%% font
\titleformat{\subsection}
    {\large\titlestyle}
    {\bfseries\thesubsection.\ }
    {0pt}
    {\color{title}}
\titlespacing{\subsection}{0pt}{\baselineskip}{1.5pt}
\dottedcontents{subsection}[7em]{\tocfont}{3.2em}{8pt}

%% Subsubsections have the same font and color as sections and subsections, but
%% are not preceded by a number
\titleformat{\subsubsection}
    {\titlestyle}
    {}
    {0pt}
    {\color{title}}
%% Subsubsections are preceded by an empty line and do not appear in the table
%% of contents
\titlespacing{\subsubsection}{0pt}{\bigskipamount}{0pt}

%% Hyperlinks are blue, except in print mode, when they are all black
\hypersetup{%
    colorlinks = true,
    citecolor = links,
    linkcolor = title,
    urlcolor = links,
    breaklinks = true
}

\RequirePackage{microtype}                   %% Makes text easier on the eyes

%% For source code highlighting, requires pygments to be installed
%% Compile with the -shell-escape flag!
\RequirePackage[section]{minted}
%% Solarized: https://github.com/shkumagai/pygments-style-solarized/
\usemintedstyle{solarizedlight}
\definecolor{bg}{RGB}{253,246,227} %% Set the background color of the codeframe
\setminted{%
  bgcolor=bg,
  breaklines,
  linenos=true
}
%% Change this line to edit the line numbering style:
\renewcommand{\theFancyVerbLine}{\ttfamily\scriptsize\arabic{FancyVerbLine}}

\RequirePackage{csquotes}                    %% For advanced inline/display quotes
\RequirePackage[nottoc]{tocbibind}           %% Adds the bibliography/index to ToC
\RequirePackage{eurosym}                     %% For the euro symbol
\RequirePackage{textcomp}                    %% Some special characters

\setlength{\parindent}{0em}              %% Don't indent paragraph text
\setlength{\parskip}{1em}
\renewcommand{\baselinestretch}{1.2}     %% Increase line height
\raggedbottom                            %% Don't equalize content on pages

\RequirePackage{pdfpages}                    %% To add pages from PDF documents
\RequirePackage{standalone}                  %% Compile TeX/TikZ pictures standalone
\RequirePackage{wrapfig}                     %% For wrapping of figures

%% Add global exceptions to the hyphenation here
\hyphenation{back-slash}

\RequirePackage{pifont}                     %% Itemized list bullets
\RequirePackage{enumitem}                    %% Make changes to the layout of lists
%\setlist[1]{labelindent=\parindent}
\setlist[itemize,1]{label=\ding{108}} %% Filled circle
\setlist[itemize,2]{label=\ding{109}} %% Circle
\setlist[itemize,3]{label=\ding{110}} %% Filled square
\setlist[itemize,4]{label=\ding{111}} %% Square

\RequirePackage{tcolorbox}                   %% For nice colored box layouts
\RequirePackage{printlen}

\RequirePackage{tabularx}                    %% Other table packages: tabu, tabulary
\RequirePackage{booktabs}                    %% Better tables
\RequirePackage{rotating}                    %% Allows... rotation
\RequirePackage{makecell}                    %% Useful for multi-line table content
\captionsetup[figure]{labelformat=parens, labelsep=newline}

%% Prevent empty pages for right-handed chapter starts in twoside mode
\renewcommand{\cleardoublepage}{\clearpage}

\renewcommand{\arraystretch}{1.2}


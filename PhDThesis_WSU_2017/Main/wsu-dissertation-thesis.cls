
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{wsu-dissertation-thesis}[2017/04/12]
%\ProvidesExplPackage


\LoadClass{report} % Base of report.cls, which is based off latex.cls

%					LOAD REQUIRED PACKAGES
\RequirePackage{microtype} % One of the main points of using latex
\RequirePackage{xparse}
\RequirePackage{expl3}
\RequirePackage{etoolbox}
\RequirePackage{ragged2e}
\RequirePackage{l3keys2e}
\RequirePackage{setspace}
\RequirePackage{graphicx}
\RequirePackage{floatrow}
\RequirePackage{pgffor}
\RequirePackage{enumitem}
\RequirePackage[toc,page]{appendix}
\RequirePackage{caption}
	\captionsetup{margin=10pt,font=small,labelfont=bf}
\RequirePackage[letterpaper]{geometry}

% Set the margins with the geometry package
\newgeometry{showframe,left=1.75in,right=1.75in,top=1.5in,bottom=1.5in,footskip=0.75in,headsep=0.75in}

% Redefine the chapter command to be ALL CAPS
\renewcommand\chapter{\clearpage\thispagestyle{plain}\secdef\@chapter\@schapter}

% patch the list of command to make the spacing the same... Just removing some code.
\patchcmd%
	{\listof}%search
	{\setlength{\parskip}{\z@}}%command
	{\setlength\parskip{0\p@ \@plus \p@}}%replace
	{}%success
	{}%failure

% Patch the l@chapter command to remove the bold font series.
\patchcmd%
	{\l@chapter}%search
	{\bfseries}%command
	{}%replace
	{}%success
	{}%failure

\renewcommand{\float@listhead}[1]{\@schapter{#1}}

% Renew the appendix page command
\renewcommand{\appendixpage}{%% TODO: redfine latex3 style
	\clearpage
	\thispagestyle{plain}%
	\markboth{}{}%
	\let\ps@plain\ps@empty{%
	\chapter*{\appendixpagename}
	\vspace{\fill}
	\clearpage
	}%
	}

% Format some section titles to go with our wacky font sizes and other starting choices.
% https://tex.stackexchange.com/questions/36609/formatting-section-titles
\renewcommand\section{\@startsection {section}{1}{\z@}%
                                   {-3.5ex \@plus -1ex \@minus -.2ex}%
                                   {2.3ex \@plus.2ex}%
                                   {\normalfont\large\MakeUppercase}}
\renewcommand\subsection{\@startsection{subsection}{2}{\z@}%
                                     {-3.25ex\@plus -1ex \@minus -.2ex}%
                                     {1.5ex \@plus .2ex}%
                                     {\normalfont\large\bfseries}}
\def\@chapter[#1]#2{% TODO: redfine latex3 style
	\refstepcounter{chapter}%
	\addcontentsline{toc}{chapter}{#1}%
	\chaptermark{#1}%
	\vspace*{50pt}
	{\centering\large\bfseries\MakeUppercase{Chapter~\thechapter.} \par \MakeUppercase{#2}\par}
	\vspace{20pt}
	}

\def\@schapter#1{%
	\vspace*{50pt}
	{\centering\large\bfseries\MakeUppercase{#1}\par}
	\vspace{20pt}
}

% Redefine the heading command to properly locate the page numbers.
\def\ps@plain{%% TODO: redfine latex3 style
	\let\@mkboth\@gobbletwo
	%\let\@oddhead\@empty
	\let\@oddfoot\@empty
	\def\@oddhead{\reset@font\hfil\thepage}
	%\def\@oddfoot{\reset@font\hfil\thepage\hfil}
	\let\@evenhead\@oddhead
	\let\@evenfoot\@oddfoot}
% Set the default pagestyle to plain:
\pagestyle{plain}

% Turn on latex3 syntax:
\ExplSyntaxOn

% N = single token
% n = set of tokens in braces {}
% A token is either 
% 	(a) a single character with an attached category code, or 
% 	(b) a control sequence.

% Define class options
\keys_define:nn { wsu }
	{
	%DegreeTitle .tl_gset:N =    \g_wsu_Degree_tl,
	DToption .choices:nn   = 	{dissertation, thesis}
		{\tl_set:Nn \g_wsu_thesis_or_diss_tl { \l_keys_choice_tl } },
	}

%\keys_set:nn { wsu } {
%	DegreeTitle = {Default Degree Title}
%}


% Process options. This command is important, and defines the sections of 
% a class file. See ADD LINK
\ProcessKeysOptions { wsu }

% Set the degree title:
\NewDocumentCommand \setDegree { m } {
	\tl_gset:Nn  \g_wsu_Degree_tl {#1}
}

\NewDocumentCommand \setAdvisor { m } {
	\tl_gset:Nn \g_myAdvisor_tl {#1}
}

\NewDocumentCommand \setUniversity { m } {
	\tl_gset:Nn \g_myUniversity_tl {#1}
}

\NewDocumentCommand \setDepartment { m } {
	\tl_gset:Nn \g_myDepartment_tl {#1}
}

% set up the title command with two options
% normal will auto pyramid shape the title
% The \makeTitlePages*{} will allow manual breaks using \par
% and let the user set where the breaks occur.
\NewDocumentCommand \makeTitlePages {s} {% s = optional star command
	\clearpage 
	\pagenumbering{roman} \setcounter{page}{0}
	\group_begin:
	\noindent
	\centering \thispagestyle{empty} \singlespacing
%	\vspace*{\fill}
		\IfBooleanTF#1%
		{% star present
			{\large \lsstyle \MakeUppercase{\@title{}} \par }%
		}
		{% no star
			{\large \MakeUppercase{\@title{}} \par}%
		}
			\vspace{\fill}
			By \par
			\vspace{\baselineskip}
			\MakeUppercase{\@author} \par
			\vspace{\fill}
			A~
		\g_wsu_thesis_or_diss_tl
			\c_space_tl % adds a space after using a latex3 command.
			submitted~in~partial~fulfillment~of\par
			the~requirements~for~the~degree~of\par
			\vspace{1\baselineskip}
			\MakeUppercase{
		\g_wsu_Degree_tl
			}\par
			\vspace{3\baselineskip}
		\MakeUppercase{\g_myUniversity_tl}\par
		\g_myDepartment_tl\par
			\vspace{1\baselineskip}
		\MakeUppercase{\@date} \par
			\vspace{2\baselineskip}
			\copyright \hspace{0.2em}
			Copyright~by~\MakeUppercase{\@author},~YEAR\par
			All~Rights~Reserved\par
			% END TITLE PAGE, BEGIN TITLEBACK PAGE
			\clearpage \centering \thispagestyle{empty} 
			\vspace*{\fill}
			\copyright\hspace{0.2em}
			Copyright~by~\MakeUppercase{\@author},~YEAR\par
			All~Rights~Reserved \par
		\group_end:
	}


% Create new token list for committee
\tl_new:N \committe_tl

% Create command to add committee members.
\DeclareDocumentCommand \addCommitteeMembers {m}{
	\tl_put_right:Nn \committe_tl {#1}
}

% Command to draw the individual signatures.
% the map function will automatically do this for each member.
\DeclareDocumentCommand \makeSignatures {}{
	\tl_map_inline:Nn \committe_tl {
		\hrulefill \par
		##1,~Ph.D. \par
		\vspace{2\baselineskip}
	}
}

% Command to generate the signature page
\NewDocumentCommand \makeSignaturePage {} {
	\group_begin:
	\setlength\RaggedRightParindent{3em} \RaggedRight 
		\clearpage \doublespacing \pagestyle{plain}
		\vspace*{\fill}
		\noindent
		To~the~Faculty~of~Washington~State~University:\par
		The~members~of~the~Committee~appointed~to~examine~the~\MakeLowercase{dissertation~or~thesis}~of~\MakeUppercase{\@author}~find~it~satisfactory~and~recommend~that~it~be~accepted.\par
		\vspace{2.0 \baselineskip} \par
		\hfill
		\begin{minipage}{3in}
			\centering \singlespace
			\hrulefill \par
			\g_myAdvisor_tl,~Ph.D.,~Chair \par
			\vspace{2.0 \baselineskip}
				%\hrulefill \par
				%,~Ph.D. \par
	\makeSignatures \par
		\end{minipage}
		\vspace{\fill}

	\group_insert_after:N \clearpage
	\group_end:
}

% Create the acknowledgment environment
\NewDocumentEnvironment{ackPage} { O{} }
	{%start code
	\doublespacing \pagestyle{plain} %
	\@schapter{Acknowledgment}
	%\vspace*{50pt}
	%{\noindent \hfill \large \bfseries ACKNOWLEDGMENT \hspace*{\fill}}
	\setlength\RaggedRightParindent{3em} \RaggedRight 
	\vspace{\baselineskip}\par
	}
	{%end code
	\def\toclevel@section{0}
	\addcontentsline{toc}{chapter}{ACKNOWLEDGMENTS}
	}


% Create the abstract environment
\NewDocumentEnvironment{abstractPage} { O{} }
	{%start code
	\clearpage
	\group_begin:
		\singlespace
		\Centering  \pagestyle{plain}
		{\large \MakeUppercase{\@title{}} \par }
		\vspace{\fill}
		Abstract\par
		\vspace{\fill}
		by~\@author,~Ph.D.\par
		\g_myUniversity_tl \par
		\@date \par
		\vspace{\fill}
		Chair:~\g_myAdvisor_tl\par
	\group_end:
	\vspace{\fill}
	}
	{%end code
	\vspace{\fill}\par
	\phantomsection
	\def\toclevel@section{0}
	\addcontentsline{toc}{chapter}{ABSTRACT}
	%Q\clearpage
	}

\ExplSyntaxOff


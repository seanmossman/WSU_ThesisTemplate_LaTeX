
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{wsu}[2017/04/12]
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
\newgeometry{left=1.75in,right=1.75in,top=1.5in,bottom=1.5in,footskip=0.75in,headsep=0.75in}




% Redefine the chapter command to be ALL CAPS
\renewcommand\chapter{\clearpage\thispagestyle{plain}\secdef\@chapter\@schapter}

% Add a command that goes before starttoc to add page numbers.
% if it goes on for more than a page and you still want it remove this and use a manual solution for now:
% https://tex.stackexchange.com/questions/8296/add-page-above-page-numbers-in-table-of-contents


% Patch the l@chapter command to remove the bold font series.
\patchcmd%
	{\l@chapter}%command
	{\bfseries}%search
	{}%replace
	{}%success
	{}%failure

% Patch the tableofcontents command to add a 'page' heading.
\patchcmd%
	{\tableofcontents}%command
	{\@starttoc{toc}}%search
	{\hfill page \par\@starttoc{toc}}%replace
	{}%success
	{}%failure


\renewcommand{\float@listhead}[1]{\@schapter{#1}}

% Renew the appendix page command
\renewcommand{\appendixpage}{%% TODO: redfine latex3 style
	\clearpage
	\chapter*{\appendixpagename}
	\thispagestyle{empty} % must go after a page entry to work
	\clearpage
	}%
	
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
	\addcontentsline{toc}{chapter}{#1\dottedline}%
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

%% Declare variables for class options.
%% Draft option boolean
\bool_new:N \g__draft_mode_bool
%% Draft option for draft mode.
%% Using a custom name for now, because the draft option gets
%% passed to other packages, eg. graphicx and microtype.
\keys_define:nn { wsu } {
	wsudraft .code:n = \bool_gset_true:N \g__draft_mode_bool,
	wsudraft .default:n = \bool_gset_false:N \g__draft_mode_bool,
}


%% TODO: move this to the packages for each degree.
% Define class options
\keys_define:nn { wsu }
	{
	%DegreeTitle .tl_gset:N =    \g_wsu_Degree_tl,
	DToption .choices:nn   = 	{dissertation, thesis}
		{\tl_set:Nn \g_wsu_thesis_or_diss_tl { \l_keys_choice_tl } },
	}

% Process options. This command is important, and defines the sections of 
% a class file. See the "interface" documentation and l3keys2e.
\ProcessKeysOptions { wsu }

%% Implement wsudraft options:
\bool_if:NT \g__draft_mode_bool
	{\geometry{showframe}}

%% Implement a dot-fill command per WSU requirements.
%% for table of content entries.
\NewDocumentCommand \dottedline {} {
	\leaders\hbox{$\m@th \mkern \@dotsep mu\hbox{.}\mkern \@dotsep mu$}\hfill
}

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
	%\clearpage 
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
	%\setlength\RaggedRightParindent{3em} \RaggedRight 
	\vspace{\baselineskip}\par
	}
	{%end code
	\phantomsection
	\def\toclevel@section{0}\addcontentsline{toc}{chapter}{ACKNOWLEDGMENTS\dottedline}
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
	\addcontentsline{toc}{chapter}{ABSTRACT\dottedline}
	%Q\clearpage
	}

\ExplSyntaxOff


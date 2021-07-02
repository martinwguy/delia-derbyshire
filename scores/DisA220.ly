% This is the Lilypond source for Delia Derbyshire's score marked only
% "D = A220", % created by Martin Guy <martinwguy@gmail.com> 2021-07-02.
% For further info see http://wikidelia.net/wiki/D_=_A220

\version "2.18.2"

\header {
 title = "D = A220"
 composer = "Delia Derbyshire"
 tagline = "Typeset from Delia's score with Lilypond by Martin Guy. See http://wikidelia-net/wiki/D_=_A220"
}

global = {
  % Print accidentals on all sharp/flat notes and nothing on naturals.
  % This seems to be the style in which Delia usually writes.
  \accidentalStyle forget
  % \key c \major   Choose a suitable key signature with C D Eb A Bb 
}

Melody = \new Voice \relative c' {
  | % A (24)
  \time 24/4
  %{1:4=4%}	a'1^"A"
  %{2:23=5%}	a2 d,2.
  %{3:1113=6%}	a'4 bes a d,2.
  %{5:11124=9%}	a'4 bes a ees2 d1
  | % B (20)
  \time 20/4
  %{2:23=5%}	a'2^"B" d,2.
  %{4:1113=6%}	a'4 bes a ees2.
  %{6:111114=9%}a4 bes a ees d c1  % Last two note lengths are unclear but
  				   % must add up to 5.
  | % C (24)
  \time 24/4
  %{2:23=5%}	a'2^"C" d,2.
  %{3:1113=6%}	a'4 bes a d,2.
  %{7:11123=8%}	a'4 bes a c2 a2.
  %{2:23=5%}	a2 d,2.
  | % D (34)
  \time 34/4
  %{2:33=6%}	a'2.^"D" d,2.
  %{3:2123=8%}	a'2 bes4 a2 d,2.
  %{4:2314=10%}	a'2 bes2. a4 ees1
  %{3:2224=10%}	a2 bes2 a2 d,1
  | % E (29)
  \time 29/4
  %{2:34=7%}	a'2.^"E" d,1
  %{5:22234=13%}a'2 bes a ees2. d1
  %{3:1224=9%}	a'4 bes2 a2 d,1
  | % F (27)
  \time 27/4
  %{2:22=4%}	a'2^"F" d,
  %{7:11133=9%}	a'4 bes a c2. a2.
  %{8:12122114=14%} a4 bes2 a4 c2 a2 ees4 d c1
  |
}

\paper {
  % Don't indent the first line of the score
  indent = #0
}

\score {
 \new Staff {
  \global
  \clef treble
  % Set tempo for MIDI output but don't include it in the printed score
  % A single-length note (1), which we represent with a crochet, is 2.6 seconds
  % of which there are 23.077 in a minute
  \tempo 4=23

  \new Voice { \Melody }
 }
 \midi {}
 \layout {}
}

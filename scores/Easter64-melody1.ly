% This is the Lilypond source for score fragment "Easter 64" by Delia Derbyshire
% created by Martin Guy <martinwguy@gmail.com>
% For further info see http://wikidelia.net/wiki/Easter_64

\version "2.16.2"

\header {
 title = "Easter 64 (melody on page 1, first 11 bars)"
 composer = "Delia Derbyshire"
 tagline = "Typeset from Delia's score with Lilypond by Martin Guy. See http://wikidelia-net/wiki/Easter_64"
}

global = {
  % Don't print the time signature, as there isn't one.
  \override Staff.TimeSignature.stencil = ##f
  % Print accidentals on all sharp/flat notes and nothing on naturals.
  % This seems to be the style in which Delia wrote the score.
  \accidentalStyle forget
  \key c \major
}

Melody = \new Voice \relative c'' {
  \time 4/4
  r4 e4 b8 c8 cis4 |
  \time 10/4
  r4 fis4 cis8 d dis4 c cis r4 e4 b8 c8 cis4 |
  \time 6/4
  r4 fis4 cis8 d dis4 <gis c,>4 <cis, dis>4 |
  % line 2
  \time 4/4
  r4 gis'4 dis8 e f4 |
  \time 6/4
  r4 bes f8 fis g4 e f ||
  \time 4/4
  r4 gis dis8 e f4 |
  \time 6/4
  r4 bes4 f8 fis g4 <e c'>4 <f g> |
  % line 3
  \time 8/4
  r4 c'4 g8 gis8 a4 fis g e fis |
  \time 6/4
  <dis g d'>2. <e gis a>2. |
  \time 8/4
  r4 d'4 a8 ais b4 gis a fis g |
  \time 6/4
  <f a e'>2. <fis b fis'>2. |
}

\paper {
  % Don't indent the first line of the score
  indent = #0
}

\score {
 \new Staff {
  \global
  \clef treble
  \tempo 4=120	% Unknown tempo; default of 60 sound ponderous
  \new Voice { \Melody }
 }
 \midi {}
 \layout {}
}

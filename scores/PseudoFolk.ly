% This is the Lilypond source for score fragment "Pseudo Folk"
% by Delia Derbyshire
% created by Martin Guy <martinwguy@gmail.com> in December 2015.
% % For further info on this piece of music see
% http://wikidelia.net/wiki/Pseudo_Folk

\version "2.16.2"

\header {
 title = "Pseudo Folk"
 composer = "Delia Derbyshire"
}

global= {
  \time 4/4
  \key c \major
}

Melody = \new Voice \relative c'' {
  g a b c
}

Bass = \new Voice \relative c' {
  <c f,> r r <e a,>
}

\paper {
  % Don't indent the first line of the score
  indent = #0
}

\score {
  \new PianoStaff
  <<
   % No curly bracket at the start of the staves, thank you
   \set GrandStaff.systemStartDelimiter = #'SystemStartBar

   \new Staff {
    \tempo 4=120
    \clef treble
    \time 4/4
    \key c \major
    \new Voice { \Melody }
   }

   % Bass staff of entire piece
   \new Staff {
    \clef bass
    \time 4/4
    \key c \major
    \new Voice { \Bass }
   }
  >>
 \midi {}
 \layout {}
}

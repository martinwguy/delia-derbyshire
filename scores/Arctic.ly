% This is the Lilypond source for score fragment "Arctic" by Delia Derbyshire
% created by Martin Guy <martinwguy@gmail.com> in December 2015.
% For further info on this piece of music see
% http://wikidelia.net/wiki/Arctic

\version "2.16.2"

\header {
 title = "Arctic"
 composer = "Delia Derbyshire"
}

global= {
  % \time 4/4
  \key c \major
}

Melody = \new Voice \relative c'' {
  \time 21/1
  \slurUp
  gis1( fis)
  gis!( fis! d')
  gis,!( fis! e' d)
  gis,!( fis! e' d ais! fis! e d)
  fis! gis! d' ais!
}

Bass = \new Voice \relative c, {
  <c g' c g'>1*21
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
    \clef treble
    % \key c \major
    \new Voice { \Melody }
   }

   % Bass staff of entire piece
   \new Staff {
    \clef bass
    % \key c \major
    \new Voice { \Bass }
   }
  >>
 \midi {}
 \layout {}
}

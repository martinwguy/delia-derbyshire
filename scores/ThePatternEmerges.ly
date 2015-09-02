% This is the Lilypond source for "The Pattern Emerges" by Delia Derbyshire
% released on the album "Electrosonic" in 1972
% created by Martin Guy <martinwguy@gmail.com> in July 2012.
%
% For further info on this piece of music
% see http://wiki.delia-derbyshire.net/wiki/The_Pattern_Emerges

\version "2.10"

\header {
 title = "The Pattern Emerges"
 composer = "Delia Derbyshire"
}

% We divide the piece into three staves: the melody, the accompanying chords
% and the bass line.

global= {
  \time 4/4
  \key c \major
}

Melody = \new Voice \relative c'' {
  \partial 4 b8 c |
  a2. b8 c 
}

Chords = \new Voice \relative c'' {
  \partial 4 r4 |
}

Bass = \new Voice \relative c {
  \partial 4 r4 |
}


\paper {
  % Don't indent the first line of the score
  indent = #0
}

\score {
 {
  \new PianoStaff
  <<
   % No curly bracket at the start of the staves, thank you
   \set GrandStaff.systemStartDelimiter = #'SystemStartBar

   % Treble staff of entire piece
   \new Staff {
    \clef treble
    \time 4/4
    \key c \major

    \context Staff <<
     \new Voice { \Melody }
     \new Voice { \Chords }
    >>
   }

   % Bass staff of entire piece
   \new Staff {
    \clef bass
    \time 4/4
    \key c \major

    \new Voice { \Bass }
   }
  >>
 }
 \midi {}
 \layout {}
}

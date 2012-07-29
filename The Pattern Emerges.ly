% This is the Lilypond source for "The Pattern Emerges" by Delia Derbyshire
% released on the album "Electrosonic" in 1972
% created by Martin Guy <martinwguy@gmail.com> in July 2012.
%
% For further info on this piece of music
% see http://wiki.delia-derbyshire.net/wiki/The_Pattern_Emerges

\version "2.10"

% We divide the piece into three staves: the melody, the accompanying chords
% and the bass line.

global= {
  \time 4/4
  \key c \major
}

melody = \new Voice \relative c'' {
  \partial 4 b8 c |
  a2. b8 c 
}

chords = \new Voice \relative c'' {
  \partial 4 r4 |

bass = \new Voice \relative c {
  \partial 4 r4 |

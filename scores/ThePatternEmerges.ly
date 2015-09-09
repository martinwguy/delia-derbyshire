% This is the Lilypond source for "The Pattern Emerges" by Delia Derbyshire
% released on the album "Electrosonic" in 1972
% created by Martin Guy <martinwguy@gmail.com> in July 2012. % % For further info on this piece of music see
% http://wikidelia.net/wiki/The_Pattern_Emerges

\version "2.16.2"

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

Melody = \new Voice \relative c''' {
  \ottava #1 \stemUp
  % Really the b8 is extended to a b4 simultaneous with the c
  \partial 8. b16 c8 |
  \set Staff.currentBarNumber = #1
  %1
  a2. b8 c | a2. b8 c | e b fis'2 b,8 c| a2. b8 c |
  %5
  g' c, fis2 b,8 c | g' c, fis2 b,8 c | a2. b8 c | a2. e'8 f |
  %9
  b f ais2 e8 f | b f ais2 dis,8 e | bes' e, a2 dis,8 e | bes' e, a2 d,8 ees |
  %13
  a ees gis2 d8 ees | a ees gis2 cis,8 d | aes' d, g2 c,8 des | g des fis2 b,8 c |
  %17
  ges' b, f'2 b,8 c | ges' b, f'2 b,8 c |
  %19
  a2. b8 c | a2. b8 c | gis'2. b,8 c | ais'2. b8 c | a2. b8 c | a2. b8 c |
  %25
  \ottava #2
  fis 1 | g 1 | aes1~ | aes1~ | aes4
}

Chords = \new Voice \relative c'' {
  \ottava #1 \stemDown
  \partial 8. s8. |
  %1
  r8 <f aes>8 <e g>4 <ees ges>2 |
  r8 <f aes>8 <e g>4 <ees ges>2 |
  <d f>4. <f aes>8 <e g>2 | 
  r8 <f aes>8 <e g>4 <ees ges>2 |
  %5
  aes8 <ges a>4 <f aes>8 <e g>4 <ees ges>4 |
  aes8 <ges a>4 <f aes>8 <e g>2~ |
  <e g>8     <f aes>8 <e g>4 <ees ges>2~ |
  <ees ges>8 <f aes>8 <e g>4 <ees ges>4 <f aes>4 |
  %9
  <d f>8 <aes' b> <f aes> <aes b> <f aes>16 <ees ges> <d f>8 <f aes>4 |
  <d f>8 <aes' b> <f aes> <aes b> <f aes>16 <ees ges> <d f>8 <f aes>4 |
  <des e>8 <g bes> <e g> <g bes> <e g>16 <d f> <des e>8 <e g>4 |
  <des e>8 <g bes> <e g> <g bes> <e g>16 <d f> <des e>8 <e g>4 |
  <c ees>8 <ges' a> <ees ges> <ges a> <ees ges>16 <des e> <c ees>8 <ees ges>4 |
  <c ees>8 <ges' a> <ees ges> <ges a> \times 2/3 { <ees ges>16 <des e>8 } <c ees>8 <ees ges>4 | %?
  %15
  <b d>8 <f' aes> <d f> <f aes> <d f>16 <c ees> <b d>8 <d f>4 |
  <bes des>8 <e g> <des e> <e g> <des e>16 <b d> <bes des>8 <des e>4 |
  <a c>8 <ees' ges> <c ees> <ees ges> <c ees>16 <bes des> <a c>8 <c ees>4 |
  <a c>8 <ees' ges> <c ees> <ees ges> <c ees>16 <bes des> <a c>8 <c ees>4~ |
  %19
  <c ees>8   <f aes> <e g>4 <ees ges>2~ |
  <ees ges>8 <f aes> <e g>4 <ees ges>2~ |
  <ees ges>8 <e g> <ees ges>4 <d f>2~ |
  <d f>8     <ges a> <f aes>4 <e g> <ees ges>4~ |
  %23
  <ees ges>8 <f' aes> <e g>4 <ees ges>2~ |
  <ees ges>8 <f aes> <e g>4 <ees ges>2~ |
  <ees ges>8 <d f>8 <des e>4 <c ees>4 <b d>4~ |
  <b d>8     <ees ges>8 <d f>4 <des e>4 <c ees>4~ |
  <c ees>8   <e g>8 <ees ges>4 <d f>4 <des e>4~ | <des e>1~ | <des e>4
}

Bass = \new Voice \relative c {
  \partial 8. s8. |
  %1
  \times 2/3 { c,8 g' e' b' e b } e,2 |
  \times 2/3 { c,8 g' e' b' e b } e,2 |
  \times 2/3 { c,8 g' e' b' e b } e,2 |
  \times 2/3 { c,8 g' e' b' e b } e,2 |
  \times 2/3 { c,8 g' e' b' e b } e,2 |
  \times 2/3 { c,8 g' e' b' e b } e,2 |
  \times 2/3 { c,8 g' e' b' e b } e,2 |
  \times 2/3 { c,8 g' e' b' e b } e,2 |
  %9
  \times 2/3 { e8  aes b } e8 aes  e4~ \times 2/3 { e8 d16 c b8 } |
  \times 2/3 { e,8 aes b } e8 aes  e4  b |
  \times 2/3 { ees,8  g bes } ees8 g  ees4~ \times 2/3 { ees8 des16 b bes8 } |
  \times 2/3 { ees,8 g bes } ees8 g  ees4  bes |
  \times 2/3 { d,8  ges a } d8 ges  d4~ \times 2/3 { d8 c16 bes a8 } |
  \times 2/3 { d,8 ges a } d8 ges  d4  a |
  \times 2/3 { des,8  f aes } des8 f  des4~ \times 2/3 { des8 b16 a aes8 } |
  \times 2/3 { c,8 e g } c8 e  c4  g |
  \times 2/3 { b,8 ees ges } b8 ees  b4 ges |
  \times 2/3 { b,8 ees ges } b8 ees  b2 |
  %19
  \times 2/3 { c,,8 g' e' b' e b } e,2 |
  \times 2/3 { c,8 g' e' b' e b } e,2 |
  \times 2/3 { c,8 g' e' b' e b } e,2 |
  \times 2/3 { c,8 g' e' b' e b } e,2 |
  \times 2/3 { c,8 g' e' b' e b } e,2 |
  % up an octave
  \times 2/3 { c8  g' e' b' e b } e,2 |
  %25
  \times 2/3 { c,8  g' e' b' e b } e,2 |
  \times 2/3 { c,8  g' e' b' e b } e,2 |
  \times 2/3 { c,8  g' e' b' e b } e,2~ | e1~ | e4
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

   % Treble staff of entire piece
   \new Staff {
    \clef treble
    \time 4/4
    \key c \major
    % one bar lasts 6 seconds so a crochet is 1.5 seconds. 60/1.5=40
    \tempo 4=40

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
 \midi {}
 \layout {}
}

\version "2.18.2"

\header {
 title = "Busy Microbes"
 composer = "Delia Derbyshire"
}

\score {
  \new PianoStaff
  <<
   % No curly bracket at the start of the staves
   \set GrandStaff.systemStartDelimiter = #'SystemStartBar

   % Continuous high-frequency chords
   \new Staff \with {
     midiInstrument = #"flute"
     instrumentName = #"Piccolo"
   } {
    \time 7/8
    \tempo 4=115	% measured in first 4 14-semiquaver bars
    \clef treble
    \relative c''' {
     \new Voice {
      \stemUp
      \ottava #1
      \partial 8. <f' e b>8.~ |
      % Every chord has the same shape, like C+F+F# (bottom-to-top)
      % (but here they are written top-to-bottom)
      < f e   b   > 2..
      < e ees bes > 2..
      < b bes f   > 2..
      < ees d a   > 2..
      < e ees bes > 2..
      < aes g d   > 2..
      < f e b     > 2..
      < e ees bes > 2..
      < b bes f   > 2..
      < ees d a   > 2..
      < e ees bes > 2..
      < aes g d   > 2.. ~
      \time 5/16
      < aes g d > 8  <g ees>8.~
      \time 4/4	% or something
      < g ees > 1~
      < g ees > 1~
      < g ees > 1~
      < g ees > 2
     }
    }
   }
   % Melody
   \new Staff {
    \clef treble
    \relative c'' {
     \new Voice {
      \partial 8. r8. |
      r8 f16   b    e  ees  a,  c    g    ges  f'   b, r8 | %1
      r8 a16   ees' e, b'   bes d,   des' b    f'   a, r8 | %2
      r8 ges16 g    f' b,   c,  a'   ees' e,   b'   f  r8 | %3
      r8 a16   f'   b  des, d,  bes' b    e,   des' a  r8 | %4
      r8 e'16  bes  b  ges  f'  a,   aes  ges' c,   e, r8 | %5
      r8 d16   bes' e  ges, g   ees' des  a    aes  d  r8 | %6
      r8 f,16   b   e  ees  a,  c    g    ges  f'   b, r8 | %7
      r8 a16   ees' e, b'   bes d,   des' b    f'   a, r8 | %8
      r8 ges16 g    f' b,   c,  a'   ees' e,   b'   f  r8 | %9
      r8 a16   f'   b  des, c,  bes' b    e,   des' a  r8 | %10
      r8 e'16  bes  b  ges  f'  a,   aes  ges' c,   e, r8 | %11
      r8 d16   bes' f' ges, g  ees' des  a    aes   d  r8 | %12
      r8 r8. }
     << \new Voice {
      \stemUp
          g,,16 des' d aes a ees' e bes   b f' ges c, des g aes d,
          ees a bes e, f b c ges          g des' d aes a ees' e bes
          b f' ges c, des g aes d,        ees a bes e, f b c ges
          g des' d aes a ees' e bes
     }
     \new Voice {
      \stemDown
	  %         maybe e d
          c,,16 ges f b a e ees a	 aes d, des g ges c, b f'
          e 
     }
     >>
    }
   }
   \new Staff {
    \clef bass
    \relative c {
     \new Voice {
      \partial 8. r8. |
     }
    }
   }
  >>

 \layout { }
 \midi { }
}

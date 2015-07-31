\version "2.12.1"

\header {
 title = "Fresh Aire"
 composer = "Delia Derbyshire"
}

\score {
  \new PianoStaff
  <<
   % No curly bracket at the start of the staves, thank you
   \set GrandStaff.systemStartDelimiter = #'SystemStartBar

   \new Staff {
    \time 3/4
    \tempo 4=188
    \clef treble
    \relative c'' {
     \new Voice {
      \stemUp
      \ottava #1
      c16 e g c c, e g c c, e g c
       c, e g c c, e g c c, e g c
       e, g c e e, g c e e, g c e
       e, g c e e, g c e e, g c e
       g, c e g g, c e g g, c e g
       g, c e g g, c e g g, c e g
       c, e g c c, e g c c, e g c
       c, e g c c, e g c c, e g c
     }
    }
   }
   \new Staff {
    \time 3/4
    \clef treble
    \relative c' {
     \new Voice {
      c4 e g c e g
       c g e c g e
      g' e c g e g
      c, e g c2.
     }
    }
   }
   \new Staff {
    \time 3/4
    \clef bass
    \relative c {
     \new Voice {
      c2. ~ c2 g4
      c2. ~ c2 e4
      g2. c2 g,4
      c2. ~ c2.
     }
    }
   }
  >>

 \layout { indent = #0 }
 \midi { }
}

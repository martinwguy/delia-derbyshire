\version "2.12.1"

\header {
 title = "Philips"
 subtitle = "score fragment dd090009"
 composer = "Delia Derbyshire"
}

\score {
  \new PianoStaff
  <<
   % No curly bracket at the start of the staves, thank you
   \set GrandStaff.systemStartDelimiter = #'SystemStartBar

   \new Staff <<
    % Set tempo for MIDI output but don't include it in the printed score
    \tempo 4=273  % "crotchet = .22s"
    \time 6/8
    \clef treble
    \relative c'''' {
     \new Voice {
      \ottava #1 \stemUp \autoBeamOff
      c8 b r c b r | c b r c b r | c b r c b r | c b r c b r |
     }
    }
    \relative c''' {
     \new Voice {
      \ottava #1 \stemDown 
      s2. | c4. g8 c4 | d4. g2\laissezVibrer
     }
    }
   >>
   \new Staff {
    \time 6/8
    \clef treble
    \relative c' {
     \new Voice {
       <c e>2. <a e' g> <g d' b'>\laissezVibrer
     }
    }
   }
  >>

 \layout { indent = #0 }
 \midi { }
}

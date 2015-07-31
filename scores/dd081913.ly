\version "2.12.1"
\score {
  \new PianoStaff
  <<
   % No curly bracket at the start of the staves, thank you
   \set GrandStaff.systemStartDelimiter = #'SystemStartBar
   \set Score.tempoHideNote = ##t

   \new Staff {
    % Set tempo for MIDI output but don't include it in the printed score
    \tempo 4=90
    \time 8/4
    \clef treble
    \relative c'' {
     \new Voice {
      \ottava #1 \stemUp
      % TODO Second b is maybe f
      gis'16 e' fis b, fis4  gis!16 e' fis! b, b'4
      % TODO 2nd half may be two voices
      e,16 b' d, b e4  fis,!16 b e b fis'!4
      fis16 b, d-+ fis, d4-+  d'16 fis,! b d, b4
      % second d may be d# (?)
      b'16 d, fis! b, d' fis,! b  d, b8 fis'! d' b'
     }
    }
   }
   \new Staff {
    \time 8/4
    \clef treble
    \relative c'' {
     \new Voice {
      \ottava #1
      e'2 fis, gis d | s1*2
     }
    }
   }
   \new Staff {
    \time 8/4
    \clef bass
    \relative c {
     \new Voice {
      s1*2 | b2 fis'4 d' d1
     }
    }
   }
  >>

 \layout { indent = #0 }
 \midi { }
}

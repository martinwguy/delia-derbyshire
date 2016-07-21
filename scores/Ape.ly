% Reconstruction of one of Delia Derbyshire's themes for "Ape and Essence"
% from manuscript score in her papers.
% See http://wikidelia.net/wiki/Ape and Essence
\version "2.12.3"

\header {
 title = "Ape"
 composer = "Delia Derbyshire"
}

\score {
 \new PianoStaff
 <<
  \new Staff {
   \time 3/4
   % No time signatures are printed in this score.
   \override Staff.TimeSignature #'stencil = ##f

   % Set tempo for MIDI output but don't include it in the printed score
   \tempo 4=90
   \set Score.tempoHideNote = ##t

   \clef treble

   \relative c' {
    \new Voice {
     \stemUp
     c4 ais' fis | d'4. e,8 gis4 | ais fis d' | e,4. gis8 c,4 |
     fis d' e, | gis4. c,8 ais'4 |
    }
   }
  }
  \new Staff {
   \time 3/4
   \override Staff.TimeSignature #'stencil = ##f
   \clef bass
   \relative c {
    \new Voice {
     e2. | c | gis | ais | c | d |
    }
   }
  }
 >>

 % Delia doesn't indent the first line of scores, so neither do we
 \layout { indent = #0 }
 \midi { }
}

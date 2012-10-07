% Notation for score from Delia Derbyshire's papers "Music To Undress To",
% http://delia-derbyshire.net/papers/html/dd155635.html
\version "2.12.3"
 \header {
 title = "Music to Undress to"
 composer = "Delia Derbyshire"
 }
\score {
 \new PianoStaff
 <<
  % No curly bracket at the start of the staves, thank you
  \set GrandStaff.systemStartDelimiter = #'SystemStartBar

  \new Staff {
   \time 4/4
   % No time signatures are printed in this score.
   \override Staff.TimeSignature #'stencil = ##f

   % Set tempo for MIDI output but don't include it in the printed score
   \tempo 4=90
   \set Score.tempoHideNote = ##t

   \clef treble

   \relative c'' {
    \new Voice {
     \stemUp \autoBeamOff
     c4. c8~c g a4 |
     b4 b8[ b8~] b2 |
     c8[ b a g~] g[ c,] d4 |
     e e8[ e~] e[ fis~] fis[ e] |

     b'4 gis8[ e~] e[ fis~] fis[ e] |
     b'4 gis8[ e] << { e4 fis8[ e] } \\ { \stemUp s8 d'~ d[ c] } >>|
     \time 3/4       b8[ a gis b] a[ g] |
     \time 5/8                              a4 e8 e4
     \once \override BarLine #'dash-period = #0.75
     \once \override BarLine #'dash-fraction = #0.1
     | g d8 d4 |
    }
   }
  }
  \new Staff {
   \time 4/4
   \override Staff.TimeSignature #'stencil = ##f
   \clef treble
   \relative c' {
    \new Voice {
     <c e g c>1 | <e gis b> |
     <c f a c>4. <c e g c>8~<c e g c>2 |
     % r8 is not there in the manuscript but implied by the chord position
     <a e' a c> s8 << { < e' fis a c >4. } \\ { \stemDown a,4. } >>  |

     << { <e' gis b>2~ } \\ { \stemDown e,2 } >> <e' gis b>4 <e fis a c> |
     <e gis b>2 s |
     \time 3/4 <cis e>4 <d e> <cis e> | \time 5/8 <b d e>4. <a cis e>4 |
     <a c d>4. <g b d>4 | 
    }
   }
  }
  \new Staff {
   \time 4/4
   \override Staff.TimeSignature #'stencil = ##f
   \clef bass
   \relative c {
    \new Voice {
     % No bassline here in main score dd155635
     %s1 * 4 |
     % Bass from dd104935 "Bass Cpt. to Undressing"
     c4 c c c | e8 b' cis b~ b gis g fis |
     f c' d ees  e g, gis d' a e' b c~c a4. |
     #(set-time-signature 8 8 '(2 2 2 2))
     e,4 gis8 b~b c~c d | e4 gis8 b~b c~c d |
     \time 3/4 s2. | \time 5/8 s4. s4 s4. s4 |
    }
   }
  }
 >>

 % Delia doesn't indent the first line of scores, so neither do we
 \layout { indent = #0 }
 \midi { }
}

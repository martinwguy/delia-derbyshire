% Notation for score from Delia Derbyshire's papers "Anything Goes",
% http://delia-derbyshire.net/papers/html/dd120020.html
\version "2.12.3"

\header {
 title = "Anything Goes"
 composer = "Delia Derbyshire"
}

\score {
 \new PianoStaff
 << % No curly bracket at the start of the staves, thank you
  \set GrandStaff.systemStartDelimiter = #'SystemStartBar

  \new Staff {
   \time 12/8

   % Set tempo from the score:
   % "(dotted minim) - .96s = 14.4i (inches of tape at 15 inches per second)"
   % 60 seconds / 0.96 = 62.5, so quaver = 6 times this
   \tempo 8=375

   \clef treble

   % Only the second and third staves have a printed time signature
   \override Staff.TimeSignature #'stencil = ##f

   \relative c'' {
    \new Voice {
     s1. |
     s1. |
     r1 r8 \stemUp b4. | % rest needs fixing, add slur/tie
     d1. ~ |

     \stemDown
     d4. f4. ~ f8 a f d4 b8 ~ |
     b4. f' a b |
     g e' ~ e2. ~ |
     \autoBeamOff
     e4. g,8. e8. ~ e2. \bar "||"
    }
   }
  }
  \new Staff {
   \time 12/8
   \clef treble
   \relative c' {
    \new Voice {
     \stemUp \autoBeamOff
     <e' e,>2. <g g,>2. |
     \stemDown
     <c  c,>2. ~ <c c,>4. <g g,>4. |
     <b b,>4 <f f,>8 <b, b,>8. <d d,>8. ~ <d d,>2. ~ |
     <d d,>1. |

     r4. <b' b,> ~ <b b,>4 \stemUp <d d,>8 \stemDown <b b,>4 <f f,>8 ~ |
     <f f,>2. r4 <b b,>8 ~ <b b,>4 <d d,>8 |
     <e e,>4 <c c,>8 <g g,>8.[ <e e,>8.] ~ <e e,>2. ~ |
     <e e,>1. \bar "||"
    }
   }
  }
  \new Staff {
   \time 12/8
   \clef bass
   \relative c' {
    \new Voice {
     \stemDown
     <c c,>4 <c c,>8 <d c,>8. <c c,>8. ~ <c c,>4. <c c,>4 <c c,>8 |
     <c c,>4 <c c,>8 <d c,>8. <c c,>8. ~ <c c,>4. <d c,>4 <c c,>8 |
     <g g,>4 <g g,>8 <a g,>8. <g g,>8. ~ <g g,>4. <g g,>4 <g g,>8 |
     <g g,>4 <g g,>8 <a g,>8. <g g,>8. ~ <g g,>4. <a g,>4 <g g,>8 |
     
     <g g,>4 <g g,>8 <a g,>8. <g g,>8. ~ <g g,>4 <a g,>8 <g g,>4. ~ |
     <g g,>4 <g g,>8 <a g,>8. <g g,>8. ~ <g g,>4 <a g,>8~<a g,>4 <g g,>8 |
     <c c,>4 <c c,>8 <d c,>8. <c c,>8. ~ <c c,>4. <c c,>4 <c c,>8 |
     <c c,>4 <c c,>8 <d c,>8. <c c,>8. ~ <c c,>2. \bar "||"
    }
   }
  }
 >>

 % Delia doesn't indent the first line of scores, so neither do we
 \layout { indent = #0 }
 \midi { }
}

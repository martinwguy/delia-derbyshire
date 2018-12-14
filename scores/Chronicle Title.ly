% Notation for score of "Chronicle Title"
% See http://delia-derbyshire.net/papers/html/dd114058.html
% Martin Guy <martinwguy@gmail.com>, 14 December 2018.
\version "2.18.2"

\header {
 title = "Chronicle Title"
 subtitle = "1.2.69"
 composer = "Delia Derbyshire"
}

% We need ASCII names to markup double quotes
\paper {
  #(include-special-characters)
}

\markup "Typeset by martinwguy from Delia's handwritten score DD114058 in December 2018."
\markup "Tempos are measured from her audio realisation of the piece."

\score {
 \new PianoStaff
 <<
  % No curly bracket at the start of the staves
  \set GrandStaff.systemStartDelimiter = #'SystemStartBar

  \new Staff \with {
   midiInstrument = #"trumpet"
  } {
   \clef treble
   \time 6/8
   \override Staff.TimeSignature #'stencil = ##f
   \stemDown \tupletUp \override TupletBracket.bracket-visibility = ##t
   \set Timing.beamExceptions = #'((end.(((3 . 16).(1 1)))))

   \relative c'' {
    \new Voice {
     \stemDown
   \tempo 2.=55
     r2. | r2. | r2. |
   \tempo 2.=43
     a4.^"&elqq;sackbut&erqq;" \tuplet 2/3 { d8 cis } |
     \tuplet 2/3 { fis cis } \tuplet 2/3 { d cis } |
     \tuplet 2/3 { a gis } \tuplet 2/3 { fis gis } |
     \tempo 2.=37
     cis4.^"&elqq;trumpet&erqq;" d8-. fis-. gis-. | a-. gis-. d-. fis-. gis-. a-. |
     \override TextSpanner.bound-details.left.text = "Rallentando"
     gis-.\startTextSpan fis-. cis-. d-. fis-. gis-. | \tempo 2.=17 cis1\stopTextSpan |
    }
   }
  }

  \new Staff \with {
   midiInstrument = #"trumpet"
  } {
   \clef treble
   \override Staff.TimeSignature #'stencil = ##f
   \relative c' {
    \new Voice {
     \stemUp
     d2.^"&elqq;sackbut&erqq;" | gis4. fis | a fis |
     gis2. | fis | d | fis4. d | fis a | gis fis | gis1
    }
   }
  }

  \new Staff \with {
   midiInstrument = #"trumpet"
  } {
   \clef bass
   \override Staff.TimeSignature #'stencil = ##f
   \relative c' {
    \new Voice {
     \stemDown \tieDown
     a2.^"low voice" ~ | a ~ | a |
     fis ~ | fis ~ | fis |
     \tieNeutral
     d^"mix low voices & horns" ~ | < d gis ~ > | < d gis e > |
     \time 4/4 < cis gis' cis >1
    }
   }
  }
 >>

 % Delia doesn't indent the first line of scores, so neither do we
 \layout { indent = #0 }
 \midi { }
}

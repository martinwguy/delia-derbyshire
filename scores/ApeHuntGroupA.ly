% Notation for score from Delia Derbyshire's manuscript for "Ape: Hunt Group A"
% See http://wiki.delia-derbyshire.net/wiki/Ape

\version "2.12.3"

\header {
 title = "Ape: Hunt Group A"
 composer = "Delia Derbyshire"
}

\score {
 \new PianoStaff
 <<
  \new Staff {
   % Score says 15 crochets = 10 seconds, so 60 seconds = 90 crochets
   \tempo 4=90

   \clef treble
   \numericTimeSignature
   % Don't print tempo changes at the end of the previous line: they are too
   % common.
   \override Staff.TimeSignature #'break-visibility = #begin-of-line-visible

   \relative c' {
    \new Voice {
     % From DD122833 "APE Hunt Group A"
     \time 4/4	s1 |
     \time 3/4  d'8 aes c ges bes e, ~ |
     \time 4/4	e1 |
     \time 3/4	c8 fis des g des gis ~ |
     \time 4/4	gis1 |
     \break
     \time 3/4	c=''16 fis d! g d gis r8 r4 |
     		c,=''16 fis des g des gis r8 r4 | % \bar "||"
		d'='''16 aes c ges bes e, r8 r4 |
		d'='''16 aes c ges bes e, r8 r4 |
     \break
     % From DD122833 "APE: Hunt Group A cont."
     \time 4/4	c,='8 fis des g c,16 fis des g d gis r8 \bar "||"
     		d'=''8 aes c ges d'16 aes c ges bes e, r8 \bar "||"
    }
   }
  }
  \new Staff {
   \clef bass
   \numericTimeSignature
   \override Staff.TimeSignature #'break-visibility = #begin-of-line-visible

   \relative c {
    \new Voice {
     \time 4/4	c8 fis des g des gis ees a
     \time 3/4	gis2.
     \time 4/4	d'8 aes c ges bes e, aes d,
     \time 3/4	fis2.
     \time 4/4	s1
     \break
     \time 3/4	gis=2. %{ c8 %} |
		gis=2. %{ c8 %} |
		ais=2. %{ d8 %} |
		ais=2. %{ d8 %} |
     % From DD122833 "APE: Hunt Group A cont."
     \time 4/4	gis=1 | fis
    }
   }
  }
 >>

 % Delia doesn't indent the first line of scores, so neither do we
 \layout { indent = #0 }
 \midi { }
}

% Score for Delia Derbyshire's unknown piece "Clothes" dated 22.12.68
% reconstructed from a manuscript in her papers
% For further info see http://wikidelia.net/wiki/Clothes

\version "2.16.2"

\header {
 title = "Clothes"
 subtitle = "22.12.68"
 composer = "Delia Derbyshire"
}

\score {
  <<
    \new Staff {
      \relative c'
      \new Voice {
	\autoBeamOff \stemUp
	\tempo 4=120
	\partial 4. fis4 e8 |
		  b'4 gis8 e4 fis e8 |
		  b'4 gis8[ cis8]~ cis[ b] e[ g!] |
	\time 3/4 e4 cis8[ a]~ a4 |
	\time 8/4 c!2 a4 g2 e4 d c |
	\time 4/4 e8[ g a g]~ g[ c,~ c d] |
	\time 3/4 e[ g a c]~ c[ a] | 
		  c4 a8 fis4 ees'8 |
	\time 4/4 d4 c r2 |
      }
    }

    \new Staff {
      \relative c'
      \new Voice {
	\autoBeamOff
	\partial 4. <e fis a>4. |
	          <e gis b>2~ <e gis b>8 <e fis a>~ <e fis a>4 |
	          <e gis>4~ <e gis>8[ <e fis a>]~ <e fis a>4 <e gis? b>4 |
	\time 3/4 <e a c>2. |
	\time 8/4 <f a c>2. <e g c> <d f aes>2 |
	\time 4/4 <c e g>2 r8 g4 a8 |
	\time 3/4 c[ e ees e] e[ fis] |
		  ees4 c8 a4 fis8 |
	\time 4/4 f!4 e r2 |
      }
    }
  >> 
  \layout { }
  \midi { }
}

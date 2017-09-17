% Score for Delia Derbyshire's "Science and Health", reconstructed from
% her manuscript "dd113144".
% For further info see http://wikidelia.net/wiki/Science_and_Health

\version "2.16.2"

\header {
  title = "Science & Health"
  composer = "Delia Derbyshire"
  subtitle = "15.7.64"
  tagline = "Reconstructed from Delia's manuscripts DD113144 and DD123034. See http://wikidelia.net/wiki/Science_and_Health"
}

\score {
  <<
    \new Staff {
      \clef treble
      \relative c'' \new Voice {
        \time 4/4
        \partial 2 { \times 2/3 { r4 g8 g[ a b ] } } |
        \set Score.currentBarNumber = #1
        <c e,>2 <e, c>2 |
	<a e>2~ \times 2/3 { <a e>8 g g g[ a b ] }
        <c e,>2 <e, c>2 | <f a,>4. f8 e4 d |
	<a' f>2.. b16 a | <g b,>1 :|
      }
    }

    \new Staff {
      \clef bass
      \relative c \new Voice {
	\stemDown
        \partial 2 { s2 } |
	<c g'>4 c8[ c] <a e'>4 a8[ a] |
	<f c'>8 f f f <g d'>4 g |
	<c g'>4 c8[ c] <a e'>4 a8[ a] | 
      }
    }
  >>
  \layout { }
  \midi { }
}

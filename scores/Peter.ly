% Score for Delia Derbyshire's score "Peter" in her papers for
% "The Legend of Hell House".
%
%	Martin Guy <martinwguy@gmail.com>, Febuary 2017.

\version "2.18.2"

\header {
  title = "Peter"
  composer = "Delia Derbyshire"
  subtitle = "1973"
  tagline = "Reconstructed from Delia's score DD170314. See http://wikidelia.net/wiki/Peter"
}
    \defineBarLine "|" #'("||" "" "|")

\score {
  <<
    \new Staff {
      \clef treble
      \relative c'' \new Voice {
        \time 3/4
	\key bes \major
	\stemUp
	r2. | bes2 c4 | d d a | g2 a4 | bes bes ees, | r2. |
	f'4 ees d | f2 c4 | bes2 c4 | d d a | g2 a4 | bes bes f | ees f g | g2 d4 |
	c f2 | c4 f2 | bes,2. |
	% line 3
	d'4 f g8 f | g4 a8 bes d,4 | g8 f ees2 | ees ees4 | c2 g'8 f | a2.~ | a2. | bes2.
	% Change to three sharps
	\key a \major   % or fis \minor
	\stemDown
	cis,2 d4 | e e b | \stemUp a2 b4 | cis cis gis~ | gis fis2 | a4 fis2 | \stemDown cis' e4 | fis e fis | gis a cis, | cis fis e |
	d d d | cis4. b | fis'4 e2 | gis4 a2 |
	% Change to five sharps F C G D A
	\key b \major
	r2. b,2 cis4 | dis dis ais | gis2 ais4 | b b fis ~ | fis e2 | gis4 e2 | gis4 dis2 | b'2 dis4 | e dis e | fis gis b, | b e dis | fis gis b, |
	b e dis | cis cis cis | b4. ais | e'4 dis2 | fis4 gis2 ||
      }
    }

    \new Staff {
      \clef bass
      \relative c \new Voice {
        \time 3/4
	\key bes \major
	\stemDown
	bes8  f' bes d bes f | r2. | 
	bes,8 f' bes d bes f | r2. | 
	f,8 c' f a f c | r2. | 
	f,8 c' f a f c |
	% 8
	bes  f' bes d bes f | bes, f' bes d bes f |
	bes, f' bes ees bes f | bes, f' bes ees bes f |
	% 12
	f, c' f a f c | f, c' f a f c |
	bes f' bes d bes f | bes, f' bes d bes f |
	bes, f' bes ees bes f | bes, f' bes ees bes f |
	% 18
	f, c' f a f c | f, c' f a f c |
	% 22
	bes  f' bes d bes f | bes, f' bes d bes f |
	bes, f' bes ees bes f | r2.*2 | f,8 c' f a f c |

	% Change to three sharps
	\key a \major   % or fis \minor
	r2. * 14

	% Change to five sharps
	\key b \major
	b8 fis' b dis b fis | b,8 fis' b dis b fis |
	b,8 fis' b e b fis | r2. |
	fis,8 cis' fis ais fis cis | r2. |
	b8 fis' b dis b fis | r2. |
	b,8 fis' b e b fis | r2. |
	fis,8 cis' fis ais fis cis | r2. |
	b,8 fis' b dis b fis |
	% new line in manuscript
	r2. | b,8 fis' b e b fis | b,8 fis' b e b fis |
	fis, cis' fis ais fis cis | fis, cis' fis ais fis cis ||
      }
    }
  >>
  \layout { }
  \midi { }
}

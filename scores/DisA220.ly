% This is the Lilypond source for Delia Derbyshire's score marked only
% "D = A220", % created by Martin Guy <martinwguy@gmail.com> 2021-07-02.
% For further info see http://wikidelia.net/wiki/D_=_A220

% Using a tempo of 23 instead of Delia's 23.077 (2.6s) gives the piece a length
% of 6'56" instead of Delia's 6'50". See "\tempo" at the end of the file.

\version "2.19"

\header {
 title = "D = A220"
 composer = "Delia Derbyshire"
 tagline = "Typeset from Delia's score with Lilypond by Martin Guy. See http://wikidelia-net/wiki/D_=_A220"
}

global = {
  \key g \minor   % Key signature with C D Eb A Bb. It's not in G minor.
}

\layout {
  \context {
    \Voice
    \consists "Horizontal_bracket_engraver"
    \override HorizontalBracket.direction = #UP
  }
}

Melody = \new Voice \relative c' {
  | % A (24)
  \time 24/4
  \mark "A"
  %{1:4=4%}	a'1^\markup { \box 1 }
  \once\override HorizontalBracketText.text = \markup { \box 2 }
  %{2:23=5%}	a2\startGroup d,2.\stopGroup
  \once\override HorizontalBracketText.text = \markup { \box 3 }
  %{3:1113=6%}	a'4\startGroup bes a d,2.\stopGroup
  \once\override HorizontalBracketText.text = \markup { \box 5 }
  %{5:11124=9%}	a'4\startGroup bes a ees2 d1\stopGroup

  | % B (20)
  \time 20/4
  \mark "B"
  \once\override HorizontalBracketText.text = \markup { \box 2 }
  %{2:23=5%}	a'2\startGroup d,2.\stopGroup
  \once\override HorizontalBracketText.text = \markup { \box 4 }
  %{4:1113=6%}	a'4\startGroup bes a ees2.\stopGroup
  \once\override HorizontalBracketText.text = \markup { \box 6 }
  %{6:111114=9%}a4\startGroup bes a ees d c1\stopGroup
  % Last two note lengths are unclear but must add up to 5.

  | % C (24)
  \time 24/4
  \mark "C"
  \once\override HorizontalBracketText.text = \markup { \box 2 }
  %{2:23=5%}	a'2\startGroup d,2.\stopGroup
  \once\override HorizontalBracketText.text = \markup { \box 3 }
  %{3:1113=6%}	a'4\startGroup bes a d,2.\stopGroup
  \once\override HorizontalBracketText.text = \markup { \box 7 }
  %{7:11123=8%}	a'4\startGroup bes a c2 a2.\stopGroup
  \once\override HorizontalBracketText.text = \markup { \box 2 }
  %{2:23=5%}	a2\startGroup d,2.\stopGroup

  | % D (34)
  \time 34/4
  \mark "D"
  \once\override HorizontalBracketText.text = \markup { \box 2 }
  %{2:33=6%}	a'2.\startGroup d,2.\stopGroup
  \once\override HorizontalBracketText.text = \markup { \box 3 }
  %{3:2123=8%}	a'2\startGroup bes4 a2 d,2.\stopGroup
  \once\override HorizontalBracketText.text = \markup { \box 4 }
  %{4:2314=10%}	a'2\startGroup bes2. a4 ees1\stopGroup
  \once\override HorizontalBracketText.text = \markup { \box 3 }
  %{3:2224=10%}	a2\startGroup bes2 a2 d,1\stopGroup

  | % E (29)
  \time 29/4
  \mark "E"
  \once\override HorizontalBracketText.text = \markup { \box 2 }
  %{2:34=7%}	a'2.\startGroup d,1\stopGroup
  \once\override HorizontalBracketText.text = \markup { \box 5 }
  %{5:22234=13%}a'2\startGroup bes a ees2. d1\stopGroup
  \once\override HorizontalBracketText.text = \markup { \box 3 }
  %{3:1224=9%}	a'4\startGroup bes2 a2 d,1\stopGroup

  | % F (27)
  \time 27/4
  \mark "F"
  \once\override HorizontalBracketText.text = \markup { \box 2 }
  %{2:22=4%}	a'2\startGroup d,\stopGroup
  \once\override HorizontalBracketText.text = \markup { \box 7 }
  %{7:11133=9%}	a'4\startGroup bes a c2. a2.\stopGroup
  \once\override HorizontalBracketText.text = \markup { \box 8 }
  %{8:12122114=14%} a4\startGroup bes2 a4 c2 a2 ees4 d c1\stopGroup
  |
}

\paper {
  % Don't indent the first line of the score
  indent = #0
}

\score {
 \new Staff {
  \global
  \clef treble
  \omit Staff.TimeSignature
  % Set tempo for MIDI output but don't include it in the printed score
  % A single-length note (1), which we represent with a crochet, is 2.6 seconds
  % of which there are 23.077 in a minute. Using 23 gives a total length of
  % 6'56" instead of Delia's 6'50" (in fact, 158 x 2.6s = 410.8s = 6'50.8")
  \set Score.tempoHideNote = ##t
  \tempo 4=23

  \new Voice { \Melody }
 }
 \midi {}
 \layout {}
}

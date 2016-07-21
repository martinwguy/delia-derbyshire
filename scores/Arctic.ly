% This is the Lilypond source for score fragment "Arctic" by Delia Derbyshire
% created by Martin Guy <martinwguy@gmail.com> on 6th June 2016.
% For further info see http://wikidelia.net/wiki/Arctic

\version "2.16.2"

\header {
 title = "Arctic"
 composer = "Delia Derbyshire"
 tagline = "Typeset from Delia's score with Lilypond by Martin Guy, 6th June 2016. See http://wikidelia-net/wiki/Arctic"
}

global = {
  % Don't print the time signature, as there isn't one.
  \override Staff.TimeSignature.stencil = ##f
  % Print accidentals on all sharp/flat notes and nothing on naturals.
  % This seems to be the style in which Delia wrote the score.
  \accidentalStyle forget
  \key c \major
}

Melody = \new Voice \relative c'' {
  \time 21/1
  \slurUp
  gis1( fis)
  gis( fis d')
  gis,( fis e' d)
  gis,( fis e' d ais fis e d)
  fis gis d' ais
  \time 1/1
  s1
  \time 30/1
  aes' b,, bes'' cis,, b'' d,, cis'' e,, d'' f,, e'' g,, f'' aes,,
  \ottava #1
  g'' bes,, aes'' b,, bes'' cis,, b'' d,, cis'' e,, d'' f,, e'' g,, f'' aes,,
  \ottava #0
  \time 4/1
  <b,, f' cis' g'> <bes e b' f'> <cis g' d' aes'> <d aes' e' bes'>
  \bar "||"
  <d aes' des ees> <b f' bes des> <bes e aes b> <cis g' b d>
  \bar "||"
  <des f bes e> <b e aes d> <bes d g des'> <aes des f b>

}

Bass = \new Voice \relative c, {
  \time 21/1
  <c g' c g'>1*21
  \time 1/1
  <des f bes f'>1
  \time 30/1
  <c g' c g'>1*30
  \time 4/1
  s1*4
  s1*4
  s1*4
}

\paper {
  % Don't indent the first line of the score
  indent = #0
}

\markup { Note: All accidentals are printed and do not carry forward to the following notes.  }

\score {
  \new PianoStaff
  <<
   % No curly bracket at the start of the staves, thank you
   \set GrandStaff.systemStartDelimiter = #'SystemStartBar

   \new Staff {
    \global
    \clef treble
    \new Voice { \Melody }
   }

   % Bass staff of entire piece
   \new Staff {
    \global
    \clef bass
    \new Voice { \Bass }
   }
  >>
 \midi {}
 \layout {}
}

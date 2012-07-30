% This is the lilypond source file for "Le Pont Mirabeau" by Delia Derbyshire,
% created by Martin Guy <martinwguy@gmail.com>, November 2011 from the
% scores in her papers.
% For info on this language and the program to convert it to PDF and MIDI files
%   see http://lilypond.org
% For further info on this piece of music
%   see http://wiki.delia-derbyshire.net/index.php?title=Le_Pont_Mirabeau

\version "2.14.2"

verseImelody = \relative c' {
  \stemUp \autoBeamOff
  c='4 d e f g8 a8 g4 ~ g2 d4 e2.
  \stemDown c'4 b \stemUp a \slurDown fis( g8) e c e g4 a b ~ b2.
  c,4 d8 e f g f4 d e c cis2( d dis4 e2.) \break
}
verseIupperbass = \relative c' {
  \stemUp
  c4 c4. b8 a2 b8 c b4 g2 c2.
  a2 c4 c4. \autoBeamOff e,8 \autoBeamOn c e g4 a b ~ b2.
  c='4 c4. b8 a b c4 g8 a b4 a2 f b4 gis2.
}
verseIlowerbass = \relative c' {
  \stemDown 
  c,=4 c2 c4 c2 c4 c2 c2 c4
  f2 f4 e4. \autoBeamOff e8 \autoBeamOn c e g4 a b ~ b2.
  c,4 c2 c4 c2 c4 a2 d2 b4 e2.
}
verseIlyrics = \lyricmode {
  Un- der the Pont Mi- ra- beau __ the Seine
  Flows with our loves must I re- call a- gain __
  Joy al- ways used to fol- low af- ter pain __
}

chorusmelody = \relative c' {
  \stemUp \tieUp \slurUp \autoBeamOff
  d'2\rest c,8. c16 gis'2 a4 ~ a4 d2\rest  d4\rest c,4. c8 fis4( g2) ~
  \break
  g2 b4 b( c) a g2 e4 a f2 d( e4) ~ e2. \bar "||"
}
chorusmelodyb = \relative c' {
  \stemDown \tieDown \autoBeamOff
  c='2\rest c8. c16 e2 f4 ~ f4 c2\rest  d4\rest a'4. f8 e2. ~
  e2 gis4 g!2 d4 d c e f d2 b2 c4 ~ c2.
}
chorusupperbass = \relative c' {
  \stemUp \tieUp	
  g2.\rest c2 c4 ~ c4 c2 c2. c2. c2 c4 c2 c4 c2 c4 d c2 c2 c4 ~ c2.
}
choruslowerbass = \relative c' {
  \stemDown \tieDown
  a,2.\rest f'=4 f f f f f f f f c c c c c f! e2 f4 e2 c4 c c c c c c ~ c2.
}
choruslyrics = \lyricmode {
  Let the night come __ Strike the hour
  The days __ go by while I stand here __
}

verseIImelody = \relative c' {
  \stemUp \autoBeamOff 
  c='4 d e f2 fis4 g8 a8 g4 d dis( e2) |
  \stemDown c'4 b \stemUp a | g2 e4 gis( a) f e8 c d2
  d4 e fis g a8 fis g4 ~ g d f! e2( fis4) ~ fis2. \bar "||"
}
verseIIupperbass = \relative c' {
  \stemUp \tieUp
  c4 c4. b8 a b16 c b4 a8 c b4 b d c2 c4 |
  a2 c4 c4 g c c2 c4 c c8 a b4 |
  d2 c4 b2 c8 a b2. b2 dis4 ~ dis2.
}
verseIIlowerbass = \relative c' {
  \stemDown \tieDown
  c,=4 c2 c4 c2 c4 c2 c2 c4 |
  f2 f4 e2 c4 f2 a4 g2. |
  b2 a4 g2. ~ g2. e2 b'4 ~ b2.
}
verseIIlyrics = \lyricmode {
  Love runs a- way like run- ning wa- ter flows
  Time past is gone can love come back a- gain
  Un- der the Pont Mi- ra- beau __ flows the Seine __
}

% Don't print a header
\header {
  tagline = ""
}
\paper {
  % Don't print page numbers
  printpagenumber = ##f
  % Don't indent the first line of the score
  indent = #0
}
% Don't print bar numbers
\layout {
  \context {
    \Score
    \remove "Bar_number_engraver"
  }
}

\score {
 {
  % "\with..." is necessary to get lyrics above the first line of notes.
  \new PianoStaff \with { \accepts Lyrics }
  <<
   % No curly bracket at the start of the staves, thank you
   \set GrandStaff.systemStartDelimiter = #'SystemStartBar

   % Set lyrics above the score
   \new Lyrics = lyrics {
   }

   % Treble staff of entire piece
   \new Staff {
    % Set tempo for MIDI output but don't include it in the printed score
    \tempo 4=130
    \set Score.tempoHideNote = ##t
    \time 3/4
    \key c \major
    \clef treble

    \mark "VERSE I"
    \new Voice = verseI { \verseImelody }

    \break

    \mark "CHORUS"
    \context Staff <<
     \new Voice = chorus { \chorusmelody }
     \new Voice { \chorusmelodyb }
    >>

    \break

    \mark "VERSE II"
    \new Voice = verseII { \verseIImelody }
   }

   % Bass staff of entire piece
   \new Staff {
    \time 3/4
    \key c \major
    \clef bass

    % VERSE I
    \context Staff <<
     \new Voice { \verseIupperbass }
     \new Voice { \verseIlowerbass }
    >>

    % CHORUS
    \context Staff <<
     \new Voice { \chorusupperbass }
     \new Voice { \choruslowerbass }
    >>

    % VERSE II
    \context Staff <<
     \new Voice { \verseIIupperbass }
     \new Voice { \verseIIlowerbass }
    >>
   }
   \context Lyrics = lyrics \lyricsto verseI  { \verseIlyrics }
   \context Lyrics = lyrics \lyricsto chorus  { \choruslyrics }
   \context Lyrics = lyrics \lyricsto verseII { \verseIIlyrics }
  >>

 }
 \midi {}
 \layout {}
}

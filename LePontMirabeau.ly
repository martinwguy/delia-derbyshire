% This is the lilypond source file for "Le Pont Mirabeau" by Delia Derbyshire,
% created by Martin Guy <martinwguy@gmail.com>, November 2011 from the
% scores in her papers.
% For info on this language and the program to convert it to PDF and MIDI files
%   see http://lilypond.org
% For further info on this piece of music
%   see http://wiki.delia-derbyshire.net/index.php?title=Le_Pont_Mirabeau

\version "2.10"
% Don't print a header
\header {
  tagline = ""
}
% Don't print page numbers
\paper {
  printpagenumber = ##f
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
  \new PianoStaff  \with { \accepts Lyrics }
  <<
   % No curly bracket at the start of the staves, thank you
   \set GrandStaff.systemStartDelimiter = #'SystemStartBar
   % Set tempo for MIDI output but don't include it in the printed score
   \tempo 4=120
   \set Score.tempoHideNote = ##t

   \new Lyrics = lyrics {
    % Set lyric text close to the top of the stave
    \override Lyrics.VerticalAxisGroup #'minimum-Y-extent = #'(-0 . 0)
    s1
   }
   \new Staff {
    \time 3/4
    \key c \major
    \clef treble
    \relative c' {
     \new Voice = "verse1" {
      \autoBeamOff
      c='4 d e f g8 a8 g4 ~ g2 d4 e2.
      \stemDown c'4 b \stemUp a \slurDown fis( g8) e c e g4 a b ~ b2.
      c,4 d8 e f g f4 d e c cis2( d dis4 e2.) \break
     }
     \context Staff <<
      \new Voice = chorus {
       \mark "CHORUS"
       \autoBeamOff \stemUp \tieUp \slurUp
       d'2\rest c,8. c16 gis'2 a4 ~ a4 d2\rest  d4\rest c,4. c8 fis4( g2) ~
        \break
       g2 b4 b( c) a g2 e4 a f2 d( e4) ~ e2.
      }
      \new Voice {
       \autoBeamOff \stemDown \tieDown
       c='2\rest c8. c16 e2 f4 ~ f4 c2\rest  d4\rest a'4. f8 e2. ~
       e2 gis4 g!2 d4 d c e f d2 b2 c4 ~ c2.
      }
     >>
    }
   }
   \new Staff {
    \time 3/4
    \key c \major
    \clef bass
    \relative c' {
     % VERSE 1
     \context Staff <<
      \new Voice {
       \stemUp
       c4 c4. b8 a2 b8 c b4 g2 c2.
       a2 c4 c4. \autoBeamOff e,8 \autoBeamOn c e g4 a b ~ b2.
       c='4 c4. b8 a b c4 g8 a b4 a2 f b4 gis2.
      }
      \new Voice {
       \stemDown
       c,=4 c2 c4 c2 c4 c2 c2 c4
       f2 f4 e4. \autoBeamOff e8 \autoBeamOn c e g4 a b ~ b2.
       c,4 c2 c4 c2 c4 a2 d2 b4 e2.
      }
     >>
     % CHORUS
     \context Staff <<
      \new Voice {
       \stemUp \tieUp
       g2.\rest c2 c4 ~ c4 c2 c2. c2. c2 c4 c2 c4 c2 c4 d c2 c2 c4 ~ c2.
      }
      \new Voice {
       \stemDown \tieDown
       a,2.\rest f'=4 f f f f f f f f c c c c c f! e2 f4 e2 c4 c c c c c c ~ c2.
      }
     >>
    }
   }
   \context Lyrics = lyrics \lyricsto "verse1" {
    Un- der the Pont Mi- ra- beau __ the Seine
    Flows with our loves must I re- call a- gain __
    Joy al- ways used to fol- low af- ter pain __
   }
   \context Lyrics = lyrics \lyricsto chorus {
    Let the night come __ Strike the hour
    The days __ go by while I stand here __
   }
  >>

  }
  \midi {}
  \layout {}
}

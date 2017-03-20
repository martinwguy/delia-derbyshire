\version "2.12.1"

\header {
 title = "Science All Around - Sound"
 subtitle = "score fragment dd081955"
 composer = "Delia Derbyshire"
 tagline = "Reconstructed from Delia's score and typeset in Lilypond by Martin Guy in 2012. See http://wikidelia.net/wiki/DD081955"
}

\score {
  \new PianoStaff
  <<
   % No curly bracket at the start of the staves, thank you
   \set GrandStaff.systemStartDelimiter = #'SystemStartBar
   \set Score.tempoHideNote = ##t

   \new Staff {
    % Set tempo for MIDI output but don't include it in the printed score
    \tempo 4=90
    \time 8/4
    \clef treble
    \relative c'' {
     \new Voice {
      \ottava #1 \stemUp
      a'16 f' g c, g4  a16 f' g c, c'4
      f,16 c' ees, c f4  g,16 c f c g'4
      % ees's may be natural
      g16 c, ees! g, ees!4  ees'!16 g, c ees,! c4
      c'16 ees, g c, ees' g, c ees,! c8 g' ees'! c'
     }
    }
   }
   \new Staff {
    \time 8/4
    \clef treble
    \relative c'' {
     \new Voice {
      s1*3
      \ottava #0
      c16 g e c ees g c e g ees c g c e g c
      c,,='2
     }
    }
   }
   %{ \new Staff {
    \time 8/4
    \clef treble
    \relative c'' {
     \new Voice {
      \ottava #1
      e'2 fis, gis d | s1*2
     }
    }
   %}
   %{ \new Staff {
    \time 8/4
    \clef bass
    \relative c {
     \new Voice {
      s1*2 | b2 fis'4 d' d1
     }
    }
   %}
  >>

 \layout { indent = #0 }
 \midi { }
}

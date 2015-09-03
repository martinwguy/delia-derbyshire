% Score for Delia Derbyshire's "Moogies Bloogies"
% Created by inspection of a log-frequenxy-axes spectrogram

\version "2.16.2"

\header {
 title = "Moogies Bloogies"
 composer = "Delia Derbyshire"
}

\score {
 \new PianoStaff
 <<
  % Spangles and bloopy swoops
  \new Staff {
   \set midiInstrument = #"glockenspiel"
   \time 6/8
   \tempo 8=150
   \clef treble

   \relative c'' {
    \new Voice {
     \stemUp
  % Spangles
     r16 \times 8/7 { g64     d' g d' g d' g } r16 r8  r8 r r |
     r16 \times 8/7 { g,,,64  d' g d' g d' g } r16 r8  r8 r r |
     r16 \times 8/7 { g,,,,32 d' g d' g d' g } r16     r8 r r |
     r2. |
  % Bloopy swoops
     r16 g,,, c g' c g' c8 r4 | r2. |
     r16 g,,  c g' c g' c8 r4 | r2. |
     r16 g,,  c g' c g' c8 r4 | r2. |
     \time 4/4
     r1
    }
   }
  }

  % Descant
  \new Staff {
   \set midiInstrument = #"flute"
   \time 6/8
   \tempo 8=150
   \clef treble

   \relative c''' {
    \new Voice {
     \stemUp
     r2. |
     r2. |
     r2. |
     r2. |
     \ottava #1
     e4 c4 f8 aes | e2. | 
     e4 c4 f8 aes | g4. r4. |
     e4 c4 f8 aes | e2 r8 ees16 aes, | 
     \time 4/4
    }
   }
  }

  % Melody
  \new Staff {
   \set midiInstrument = #"reed organ"
   \time 6/8
   \tempo 8=150
   \clef treble

   \relative c'' {
    \new Voice {
     \stemUp
     r2. |
     r2. |
     r2. |
     r2. |
     r16 g  a b c8 r aes' des, | g c, r c 8r r |
     r16 g  a b c8 r aes' des, | b'2. |
     r16 g, a b c8 r aes' des, | g c, r c 8r r |
     \time 4/4
     r1 |
    }
   }
  }

  % Bass
  \new Staff {
   \set midiInstrument = #"oboe"
   \time 6/8
   \clef bass
   \relative c {
    \new Voice {
     g8 r aes g r aes | g r aes g r aes | g r aes g r aes | g r aes g r g |
     c8 r aes des r f | c r r c r g | c r aes des r f | g r r g r g, |
     c8 r aes des r f | c r r c r aes |
     \time 4/4
     g8 r aes r g r aes r | g r aes r g r aes g |
     \time 11/16
     c8 r c r8. g8 | c8 r c r8. g8 |
     c8 r c r8. g8 | c8 r c r8. g8 |
    }
   }
  }
 >>

 % Delia doesn't indent the first line of scores, so neither do we
 \layout { indent = #0 }
 \midi { }
}

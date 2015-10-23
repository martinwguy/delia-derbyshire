% Score for Delia Derbyshire's "Moogies Bloogies"
% Created by inspection of a log-frequenxy-axes spectrogram

\version "2.16.2"

\header {
 title = "Moogies Bloogies"
 tagline = "Scored in LilyPond for piano, flute and piccolo by Martin Guy, September 2015."
 composer = "Delia Derbyshire"
}

\score {
 <<
  % Descant
  \new Staff \with {
   midiInstrument = #"flute"
   instrumentName = #"Piccolo"
  } {
   \time 6/8
   \tempo 8=150
   \clef treble
   \override Staff.Rest #'style = #'classical
   \set Score.markFormatter = #format-mark-box-alphabet

   \relative c''' {
    \new Voice {
     \stemUp
     \mark \default
     R2.*4 |
     \mark \default
     \ottava #1
     e4\p c4 f8 aes | e2. | 
     e4 c4 f8 aes | g4. r4. |
     e4 c4 f8 aes | e2 r8 
       
       \set Voice.fontSize = #-4
                          ees16 aes,~_\markup { \center-align \italic "pre-echo" } | 
       \unset Voice.fontSize
     \time 4/4
     <<
      {
       % Pre-echo must come first so that the aes ties work
       \stemUp \tupletUp \dynamicUp
       \mark \default
       \set Voice.fontSize = #-4
       \times 2/3 { aes16\p
                            d8  g,    s8   ees'8 s   aes,16~ }
       \times 2/3 { aes16   d8  g,    s8   ees'8 s   aes,16~ } |
       \times 2/3 { aes16   d8  g,    s8   ees'8 s   aes,8 }
       \times 2/3 {         d8  g,    s8   ees'8 s      s16  }
       \unset Voice.fontSize
      }
      \relative c''' \new Voice {
       % Melody
       \stemDown \tupletDown
       \times 2/3 { r8\f      aes8[ d8 g,8]  r8  ees'8      }
       \times 2/3 { r8       aes,8[ d8 g,8]  r8  ees'8      } |
       \times 2/3 { r8       aes,8[ d8 g,8]  r8  ees'8      }
       \times 2/3 { r8       aes,8[ d8 g,8]  r8     r8      }
      }
     >>

     %\times 2/3 { r16 d aes g d'8 g,16 ees'8. ees16 aes, }
     %\times 2/3 { r16 d aes g d'8 g,16 ees'8. ees16 aes, } |
     %\times 2/3 { r16 d aes g d'8 g,16 ees'8. ees16 aes, }
     %\times 2/3 { r16 d aes g d'8 g,16 ees'8. r8 } |

     \ottava #0
     \time 11/16
     \mark \default
     r4 r4.. | r4 r4.. | r4 r4.. | r4 r4.. |
     % [E]
     \time 6/8
     R2.*2
  }}}

  % Melody
  \new Staff \with {
   midiInstrument = #"flute"
   instrumentName = #"Flute"
  } {
   \time 6/8
   \tempo 8=150
   \clef treble

   % Delia writes backward-7 crochet rests and so do we.
   \override Staff.Rest #'style = #'classical

   \relative c'' {
    \new Voice {
     \stemUp
     R2.*4 |
     r16\f g a b c r r8 aes' des, | g c, r c r r |
     r16 g   a b c r r8 aes' des, | b'2. |
     r16 g,  a b c r r8 aes' des, | g c, r c r r |
     \time 4/4
     R1*2 |
     \time 11/16
     { r16 g[ a b c] r r16. c16 r16. r16 } |
     { r16 g[ a b c] r r16. c16 r16. r16 } |
     { r16 g[ a b c] r r16. c16 r16. r16 } |
     { r16 g[ a b c] r r16. c16 r16. r16 } |
     % [E]
     \time 6/8
     { r16^"Last time only" g[ a b c] r r8 r4 } |
     R2.
  }}}

  \new PianoStaff \with {
   midiInstrument = #"acoustic grand"
   instrumentName = #"Piano"
  } << \new Voice {
   % Upward rushes
   \time 6/8
   \tempo 8=150
   \clef treble

   % Delia writes backward-7 crochet rests and so do we.
   \override Staff.Rest #'style = #'classical

   \relative c'' {
    \new Voice {
     \stemUp
     r16 \times 8/7 { g64\f   d' g d' g d' g } r16 r2  |
     r16 \times 8/7 { g,,,64  d' g d' g d' g } r16 r2  |
     r16 \times 8/7 { g,,,,32 d' g d' g d' g } r16 r4. |
     R2. \bar "|:"
     r16 g,,,\p c g' c g' c8 r4 | R2. |
     r16 g,,    c g' c g' c8 r4 | R2. |
     r16 g,,    c g' c g' c8 r4 | R2. |
     \time 4/4
     R1*2 |
     \time 11/16
     r4 r4.. | r4 r4.. | r4 r4.. | r4 r4.. \bar ":|"
     % [E]
     \mark \default
     \time 6/8
     r16 g,, c g' c g' c g,, c g' c g' |
       c g,, c g' c g' c g,, c g' c g' |
  }}}


  % Bass
  \new Voice {
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
     % [E]
     \time 6/8
     c r r r r g \bar "|:" c r g c r g \bar ":|"
  }}}
  >>
 >>

 \layout { }
 \midi { }
}

% Sequence: A B C D - B C D - A B C D - B E - 8 bars of E - B C D - B C - 4 bars of E (fade)

\markup {
 Sequence: \box "A" \box "B" \box "C" \box "D" - \box "B" \box "C" \box "D" - \box "A" \box "B" \box "C" \box "D" - \box "B" - 8 bars of \box "E" - \box "B" \box "C" \box "D" - \box "B" \box "C" - 2 bars of \box "E" (fade)
}

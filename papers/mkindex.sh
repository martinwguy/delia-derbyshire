#! /bin/sh

# Make index.html from the foto file names.
# Originals are in maxi/ while the 100-pixel-high thumbnails are in mini/
#
# The HTML output is dumped in "index.html" and consists of a header
# (read from header.html), a long sequence of thumbnail images and a
# footer (from footer.html).
# Each thumbnail image here has a label such as "dd012345" and
# clicking a thumbnail takes you to an HTML wrapper html/dd012345.html"
# around the maximum-size version of the image  in "maxi/dd012345.jpg".
# Each wrapper has crude "previous" and "next" links and a link back to
# the images' thumbnail in index.html.
#
# The main part of this file is a crude language to insert a title or a
# line of text before the image it indexes. These titles have labels of
# the form dd012345_title, which are linked to in the short index
# contained in "header.html".
#
#	Martin Guy <martinwguy@gmail.com>, May 2010

for mini in thumb toe
do
  {
    cat header.html
    echo '<P>'

    for a in `ls maxi`
    do
	t= n=
	case "`basename $a .jpg | sed 's/dd//'`" in
#==============================================================================
072610) n=2 t='<A NAME=RedFolder>Red folder</A>';;
072615) n=3 t='Radiophonic Workshop: Television and Radio Commitments 1970';;
072951) t='Various RW papers';;
073807) t='First draft of "<A HREF="#FacilitiesAvailable">Radiophonic Workshop: Facilities available</A>" document';;
074011) t='-';;

074801) n=2 t='<A NAME=ConcertFolder>Folder "Concert"</A> (of Electronic Music, Bagnor, 10 Sept 1966)';;
075552) t='Draft of concert programme - see also <A HREF="#ConcertOfElectronicMusicProgramme">the final version</A>';;

080039) n=2 t='<A NAME=GincUDPFolder>Folder "G. inc. U.D.P."</A> (Unit Delta Plus)';;
# DATES done to 080404

080520) n=2 t='<A NAME=Medea>"Medea"</A>';;

080922) n=2 t='<A NAME=LivingWorld>Folder "The Living World"</A>';;

081548) n=2 t='<A NAME=BrownFolder>Brown Folder</A>';;
081603) n=3 t='<A NAME=Athos>Athos films</A>: "Science All Around" or "What'\''s going to happen next?"';;

082103) n=2 t='<A NAME=BlueDeliaFolder>Blue folder "Delia"</A>';;
082346) n=3 t='<A NAME=Brighton>Brighton Festival / Hornsey College of Arts</A>';;

082851) t='Left pocket';;
# SPIN /
# WAY OUT /
# NEWLEY /
# LIVERPOOL /
# BRIGHTON /
# ICI FASHION SHOW /
# PHILIPS /
# WORK
083001) t='<A NAME=Lacey>Brochure for "The first exhibition of automata and humanoids by Bruce Lacey, June 1963"</A>';;
083229) n=3 t='<A NAME=Newley>"Newley"</A>';;
084055) n=3 t='<A NAME=Macbeth>Macbeth/RSC</A>, 15 August 1967';;
084547) n=3 t='<A NAME=Work>"Work is a Four Letter Work"</A> - see also <A HREF="#WorkScores">dd092350</A>';;
085921) n=3 t='<A NAME=Philips>"Philips"</A>';;
090240) n=3 t='<A NAME=ICIFashionShow>ICI fashion show</A>, 6 April 1967';;
090924) n=3 t='<A NAME=Liverpool>"Liverpool"</A>';;
091127) n=3 t='<A NAME=WayOutInPiccadilly>"Way out in Piccadilly"</A>, 24 October 1966';;
091435) t='Newspaper clipping: Paul McCartney';;
091653) n=3 t='<A NAME=Spin>"Spin"</A>,
	for a Proctor and Gamble washing powder advert, 1966.';;

092314) t='Right pocket';;
# SEARCHING / 
# CLOUD / 
# BUSINESS OF GOOD GOVERNMENT / 
# BRING BACK : LONDON LEMONS / 
# BANK : TIGER TALKS / 
# COLOURED WALL / 
# WHO IS / 
# LEAR 
092350) n=3 t='<A NAME=WorkScores>"Work is a Four Letter Word" scores</A> - see also <A HREF="#Work">dd084547</A>';;
092635) n=3 t='<A NAME=Lear>"Lear"</A>';;
092748) n=3 t='<A NAME=OnTheLevel>"On The Level"</A> - see also <A HREF="#OnTheLevel2">dd094231</A>';;
092820) n=3 t='<A NAME=Searching>"Searching"</A>, a 30-second score by Sandy Brown for an advert for Bristow'\''s Lanalin Shampoo, realised by Delia 1-10 Feb 1966';;
093652) t='Royal Court Theatre, Liverpool programme for "On The Level"
	<BR>Martin Landau, Brian Epstein, Produced by Wendy Toye, Music by Ron Grainer';;
093953) n=3 t='<A NAME=Cloud>"Cloud"</A>';;
094231) n=3 t='<A NAME=OnTheLevel2>"On The Level"</A> - see also <A HREF="#OnTheLevel">dd092748</A>';;
095538) n=3 t='<A NAME=LondonLemons>"London Lemons"</A>';;
095849) n=3 t='<A NAME=BusinessOfGoodGovernment>"The Business of Good Government"</A>';;
100117) n=3 t='<A NAME=BringBack>"Bring Back"</A>, dated 9 Apr 1968';;
100247) n=3 t='<A NAME=SaveTheTiger>"Save the Tiger"</A> jingle for Esso';;
100325) n=3 t='<A NAME=Bank>"Bank"</A>: Signature tune for Bank of Canada, 20 November 1967';;
100603) n=3 t='<A NAME=TigerTalks>"Tiger talks"</A> for an Esso advert';;
100824) n=3 t='Sound track for <A NAME=ColouredWall>"The Coloured Wall"</A>
	(Association of Electrical Engineers exhibition, 1968)';;
101317) n=3 t='<A NAME=WhoIs>"Who Is"</A> series signature for Allan King Associates, Toronto, 22 March 1968';;

101712) n=2 t='<A NAME=PoetsInPrison>"Poets in Prison"</A>';;
104538) n=2 t='<A NAME=FilingFolder>Folder "Filing"</A>';;
# Left pocket
104702) n=3 t='<A NAME=YourHiddenDreams>"Your Hidden Dreams"</A> manuscript -
		see also <A HREF="#YourHiddenDreams2">dd155714</A>';;
104749) n=3 t='<A NAME=GameOfLoving>"Game of Loving"</A> manuscript and foreign-language texts';;
104912) n=3 t='<A NAME=Clothes>"Clothes"</A> manuscript';;
104935) n=3 t='Bass Cpt. to Undressing - see also <A HREF="#MusicToUndressTo">dd155635</A>';;
104942) t='-';;
# Right pocket
105241) n=3 t='<A NAME=Paolozzi>"Paolozzi ART AND DESIGN / BBC radiovision / NOTES, AUTUMN 1971"</A>';;
105820) n=3 t='Envelope "DD307": Newspaper clippings for various works';;
110623) n=3 t='<A NAME=Orpheus>"Orpheus"</A>, a play by Ted Hughes, 18 Nov 1970 - 19 Jan 1971. See also <A HREF="#OrpheusVCS3">its VCS3 dope sheets</A>';;
111029) n=3 t='<A NAME="MagicBox5-11">Magic Box, sheets 5 to 11</A> (see also <A HREF="#MagicBox">sheets 1-4</A>)';;
111416) n=3 t='<A NAME=HungryGap>"Hungry Gap"</A>';;
111429) t='-';;
111931) n=3 t='<A NAME=MagicBox>Magic Box, sheets 1 to 4</A> (see also <A HREF="#MagicBox5-11">sheets 5-11</A>)';;
112125) n=3 t='<A NAME=HereComeTheFleasLyrics>Here Come The Fleas</A> lyrics';;
112200) t='-';;
112418) n=3 t='<A NAME=HereComeTheFleas>Here Come The Fleas</A> manuscript';;
112448) t='-';;

112541) n=2 t='Folder "<A NAME=RorateCoeliFolder>Rorate coeli</A>"';;

113011) n=2 t='Folder "<A NAME=RWFolder>R. W.</A>"';;
113051) n=3 t='<A NAME=InventionsForRadio>"After Life" / "Evenings" / "Amor Dei"</A>';;
113144) n=3 t='<A NAME=ScienceAndHealth>"Science &amp; Health"</A>';;
113240) n=3 t='<A NAME=SilenceMartinis>"Silence" / "Martinis" 6.3.66</A>';;
113349) n=3 t='<A NAME=MusicToMidnight>"19&amp;20.7.63 Light"(?) / "Music to midnight"</A>';;
113547) n=3 t='<A NAME=CoolOnTheOutside>"Cool on the outside, man,
	I'\''m hot on the in (6.IV.62 / 10.IV.62 / 5.2.63)"</A>';;
113707) n=3 t='<A NAME=Michelle>"Michelle"</A> (version of Beatles song)';;
113740) n=3 t='<A NAME=ScienceAndHealth2>Science and Health opening chords</A>';;
113755) t='-';;
113857) n=3 t='<A NAME=YouCanCome>"6.6.64" "You can come - if you like..."</A>';;
113939) n=3 t='<A NAME=Easter64>"Easter 64"</A>';;
114048) n=3 t='<A NAME=Chronicle>"Chronicle 1.2.69"</A> - see also <A HREF="#dd145330">dd145330</A>';;
114117) t='-';;
114144) n=3 t='<A NAME=Delta60-61>"&Delta; 61" / "&Delta; 60"</A>';;
114447) t='-';;
115027) n=3 t='<A NAME=Radio2>"Radio Two"</A>';;
115153) n=3 t='<A NAME=AnythingGoes2>"Anything Goes [2] &amp;/or Trend"</A>';;
115202) t='-';;
115254) n=3 t='<A NAME=LookOut>"Look Out"</A>';;
115331) n=3 t='<A NAME=FirstTimeOut>"First Time Out"</A>';;
115351) n=3 t='<A NAME=RadioSolent>"Radio Solent"</A>';;
115438) t='-';;
115500) n=3 t='<A NAME=EnvironmentalStudies>"Environmental Studies" / "Arctic?"</A>';;
115550) n=3 t='<A NAME=PontMirabeau>"Pont Mirabeau"</A>';;
120020) n=3 t='<A NAME=AnythingGoes1>Anything Goes [1]</A>';;
120210) n=3 t='<A NAME=BBC1Ident>BBC1 Ident</A>';;
120242) n=3 t='<A NAME=JoanElliotCalls>Joan Elliot Calls (June 68)</A>';;
120343) n=3 t='<A NAME=RadioLeeds>Radio Leeds (5.5.68)</A>';;
121406) t='-';;
121439) n=3 t='<A NAME=ScarfeViolence>"Scarfe: Violence -3.68-"</A>';;
121841) t='-';;
122454) n=3 t='<A NAME=NU>"N.U." / "Trademark Britain"</A>';;
122728) n=3 t='<A NAME=TowardsTomorrow>"Towards Tomorrow"</A>';;
122833) n=3 t='<A NAME=Ape>"Ape"</A>';;
122929) t='-';;
122954) n=3 t='<A NAME=SFMunich>"S.F." / "Munich"</A>';;
123106) n=3 t='<A NAME=MathsProg>"Maths Prog 3.67"</A>';;
123409) t='-';;
124722) n=3 t='<A NAME=PotAuFeu>11/8 rhythm used in Pot Au Feu</A>';;
124753) n=3 t='<A NAME=Finnish>"Finnish"</A>';;

124901) n=2 t='<A NAME=CurrentFolder>Folder "Current"</A>';;
125016) n=3 t='<A NAME=IEE100>I.E.E. 100, 21 April 1971</A>';;
125416) t='"Dr Who + Peladon"';;
125550) t='"Radiophonic Workshop in Concert" script';;
125824) t='Woman'\''s Guardian article 3 Sept 1970: "Dial a tune" by Kirsten Cubitt';;
125959) t='Doctor Who: The Sea Devils/The Curse of Peladon';;
130311) t='-';;
130754) t='Logistics for IEE100 "Radiophonic Workshop in Concert", 3rd May 1971';;
130959) t='Eduardo Paolozzi, Autumn 1971';;
131353) n=3 t='<A NAME=FOLFanfares>Two fanfares for BBC Festival of Light Music, 5th June 1971</A>';;
131736) t='Omnibus about Goya, 25.2.71';;
131758) t='-';;
131844) n=3 t='<A NAME=MacbethMaguire>Macbeth (produced by P.P.Maguire)</A>';;
133825) t='Brochures from O.R.T.F., Paris / Pierre Schaffer 1966-68';;
134239) t='Two extracts from "The Long Polar Walk" on TRW 7463 are used in
	film documentary "On The Rim - Spitzbergen", 28 Oct 1971';;
134251) t='"I Measured The Skies" biography (Kepler), 10 Mar 1970';;
134310) t='Brochure from Studio di Fonologia Musicale di Firenze: Esperienze di Computer Music, Jan 1969';;
134512) t='Brochure: "Peter Logan'\''s experiments towards mechnical ballet",
	3-9 Mar 1969';;
134709) t='Various notes for Kaleidophon';;
135239) n=3 t='The Dark Ages';;

135506) n=2 t='<A NAME=MacbethGreenwich>Macbeth (Greenwich Theatre, 18 Feb 1971)</A>';;

141044) n=2 t='BBC "Clanfolk" magazine review of "An Electric Storm" album';;

141522) n=2 t='<A NAME=CurrentDDFolder>Folder "Current DD"</A>';;
141542) t='Letters re "The Bagman" or "The Impromptu of Muswell Hill" Italia Prize 1970, "The Dreams" and more';;

141940) n=2 t='<A NAME=PinkDeliaFolder>Pink folder "Delia"</A>';;
142121) n=3 t='<A NAME=TutenkhamunsEgypt>Tutenhamun'\''s Egypt, 4/1972</A>';;
142943) n=3 t='<A NAME=ThisQuestionOfPressures>This Question Of Pressures</A>';;
143213) n=3 t='<A NAME=OFatWhiteWoman>O Fat White Woman (Play For Today, 10/8/71)</A>';;
143650) t='-';;
144232) n=3 t='<A NAME=RedClipboard>Red Clipboard "Alan and Clarry"</A>';;
145330) t='Chronicle: Pompeii, final dubbing script';;

145456) n=2 t='<A NAME=TRW7598Folder>Folder "TRW 7598: Wildlife Safari to the Argentine, 1972"</A>';;
145530) n=3 t='<A NAME=WildlifeSafariToArgentina>Wildlife Safari to Argentina</A>, early 1972';;
150219) t='-';;
150337) t='Draft of Letter re Erik Satie';;
150417) t='Bundle "Atwan Layton"';;
150510) n=3 t='<A NAME=Electrosonic>Electrosonic</A>';;
150657) n=3 t='<A NAME=EngineeringCraftStudies>Engineering Craft Studies</A>';;
151003) n=3 t='<A NAME=WildlifeSafariToSouthernSouthAmerica>Wildlife Safari to Southern South America, 1972</A>';;

151603) n=2 t='<A NAME=TRW6891Folder>Folder "TRW 6891 / Out of the Unknown: The Naked Sun", 1968</A>';;

153216) n=2 t='<A NAME=DD332Folder>Pink Folder "DD 332"</A>';;
153314) n=3 t='<A NAME=HatchEnd>"Hatch End 1154"</A>';;
153341) n=3 t='<A NAME=TheTower>"The Tower" 1964</A>';;
153403) n=3 t='<A NAME=WhenIWasYoung>"When I Was Young"</A>';;
153420) n=3 t='<A NAME=TheCracksman>"The Cracksman"</A>';;
153532) n=3 t='<A NAME=RainMusic>"Ron Grainer - Rain Music"</A>';;
153551) t='-';;
153652) n=3 t='<A NAME=TheCracksmanLetter>"The Cracksman (letter)"</A>';;
153703) n=3 t='<A NAME=BB>BB (Inventions for Radio?)</A>';;
154217) n=3 t='<A NAME=LastYear>"Last Year"</A>';;

154348) n=2 t='<A NAME=DD333Folder>Folder "DD 333"</A>';;
154505) t='<A NAME=ConcertOfElectronicMusicProgramme>Unit Delta Plus: Concert of Electronic Music programme</A> - see also <A HREF="#ConcertFolder">"Concert" folder</A>';;
154536) n=3 t='<A NAME=LivingLessons>"Living Lessons"</A>';;
154553) t='-';;
154626) t='Radio Newsreel (see <A HREF="#RadioNewsreel">Radio Newsreel</A>)';;
154725) n=3 t='<A NAME=MacbethVCS3>VCS3 dope sheets for Macbeth</A>';;
154843) t='Time Out review of "An Electric Storm" album';;
155044) t='<A NAME=FacilitiesAvailable>BBC Radiophonic Workshop: "Facilities available in experimental music studios" and "Catalogue of Works 1957-1963"</A>';;
155222) t='Description of Doctor Who theme';;
155317) t='-';;
155455) n=3 t='<A NAME=CHCl3>Manuscript including "CHCl3 theme". CHCl<SMALL><SUB>3</SUB></SMALL> is Chloroform</A>';;
155616) t='-';;
155635) n=3 t='<A NAME=MusicToUndressTo>"Music To Undress To"</A> - see also <A HREF="#dd104935">dd104935</A>';;
155649) n=3 t='<A NAME=ClassicalClassical>"Classical - Classical"</A>';;
155714) n=3 t='<A NAME=YourHiddenDreams2>Your Hidden Dreams</A> -
		see also <A HREF="#YourHiddenDreams">dd104702</A>';;
155744) t='-';;
155903) t='"BBC Engineering Division Monograph, November 1963: Radiophonics in the BBC"';;
160451) t='"The BBC Radiophonic Workshop"';;
160538) t='EMS brochure';;
160759) t='-';;

160926) n=2 t='<A NAME=DD334Folder>Folder "DD 334"</A>';;
160949) n=3 t='<A NAME=ArabicScienceAndIndustry>Arabic Science and Industry</A>, 10 Aug 1962';;
161200) t='-';;
161321) n=3 t='<A NAME=ScienceServesTheArts>"Science Serves The Arts"</A>, July 62';;
161452) t='-';;
161614) t='Summer course at Dartington Hall 11-25 Aug 1962';;
161738) n=3 t='<A NAME=FYinT>"F.Y.in T."</A> (see also <A HREF="html/dd074527.html">dd074527</A>)';;
161912) n=3 t='<A NAME=ClosedPlanet>"Closed Planet"</A>';;
162117) n=3 t='<A NAME=TimeOnOurHands>"Time On Our Hands"</A>';;
162544) t='-';;
163536) n=3 t='<A NAME=OrpheusVCS3>VCS3 dope sheets</A> for
	"<A HREF="#Orpheus">Orpheus</A>"';;
163659) n=3 t='<A NAME=EarlyMorning>Early Morning</A>';;
163723) t='-';;
163832) t='Dartington Summer School of Music 1962: General Information';;
163852) t='-';;
163940) n=3 t='<A NAME=RadioNewsreel>Radio Newsreel</A> (see also <A HREF="#dd154626">dd154626</A>)';;

164537) n=2 t='<A NAME=DD335Folder>Folder "DD 335"</A>';;
164612) n=3 t='<A NAME=ElectricStorm>"An Electric Storm" album and other Kaleidophon letters</A>';;

165844) n=2 t='<A NAME=DD336Folder>Folder "DD 336"</A>';;
165920) n=3 t='<A NAME=HellHouse>"Hell House"</A>';;
170334) t='"The Legend of Hell House: music measurements"';;

170708) n=2 t='<A NAME=InitialCatalogue>Initial Catalogue of Delia'\''s tapes and papers</A>';;
#==============================================================================
	esac
	
	# name of image for labels etc, e.g. dd102417
	shortname=`basename "$a" .jpg`

	# $t gives a line of text to be printed before the image
	# $n gives a typographical style for the text: 1 2 3 4 -> H1 H2 H3 H4 for $t
	# $t of "-" means the piece in question is unknown
	case "$t" in
	"") : ;;
	-)  echo "</P>???<P>" ;;
	*)  echo "</P>"
	    [ "$n" ] && echo -n "<H$n>"
	    echo -n "$t"
	    [ "$n" ] && echo -n "</H$n>"
	    echo "<P>"
	    ;;
	esac

	# Find the width and height of the thumbnail:
	#    rdjpgcom -verbose thumb/dd072610.jpg
	# outputs:
	#    JPEG image is 100w * 133h, 3 color components, 8 bits per sample
	#    JPEG process: Baseline
	# so we need to pick out 100 and 133 from  "... 100w * 133h ..."
	size=`rdjpgcom -verbose "$mini/$a" | sed -n '/.* \([1-9][0-9]*\)w \* \([1-9][0-9]*\)h.*/s//\1 \2/p'`
	width=`echo "$size" | awk '{print $1}'`
	height=`echo "$size" | awk '{print $2}'`

	echo "<A NAME=$shortname HREF=\"html/$shortname.html\"><IMG BORDER=1"
	echo " TITLE=$shortname SRC=\"$mini/$a\" WIDTH=$width HEIGHT=$height"
	# Alternate text: the filename without the ".jpg"
  	echo " ALT=\"$shortname\"></A>"
    done

    echo '</P>'
    cat footer.html
  } > $mini.html &
done
wait

ln -sf thumb.html index.html

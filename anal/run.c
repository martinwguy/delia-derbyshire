/*
 *	run: Turn a spectrogram back into audio.
 *
 *	Copyright (c) 2016 Martin Guy <martinwguy@gmail.com>
 *
 *	Usage: run dbmin dbmax fmin fmax duration graph.png scale.png output.wav
 *	All numbers are floating point values.
 *	dbmin dbmax		Range of dB values in the color scale.
 *		dbmin is the amplitude represented by the bottom pixel of the
 *		color scale, dbmax the value represented by the top color.
 *		To normalise the output, give dbmax as 0 and dbmin as minus the
 *		total dynamic range.
 *	fmin fmax		Range of frequency values in the graph.
 *		fmin is the frequency in Hz represented by the bottom row of
 *		pixels in the graph; fmax that of the top row.
 *	duration		Length of the audio in seconds.
 *		The length of the audio in seconds.
 *	graph.png		The raw spectrogram
 *		Just the data points without legends, scales or borders.
 *		Time on the x-axis, frequency on the y-axis.
 *	scale.png		Color scale
 *		A one-pixel-wide vertical stripe giving the colors for the
 *		range of db values. The top pixel represents dbmax, the bottom
 *		one dbmin and the values in between are assumed to be linearly
 *		spaced. It is OK for several adjacent pixels in the scale to be
 *		of the same tint: the program will assign the middle value of
 *		the same-color band to pixels of that color.
 *	output.wav		Output file name
 *		Audio output is written into the named file.
 *
 *	Options:
 *	--floor db		Set noise floor to -db decibels.
 *		Any pixel in the input that is below this value is taken as 0.
 *	--fps N			Interpolate to N frames per second
 *		Reduce choppiness of low frame rate spectrograms by
 *		interpolating between FFT frames before doing the transform.
 *	--fill
 *		Write all FFT points by interpolating between input values
 *		(the default is to write each input once to the nearest
 *		FFT input point)
 *	--verbose
 *		Show calculated parameters (FFT/second, max freq etc)
 *
#ifdef PARTIALS
 *	--partials		Write audio of each frame to files
 *		A debugging aid that writes the first ten audio fragments
 *		to ten WAV files before they are merged to form the output.
#endif
 */
#include <stdlib.h>
#include <stdint.h>	/* for uint32_t */
#include <stdio.h>
#include <math.h>
#include <string.h>	/* for memset() */
#include <ctype.h>	/* for isdigit() */
#include <png.h>
#include <fftw3.h>
#include <sndfile.h>
void perror(const char *s);

/* Forward declarations */
static png_bytep *
    read_png(char *filename, png_structp *pngp, png_infop *infop, char *type);
static void
    init_scale(png_bytep *data, long height, double dbmin, double dbmax);
static double color2amp(png_byte *px, int x, int y);
static double interpolate(double y1, double y2, double mu);
static void calc_hann_window (double * data, int datalen);
static void write_audio(float *audio, sf_count_t audiosamples,
			int samplerate, char *filename, int normalize);
static void oom();	/* Out of memory handler */

/* Local data */
static char *progname;

#ifdef PARTIALS
/* Debugging flag --partials outputs audio for each pixel column
 * into separate audio files */
static int partials = 0;
#endif

static double noise_floor = -INFINITY;

/* Frame rate to interpolate the input frames to.
 * 0.0 means no interpolation (so same as pixel column rate).
 */
static double fps = 0.0;

/* Interpolate input values in each column to fill the FFT input array,
 * instead of sparsely populating it? */
static int fill = 0;

/* Whistle while we work? */
static int verbose = 0;

void
main(int argc, char **argv)
{
    double dbmin, dbmax, fmin, fmax, duration;
    char *graphfilename, *scalefilename, *audiofilename;
    png_structp graphpng, scalepng;
    png_infop graphinfo, scaleinfo;
    png_bytep *graphdata, *scaledata;
    long graphwidth, graphheight, scaleheight;
    float **amplitudes;	/* amplitude equivalents of graphdata[][] */
    int x,y;	/* Indices into graph */

    progname = argv[0];

    while (argc > 1 && argv[1][0] == '-') {
	/* Stop if we're at the negative numeric arguments */
        if (isdigit(argv[1][1])) break;

	if (strcmp(argv[1], "--fill") == 0)
	    fill = 1;
	else
	if (strcmp(argv[1], "--floor") == 0) {
	    noise_floor = atof(argv[2]);
	    if (noise_floor == 0.0) {
		fputs("--floor what?\n", stderr);
		exit(1);
	    }
	    /* Accept positive or negative db value; only -ve make sense */
	    if (noise_floor > 0.0) noise_floor = -noise_floor;

	    argv++, argc--;	/* gobble numeric parameter too */
	} else
	if (strcmp(argv[1], "--fps") == 0) {
	    fps = atof(argv[2]);
	    if (fps <= 0.0) {
		fputs("--fps what?\n", stderr);
		exit(1);
	    }
	    argv++, argc--;	/* gobble numeric parameter too */
	} else
#ifdef PARTIALS
	if (strcmp(argv[1], "--partials") == 0)
	    partials = 1;
	else
#endif
	if (strcmp(argv[1], "--versobe") == 0 ||
	    strcmp(argv[1], "-v") == 0) {
		verbose++;
	} else
	{
	    fprintf(stderr, "Unknown flag '%s'.\n", argv[1]);
	    exit(1);
        }
	argv++; argc--;
    }

    if (argc != 9) {
	fprintf(stderr, "Usage: %s [options] dbmin dbmax fmin fmax duration graph.png scale.png audio.wav\n", progname);
	exit(1);
    }

    dbmin=atof(argv[1]);
    dbmax=atof(argv[2]);
    fmin=atof(argv[3]);
    fmax=atof(argv[4]);
    duration=atof(argv[5]);
    graphfilename=argv[6];
    scalefilename=argv[7];
    audiofilename=argv[8];

    /* Non-numeric strings convert as 0.0; check this where possible
     * and do some half-hearted sanity checks. */
    if (dbmin >= 0.0) {
	fprintf(stderr, "%s: dbmin must be negative.\n", progname);
	exit(1);
    }
    if (fmin < 0.0) {
	fprintf(stderr, "%s: fmin cannot be negative.\n", progname);
	exit(1);
    }
    if (fmax <= 0.0) {
	fprintf(stderr, "%s: fmax must be greater than zero.\n", progname);
	exit(1);
    }
    if (duration <= 0.0) {
	fprintf(stderr, "%s: dbmin must be greater than zero.\n", progname);
	exit(1);
    }

    /* Read the images into memory */
    graphdata = read_png(graphfilename, &graphpng, &graphinfo, "spectrogram");
    scaledata = read_png(scalefilename, &scalepng, &scaleinfo, "color scale");

    /* Measure the images */
    graphwidth = png_get_image_width(graphpng, graphinfo);
    graphheight = png_get_image_height(graphpng, graphinfo);
    if (png_get_image_width(scalepng, scaleinfo) != 1) {
	fprintf(stderr, "%s: Color scale must be one pixel wide instead of %lu.\n",
		progname, png_get_image_width(scalepng, scaleinfo));
	exit(1);
    }
    scaleheight = png_get_image_height(scalepng, scaleinfo);

    /* Make our color-to-loudness reverse mapping table */
    init_scale(scaledata, scaleheight, dbmin, dbmax);

    /* Convert the color values to amplitude values */
    amplitudes = calloc(graphheight, sizeof(*amplitudes));
    if (!amplitudes) oom();
    for (y=0; y<graphheight; y++) {
	amplitudes[y] = calloc(graphwidth, sizeof(*amplitudes[y]));
	if (!amplitudes[y]) oom();
	for (x=0; x<graphwidth; x++)
            amplitudes[y][x] = color2amp(&graphdata[y][x*3], x, y);
    }
    /* Can now free the PNG images and their data */

    /* Resample the amplitude graph to give more columns if requested.
     * Each input column represents a fraction of a second of audio, for
     * a total of "duration" seconds. We consider the "time" of a sample bin
     * to be at the centre of the column's width, hence the +0.5 and -0.5.
     * From the time at the centre of the output column we need to find the
     * pair of input column centres that enclose it (oldx and oldx+1),
     * and how far between them it falls as a proportion 0.0 <= mu < 1.0.
     */
    if (fps != 0.0) {
	double oldfps = graphwidth / duration;
	double newfps = fps;
	int newwidth = round(duration * newfps);
	float *newamplitudeline = calloc(newwidth, sizeof(float));

	for (y = 0; y < graphheight; y++) {
	    float *newamplitude = calloc(newwidth, sizeof(float));
	    int newx;  /* Which item of newamplitudes[] we are calculating */
	    for (newx = 0; newx < newwidth; newx++) {
		/* time from start represented by centre of output column */
		double time = (newx + 0.5) / newfps;
		double x = time * oldfps - 0.5;
		int oldx = floor(x);
		double y1, y2;

		y1 = amplitudes[y][oldx < 0 ? 0 : oldx];
		y2 = amplitudes[y][oldx+1 > graphwidth-1 ? graphwidth-1 : oldx+1];
		newamplitude[newx] = interpolate(y1, y2, x - oldx);
	    }
	    free(amplitudes[y]);
	    amplitudes[y] = newamplitude;
	}
	graphwidth = newwidth;
    }

    /* We have graphwidth columns of input, each representing a fraction of
     * a second of audio. We do an inverse FFT with a window length twice
     * the size of this fraction then add it to the audio output using a
     * Hann window which, being cos^2, has the nice properties that it
     * crosses .5 at 1/4 and 3/4 of its width, that each half has
     * rotational symmetry and the endpoints are at 0 which means that two
     * adjacent half-overlapped windows sum to 1.0 and the sound output
     * for the middle half of each window depends mostly on the data for
     * the corresponding pixel column.
     * If you center the windows on the columns' centers, a quarter of
     * the first window sticks out before the start of the first column
     * and a quarter of the last window sticks out beyond the last column so
     * the total audio length is the stated duration plus half a window.
     * In practice we add half a window at the end of the audio and write each
     * frame of output left-aligned instead of centred.
     */

    /* Precompute some constants */
    int samplerate = 44100;
    double column_interval = duration / (double)graphwidth;
    int fft_size = lrint(column_interval * samplerate * 2);

    /* Allocate the audio in memory, all initialised to zero. */
    unsigned long audiosamples = ceil(duration * samplerate + fft_size/2.0);
    float *audio = calloc(audiosamples, sizeof(float)); /* Fills with 0s */
    if (!audio) oom();

    /* Precompute the window function into a table */
    double *hann_window = malloc(fft_size * sizeof(double));
    if (!hann_window) oom();
    calc_hann_window(hann_window, fft_size);

    fftw_complex *in;
    double *out;
    fftw_plan p;

    in = fftw_alloc_complex(fft_size);
    out = fftw_alloc_real(fft_size);
    p = fftw_plan_dft_c2r_1d(fft_size, in, out, FFTW_MEASURE); /* always FFTW_BACKWARD */

    /* Now convert each column of the graph into data suitable as input
     * to a reverse DFT, do the DFT, then add the result to the audio
     * through the Hann window. */

    /* Add a random phase offset to each bin to avoid all the partials
     * coinciding and producing a nasty peak. */
    srandom(time(NULL));
    double *rphase;
    if (!fill) {
        rphase = calloc(graphheight, sizeof(double));
        if (!rphase) oom();
        for (y=0; y<graphheight; y++)
	    rphase[y] = (double)random() * 2.0 * M_PI / (double)RAND_MAX;
    } else {
        rphase = calloc(fft_size/2, sizeof(double));
        if (!rphase) oom();
        for (y=0; y<fft_size/2; y++)
	    rphase[y] = (double)random() * 2.0 * M_PI / (double)RAND_MAX;
    }

    for (x=0; x<graphwidth; x++) {
	/* The start of this pixel column represents audio starting after
	 * how many seconds? */
	double time = x * column_interval;

        /* fftw_2r destroys the input array so we zero it and rebuild it
	 * for every column. */
	memset(in, 0, sizeof(fftw_complex) * fft_size);

	if (!fill)
	for (y=0; y<graphheight; y++) {

	    /* What frequency does this row represent?
	     * At y=0, the frequency is fmax. At y=graphheight-1, freq=fmin.
	     */
	    double freq = fmax - (fmax-fmin) * ((double)y / (graphheight-1));;

	    /* The iFFT input from [0] to [(n/2)+1] represents 0Hz to nyquist,
	     * both of the endpoints being purely real. */
	    int fftindex = lrint(freq * (fft_size/2+1) / (samplerate/2));

	    /* What frequency does that bin really represent? */
	    double fftfreq = (double)fftindex * (samplerate/2) / (fft_size/2+1);

	    /* Phase is chosen in such a way that the sine wave output from a
	     * single bin is in phase with its output from the same bin in the
	     * all the other frames.
	     * Phase for a bin at fHz at time t seconds is t * f * 2 PI radians.
	     * Without the random phase offset, constant for each bin, many
	     * partials coincide in phase and produce harsh cos-like peaks
	     *       /\                                 ,
	     *      /  \                               /|
	     * /\  /    \  /\  or sin-like peaks  /\  / |  /\
	     *   \/      \/                         \/  | /  \/
	     *                                          |/
             *                                          '
	     */
            double amp = amplitudes[y][x];
	    double phase = time * fftfreq * 2.0 * M_PI + rphase[y];

	    in[fftindex][0] += amp * sin(phase); /* real */
	    in[fftindex][1] += amp * cos(phase); /* imaginary */
        }
	else {
	    /* Fill in all FFT points by interpolating between the input points
	     */
	    double fft_points_per_bucket = ((double)(fft_size/2+1) / (samplerate/2)) /
	                                   ((double)(graphheight-1) / (fmax - fmin));
	    int minfftindex = floor(fmin * (fft_size/2+1) / (samplerate/2));
	    int maxfftindex = ceil (fmax * (fft_size/2+1) / (samplerate/2));
	    int fftindex;
	    for (fftindex = minfftindex; fftindex <= maxfftindex; fftindex++) {
		double freq = fftindex * (samplerate/2) / (fft_size/2+1);
		/* Corresponding index into input column, by inverting
		 * the "freq = ... y ..." formula in the above code */
		double y = ((fmax-freq) / (fmax-fmin)) * (graphheight - 1);
		double y1 = trunc(y) < 0.0 ? 0.0 :
		            amplitudes[(int)trunc(y)][x];
		double y2 = trunc(y)+1 > graphheight-1 ? 0.0 :
		            amplitudes[(int)trunc(y)+1][x];
		double mu = y - trunc(y);
		double amp = interpolate(y1, y2, mu);
	        double phase = time * freq * 2.0 * M_PI + rphase[fftindex];
		in[fftindex][0] += amp * sin(phase); /* real */
		in[fftindex][1] += amp * cos(phase); /* imaginary */
	    }
	}

	fftw_execute(p);

	/* Now out[0..fft_size-1] represent the audio for one frame.
	 * Add this to the audio through the window.
	 */
	/* Where do we start writing in the output array? */
	{
	    float *audio_start = &(audio[lrint(time * samplerate)]);
	    for (y=0; y<fft_size-1; y++)
		/* A 0dB single point gives output from -2 to +2.
		 * I have no idea why; it should be from -1 to +1.
		 * We compensate by dividing it by 2!
		 */
		audio_start[y] += out[y] * hann_window[y] / 2;
	}
#ifdef PARTIALS
	if (partials) {
	    static unsigned partial_number;
	    if (partial_number < 10) {
		char filename[16];
		float *partial = calloc(audiosamples, sizeof(float));
		float *audio_start = &(partial[lrint(time * samplerate)]);
		for (y=0; y<fft_size-1; y++)
		    audio_start[y] += out[y] * hann_window[y] / 2;
		sprintf(filename, "partial-%03u.wav", partial_number++);
		write_audio(partial, audiosamples, samplerate, filename, 0);
		free(partial);
	    }
	}
#endif
    }

    write_audio(audio, audiosamples, samplerate, audiofilename, 1);

    exit(0);
}

/* Open a PNG file and read its contents into memory as a vector of pointers
 * to rows of 8-bit tuples.  The RGB values of pixel at (x,y) are then
 * png_bytep *im = read_png(...);
 * png_bytep px = &(im[y][x*3]);
 * r = px[0]; g = px[1]; b = px[2]; // a = px[3];
 */
static png_bytep *
read_png(char *filename, png_structp *pngp, png_infop *infop, char *type)
{
    FILE *fp;
    png_structp png;
    png_infop info;
    png_bytep *row_pointers;
    long height;

    fp = fopen(filename, "rb");
    if (fp == NULL) {
	fprintf(stderr, "%s: Cannot open %s file ", progname, type);
	perror(filename);
	exit(1);
    }
    
    png = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    if (!png) abort();
    info = png_create_info_struct(png);
    if (!info) abort();
    if (setjmp(png_jmpbuf(png))) abort();
    png_init_io(png, fp);
    png_read_info(png, info);

    /* Extra stuff from https://gist.github.com/niw/5963798
     * to convert other image types to RGB */
    if (png_get_bit_depth(png, info) == 16) {
	fprintf(stderr, "%s: Truncating 16-bit %s to 8-bit depth.\n", progname, type);
#if PNG_LIBPNG_VER >= 10504
	png_set_scale_16(png);
#else
	png_set_strip_16(png);
#endif
    }
    if (png_get_color_type(png, info) == PNG_COLOR_TYPE_PALETTE)
	    png_set_palette_to_rgb(png);
    if (png_get_color_type(png, info) == PNG_COLOR_TYPE_GRAY &&
	png_get_bit_depth(png, info) < 8)
	    png_set_expand_gray_1_2_4_to_8(png);
    png_read_update_info(png, info);

    if (png_get_color_type(png, info) != PNG_COLOR_TYPE_RGB) {
	fprintf(stderr, "%s: Can only handle RGB images.\n", progname);
	exit(1);
    }

    *pngp = png; *infop = info;

    /* Measure image and allocate memory */

    height = png_get_image_height(png, info);
    row_pointers = (png_bytep *) calloc(height, sizeof(png_bytep));
    if (!row_pointers) oom();
    {   int y;
	for (y=0; y<height; y++) {
	    row_pointers[y] = (png_byte *) malloc(png_get_rowbytes(png, info));
	    if (row_pointers[y] == NULL) oom();
	}
    }

    png_read_image(png, row_pointers);

    fclose(fp);

    return row_pointers;
}

/* Associative array to map colors to values in decibels.
 * Since several adjacent entries in the color scale can be of the same color
 * we find the mean value for that color by summing the dB values in "db",
 * keeping track of how many values we have summed in "count" and dividing
 * "db" by "count" when we have finished scanning the color map.
 */
typedef struct scale {
    union {
	png_byte colors[4];	/* R, G, B, A */
	uint32_t color;		/* as a 32-bit word */
    };
    double db;		/* Sum of decibel values that this color stands for */
    double amp;		/* Amplitude for this dB value (db=0 == 1.0) */
    unsigned count;	/* How many values were added to "db" for this color? */
} scale_t;

#define db2amp(db) ((db)<noise_floor ? 0.0 : pow(10.0, (db)/20.0))

static scale_t *scale;	/* Array of color/db pairs */
static int scaleitems;	/* Number of elements that are in use in scale[] */
static int lastscaleitem; /* Last items that came from the color scale itself */
static int scalesize;	/* Number of elements allocated to scale[] */

/*
 * Convert the one-pixel-high color scale image to our internal representation,
 * an associative array collecting unique color values and their db values.
 */
static void
init_scale(png_bytep *scaledata, long scaleheight, double dbmin, double dbmax)
{
    int y;	/* Loop counter to scan the image of the color map */
    int entry;	/* Loop counter to scan the existing entries */

    scale = calloc(scalesize=scaleheight, sizeof(struct scale));
    if (!scale) oom();
    scaleitems = 0;

    for (y=0; y < scaleheight; y++) {
	png_bytep px = scaledata[y];
	uint32_t color;	/* [R,G,B,zero] cast to a 32.bit int */
	double db; /* Decibel value represented by this item in the scale */

	color = *(uint32_t *)px;
	((png_byte *)(&color))[3] = 0;	/* Zap the alpha value */

	/* Calculate the dB value represented by this item in the scale.
	 * y==0 represents dbmax and y==(scaleheight-1) represents dbmin
	 */
	db = dbmax + y * dbmin / (scaleheight-1);

	/* See if the color is already in the mapping table */
	for (entry=0; entry<scaleitems; entry++) {
	    if (scale[entry].color == color) {
		scale[entry].db += db;
		scale[entry].count++;
		break;
	    }
	}
	if (entry == scaleitems) {
	    /* It was not found. Add a new entry */
	    scale[entry].color = color;
	    scale[entry].db = db;
	    scale[entry].count = 1;
	    scaleitems++;
	}
    }

    /* Now average the entries for colors representing multiple db values */
    for (entry=1; entry < scaleitems; entry++) {
	scale[entry].db /= scale[entry].count;
	scale[entry].amp = db2amp(scale[entry].db);
	scale[entry].count = 1;  /* even if never used again */
    }
    /* Special case: the top value is dragged down by the same color value
     * below it but not up by the (nonexistent) entry above it. So just take
     * the top value as-is, being the centre pixel of the 3-pixel high
     * same-color band it should be part of. Furthermore, the dbmax value
     * seems to refer to the white one-pixel top border of the scale, not to
     * the top pixel row of the color scale, so we adjust for that too.
     */
    scale[0].db = dbmax;
    scale[0].amp = db2amp(dbmax);

    /* Remember how many came from the scale itself as we invent more later
     * when we find colors not in the scale */
    lastscaleitem = scaleitems - 1;
}

/* Map a color to its corresponding amplitude value.
 * px points to an array of four 8-bit value (RGBA)
 */
static double
color2amp(png_byte *px, int x, int y)
{
    int entry;
    uint32_t color = *(uint32_t *)px;
    double db, amp;	/* Estimated value for this color */

    ((png_byte *)(&color))[3] = 0;	/* Zap the alpha value */

    /* Look for an exact match in the color scale. */
    for (entry=0; entry<scaleitems; entry++)
	if (scale[entry].color == color)
	    return scale[entry].amp;

    /* Color is not in the scale.  Either it's black, above the top
     * of the range of colors, off the bottom or between other colors.
     * For black, just return 0 amplitude (-inf dB).
     * For values above the maximum do linear interpolation from the top two
     * entries according to the red value which seems to increase isotonically.
     * For values off the bottom, we do nothing yet.
     * For values in between,
     * - first, try to find two adjacent values in the existing color table
     *   whereby the red value lies between the red values, the green between
     *   the green etc. and interpolate between the two dB values.
     * - if there are none, just find the closest color value and use that.
     */

    /* Black? Zero amplitude. */
    if (px[0] == 0 && px[1] == 0 && px[2] == 0)
	return(0);

    /* If the red value is off the top of the scale, interpolate on the
     * the top two values in the scale. */
    if (px[0] > scale[0].colors[0]) {
	double extra_red=px[0] - scale[0].colors[0];
	double db_per_unit_red = (scale[0].db - scale[1].db) /
			            (scale[0].colors[0] - scale[1].colors[0]);
	db = scale[0].db + extra_red * db_per_unit_red;

	/* Sanity check */
	if (scale[0].colors[0] == scale[1].colors[0]) {
            fprintf(stderr, "Color (%u,%u,%u) at (%d,%d) off top of the scale but can't interpolate.\n",
	            px[0], px[1], px[2], x, y);
	    return scale[0].amp;
	}

	goto store_and_return;
    }

    /* If value is off the bottom of the scale, interpolate on the
     * the bottom two values in the scale. i If the initial test succeeds,
     * at least one of the three colors will be < the minimum because the
     * case of all three being equal was covered above. */
    if (px[0] <= scale[lastscaleitem].colors[0] &&
	px[1] <= scale[lastscaleitem].colors[1] &&
	px[2] <= scale[lastscaleitem].colors[2]) {

	/* Find a color in which there is a gradient at the bottom of the scale
	 * and a difference in that color. */
	for (int color=0; color<=2; color++) {
	    if (scale[lastscaleitem-1].colors[color] >
		scale[lastscaleitem].colors[color] &&
	        px[color] < scale[lastscaleitem].colors[color]) {
	        double missing=scale[lastscaleitem].colors[color] - px[color];
	        double db_per_unit =
		    (scale[lastscaleitem-1].db - scale[lastscaleitem].db) /
		    (scale[0].colors[color] - scale[1].colors[color]);
	        db = scale[lastscaleitem].db + missing * db_per_unit;

		goto store_and_return;
	    }
	}

	/* Give up. Give it the end-of-scale value */
        fprintf(stderr, "Color (%u,%u,%u) at (%d,%d) off bottom of scale but can't interpolate.\n",
	        px[0], px[1], px[2], x, y);
	db = scale[lastscaleitem].db;
	goto store_and_return;
    }

/* Conventional weightings when converting from color to grayscale.
 * This may not be the most appropriate for our purposes! */
#define R_WEIGHT (0.299)
#define G_WEIGHT (0.587)
#define B_WEIGHT (0.114)

    /* See if it falls between two other colors */
    for (entry=0; entry<lastscaleitem; entry++) {
	png_byte r = px[0], g = px[1], b = px[2];
	png_byte r0 = scale[entry].colors[0], r1 = scale[entry+1].colors[0];
	png_byte g0 = scale[entry].colors[1], g1 = scale[entry+1].colors[1];
	png_byte b0 = scale[entry].colors[2], b1 = scale[entry+1].colors[2];
	double db0 = scale[entry].db, db1 = scale[entry+1].db;

	/* Are all three channel's values between [entry] and [entry+1]? */
	if ((r0 <= r && r <= r1 || r0 >= r && r >= r1) &&
            (g0 <= g && g <= g1 || g0 >= g && g >= g1) &&
            (b0 <= b && b <= b1 || b0 >= b && b >= b1)) {
	    /* Channels that have no range are useless for interpolation.
	     * For the others, make a weighted average of the interpolated
	     * values that they suggest.
	     */
	    db = 0.0;		/* Sum of weighted interpolations */
	    double weights = 0.0;	/* Sum of weights that were used */

	    if (r0 != r1) {
		db += (db0 + (db1-db0) * (r - r0) / (r1 - r0)) * R_WEIGHT;
		weights += R_WEIGHT;
	    }
	    if (g0 != g1) {
		db += (db0 + (db1-db0) * (g - g0) / (g1 - g0)) * G_WEIGHT;
		weights += G_WEIGHT;
	    }
	    if (b0 != b1) {
		db += (db0 + (db1-db0) * (b - b0) / (b1 - b0)) * B_WEIGHT;
		weights += B_WEIGHT;
	    }
	    db /= weights;
	    goto store_and_return;
        }
    }

    /* Find the closest entry */
    int best_entry = -1;  /* None chosen yet */
    double best_distance = INFINITY;

    for (entry=0; entry<scaleitems; entry++) {
	/* Maybe should weight these */
	double distance =
	    abs(scale[entry].colors[0]-px[0]) +
	    abs(scale[entry].colors[1]-px[1]) +
	    abs(scale[entry].colors[2]-px[2]);
	if (distance < best_distance) {
	    best_entry = entry;
	    best_distance = distance;
	}
    }
    if (best_entry != -1) {
	/* Complain if it differs by more than three hue values */
	if (best_distance > 3.0)
        fprintf(stderr, "Color (%u,%u,%u) at (%d,%d) approximated to (%u,%u,%u), distance=%g.\n",
	    px[0], px[1], px[2], x, y,
	    scale[best_entry].colors[0],
	    scale[best_entry].colors[1],
	    scale[best_entry].colors[2],
	    best_distance);

	db = scale[best_entry].db;
	goto store_and_return;
    }

    fprintf(stderr, "%s: Color (%u,%u,%u) at (%d,%d) not found in scale.\n",
	progname, px[0], px[1], px[2], x, y);
    exit(1);

store_and_return:

    amp = db2amp(db);

    /* Add it to the mapping table */
    if (scaleitems >= scalesize) {
	scalesize *= 2;
	scale = realloc(scale, scalesize * sizeof(struct scale));
	if (!scale) oom();
    }
    scale[scaleitems].color = *(uint32_t *)px;
    scale[scaleitems].colors[3] = 0; /* zap alpha */
    scale[scaleitems].db = db;
    scale[scaleitems].amp = amp;
    scale[scaleitems].count = 1;
    scaleitems++;

    return amp;
}


static double
interpolate(double y1, double y2, double mu)
{
    /* Linear interpolation */
    // return y1 * (1 - mu) + y2 * mu;

    /* Cosine interpolation does not exhibit the cubic splines' overshoot
     * and depends only on the two bounding points.
     * However, multiplying the signal by a constant-frequency cosine
     * may be like putting it through a ring modulator.
     */
    double mu2 = (1 - cos(mu * M_PI)) / 2;
    return y1 * (1 - mu2) + y2 * mu2;
}


/* Stolen from sndfile-tools */
static void
calc_hann_window (double * data, int datalen)
{
        int k ;

        /*
        **      Hann window function from :
        **
        **      http://en.wikipedia.org/wiki/Window_function
        */

        for (k = 0 ; k < datalen ; k++) {
                data [k] = 0.5 * (1.0 - cos (2.0 * M_PI * k / (datalen - 1))) ;
	}

        return ;
}

static void
write_audio(float *audio, sf_count_t audiosamples, int samplerate,
	    char *filename, int normalize)
{
    SF_INFO sfinfo;
    SNDFILE *sndfile;

    sfinfo.frames = audiosamples;
    sfinfo.samplerate = samplerate;
    sfinfo.channels = 1;
    sfinfo.format = SF_FORMAT_WAV | SF_FORMAT_FLOAT;
    sndfile = sf_open(filename, SFM_WRITE, &sfinfo);
    if (!sndfile) {
	fprintf(stderr, "%s: Failed to create audio file %s: %s\n",
		progname, filename, sf_strerror(NULL));
	exit(1);
    }

    /* Fix volume so that maximum amplitude is +- 1.0 */
    if (normalize) {
	float maxamp = 0.0;
	sf_count_t x;
	for (x=0; x < audiosamples; x++)
	    if (fabsf(audio[x]) > maxamp)
		maxamp = fabsf(audio[x]);
	if (maxamp > 0.0)
	    for (x=0; x < audiosamples; x++)
	        audio[x] /= maxamp;
    }

    if (sf_write_float(sndfile, audio, audiosamples) != audiosamples) {
	fprintf(stderr, "%s: Error writing audio file: %s\n",
		progname, sf_strerror(NULL));
	exit(1);
    }
    if (sf_close(sndfile) != 0) {
	fprintf(stderr, "%s: Error closing audio file: %s\n",
		progname, sf_strerror(NULL));
	exit(1);
    }
}

/* This is called when malloc() fails */
static void
oom()
{
    fprintf(stderr, "%s: Out of memory.\n", progname);
    abort();
}

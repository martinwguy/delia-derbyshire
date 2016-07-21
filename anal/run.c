/*
 *	run: Turn a spectrogram back into audio.
 *
 *	Copyright (c) 2016 Martin Guy <martinwguy@gmail.com>
 *
 *	Usage: run dbmin dbmax fmin fmax duration graph.png scale.png
 *	All numbers are floating point values.
 *	dbmin dbmax		Range of dB values in the color scale.
 *		dbmin is the amplitude represented by the bottom pixel of the
 *		color scale, dbmax the value represented by the top color.
 *		To normalise the output, give dbmax as 0 and dbmin as minus te
 *		total dynamic range.
 *	fmin fmax		Range of frequency values in the graph
 *		fmin is the frequency in Hz represented by the bottom row of
 *		pixels in the graph; fmax that of the top row.
 *	duration		Length of the audio in seconds.
 *		The length of the audio in seconds.
 *	graph.png		The raw spectrogram
 * 		Just the data points without legends, scales or borders.
 *		Time on the x-axis, frequency on the y-axis.
 *	scale.png		Color scale
 *		A one-pixel-wide vertical stripe giving the colors for the
 *		range of db values. THe top pixel represents dbmax, the bottom
 *		one dbmin and the values in between are assumed to be linearly
 *		spaced. It is OK for several adjacent pixels in the scale to be
 *		of the same tint: the program will assign the middle value of
 *		the same-color band to pixels of that color.
 *
 *	Output is written into file audio.wav
 */
#include <stdlib.h>
#include <stdint.h>	/* for uint32_t */
#include <stdio.h>
#include <math.h>
#include <string.h>	/* for memset() */
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
static void calc_hann_window (double * data, int datalen);
static void write_audio(float *audio, sf_count_t audiosamples,
			int samplerate, char *filename);
static void oom();	/* Out of memory handler */

/* Local data */
static char *progname;

void
main(int argc, char **argv)
{
    double dbmin, dbmax, fmin, fmax, duration;
    char *graphfilename, *scalefilename;
    png_structp graphpng, scalepng;
    png_infop graphinfo, scaleinfo;
    png_bytep *graphdata, *scaledata;
    long graphwidth, graphheight, scaleheight;

    progname = argv[0];

    if (argc != 8) {
	fprintf(stderr, "Usage: %s dbmin dbmax fmin fmax duration graph.png scale.png\n", progname);
	exit(1);
    }

    dbmin=atof(argv[1]);
    dbmax=atof(argv[2]);
    fmin=atof(argv[3]);
    fmax=atof(argv[4]);
    duration=atof(argv[5]);
    graphfilename=argv[6];
    scalefilename=argv[7];

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

    graphwidth = png_get_image_width(graphpng, graphinfo);
    graphheight = png_get_image_height(graphpng, graphinfo);
    if (png_get_image_width(scalepng, scaleinfo) != 1) {
	fprintf(stderr, "%s: Color scale must be one pixel wide instead of %lu.\n",
		progname, png_get_image_width(scalepng, scaleinfo));
	exit(1);
    }
    scaleheight = png_get_image_height(scalepng, scaleinfo);

    init_scale(scaledata, scaleheight, dbmin, dbmax);

    /* See if every color in the graph is represented in the scale */
    {   int x, y;
	for (x=0; x<graphwidth; x++)
	    for (y=0; y<graphheight; y++)
		color2amp(&graphdata[y][x*3], x, y);
    }

    /* We have graphwidth columns of input, each representing a fraction of
     * a second of audio. We do an inverse FFT with a window length twice
     * the size of this fraction then add it to the audio output using a
     * Hann window which, being cos^2, has the nice properties that it
     * crosses .5 at 1/4 and 3/4 of its width, that each half has
     * rotational symmetry and the endpoints are at 0 which mean that two
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

fprintf(stderr, "column interval = %g seconds\n", column_interval);
fprintf(stderr, "FFT size = %d\n", fft_size);

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

    int x,y;	/* Indices into graph */

    for (x=0; x<graphwidth; x++) {
	/* The start of this pixel column represents audio starting after
	 * how many seconds? */
	double time = x * column_interval;

        /* fftw_2r destroys the input array so we zero it and rebuild it
	 * for every column. */
	memset(in, 0, sizeof(fftw_complex) * fft_size);

	for (y=0; y<graphheight; y++) {
	    /* What frequency does this row represent?
	     * At y=0, the frequency is fmax. At y=graphheight-1, freq=fmin.
	     */
	    double freq = fmax - (fmax-fmin) * ((double)y / (graphheight-1));
	    /* The iFFT input from [0] to [(n/2)+1] represents 0Hz to nyquist,
	     * both of the endpoints being real. */
	    int fftindex = lrint(freq * (fft_size/2+1) / (samplerate/2));
	    /* Phase is chosen in such a way that the sine wave output from a
	     * single bin is in phase with its output in the following bin.
	     * Phase for a bin at f Hz at time t seconds is t*f* 2 PI radians.
	     */
            double amp = color2amp(&graphdata[y][x*3], x, y);
	    double phase = time * freq * 2.0 * M_PI;
#if 0
printf("amp,phase = %g,%g\n", amp, phase);
	    in[fftindex][0] += amp * cos(phase); /* real */
	    in[fftindex][1] += amp * sin(phase); /* imaginary */
#endif
        }

#if 0
printf("FFT INPUT\n");
for (y=0; y<=fft_size/2+1; y++) {
    printf("(%g,%g) ", in[y][0], in[y][1]);
}
putchar('\n');
#endif

	fftw_execute(p);

#if 0
printf("\nFFT OUTPUT\n");
for (y=0; y<=fft_size-1; y++) {
    printf("%g ", out[y]);
}
putchar('\n');
#endif

	/* Now out[0..fft_size-1] represent the audio for one frame.
	 * Add this to the audio through the window
	 */
	/* Where do we start wrting in the output array? */
	float *audio_start = &(audio[lrint(time * samplerate)]);
	for (y=0; y<fft_size-1; y++)
		audio_start[y] += out[y] * hann_window[y];
    }

    write_audio(audio, audiosamples, samplerate, "audio.wav");

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

    /* Extra stuff from https://gist.github.com/niw/5963798 */
    if (png_get_bit_depth(png, info) == 16) {
	fprintf(stderr, "%s: Warning: truncating 16-bit %s to 8-bit depth.\n", progname, type);
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
 * keeping tack of how many values we have summed in "count" and dividing
 * "db" by "count" when we have finished scanning the colour map.
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

#define db2amp(db) pow(10.0, (db)/20.0)

static scale_t *scale;	/* Array of colour/db pairs */
static int scaleitems;	/* Number of used items in scale[] */

/*
 * Convert the one-pixel-high color scale image to our internal representation,
 * an associative array collecting unique color values and their db values.
 */
static void
init_scale(png_bytep *scaledata, long scaleheight, double dbmin, double dbmax)
{
    int y;	/* Loop counter to scan the image of the color map */
    int entry;	/* Loop counter to scan the existing entries */

    scale = calloc(scaleheight, sizeof(struct scale));
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

	/* See if the colour is already in the mapping table */
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
     * ssems to refer to the white one-pixel top border of the scale, not to
     * the top pixel row of the colour scale, so this adjusts for that too.
     */
    scale[0].db = dbmax;
    scale[0].amp = db2amp(dbmax);

#if 0
    for (entry=0; entry < scaleitems; entry++) {
        fprintf(stderr, "(%u,%u,%u)=%g\n",
		scale[entry].colors[0],
		scale[entry].colors[1],
		scale[entry].colors[2],
		scale[entry].db);
    }
#endif
}

/* Map a color to its corresponding amplitude value.
 * px points to an array of four 8-bit value (RGBA)
 */
static double
color2amp(png_byte *px, int x, int y)
{
    int entry;
    uint32_t color = *(uint32_t *)px;

    ((png_byte *)(&color))[3] = 0;	/* Zap the alpha value */

    for (entry=0; entry<scaleitems; entry++)
	if (scale[entry].color == color)
	    return scale[entry].amp;

    /* Colour is not in the scale.  Either it's black, or above the top
     * of the range of colors or between other colours.
     * For black, just return 0. For values above the maximum,
     * do linear interpolation from the top two values.
     * For values in between, find the closest value and use that.
     */
    if (px[0] == 0 && px[1] == 0 && px[2] == 0)
	return(0);	/* Black. Zero amplitude. */

    if (px[0] > scale[0].colors[0]) {
        /* The color is off the top of the scale. Interpolate on the red
	 * component, which is the only one that rises consistently
	 * in the scale. */
	double extra_red=px[0] - scale[0].colors[0];
	double db_per_unit_of_red = (scale[0].db - scale[1].db) /
			            (scale[0].colors[0] - scale[1].colors[0]);
	double db = scale[0].db + extra_red * db_per_unit_of_red;

        fprintf(stderr, "%s: Warning: Color (%u,%u,%u) at (%d,%d) is off the scale. Using %g dB.\n",
	        progname, px[0], px[1], px[2], x, y, db);

        /* Add it to the mapping table */
	scale[scaleitems].color = *(uint32_t *)px;
	scale[scaleitems].colors[3] = 0; /* zap alpha */
	scale[scaleitems].db = db;
	scale[scaleitems].amp = db2amp(db);
	scale[scaleitems].count = 1;
	scaleitems++;

	return scale[scaleitems].amp;
    }

    /* Find the closest entry */
    int best_entry = -1;  /* None chosen yet */
    double best_distance = INFINITY;

#define sqr(x) ((x) * (x))

    for (entry=0; entry<scaleitems; entry++) {
	/* Maybe should weight these */
	double distance =
	    sqr(scale[entry].colors[0]-px[0]) +
	    sqr(scale[entry].colors[1]-px[1]) +
	    sqr(scale[entry].colors[2]-px[2]);
	if (distance < best_distance) {
	    best_entry = entry;
	    best_distance = distance;
	}
    }
    if (best_entry != -1) {
        fprintf(stderr, "%s: Color (%u,%u,%u) at (%d,%d) approximated to (%u,%u,%u).\n",
    	    progname, px[0], px[1], px[2], x, y,
	    scale[best_entry].colors[0],
	    scale[best_entry].colors[1],
	    scale[best_entry].colors[2]);
	return scale[best_entry].amp;
    }

    fprintf(stderr, "%s: Color (%u,%u,%u) at (%d,%d) not found in scale.\n",
	progname, px[0], px[1], px[2], x, y);
    exit(1);
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
write_audio(float *audio, sf_count_t audiosamples, int samplerate, char *filename)
{
    SF_INFO sfinfo;
    SNDFILE *sndfile;

    sfinfo.frames = audiosamples;
    sfinfo.samplerate = samplerate;
    sfinfo.channels = 1;
    sfinfo.format = SF_FORMAT_WAV | SF_FORMAT_PCM_16;
    sndfile = sf_open(filename, SFM_WRITE, &sfinfo);
    if (!sndfile) {
	fprintf(stderr, "%s: Failed to create audio file %s: %s\n",
		progname, filename, sf_strerror(NULL));
	exit(1);
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

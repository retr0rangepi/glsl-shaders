#version 130

/////////////////////////////  GPL LICENSE NOTICE  /////////////////////////////

//  crt-royale: A full-featured CRT shader, with cheese.
//  Copyright (C) 2014 TroggleMonkey <trogglemonkey@gmx.com>
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along with
//  this program; if not, write to the Free Software Foundation, Inc., 59 Temple
//  Place, Suite 330, Boston, MA 02111-1307 USA

// Compatibility #ifdefs needed for parameters
#ifdef GL_ES
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

// Parameter lines go here:

//  Disable runtime shader params if the user doesn't explicitly want them.
//  Static constants will be defined in place of uniforms of the same name.
//#ifndef RUNTIME_SHADER_PARAMS_ENABLE
//    #undef PARAMETER_UNIFORM
//#endif

//  Bind option names to shader parameter uniforms or static constants.
#ifdef PARAMETER_UNIFORM
    uniform float crt_gamma;
    uniform float lcd_gamma;
    uniform float levels_contrast;
    uniform float halation_weight;
    uniform float diffusion_weight;
    uniform float bloom_underestimate_levels;
    uniform float bloom_excess;
    uniform float beam_min_sigma;
    uniform float beam_max_sigma;
    uniform float beam_spot_power;
    uniform float beam_min_shape;
    uniform float beam_max_shape;
    uniform float beam_shape_power;
    uniform float beam_horiz_sigma;
//    #ifdef RUNTIME_SCANLINES_HORIZ_FILTER_COLORSPACE
        uniform float beam_horiz_filter;
        uniform float beam_horiz_linear_rgb_weight;
//    #else
//        float beam_horiz_filter = clamp(beam_horiz_filter_static, 0.0, 2.0);
//        float beam_horiz_linear_rgb_weight = clamp(beam_horiz_linear_rgb_weight_static, 0.0, 1.0);
//    #endif
    uniform float convergence_offset_x_r;
    uniform float convergence_offset_x_g;
    uniform float convergence_offset_x_b;
    uniform float convergence_offset_y_r;
    uniform float convergence_offset_y_g;
    uniform float convergence_offset_y_b;
//    #ifdef RUNTIME_PHOSPHOR_MASK_MODE_TYPE_SELECT
        uniform float mask_type;
//    #else
//        float mask_type = clamp(mask_type_static, 0.0, 2.0);
//    #endif
    uniform float mask_sample_mode_desired;
    uniform float mask_specify_num_triads;
    uniform float mask_triad_size_desired;
    uniform float mask_num_triads_desired;
    uniform float aa_subpixel_r_offset_x_runtime;
    uniform float aa_subpixel_r_offset_y_runtime;
//    #ifdef RUNTIME_ANTIALIAS_WEIGHTS
        uniform float aa_cubic_c;
        uniform float aa_gauss_sigma;
//    #else
//        float aa_cubic_c = aa_cubic_c_static;                              //  Clamp to [0, 4]?
//        float aa_gauss_sigma = max(FIX_ZERO(0.0), aa_gauss_sigma_static);  //  Clamp to [FIXZERO(0), 1]?
//    #endif
    uniform float geom_mode_runtime;
    uniform float geom_radius;
    uniform float geom_view_dist;
    uniform float geom_tilt_angle_x;
    uniform float geom_tilt_angle_y;
    uniform float geom_aspect_ratio_x;
    uniform float geom_aspect_ratio_y;
    uniform float geom_overscan_x;
    uniform float geom_overscan_y;
    uniform float border_size;
    uniform float border_darkness;
    uniform float border_compress;
    uniform float interlace_bff;
    uniform float interlace_1080i;
#else
    //  Use constants from user-settings.h, and limit ranges appropriately:
    #define crt_gamma max(0.0, crt_gamma_static);
    #define lcd_gamma max(0.0, lcd_gamma_static);
    #define levels_contrast clamp(levels_contrast_static, 0.0, 4.0);
    #define halation_weight clamp(halation_weight_static, 0.0, 1.0);
    #define diffusion_weight clamp(diffusion_weight_static, 0.0, 1.0);
    #define bloom_underestimate_levels max(FIX_ZERO(0.0), bloom_underestimate_levels_static);
    #define bloom_excess clamp(bloom_excess_static, 0.0, 1.0);
    #define beam_min_sigma max(FIX_ZERO(0.0), beam_min_sigma_static);
    #define beam_max_sigma max(beam_min_sigma, beam_max_sigma_static);
    #define beam_spot_power max(beam_spot_power_static, 0.0);
    #define beam_min_shape max(2.0, beam_min_shape_static);
    #define beam_max_shape max(beam_min_shape, beam_max_shape_static);
    #define beam_shape_power max(0.0, beam_shape_power_static);
    #define beam_horiz_filter clamp(beam_horiz_filter_static, 0.0, 2.0);
    #define beam_horiz_sigma max(FIX_ZERO(0.0), beam_horiz_sigma_static);
    #define beam_horiz_linear_rgb_weight clamp(beam_horiz_linear_rgb_weight_static, 0.0, 1.0);
    //  Unpack vector elements to match scalar uniforms:
    #define convergence_offset_x_r clamp(convergence_offsets_r_static.x, -4.0, 4.0);
    #define convergence_offset_x_g clamp(convergence_offsets_g_static.x, -4.0, 4.0);
    #define convergence_offset_x_b clamp(convergence_offsets_b_static.x, -4.0, 4.0);
    #define convergence_offset_y_r clamp(convergence_offsets_r_static.y, -4.0, 4.0);
    #define convergence_offset_y_g clamp(convergence_offsets_g_static.y, -4.0, 4.0);
    #define convergence_offset_y_b clamp(convergence_offsets_b_static.y, -4.0, 4.0);
    #define mask_type clamp(mask_type_static, 0.0, 2.0);
    #define mask_sample_mode_desired clamp(mask_sample_mode_static, 0.0, 2.0);
    #define mask_specify_num_triads clamp(mask_specify_num_triads_static, 0.0, 1.0);
    #define mask_triad_size_desired clamp(mask_triad_size_desired_static, 1.0, 18.0);
    #define mask_num_triads_desired clamp(mask_num_triads_desired_static, 342.0, 1920.0);
    #define aa_subpixel_r_offset_x_runtime clamp(aa_subpixel_r_offset_static.x, -0.5, 0.5);
    #define aa_subpixel_r_offset_y_runtime clamp(aa_subpixel_r_offset_static.y, -0.5, 0.5);
    #define aa_cubic_c aa_cubic_c_static;                              //  Clamp to [0, 4]?
    #define aa_gauss_sigma max(FIX_ZERO(0.0), aa_gauss_sigma_static);  //  Clamp to [FIXZERO(0), 1]?
    #define geom_mode_runtime clamp(geom_mode_static, 0.0, 3.0);
    #define geom_radius max(1.0/(2.0*pi), geom_radius_static);         //  Clamp to [1/(2*pi), 1024]?
    #define geom_view_dist max(0.5, geom_view_dist_static);            //  Clamp to [0.5, 1024]?
    #define geom_tilt_angle_x clamp(geom_tilt_angle_static.x, -pi, pi);
    #define geom_tilt_angle_y clamp(geom_tilt_angle_static.y, -pi, pi);
    #define geom_aspect_ratio_x geom_aspect_ratio_static;              //  Force >= 1?
    #define geom_aspect_ratio_y 1.0;
    #define geom_overscan_x max(FIX_ZERO(0.0), geom_overscan_static.x);
    #define geom_overscan_y max(FIX_ZERO(0.0), geom_overscan_static.y);
    #define border_size clamp(border_size_static, 0.0, 0.5);           //  0.5 reaches to image center
    #define border_darkness max(0.0, border_darkness_static);
    #define border_compress max(1.0, border_compress_static);          //  < 1.0 darkens whole image
    #define interlace_bff float(interlace_bff_static);
    #define interlace_1080i float(interlace_1080i_static);
#endif

/////////////////////////////  SETTINGS MANAGEMENT  ////////////////////////////

//////////////////////////////////  INCLUDES  //////////////////////////////////

#ifndef USER_SETTINGS_H
#define USER_SETTINGS_H

/////////////////////////////  DRIVER CAPABILITIES  ////////////////////////////

//  The Cg compiler uses different "profiles" with different capabilities.
//  This shader requires a Cg compilation profile >= arbfp1, but a few options
//  require higher profiles like fp30 or fp40.  The shader can't detect profile
//  or driver capabilities, so instead you must comment or uncomment the lines
//  below with "//" before "#define."  Disable an option if you get compilation
//  errors resembling those listed.  Generally speaking, all of these options
//  will run on nVidia cards, but only DRIVERS_ALLOW_TEX2DBIAS (if that) is
//  likely to run on ATI/AMD, due to the Cg compiler's profile limitations.

//  Derivatives: Unsupported on fp20, ps_1_1, ps_1_2, ps_1_3, and arbfp1.
//  Among other things, derivatives help us fix anisotropic filtering artifacts
//  with curved manually tiled phosphor mask coords.  Related errors:
//  error C3004: function "vec2 ddx(vec2);" not supported in this profile
//  error C3004: function "vec2 ddy(vec2);" not supported in this profile
    //#define DRIVERS_ALLOW_DERIVATIVES

//  Fine derivatives: Unsupported on older ATI cards.
//  Fine derivatives enable 2x2 fragment block communication, letting us perform
//  fast single-pass blur operations.  If your card uses coarse derivatives and
//  these are enabled, blurs could look broken.  Derivatives are a prerequisite.
    #ifdef DRIVERS_ALLOW_DERIVATIVES
        #define DRIVERS_ALLOW_FINE_DERIVATIVES
    #endif

//  Dynamic looping: Requires an fp30 or newer profile.
//  This makes phosphor mask resampling faster in some cases.  Related errors:
//  error C5013: profile does not support "for" statements and "for" could not
//  be unrolled
    //#define DRIVERS_ALLOW_DYNAMIC_BRANCHES

//  Without DRIVERS_ALLOW_DYNAMIC_BRANCHES, we need to use unrollable loops.
//  Using one static loop avoids overhead if the user is right, but if the user
//  is wrong (loops are allowed), breaking a loop into if-blocked pieces with a
//  binary search can potentially save some iterations.  However, it may fail:
//  error C6001: Temporary register limit of 32 exceeded; 35 registers
//  needed to compile program
    //#define ACCOMODATE_POSSIBLE_DYNAMIC_LOOPS

//  tex2Dlod: Requires an fp40 or newer profile.  This can be used to disable
//  anisotropic filtering, thereby fixing related artifacts.  Related errors:
//  error C3004: function "vec4 tex2Dlod(sampler2D, vec4);" not supported in
//  this profile
    //#define DRIVERS_ALLOW_TEX2DLOD

//  tex2Dbias: Requires an fp30 or newer profile.  This can be used to alleviate
//  artifacts from anisotropic filtering and mipmapping.  Related errors:
//  error C3004: function "vec4 tex2Dbias(sampler2D, vec4);" not supported
//  in this profile
    //#define DRIVERS_ALLOW_TEX2DBIAS

//  Integrated graphics compatibility: Integrated graphics like Intel HD 4000
//  impose stricter limitations on register counts and instructions.  Enable
//  INTEGRATED_GRAPHICS_COMPATIBILITY_MODE if you still see error C6001 or:
//  error C6002: Instruction limit of 1024 exceeded: 1523 instructions needed
//  to compile program.
//  Enabling integrated graphics compatibility mode will automatically disable:
//  1.) PHOSPHOR_MASK_MANUALLY_RESIZE: The phosphor mask will be softer.
//      (This may be reenabled in a later release.)
//  2.) RUNTIME_GEOMETRY_MODE
//  3.) The high-quality 4x4 Gaussian resize for the bloom approximation
    //#define INTEGRATED_GRAPHICS_COMPATIBILITY_MODE


////////////////////////////  USER CODEPATH OPTIONS  ///////////////////////////

//  To disable a #define option, turn its line into a comment with "//."

//  RUNTIME VS. COMPILE-TIME OPTIONS (Major Performance Implications):
//  Enable runtime shader parameters in the Retroarch (etc.) GUI?  They override
//  many of the options in this file and allow real-time tuning, but many of
//  them are slower.  Disabling them and using this text file will boost FPS.
#define RUNTIME_SHADER_PARAMS_ENABLE
//  Specify the phosphor bloom sigma at runtime?  This option is 10% slower, but
//  it's the only way to do a wide-enough full bloom with a runtime dot pitch.
#define RUNTIME_PHOSPHOR_BLOOM_SIGMA
//  Specify antialiasing weight parameters at runtime?  (Costs ~20% with cubics)
#define RUNTIME_ANTIALIAS_WEIGHTS
//  Specify subpixel offsets at runtime? (WARNING: EXTREMELY EXPENSIVE!)
//#define RUNTIME_ANTIALIAS_SUBPIXEL_OFFSETS
//  Make beam_horiz_filter and beam_horiz_linear_rgb_weight into runtime shader
//  parameters?  This will require more math or dynamic branching.
#define RUNTIME_SCANLINES_HORIZ_FILTER_COLORSPACE
//  Specify the tilt at runtime?  This makes things about 3% slower.
#define RUNTIME_GEOMETRY_TILT
//  Specify the geometry mode at runtime?
#define RUNTIME_GEOMETRY_MODE
//  Specify the phosphor mask type (aperture grille, slot mask, shadow mask) and
//  mode (Lanczos-resize, hardware resize, or tile 1:1) at runtime, even without
//  dynamic branches?  This is cheap if mask_resize_viewport_scale is small.
#define FORCE_RUNTIME_PHOSPHOR_MASK_MODE_TYPE_SELECT

//  PHOSPHOR MASK:
//  Manually resize the phosphor mask for best results (slower)?  Disabling this
//  removes the option to do so, but it may be faster without dynamic branches.
    #define PHOSPHOR_MASK_MANUALLY_RESIZE
//  If we sinc-resize the mask, should we Lanczos-window it (slower but better)?
    #define PHOSPHOR_MASK_RESIZE_LANCZOS_WINDOW
//  Larger blurs are expensive, but we need them to blur larger triads.  We can
//  detect the right blur if the triad size is static or our profile allows
//  dynamic branches, but otherwise we use the largest blur the user indicates
//  they might need:
    #define PHOSPHOR_BLOOM_TRIADS_LARGER_THAN_3_PIXELS
    //#define PHOSPHOR_BLOOM_TRIADS_LARGER_THAN_6_PIXELS
    //#define PHOSPHOR_BLOOM_TRIADS_LARGER_THAN_9_PIXELS
    //#define PHOSPHOR_BLOOM_TRIADS_LARGER_THAN_12_PIXELS
    //  Here's a helpful chart:
    //  MaxTriadSize    BlurSize    MinTriadCountsByResolution
    //  3.0             9.0         480/640/960/1920 triads at 1080p/1440p/2160p/4320p, 4:3 aspect
    //  6.0             17.0        240/320/480/960 triads at 1080p/1440p/2160p/4320p, 4:3 aspect
    //  9.0             25.0        160/213/320/640 triads at 1080p/1440p/2160p/4320p, 4:3 aspect
    //  12.0            31.0        120/160/240/480 triads at 1080p/1440p/2160p/4320p, 4:3 aspect
    //  18.0            43.0        80/107/160/320 triads at 1080p/1440p/2160p/4320p, 4:3 aspect


///////////////////////////////  USER PARAMETERS  //////////////////////////////

//  Note: Many of these static parameters are overridden by runtime shader
//  parameters when those are enabled.  However, many others are static codepath
//  options that were cleaner or more convert to code as static constants.

//  GAMMA:
    float crt_gamma_static = 2.5;                  //  range [1, 5]
    float lcd_gamma_static = 2.2;                  //  range [1, 5]

//  LEVELS MANAGEMENT:
    //  Control the final multiplicative image contrast:
    float levels_contrast_static = 1.0;            //  range [0, 4)
    //  We auto-dim to avoid clipping between passes and restore brightness
    //  later.  Control the dim factor here: Lower values clip less but crush
    //  blacks more (static only for now).
    float levels_autodim_temp = 0.5;               //  range (0, 1]

//  HALATION/DIFFUSION/BLOOM:
    //  Halation weight: How much energy should be lost to electrons bounding
    //  around under the CRT glass and exciting random phosphors?
    float halation_weight_static = 0.0;            //  range [0, 1]
    //  Refractive diffusion weight: How much light should spread/diffuse from
    //  refracting through the CRT glass?
    float diffusion_weight_static = 0.075;         //  range [0, 1]
    //  Underestimate brightness: Bright areas bloom more, but we can base the
    //  bloom brightpass on a lower brightness to sharpen phosphors, or a higher
    //  brightness to soften them.  Low values clip, but >= 0.8 looks okay.
    float bloom_underestimate_levels_static = 0.8; //  range [0, 5]
    //  Blur all colors more than necessary for a softer phosphor bloom?
    float bloom_excess_static = 0.0;               //  range [0, 1]
    //  The BLOOM_APPROX pass approximates a phosphor blur early on with a small
    //  blurred resize of the input (convergence offsets are applied as well).
    //  There are three filter options (static option only for now):
    //  0.) Bilinear resize: A fast, close approximation to a 4x4 resize
    //      if min_allowed_viewport_triads and the BLOOM_APPROX resolution are sane
    //      and beam_max_sigma is low.
    //  1.) 3x3 resize blur: Medium speed, soft/smeared from bilinear blurring,
    //      always uses a static sigma regardless of beam_max_sigma or
    //      mask_num_triads_desired.
    //  2.) True 4x4 Gaussian resize: Slowest, technically correct.
    //  These options are more pronounced for the fast, unbloomed shader version.
    float bloom_approx_filter_static = 2.0;

//  ELECTRON BEAM SCANLINE DISTRIBUTION:
    //  How many scanlines should contribute light to each pixel?  Using more
    //  scanlines is slower (especially for a generalized Gaussian) but less
    //  distorted with larger beam sigmas (especially for a pure Gaussian).  The
    //  max_beam_sigma at which the closest unused weight is guaranteed <
    //  1.0/255.0 (for a 3x antialiased pure Gaussian) is:
    //      2 scanlines: max_beam_sigma = 0.2089; distortions begin ~0.34; 141.7 FPS pure, 131.9 FPS generalized
    //      3 scanlines, max_beam_sigma = 0.3879; distortions begin ~0.52; 137.5 FPS pure; 123.8 FPS generalized
    //      4 scanlines, max_beam_sigma = 0.5723; distortions begin ~0.70; 134.7 FPS pure; 117.2 FPS generalized
    //      5 scanlines, max_beam_sigma = 0.7591; distortions begin ~0.89; 131.6 FPS pure; 112.1 FPS generalized
    //      6 scanlines, max_beam_sigma = 0.9483; distortions begin ~1.08; 127.9 FPS pure; 105.6 FPS generalized
    float beam_num_scanlines = 3.0;                //  range [2, 6]
    //  A generalized Gaussian beam varies shape with color too, now just width.
    //  It's slower but more flexible (static option only for now).
    bool beam_generalized_gaussian = true;
    //  What kind of scanline antialiasing do you want?
    //  0: Sample weights at 1x; 1: Sample weights at 3x; 2: Compute an integral
    //  Integrals are slow (especially for generalized Gaussians) and rarely any
    //  better than 3x antialiasing (static option only for now).
    float beam_antialias_level = 1.0;              //  range [0, 2]
    //  Min/max standard deviations for scanline beams: Higher values widen and
    //  soften scanlines.  Depending on other options, low min sigmas can alias.
    float beam_min_sigma_static = 0.02;            //  range (0, 1]
    float beam_max_sigma_static = 0.3;             //  range (0, 1]
    //  Beam width varies as a function of color: A power function (0) is more
    //  configurable, but a spherical function (1) gives the widest beam
    //  variability without aliasing (static option only for now).
    float beam_spot_shape_function = 0.0;
    //  Spot shape power: Powers <= 1 give smoother spot shapes but lower
    //  sharpness.  Powers >= 1.0 are awful unless mix/max sigmas are close.
    float beam_spot_power_static = 1.0/3.0;    //  range (0, 16]
    //  Generalized Gaussian max shape parameters: Higher values give flatter
    //  scanline plateaus and steeper dropoffs, simultaneously widening and
    //  sharpening scanlines at the cost of aliasing.  2.0 is pure Gaussian, and
    //  values > ~40.0 cause artifacts with integrals.
    float beam_min_shape_static = 2.0;         //  range [2, 32]
    float beam_max_shape_static = 4.0;         //  range [2, 32]
    //  Generalized Gaussian shape power: Affects how quickly the distribution
    //  changes shape from Gaussian to steep/plateaued as color increases from 0
    //  to 1.0.  Higher powers appear softer for most colors, and lower powers
    //  appear sharper for most colors.
    float beam_shape_power_static = 1.0/4.0;   //  range (0, 16]
    //  What filter should be used to sample scanlines horizontally?
    //  0: Quilez (fast), 1: Gaussian (configurable), 2: Lanczos2 (sharp)
    float beam_horiz_filter_static = 0.0;
    //  Standard deviation for horizontal Gaussian resampling:
    float beam_horiz_sigma_static = 0.35;      //  range (0, 2/3]
    //  Do horizontal scanline sampling in linear RGB (correct light mixing),
    //  gamma-encoded RGB (darker, hard spot shape, may better match bandwidth-
    //  limiting circuitry in some CRT's), or a weighted avg.?
    float beam_horiz_linear_rgb_weight_static = 1.0;   //  range [0, 1]
    //  Simulate scanline misconvergence?  This needs 3x horizontal texture
    //  samples and 3x texture samples of BLOOM_APPROX and HALATION_BLUR in
    //  later passes (static option only for now).
    bool beam_misconvergence = true;
    //  Convergence offsets in x/y directions for R/G/B scanline beams in units
    //  of scanlines.  Positive offsets go right/down; ranges [-2, 2]
    vec2 convergence_offsets_r_static = vec2(0.0, 0.0);
    vec2 convergence_offsets_g_static = vec2(0.0, 0.0);
    vec2 convergence_offsets_b_static = vec2(0.0, 0.0);
    //  Detect interlacing (static option only for now)?
    bool interlace_detect = true;
    //  Assume 1080-line sources are interlaced?
    bool interlace_1080i_static = false;
    //  For interlaced sources, assume TFF (top-field first) or BFF order?
    //  (Whether this matters depends on the nature of the interlaced input.)
    bool interlace_bff_static = false;

//  ANTIALIASING:
    //  What AA level do you want for curvature/overscan/subpixels?  Options:
    //  0x (none), 1x (sample subpixels), 4x, 5x, 6x, 7x, 8x, 12x, 16x, 20x, 24x
    //  (Static option only for now)
    float aa_level = 12.0;                     //  range [0, 24]
    //  What antialiasing filter do you want (static option only)?  Options:
    //  0: Box (separable), 1: Box (cylindrical),
    //  2: Tent (separable), 3: Tent (cylindrical),
    //  4: Gaussian (separable), 5: Gaussian (cylindrical),
    //  6: Cubic* (separable), 7: Cubic* (cylindrical, poor)
    //  8: Lanczos Sinc (separable), 9: Lanczos Jinc (cylindrical, poor)
    //      * = Especially slow with RUNTIME_ANTIALIAS_WEIGHTS
    float aa_filter = 6.0;                     //  range [0, 9]
    //  Flip the sample grid on odd/even frames (static option only for now)?
    bool aa_temporal = false;
    //  Use RGB subpixel offsets for antialiasing?  The pixel is at green, and
    //  the blue offset is the negative r offset; range [0, 0.5]
    vec2 aa_subpixel_r_offset_static = vec2(-1.0/3.0, 0.0);//vec2(0.0);
    //  Cubics: See http://www.imagemagick.org/Usage/filter/#mitchell
    //  1.) "Keys cubics" with B = 1 - 2C are considered the highest quality.
    //  2.) C = 0.5 (default) is Catmull-Rom; higher C's apply sharpening.
    //  3.) C = 1.0/3.0 is the Mitchell-Netravali filter.
    //  4.) C = 0.0 is a soft spline filter.
    float aa_cubic_c_static = 0.5;             //  range [0, 4]
    //  Standard deviation for Gaussian antialiasing: Try 0.5/aa_pixel_diameter.
    float aa_gauss_sigma_static = 0.5;     //  range [0.0625, 1.0]

//  PHOSPHOR MASK:
    //  Mask type: 0 = aperture grille, 1 = slot mask, 2 = EDP shadow mask
    float mask_type_static = 1.0;                  //  range [0, 2]
    //  We can sample the mask three ways.  Pick 2/3 from: Pretty/Fast/Flexible.
    //  0.) Sinc-resize to the desired dot pitch manually (pretty/slow/flexible).
    //      This requires PHOSPHOR_MASK_MANUALLY_RESIZE to be #defined.
    //  1.) Hardware-resize to the desired dot pitch (ugly/fast/flexible).  This
    //      is halfway decent with LUT mipmapping but atrocious without it.
    //  2.) Tile it without resizing at a 1:1 texel:pixel ratio for flat coords
    //      (pretty/fast/inflexible).  Each input LUT has a fixed dot pitch.
    //      This mode reuses the same masks, so triads will be enormous unless
    //      you change the mask LUT filenames in your .cgp file.
    float mask_sample_mode_static = 0.0;           //  range [0, 2]
    //  Prefer setting the triad size (0.0) or number on the screen (1.0)?
    //  If RUNTIME_PHOSPHOR_BLOOM_SIGMA isn't #defined, the specified triad size
    //  will always be used to calculate the full bloom sigma statically.
    float mask_specify_num_triads_static = 0.0;    //  range [0, 1]
    //  Specify the phosphor triad size, in pixels.  Each tile (usually with 8
    //  triads) will be rounded to the nearest integer tile size and clamped to
    //  obey minimum size constraints (imposed to reduce downsize taps) and
    //  maximum size constraints (imposed to have a sane MASK_RESIZE FBO size).
    //  To increase the size limit, double the viewport-relative scales for the
    //  two MASK_RESIZE passes in crt-royale.cgp and user-cgp-contants.h.
    //      range [1, mask_texture_small_size/mask_triads_per_tile]
//    float mask_triad_size_desired_static = 24.0 / 8.0;
    //  If mask_specify_num_triads is 1.0/true, we'll go by this instead (the
    //  final size will be rounded and constrained as above); default 480.0
    float mask_num_triads_desired_static = 480.0;
    //  How many lobes should the sinc/Lanczos resizer use?  More lobes require
    //  more samples and avoid moire a bit better, but some is unavoidable
    //  depending on the destination size (static option for now).
    float mask_sinc_lobes = 3.0;                   //  range [2, 4]
    //  The mask is resized using a variable number of taps in each dimension,
    //  but some Cg profiles always fetch a constant number of taps no matter
    //  what (no dynamic branching).  We can limit the maximum number of taps if
    //  we statically limit the minimum phosphor triad size.  Larger values are
    //  faster, but the limit IS enforced (static option only, forever);
    //      range [1, mask_texture_small_size/mask_triads_per_tile]
    //  TODO: Make this 1.0 and compensate with smarter sampling!
    float mask_min_allowed_triad_size = 2.0;

//  GEOMETRY:
    //  Geometry mode:
    //  0: Off (default), 1: Spherical mapping (like cgwg's),
    //  2: Alt. spherical mapping (more bulbous), 3: Cylindrical/Trinitron
    float geom_mode_static = 0.0;      //  range [0, 3]
    //  Radius of curvature: Measured in units of your viewport's diagonal size.
    float geom_radius_static = 2.0;    //  range [1/(2*pi), 1024]
    //  View dist is the distance from the player to their physical screen, in
    //  units of the viewport's diagonal size.  It controls the field of view.
    float geom_view_dist_static = 2.0; //  range [0.5, 1024]
    //  Tilt angle in radians (clockwise around up and right vectors):
    vec2 geom_tilt_angle_static = vec2(0.0, 0.0);  //  range [-pi, pi]
    //  Aspect ratio: When the true viewport size is unknown, this value is used
    //  to help convert between the phosphor triad size and count, along with
    //  the mask_resize_viewport_scale constant from user-cgp-constants.h.  Set
    //  this equal to Retroarch's display aspect ratio (DAR) for best results;
    //  range [1, geom_max_aspect_ratio from user-cgp-constants.h];
    //  default (256/224)*(54/47) = 1.313069909 (see below)
    float geom_aspect_ratio_static = 1.313069909;
    //  Before getting into overscan, here's some general aspect ratio info:
    //  - DAR = display aspect ratio = SAR * PAR; as in your Retroarch setting
    //  - SAR = storage aspect ratio = DAR / PAR; square pixel emulator frame AR
    //  - PAR = pixel aspect ratio   = DAR / SAR; holds regardless of cropping
    //  Geometry processing has to "undo" the screen-space 2D DAR to calculate
    //  3D view vectors, then reapplies the aspect ratio to the simulated CRT in
    //  uv-space.  To ensure the source SAR is intended for a ~4:3 DAR, either:
    //  a.) Enable Retroarch's "Crop Overscan"
    //  b.) Readd horizontal padding: Set overscan to e.g. N*(1.0, 240.0/224.0)
    //  Real consoles use horizontal black padding in the signal, but emulators
    //  often crop this without cropping the vertical padding; a 256x224 [S]NES
    //  frame (8:7 SAR) is intended for a ~4:3 DAR, but a 256x240 frame is not.
    //  The correct [S]NES PAR is 54:47, found by blargg and NewRisingSun:
    //      http://board.zsnes.com/phpBB3/viewtopic.php?f=22&t=11928&start=50
    //      http://forums.nesdev.com/viewtopic.php?p=24815#p24815
    //  For flat output, it's okay to set DAR = [existing] SAR * [correct] PAR
    //  without doing a. or b., but horizontal image borders will be tighter
    //  than vertical ones, messing up curvature and overscan.  Fixing the
    //  padding first corrects this.
    //  Overscan: Amount to "zoom in" before cropping.  You can zoom uniformly
    //  or adjust x/y independently to e.g. readd horizontal padding, as noted
    //  above: Values < 1.0 zoom out; range (0, inf)
    vec2 geom_overscan_static = vec2(1.0, 1.0);// * 1.005 * (1.0, 240/224.0)
    //  Compute a proper pixel-space to texture-space matrix even without ddx()/
    //  ddy()?  This is ~8.5% slower but improves antialiasing/subpixel filtering
    //  with strong curvature (static option only for now).
    bool geom_force_correct_tangent_matrix = true;

//  BORDERS:
    //  Rounded border size in texture uv coords:
    float border_size_static = 0.015;           //  range [0, 0.5]
    //  Border darkness: Moderate values darken the border smoothly, and high
    //  values make the image very dark just inside the border:
    float border_darkness_static = 2.0;        //  range [0, inf)
    //  Border compression: High numbers compress border transitions, narrowing
    //  the dark border area.
    float border_compress_static = 2.5;        //  range [1, inf)


#endif  //  USER_SETTINGS_H

#ifndef BIND_SHADER_PARAMS_H
#define BIND_SHADER_PARAMS_H

/////////////////////////////  GPL LICENSE NOTICE  /////////////////////////////

//  crt-royale: A full-featured CRT shader, with cheese.
//  Copyright (C) 2014 TroggleMonkey <trogglemonkey@gmx.com>
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along with
//  this program; if not, write to the Free Software Foundation, Inc., 59 Temple
//  Place, Suite 330, Boston, MA 02111-1307 USA


/////////////////////////////  SETTINGS MANAGEMENT  ////////////////////////////

//#include "../user-settings.h"
////////////////   BEGIN #include "derived-settings-and-constants.h"   /////////
#ifndef DERIVED_SETTINGS_AND_CONSTANTS_H
#define DERIVED_SETTINGS_AND_CONSTANTS_H

/////////////////////////////  GPL LICENSE NOTICE  /////////////////////////////

//  crt-royale: A full-featured CRT shader, with cheese.
//  Copyright (C) 2014 TroggleMonkey <trogglemonkey@gmx.com>
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along with
//  this program; if not, write to the Free Software Foundation, Inc., 59 Temple
//  Place, Suite 330, Boston, MA 02111-1307 USA


/////////////////////////////////  DESCRIPTION  ////////////////////////////////

//  These macros and constants can be used across the whole codebase.
//  Unlike the values in user-settings.cgh, end users shouldn't modify these.


//////////////////////////////////  INCLUDES  //////////////////////////////////

//#include "../user-settings.h"
/////////////////////   BEGIN #include "user-preset-constants.h"   /////////////
#ifndef USER_CGP_CONSTANTS_H
#define USER_CGP_CONSTANTS_H

//  IMPORTANT:
//  These constants MUST be set appropriately for the settings in crt-royale.cgp
//  (or whatever related .cgp file you're using).  If they aren't, you're likely
//  to get artifacts, the wrong phosphor mask size, etc.  I wish these could be
//  set directly in the .cgp file to make things easier, but...they can't.

//  PASS SCALES AND RELATED CONSTANTS:
//  Copy the absolute scale_x for BLOOM_APPROX.  There are two major versions of
//  this shader: One does a viewport-scale bloom, and the other skips it.  The
//  latter benefits from a higher bloom_approx_scale_x, so save both separately:
float bloom_approx_size_x = 320.0;
float bloom_approx_scale_x = 320.0; //dunno why this is necessary
float bloom_approx_size_x_for_fake = 400.0;
//  Copy the viewport-relative scales of the phosphor mask resize passes
//  (MASK_RESIZE and the pass immediately preceding it):
vec2 mask_resize_viewport_scale = vec2(0.0625, 0.0625);
//  Copy the geom_max_aspect_ratio used to calculate the MASK_RESIZE scales, etc.:
float geom_max_aspect_ratio = 4.0/3.0;

//  PHOSPHOR MASK TEXTURE CONSTANTS:
//  Set the following constants to reflect the properties of the phosphor mask
//  texture named in crt-royale.cgp.  The shader optionally resizes a mask tile
//  based on user settings, then repeats a single tile until filling the screen.
//  The shader must know the input texture size (default 64x64), and to manually
//  resize, it must also know the horizontal triads per tile (default 8).
vec2 mask_texture_small_size = vec2(64.0);
vec2 mask_texture_large_size = vec2(512.0);
float mask_triads_per_tile = 8.0;
//  We need the average brightness of the phosphor mask to compensate for the
//  dimming it causes.  The following four values are roughly correct for the
//  masks included with the shader.  Update the value for any LUT texture you
//  change.  [Un]comment "#define PHOSPHOR_MASK_GRILLE14" depending on whether
//  the loaded aperture grille uses 14-pixel or 15-pixel stripes (default 15).
//#define PHOSPHOR_MASK_GRILLE14
float mask_grille14_avg_color = 50.6666666/255.0;
    //  TileableLinearApertureGrille14Wide7d33Spacing*.png
    //  TileableLinearApertureGrille14Wide10And6Spacing*.png
float mask_grille15_avg_color = 53.0/255.0;
    //  TileableLinearApertureGrille15Wide6d33Spacing*.png
    //  TileableLinearApertureGrille15Wide8And5d5Spacing*.png
float mask_slot_avg_color = 46.0/255.0;
    //  TileableLinearSlotMask15Wide9And4d5Horizontal8VerticalSpacing*.png
    //  TileableLinearSlotMaskTall15Wide9And4d5Horizontal9d14VerticalSpacing*.png
float mask_shadow_avg_color = 41.0/255.0;
    //  TileableLinearShadowMask*.png
    //  TileableLinearShadowMaskEDP*.png

#ifdef PHOSPHOR_MASK_GRILLE14
    float mask_grille_avg_color = mask_grille14_avg_color;
#else
    float mask_grille_avg_color = mask_grille15_avg_color;
#endif


#endif  //  USER_CGP_CONSTANTS_H


/////////////////////   END #include "user-preset-constants.h"   ///////////////


///////////////////////////////  FIXED SETTINGS  ///////////////////////////////

//  Avoid dividing by zero; using a macro overloads for float, vec2, etc.:
#define FIX_ZERO(c) (max(abs(c), 0.0000152587890625))   //  2^-16

//  Ensure the first pass decodes CRT gamma and the last encodes LCD gamma.
#ifndef SIMULATE_CRT_ON_LCD
    #define SIMULATE_CRT_ON_LCD
#endif

//  Manually tiling a manually resized texture creates texture coord derivative
//  discontinuities and confuses anisotropic filtering, causing discolored tile
//  seams in the phosphor mask.  Workarounds:
//  a.) Using tex2Dlod disables anisotropic filtering for tiled masks.  It's
//      downgraded to tex2Dbias without DRIVERS_ALLOW_TEX2DLOD #defined and
//      disabled without DRIVERS_ALLOW_TEX2DBIAS #defined either.
//  b.) "Tile flat twice" requires drawing two full tiles without border padding
//      to the resized mask FBO, and it's incompatible with same-pass curvature.
//      (Same-pass curvature isn't used but could be in the future...maybe.)
//  c.) "Fix discontinuities" requires derivatives and drawing one tile with
//      border padding to the resized mask FBO, but it works with same-pass
//      curvature.  It's disabled without DRIVERS_ALLOW_DERIVATIVES #defined.
//  Precedence: a, then, b, then c (if multiple strategies are #defined).
    #define ANISOTROPIC_TILING_COMPAT_TEX2DLOD              //  129.7 FPS, 4x, flat; 101.8 at fullscreen
    #define ANISOTROPIC_TILING_COMPAT_TILE_FLAT_TWICE       //  128.1 FPS, 4x, flat; 101.5 at fullscreen
    #define ANISOTROPIC_TILING_COMPAT_FIX_DISCONTINUITIES   //  124.4 FPS, 4x, flat; 97.4 at fullscreen
//  Also, manually resampling the phosphor mask is slightly blurrier with
//  anisotropic filtering.  (Resampling with mipmapping is even worse: It
//  creates artifacts, but only with the fully bloomed shader.)  The difference
//  is subtle with small triads, but you can fix it for a small cost.
    //#define ANISOTROPIC_RESAMPLING_COMPAT_TEX2DLOD


//////////////////////////////  DERIVED SETTINGS  //////////////////////////////

//  Intel HD 4000 GPU's can't handle manual mask resizing (for now), setting the
//  geometry mode at runtime, or a 4x4 true Gaussian resize.  Disable
//  incompatible settings ASAP.  (INTEGRATED_GRAPHICS_COMPATIBILITY_MODE may be
//  #defined by either user-settings.h or a wrapper .cg that #includes the
//  current .cg pass.)
#ifdef INTEGRATED_GRAPHICS_COMPATIBILITY_MODE
    #ifdef PHOSPHOR_MASK_MANUALLY_RESIZE
        #undef PHOSPHOR_MASK_MANUALLY_RESIZE
    #endif
    #ifdef RUNTIME_GEOMETRY_MODE
        #undef RUNTIME_GEOMETRY_MODE
    #endif
    //  Mode 2 (4x4 Gaussian resize) won't work, and mode 1 (3x3 blur) is
    //  inferior in most cases, so replace 2.0 with 0.0:
     float bloom_approx_filter =
        bloom_approx_filter_static > 1.5 ? 0.0 : bloom_approx_filter_static;
#else
     float bloom_approx_filter = bloom_approx_filter_static;
#endif

//  Disable slow runtime paths if static parameters are used.  Most of these
//  won't be a problem anyway once the params are disabled, but some will.
#ifndef RUNTIME_SHADER_PARAMS_ENABLE
    #ifdef RUNTIME_PHOSPHOR_BLOOM_SIGMA
        #undef RUNTIME_PHOSPHOR_BLOOM_SIGMA
    #endif
    #ifdef RUNTIME_ANTIALIAS_WEIGHTS
        #undef RUNTIME_ANTIALIAS_WEIGHTS
    #endif
    #ifdef RUNTIME_ANTIALIAS_SUBPIXEL_OFFSETS
        #undef RUNTIME_ANTIALIAS_SUBPIXEL_OFFSETS
    #endif
    #ifdef RUNTIME_SCANLINES_HORIZ_FILTER_COLORSPACE
        #undef RUNTIME_SCANLINES_HORIZ_FILTER_COLORSPACE
    #endif
    #ifdef RUNTIME_GEOMETRY_TILT
        #undef RUNTIME_GEOMETRY_TILT
    #endif
    #ifdef RUNTIME_GEOMETRY_MODE
        #undef RUNTIME_GEOMETRY_MODE
    #endif
    #ifdef FORCE_RUNTIME_PHOSPHOR_MASK_MODE_TYPE_SELECT
        #undef FORCE_RUNTIME_PHOSPHOR_MASK_MODE_TYPE_SELECT
    #endif
#endif

//  Make tex2Dbias a backup for tex2Dlod for wider compatibility.
#ifdef ANISOTROPIC_TILING_COMPAT_TEX2DLOD
    #define ANISOTROPIC_TILING_COMPAT_TEX2DBIAS
#endif
#ifdef ANISOTROPIC_RESAMPLING_COMPAT_TEX2DLOD
    #define ANISOTROPIC_RESAMPLING_COMPAT_TEX2DBIAS
#endif
//  Rule out unavailable anisotropic compatibility strategies:
#ifndef DRIVERS_ALLOW_DERIVATIVES
    #ifdef ANISOTROPIC_TILING_COMPAT_FIX_DISCONTINUITIES
        #undef ANISOTROPIC_TILING_COMPAT_FIX_DISCONTINUITIES
    #endif
#endif
#ifndef DRIVERS_ALLOW_TEX2DLOD
    #ifdef ANISOTROPIC_TILING_COMPAT_TEX2DLOD
        #undef ANISOTROPIC_TILING_COMPAT_TEX2DLOD
    #endif
    #ifdef ANISOTROPIC_RESAMPLING_COMPAT_TEX2DLOD
        #undef ANISOTROPIC_RESAMPLING_COMPAT_TEX2DLOD
    #endif
    #ifdef ANTIALIAS_DISABLE_ANISOTROPIC
        #undef ANTIALIAS_DISABLE_ANISOTROPIC
    #endif
#endif
#ifndef DRIVERS_ALLOW_TEX2DBIAS
    #ifdef ANISOTROPIC_TILING_COMPAT_TEX2DBIAS
        #undef ANISOTROPIC_TILING_COMPAT_TEX2DBIAS
    #endif
    #ifdef ANISOTROPIC_RESAMPLING_COMPAT_TEX2DBIAS
        #undef ANISOTROPIC_RESAMPLING_COMPAT_TEX2DBIAS
    #endif
#endif
//  Prioritize anisotropic tiling compatibility strategies by performance and
//  disable unused strategies.  This concentrates all the nesting in one place.
#ifdef ANISOTROPIC_TILING_COMPAT_TEX2DLOD
    #ifdef ANISOTROPIC_TILING_COMPAT_TEX2DBIAS
        #undef ANISOTROPIC_TILING_COMPAT_TEX2DBIAS
    #endif
    #ifdef ANISOTROPIC_TILING_COMPAT_TILE_FLAT_TWICE
        #undef ANISOTROPIC_TILING_COMPAT_TILE_FLAT_TWICE
    #endif
    #ifdef ANISOTROPIC_TILING_COMPAT_FIX_DISCONTINUITIES
        #undef ANISOTROPIC_TILING_COMPAT_FIX_DISCONTINUITIES
    #endif
#else
    #ifdef ANISOTROPIC_TILING_COMPAT_TEX2DBIAS
        #ifdef ANISOTROPIC_TILING_COMPAT_TILE_FLAT_TWICE
            #undef ANISOTROPIC_TILING_COMPAT_TILE_FLAT_TWICE
        #endif
        #ifdef ANISOTROPIC_TILING_COMPAT_FIX_DISCONTINUITIES
            #undef ANISOTROPIC_TILING_COMPAT_FIX_DISCONTINUITIES
        #endif
    #else
        //  ANISOTROPIC_TILING_COMPAT_TILE_FLAT_TWICE is only compatible with
        //  flat texture coords in the same pass, but that's all we use.
        #ifdef ANISOTROPIC_TILING_COMPAT_TILE_FLAT_TWICE
            #ifdef ANISOTROPIC_TILING_COMPAT_FIX_DISCONTINUITIES
                #undef ANISOTROPIC_TILING_COMPAT_FIX_DISCONTINUITIES
            #endif
        #endif
    #endif
#endif
//  The tex2Dlod and tex2Dbias strategies share a lot in common, and we can
//  reduce some #ifdef nesting in the next section by essentially OR'ing them:
#ifdef ANISOTROPIC_TILING_COMPAT_TEX2DLOD
    #define ANISOTROPIC_TILING_COMPAT_TEX2DLOD_FAMILY
#endif
#ifdef ANISOTROPIC_TILING_COMPAT_TEX2DBIAS
    #define ANISOTROPIC_TILING_COMPAT_TEX2DLOD_FAMILY
#endif
//  Prioritize anisotropic resampling compatibility strategies the same way:
#ifdef ANISOTROPIC_RESAMPLING_COMPAT_TEX2DLOD
    #ifdef ANISOTROPIC_RESAMPLING_COMPAT_TEX2DBIAS
        #undef ANISOTROPIC_RESAMPLING_COMPAT_TEX2DBIAS
    #endif
#endif


///////////////////////  DERIVED PHOSPHOR MASK CONSTANTS  //////////////////////

//  If we can use the large mipmapped LUT without mipmapping artifacts, we
//  should: It gives us more options for using fewer samples.
#ifdef DRIVERS_ALLOW_TEX2DLOD
    #ifdef ANISOTROPIC_RESAMPLING_COMPAT_TEX2DLOD
        //  TODO: Take advantage of this!
        #define PHOSPHOR_MASK_RESIZE_MIPMAPPED_LUT
         vec2 mask_resize_src_lut_size = mask_texture_large_size;
    #else
         vec2 mask_resize_src_lut_size = mask_texture_small_size;
    #endif
#else
     vec2 mask_resize_src_lut_size = mask_texture_small_size;
#endif


//  tex2D's sampler2D parameter MUST be a uniform global, a uniform input to
//  main_fragment, or a static alias of one of the above.  This makes it hard
//  to select the phosphor mask at runtime: We can't even assign to a uniform
//  global in the vertex shader or select a sampler2D in the vertex shader and
//  pass it to the fragment shader (even with explicit TEXUNIT# bindings),
//  because it just gives us the input texture or a black screen.  However, we
//  can get around these limitations by calling tex2D three times with different
//  uniform samplers (or resizing the phosphor mask three times altogether).
//  With dynamic branches, we can process only one of these branches on top of
//  quickly discarding fragments we don't need (cgc seems able to overcome
//  limigations around dependent texture fetches inside of branches).  Without
//  dynamic branches, we have to process every branch for every fragment...which
//  is slower.  Runtime sampling mode selection is slower without dynamic
//  branches as well.  Let the user's static #defines decide if it's worth it.
#ifdef DRIVERS_ALLOW_DYNAMIC_BRANCHES
    #define RUNTIME_PHOSPHOR_MASK_MODE_TYPE_SELECT
#else
    #ifdef FORCE_RUNTIME_PHOSPHOR_MASK_MODE_TYPE_SELECT
        #define RUNTIME_PHOSPHOR_MASK_MODE_TYPE_SELECT
    #endif
#endif

//  We need to render some minimum number of tiles in the resize passes.
//  We need at least 1.0 just to repeat a single tile, and we need extra
//  padding beyond that for anisotropic filtering, discontinuitity fixing,
//  antialiasing, same-pass curvature (not currently used), etc.  First
//  determine how many border texels and tiles we need, based on how the result
//  will be sampled:
#ifdef GEOMETRY_EARLY
         float max_subpixel_offset = aa_subpixel_r_offset_static.x;
        //  Most antialiasing filters have a base radius of 4.0 pixels:
         float max_aa_base_pixel_border = 4.0 +
            max_subpixel_offset;
#else
     float max_aa_base_pixel_border = 0.0;
#endif
//  Anisotropic filtering adds about 0.5 to the pixel border:
#ifndef ANISOTROPIC_TILING_COMPAT_TEX2DLOD_FAMILY
     float max_aniso_pixel_border = max_aa_base_pixel_border + 0.5;
#else
     float max_aniso_pixel_border = max_aa_base_pixel_border;
#endif
//  Fixing discontinuities adds 1.0 more to the pixel border:
#ifdef ANISOTROPIC_TILING_COMPAT_FIX_DISCONTINUITIES
     float max_tiled_pixel_border = max_aniso_pixel_border + 1.0;
#else
     float max_tiled_pixel_border = max_aniso_pixel_border;
#endif
//  Convert the pixel border to an integer texel border.  Assume same-pass
//  curvature about triples the texel frequency:
#ifdef GEOMETRY_EARLY
     float max_mask_texel_border =
        ceil(max_tiled_pixel_border * 3.0);
#else
     float max_mask_texel_border = ceil(max_tiled_pixel_border);
#endif
//  Convert the texel border to a tile border using worst-case assumptions:
 float max_mask_tile_border = max_mask_texel_border/
    (mask_min_allowed_triad_size * mask_triads_per_tile);

//  Finally, set the number of resized tiles to render to MASK_RESIZE, and set
//  the starting texel (inside borders) for sampling it.
#ifndef GEOMETRY_EARLY
    #ifdef ANISOTROPIC_TILING_COMPAT_TILE_FLAT_TWICE
        //  Special case: Render two tiles without borders.  Anisotropic
        //  filtering doesn't seem to be a problem here.
         float mask_resize_num_tiles = 1.0 + 1.0;
         float mask_start_texels = 0.0;
    #else
         float mask_resize_num_tiles = 1.0 +
            2.0 * max_mask_tile_border;
         float mask_start_texels = max_mask_texel_border;
    #endif
#else
     float mask_resize_num_tiles = 1.0 + 2.0*max_mask_tile_border;
     float mask_start_texels = max_mask_texel_border;
#endif

//  We have to fit mask_resize_num_tiles into an FBO with a viewport scale of
//  mask_resize_viewport_scale.  This limits the maximum final triad size.
//  Estimate the minimum number of triads we can split the screen into in each
//  dimension (we'll be as correct as mask_resize_viewport_scale is):
 float mask_resize_num_triads =
    mask_resize_num_tiles * mask_triads_per_tile;
 vec2 min_allowed_viewport_triads =
    vec2(mask_resize_num_triads) / mask_resize_viewport_scale;


////////////////////////  COMMON MATHEMATICAL CONSTANTS  ///////////////////////

 float pi = 3.141592653589;
//  We often want to find the location of the previous texel, e.g.:
//      vec2 curr_texel = uv * texture_size;
//      vec2 prev_texel = floor(curr_texel - vec2(0.5)) + vec2(0.5);
//      vec2 prev_texel_uv = prev_texel / texture_size;
//  However, many GPU drivers round incorrectly around exact texel locations.
//  We need to subtract a little less than 0.5 before flooring, and some GPU's
//  require this value to be farther from 0.5 than others; define it here.
//      vec2 prev_texel =
//          floor(curr_texel - vec2(under_half)) + vec2(0.5);
 float under_half = 0.4995;


#endif  //  DERIVED_SETTINGS_AND_CONSTANTS_H


////////////////   END #include "derived-settings-and-constants.h"   ///////////

//  Override some parameters for gamma-management.h and tex2Dantialias.h:
#define OVERRIDE_DEVICE_GAMMA
float gba_gamma = 3.5; //  Irrelevant but necessary to define.
#define ANTIALIAS_OVERRIDE_BASICS
#define ANTIALIAS_OVERRIDE_PARAMETERS

//  Provide accessors for vector constants that pack scalar uniforms:
vec2 get_aspect_vector(float geom_aspect_ratio)
{
    //  Get an aspect ratio vector.  Enforce geom_max_aspect_ratio, and prevent
    //  the absolute scale from affecting the uv-mapping for curvature:
    float geom_clamped_aspect_ratio =
        min(geom_aspect_ratio, geom_max_aspect_ratio);
    vec2 geom_aspect =
        normalize(vec2(geom_clamped_aspect_ratio, 1.0));
    return geom_aspect;
}

vec2 get_geom_overscan_vector()
{
    return vec2(geom_overscan_x, geom_overscan_y);
}

vec2 get_geom_tilt_angle_vector()
{
    return vec2(geom_tilt_angle_x, geom_tilt_angle_y);
}

vec3 get_convergence_offsets_x_vector()
{
    return vec3(convergence_offset_x_r, convergence_offset_x_g,
        convergence_offset_x_b);
}

vec3 get_convergence_offsets_y_vector()
{
    return vec3(convergence_offset_y_r, convergence_offset_y_g,
        convergence_offset_y_b);
}

vec2 get_convergence_offsets_r_vector()
{
    return vec2(convergence_offset_x_r, convergence_offset_y_r);
}

vec2 get_convergence_offsets_g_vector()
{
    return vec2(convergence_offset_x_g, convergence_offset_y_g);
}

vec2 get_convergence_offsets_b_vector()
{
    return vec2(convergence_offset_x_b, convergence_offset_y_b);
}

vec2 get_aa_subpixel_r_offset()
{
    #ifdef RUNTIME_ANTIALIAS_WEIGHTS
        #ifdef RUNTIME_ANTIALIAS_SUBPIXEL_OFFSETS
            //  WARNING: THIS IS EXTREMELY EXPENSIVE.
            return vec2(aa_subpixel_r_offset_x_runtime,
                aa_subpixel_r_offset_y_runtime);
        #else
            return aa_subpixel_r_offset_static;
        #endif
    #else
        return aa_subpixel_r_offset_static;
    #endif
}

//  Provide accessors settings which still need "cooking:"
float get_mask_amplify()
{
    float mask_grille_amplify = 1.0/mask_grille_avg_color;
    float mask_slot_amplify = 1.0/mask_slot_avg_color;
    float mask_shadow_amplify = 1.0/mask_shadow_avg_color;
    return mask_type < 0.5 ? mask_grille_amplify :
        mask_type < 1.5 ? mask_slot_amplify :
        mask_shadow_amplify;
}

float get_mask_sample_mode()
{
    #ifdef RUNTIME_PHOSPHOR_MASK_MODE_TYPE_SELECT
        #ifdef PHOSPHOR_MASK_MANUALLY_RESIZE
            return mask_sample_mode_desired;
        #else
            return clamp(mask_sample_mode_desired, 1.0, 2.0);
        #endif
    #else
        #ifdef PHOSPHOR_MASK_MANUALLY_RESIZE
            return mask_sample_mode_static;
        #else
            return clamp(mask_sample_mode_static, 1.0, 2.0);
        #endif
    #endif
}


#endif  //  BIND_SHADER_PARAMS_H

/////////////   BEGIN #include gamma-management.h   ///////////////////
#ifndef GAMMA_MANAGEMENT_H
#define GAMMA_MANAGEMENT_H

///////////////////////////////  BASE CONSTANTS  ///////////////////////////////

//  Set standard gamma constants, but allow users to override them:
#ifndef OVERRIDE_STANDARD_GAMMA
    //  Standard encoding gammas:
    float ntsc_gamma = 2.2;    //  Best to use NTSC for PAL too?
    float pal_gamma = 2.8;     //  Never actually 2.8 in practice
    //  Typical device decoding gammas (only use for emulating devices):
    //  CRT/LCD reference gammas are higher than NTSC and Rec.709 video standard
    //  gammas: The standards purposely undercorrected for an analog CRT's
    //  assumed 2.5 reference display gamma to maintain contrast in assumed
    //  [dark] viewing conditions: http://www.poynton.com/PDFs/GammaFAQ.pdf
    //  These unstated assumptions about display gamma and perceptual rendering
    //  intent caused a lot of confusion, and more modern CRT's seemed to target
    //  NTSC 2.2 gamma with circuitry.  LCD displays seem to have followed suit
    //  (they struggle near black with 2.5 gamma anyway), especially PC/laptop
    //  displays designed to view sRGB in bright environments.  (Standards are
    //  also in flux again with BT.1886, but it's underspecified for displays.)
    float crt_reference_gamma_high = 2.5;  //  In (2.35, 2.55)
    float crt_reference_gamma_low = 2.35;  //  In (2.35, 2.55)
    float lcd_reference_gamma = 2.5;       //  To match CRT
    float crt_office_gamma = 2.2;  //  Circuitry-adjusted for NTSC
    float lcd_office_gamma = 2.2;  //  Approximates sRGB
#endif  //  OVERRIDE_STANDARD_GAMMA

//  Assuming alpha == 1.0 might make it easier for users to avoid some bugs,
//  but only if they're aware of it.
#ifndef OVERRIDE_ALPHA_ASSUMPTIONS
    bool assume_opaque_alpha = false;
#endif


///////////////////////  DERIVED CONSTANTS AS FUNCTIONS  ///////////////////////

//  gamma-management.h should be compatible with overriding gamma values with
//  runtime user parameters, but we can only define other global constants in
//  terms of static constants, not uniform user parameters.  To get around this
//  limitation, we need to define derived constants using functions.

//  Set device gamma constants, but allow users to override them:
#ifdef OVERRIDE_DEVICE_GAMMA
    //  The user promises to globally define the appropriate constants:
    float get_crt_gamma()    {   return crt_gamma;   }
    float get_gba_gamma()    {   return gba_gamma;   }
    float get_lcd_gamma()    {   return lcd_gamma;   }
#else
    float get_crt_gamma()    {   return crt_reference_gamma_high;    }
    float get_gba_gamma()    {   return 3.5; }   //  Game Boy Advance; in (3.0, 4.0)
    float get_lcd_gamma()    {   return lcd_office_gamma;            }
#endif  //  OVERRIDE_DEVICE_GAMMA

//  Set decoding/encoding gammas for the first/lass passes, but allow overrides:
#ifdef OVERRIDE_FINAL_GAMMA
    //  The user promises to globally define the appropriate constants:
    float get_intermediate_gamma()   {   return intermediate_gamma;  }
    float get_input_gamma()          {   return input_gamma;         }
    float get_output_gamma()         {   return output_gamma;        }
#else
    //  If we gamma-correct every pass, always use ntsc_gamma between passes to
    //  ensure middle passes don't need to care if anything is being simulated:
    float get_intermediate_gamma()   {   return ntsc_gamma;          }
    #ifdef SIMULATE_CRT_ON_LCD
        float get_input_gamma()      {   return get_crt_gamma();     }
        float get_output_gamma()     {   return get_lcd_gamma();     }
    #else
    #ifdef SIMULATE_GBA_ON_LCD
        float get_input_gamma()      {   return get_gba_gamma();     }
        float get_output_gamma()     {   return get_lcd_gamma();     }
    #else
    #ifdef SIMULATE_LCD_ON_CRT
        float get_input_gamma()      {   return get_lcd_gamma();     }
        float get_output_gamma()     {   return get_crt_gamma();     }
    #else
    #ifdef SIMULATE_GBA_ON_CRT
        float get_input_gamma()      {   return get_gba_gamma();     }
        float get_output_gamma()     {   return get_crt_gamma();     }
    #else   //  Don't simulate anything:
        float get_input_gamma()      {   return ntsc_gamma;          }
        float get_output_gamma()     {   return ntsc_gamma;          }
    #endif  //  SIMULATE_GBA_ON_CRT
    #endif  //  SIMULATE_LCD_ON_CRT
    #endif  //  SIMULATE_GBA_ON_LCD
    #endif  //  SIMULATE_CRT_ON_LCD
#endif  //  OVERRIDE_FINAL_GAMMA

#ifndef GAMMA_ENCODE_EVERY_FBO
    #ifdef FIRST_PASS
        bool linearize_input = true;
        float get_pass_input_gamma()     {   return get_input_gamma();   }
    #else
        bool linearize_input = false;
        float get_pass_input_gamma()     {   return 1.0;                 }
    #endif
    #ifdef LAST_PASS
        bool gamma_encode_output = true;
        float get_pass_output_gamma()    {   return get_output_gamma();  }
    #else
        bool gamma_encode_output = false;
        float get_pass_output_gamma()    {   return 1.0;                 }
    #endif
#else
    bool linearize_input = true;
    bool gamma_encode_output = true;
    #ifdef FIRST_PASS
        float get_pass_input_gamma()     {   return get_input_gamma();   }
    #else
        float get_pass_input_gamma()     {   return get_intermediate_gamma();    }
    #endif
    #ifdef LAST_PASS
        float get_pass_output_gamma()    {   return get_output_gamma();  }
    #else
        float get_pass_output_gamma()    {   return get_intermediate_gamma();    }
    #endif
#endif

vec4 decode_input(vec4 color)
{
    if(linearize_input = true)
    {
        if(assume_opaque_alpha = true)
        {
            return vec4(pow(color.rgb, vec3(get_pass_input_gamma())), 1.0);
        }
        else
        {
            return vec4(pow(color.rgb, vec3(get_pass_input_gamma())), color.a);
        }
    }
    else
    {
        return color;
    }
}

vec4 encode_output(vec4 color)
{
    if(gamma_encode_output = true)
    {
        if(assume_opaque_alpha = true)
        {
            return vec4(pow(color.rgb, vec3(1.0/get_pass_output_gamma())), 1.0);
        }
        else
        {
            return vec4(pow(color.rgb, vec3(1.0/get_pass_output_gamma())), color.a);
        }
    }
    else
    {
        return color;
    }
}

#define tex2D_linearize(C, D) decode_input(vec4(texture(C, D)))
//vec4 tex2D_linearize(sampler2D tex, vec2 tex_coords)
//{   return decode_input(vec4(texture(tex, tex_coords)));   }

//#define tex2D_linearize(C, D, E) decode_input(vec4(texture(C, D, E)))
//vec4 tex2D_linearize(sampler2D tex, vec2 tex_coords, int texel_off)
//{   return decode_input(vec4(texture(tex, tex_coords, texel_off)));    }

#endif  //  GAMMA_MANAGEMENT_H
/////////////   END #include gamma-management.h     ///////////////////

///////////   BEGIN #include scanline-functions.h     /////////////////
#ifndef SCANLINE_FUNCTIONS_H
#define SCANLINE_FUNCTIONS_H

//////////////////////////////////  INCLUDES  //////////////////////////////////

//#include "../user-settings.h"
//#include "derived-settings-and-constants.h"
/////////   BEGIN #include "../../../../include/special-functions.h"   /////////
#ifndef SPECIAL_FUNCTIONS_H
#define SPECIAL_FUNCTIONS_H


/////////////////////////////////  MIT LICENSE  ////////////////////////////////

//  Copyright (C) 2014 TroggleMonkey
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.


/////////////////////////////////  DESCRIPTION  ////////////////////////////////

//  This file implements the following mathematical special functions:
//  1.) erf() = 2/sqrt(pi) * indefinite_integral(e**(-x**2))
//  2.) gamma(s), a real-numbered extension of the integer factorial function
//  It also implements normalized_ligamma(s, z), a normalized lower incomplete
//  gamma function for s < 0.5 only.  Both gamma() and normalized_ligamma() can
//  be called with an _impl suffix to use an implementation version with a few
//  extra precomputed parameters (which may be useful for the caller to reuse).
//  See below for details.
//
//  Design Rationale:
//  Pretty much every line of code in this file is duplicated four times for
//  different input types (vec4/vec3/vec2/float).  This is unfortunate,
//  but Cg doesn't allow function templates.  Macros would be far less verbose,
//  but they would make the code harder to document and read.  I don't expect
//  these functions will require a whole lot of maintenance changes unless
//  someone ever has need for more robust incomplete gamma functions, so code
//  duplication seems to be the lesser evil in this case.


///////////////////////////  GAUSSIAN ERROR FUNCTION  //////////////////////////

vec4 erf6(vec4 x)
{
    //  Requires:   x is the standard parameter to erf().
    //  Returns:    Return an Abramowitz/Stegun approximation of erf(), where:
    //                  erf(x) = 2/sqrt(pi) * integral(e**(-x**2))
    //              This approximation has a max absolute error of 2.5*10**-5
    //              with solid numerical robustness and efficiency.  See:
	//                  https://en.wikipedia.org/wiki/Error_function#Approximation_with_elementary_functions
	vec4 one = vec4(1.0);
	vec4 sign_x = sign(x);
	vec4 t = one/(one + 0.47047*abs(x));
	vec4 result = one - t*(0.3480242 + t*(-0.0958798 + t*0.7478556))*
		exp(-(x*x));
	return result * sign_x;
}

vec3 erf6(vec3 x)
{
    //  vec3 version:
	vec3 one = vec3(1.0);
	vec3 sign_x = sign(x);
	vec3 t = one/(one + 0.47047*abs(x));
	vec3 result = one - t*(0.3480242 + t*(-0.0958798 + t*0.7478556))*
		exp(-(x*x));
	return result * sign_x;
}

vec2 erf6(vec2 x)
{
    //  vec2 version:
	vec2 one = vec2(1.0);
	vec2 sign_x = sign(x);
	vec2 t = one/(one + 0.47047*abs(x));
	vec2 result = one - t*(0.3480242 + t*(-0.0958798 + t*0.7478556))*
		exp(-(x*x));
	return result * sign_x;
}

float erf6(float x)
{
    //  Float version:
	float sign_x = sign(x);
	float t = 1.0/(1.0 + 0.47047*abs(x));
	float result = 1.0 - t*(0.3480242 + t*(-0.0958798 + t*0.7478556))*
		exp(-(x*x));
	return result * sign_x;
}

vec4 erft(vec4 x)
{
    //  Requires:   x is the standard parameter to erf().
    //  Returns:    Approximate erf() with the hyperbolic tangent.  The error is
    //              visually noticeable, but it's blazing fast and perceptually
    //              close...at least on ATI hardware.  See:
    //                  http://www.maplesoft.com/applications/view.aspx?SID=5525&view=html
    //  Warning:    Only use this if your hardware drivers correctly implement
    //              tanh(): My nVidia 8800GTS returns garbage output.
	return tanh(1.202760580 * x);
}

vec3 erft(vec3 x)
{
    //  vec3 version:
	return tanh(1.202760580 * x);
}

vec2 erft(vec2 x)
{
    //  vec2 version:
	return tanh(1.202760580 * x);
}

float erft(float x)
{
    //  Float version:
	return tanh(1.202760580 * x);
}

vec4 erf(vec4 x)
{
    //  Requires:   x is the standard parameter to erf().
    //  Returns:    Some approximation of erf(x), depending on user settings.
	#ifdef ERF_FAST_APPROXIMATION
		return erft(x);
	#else
		return erf6(x);
	#endif
}

vec3 erf(vec3 x)
{
    //  vec3 version:
	#ifdef ERF_FAST_APPROXIMATION
		return erft(x);
	#else
		return erf6(x);
	#endif
}

vec2 erf(vec2 x)
{
    //  vec2 version:
	#ifdef ERF_FAST_APPROXIMATION
		return erft(x);
	#else
		return erf6(x);
	#endif
}

float erf(float x)
{
    //  Float version:
	#ifdef ERF_FAST_APPROXIMATION
		return erft(x);
	#else
		return erf6(x);
	#endif
}

///////////////////////////  COMPLETE GAMMA FUNCTION  //////////////////////////

vec4 gamma_impl(vec4 s, vec4 s_inv)
{
    //  Requires:   1.) s is the standard parameter to the gamma function, and
    //                  it should lie in the [0, 36] range.
    //              2.) s_inv = 1.0/s.  This implementation function requires
    //                  the caller to precompute this value, giving users the
    //                  opportunity to reuse it.
    //  Returns:    Return approximate gamma function (real-numbered factorial)
    //              output using the Lanczos approximation with two coefficients
    //              calculated using Paul Godfrey's method here:
    //                  http://my.fit.edu/~gabdo/gamma.txt
    //              An optimal g value for s in [0, 36] is ~1.12906830989, with
    //              a maximum relative error of 0.000463 for 2**16 equally
    //              evals.  We could use three coeffs (0.0000346 error) without
    //              hurting latency, but this allows more parallelism with
    //              outside instructions.
	vec4 g = vec4(1.12906830989);
	vec4 c0 = vec4(0.8109119309638332633713423362694399653724431);
	vec4 c1 = vec4(0.4808354605142681877121661197951496120000040);
	vec4 e = vec4(2.71828182845904523536028747135266249775724709);
	vec4 sph = s + vec4(0.5);
	vec4 lanczos_sum = c0 + c1/(s + vec4(1.0));
	vec4 base = (sph + g)/e;  //  or (s + g + vec4(0.5))/e
	//  gamma(s + 1) = base**sph * lanczos_sum; divide by s for gamma(s).
	//  This has less error for small s's than (s -= 1.0) at the beginning.
	return (pow(base, sph) * lanczos_sum) * s_inv;
}

vec3 gamma_impl(vec3 s, vec3 s_inv)
{
    //  vec3 version:
	vec3 g = vec3(1.12906830989);
	vec3 c0 = vec3(0.8109119309638332633713423362694399653724431);
	vec3 c1 = vec3(0.4808354605142681877121661197951496120000040);
	vec3 e = vec3(2.71828182845904523536028747135266249775724709);
	vec3 sph = s + vec3(0.5);
	vec3 lanczos_sum = c0 + c1/(s + vec3(1.0));
	vec3 base = (sph + g)/e;
	return (pow(base, sph) * lanczos_sum) * s_inv;
}

vec2 gamma_impl(vec2 s, vec2 s_inv)
{
    //  vec2 version:
	vec2 g = vec2(1.12906830989);
	vec2 c0 = vec2(0.8109119309638332633713423362694399653724431);
	vec2 c1 = vec2(0.4808354605142681877121661197951496120000040);
	vec2 e = vec2(2.71828182845904523536028747135266249775724709);
	vec2 sph = s + vec2(0.5);
	vec2 lanczos_sum = c0 + c1/(s + vec2(1.0));
	vec2 base = (sph + g)/e;
	return (pow(base, sph) * lanczos_sum) * s_inv;
}

float gamma_impl(float s, float s_inv)
{
    //  Float version:
	float g = 1.12906830989;
	float c0 = 0.8109119309638332633713423362694399653724431;
	float c1 = 0.4808354605142681877121661197951496120000040;
	float e = 2.71828182845904523536028747135266249775724709;
	float sph = s + 0.5;
	float lanczos_sum = c0 + c1/(s + 1.0);
	float base = (sph + g)/e;
	return (pow(base, sph) * lanczos_sum) * s_inv;
}

vec4 gamma(vec4 s)
{
    //  Requires:   s is the standard parameter to the gamma function, and it
    //              should lie in the [0, 36] range.
    //  Returns:    Return approximate gamma function output with a maximum
    //              relative error of 0.000463.  See gamma_impl for details.
	return gamma_impl(s, vec4(1.0)/s);
}

vec3 gamma(vec3 s)
{
    //  vec3 version:
	return gamma_impl(s, vec3(1.0)/s);
}

vec2 gamma(vec2 s)
{
    //  vec2 version:
	return gamma_impl(s, vec2(1.0)/s);
}

float gamma(float s)
{
    //  Float version:
	return gamma_impl(s, 1.0/s);
}

////////////////  INCOMPLETE GAMMA FUNCTIONS (RESTRICTED INPUT)  ///////////////

//  Lower incomplete gamma function for small s and z (implementation):
vec4 ligamma_small_z_impl(vec4 s, vec4 z, vec4 s_inv)
{
    //  Requires:   1.) s < ~0.5
    //              2.) z <= ~0.775075
    //              3.) s_inv = 1.0/s (precomputed for outside reuse)
    //  Returns:    A series representation for the lower incomplete gamma
    //              function for small s and small z (4 terms).
    //  The actual "rolled up" summation looks like:
	//      last_sign = 1.0; last_pow = 1.0; last_factorial = 1.0;
	//      sum = last_sign * last_pow / ((s + k) * last_factorial)
	//      for(int i = 0; i < 4; ++i)
	//      {
	//          last_sign *= -1.0; last_pow *= z; last_factorial *= i;
	//          sum += last_sign * last_pow / ((s + k) * last_factorial);
	//      }
	//  Unrolled, constant-unfolded and arranged for madds and parallelism:
	vec4 scale = pow(z, s);
	vec4 sum = s_inv;  //  Summation iteration 0 result
	//  Summation iterations 1, 2, and 3:
	vec4 z_sq = z*z;
	vec4 denom1 = s + vec4(1.0);
	vec4 denom2 = 2.0*s + vec4(4.0);
	vec4 denom3 = 6.0*s + vec4(18.0);
	//vec4 denom4 = 24.0*s + vec4(96.0);
	sum -= z/denom1;
	sum += z_sq/denom2;
	sum -= z * z_sq/denom3;
	//sum += z_sq * z_sq / denom4;
	//  Scale and return:
	return scale * sum;
}

vec3 ligamma_small_z_impl(vec3 s, vec3 z, vec3 s_inv)
{
    //  vec3 version:
	vec3 scale = pow(z, s);
	vec3 sum = s_inv;
	vec3 z_sq = z*z;
	vec3 denom1 = s + vec3(1.0);
	vec3 denom2 = 2.0*s + vec3(4.0);
	vec3 denom3 = 6.0*s + vec3(18.0);
	sum -= z/denom1;
	sum += z_sq/denom2;
	sum -= z * z_sq/denom3;
	return scale * sum;
}

vec2 ligamma_small_z_impl(vec2 s, vec2 z, vec2 s_inv)
{
    //  vec2 version:
	vec2 scale = pow(z, s);
	vec2 sum = s_inv;
	vec2 z_sq = z*z;
	vec2 denom1 = s + vec2(1.0);
	vec2 denom2 = 2.0*s + vec2(4.0);
	vec2 denom3 = 6.0*s + vec2(18.0);
	sum -= z/denom1;
	sum += z_sq/denom2;
	sum -= z * z_sq/denom3;
	return scale * sum;
}

float ligamma_small_z_impl(float s, float z, float s_inv)
{
    //  Float version:
	float scale = pow(z, s);
	float sum = s_inv;
	float z_sq = z*z;
	float denom1 = s + 1.0;
	float denom2 = 2.0*s + 4.0;
	float denom3 = 6.0*s + 18.0;
	sum -= z/denom1;
	sum += z_sq/denom2;
	sum -= z * z_sq/denom3;
	return scale * sum;
}

//  Upper incomplete gamma function for small s and large z (implementation):
vec4 uigamma_large_z_impl(vec4 s, vec4 z)
{
    //  Requires:   1.) s < ~0.5
    //              2.) z > ~0.775075
    //  Returns:    Gauss's continued fraction representation for the upper
    //              incomplete gamma function (4 terms).
	//  The "rolled up" continued fraction looks like this.  The denominator
    //  is truncated, and it's calculated "from the bottom up:"
	//      denom = vec4('inf');
	//      vec4 one = vec4(1.0);
	//      for(int i = 4; i > 0; --i)
	//      {
	//          denom = ((i * 2.0) - one) + z - s + (i * (s - i))/denom;
	//      }
	//  Unrolled and constant-unfolded for madds and parallelism:
	vec4 numerator = pow(z, s) * exp(-z);
	vec4 denom = vec4(7.0) + z - s;
	denom = vec4(5.0) + z - s + (3.0*s - vec4(9.0))/denom;
	denom = vec4(3.0) + z - s + (2.0*s - vec4(4.0))/denom;
	denom = vec4(1.0) + z - s + (s - vec4(1.0))/denom;
	return numerator / denom;
}

vec3 uigamma_large_z_impl(vec3 s, vec3 z)
{
    //  vec3 version:
	vec3 numerator = pow(z, s) * exp(-z);
	vec3 denom = vec3(7.0) + z - s;
	denom = vec3(5.0) + z - s + (3.0*s - vec3(9.0))/denom;
	denom = vec3(3.0) + z - s + (2.0*s - vec3(4.0))/denom;
	denom = vec3(1.0) + z - s + (s - vec3(1.0))/denom;
	return numerator / denom;
}

vec2 uigamma_large_z_impl(vec2 s, vec2 z)
{
    //  vec2 version:
	vec2 numerator = pow(z, s) * exp(-z);
	vec2 denom = vec2(7.0) + z - s;
	denom = vec2(5.0) + z - s + (3.0*s - vec2(9.0))/denom;
	denom = vec2(3.0) + z - s + (2.0*s - vec2(4.0))/denom;
	denom = vec2(1.0) + z - s + (s - vec2(1.0))/denom;
	return numerator / denom;
}

float uigamma_large_z_impl(float s, float z)
{
    //  Float version:
	float numerator = pow(z, s) * exp(-z);
	float denom = 7.0 + z - s;
	denom = 5.0 + z - s + (3.0*s - 9.0)/denom;
	denom = 3.0 + z - s + (2.0*s - 4.0)/denom;
	denom = 1.0 + z - s + (s - 1.0)/denom;
	return numerator / denom;
}

//  Normalized lower incomplete gamma function for small s (implementation):
vec4 normalized_ligamma_impl(vec4 s, vec4 z,
    vec4 s_inv, vec4 gamma_s_inv)
{
    //  Requires:   1.) s < ~0.5
    //              2.) s_inv = 1/s (precomputed for outside reuse)
    //              3.) gamma_s_inv = 1/gamma(s) (precomputed for outside reuse)
    //  Returns:    Approximate the normalized lower incomplete gamma function
    //              for s < 0.5.  Since we only care about s < 0.5, we only need
    //              to evaluate two branches (not four) based on z.  Each branch
    //              uses four terms, with a max relative error of ~0.00182.  The
    //              branch threshold and specifics were adapted for fewer terms
    //              from Gil/Segura/Temme's paper here:
    //                  http://oai.cwi.nl/oai/asset/20433/20433B.pdf
	//  Evaluate both branches: Real branches test slower even when available.
	vec4 thresh = vec4(0.775075);
	bvec4 z_is_large = greaterThan(z , thresh);
	vec4 z_size_check = vec4(z_is_large.x ? 1.0 : 0.0, z_is_large.y ? 1.0 : 0.0, z_is_large.z ? 1.0 : 0.0, z_is_large.w ? 1.0 : 0.0);
	vec4 large_z = vec4(1.0) - uigamma_large_z_impl(s, z) * gamma_s_inv;
	vec4 small_z = ligamma_small_z_impl(s, z, s_inv) * gamma_s_inv;
	//  Combine the results from both branches:
	return large_z * vec4(z_size_check) + small_z * vec4(z_size_check);
}

vec3 normalized_ligamma_impl(vec3 s, vec3 z,
    vec3 s_inv, vec3 gamma_s_inv)
{
    //  vec3 version:
	vec3 thresh = vec3(0.775075);
	bvec3 z_is_large = greaterThan(z , thresh);
	vec3 z_size_check = vec3(z_is_large.x ? 1.0 : 0.0, z_is_large.y ? 1.0 : 0.0, z_is_large.z ? 1.0 : 0.0);
	vec3 large_z = vec3(1.0) - uigamma_large_z_impl(s, z) * gamma_s_inv;
	vec3 small_z = ligamma_small_z_impl(s, z, s_inv) * gamma_s_inv;
	return large_z * vec3(z_size_check) + small_z * vec3(z_size_check);
}

vec2 normalized_ligamma_impl(vec2 s, vec2 z,
    vec2 s_inv, vec2 gamma_s_inv)
{
    //  vec2 version:
	vec2 thresh = vec2(0.775075);
	bvec2 z_is_large = greaterThan(z , thresh);
	vec2 z_size_check = vec2(z_is_large.x ? 1.0 : 0.0, z_is_large.y ? 1.0 : 0.0);
	vec2 large_z = vec2(1.0) - uigamma_large_z_impl(s, z) * gamma_s_inv;
	vec2 small_z = ligamma_small_z_impl(s, z, s_inv) * gamma_s_inv;
	return large_z * vec2(z_size_check) + small_z * vec2(z_size_check);
}

float normalized_ligamma_impl(float s, float z,
    float s_inv, float gamma_s_inv)
{
    //  Float version:
	float thresh = 0.775075;
	float z_size_check = 0.0;
	if (z > thresh) z_size_check = 1.0;
	float large_z = 1.0 - uigamma_large_z_impl(s, z) * gamma_s_inv;
	float small_z = ligamma_small_z_impl(s, z, s_inv) * gamma_s_inv;
	return large_z * float(z_size_check) + small_z * float(z_size_check);
}

//  Normalized lower incomplete gamma function for small s:
vec4 normalized_ligamma(vec4 s, vec4 z)
{
    //  Requires:   s < ~0.5
    //  Returns:    Approximate the normalized lower incomplete gamma function
    //              for s < 0.5.  See normalized_ligamma_impl() for details.
	vec4 s_inv = vec4(1.0)/s;
	vec4 gamma_s_inv = vec4(1.0)/gamma_impl(s, s_inv);
	return normalized_ligamma_impl(s, z, s_inv, gamma_s_inv);
}

vec3 normalized_ligamma(vec3 s, vec3 z)
{
    //  vec3 version:
	vec3 s_inv = vec3(1.0)/s;
	vec3 gamma_s_inv = vec3(1.0)/gamma_impl(s, s_inv);
	return normalized_ligamma_impl(s, z, s_inv, gamma_s_inv);
}

vec2 normalized_ligamma(vec2 s, vec2 z)
{
    //  vec2 version:
	vec2 s_inv = vec2(1.0)/s;
	vec2 gamma_s_inv = vec2(1.0)/gamma_impl(s, s_inv);
	return normalized_ligamma_impl(s, z, s_inv, gamma_s_inv);
}

float normalized_ligamma(float s, float z)
{
    //  Float version:
	float s_inv = 1.0/s;
	float gamma_s_inv = 1.0/gamma_impl(s, s_inv);
	return normalized_ligamma_impl(s, z, s_inv, gamma_s_inv);
}

#endif  //  SPECIAL_FUNCTIONS_H
/////////   END #include "../../../../include/special-functions.h"   /////////
//#include "../../../../include/gamma-management.h"

/////////////////////////////  SCANLINE FUNCTIONS  /////////////////////////////

vec3 get_raw_interpolated_color(vec3 color0,
    vec3 color1, vec3 color2, vec3 color3,
    vec4 weights)
{
    //  Use max to avoid bizarre artifacts from negative colors:
    return max(mat4x3(color0, color1, color2, color3) * weights, 0.0);
}

vec3 get_interpolated_linear_color(vec3 color0, vec3 color1,
    vec3 color2, vec3 color3, vec4 weights)
{
    //  Requires:   1.) Requirements of include/gamma-management.h must be met:
    //                  intermediate_gamma must be globally defined, and input
    //                  colors are interpreted as linear RGB unless you #define
    //                  GAMMA_ENCODE_EVERY_FBO (in which case they are
    //                  interpreted as gamma-encoded with intermediate_gamma).
    //              2.) color0-3 are colors sampled from a texture with tex2D().
    //                  They are interpreted as defined in requirement 1.
    //              3.) weights contains weights for each color, summing to 1.0.
    //              4.) beam_horiz_linear_rgb_weight must be defined as a global
    //                  float in [0.0, 1.0] describing how much blending should
    //                  be done in linear RGB (rest is gamma-corrected RGB).
    //              5.) RUNTIME_SCANLINES_HORIZ_FILTER_COLORSPACE must be #defined
    //                  if beam_horiz_linear_rgb_weight is anything other than a
    //                  static constant, or we may try branching at runtime
    //                  without dynamic branches allowed (slow).
    //  Returns:    Return an interpolated color lookup between the four input
    //              colors based on the weights in weights.  The final color will
    //              be a linear RGB value, but the blending will be done as
    //              indicated above.
    float intermediate_gamma = get_intermediate_gamma();
    //  Branch if beam_horiz_linear_rgb_weight is static (for free) or if the
    //  profile allows dynamic branches (faster than computing extra pows):
    #ifndef RUNTIME_SCANLINES_HORIZ_FILTER_COLORSPACE
        #define SCANLINES_BRANCH_FOR_LINEAR_RGB_WEIGHT
    #else
        #ifdef DRIVERS_ALLOW_DYNAMIC_BRANCHES
            #define SCANLINES_BRANCH_FOR_LINEAR_RGB_WEIGHT
        #endif
    #endif
    #ifdef SCANLINES_BRANCH_FOR_LINEAR_RGB_WEIGHT
        //  beam_horiz_linear_rgb_weight is static, so we can branch:
        #ifdef GAMMA_ENCODE_EVERY_FBO
            vec3 gamma_mixed_color = pow(get_raw_interpolated_color(
                color0, color1, color2, color3, weights), vec3(intermediate_gamma));
            if(beam_horiz_linear_rgb_weight > 0.0)
            {
                vec3 linear_mixed_color = get_raw_interpolated_color(
                    pow(color0, vec3(intermediate_gamma)),
                    pow(color1, vec3(intermediate_gamma)),
                    pow(color2, vec3(intermediate_gamma)),
                    pow(color3, vec3(intermediate_gamma)),
                    weights);
                return mix(gamma_mixed_color, linear_mixed_color,
                    beam_horiz_linear_rgb_weight);
            }
            else
            {
                return gamma_mixed_color;
            }
        #else
            vec3 linear_mixed_color = get_raw_interpolated_color(
                color0, color1, color2, color3, weights);
            if(beam_horiz_linear_rgb_weight < 1.0)
            {
                vec3 gamma_mixed_color = get_raw_interpolated_color(
                    pow(color0, vec3(1.0/intermediate_gamma)),
                    pow(color1, vec3(1.0/intermediate_gamma)),
                    pow(color2, vec3(1.0/intermediate_gamma)),
                    pow(color3, vec3(1.0/intermediate_gamma)),
                    weights);
                return mix(gamma_mixed_color, linear_mixed_color,
                    beam_horiz_linear_rgb_weight);
            }
            else
            {
                return linear_mixed_color;
            }
        #endif  //  GAMMA_ENCODE_EVERY_FBO
    #else
        #ifdef GAMMA_ENCODE_EVERY_FBO
            //  Inputs: color0-3 are colors in gamma-encoded RGB.
            vec3 gamma_mixed_color = pow(get_raw_interpolated_color(
                color0, color1, color2, color3, weights), vec3(intermediate_gamma));
            vec3 linear_mixed_color = get_raw_interpolated_color(
                pow(color0, vec3(intermediate_gamma)),
                pow(color1, vec3(intermediate_gamma)),
                pow(color2, vec3(intermediate_gamma)),
                pow(color3, vec3(intermediate_gamma)),
                weights);
            return mix(gamma_mixed_color, linear_mixed_color,
                beam_horiz_linear_rgb_weight);
        #else
            //  Inputs: color0-3 are colors in linear RGB.
            vec3 linear_mixed_color = get_raw_interpolated_color(
                color0, color1, color2, color3, weights);
            vec3 gamma_mixed_color = get_raw_interpolated_color(
                    pow(color0, vec3(1.0/intermediate_gamma)),
                    pow(color1, vec3(1.0/intermediate_gamma)),
                    pow(color2, vec3(1.0/intermediate_gamma)),
                    pow(color3, vec3(1.0/intermediate_gamma)),
                    weights);
            return mix(gamma_mixed_color, linear_mixed_color,
                beam_horiz_linear_rgb_weight);
        #endif  //  GAMMA_ENCODE_EVERY_FBO
    #endif  //  SCANLINES_BRANCH_FOR_LINEAR_RGB_WEIGHT
}

vec3 get_scanline_color(sampler2D tex, vec2 scanline_uv,
    vec2 uv_step_x, vec4 weights)
{
    //  Requires:   1.) scanline_uv must be vertically snapped to the caller's
    //                  desired line or scanline and horizontally snapped to the
    //                  texel just left of the output pixel (color1)
    //              2.) uv_step_x must contain the horizontal uv distance
    //                  between texels.
    //              3.) weights must contain interpolation filter weights for
    //                  color0, color1, color2, and color3, where color1 is just
    //                  left of the output pixel.
    //  Returns:    Return a horizontally interpolated texture lookup using 2-4
    //              nearby texels, according to weights and the conventions of
    //              get_interpolated_linear_color().
    //  We can ignore the outside texture lookups for Quilez resampling.
    vec3 color1 = texture(tex, scanline_uv).rgb;
    vec3 color2 = texture(tex, scanline_uv + uv_step_x).rgb;
    vec3 color0 = vec3(0.0);
    vec3 color3 = vec3(0.0);
    if(beam_horiz_filter > 0.5)
    {
        color0 = texture(tex, scanline_uv - uv_step_x).rgb;
        color3 = texture(tex, scanline_uv + 2.0 * uv_step_x).rgb;
    }
    //  Sample the texture as-is, whether it's linear or gamma-encoded:
    //  get_interpolated_linear_color() will handle the difference.
    return get_interpolated_linear_color(color0, color1, color2, color3, weights);
}

vec3 sample_single_scanline_horizontal(sampler2D texture,
    vec2 tex_uv, vec2 texture_size,
    vec2 texture_size_inv)
{
    //  TODO: Add function requirements.
    //  Snap to the previous texel and get sample dists from 2/4 nearby texels:
    vec2 curr_texel = tex_uv * texture_size;
    //  Use under_half to fix a rounding bug right around exact texel locations.
    vec2 prev_texel =
        floor(curr_texel - vec2(under_half)) + vec2(0.5);
    vec2 prev_texel_hor = vec2(prev_texel.x, curr_texel.y);
    vec2 prev_texel_hor_uv = prev_texel_hor * texture_size_inv;
    float prev_dist = curr_texel.x - prev_texel_hor.x;
    vec4 sample_dists = vec4(1.0 + prev_dist, prev_dist,
        1.0 - prev_dist, 2.0 - prev_dist);
    //  Get Quilez, Lanczos2, or Gaussian resize weights for 2/4 nearby texels:
    vec4 weights;
    if(beam_horiz_filter < 0.5)
    {
        //  Quilez:
        float x = sample_dists.y;
        float w2 = x*x*x*(x*(x*6.0 - 15.0) + 10.0);
        weights = vec4(0.0, 1.0 - w2, w2, 0.0);
    }
    else if(beam_horiz_filter < 1.5)
    {
        //  Gaussian:
        float inner_denom_inv = 1.0/(2.0*beam_horiz_sigma*beam_horiz_sigma);
        weights = exp(-(sample_dists*sample_dists)*inner_denom_inv);
    }
    else
    {
        //  Lanczos2:
        vec4 pi_dists = FIX_ZERO(sample_dists * pi);
        weights = 2.0 * sin(pi_dists) * sin(pi_dists * 0.5) /
            (pi_dists * pi_dists);
    }
    //  Ensure the weight sum == 1.0:
    vec4 final_weights = weights/dot(weights, vec4(1.0));
    //  Get the interpolated horizontal scanline color:
    vec2 uv_step_x = vec2(texture_size_inv.x, 0.0);
    return get_scanline_color(
        texture, prev_texel_hor_uv, uv_step_x, final_weights);
}

bool is_interlaced(float num_lines)
{
    //  Detect interlacing based on the number of lines in the source.
    if(interlace_detect == true)
    {
        //  NTSC: 525 lines, 262.5/field; 486 active (2 half-lines), 243/field
        //  NTSC Emulators: Typically 224 or 240 lines
        //  PAL: 625 lines, 312.5/field; 576 active (typical), 288/field
        //  PAL Emulators: ?
        //  ATSC: 720p, 1080i, 1080p
        //  Where do we place our cutoffs?  Assumptions:
        //  1.) We only need to care about active lines.
        //  2.) Anything > 288 and <= 576 lines is probably interlaced.
        //  3.) Anything > 576 lines is probably not interlaced...
        //  4.) ...except 1080 lines, which is a crapshoot (user decision).
        //  5.) Just in case the main program uses calculated video sizes,
        //      we should nudge the float thresholds a bit.
        bool sd_interlace;
		if (num_lines > 288.5 && num_lines < 576.5)
			{sd_interlace = true;}
		else
			{sd_interlace = false;}
        bool hd_interlace;
        if (num_lines > 1079.5 && num_lines < 1080.5)
			{hd_interlace = true;}
		else
			{hd_interlace = false;}
		return (sd_interlace || hd_interlace);
    }
    else
    {
        return false;
    }
}

vec3 sample_rgb_scanline_horizontal(sampler2D tex,
    vec2 tex_uv, vec2 texture_size,
    vec2 texture_size_inv)
{
    //  TODO: Add function requirements.
    //  Rely on a helper to make convergence easier.
    if(beam_misconvergence == true)
    {
        vec3 convergence_offsets_rgb =
            get_convergence_offsets_x_vector();
        vec3 offset_u_rgb =
            convergence_offsets_rgb * texture_size_inv.xxx;
        vec2 scanline_uv_r = tex_uv - vec2(offset_u_rgb.r, 0.0);
        vec2 scanline_uv_g = tex_uv - vec2(offset_u_rgb.g, 0.0);
        vec2 scanline_uv_b = tex_uv - vec2(offset_u_rgb.b, 0.0);
        vec3 sample_r = sample_single_scanline_horizontal(
            tex, scanline_uv_r, texture_size, texture_size_inv);
        vec3 sample_g = sample_single_scanline_horizontal(
            tex, scanline_uv_g, texture_size, texture_size_inv);
        vec3 sample_b = sample_single_scanline_horizontal(
            tex, scanline_uv_b, texture_size, texture_size_inv);
        return vec3(sample_r.r, sample_g.g, sample_b.b);
    }
    else
    {
        return sample_single_scanline_horizontal(tex, tex_uv, texture_size,
            texture_size_inv);
    }
}

vec2 get_last_scanline_uv(vec2 tex_uv, vec2 texture_size,
    vec2 texture_size_inv, vec2 il_step_multiple,
    float frame_count, out float dist)
{
    //  Compute texture coords for the last/upper scanline, accounting for
    //  interlacing: With interlacing, only consider even/odd scanlines every
    //  other frame.  Top-field first (TFF) order puts even scanlines on even
    //  frames, and BFF order puts them on odd frames.  Texels are centered at:
    //      frac(tex_uv * texture_size) == x.5
    //  Caution: If these coordinates ever seem incorrect, first make sure it's
    //  not because anisotropic filtering is blurring across field boundaries.
    //  Note: TFF/BFF won't matter for sources that double-weave or similar.
    float field_offset = floor(il_step_multiple.y * 0.75) *
        mod(frame_count + float(interlace_bff), 2.0);
    vec2 curr_texel = tex_uv * texture_size;
    //  Use under_half to fix a rounding bug right around exact texel locations.
    vec2 prev_texel_num = floor(curr_texel - vec2(under_half));
    float wrong_field = mod(
        prev_texel_num.y + field_offset, il_step_multiple.y);
    vec2 scanline_texel_num = prev_texel_num - vec2(0.0, wrong_field);
    //  Snap to the center of the previous scanline in the current field:
    vec2 scanline_texel = scanline_texel_num + vec2(0.5);
    vec2 scanline_uv = scanline_texel * texture_size_inv;
    //  Save the sample's distance from the scanline, in units of scanlines:
    dist = (curr_texel.y - scanline_texel.y)/il_step_multiple.y;
    return scanline_uv;
}

vec3 get_gaussian_sigma(vec3 color, float sigma_range)
{
    //  Requires:   Globals:
    //              1.) beam_min_sigma and beam_max_sigma are global floats
    //                  containing the desired minimum and maximum beam standard
    //                  deviations, for dim and bright colors respectively.
    //              2.) beam_max_sigma must be > 0.0
    //              3.) beam_min_sigma must be in (0.0, beam_max_sigma]
    //              4.) beam_spot_power must be defined as a global float.
    //              Parameters:
    //              1.) color is the underlying source color along a scanline
    //              2.) sigma_range = beam_max_sigma - beam_min_sigma; we take
    //                  sigma_range as a parameter to avoid repeated computation
    //                  when beam_{min, max}_sigma are runtime shader parameters
    //  Optional:   Users may set beam_spot_shape_function to 1 to define the
    //              inner f(color) subfunction (see below) as:
    //                  f(color) = sqrt(1.0 - (color - 1.0)*(color - 1.0))
    //              Otherwise (technically, if beam_spot_shape_function < 0.5):
    //                  f(color) = pow(color, beam_spot_power)
    //  Returns:    The standard deviation of the Gaussian beam for "color:"
    //                  sigma = beam_min_sigma + sigma_range * f(color)
    //  Details/Discussion:
    //  The beam's spot shape vaguely resembles an aspect-corrected f() in the
    //  range [0, 1] (not quite, but it's related).  f(color) = color makes
    //  spots look like diamonds, and a spherical function or cube balances
    //  between variable width and a soft/realistic shape.   A beam_spot_power
    //  > 1.0 can produce an ugly spot shape and more initial clipping, but the
    //  final shape also differs based on the horizontal resampling filter and
    //  the phosphor bloom.  For instance, resampling horizontally in nonlinear
    //  light and/or with a sharp (e.g. Lanczos) filter will sharpen the spot
    //  shape, but a sixth root is still quite soft.  A power function (default
    //  1.0/3.0 beam_spot_power) is most flexible, but a fixed spherical curve
    //  has the highest variability without an awful spot shape.
    //
    //  beam_min_sigma affects scanline sharpness/aliasing in dim areas, and its
    //  difference from beam_max_sigma affects beam width variability.  It only
    //  affects clipping [for pure Gaussians] if beam_spot_power > 1.0 (which is
    //  a conservative estimate for a more complex constraint).
    //
    //  beam_max_sigma affects clipping and increasing scanline width/softness
    //  as color increases.  The wider this is, the more scanlines need to be
    //  evaluated to avoid distortion.  For a pure Gaussian, the max_beam_sigma
    //  at which the first unused scanline always has a weight < 1.0/255.0 is:
    //      num scanlines = 2, max_beam_sigma = 0.2089; distortions begin ~0.34
    //      num scanlines = 3, max_beam_sigma = 0.3879; distortions begin ~0.52
    //      num scanlines = 4, max_beam_sigma = 0.5723; distortions begin ~0.70
    //      num scanlines = 5, max_beam_sigma = 0.7591; distortions begin ~0.89
    //      num scanlines = 6, max_beam_sigma = 0.9483; distortions begin ~1.08
    //  Generalized Gaussians permit more leeway here as steepness increases.
    if(beam_spot_shape_function < 0.5)
    {
        //  Use a power function:
        return vec3(beam_min_sigma) + sigma_range *
            pow(color, vec3(beam_spot_power));
    }
    else
    {
        //  Use a spherical function:
        vec3 color_minus_1 = color - vec3(1.0);
        return vec3(beam_min_sigma) + sigma_range *
            sqrt(vec3(1.0) - color_minus_1*color_minus_1);
    }
}

vec3 get_generalized_gaussian_beta(vec3 color,
    float shape_range)
{
    //  Requires:   Globals:
    //              1.) beam_min_shape and beam_max_shape are global floats
    //                  containing the desired min/max generalized Gaussian
    //                  beta parameters, for dim and bright colors respectively.
    //              2.) beam_max_shape must be >= 2.0
    //              3.) beam_min_shape must be in [2.0, beam_max_shape]
    //              4.) beam_shape_power must be defined as a global float.
    //              Parameters:
    //              1.) color is the underlying source color along a scanline
    //              2.) shape_range = beam_max_shape - beam_min_shape; we take
    //                  shape_range as a parameter to avoid repeated computation
    //                  when beam_{min, max}_shape are runtime shader parameters
    //  Returns:    The type-I generalized Gaussian "shape" parameter beta for
    //              the given color.
    //  Details/Discussion:
    //  Beta affects the scanline distribution as follows:
    //  a.) beta < 2.0 narrows the peak to a spike with a discontinuous slope
    //  b.) beta == 2.0 just degenerates to a Gaussian
    //  c.) beta > 2.0 flattens and widens the peak, then drops off more steeply
    //      than a Gaussian.  Whereas high sigmas widen and soften peaks, high
    //      beta widen and sharpen peaks at the risk of aliasing.
    //  Unlike high beam_spot_powers, high beam_shape_powers actually soften shape
    //  transitions, whereas lower ones sharpen them (at the risk of aliasing).
    return beam_min_shape + shape_range * pow(color, vec3(beam_shape_power));
}

vec3 scanline_gaussian_integral_contrib(vec3 dist,
    vec3 color, float pixel_height, float sigma_range)
{
    //  Requires:   1.) dist is the distance of the [potentially separate R/G/B]
    //                  point(s) from a scanline in units of scanlines, where
    //                  1.0 means the sample point straddles the next scanline.
    //              2.) color is the underlying source color along a scanline.
    //              3.) pixel_height is the output pixel height in scanlines.
    //              4.) Requirements of get_gaussian_sigma() must be met.
    //  Returns:    Return a scanline's light output over a given pixel.
    //  Details:
    //  The CRT beam profile follows a roughly Gaussian distribution which is
    //  wider for bright colors than dark ones.  The integral over the full
    //  range of a Gaussian function is always 1.0, so we can vary the beam
    //  with a standard deviation without affecting brightness.  'x' = distance:
    //      gaussian sample = 1/(sigma*sqrt(2*pi)) * e**(-(x**2)/(2*sigma**2))
    //      gaussian integral = 0.5 (1.0 + erf(x/(sigma * sqrt(2))))
    //  Use a numerical approximation of the "error function" (the Gaussian
    //  indefinite integral) to find the definite integral of the scanline's
    //  average brightness over a given pixel area.  Even if curved coords were
    //  used in this pass, a flat scalar pixel height works almost as well as a
    //  pixel height computed from a full pixel-space to scanline-space matrix.
    vec3 sigma = get_gaussian_sigma(color, sigma_range);
    vec3 ph_offset = vec3(pixel_height * 0.5);
    vec3 denom_inv = 1.0/(sigma*sqrt(2.0));
    vec3 integral_high = erf((dist + ph_offset)*denom_inv);
    vec3 integral_low = erf((dist - ph_offset)*denom_inv);
    return color * 0.5*(integral_high - integral_low)/pixel_height;
}

vec3 scanline_generalized_gaussian_integral_contrib(vec3 dist,
    vec3 color, float pixel_height, float sigma_range,
    float shape_range)
{
    //  Requires:   1.) Requirements of scanline_gaussian_integral_contrib()
    //                  must be met.
    //              2.) Requirements of get_gaussian_sigma() must be met.
    //              3.) Requirements of get_generalized_gaussian_beta() must be
    //                  met.
    //  Returns:    Return a scanline's light output over a given pixel.
    //  A generalized Gaussian distribution allows the shape (beta) to vary
    //  as well as the width (alpha).  "gamma" refers to the gamma function:
    //      generalized sample =
    //          beta/(2*alpha*gamma(1/beta)) * e**(-(|x|/alpha)**beta)
    //  ligamma(s, z) is the lower incomplete gamma function, for which we only
    //  implement two of four branches (because we keep 1/beta <= 0.5):
    //      generalized integral = 0.5 + 0.5* sign(x) *
    //          ligamma(1/beta, (|x|/alpha)**beta)/gamma(1/beta)
    //  See get_generalized_gaussian_beta() for a discussion of beta.
    //  We base alpha on the intended Gaussian sigma, but it only strictly
    //  models models standard deviation at beta == 2, because the standard
    //  deviation depends on both alpha and beta (keeping alpha independent is
    //  faster and preserves intuitive behavior and a full spectrum of results).
    vec3 alpha = sqrt(2.0) * get_gaussian_sigma(color, sigma_range);
    vec3 beta = get_generalized_gaussian_beta(color, shape_range);
    vec3 alpha_inv = vec3(1.0)/alpha;
    vec3 s = vec3(1.0)/beta;
    vec3 ph_offset = vec3(pixel_height * 0.5);
    //  Pass beta to gamma_impl to avoid repeated divides.  Similarly pass
    //  beta (i.e. 1/s) and 1/gamma(s) to normalized_ligamma_impl.
    vec3 gamma_s_inv = vec3(1.0)/gamma_impl(s, beta);
    vec3 dist1 = dist + ph_offset;
    vec3 dist0 = dist - ph_offset;
    vec3 integral_high = sign(dist1) * normalized_ligamma_impl(
        s, pow(abs(dist1)*alpha_inv, beta), beta, gamma_s_inv);
    vec3 integral_low = sign(dist0) * normalized_ligamma_impl(
        s, pow(abs(dist0)*alpha_inv, beta), beta, gamma_s_inv);
    return color * 0.5*(integral_high - integral_low)/pixel_height;
}

vec3 scanline_gaussian_sampled_contrib(vec3 dist, vec3 color,
    float pixel_height, float sigma_range)
{
    //  See scanline_gaussian integral_contrib() for detailed comments!
    //  gaussian sample = 1/(sigma*sqrt(2*pi)) * e**(-(x**2)/(2*sigma**2))
    vec3 sigma = get_gaussian_sigma(color, sigma_range);
    //  Avoid repeated divides:
    vec3 sigma_inv = vec3(1.0)/sigma;
    vec3 inner_denom_inv = 0.5 * sigma_inv * sigma_inv;
    vec3 outer_denom_inv = sigma_inv/sqrt(2.0*pi);
    if(beam_antialias_level > 0.5)
    {
        //  Sample 1/3 pixel away in each direction as well:
        vec3 sample_offset = vec3(pixel_height/3.0);
        vec3 dist2 = dist + sample_offset;
        vec3 dist3 = abs(dist - sample_offset);
        //  Average three pure Gaussian samples:
        vec3 scale = color/3.0 * outer_denom_inv;
        vec3 weight1 = exp(-(dist*dist)*inner_denom_inv);
        vec3 weight2 = exp(-(dist2*dist2)*inner_denom_inv);
        vec3 weight3 = exp(-(dist3*dist3)*inner_denom_inv);
        return scale * (weight1 + weight2 + weight3);
    }
    else
    {
        return color*exp(-(dist*dist)*inner_denom_inv)*outer_denom_inv;
    }
}

vec3 scanline_generalized_gaussian_sampled_contrib(vec3 dist,
    vec3 color, float pixel_height, float sigma_range,
    float shape_range)
{
    //  See scanline_generalized_gaussian_integral_contrib() for details!
    //  generalized sample =
    //      beta/(2*alpha*gamma(1/beta)) * e**(-(|x|/alpha)**beta)
    vec3 alpha = sqrt(2.0) * get_gaussian_sigma(color, sigma_range);
    vec3 beta = get_generalized_gaussian_beta(color, shape_range);
    //  Avoid repeated divides:
    vec3 alpha_inv = vec3(1.0)/alpha;
    vec3 beta_inv = vec3(1.0)/beta;
    vec3 scale = color * beta * 0.5 * alpha_inv /
        gamma_impl(beta_inv, beta);
    if(beam_antialias_level > 0.5)
    {
        //  Sample 1/3 pixel closer to and farther from the scanline too.
        vec3 sample_offset = vec3(pixel_height/3.0);
        vec3 dist2 = dist + sample_offset;
        vec3 dist3 = abs(dist - sample_offset);
        //  Average three generalized Gaussian samples:
        vec3 weight1 = exp(-pow(abs(dist*alpha_inv), beta));
        vec3 weight2 = exp(-pow(abs(dist2*alpha_inv), beta));
        vec3 weight3 = exp(-pow(abs(dist3*alpha_inv), beta));
        return scale/3.0 * (weight1 + weight2 + weight3);
    }
    else
    {
        return scale * exp(-pow(abs(dist*alpha_inv), beta));
    }
}

vec3 scanline_contrib(vec3 dist, vec3 color,
    float pixel_height, float sigma_range, float shape_range)
{
    //  Requires:   1.) Requirements of scanline_gaussian_integral_contrib()
    //                  must be met.
    //              2.) Requirements of get_gaussian_sigma() must be met.
    //              3.) Requirements of get_generalized_gaussian_beta() must be
    //                  met.
    //  Returns:    Return a scanline's light output over a given pixel, using
    //              a generalized or pure Gaussian distribution and sampling or
    //              integrals as desired by user codepath choices.
    if(beam_generalized_gaussian == true)
    {
        if(beam_antialias_level > 1.5)
        {
            return scanline_generalized_gaussian_integral_contrib(
                dist, color, pixel_height, sigma_range, shape_range);
        }
        else
        {
            return scanline_generalized_gaussian_sampled_contrib(
                dist, color, pixel_height, sigma_range, shape_range);
        }
    }
    else
    {
        if(beam_antialias_level > 1.5)
        {
            return scanline_gaussian_integral_contrib(
                dist, color, pixel_height, sigma_range);
        }
        else
        {
            return scanline_gaussian_sampled_contrib(
                dist, color, pixel_height, sigma_range);
        }
    }
}

#endif  //  SCANLINE_FUNCTIONS_H
////////////   END #include scanline-functions.h     //////////////////

#ifndef PHOSPHOR_MASK_RESIZING_H
#define PHOSPHOR_MASK_RESIZING_H

/////////////////////////////  GPL LICENSE NOTICE  /////////////////////////////

//  crt-royale: A full-featured CRT shader, with cheese.
//  Copyright (C) 2014 TroggleMonkey <trogglemonkey@gmx.com>
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along with
//  this program; if not, write to the Free Software Foundation, Inc., 59 Temple
//  Place, Suite 330, Boston, MA 02111-1307 USA


//////////////////////////////////  INCLUDES  //////////////////////////////////

//#include "../user-settings.h"
//#include "derived-settings-and-constants.h"

/////////////////////////////  CODEPATH SELECTION  /////////////////////////////

//  Choose a looping strategy based on what's allowed:
//  Dynamic loops not allowed: Use a flat static loop.
//  Dynamic loops accomodated: Coarsely branch around static loops.
//  Dynamic loops assumed allowed: Use a flat dynamic loop.
#ifndef DRIVERS_ALLOW_DYNAMIC_BRANCHES
    #ifdef ACCOMODATE_POSSIBLE_DYNAMIC_LOOPS
        #define BREAK_LOOPS_INTO_PIECES
    #else
        #define USE_SINGLE_STATIC_LOOP
    #endif
#endif  //  No else needed: Dynamic loops assumed.


    #define CALCULATE_R_COORD_FOR_4_SAMPLES                                    \
        vec4 true_i = vec4(i_base + i) + vec4(0.0, 1.0, 2.0, 3.0); \
        vec4 tile_uv_r = fract(                                         \
            first_texel_tile_uv_rrrr + true_i * tile_dr);                      \
        vec4 tex_uv_r = tile_uv_r * tile_size_uv_r;

    #define VERTICAL_SINC_RESAMPLE_LOOP_BODY                                   \
        CALCULATE_R_COORD_FOR_4_SAMPLES;                                       \
        vec3 new_sample0 = tex2Dlod0try(texture,                       \
            vec2(tex_uv.x, tex_uv_r.x)).rgb;                                 \
        vec3 new_sample1 = tex2Dlod0try(texture,                       \
            vec2(tex_uv.x, tex_uv_r.y)).rgb;                                 \
        vec3 new_sample2 = tex2Dlod0try(texture,                       \
            vec2(tex_uv.x, tex_uv_r.z)).rgb;                                 \
        vec3 new_sample3 = tex2Dlod0try(texture,                       \
            vec2(tex_uv.x, tex_uv_r.w)).rgb;                                 \
        UPDATE_COLOR_AND_WEIGHT_SUMS;
		
	#define UPDATE_COLOR_AND_WEIGHT_SUMS                                       \
        vec4 dist = magnification_scale *                              \
            abs(first_dist_unscaled - true_i);                                 \
        vec4 pi_dist = pi * dist;                                      \
        CALCULATE_SINC_RESAMPLE_WEIGHTS;                                       \
        pixel_color += new_sample0 * weights.xxx;                              \
        pixel_color += new_sample1 * weights.yyy;                              \
        pixel_color += new_sample2 * weights.zzz;                              \
        pixel_color += new_sample3 * weights.www;                              \
        weight_sum += weights;
		
	#ifdef PHOSPHOR_MASK_RESIZE_LANCZOS_WINDOW
        #define CALCULATE_SINC_RESAMPLE_WEIGHTS                                \
            vec4 pi_dist_over_lobes = pi_over_lobes * dist;            \
            vec4 weights = min(sin(pi_dist) * sin(pi_dist_over_lobes) /\
                (pi_dist*pi_dist_over_lobes), vec4(1.0));
    #else
        #define CALCULATE_SINC_RESAMPLE_WEIGHTS                                \
            vec4 weights = min(sin(pi_dist)/pi_dist, vec4(1.0));
    #endif
	
	#define HORIZONTAL_SINC_RESAMPLE_LOOP_BODY                                 \
        CALCULATE_R_COORD_FOR_4_SAMPLES;                                       \
        vec3 new_sample0 = tex2Dlod0try(texture,                       \
            vec2(tex_uv_r.x, tex_uv.y)).rgb;                                 \
        vec3 new_sample1 = tex2Dlod0try(texture,                       \
            vec2(tex_uv_r.y, tex_uv.y)).rgb;                                 \
        vec3 new_sample2 = tex2Dlod0try(texture,                       \
            vec2(tex_uv_r.z, tex_uv.y)).rgb;                                 \
        vec3 new_sample3 = tex2Dlod0try(texture,                       \
            vec2(tex_uv_r.w, tex_uv.y)).rgb;                                 \
        UPDATE_COLOR_AND_WEIGHT_SUMS;

//////////////////////////////////  CONSTANTS  /////////////////////////////////

//  The larger the resized tile, the fewer samples we'll need for downsizing.
//  See if we can get a static min tile size > mask_min_allowed_tile_size:
float mask_min_allowed_tile_size = ceil(
    mask_min_allowed_triad_size * mask_triads_per_tile);
float mask_min_expected_tile_size = 
        mask_min_allowed_tile_size;
//  Limit the number of sinc resize taps by the maximum minification factor:
float pi_over_lobes = pi/mask_sinc_lobes;
float max_sinc_resize_samples_float = 2.0 * mask_sinc_lobes *
    mask_resize_src_lut_size.x/mask_min_expected_tile_size;
//  Vectorized loops sample in multiples of 4.  Round up to be safe:
float max_sinc_resize_samples_m4 = ceil(
    max_sinc_resize_samples_float * 0.25) * 4.0;
	
	/////////////////////////  RESAMPLING FUNCTION HELPERS  ////////////////////////

float get_dynamic_loop_size(float magnification_scale)
{
    //  Requires:   The following global constants must be defined:
    //              1.) mask_sinc_lobes
    //              2.) max_sinc_resize_samples_m4
    //  Returns:    The minimum number of texture samples for a correct downsize
    //              at magnification_scale.
    //  We're downsizing, so the filter is sized across 2*lobes output pixels
    //  (not 2*lobes input texels).  This impacts distance measurements and the
    //  minimum number of input samples needed.
    float min_samples_float = 2.0 * mask_sinc_lobes / magnification_scale;
    float min_samples_m4 = ceil(min_samples_float * 0.25) * 4.0;
    #ifdef DRIVERS_ALLOW_DYNAMIC_BRANCHES
        float max_samples_m4 = max_sinc_resize_samples_m4;
    #else   // ifdef BREAK_LOOPS_INTO_PIECES
        //  Simulating loops with branches imposes a 128-sample limit.
        float max_samples_m4 = min(128.0, max_sinc_resize_samples_m4);
    #endif
    return min(min_samples_m4, max_samples_m4);
}

vec2 get_first_texel_tile_uv_and_dist(vec2 tex_uv, 
    vec2 texture_size, float dr, 
    float input_tiles_per_texture_r, float samples,
    bool vertical)
{
    //  Requires:   1.) dr == du == 1.0/texture_size.x or
    //                  dr == dv == 1.0/texture_size.y
    //                  (whichever direction we're resampling in).
    //                  It's a scalar to save register space.
    //              2.) input_tiles_per_texture_r is the number of input tiles
    //                  that can fit in the input texture in the direction we're
    //                  resampling this pass.
    //              3.) vertical indicates whether we're resampling vertically
    //                  this pass (or horizontally).
    //  Returns:    Pack and return the first sample's tile_uv coord in [0, 1]
    //              and its texel distance from the destination pixel, in the
    //              resized dimension only.
    //  We'll start with the topmost or leftmost sample and work down or right,
    //  so get the first sample location and distance.  Modify both dimensions
    //  as if we're doing a one-pass 2D resize; we'll throw away the unneeded
    //  (and incorrect) dimension at the end.
    vec2 curr_texel = tex_uv * texture_size;
    vec2 prev_texel =
        floor(curr_texel - vec2(under_half)) + vec2(0.5);
    vec2 first_texel = prev_texel - vec2(samples/2.0 - 1.0);
    vec2 first_texel_uv_wrap_2D = first_texel * dr;
    vec2 first_texel_dist_2D = curr_texel - first_texel;
    //  Convert from tex_uv to tile_uv coords so we can sub fracts for fmods.
    vec2 first_texel_tile_uv_wrap_2D =
        first_texel_uv_wrap_2D * input_tiles_per_texture_r;
    //  Project wrapped coordinates to the [0, 1] range.  We'll do this with all
    //  samples,but the first texel is special, since it might be negative.
    vec2 coord_negative = vec2(0.0);
        if(first_texel_tile_uv_wrap_2D.x < 0.0) coord_negative.x = first_texel_tile_uv_wrap_2D.x;
		if(first_texel_tile_uv_wrap_2D.x < 0.0) coord_negative.y = first_texel_tile_uv_wrap_2D.y;
    vec2 first_texel_tile_uv_2D =
        fract(first_texel_tile_uv_wrap_2D) + coord_negative;
    //  Pack the first texel's tile_uv coord and texel distance in 1D:
    vec2 tile_u_and_dist =
        vec2(first_texel_tile_uv_2D.x, first_texel_dist_2D.x);
    vec2 tile_v_and_dist =
        vec2(first_texel_tile_uv_2D.y, first_texel_dist_2D.y);
    return vertical ? tile_v_and_dist : tile_u_and_dist;
    //return mix(tile_u_and_dist, tile_v_and_dist, float(vertical));
}

vec4 tex2Dlod0try(sampler2D tex, vec2 tex_uv)
{
    //  Mipmapping and anisotropic filtering get confused by sinc-resampling.
    //  One [slow] workaround is to select the lowest mip level:
    #ifdef ANISOTROPIC_RESAMPLING_COMPAT_TEX2DLOD
        return tex2Dlod(tex, vec4(tex_uv, 0.0, 0.0));
    #else
        #ifdef ANISOTROPIC_RESAMPLING_COMPAT_TEX2DBIAS
            return tex2Dbias(tex, vec4(tex_uv, 0.0, -16.0));
        #else
            return texture(tex, tex_uv);
        #endif
    #endif
}
	
////////////////////////////  TILE SIZE CALCULATION  ///////////////////////////

vec2 get_resized_mask_tile_size(vec2 estimated_viewport_size,
    vec2 estimated_mask_resize_output_size,
    bool solemnly_swear_same_inputs_for_every_pass)
{
    //  Requires:   The following global constants must be defined according to
    //              certain constraints:
    //              1.) mask_resize_num_triads: Must be high enough that our
    //                  mask sampling method won't have artifacts later
    //                  (long story; see derived-settings-and-constants.h)
    //              2.) mask_resize_src_lut_size: Texel size of our mask LUT
    //              3.) mask_triads_per_tile: Num horizontal triads in our LUT
    //              4.) mask_min_allowed_triad_size: User setting (the more
    //                  restrictive it is, the faster the resize will go)
    //              5.) mask_min_allowed_tile_size_x < mask_resize_src_lut_size.x
    //              6.) mask_triad_size_desired_{runtime, static}
    //              7.) mask_num_triads_desired_{runtime, static}
    //              8.) mask_specify_num_triads must be 0.0/1.0 (false/true)
    //              The function parameters must be defined as follows:
    //              1.) estimated_viewport_size == (final viewport size);
    //                  If mask_specify_num_triads is 1.0/true and the viewport
    //                  estimate is wrong, the number of triads will differ from
    //                  the user's preference by about the same factor.
    //              2.) estimated_mask_resize_output_size: Must equal the
    //                  output size of the MASK_RESIZE pass.
    //                  Exception: The x component may be estimated garbage if
    //                  and only if the caller throws away the x result.
    //              3.) solemnly_swear_same_inputs_for_every_pass: Set to false,
    //                  unless you can guarantee that every call across every
    //                  pass will use the same sizes for the other parameters.
    //              When calling this across multiple passes, always use the
    //              same y viewport size/scale, and always use the same x
    //              viewport size/scale when using the x result.
    //  Returns:    Return the final size of a manually resized mask tile, after
    //              constraining the desired size to avoid artifacts.  Under
    //              unusual circumstances, tiles may become stretched vertically
    //              (see wall of text below).
    //  Stated tile properties must be correct:
    float tile_aspect_ratio_inv =
        mask_resize_src_lut_size.y/mask_resize_src_lut_size.x;
    float tile_aspect_ratio = 1.0/tile_aspect_ratio_inv;
    vec2 tile_aspect = vec2(1.0, tile_aspect_ratio_inv);
    //  If mask_specify_num_triads is 1.0/true and estimated_viewport_size.x is
    //  wrong, the user preference will be misinterpreted:
    float desired_tile_size_x = mask_triads_per_tile * mix(
        mask_triad_size_desired,
        estimated_viewport_size.x / mask_num_triads_desired,
        mask_specify_num_triads);
    if(mask_sample_mode_desired > 0.5)
    {
        //  We don't need constraints unless we're sampling MASK_RESIZE.
        return desired_tile_size_x * tile_aspect;
    }
    //  Make sure we're not upsizing:
    float temp_tile_size_x =
        min(desired_tile_size_x, mask_resize_src_lut_size.x);
    //  Enforce min_tile_size and max_tile_size in both dimensions:
    vec2 temp_tile_size = temp_tile_size_x * tile_aspect;
    vec2 min_tile_size =
        mask_min_allowed_tile_size * tile_aspect;
    vec2 max_tile_size =
        estimated_mask_resize_output_size / mask_resize_num_tiles;
    vec2 clamped_tile_size =
        clamp(temp_tile_size, min_tile_size, max_tile_size);
    //  Try to maintain tile_aspect_ratio.  This is the tricky part:
    //  If we're currently resizing in the y dimension, the x components
    //  could be MEANINGLESS.  (If estimated_mask_resize_output_size.x is
    //  bogus, then so is max_tile_size.x and clamped_tile_size.x.)
    //  We can't adjust the y size based on clamped_tile_size.x.  If it
    //  clamps when it shouldn't, it won't clamp again when later passes
    //  call this function with the correct sizes, and the discrepancy will
    //  break the sampling coords in MASKED_SCANLINES.  Instead, we'll limit
    //  the x size based on the y size, but not vice versa, unless the
    //  caller swears the parameters were the same (correct) in every pass.
    //  As a result, triads could appear vertically stretched if:
    //  a.) mask_resize_src_lut_size.x > mask_resize_src_lut_size.y: Wide
    //      LUT's might clamp x more than y (all provided LUT's are square)
    //  b.) true_viewport_size.x < true_viewport_size.y: The user is playing
    //      with a vertically oriented screen (not accounted for anyway)
    //  c.) mask_resize_viewport_scale.x < masked_resize_viewport_scale.y:
    //      Viewport scales are equal by default.
    //  If any of these are the case, you can fix the stretching by setting:
    //      mask_resize_viewport_scale.x = mask_resize_viewport_scale.y *
    //          (1.0 / min_expected_aspect_ratio) *
    //          (mask_resize_src_lut_size.x / mask_resize_src_lut_size.y)
    float x_tile_size_from_y =
        clamped_tile_size.y * tile_aspect_ratio;
    float y_tile_size_from_x = mix(clamped_tile_size.y,
        clamped_tile_size.x * tile_aspect_ratio_inv,
        float(solemnly_swear_same_inputs_for_every_pass));
    vec2 reclamped_tile_size = vec2(
        min(clamped_tile_size.x, x_tile_size_from_y),
        min(clamped_tile_size.y, y_tile_size_from_x));
    //  We need integer tile sizes in both directions for tiled sampling to
    //  work correctly.  Use floor (to make sure we don't round up), but be
    //  careful to avoid a rounding bug where floor decreases whole numbers:
    vec2 final_resized_tile_size =
        floor(reclamped_tile_size + vec2(FIX_ZERO(0.0)));
    return final_resized_tile_size;
}

/////////////////////////  FINAL MASK SAMPLING HELPERS  ////////////////////////

vec4 get_mask_sampling_parameters(vec2 mask_resize_texture_size,
    vec2 mask_resize_video_size, vec2 true_viewport_size,
    out vec2 mask_tiles_per_screen)
{
    //  Requires:   1.) Requirements of get_resized_mask_tile_size() must be
    //                  met, particularly regarding global constants.
    //              The function parameters must be defined as follows:
    //              1.) mask_resize_texture_size == MASK_RESIZE.texture_size
    //                  if get_mask_sample_mode() is 0 (otherwise anything)
    //              2.) mask_resize_video_size == MASK_RESIZE.video_size
    //                  if get_mask_sample_mode() is 0 (otherwise anything)
    //              3.) true_viewport_size == IN.output_size for a pass set to
    //                  1.0 viewport scale (i.e. it must be correct)
    //  Returns:    Return a vec4 containing:
    //                  xy: tex_uv coords for the start of the mask tile
    //                  zw: tex_uv size of the mask tile from start to end
    //              mask_tiles_per_screen is an out parameter containing the
    //              number of mask tiles that will fit on the screen.
    //  First get the final resized tile size.  The viewport size and mask
    //  resize viewport scale must be correct, but don't solemnly swear they
    //  were correct in both mask resize passes unless you know it's true.
    //  (We can better ensure a correct tile aspect ratio if the parameters are
    //  guaranteed correct in all passes...but if we lie, we'll get inconsistent
    //  sizes across passes, resulting in broken texture coordinates.)
    float mask_sample_mode = mask_sample_mode_desired;//get_mask_sample_mode();
    vec2 mask_resize_tile_size = get_resized_mask_tile_size(
        true_viewport_size, mask_resize_video_size, false);
    if(mask_sample_mode < 0.5)
    {
        //  Sample MASK_RESIZE: The resized tile is a fracttion of the texture
        //  size and starts at a nonzero offset to allow for border texels:
        vec2 mask_tile_uv_size = mask_resize_tile_size /
            mask_resize_texture_size;
        vec2 skipped_tiles = mask_start_texels/mask_resize_tile_size;
        vec2 mask_tile_start_uv = skipped_tiles * mask_tile_uv_size;
        //  mask_tiles_per_screen must be based on the *true* viewport size:
        mask_tiles_per_screen = true_viewport_size / mask_resize_tile_size;
        return vec4(mask_tile_start_uv, mask_tile_uv_size);
    }
    else
    {
        //  If we're tiling at the original size (1:1 pixel:texel), redefine a
        //  "tile" to be the full texture containing many triads.  Otherwise,
        //  we're hardware-resampling an LUT, and the texture truly contains a
        //  single unresized phosphor mask tile anyway.
        vec2 mask_tile_uv_size = vec2(1.0);
        vec2 mask_tile_start_uv = vec2(0.0);
        if(mask_sample_mode > 1.5)
        {
            //  Repeat the full LUT at a 1:1 pixel:texel ratio without resizing:
            mask_tiles_per_screen = true_viewport_size/mask_texture_large_size;
        }
        else
        {
            //  Hardware-resize the original LUT:
            mask_tiles_per_screen = true_viewport_size / mask_resize_tile_size;
        }
        return vec4(mask_tile_start_uv, mask_tile_uv_size);
    }
}

////////////////////////////  RESAMPLING FUNCTIONS  ////////////////////////////

vec3 downsample_vertical_sinc_tiled(sampler2D texture,
    vec2 tex_uv, vec2 texture_size, float dr,
    float magnification_scale, float tile_size_uv_r)
{
    //  Requires:   1.) dr == du == 1.0/texture_size.x or
    //                  dr == dv == 1.0/texture_size.y
    //                  (whichever direction we're resampling in).
    //                  It's a scalar to save register space.
    //              2.) tile_size_uv_r is the number of texels an input tile
    //                  takes up in the input texture, in the direction we're
    //                  resampling this pass.
    //              3.) magnification_scale must be <= 1.0.
    //  Returns:    Return a [Lanczos] sinc-resampled pixel of a vertically
    //              downsized input tile embedded in an input texture.  (The
    //              vertical version is special-cased though: It assumes the
    //              tile size equals the [static] texture size, since it's used
    //              on an LUT texture input containing one tile.  For more
    //              generic use, eliminate the "static" in the parameters.)
    //  The "r" in "dr," "tile_size_uv_r," etc. refers to the dimension
    //  we're resizing along, e.g. "dy" in this case.
    #ifdef USE_SINGLE_STATIC_LOOP
        //  A static loop can be faster, but it might blur too much from using
        //  more samples than it should.
        int samples = int(max_sinc_resize_samples_m4);
    #else
        int samples = int(get_dynamic_loop_size(magnification_scale));
    #endif

    //  Get the first sample location (scalar tile uv coord along the resized
    //  dimension) and distance from the output location (in texels):
    float input_tiles_per_texture_r = 1.0/tile_size_uv_r;
    //  true = vertical resize:
    vec2 first_texel_tile_r_and_dist = get_first_texel_tile_uv_and_dist(
        tex_uv, texture_size, dr, input_tiles_per_texture_r, samples, true);
    vec4 first_texel_tile_uv_rrrr = first_texel_tile_r_and_dist.xxxx;
    vec4 first_dist_unscaled = first_texel_tile_r_and_dist.yyyy;
    //  Get the tile sample offset:
    float tile_dr = dr * input_tiles_per_texture_r;

    //  Sum up each weight and weighted sample color, varying the looping
    //  strategy based on our expected dynamic loop capabilities.  See the
    //  loop body macros above.
    int i_base = 0;
    vec4 weight_sum = vec4(0.0);
    vec3 pixel_color = vec3(0.0);
    int i_step = 4;
    #ifdef BREAK_LOOPS_INTO_PIECES
        if(samples - i_base >= 64)
        {
            for(int i = 0; i < 64; i += i_step)
            {
                VERTICAL_SINC_RESAMPLE_LOOP_BODY;
            }
            i_base += 64;
        }
        if(samples - i_base >= 32)
        {
            for(int i = 0; i < 32; i += i_step)
            {
                VERTICAL_SINC_RESAMPLE_LOOP_BODY;
            }
            i_base += 32;
        }
        if(samples - i_base >= 16)
        {
            for(int i = 0; i < 16; i += i_step)
            {
                VERTICAL_SINC_RESAMPLE_LOOP_BODY;
            }
            i_base += 16;
        }
        if(samples - i_base >= 8)
        {
            for(int i = 0; i < 8; i += i_step)
            {
                VERTICAL_SINC_RESAMPLE_LOOP_BODY;
            }
            i_base += 8;
        }
        if(samples - i_base >= 4)
        {
            for(int i = 0; i < 4; i += i_step)
            {
                VERTICAL_SINC_RESAMPLE_LOOP_BODY;
            }
            i_base += 4;
        }
        //  Do another 4-sample block for a total of 128 max samples.
        if(samples - i_base > 0)
        {
            for(int i = 0; i < 4; i += i_step)
            {
                VERTICAL_SINC_RESAMPLE_LOOP_BODY;
            }
        }
    #else
        for(int i = 0; i < samples; i += i_step)
        {
            VERTICAL_SINC_RESAMPLE_LOOP_BODY;
        }
    #endif
    //  Normalize so the weight_sum == 1.0, and return:
    vec2 weight_sum_reduce = weight_sum.xy + weight_sum.zw;
    vec3 scalar_weight_sum = vec3(weight_sum_reduce.x + 
        weight_sum_reduce.y);
    return (pixel_color/scalar_weight_sum);
}

vec3 downsample_horizontal_sinc_tiled(sampler2D texture,
    vec2 tex_uv, vec2 texture_size, float dr,
    float magnification_scale, float tile_size_uv_r)
{
    //  Differences from downsample_horizontal_sinc_tiled:
    //  1.) The dr and tile_size_uv_r parameters are not static consts.
    //  2.) The "vertical" parameter to get_first_texel_tile_uv_and_dist is
    //      set to false instead of true.
    //  3.) The horizontal version of the loop body is used.
    //  TODO: If we can get guaranteed compile-time dead code elimination,
    //  we can combine the vertical/horizontal downsampling functions by:
    //  1.) Add an extra static bool parameter called "vertical."
    //  2.) Supply it with the result of get_first_texel_tile_uv_and_dist().
    //  3.) Use a conditional assignment in the loop body macro.  This is the
    //      tricky part: We DO NOT want to incur the extra conditional
    //      assignment in the inner loop at runtime!
    //  The "r" in "dr," "tile_size_uv_r," etc. refers to the dimension
    //  we're resizing along, e.g. "dx" in this case.
    #ifdef USE_SINGLE_STATIC_LOOP
        //  If we have to load all samples, we might as well use them.
        int samples = int(max_sinc_resize_samples_m4);
    #else
        int samples = int(get_dynamic_loop_size(magnification_scale));
    #endif

    //  Get the first sample location (scalar tile uv coord along resized
    //  dimension) and distance from the output location (in texels):
    float input_tiles_per_texture_r = 1.0/tile_size_uv_r;
    //  false = horizontal resize:
    vec2 first_texel_tile_r_and_dist = get_first_texel_tile_uv_and_dist(
        tex_uv, texture_size, dr, input_tiles_per_texture_r, samples, false);
    vec4 first_texel_tile_uv_rrrr = first_texel_tile_r_and_dist.xxxx;
    vec4 first_dist_unscaled = first_texel_tile_r_and_dist.yyyy;
    //  Get the tile sample offset:
    float tile_dr = dr * input_tiles_per_texture_r;

    //  Sum up each weight and weighted sample color, varying the looping
    //  strategy based on our expected dynamic loop capabilities.  See the
    //  loop body macros above.
    int i_base = 0;
    vec4 weight_sum = vec4(0.0);
    vec3 pixel_color = vec3(0.0);
    int i_step = 4;
    #ifdef BREAK_LOOPS_INTO_PIECES
        if(samples - i_base >= 64)
        {
            for(int i = 0; i < 64; i += i_step)
            {
                HORIZONTAL_SINC_RESAMPLE_LOOP_BODY;
            }
            i_base += 64;
        }
        if(samples - i_base >= 32)
        {
            for(int i = 0; i < 32; i += i_step)
            {
                HORIZONTAL_SINC_RESAMPLE_LOOP_BODY;
            }
            i_base += 32;
        }
        if(samples - i_base >= 16)
        {
            for(int i = 0; i < 16; i += i_step)
            {
                HORIZONTAL_SINC_RESAMPLE_LOOP_BODY;
            }
            i_base += 16;
        }
        if(samples - i_base >= 8)
        {
            for(int i = 0; i < 8; i += i_step)
            {
                HORIZONTAL_SINC_RESAMPLE_LOOP_BODY;
            }
            i_base += 8;
        }
        if(samples - i_base >= 4)
        {
            for(int i = 0; i < 4; i += i_step)
            {
                HORIZONTAL_SINC_RESAMPLE_LOOP_BODY;
            }
            i_base += 4;
        }
        //  Do another 4-sample block for a total of 128 max samples.
        if(samples - i_base > 0)
        {
            for(int i = 0; i < 4; i += i_step)
            {
                HORIZONTAL_SINC_RESAMPLE_LOOP_BODY;
            }
        }
    #else
        for(int i = 0; i < samples; i += i_step)
        {
            HORIZONTAL_SINC_RESAMPLE_LOOP_BODY;
        }
    #endif
    //  Normalize so the weight_sum == 1.0, and return:
    vec2 weight_sum_reduce = weight_sum.xy + weight_sum.zw;
    vec3 scalar_weight_sum = vec3(weight_sum_reduce.x +
        weight_sum_reduce.y);
    return (pixel_color/scalar_weight_sum);
}

vec2 convert_phosphor_tile_uv_wrap_to_tex_uv(vec2 tile_uv_wrap,
    vec4 mask_tile_start_uv_and_size)
{
    //  Requires:   1.) tile_uv_wrap contains tile-relative uv coords, where the
    //                  tile spans from [0, 1], such that (0.5, 0.5) is at the
    //                  tile center.  The input coords can range from [0, inf],
    //                  and their fracttional parts map to a repeated tile.
    //                  ("Tile" can mean texture, the video embedded in the
    //                  texture, or some other "tile" embedded in a texture.)
    //              2.) mask_tile_start_uv_and_size.xy contains tex_uv coords
    //                  for the start of the embedded tile in the full texture.
    //              3.) mask_tile_start_uv_and_size.zw contains the [fracttional]
    //                  tex_uv size of the embedded tile in the full texture.
    //  Returns:    Return tex_uv coords (used for texture sampling)
    //              corresponding to tile_uv_wrap.
    if(mask_sample_mode_desired < 0.5)
    {
        //  Manually repeat the resized mask tile to fill the screen:
        //  First get fracttional tile_uv coords.  Using fract/fmod on coords
        //  confuses anisotropic filtering; fix it as user options dictate.
        //  derived-settings-and-constants.h disables incompatible options.
        #ifdef ANISOTROPIC_TILING_COMPAT_TILE_FLAT_TWICE
            vec2 tile_uv = fract(tile_uv_wrap * 0.5) * 2.0;
        #else
            vec2 tile_uv = fract(tile_uv_wrap);
        #endif
        #ifdef ANISOTROPIC_TILING_COMPAT_FIX_DISCONTINUITIES
            vec2 tile_uv_dx = ddx(tile_uv);
            vec2 tile_uv_dy = ddy(tile_uv);
            tile_uv = fix_tiling_discontinuities_normalized(tile_uv,
                tile_uv_dx, tile_uv_dy);
        #endif
        //  The tile is embedded in a padded FBO, and it may start at a
        //  nonzero offset if border texels are used to avoid artifacts:
        vec2 mask_tex_uv = mask_tile_start_uv_and_size.xy +
            tile_uv * mask_tile_start_uv_and_size.zw;
        return mask_tex_uv;
    }
    else
    {
        //  Sample from the input phosphor mask texture with hardware tiling.
        //  If we're tiling at the original size (mode 2), the "tile" is the
        //  whole texture, and it contains a large number of triads mapped with
        //  a 1:1 pixel:texel ratio.  OTHERWISE, the texture contains a single
        //  unresized tile.  tile_uv_wrap already has correct coords for both!
        return tile_uv_wrap;
    }
}

#endif  //  PHOSPHOR_MASK_RESIZING_H

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//

#if defined(VERTEX)

#if __VERSION__ >= 130
#define COMPAT_VARYING out
#define COMPAT_ATTRIBUTE in
#define COMPAT_TEXTURE texture
#else
#define COMPAT_VARYING varying 
#define COMPAT_ATTRIBUTE attribute 
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

COMPAT_ATTRIBUTE vec4 VertexCoord;
COMPAT_ATTRIBUTE vec4 COLOR;
COMPAT_ATTRIBUTE vec4 TexCoord;
COMPAT_VARYING vec4 COL0;
COMPAT_VARYING vec4 TEX0;
COMPAT_VARYING vec2 src_tex_uv_wrap;
COMPAT_VARYING vec2 tile_uv_wrap;
COMPAT_VARYING vec2 resize_magnification_scale;
COMPAT_VARYING vec2 src_dxdy;
COMPAT_VARYING vec2 tile_size_uv;
COMPAT_VARYING vec2 input_tiles_per_texture;

vec4 _oPosition1; 
uniform mat4 MVPMatrix;
uniform int FrameDirection;
uniform int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;

// compatibility #defines
#define tex_uv TEX0.xy
#define SourceSize vec4(TextureSize, 1.0 / TextureSize) //either TextureSize or InputSize
#define OutSize vec4(OutputSize, 1.0 / OutputSize)

void main()
{
    gl_Position = MVPMatrix * VertexCoord;
    TEX0.xy = TexCoord.xy;

	//  First estimate the viewport size (the user will get the wrong number of
    //  triads if it's wrong and mask_specify_num_triads is 1.0/true).
	vec2 estimated_viewport_size =
        OutputSize.xy / mask_resize_viewport_scale;
	//  Find the final size of our resized phosphor mask tiles.  We probably
    //  estimated the viewport size and MASK_RESIZE output size differently last
    //  pass, so do not swear they were the same. ;)
	vec2 mask_resize_tile_size = get_resized_mask_tile_size(
        estimated_viewport_size, OutputSize.xy, false);
		
	//  We'll render resized tiles until filling the output FBO or meeting a
    //  limit, so compute [wrapped] tile uv coords based on the output uv coords
    //  and the number of tiles that will fit in the FBO.
    vec2 output_tiles_this_pass = OutputSize.xy / mask_resize_tile_size;
    vec2 output_video_uv = tex_uv * TextureSize / InputSize;
    tile_uv_wrap = output_video_uv * output_tiles_this_pass;
	
	//  Get the texel size of an input tile and related values:
    vec2 input_tile_size = vec2(min(
        mask_resize_src_lut_size.x, InputSize.x), mask_resize_tile_size.y);
    tile_size_uv = input_tile_size * SourceSize.zw;
    input_tiles_per_texture = SourceSize.xy / input_tile_size;
	
	//  Derive [wrapped] texture uv coords from [wrapped] tile uv coords and
    //  the tile size in uv coords, and save frac() for the fragment shader.
    src_tex_uv_wrap = tile_uv_wrap * tile_size_uv;
	
	resize_magnification_scale = mask_resize_tile_size / input_tile_size;
    src_dxdy = vec2(SourceSize.z, 0.0);
}

#elif defined(FRAGMENT)
#pragma format R8G8B8A8_SRGB

#if __VERSION__ >= 130
#define COMPAT_VARYING in
#define COMPAT_TEXTURE texture
out vec4 FragColor;
#else
#define COMPAT_VARYING varying
#define FragColor gl_FragColor
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

uniform int FrameDirection;
uniform int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;
uniform sampler2D Texture;
COMPAT_VARYING vec4 TEX0;
COMPAT_VARYING vec2 src_tex_uv_wrap;
COMPAT_VARYING vec2 tile_uv_wrap;
COMPAT_VARYING vec2 resize_magnification_scale;
COMPAT_VARYING vec2 src_dxdy;
COMPAT_VARYING vec2 tile_size_uv;
COMPAT_VARYING vec2 input_tiles_per_texture;

// compatibility #defines
#define Source Texture
#define tex_uv TEX0.xy
#define texture(c, d) COMPAT_TEXTURE(c, d)
#define SourceSize vec4(TextureSize, 1.0 / TextureSize) //either TextureSize or InputSize
#define OutSize vec4(OutputSize, 1.0 / OutputSize)

void main()
{
    //  The input contains one mask tile horizontally and a number vertically.
    //  Resize the tile horizontally to its final screen size and repeat it
    //  until drawing at least mask_resize_num_tiles, leaving it unchanged
    //  vertically.  Lanczos-resizing the phosphor mask achieves much sharper
    //  results than mipmapping, outputting >= mask_resize_num_tiles makes for
    //  easier tiled sampling later.
    #ifdef PHOSPHOR_MASK_MANUALLY_RESIZE
        //  Discard unneeded fragments in case our profile allows real branches.
//        vec2 tile_uv_wrap = tile_uv_wrap;
        if(mask_sample_mode_desired < 0.5 &&
            max(tile_uv_wrap.x, tile_uv_wrap.y) <= mask_resize_num_tiles)
        {
            float src_dx = src_dxdy.x;
            vec2 src_tex_uv = fract(src_tex_uv_wrap);
            vec3 pixel_color = downsample_horizontal_sinc_tiled(Source,
                src_tex_uv, SourceSize.xy, src_dxdy.x,
                resize_magnification_scale.x, tile_size_uv.x);
            //  The input LUT was linear RGB, and so is our output:
            FragColor = vec4(pixel_color, 1.0);
        }
        else
        {
            discard;
        }
    #else
        discard;
        FragColor = vec4(1.0);
    #endif
} 
#endif

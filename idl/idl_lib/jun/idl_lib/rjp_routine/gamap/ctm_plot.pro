; $Id: ctm_plot.pro,v 1.4 2005/03/24 18:03:11 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        CTM_PLOT
;
; PURPOSE:
;        General plotting tool for CTM data that is stored in the 
;        GAMAP datainfo and fileinfo structures. CTM_PLOT can 
;        handle everything from 0-D to 3-D and has many different
;        plot options, especially for 2-D plots for which it was
;        originally designed. E.g. full map support.
;
; CATEGORY:
;        Plotting
;
; CALLING SEQUENCE:
;        CTM_PLOT, [ Diagn [ [ ,Keywords ] ] 
;
; INPUTS:
;        DIAGN -> The diagnostic number (e.g. ND22, ND45, etc or 
;             category name (e.g. "JV-MAP", "IJ-AVG") for which to 
;             read data from the punch file. 
;
; KEYWORD PARAMETERS:
;    Keyword parameters passed to CTM_GET_DATABLOCK:
;    ===============================================
;        FILENAME -> Name of the punch file to read data from.  
;             FILENAME is passed to CTM_GET_DATABLOCK.  You can also
;             use a file mask, in which case FILENAME will return the 
;             full filename if it is a named variable. If an empty 
;             filename is provided, the default search mask from 
;             gamap.defaults (see gamap.cmn) will be used. If no 
;             filename is given, ctm_plot will try 
;             to find the records from data already loaded.
;
;        TRACER -> Number of tracer to read from the punch file.
;
;        TAU0, /FIRST, /LAST -> time step to be plotted
;
;        LON -> If /INDEX is set, LON denotes the CTM longitude index
;             of the box to plot.  Otherwise, LON denotes the actual 
;             longitude value of that box.
;
;        LAT -> If /INDEX is set, LAT denotes the CTM latitude index 
;             of the box to plot.  Otherwise, LAT denotes the actual 
;             latitude value of that box.
;
;        LEV -> An index array of sigma levels *OR* a two-element
;             vector specifying the min and max sigma levels to be 
;             included in the plot.  Default is [ 1, GRIDINFO.LMX ].
; 
;        ALTRANGE -> A vector specifying the min and max altitude
;             values to be included in the extracted data block.
;
;        PRANGE -> A vector specifying the min and max pressure 
;             levels to be included in the extracted data block.
;
;        /INDEX -> If set, will interpret LAT, LEV, and LON as CTM 
;             indices.  If not set, will interpret LAT, LEV, and LON
;             as the actual values of latitude, level, and longitude.
;             NOTE: If /INDEX is set, then GAMAP cannot create plots
;             for longitude ranges that span the date line!!!
;
;        AVERAGE -> If = 0, will not average the data 
;                      = 1, will average data longitudinally
;                      = 2, will average data latitudinally
;                      = 4, will average data vertically
;             These are cumulative (e.g. AVERAGE=3 will average over 
;             both lat and lon, and AVERAGE=7 will average over lat,
;             lon, and vertical levels to produce 1 data point).
;                       
;        TOTAL -> If = 0, will not total data
;                    = 1, will total data longitudinally
;                    = 2, will total data latitudinally
;                    = 4, will total data vertically
;             These are cumulative (e.g. TOTAL=3 will total over both 
;             lat and lon, and TOTAL=7 will total over lat, lon, and 
;             vertical levels to produce 1 data point).
;
;        USE_FILEINFO -> (optional) If provided, CTM_GET_DATABLOCK will 
;             restrict its search to only the files that are
;             contained in USE_FILEINFO which must be a FILEINFO 
;             structure array. Default is to use the global information 
;             (see gamap_cmn.pro).
;             If an undefined named variable is provided in USE_FILEINFO,
;             it will either contain the global FILEINFO structure array 
;             or the FILEINFO record of the specified file.
;             USE_FILEINFO and USE_DATAINFO must be consistent, and should
;             either both be used or omitted. However, it is
;             possible to provide the global FILEINFO structure 
;             (or nothing) with a local subset of DATAINFO.
;
;        USE_DATAINFO -> (optional) Restrict search to records contained
;             in USE_DATAINFO which must be a DATAINFO structure array. 
;             If an undefined named variable is provided in USE_DATAINFO,
;             it will either contain the global DATAINFO structure array 
;             or all DATAINFO records of the specified file.
;             See also USE_FILEINFO.
;
;    Keywords passed to CTM_CONVERT_UNIT:
;    ====================================
;        UNIT -> Name of the unit that the DATA array will be converted
;             to. If not specified, then no unit conversion will be done.
;
;    Keywords passed to TVMAP or TVPLOT:
;    ===================================
;        NOERASE -> Do not erase previous plot.
; 
;        POSITION -> A four-element array of normalized coordinates
;             that specifies the location of map on the plot. POSITION
;             has the same form as the POSITION keyword on a plot. 
;             Default is [0.1, 0.05, 0.9, 0.08]. (Passed to TVMAP).
;
;        NCOLORS -> This is the maximum color index that will be used.
;
;        BOTTOM -> The lowest color index of the colors to be loaded
;             used in the color map and color bar.
;
;        /NOCBAR -> If set, will not plot the colorbar below the map
;             in the position specified by CBPOSITION.  Default is to
;             plot a colorbar.
;
;        CBCOLOR -> Color index of the colorbar outline and
;             characters.  Defaults to BLACK (from colors_default.pro).
;
;        CBPOSITION -> A four-element array of normalized coordinates
;             that specifies the location of the colorbar. BARPOSITION 
;             has the same form as the POSITION keyword on a plot. 
;             Default is [0.1, 0.05, 0.9, 0.08]. 
;
;        CBUNIT -> Passes the Unit string to COLORBAR, which will be
;             plotted to the right of the color bar.  NOTE: For black
;             & white contour plots, the string specified by CBUNIT
;             will be plotted below the X-axis.  
;
;        CBFORMAT -> format to use in call to colorbar. Default is I12
;             if abs(max(data)) < 1e4, else e12.2 (strings get trimmed)
;
;        COLOR  -> Color index of the map outline and title characters.  
;             Defaults to BLACK (from colors_default.pro). Also used as
;             plot color for 1-D (line) plots.
;
;        MPARAM -> A 3 element vector containing values for
;             [ P0Lat, P0Lon, Rot ].  Default is [ 0, 0, 0 ].
;
;        POSITION -> A four-element array of normalized coordinates
;             that specifies the location of the map.  POSITION has
;             the same form as the POSITION keyword on a plot. 
;             Default is [0.1, 0.1, 0.9, 0.9]. 
;
;        TITLE -> The title string that is to be placed atop the
;             map window.  
;
;        /NOCONTINENTS -> If set, will suppress adding continent lines
;             to the map.  Default is to call MAP_CONTINENTS to plot
;             continent outlines or filled boundaries.
;
;        CCOLOR -> The color index of the continent outline or fill 
;             region.  Default is BLACK (from colors_default.pro).
; 
;        CFILL -> Value passed to FILL_CONTINENTS keyword of
;             MAP_CONTINENTS.  If CFILL=1 then will fill continents
;             with a solid color (as specified in CCOLOR above).  
;             If CFILL=2 then will fill continents with hatching.
;
;        /NOGRID -> If set, will suppress printing of grid lines.
;             Default is to call MAP_GRID to overlay grid lines.
; 
;        GCOLOR -> The color index of the grid lines.
;             Default is BLACK (from colors_default.pro)
;
;        /NOGLABELS -> Will suppres printing of labels for each grid
;             line in TVMAP.PRO.  Default is to print grid labels
;             for each grid line.
;
;        /NOISOTROPIC -> Will suppress plotting of an isotropic map
;             (i.e. one with the same X and Y scale).  Default is to 
;             print an isotropic map.
;  
;        /CONTOUR -> Will produce a line-contour map instead of the 
;             default color-pixel image map.
;
;        /FCONTOUR -> Will produce a filled contour map instead
;             of the default color-pixel image map. If you find
;             that one or more color bands are not filled properly, 
;             try the /CELL_FILL keyword. This is a known IDL precularity.
;
;        C_LEVELS -> Vector containing the contour levels.  If not
;             specified, TVMAP will use quasi-logarithmic levels.
;
;        C_COLORS -> Index array of color levels for each line (or
;             each fill section) of the contour map.  If not
;             specified, TVMAP will select default colors from the 
;             colortable.
;
;        C_ANNOTATION -> Vector containing the contour labels.
;             Default is to use string representations of C_LEVELS.
;
;        C_FORMAT -> Format string used in converting C_LEVELS to
;             the default C_ANNOTATION values.  Default is '(f8.1)'.
;
;        C_LABELS -> Specifies which contour levels should be labeled.
;             By default, every other contour level is labeled.  C_LABELS 
;             allows you to override this default and explicitly
;             specify the levels to label. This parameter is a vector, 
;             converted to integer type if necessary.  If the LEVELS 
;             keyword is specified, the elements of C_LABELS
;             correspond directly to the levels specified, otherwise, 
;             they correspond to the default levels chosen by the 
;             CONTOUR procedure. Setting an element of the vector to 
;             zero causes that contour label to not be labeled.  A
;             nonzero value forces labeling. 
;
;             NOTE: If C_LABELS is given as a scalar, then it will be
;             expanded to a vector with all elements having the same value.
;
;        /C_LINES -> Will overplot a filled-contour map with contour lines
;             and labels instead of plotting a colorbar. This was the old
;             default behaviour but has been changed with the advent of
;             "discrete" colorbars. The old NOLINES keyword is kept
;             for compatibility reasons but doesn't do anything.
;
;        /NOLABELS -> Will suppress printing contour labels on both
;             line-contour and filled-contour maps.
;
;        OVERLAYCOLOR -> Color of the solid lines that will be
;             overlaid atop a filled contour map.  Default is BLACK.
;
;        /OVERPLOT -> Add an additional line plot to an existing one.
;             You should specify LINE=n and/or COLOR=n to distinguish 
;             between curves in this case. You can manually add a legend
;             with legend.pro after the plot(s) are produced.
;             Note that the title string will contain information on 
;             your first selection only. Use an explicit TITLE for 
;             best results.
;
;        /SAMPLE -> Will cause REBIN (in TVMAP) to use nearest-
;             neighbor sampling rather than bilinear interpolation.
;
;        /LOG -> Will create a color-pixel plot with logarithmic
;             scaling.  /LOG has no effect on line-contour or
;             filled-contour plots, since the default contour levels
;             are quasi-logarithmic.
;
;        /POLAR -> Create a polar plot. Note that the longitude range must 
;             be -180..180 and the latitude range must extend to one pole
;             but not straddle the equator.
;
;
;    Keywords passed to ISOPLETH_MAP:
;    ================================
;        ISOPLETH -> Value for which a 3-D isosurface will be computed.
;             ISOPLETH_MAP assigns a default value of 35.0.  
;
;
;    Other Keywords:
;    ===============
;        USTR -> Unit string to be plotted to the right of the colorbar.  
;             If not specified, then CTM_PLOT  will construct a unit 
;             string based on the value of TRACERINFO.UNIT.
;             NOTE: USTR is a synonym for the keyword CBUNIT, which
;             specifies the color bar unit string.
;
;        THISDATAINFO -> Returns to the calling program the THISDATAINFO
;             structure obtained by CTM_GET_DATABLOCK.
;
;        LABELSTRU -> Returns to the calling program the structure
;             of label information obtained by CTM_LABEL.
; 
;        YRANGE -> range of y values for color scaling (default:
;             scale each plot seperately with data min and max)
;
;        X_FORMAT, Y_FORMAT (optional) -> Specifies the format string
;             (e.g. '(f10.3)', '(e14.2)' ) for the X and Y axes, when
;             making line plots.  If omitted, CTM_PLOT will call
;             GET_DEFAULTFORMAT to compute default format strings. 
;
;        RESULT -> A named variable will contain the data subset that was
;             plotted together with the X and/or Y coordinates in a structure.
;             For 1D plots, either X or Y are -1. 3D visualization returns
;             a structure including the Z coordinate.
;
;        _EXTRA=e -> Picks up extra keywords for CTM_GET_DATABLOCK,
;             CTM_LABEL, TVMAP, and TVPLOT.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ===========================================================
;        CTM_DRAW_CUBE                  CONVERT_LON
;        CTM_TRACERINFO                 CTM_CONVERT_UNIT
;        TVMAP                          TVPLOT
;        CHKSTRU           (function)   MYCT_DEFAULTS     (function)
;        CTM_GET_DATABLOCK (function)   CTM_LABEL         (function) 
;        REPLACE_TOKEN     (function)   CTM_BOXSIZE       (function)   
;        GET_DEFAULTFORMAT (function)   GAMAP_CMN     (include file)   
;
;        
; REQUIREMENTS:
;        References routines from both GAMAP and TOOLS packages.
;        Also assumes colortable has been loaded with "myct.pro". 
;
; NOTES:
;        (1) Some keywords are saved in local variables with 
;        slightly different names (e.g. MCONTOUR for /CONTOUR) 
;        to prevent confusion with routine names and/or keywords
;        that are picked up by the _EXTRA=e facility.
;
;        (2) Not every possible combination of keywords has been thoroghly 
;        tested. *PLEASE* report reproducible errors to mgs@io.harvard.edu!!
;
;        (3) As of 11/17/98, CTM_PLOT can only produce X-Y plots with
;        either PRESSURE or ALTITUDE along the left Y-Axis.  The right
;        Y-Axis is left disabled (but will fix that later on...) 
;
;        (4) Now define X-axis labels for longitude.  The labels are
;        defined correctly for data blocks that span the date line.
;
; EXAMPLE:
;        (0) To plot an ozone surface map (default) of a user-selected
;            file, simply call
;        CTM_PLOT
;
;        (1)
;        FileName = '~/terra/CTM4/run_code/ctm.pch.sep1'
;        CTM_PLOT, 22, 1, FileName=FileName, Lev=[1,14], $
;           Total=4, /NoErase 
;
;             ; Plots vertically-summed map for tracer 1 of ND22
;             ; (J-Values map).  Will erase screen before plotting map.
;
;        (2)
;        CTM_PLOT, 'JV-MAP-$', 1, FileName=FileName, Lev=[1,14], $
;           Total=4, /NoErase 
;
;             ; Same as above, but uses category name instead of 
;             ; diagnostic number.
; 
;
; MODIFICATION HISTORY:
;        bmy, 21 Sep 1998: VERSION 1.00
;        bmy, 22 Sep 1998: VERSION 1.01
;                          - added AVERAGE and TOTAL keywords
;        bmy, 22 Sep 1998: VERSION 1.10
;                          - Modified for use with new versions of
;                            CTM_GET_DATABLOCK, CTM_EXTRACT,
;                            CTM_LABEL, REPLACE_TOKEN, and TVMAP
;        bmy, 25 Sep 1998: VERSION 1.11
;                          - modified for TVMAP v. 2.0
;        bmy, 28 Sep 1998: VERSION 2.00
;                          - modified for TVMAP v. 2.01
;                          - renamed LONSHIFT to LSHIFT
;        bmy, 29 Sep 1998: - added ALTRANGE and PRANGE keywords
;                            (which had been previously omitted)
;        bmy, 30 Sep 1998: VERSION 2.01
;                          - added call to CTM_CONVERT_UNIT
;                          - added LABELSTRU keyword 
;        bmy, 07 Oct 1998  VERSION 2.02
;                          - now works with TVMAP 3.0
;                          - added /CONTOUR, /FCONTOUR, and 
;                            /COLORBAR keywords
;                          - removed I/O error handling (that 
;                            is already done in CTM_GET_DATABLOCK)
;        bmy, 08 Oct 1998: VERSION 2.03
;                          - now works with CTM_GET_DATABLOCK v. 1.03
;                            and CTM_EXTRACT v. 1.04
;                          - added DATA and THISDATAINFO keywords so
;                            that an external data block can be
;                            passed.
;                          - another bug fix for UNITSTR
;        bmy, 03 Nov 1998: VERSION 2.04
;                          - works with new CTM_GET_DATA, 
;                            CTM_GET_DATABLOCK and CTM_LABEL routines
;                          - Now pass the FILEINFO and DATAINFO
;                            structures via USE_FILEINFO and
;                            USE_DATAINFO keywords
;                          - removed DATA keyword   
;                          - changed %NAME% token to %TRACERNAME%
;                          - Now can pass an explicit unit string
;                            via the USTR keyword
;        mgs, 10 Nov 1998: - adapted for use with new CTM_GET_DATABLOCK
;                          - changed keyword Erase to NoErase
;                          - defaults set to produce an OX surface map
;                            from IJ-AVG-$ diagnostics 
;                          - allow for vertical cross section plots
;                            (interface to TVPLOT) : ** still needs work! **
;                          - changed CBAR to NOCBAR
;        bmy, 12 Nov 1998: - TRACER is now a keyword instead of
;                            an argument
;                          - Changed keyword CONTINENTS to
;                            NOCONTINENTS and GRID to NOGRID
;                          - added NOISOTROPIC, SAMPLE and
;                            keywords
;        bmy, 13 Nov 1998: - VERSION 3.00
;                          - ***** RENAMED to CTM_PLOT *****
;                          - updated documentation header
;                          - renamed C_LABELS to C_ANNOTATION to
;                            prevent keyword name confusion
;                          - added NOLINES, NOLABELS, C_LABELS,
;                            and OVERLAYCOLOR keywords for tvmap
;                          - now gets default colors from 
;                            DEFAULT_COLORS.PRO
;                          - Error checking for LIMIT keyword
;                            (OK for now...fix this later on...)
;        bmy, 16 Nov 1998: - Now use %DATE% instead of %YMD1% for
;                            all default plot titles
;                          - now enhanced for TVPLOT v. 2.0
;                          - now only convert units for a tracer 
;                            if the default unit is different from
;                            the desired unit!!
;        bmy, 17 Nov 1998: - added /PRESSURE keyword to plot pressure
;                            instead of altitude on the left Y-axis
;        mgs, 17 Nov 1998: - messed around quite a bit, because of 
;                            (unfortunate) changes in default_range !@#$!@
;                          - added CBFormat keyword
;        bmy, 23 Nov 1998: - eliminated %SCALE% token from UNITSTR,
;                            to be consistent with the latest
;                            upgrade to COLORBAR.PRO. 
;                          - now pass SECONDS to CTM_CONVERT_UNIT
;        bmy, 13 Jan 1999: - add support for line plots.  Also, if
;                            the DATA array is averaged down to a
;                            single point, will print the value of
;                            that point and exit.
;                          - use NEWXTITLE and NEWYTITLE as token-replaced
;                            strings for XTITLE and YTITLE
;        bmy, 15 Jan 1999: - add support for 3-D visualization plots
;                          - added unit string for contour plots
;                          - now place CTM_LABEL call after the case
;                            statement for PLOTTYPE, so that we can
;                            suppress printing of special characters
;                            in plot titles.
;        bmy, 19 Jan 1999: - improve 0-D output
;                          - fixed [XY]Titles for line plots
;                          - "unitless" is now a unit string option
;                          - now use new default color names from
;                            DEFAULT_COLORS.PRO
;        bmy, 20 Jan 1999: - Updated comments
;        mgs, 22 Jan 1999: - couple bug fixes, some code cleaning
;                          - added OverPlot keyword to allow multiple
;                            line plots
;        bmy, 19 Feb 1999: - now pass DEBUG (from GAMAP_CMN) to 
;                            CTM_GET_DATABLOCK via DEBUG keyword
;                          - Rename XIND, YIND, ZIND keywords to
;                            XMID, YMID, ZMID, in call to CTM_GET_DATABLOCK
;        bmy, 23 Feb 1999: - Add XTICKNAME, XTICKS, XTICKV in call to
;                            TVPLOT...fix for map regions smaller than 
;                            the globe
;                          - bug fix.../NOGRID was listed as GRID!!!
;                          - added keyword /NOGLABELS, which
;                            suppresses grid line labels in MAP_SET 
;                          - updated comments
;        bmy, 26 Feb 1999: - now calls MAP_LABELS to get latitude labels
;                            for X, XZ, Y, YZ plot types.
;                          - updated comments
;        bmy, 04 Mar 1999: - now pass DEBUG keyword to TVMAP
;                          - now use GRIDINFO.XEDGE, GRIDINFO.YEDGE
;                            to compute the LIMIT keyword for MAP_SET
;        mgs, 18 Mar 1999: - minor cleaning
;        mgs, 23 Mar 1999: - added ILun to keyword list to prevent retrieval
;                            of two otherwise identical records from two
;                            different files
;        bmy, 25 Mar 1999: - now line plots use MULTIPANEL
;                          - if NPANELS >=2 then place the plot title
;                            higher above the window, to allow for 
;                            carriage-returned lines
;                            for X, Y, Z, XY, XZ, YZ plots
;        mgs, 25 Mar 1999: - no unit conversion if not necessary
;                          - small fix to allow for 2D fields (e.g. EPTOMS)
;        bmy, 14 Apr 1999: - now prints unit string at lower right of
;                            XZ or YZ plots, if the colorbar is not
;                            plotted
;        bmy, 26 Apr 1999: - rename YRANGE to YYRANGE internally, so as
;                            to avoid confusion with YRANGE plot keywords   
;        mgs, 19 May 1999: - removed a few too explicit keyword settings
;                            for 1D plots and fixed OverPlot option.
;                            Now stores !X, !Y, and !P from last 1D plot
;                            in a local common block.
;        mgs, 21 May 1999: - restore !X, !Y, and !P at the end of each
;                            1-D plot to allow overplotting of data.
;        mgs, 25 May 1999: - needed to mess around with lonrange to get
;                            it right.
;        mgs & bmy, 26 May 1999: - added POLAR keyword
;        bmy, 27 May 1999: - bug fix: CBUnit keyword wasn't honored
;                          - neither was NoIsotropic
;        mgs, 27 May 1999: - changed default behaviour for filled contours:
;                            now plots no lines and colorbar. Keyword
;                            NoLines changed to C_Lines.
;        mgs, 28 May 1999: - added RESULT keyword to return data as plotted
;                          - bug fix with wrapping round data: shouldn't be
;                            done for vertical cross sections.
;        mgs, 02 Jun 1999: - small bug fix for 0D results.
;        mgs, bmy 03 Jun 1999: - removed "Unit:" from output
;        bmy, 07 Jul 1999: - added PLOTCSFAC scale factor for multipanel
;                            plots
;                          - small fixes for line plots
;        bmy, 02 Nov 1999: GAMAP VERSION 1.44
;                          - return if THISDATAINFO contains
;                            information for more than one data block
;        bmy, 24 Nov 1999: - now pass _EXTRA=e to CTM_TRACERINFO
;                            so that /SMALLCHEM will be passed
;        bmy, 13 Dec 1999: - if GRIDINFO is undefined after returning from
;                            CTM_GET_DATABLOCK, rebuild it w/ CTM_TYPE
;        bmy, 03 Feb 2000: GAMAP VERSION 1.45
;                          - NOTE: /INDEX does not work with lon range
;                            shifting anymore.  Will fix later.
;                          - also make sure LON, LAT have two elements 
;                          - added X_FORMAT, Y_FORMAT keywords for line plots
;                          - updated comments 
;        bmy, 06 Apr 2000: - bug fix: restrict X or Y axis range for line
;                            plots using the value passed from YYRANGE.
;                          - cosmetic changes, updated comments
;        bmy, 23 Jan 2001: GAMAP VERSION 1.47
;                          - now call "isopleth_map.pro" to plot a 3-D
;                            isosurface.  3-D visualization via
;                            routine "ctm_draw_cube.pro" is obsolete.
;                          - added ISOPLETH keyword as pass-thru to 
;                            ISOPLETH_MAP
;        bmy, 23 Jul 2001: GAMAP VERSION 1.48
;                          - replaced call to DEFAULT_COLORS with 
;                            call to MYCT_DEFAULTS() to specify
;                            MYCT color table information
;                          - deleted obsolete code from 1998 and 1999
;        bmy, 09 Aug 2001: - bug fix: remove reference to BLACK from
;                            the old "default_colors.pro"
;        bmy, 24 May 2002: GAMAP VERSION 1.50
;                          - Now use SI unit hPa instead of mb in axis titles
;                          - delete obsolete, commented-out code
;        bmy, 28 Sep 2002: GAMAP VERSION 1.51
;                          - now get default NCOLORS, BOTTOM, BLACK values
;                            from !MYCT system variable instead of from
;                            the MYCT_DEFAULTS function
;        bmy, 16 Apr 2004: GAMAP VERSION 2.02
;                          - Also need to convert the units of YYRANGE
;                            accordingly so that /AUTORANGE will work
;        bmy, 16 Jun 2004: - Bug fix: if we do unit conversion, do not
;                            let the converted value of YRANGE get
;                            passed back to the main program
;
;-
; Copyright (C) 1998, 1999, 2000, 2001, 2002, 2004,
; Bob Yantosca and Martin Schultz, Harvard University.
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to bmy@io.harvard.edu
; or mgs@io.harvard.edu with subject "IDL routine ctm_plot"
;-------------------------------------------------------------


pro CTM_Plot, DiagN,                                                $
              Use_FileInfo=Use_FileInfo, Use_DataInfo=Use_DataInfo, $
              ThisDataInfo=ThisDataInfo, Tracer=Tracer,             $
              ILun=ILun,                 IsoPleth=IsoPleth,         $
              Average=Average,           Total=FTotal,              $
              FileName=FileName,         Index=Index,               $
              Lat=Lat,                   Lev=Lev,                   $
              Lon=Lon,                   AltRange=AltRange,         $
              PRange=PRange,             YRange=YYRange,            $
              Unit=Unit,                 UStr=UStr,                 $
              DLon=DLon,                 LShift=LShift,             $
              NoErase=NoErase,           Pressure=Pressure,         $
              MaxData=MaxData,           MinData=MinData,           $
              NColors=NColors,           Bottom=Bottom,             $
              NoCBar=NoCBar,             CBPosition=CBPosition,     $
              CBColor=CBColor,           CBUnit=CBUnit,             $
              CBFormat=CBFormat,                                    $
              Divisions=Divisions,       Sample=Sample,             $
              Color=MColor,              MParam=MParam,             $
              Title=Title,               Position=Position,         $
              NoContinents=NoContinents, CColor=CColor,             $
              CFill=CFill,               NoIsotropic=NoIsotropic,   $
              NoGrid=NoGrid,             GColor=GColor,             $
              NoGLabels=NoGLabels,                                  $
              LabelStru=LabelStru,                                  $
              Contour=MContour,          FContour=FContour,         $
              C_Annotation=C_Annotation, C_Colors=C_Colors,         $
              C_Labels=C_Labels,         C_Lines=C_Lines,           $
              NoLabels=NoLabels,         OverLayColor=OverLayColor, $
              OverPlot=OverPlot,         Polar=Polar,               $
              X_Format=X_Format,         Y_Format=Y_Format,         $
              Result=DataStru,           _EXTRA=e,                  $
              ; 
              ;   >>>>  OBSOLETE  KEYWORDS  <<<<
              ;
              NoLines=NoLines 

   ;====================================================================    
   ; Pass external functions & Initialization
   ;====================================================================    
   FORWARD_FUNCTION ChkStru,       CTM_Get_DataBlock, CTM_Label, $
                    Replace_Token, Get_GridSpacing,   USSA_Press

   ; Local common block for axis parameters of most recent plot
   ; (needed for OverPlot option)
   COMMON LastPlot_AxisParam, XPar, YPar, PPar

   ; Include global common block (for DEBUG flag)
   @gamap_cmn  

   ; Undefine the local XRANGE and YRANGE keywords (bmy, 3/6/00)
   UnDefine, XRange
   UnDefine, YRange

   ;==================================================================== 
   ; Initialize local common block
   ;==================================================================== 
   if (N_Elements(XPar) eq 0) then begin
      XPar = !X
      YPar = !Y
      PPar = !P
   endif

   ;==================================================================== 
   ; Keyword settings 
   ;==================================================================== 
   if ( N_Elements( DiagN ) eq 0 ) then begin
      Message,'No DIAGN passed!', /Continue
      Message,'Will use IJ-AVG-$ ...',/INFO,/NONAME
      DiagN = 'IJ-AVG-$'

      if (n_elements(Lev) eq 0 AND n_elements(AltRange) eq 0 $
          AND n_elements(PRange) eq 0 AND n_elements(Lon) eq 0 $
          AND n_elements(Lat) eq 0) then Lev = 1
   endif
   
   if ( N_Elements( Tracer ) eq 0 ) then begin
      Message,'No TRACER passed!', /Continue
      Message,'Will use tracer 2 as default ...',/INFO,/NONAME
      Tracer = 2
   endif
  
   if ( N_Elements( Bottom  ) ne 1 ) then Bottom  = !MYCT.BOTTOM  
   if ( N_Elements( NColors ) ne 1 ) then NColors = !MYCT.NCOLORS 
   if ( N_Elements( MColor  ) ne 1 ) then MColor  = !MYCT.BLACK

   Pressure = Keyword_Set( Pressure )
   MContour = Keyword_Set( MContour )
   FContour = Keyword_Set( FContour )

   if (keyword_set(NoLines)) then $
        message,'You have used the obsolete keyword NOLINES.',/INFO
   C_Lines = keyword_Set(C_Lines)   ; plot contour lines in filled contours

   ; Number of plot panels per page
   NPanels = !P.MULTI[1] * !P.MULTI[2]

   ;===================================================================
   ; Call CTM_GET_DATABLOCK to read in a data block
   ;
   ; NOTE: If CTM_PLOT is being called from GAMAP.PRO, then:
   ;       - LAT and LON contain latitude and longitude EDGES
   ;       - LEV contains level numbers 
   ;       - XMID, YMID, ZMID contain one of the following:
   ;            latitude CENTERS, longitude CENTERS, level CENTERS 
   ;         The ordering corresponds to the order of the dimensions
   ;         in the data block.
   ;
   ; NOTE: The THISDATAINFO structure should only contain information
   ;       pertaining to one data block.  If the number of elements
   ;       in THISDATAINFO > 1, print an error message and return
   ;===================================================================
   if (chkstru(e,'PSURF')) then  $
        message,'PSURF specified as '+strtrim(e.psurf,2),/INFO

   Success = CTM_Get_DataBlock( Data, DiagN,                             $
                                XMid=XMid, YMid=YMid, ZMid=ZMid,         $
                                Use_FileInfo=Use_FileInfo,               $
                                Use_DataInfo=Use_DataInfo,               $
                                ThisDataInfo=ThisDataInfo,               $
                                ILun=ILun,                               $
                                Average=Average,    Total=FTotal,        $
                                Tracer=Tracer,      FileName=FileName,   $
                                GridInfo=GridInfo,  ModelInfo=ModelInfo, $
                                Index=Index,        Lev=Lev,             $
                                Lat=Lat,            Lon=Lon,             $
                                AltRange=AltRange,  PRange=PRange,       $
                                WE=WE,              SN=SN,               $
                                UP=UP,              Debug=Debug,         $
                                _EXTRA=e ) 

   if ( not Success ) then return

   ;##### Debug...necessary if GRIDINFO comes back undefined
   ;##### from CTM_GET_DATABLOCK!  (bmy, 12/13/99)
   if ( not ChkStru( GridInfo, [ 'IMX', 'JMX' ] ) ) then begin
      GridInfo = CTM_Grid( ModelInfo )
   endif

   if ( N_Elements( ThisDataInfo ) gt 1 ) then begin
      S = 'Multiple data blocks found for the same tracer' + $
          '...Check the "tracerinfo.dat" file!'
      Message, S, /Continue
      return
   endif

   ;===================================================================
   ; Store the number of dimensions of DATA in SDATA.
   ; If SDATA is > 3 then print error message and return.
   ;===================================================================
   SData = Size( Data, /N_DIMENSIONS )

   if ( SData gt 3 ) then begin
      Message, 'DATA must have <= 3 dimensions!', /Continue
      returnv
   endif

   if (n_elements(Data) eq 1) then SData = 0

   ;#### DEBUG 
   if ( DEBUG ) then begin
      print, '### CTM_PLOT : Lon  : ', Lon
      print, '### CTM_PLOT : Lat  : ', Lat
      print, '### CTM_PLOT : Lev  : ', Lev
      print, '### CTM_PLOT : WE   : ', we
      print, '### CTM_PLOT : SN   : ', sn
      print, '### CTM_PLOT : UP   : ', up
      print, '### CTM_PLOT : XMid : ', Xmid
      print, '### CTM_PLOT : YMid : ', Ymid
      print, '### CTM_PLOT : ZMid : ', Zmid
   endif

   ;===================================================================
   ; determine plot type: XY, XZ, YZ, etc.
   ; for XY plots, /CONTINENTS will be defaulted to true
   ;===================================================================
   NLon = N_Elements( WE )
   NLat = N_Elements( SN )
   NAlt = N_Elements( UP )
   PlotTypeList = [ '0', 'X', 'Y', 'XY', 'Z', 'XZ', 'YZ', 'XYZ' ]

   ; Get plot type based on the size of the data block
   PlotType = PlotTypeList[ (NLon gt 1) + 2*(NLat gt 1) + 4*(NAlt gt 1) ]

   ;### Debug
   if (DEBUG) then print,'##DEBUG: PlotType , NLon, NLat, NAlt = ', $
        PlotType,NLon,NLat,NAlt

   ;===================================================================
   ; Call CTM_TRACERINFO to get the carbon number 
   ; Call CTM_CONVERT_UNIT to do unit conversion
   ;
   ; NOTE: Only call CTM_CONVERT_UNIT if the default
   ; unit and the desired unit are different!!!
   ;===================================================================
   CTM_TracerInfo, ThisDataInfo.Tracer, $
      Name=Name, MolC=CNum, MolWt=MolWt, _EXTRA=e

   ; *** QUICK FIX: ALWAYS OVERWRITE TRACER NAME IN DATAINFO STRUCTURE
   ThisDataInfo.TracerName = Name

   if ( N_Elements( Unit ) gt 0 ) then begin
      From_Unit = ThisDataInfo.Unit

      ; print, '### converting units from ', from_unit, ' to >', unit, '<'
      if ( From_Unit ne Unit AND Unit ne '') then begin

         ; *** HERE'S A WEAKNESS: CTM_Box_Size should only be called 
         ; *** if necessary, I.E. if the unit conversion needs the box sizes !
         ; *** (perhaps we can do this in ctm_convert_units.pro altogether ?)

         ; Get the grid box areas in cm/2 for mol/cm2/s -> Tg
         AreaCm2 = CTM_BoxSize( GridInfo, /cm2,  $
                                GISS_Radius = ( ModelInfo.Family eq 'GISS' ))
         if (n_elements(WE) gt 0) then $
            if (WE[0] ge 0) then AreaCm2 = AreaCm2[ WE, * ]
         if (n_elements(SN) gt 0) then $
            if (SN[0] ge 0) then AreaCm2 = AreaCm2[ *, SN ]

         ; Convert the units!
         ; Elapsed seconds during diagnostic interval
         Seconds = ( ThisDataInfo.Tau1 - ThisDataInfo.Tau0 ) * 3600.0
         CTM_Convert_Unit, Data, From_Unit=From_Unit,      $
            To_Unit=Unit, CNum=CNum,        Result=Result, $
            MolWt=MolWt,  AreaCm2=AreaCm2,  Seconds=Seconds, $
            _EXTRA=e

         ; Also need to convert units of YYRANGE, if passed (bmy, 4/14/04)
         if ( N_Elements( YYRange ) gt 0 ) then begin

            ; Save original value into shadow variable YYYRange (bmy, 6/16/04)
            YYYRange = YYRange

            ; Convert units of YYRANGE 
            CTM_Convert_Unit, YYRange, From_Unit=From_Unit,      $
               To_Unit=Unit, CNum=CNum,        Result=Result, $
               MolWt=MolWt,  AreaCm2=AreaCm2,  Seconds=Seconds, $
               _EXTRA=e
         endif

         ; Reassign Unit and Scale numbers in THISDATAINFO
         if (Result) then ThisDataInfo.Unit = Unit
      endif
   endif

   ;===================================================================
   ; If YRANGE is specified, then use those values for the min and 
   ; max of the byte scaling.  Otherwise, use the min and max values 
   ; of the DATA array.
   ;===================================================================

   ; Now save the max and min of YYRANGE in separate 
   ; variables for use below. (bmy, 4/6/00)
   if ( N_Elements( YYRange ) gt 0 ) then begin
      MaxYY   = Max( YYRange, Min=MinYY )
      MaxData = MaxYY
      MinData = MinYY

      ; Now that we have defined MINYY and MAXYY, we need to 
      ; restore the original value of YYRANGE (bmy, 6/16/04)
      if ( N_Elements( YYYRange ) gt 0 ) then YYRange = YYYRange
   endif else begin
      MaxData = Max( Data, Min=MinData )
   endelse

   ;===================================================================
   ; Settings (titles, etc) for the different plot types
   ;===================================================================
   NoTit = ( n_elements(Title) eq 0 )
   NoXTit = ( n_elements(XTitle) eq 0 )
   NoYTit = ( n_elements(YTitle) eq 0 )

   case ( PlotType ) of

      ;=================================================================
      ; Type "0": Average or total all data down to a single point
      ;=================================================================
      '0' : begin
         if (NoTit) then Title  = '%MODEL% %TRACERNAME% %DATE%'
         if (NoXTit) then XTitle = '%LON%   %LAT%   %LEV% (%ALT%)'
         if (NoYTit) then YTitle = ''
                 
         ; suppress super/subscript characters
         No_Special = 1
      end

      ;=================================================================
      ; Type "X": Tracer vs. Longitude
      ;=================================================================
     'X' : begin

        ; Break the title string into 2 lines, if necessary
        if ( NPanels lt 2 ) then begin
           if (NoTit) then Title  =  $
              '%MODEL% %TRACERNAME% %DATE% %LAT% %LEV% (%ALT%)'
        endif else begin
           if (NoTit) then Title  =  $
              '%MODEL% %TRACERNAME% %DATE%!C!C%LAT% %LEV% (%ALT%)'       
        endelse

        if (NoXTit) then XTitle = 'Longitude'
        if (NoYTit) then YTitle = '' ; fill in YTitle below
        
        if (XMid[0] gt XMid[n_elements(XMid)-1] ) then $
           Convert_Lon,XMid,/Pacific

        ; XRANGE is defined from XMID, which is returned 
        ; from CTM_GET_DATABLOCK
        XRange = [ min( XMid, max=M ), M ]
        
        ; If YYRANGE is passed from the command line, then use 
        ; those values to define the Y-axis plot range (bmy, 4/6/00)
        if ( N_Elements( YYRange ) gt 0 ) then YRange = [ MinYY, MaxYY ]
        
        ;print,'##1: XRANGE=',XRANGE,'  YRANGE=',YRANGE
     end

     ;==================================================================
     ; Type "Y": Tracer vs. latitude
     ;==================================================================
     'Y' : begin

        ; Break the title string into 2 lines, if necessary
        if ( NPanels lt 2 ) then begin
           if (NoTit) then Title  =  $
              '%MODEL% %TRACERNAME% %DATE% %LON% %LEV% (%ALT%)'
        endif else begin
           if (NoTit) then Title  =  $
              '%MODEL% %TRACERNAME% %DATE%!C!C%LON% %LEV% (%ALT%)'
        endelse

        if (NoXTit) then XTitle = 'Latitude'
        if (NoYTit) then YTitle = '' ; Fill in YTitle below
        
        ; XRANGE is defined from XMID, which is returned 
        ; from CTM_GET_DATABLOCK
        XRange = [ min( XMid, max=M ), M ]

        ; If YYRANGE is passed from the command line, then use 
        ; those values to define the Y-axis plot range (bmy, 4/6/00)
        if ( N_Elements( YYRange ) gt 0 ) then YRange = [ MinYY, MaxYY ]

        ;print,'##2: XRANGE=',XRANGE,'  YRANGE=',YRANGE
     end

     ;==================================================================
     ; Type "Z": Altitude vs. Tracer (vertical profile)
     ;==================================================================
     'Z'  : begin

        ; Break the title string into 2 lines, if necessary
        if ( NPanels lt 2 ) then begin
           if (NoTit) then Title  = $
              '%MODEL% %TRACERNAME% %DATE% %LAT% %LON%'
        endif else begin
           if (NoTit) then Title  = $
              '%MODEL% %TRACERNAME% %DATE%!C!C%LAT% %LON%'
        endelse
        
        if (NoXTit) then XTitle = '' ; fill in XTitle below
        
        if ( Pressure ) then begin
           if (NoYTit) then YTitle = 'Pressure (hPa)' 
        endif else  $
           if (NoYTit) then YTitle = 'Altitude (km)' 

        ; YRANGE is defined from XMID, which is returned from 
        ; CTM_GET_DATABLOCK.  This should be the altitudes, since
        ; we are now plotting altitude on the Y-axis. (bmy, 4/6/00)
        YRange = [ min( XMid, max=M ), M ]
       
        ; If YYRANGE is passed from the command line, then use
        ; those values to restrict the X-axis plot range (which
        ; is tracer concentrations). (bmy, 4/6/00)
        if ( N_Elements( YYRange ) gt 0 ) then XRange = [ MinYY, MaxYY ]

        ;print,'##3: XRANGE=',XRANGE,'  YRANGE=',YRANGE
     end

     ;==================================================================
     ; Type XY: Latitude-longitude plots (TVMAP)
     ;==================================================================
     'XY' : begin

        ; Break the title string into 2 lines, if necessary
        if ( NPanels lt 2 ) then begin
           if (NoTit) then Title  = $
              '%MODEL% %TRACERNAME% %DATE% %LEV% (%ALT%)'
        endif else begin
           if (NoTit) then Title  = $
              '%MODEL% %TRACERNAME% %DATE%!C!C%LEV% (%ALT%)'
        endelse
              
        if (NoXTit) then XTitle =  ''
        if (NoYTit) then YTitle =  ''
        if (n_elements(continents) eq 0) then continents = 1
     end


     ;==================================================================
     ; Type XY: Longitude-altitude plots (TVPLOT)
     ;==================================================================
     'XZ' : begin

        ; Break the title string into 2 lines, if necessary
        if ( NPanels lt 2 ) then begin
           if (NoTit) then Title = '%MODEL% %TRACERNAME% %DATE% %LAT%'
        endif else begin
           if (NoTit) then Title = '%MODEL% %TRACERNAME% %DATE%!C!C%LAT%'
        endelse

        if (NoXTit) then XTitle = 'Longitude'

        ; Titles for PRESSURE or ALTITUDE on Y-axis
        if ( Pressure ) then begin
           if (NoYTit) then YTitle   = 'Pressure (hPa)'
        endif else begin
           if (NoYTit) then YTitle   = 'Altitude (km)'
        endelse
 
        YRange = [ min(Ymid), max(Ymid) ]
        if (n_elements(LON) eq 2) then XRange = Lon
     end
        
     ;==================================================================
     ; Type YZ: Latitude-altitude plots (TVPLOT)
     ;==================================================================
     'YZ' : begin

        ; Break the title string into 2 lines, if necessary
        if ( NPanels lt 2 ) then begin
           if (NoTit) then Title = '%MODEL% %TRACERNAME% %DATE% %LON%'
        endif else begin
           if (NoTit) then Title = '%MODEL% %TRACERNAME% %DATE%!C!C%LON%'
        endelse

        if (NoXTit) then XTitle = 'Latitude'

        ; Settings for PRESSURE or ALTITUDE on Y-axis
        if ( Pressure ) then begin
           if (NoYTit) then YTitle   = 'Pressure (hPa)'
        endif else begin
           if (NoYTit) then YTitle   = 'Altitude (km)'
        endelse


        YRange = [ min(Ymid), max(Ymid) ]
        if (n_elements(LAT) eq 2) then XRange = Lat
     end

     ;==================================================================
     ; Type XYZ: Call the data slicer (CTM_SLICER3)
     ;==================================================================
     'XYZ' : begin
        if (NoTit) then Title  = '%MODEL% %TRACERNAME% %DATE%'
        if (NoXTit) then XTitle = ''
        if (NoYTit) then YTitle = ''

        ; suppress super/subscript characters
        No_Special = 1
     end

     ;==================================================================
     ; Otherwise, invalid plot type.  Return w/ error messages.
     ;==================================================================
     else : begin
        Message, 'Invalid Plot Type!', /Continue
        return
     end

   endcase


   ;===================================================================
   ; Call CTM_LABEL to return the LABELSTRU structure
   ; Also pass altitude and pressure information
   ;===================================================================
   if ( not ChkStru(GridInfo,'LMX') ) then begin
      Prs    = 1013.25    ; *** FIXED *** 
      Alt    =    0.
   endif else if ( N_Elements( Lev ) eq 1) then begin
      Alt    = GridInfo.ZMid[ Lev[0] - 1 ]
      Prs    = GridInfo.PMid[ Lev[0] - 1 ]
   endif else begin
      MinLev = ( Min( Lev, Max=MaxLev ) > 0 )
      MaxLev = MaxLev < ( GridInfo.LMX - 1)

      Alt    = [ GridInfo.ZMid( MinLev-1 ), GridInfo.ZMid( MaxLev - 1 ) ]
      Prs    = [ GridInfo.PMid( MinLev-1 ), GridInfo.PMid( MaxLev - 1 ) ]
   endelse

   LabelStru = CTM_Label( ThisDataInfo, ModelInfo,                     $
                          Lat=Lat, Lon=Lon, Lev=Lev, Alt=Alt, Prs=Prs, $
                          Average=Average, Total=FTotal,               $
                          No_Special=No_Special, _Extra=e )

   ; Debug output
   if (DEBUG gt 1) then help,labelstru,/Stru
   if (DEBUG gt 1) then help,gridinfo,/stru

   ;===================================================================
   ; Call REPLACE_TOKEN to replace tokens in the title
   ; strings with text from the LABELSTRU structure
   ;===================================================================
   NewTitle  = Replace_Token( Title,  LabelStru )
   NewXTitle = Replace_Token( XTitle, LabelStru )
   NewYTitle = Replace_Token( YTitle, LabelStru )
 
   ;===================================================================
   ; Unit string for colorbar.  If the unit is PPBC or PPBV 
   ; then we don't need to print the scale factor as well.
   ;===================================================================
   if ( ChkStru( LabelStru, [ 'UNIT' ] ) gt 0 ) then begin
      if ( N_Elements( UStr ) eq 0 ) then begin
         case ( StrUpCase( StrTrim( ThisDataInfo.Unit, 2 ) ) ) of
            ''          : UnitStr = ' '
            'UNDEFINED' : UnitStr = '<undefined>'
            'UNITLESS'  : UnitStr = '[unitless]'
            'NONE'      : UnitStr = '[unitless]'
            else        : begin
                             UnitStr = '[%UNIT%]'     
                          end
         endcase
      endif else begin
         UnitStr = UStr
      endelse
   endif

   ;===================================================================
   ; Call REPLACE_TOKEN to replace tokens in the unit strings with 
   ; text from the LABELSTRU structure
   ;
   ; For contour plots also add the tracername to the unit string, 
   ; which will be placed below the plot window.
   ;
   ; For Line Plots, set the X-axis or Y-axis title to the tracer 
   ; name plus the unit string.
   ;===================================================================

   if ( PlotType eq 'X' OR PlotType eq 'Y' OR PlotType eq 'Z' ) $
      then UnitStr = '%TRACERNAME% ' + UnitStr

   NewUnitStr = Replace_Token( UnitStr, LabelStru )

   case ( PlotType ) of 
      'X'  : NewYTitle = NewUnitStr
      'Y'  : NewYTitle = NewUnitStr
      'Z'  : NewXTitle = NewUnitStr
      else : ;Null command
   endcase
     
   ;===================================================================
   ; Call MAP_LABELS to compute the latitude and longitude
   ; labels that will go on the X-axis
   ; 
   ; For pixel or polar plots, we have to make sure that we set 
   ; xxxRange to the grid box edges - otherwise the "pixels" are shifted 
   ; by up to 1/2 box.
   ;
   ; NOTE: Make sure LON and LAT have two elements. (bmy, 2/3/00)
   ;===================================================================
   if ( N_Elements( Lon ) eq 1 ) then Lon = [ Lon[0], Lon[0] ]
   if ( N_Elements( Lat ) eq 1 ) then Lat = [ Lat[0], Lat[0] ]
   
   LonRange = Lon
   LatRange = Lat
   Convert_Lon, LonRange, /Atlantic

; print,'$$$ LON = ',lon
; print,'### LonRange, LatRange = ',LonRange,LatRange,format='(A,4F8.1)'

   if (MContour + FContour eq 0 OR keyword_set(Polar) ) then begin

      ; get coordinates for lower left boundary
      ctm_index,gridinfo,ii,jj,center=[ Lat[0], LonRange[0] ], $
         /Non_Interactive
      LonRange[0] = GridInfo.XEdge[II-1]
      LatRange[0] = GridInfo.YEdge[JJ-1]

      ctm_index,gridinfo,ii,jj,center=[ Lat[1], LonRange[1] ], $
         /Non_Interactive
      LonRange[1] = GridInfo.XEdge[II]
      LatRange[1] = GridInfo.YEdge[JJ]

; print,'### LonRange, LatRange = ',LonRange,LatRange,format='(A,4F8.1)'

      ; take care of special cases:
      ; - lonrange spans dateline 
      if (LonRange[0] gt LonRange[1]) then $
         Convert_Lon,LonRange,/Pacific

      ; - lonrange = -180 .. 180
      if (lon[0] eq -180. AND lon[1] eq 180) then $
         LonRange[1] = LonRange[1]+360.-GridInfo.DI

      ; - lonrange = 0..360
      if (lon[0] gt 0. AND lon[1] eq 0.) then begin
         LonRange[0] = LonRange[0] - GridInfo.DI
         LonRange[1] = 360. - 0.5*GridInfo.DI

         ; need to shift data in this case!!
         s = size(Data,/Dimensions)
         if (n_elements(s) eq 2 AND plottype eq 'XY') then begin
            data = ( [ data[s[0]-1,*], data ] )[0:s[0]-1,*]  
         endif else  $
            if (n_elements(s) eq 1) then begin
            data = ( [ data[s[0]-1], data ] ) ;  [0:s[0]-1]
            XMid[s[0]-1] = 360.
            XMid = [ 0., XMid ]
         endif
      endif

; print,'### LonRange, LatRange = ',LonRange,LatRange,format='(A,4F8.1)'
   endif

   ; ------------------------------------------------------------ 
   ; Need to duplicate first data column for global contour plots
   ; ------------------------------------------------------------ 
   if ( MContour OR FContour ) then begin
; print,'### LonRange = ',LonRange,lon
      if ( LonRange[1]-LonRange[0] ge 360.-GridInfo.DI $
        AND plottype eq 'XY' ) then begin
; print,'### duplicating first column for global contour plot ...'
         XMid = [ XMid, XMid[0]+360. ]
         Data = [ Data, Data[0,*] ]
      endif
   endif

                  
   Map_Labels, LatLabel, LonLabel,              $
      LatRange=LatRange,     LonRange=LonRange, $
      Lats=Lats,             Lons=Lons,         $
      DLat=DLat,             DLon=DLon,         $
      _EXTRA=e
	 
   ;===================================================================
   ; Data block is zero-dimensional
   ;
   ; SData = 0: We are printing a single point, or have averaged 
   ; (or totaled) a larger data cube down to a single point.  
   ; Print value and exit (bmy, 1/13/99)
   ;===================================================================
; stop
   if ( SData eq 0 ) then begin
      LineStr = $
         '---------------------------------------------------------------'
      DataStr = 'Value of Data : ' + StrTrim( String( Data ), 2 )
      
      Print, ' ', LineStr
      Print, ' ', NewTitle
      Print, ' ', NewXTitle
      Print, ' ', DataStr
      Print, ' ', LineStr
      return
   endif

   ;===================================================================
   ; Data block is 1-dimensional
   ;
   ; SDATA = 1: Produce a line plot and exit
   ; Now use MULTIPANEL to get the right plot position
   ;
   ; NOTE: It is important to set position here and not at the top
   ;       of the program, since position is also passed to TVMAP
   ;       and TVPLOT.  Thus, we do not let settings for line plots
   ;       affect settings for contour or pixel plots.
   ;===================================================================
   if ( SData eq 1 ) then begin
      
      ; For MULTIPANEL
      if (!D.NAME eq 'PS') then PSOffset = 0.02 else PSOffset = 0.
      if ( N_Elements( Position  ) eq 0 ) then begin
         if ( MContour or FContour ) then $
            Position = [ 0.05, 0.03, 1.0, 1.0 ]   $     
         else $
            Position = [ 0.05, 0.15+psoffset, 1.0, 1.0 ] ; room for colorbar
      endif else print,'Position passed: ',Position

      ;================================================================
      ; Get actual position of current plot panel
      ; (we may want to add margin parameters at some point??)
      ; Use extra-large left margin, since the Y-ticks may be in
      ; scientific notation (bmy, 3/25/99)
      ;================================================================

      ; first try to extract PlotPosition from !X and !Y.Window
      ; this is just a dummy to have things defined if OverPlot is set.
      PlotPosition = [ !X.Window[0], !Y.Window[0],  $
                       !X.Window[1], !Y.Window[1] ]

      ; then get a better position from multipanel unless we OverPlot
      if (not keyword_set(OverPlot)) then $
         MultiPanel, Position=PlotPosition, Margin=[0.10,0.02,0.04,0.07] 

      NPanels = !P.MULTI[1] * !P.MULTI[2]
                           
      ;==============================================================
      ; Calculate true window position from position and MPosition
      ; Here we don't need to add a colorbar ...
      ;==============================================================
      ; get width of plot window
      wx = ( PlotPosition[2] - PlotPosition[0] ) > 0.1
      wy = ( PlotPosition[3] - PlotPosition[1] ) > 0.1

      Position[0] = PlotPosition[0] + wx * Position[0]
      Position[1] = PlotPosition[1] + wy * Position[1]
      Position[2] = PlotPosition[0] + wx * Position[2]
      Position[3] = PlotPosition[1] + wy * Position[3]

      ;==============================================================
      ; Scale factor for charsize
      ;=============================================================
      OldXcs  = !X.CHARSIZE
      OldYcs  = !Y.CHARSIZE
      CsFac   = 1.0
      PlotCsFac = 1.0
      if ( Npanels gt 4 ) then PlotCsFac = 1.0 / 0.62

      if ( NPanels gt 1 ) then CsFac = 0.9
      if ( NPanels gt 4 ) then CsFac = 0.75
      if ( NPanels gt 9 ) then CsFac = 0.6
      
      if ( !D.NAME ne 'PS' ) then CsFac = CsFac * 1.2
      
      ; Set X and Y charsize appropriate to the plot window
      !X.CHARSIZE = CsFac*PlotCsFac
      !Y.CHARSIZE = CsFac*PlotCsFac

      if ( PlotType eq 'Z' ) then begin
        
         ;==========================================================
         ; Set tick parameters for the X-axis (bmy, 4/14/99)
         ;==========================================================
         ;XTickV = ( findgen(7) / 6.0 ) * (MaxData-MinData) + MinData
         ;XTicks = N_Elements( XTickV ) - 1
         ;X_Format = get_defaultformat( XTickV[ 0 ],XTickV[ XTicks ], $
         ;                              DefaultLen=['14.2','9.2'], Log=0)
         ;XTickName = StrTrim( String( XTickV, Format=X_Format ), 2 )
         ;XMinor    = 4 
         
         ; Get default format for X-axis if not already specified
         if ( N_Elements( X_Format ) eq 0 ) then begin
            X_Format = get_defaultformat( MinData,MaxData,threshold=3, $
                                          DefaultLen=['14.2','9.2'], Log=0)
         endif

         if ( Pressure ) then begin

            ;==========================================================
            ; Vertical profile with pressure on Y-axis
            ; Keep altitude gridding, but relabel w/ pressure values
            ;==========================================================       
            NewXmid = USSA_Press( XMid )
            
            ; Get default format for Y-axis if not already specified
            if ( N_Elements( Y_Format ) eq 0 ) then begin
               Y_Format = get_defaultformat( NewXMid[N_Elements(NewXMid)-1], $
                                             NewXMid[ 0 ],threshold=3, $
                                             DefaultLen=['14.2','9.2'], Log=0)
            endif

            YTickName = StrTrim( String( NewXMid, Format=Y_Format ), 2 )
            YTicks    = N_Elements( YTickName ) - 1

            if ( not keyword_set( OverPlot ) ) then begin
               Plot, Data, XMid,    $
                  Color=MColor,         XTitle=NewXTitle,         $
                  YTitle=NewYTitle,     YTickName=YTickName,      $
                  YTicks=YTicks,        YMinor=3,                 $
                  Position=Position,    CharSize=PlotCsFac*CsFac, $
                  XTickFormat=X_Format, XMinor=XMinor,            $
                  ; Added XRANGE and YRANGE keywords (bmy, 4/6/00)
                  XRange=XRange,        YRange=YRange,            $ 
                  _EXTRA=e

               ; save important parameters
               XPar = !X
               YPar = !Y
               PPar = !P
            endif else begin
               ; restore axis parameters from last XY Plot
               !X = XPar
               !Y = YPar
               !P = PPar
            endelse

            OPlot, Data, XMid, Color=MColor, _EXTRA=e

            ; Store plotted data in structure to return it
            DataStru = { X:-1., Y:XMid, Data:Data }

         endif else begin
               
            ;==========================================================
            ; Vertical profile with altitude on Y-axis
            ;==========================================================
            if ( not Keyword_Set( OverPlot ) ) then begin
               Plot, Data, XMid,                                  $
                  Color=MColor,             XTitle=NewXTitle,     $
                  YTitle=NewYTitle,         Position=Position,    $
                  CharSize=PlotCsFac*CsFac, XTickFormat=X_Format, $
                  XMinor=XMinor,                                  $
                  ; Added XRANGE and YRANGE keywords (bmy, 4/6/00)
                  XRange=XRange,            YRange=YRange,        $
                  _EXTRA=e

               ; save important parameters
               XPar = !X
               YPar = !Y
               PPar = !P
            endif else begin
               ; restore axis parameters from last XY Plot
               !X = XPar
               !Y = YPar
               !P = PPar
            endelse

            OPlot, Data, XMid, Color=MColor, _EXTRA=e

            ; Store plotted data in structure to return it
            DataStru = { X:-1., Y:XMid, Data:Data }

; #### DEBUG
; print,'!X(CRng,Reg,Window,Style) :',!X.CRange,!X.Region,!X.Window,!X.Style 
; print,'!Y(CRng,Reg,Window,Style) :',!Y.CRange,!Y.Region,!Y.Window,!Y.Style 
; print,'PlotPosition=',PlotPosition


         endelse
         
      endif else begin
         
         ; Select X-axis labels and number of ticks
         if ( PlotType eq 'X' ) then begin
            XTickName = LonLabel 
            XTickV    = Lons
            Delta     = DLon
         endif else begin
            XTickName = LatLabel 
            XTickV    = Lats
            Delta     = DLat
         endelse

         XTicks = N_Elements( XTickV ) - 1

         ; Choose appropriate minor X-tick interval (bmy, 3/25/99)
         case ( Delta ) of
            5    : XMinor = 5
            10   : XMinor = 2
            else : XMinor = 3
         endcase

         ; For the Y-Axis ticks
         ;YTickV = ( findgen(10) / 10.0 ) * (MaxData-MinData) + MinData
         ;YTicks = N_Elements( YTickV ) - 1
         ;Y_Format = get_defaultformat( YTickV[0],YTickV[YTicks], $
         ;                              DefaultLen=['14.2','9.2'], Log=0)
         ;YTickName = StrTrim( String( YTickV, Format=Y_Format ), 2 )
         YMinor    = 2
         
         if ( N_Elements( Y_Format ) eq 0 ) then begin
            Y_Format = get_defaultformat( MinData,MaxData,threshold=3,  $
                                          DefaultLen=['14.2','9.2'], Log=0)
         endif

         ;=============================================================
         ; Horizontal profile with tracer on the Y-axis and 
         ; either latitude or longitude on the X-axis
         ;=============================================================
         if ( not keyword_set( OverPlot ) ) then begin
            Plot, Xmid, Data,                                   $
               Color=MColor,             XTitle=NewXTitle,      $
               YTitle=NewYTitle,         Position=Position,     $
               CharSize=PlotCsFac*CsFac, XTickName=XTickName,   $
               XTicks=XTicks,            XTickV=XTickV,         $
               XMinor=XMinor,            YTickFormat=Y_Format,  $
               YMinor=YMinor,                                   $
               ; Added XRANGE and YRANGE keywords (bmy, 4/6/00)
               XRange=XRange,            YRange=YRange,         $
               _EXTRA=e

            ; save important parameters
            XPar = !X
            YPar = !Y
            PPar = !P
         endif else begin
            ; restore axis parameters from last XY Plot
            !X = XPar
            !Y = YPar
            !P = PPar
         endelse

         OPlot, XMid, Data, Color=MColor, _EXTRA=e

         ; Store plotted data in structure to return it
         DataStru = { X:XMid, Y:-1., Data:Data }

      endelse

      xpmid = (!x.window[1]+!x.window[0])/2.

      ; Place title a little higher for multipanel plots
      if ( NPanels lt 2 )                 $
         then yptop = !y.window[1]+0.025  $
         else yptop = !y.window[1]+0.040

      ; place title yet a little higher if it has two lines
      if ( StrPos( NewTitle,'!C' ) ge 0) then yptop = yptop + 0.02


      ; print title (but only if OverPlot keyword is not set)
      if (not keyword_set(OverPlot)) then $
         xyouts,xpmid,yptop,NewTitle,color=MColor,/norm,align=0.5,  $
            charsize=1.2*csfac


      ; Advance to next frame w/o erasing screen
      ; but only if we haven't done an OverPlot
      if (not keyword_set(OverPlot)) then $
         MultiPanel, /Advance, /NoErase


      ; restore !X, !Y, and !P vectors to allow overplotting of data
      !X = XPar
      !Y = YPar
      !P = PPar

      ; restore old charsize for !x and !y
      !X.CHARSIZE = OldXcs
      !Y.CHARSIZE = OldYcs

      return
   endif

   ;===================================================================
   ; Data block is 2-dimensional
   ;ex
   ; SDATA = 2: Plot 2-D map either as a pixel plot or as a 
   ; contour plot, and then exit.
   ;===================================================================
   if ( SData eq 2 ) then begin

      ;================================================================
      ; Define some plot variables
      ;================================================================
      Erase      = 1 - Keyword_Set( NoErase      )
      CBar       = 1 - Keyword_Set( NoCBar       )
      Continents = 1 - Keyword_Set( NoContinents )
      Grid       = 1 - Keyword_Set( NoGrid       )
      Isotropic  = 1 - Keyword_Set( NoIsotropic  )

      ;================================================================
      ; Make sure that the values specified for the LIMIT keyword
      ; for MAP_SET do not exceed the latitude and longitude 
      ; extents specified in the GRIDINFO structure.
      ;
      ; if CTM_PLOT is called from GAMAP, then LON and LAT are grid box 
      ; centers - edges were computed above.
      ;================================================================
      if ( PlotType eq 'XY' ) then begin
         Limit = [ LatRange[0], LonRange[0], LatRange[1], LonRange[1] ]
         LShift = 0.
         if (LonRange[1] lt LonRange[0]) then begin
            Limit[3] = Limit[3] + 360.
            LShift = (Limit[3]+Limit[1])/2.
         endif
         DLon = GridInfo.DI
      endif
      
      if ( MContour ) then Cbar = 0
      if ( FContour ) then begin
          ; shouldn't be necessary to do anything (?)
          ; automatic default would be /cbar and no lines
          ; /C_Lines will still plot colorbar unless you set /nocbar
      endif

      if ( N_Elements( Divisions ) eq 0 ) then Divisions=4

      if (N_Elements(CBUnit) eq 0) then CBUnit = NewUnitStr

      print,'Min and Max of selected data : ',min(data),max(data)

      ;================================================================
      ; Call TVMAP to plot the color-pixel map, 
      ; line-contour map, or filled contour map...
      ;
      ;**** Now pass DEBUG flag to TVMAP (bmy, 3/4/99)
      ;================================================================
      if ( PlotType eq 'XY' ) then begin

         TVMap, Data, XMid, YMid,                                 $
            DLon=DLon,                                            $
            LShift=LShift,      $ ;    Erase=Erase,               $
            MaxData=MaxData,           MinData=MinData,           $
            NColors=NColors,           Bottom=Bottom,             $
            CBar=CBar,                 CBPosition=CBPosition,     $
            CBColor=CBColor,           CBUnit=CBUnit,             $ 
            CBFormat=CBFormat,                                    $
            Divisions=Divisions,       Log=Log,                   $
            Sample=Sample,             Isotropic=Isotropic,       $
            Limit=Limit,               Color=MColor,              $
            MParam=MParam,             Title=NewTitle,            $
            Position=Position,                                    $
            Continents=Continents,     CColor=CColor,             $
            CFill=CFill,                                          $
            Grid=Grid,                 GColor=GColor,             $ 
            NoGLabels=NoGLabels,                                  $
            Contour=MContour,          FContour=FContour,         $
            C_Levels=C_Levels,         C_Colors=C_Colors,         $
            C_Annotation=C_Annotation, C_Format=C_Format,         $
            C_Labels=C_Labels,         C_Lines=C_Lines,           $
            NoLabels=NoLabels,         OverLayColor=OverLayColor, $
            Debug=Debug,               Polar=Polar,               $
            _EXTRA=e
         
         ; Store plotted data in structure to return it
         DataStru = { X:XMid, Y:YMid, Data:Data }

      endif   $

      ;================================================================
      ; ... or call TVPLOT to plot the color-pixel plot, 
      ; line contour plot, or filled-contour plot
      ;================================================================
      else begin

       ; Get levels for y ticks if PRESSURE keyword set
         if ( Pressure ) then begin
            YTickV      = Ymid 
            YTicks      = N_Elements( YTickV ) - 1
            YTickName   = StrTrim( String( GridInfo.PMid[UP], $
                                           Format='(i4)' ), 2 )
            ;YA_TickName  = StrTrim( String( GridInfo.ZMid[UP], $
            ;                               Format='(i4)' ), 2 )

            ; Blank out a couple of elements of YTICKNAME, for clarity
            if ( N_Elements( YTickName ) gt 10 AND Min( UP ) lt 3 ) $
               then YTickName[1:2] = ' '
            
            ;if ( N_Elements( YA_TickName ) gt 10 AND Min( UP ) lt 3 ) $
            ;   then YA_TickName[1:2] = ' '
         endif
          
         XStyle = 1
         YStyle = 1
       
         ;=============================================================
         ; For X or XZ plots, set XTICKV, XTICKNAME, etc 
         ; to the quantities for longitude
         ;=============================================================
         if ( StrPos( PlotType, 'X' ) ge 0 ) then begin

            ; Convert to 0..360 degrees for plotting purposes
            if ( XRange[0] gt XRange[1] ) then begin
               Convert_Lon, XMid,   /Pacific
               Convert_Lon, XRange, /Pacific
            endif

            XTickV    = Lons
            XTickName = LonLabel 
            XTicks    = N_Elements( XTickV ) - 1

            ; DLon is always 5, 10, 15, or 30, so choose an
            ; appropriate minor tick interval (bmy, 2/26/99)
            case ( DLon ) of
               5    : XMinor = 5
               10   : XMinor = 2
               else : XMinor = 3
            endcase

         ;=============================================================
         ; For Y or YZ plots, set XTICKV, XTICKNAME, etc
         ; to the quantities for latitude
         ;=============================================================
         endif else if ( StrPos( PlotType, 'Y' ) ge 0 ) then begin

            ; Number of ticks
            XTickName = LatLabel 
            XTickV    = Lats
            XTicks    = N_Elements( XTickV ) - 1

            ; DLon is always 5, 10, 15, or 30, so choose an
            ; appropriate minor tick interval (bmy, 2/26/99)
            case ( DLat ) of
               5    : XMinor = 5
               10   : XMinor = 2
               else : XMinor = 3
            endcase

         endif

         ;### Debug output (bmy, 2/26/99)
         if ( Debug ) then begin
            print, '### CTM_PLOT -- before TVPLOT!' 
            print, '### XTickV    : ', XTickV
            print, '### XTickName : ', XTickName
            print, '### XTicks    : ', XTicks
            print, '### XRange    : ', XRange
            print, '### XMid      : ', XMid
            print, '### YMid      : ', YMid
         endif

         ;=============================================================
         ; Call TVPLOT with the proper keyword settings!!!
         ;=============================================================
         TVPlot, Data, XMid, YMid,                                $
            MaxData=MaxData,           MinData=MinData,           $
            NColors=NColors,           Bottom=Bottom,             $
            CBar=CBar,                 CBPosition=CBPosition,     $
            CBColor=CBColor,           CBUnit=CBUnit,             $ 
            CBFormat=CBFormat,                                    $
            Divisions=Divisions,       Log=Log,                   $
            Sample=Sample,             Color=MColor,              $
            Title=NewTitle,            Position=Position,         $
            XRange=XRange,             YRange=YRange,             $
            XTitle=NewXTitle,          YTitle=NewYTitle,          $ 
            XStyle=XStyle,             YStyle=YStyle,             $
            Contour=MContour,          FContour=FContour,         $
            C_Levels=C_Levels,         C_Colors=C_Colors,         $
            C_Annotation=C_Annotation, C_Format=C_Format,         $
            C_Labels=C_Labels,         C_Lines=C_Lines,           $
            NoLabels=NoLabels,         OverLayColor=OverLayColor, $
            YTickV=YTickV,             YTicks=YTicks,             $
            YTickName=YTickName,       YA_Title=YA_Title,         $
            YA_TickName=YA_TickName,                              $
            ; fix for longitudes spanning the date line (bmy, 2/23/99)
            XTickName=XTickName,       XTicks=XTicks,             $
            XTickV=XTickV,             XMinor=XMinor,             $
            _EXTRA=e

         ; Store plotted data in structure to return it
         DataStru = { X:XMid, Y:YMid, Data:Data }

      endelse 

      return
   endif

   ;===================================================================
   ; Data block is 3-dimensional
   ;
   ; SDATA = 3: Plot a 3-D isopleth map and then exit
   ;===================================================================
   if ( SData eq 3 ) then begin

      ; Handle plots that wrap around the date line by defining P0Lat=0, 
      ; P0Lon=180, Rot=0, and then shifting XMID into the range 0..360 deg
      if ( XMid[0] gt XMid[ N_Elements( XMid ) - 1L ] ) then begin
         TmpMParam = [0, 180, 0]
         TmpXMid   = XMid
         Convert_Lon, TmpXMid, /Pacific
      endif else begin
         TmpMParam = [0, 0, 0]
         TmpXMid   = XMid
      endelse

      ; Format string for title -- use CBFORMAT if it's defined
      if ( N_Elements( CBFormat ) eq 0 ) $
         then NewFormat = '(f14.3)'     $
         else NewFormat = CBFormat

      ; Plot the 3-D isopleth over the world map
      Isopleth_Map, Data, TmpXMid, YMid, ZMid,                 $  
         MParam=TmpMParam, IsoPleth=IsoPleth, Title1=NewTitle, $
         UStr=NewUnitStr,  XCharSize=1.2,     YCharSize=1.2,   $
         ZCharSize=1.2,    Format=NewFormat, _EXTRA=e
   
      ; Store plotted data in structure to return it
      DataStru = { X:XMid, Y:YMid, Z:ZMid, Data:Data }
      return
   endif

   ;===================================================================
   ; If we have reached here, then this is an invalid plot type.  
   ; Print error message and return.
   ;===================================================================
   Message, 'Data block cannot have more than 3 dimensions.', /Continue

   return
 
end

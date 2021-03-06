FUNCTION SIG2PRESS, FILE,GAS,ILMM=ILMM,IJMM=IJMM,IKMM=IKMM,NCON=NCON,TIME=TIME,POUT=POUT, $
                   OHAVG=OHAVG, OUTFILE=OUTFILE

;+
; NAME:
;   SIG2PRESS
;
; PURPOSE :
;   INTERPOLATE GAS CONCENTRATION FROM SIGMA TO PRESSURE COORDINATE
;
;IF N_ELEMENTS(ILMM) EQ 0 THEN ILMM = 72
;IF N_ELEMENTS(IJMM) EQ 0 THEN IJMM = 46
;IF N_ELEMENTS(IKMM) EQ 0 THEN IKMM = 20
;IF N_ELEMENTS(NCON) EQ 0 THEN NCON = 52
;IF N_ELEMENTS(TIME) EQ 0 THEN TIME = 122
;IF N_ELEMENTS(POUT) EQ 0 THEN POUT = [100.,150.,200.,300.,500.,700.,800.,900.,1000.]
;-

IF N_ELEMENTS(ILMM) EQ 0 THEN ILMM = 72
IF N_ELEMENTS(IJMM) EQ 0 THEN IJMM = 46
IF N_ELEMENTS(IKMM) EQ 0 THEN IKMM = 20
IF N_ELEMENTS(NCON) EQ 0 THEN NCON = 52
IF N_ELEMENTS(TIME) EQ 0 THEN TIME = 122
IF N_ELEMENTS(POUT) EQ 0 THEN POUT = [100.,150.,200.,300.,500.,700.,800.,900.,1000.]

IF N_ELEMENTS(FILE) EQ 0 THEN RETURN, 0
 WR = 0
IF N_ELEMENTS(OUTFILE) NE 0 THEN WR = 1

GAS  = STRUPCASE(GAS)
NZ   = N_ELEMENTS(POUT)
NC   = N_ELEMENTS(GAS)

FOR I = 0 , NC-1 DO BEGIN
 IF (GAS(I) EQ 'OH') THEN BEGIN
  NC  = NC-1
  OH  = FLTARR(ILMM,IJMM,9) & OHAVG = FLTARR(IJMM,9)
  POH = [100.,150.,200.,300.,500.,700.,800.,900.,1000.]
  POH = ALOG(POH)
  GAS = SHIFT(GAS,-(I+1))
 END
END

PRESS = FLTARR(ILMM,IJMM,IKMM) & TEMP = PRESS & HEADER = FLTARR(2)

CONC = FLTARR(ILMM,IJMM,IKMM,NCON) & AIRD = FLTARR(ILMM,IJMM,IKMM)
DATA = FLTARR(IKMM) & PIN = DATA
CONCOUT = FLTARR(ILMM,IJMM,NZ,NC) & CONCAVG = CONCOUT

;OPENR,ILUN,FILE,/F77,/SWAP_ENDIAN,/GET_LUN
 OPENR,ILUN,FILE,/XDR,/GET_LUN
IF (WR EQ 1) THEN OPENW, JLUN, OUTFILE, /GET_LUN

POUT = ALOG(POUT)
ISPEC = SPEC(GAS,ncon=ncon)

FOR I = 0 , TIME-1 DO BEGIN

 READU, ILUN, HEADER, PRESS
 READU, ILUN, HEADER, TEMP
 READU, ILUN, HEADER, AIRD
 READU, ILUN, HEADER, CONC
 PRINT, HEADER

; calculate other gases than oh
 FOR IC = 0 , NC-1   DO BEGIN
  NSPEC = ISPEC(IC)
 FOR IY = 0 , IJMM-1 DO BEGIN
 FOR IX = 0 , ILMM-1 DO BEGIN
  DATA(*) = CONC(IX,IY,*,NSPEC) / AIRD(IX,IY,*)
  PIN(*)  = ALOG(PRESS(IX,IY,*))
;  CONCOUT(IX,IY,*,IC) = INTERPOL3D(DATA, PIN, POUT) ; confer undefined value for out of interval
  CONCOUT(IX,IY,*,IC) = INTERPOL2(DATA, PIN, POUT)  ; confer boundary value for out of interval
 END
 END
 END

 IF (WR EQ 1) THEN WRITEU, JLUN, CONCOUT
 
 CONCAVG = CONCAVG + CONCOUT

; CALCULATE OH VERTICAL-MERIDIONAL CROSS SECTION

 IF(N_ELEMENTS(GAS) EQ (NC+1)) THEN BEGIN
  NSPEC = ISPEC(NC)
 FOR IY = 0 , IJMM-1 DO BEGIN
 FOR IX = 0 , ILMM-1 DO BEGIN
  DATA(*) = CONC(IX,IY,*,NSPEC)
  PIN(*)  = ALOG(PRESS(IX,IY,*))
  OH(IX,IY,*) = INTERPOL2(DATA, PIN, POH)
 END
 END
  OHAVG = OHAVG + TOTAL(OH,1)/ILMM
  IF (WR EQ 1) THEN WRITEU, JLUN, OH
 END
 
END

 CONCAVG = CONCAVG / FLOAT(TIME)

 IF(N_ELEMENTS(GAS) EQ (NC+1)) THEN BEGIN
 OHAVG   = OHAVG / FLOAT(TIME)
 OHAVG   = REVERSE(OHAVG,2)
 END

 FREE_LUN,ILUN
 IF (WR EQ 1) THEN FREE_LUN,JLUN

 RETURN, CONCAVG

 END 

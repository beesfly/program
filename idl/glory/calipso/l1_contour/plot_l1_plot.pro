

; purpose of this program : plot the CALIPSO Lidar Level 1 data

@./read_hdf_l1.pro
@./sub/color_contour.pro
@./read_hdf_l2_aerprf.pro


  filedir = '/mnt/sdb/data/CALIPSO/2009/CALIPSO/data/CAL_LID_L2_05kmAPro-Prov-V3-01/'
  filename1 = 'CAL_LID_L2_05kmAPro-Prov-V3-01.2009-05-07T19-28-22ZD.hdf'
  fileres = '/mnt/sdb/data/CALIPSO/2009/CALIPSO/data/result/CAL_LID_L2_05kmAPro-Prov-V3-01/'

;  read_hdf_l1, filedir, filename1, num, lat, lon, alt, tbks, ttmp, pratio
  read_hdf_l2_aerprf,filedir,filename1,lat, lon, alt, aod 
;  PRINT, 'LATITUDE : ', lat
;  PRINT, 'LONGITUDE : ', lon
;  PRINT, 'Spacecraft Altitude : ', alt
;  PRINT, 'Total_Attenuated_Backscatter_532 : ', tbks
  np = 1
  nl = 4224
  minvalue = 0.0
  maxvalue = 2.1
  n_levels = 12

; color bar coordinate
  xa = 0.125      &  ya = 0.9
  dx = 0.05       &  dy = 0.00
  ddx = 0.0       &  ddy = 0.03
  dddx = 0.05     &  dddy = -0.047
  dirinx = 0      &  extrachar = 'T'

; label format
  FORMAT = '(f6.3)'

; title
  title = STRMID(filename1, 0, 52)

; region

  region = [-1.0, 25.0, 30.0, 75.0]
  
  ;lat = CONGRID(lat, np, nl)
  ;lon = CONGRID(lon, np, nl)

  alat = FLTARR(np,nl)
  aalt = FLTARR(np,nl)
  aaod = FLTARR(np,nl)
  FOR i = 0L, np-1 DO BEGIN
   FOR j = 0L, nl-1 DO BEGIN
    alat(i,j) = lat(0,j)
    aalt(i,j) = alt(i)
    aaod(i,j) = aod(0,j)
   ENDFOR
  ENDFOR


; plot the profile
  SET_PLOT, 'ps'
  DEVICE, filename =fileres + '/' + title + '_plot.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8
  PLOT, alat, aaod, color = 1, $
        title = 'Aerosol Optical Depth (532nm)', $
        xrange = [10, 45], xticks = 7, xtitle = 'Latitude (deg)', $
        yrange = [0, 4], ytitle = 'Aerosol Optical Depth (532nm)'

  DEVICE, /close 
  
END

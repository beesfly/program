pro mapplot,fd,lon,lat,level=level,POS=pos,VERTICAL=vertical,NOERASE=noerase,twait=twait,$
    Title=title,xlon=xlon,ylat=ylat,Global=global,Shade=shade,Cline=cline,Grid=grid

if n_elements(POS) eq 0 then pos = [0.15,0.2,0.85,0.85]
if n_elements(twait) eq 0 then twait = 0.1
if n_elements(title) eq 0 then title=''
if n_elements(xlon) eq 0 then xlon= [-180.,180.]
if n_elements(ylat) eq 0 then ylat= [-90.,90.]


if n_elements(level) eq 0 then begin
 nl = 11
 dim = size(fd, /dimension)
 inc = (max(fd)-min(fd))/float(nl-1)
 level = fltarr(nl)
 for i = 0, nl-1 do begin
  level[i] = min(fd)+float(i)*inc
 end
endif else begin
 nl = n_elements(level)
end

if n_elements(lon) eq 0 then begin
 dim = size(fd,/dimensions)
 dx  = 360./dim(0)
 dy  = 180./(dim(1)-1)
 lon = -180.+ dx*findgen(dim(0))
 lat = -90.+ dy*findgen(dim(1))
endif

if KEYWORD_SET(shade) then begin
 ;loadct, 0
 ;loadct, 4, ncolors=nl+1, bottom=0
 ;device, decomposed=0
 loadct_rjp, ncolors=nl+1
 ctable = indgen(nl)+1
endif

!p.position = pos

if KEYWORD_SET(global) then begin
 lonst = [lon, lon(0)+360.]
 fdst = [fd,fd(0,*)]
 map_set,/cylindrical,0.,0.,/continent,title=Title, $
        charsize=1.7, /noerase
 if keyword_set(shade) then $
  contour,fdst,lonst,lat,/cell_fill,c_colors=ctable,levels=level, $
  xstyle=1,ystyle=1,background=!p.color,color=!p.background, $
  /overplot,/normal
 if keyword_set(cline) then $
  contour,fdst,lonst,lat,levels=level,xstyle=1,ystyle=1,/overplot,/normal, $
  /follow,c_thick=1.5
 
endif else begin
 nx = where( lon ge xlon(0) and lon le xlon(1) )
 ny = where( lat ge ylat(0) and lat le ylat(1) )
 i1 = min(nx) & i2 = max(nx)
 j1 = min(ny) & j2 = max(ny)
 limit = [ylat[0],xlon[0],ylat[1],xlon[1]]
 map_set,/cylindrical,0.,0.,/continent,title=Title, $
        Limit=limit,charsize=1.7,/noerase
 if keyword_set(shade) then $
  contour,fd(i1:i2,j1:j2),lon(i1:i2),lat(j1:j2),/cell_fill, $
  c_colors=ctable,levels=level,xstyle=1,ystyle=1, $
  background=!p.color,color=!p.background,/overplot,/normal
 if keyword_set(cline) then $
  contour,fd(i1:i2,j1:j2),lon(i1:i2),lat(j1:j2),levels=level,xstyle=1,ystyle=1,$
  /overplot,/normal,/follow,c_thick=1.5

endelse
 
 if keyword_set(grid) then map_grid, /label, latlab=xlon[0],latalign=0.0,lonlab=ylat[0],lonalign=0.5
 map_continents, /continent, /usa

wait, twait

end

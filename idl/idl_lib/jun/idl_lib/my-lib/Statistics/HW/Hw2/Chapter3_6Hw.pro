PRO Chapter3_6Hw

newPrecip = FltArr(19)
Precip = [43, 10, 4, 0, 2, -999, 31, 0, 0, 0, 2, 3, 0, 4, 15, 2, 0, 1, 127, 2]

R = Where(Precip GE 0)	;"R" will index all the values in the array except missing data
newPrecip = Precip(R)	;For simplicity's sake, we will just make this a new array.

ResultPrecip = Sort(newPrecip)		;Sorting the values
SortPrecip = newPrecip[Sort(newPrecip)]	;Putting the sorted values into an array
SizePrecip = Size(newPrecip)		;Implementing the size function of the array
n = SizePrecip[1]			;Getting the size of the array

minimum = SortPrecip[0]			;min value of the sorted array
maximum = SortPrecip[n-1]		;max value of the sorted array

q025 = ((n-1)*0.25)+1
quantile25 = (SortPrecip[Ceil(q025-1)] + SortPrecip[Floor(q025-1)])/2.

q075 = ((n-1)*0.75)+1
quantile75 = (SortPrecip[Ceil(q075-1)] + SortPrecip[Floor(q075-1)])/2.

Print, "Problem #3.6"
;BOXPLOT---------------------------------------------------------------------------------

Print, "Box Plot"			;These are all the necessary points 
Print, "Minimum = ", minimum		;for the boxplot, in order.
Print, "Quantile 25 = ", quantile25	;I am not graphing this in idl,
Print, "Median = ", Median(Precip)	;I am simply printing out the
Print, "Quantile 75 = ", quantile75	;data values to plot in excel
Print, "Maximum = ", maximum
Print, " "

;SCHEMATIC-------------------------------------------------------------------------------

IQR = quantile75 - quantile25
upperOuterFence = quantile75 + 3*IQR		;Figuring out the fences 
upperInnerFence = quantile75 + (3*IQR)/2	;for the Schematic plot
lowerInnerFence = quantile25 - (3*IQR)/2
lowerOuterFence = quantile25 - 3*IQR

FOR i = 1, n-1 DO BEGIN
	;We want to find the highest value in between the upper fences
	IF (SortPrecip[i] LE upperInnerFence) THEN BEGIN
		IF (SortPrecip[i] GE SortPrecip[i-1]) THEN BEGIN
			largeInside = float(SortPrecip[i])	;keep as a float number
		ENDIF
	ENDIF
	;Here, we want to find the lowest value between the lower fences
	IF (SortPrecip[i] LE quantile25) THEN BEGIN
		IF (SortPrecip[i] LE SortPrecip[i-1]) THEN BEGIN
			smallInside = float(SortPrecip[i])	;keep as a float number
		ENDIF
	ENDIF
ENDFOR

Print, "Schematic Plot"
Print, "Upper Outer = ", upperOuterFence	;I am not graphing this in idl,
Print, "Upper Inner = ", upperInnerFence	;I am simply printing out the 
Print, "Large Inside = ", largeInside		;data values to plot in excel
Print, "Quantile 75 = ", quantile75
Print, "Median = ", Median(Precip)
Print, "Quantile 25 = ", quantile25
Print, "Small Inside = ", smallInside
Print, "Lower Inner = ", lowerInnerFence	;Please see attatched sheet for
Print, "Lower Outer = ", lowerOuterFence	;both the boxplot and schematic plot.
END

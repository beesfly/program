PRO Chapter5_3Hw

;Problem 5.3

CanMin =[28.0, 28.0, 26.0, 19.0, 16.0, 24.0, 26.0, 24.0, 24.0, $
29.0, 29.0, 27.0, 31.0, 26.0, 38.0, 23.0, 13.0, 14.0, 28.0, 19.0, $
19.0, 17.0, 22.0, 2.0, 4.0, 5.0, 7.0, 8.0, 14.0, 14.0, 23.0]

IthMin = [19.0, 25.0, 22.0, -1.0, 4.0, 14.0, 21.0, 22.0, 23.0, $
27.0, 29.0, 25.0, 29.0, 15.0, 29.0, 24.0, 0, 2.0, 26.0, 17.0, $
19.0, 9.0, 20.0, -6.0, -13.0, -13.0, -11.0, -4.0, -4.0, 11.0, 23.]

delta = FltArr(31)

canAvg = Mean(CanMin)		;Average of Canadiagua temps
ithAvg = Mean(IthMin)		;Average of Ithaca temps

;Variance = (Standard Deviation)^2
canVar = Variance(CanMin)	;Variance of Canadaigua temps
ithVar = Variance(IthMin)	;Variance of Ithaca

FOR i = 0,  30 DO BEGIN
    delta(i) = CanMin(i) - IthMin(i)
ENDFOR

deltaVar = Variance(delta)

rho = A_Correlate(delta,  1)
;rho = .4087

nPrime = 31*((1 - rho)/(1 + rho)) 

rhoDelta = deltaVar/nprime
z = (ithAvg - canAvg) / SQRT(rhoDelta)
print,  z

;z = -4.04847

;A.  Ha = Min temps are different
;Two-tailed test, with even tails
;One tail = -4.04, so for both tails, p = Z(-4.04) + Z(4.04) = 0.00006

;B. Ha = Canadaigua temps are warmer
;One-tailed test
;One tail = -4.04, p = Z(-4.04) = 0.00003

END

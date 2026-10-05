local Easing = {}

function Easing.SinEnd(p: number)
	return (math.sin(p * 1.5707963267948966))
end

function Easing.SinStart(p: number)
	return 1 - math.cos(p * 1.5707963267948966)
end

function Easing.SinBoth(p: number)
	return 0.5 - math.cos(p * 3.141592653589793) * 0.5
end

return Easing
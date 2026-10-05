return {
	tuneBrightness = function(color: Color3, p: number)
		local HSV, v, v2 = color:ToHSV()
		return Color3.fromHSV(HSV, v, v2 * p)
	end
}
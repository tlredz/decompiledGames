local v = {
	25,
	33,
	37,
	45,
	51,
	56,
	66,
	107,
	124,
	132,
	152,
	155
}
return function(object, p, p2)
	for k, v2 in pairs(v) do
		object:CreateSound("rbxassetid://14241444681", 1, 1 + 0.25 * math.random(), true, 10)
		object:CreateSound("rbxassetid://110122962237431", 1.25, 1.25 + 0.25 * math.random() + 0.25, true, 5)

		if not object:_AnimationWait(script.Name, p2, (v2 - (v[k - 1] or 0)) / 60 / p) then
			break
		end
	end
end
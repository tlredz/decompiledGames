local _ = {
	4,
	6,
	12,
	17,
	23,
	28,
	33,
	38,
	42,
	46,
	51,
	56,
	62,
	67
}
local v = { "rbxassetid://14000023581", "rbxassetid://14000023392" }
return function(object, p, p2)
	for _ = 1, 15 do
		object:CreateSound(v[math.random(#v)], 0.75 + 0.5 * math.random(), 2 + 0.5 * math.random(), true, 10)
		object:CreateSound("rbxassetid://13455968853", 0.375, 1.25 + 0.25 * math.random(), true, 10)

		if not object:_AnimationWait(script.Name, p2, 0.06666666666666667 / p) then
			break
		end
	end
end
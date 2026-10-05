return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://136633555539199", 1, 0.625, true, 10)
	object:CreateSound("rbxassetid://21343225", 0.25 + 0.125 * math.random(), 0.9 + 0.2 * math.random(), true, 10)
end
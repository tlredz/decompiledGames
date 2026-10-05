return function(object, p, p2)
	object:CreateSound("rbxassetid://85453370165436", 1, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://136633555539199", 1, 0.625, true, 10)
end
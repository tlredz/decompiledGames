return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://136633555539199", 1, 0.75, true, 10)
	object:CreateSound("rbxassetid://111488886881644", 1, 1, true, 10)
end
return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.45 / p) then
		return
	end

	object:CreateSound("rbxassetid://17274798693", 0.75, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://17274798406", 0.75, 1, true, 10)
	object:CreateSound("rbxassetid://17274798198", 0.75, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.6 / p) then
		return
	end

	object:CreateSound("rbxassetid://17274798538", 0.75, 1, true, 10)
end
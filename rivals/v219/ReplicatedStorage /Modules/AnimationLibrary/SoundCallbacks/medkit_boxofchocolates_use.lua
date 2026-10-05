return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://75064925834262", 0.875, 1 + 0.2 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 2.05 / p) then
		return
	end

	object:CreateSound("rbxassetid://128380920423591", 0.875, 0.8 + 0.2 * math.random(), true, 5)
	object:CreateSound("rbxassetid://18128896325", 0.75, 1 + 0.25 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://128380920423591", 0.875, 0.8 + 0.2 * math.random(), true, 5)
	object:CreateSound("rbxassetid://18128896325", 0.75, 1 + 0.25 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.85 / p) then
		return
	end

	object:CreateSound("rbxassetid://128380920423591", 0.875, 0.8 + 0.2 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://128380920423591", 0.875, 0.8 + 0.2 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.07 / p) then
		return
	end

	object:CreateSound("rbxassetid://128380920423591", 0.75, 0.9 + 0.2 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.04 / p) then
		return
	end

	object:CreateSound("rbxassetid://128380920423591", 0.625, 1 + 0.2 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.03 / p) then
		return
	end

	object:CreateSound("rbxassetid://18128896325", 0.75, 1 + 0.25 * math.random(), true, 10)
end
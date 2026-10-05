return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 1.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://92914419322840", 1, 1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.3 / p) then
		return
	end

	object:CreateSound("rbxassetid://92914419322840", 0.875, 1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 1.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://18128896162", 1, 1 + 0.25 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	object:CreateSound("rbxassetid://78700624599503", 1.25, 1 + 0.1 * math.random(), true, 10)

	if not object:_AnimationWait(script.Name, p2, 1 / p) then
		return
	end

	for i = 1, 5 do
		object:CreateSound("rbxassetid://18128896325", 1 - i * 0.15, i * 0.1 + 1, true, 10)

		if not object:_AnimationWait(script.Name, p2, 0.1 / p) then
			break
		end
	end
end
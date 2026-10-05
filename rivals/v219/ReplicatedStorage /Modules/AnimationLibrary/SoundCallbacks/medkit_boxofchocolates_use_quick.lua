return function(object, p, p2)
	object:CreateSound("rbxassetid://75064925834262", 0.875, 1 + 0.2 * math.random(), true, 5)

	if not object:_AnimationWait(script.Name, p2, 0.3 / p) then
		return
	end

	for _ = 1, 3 do
		object:CreateSound("rbxassetid://128380920423591", 0.875, 0.8 + 0.2 * math.random(), true, 5)

		if not object:_AnimationWait(script.Name, p2, 0.1 / p) then
			return
		end
	end

	object:CreateSound("rbxassetid://18128896325", 0.75, 1 + 0.25 * math.random(), true, 10)
end
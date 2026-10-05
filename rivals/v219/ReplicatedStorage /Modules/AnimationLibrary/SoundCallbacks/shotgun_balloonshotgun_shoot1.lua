return function(object, p, p2)
	for i = 1, 5 do
		local v = i
		task.spawn(function()
			if not object:_AnimationWait(script.Name, p2, 0.15 / p * v / 5) then
				return
			end

			object:CreateSound("rbxassetid://17803308936", 1 + 0.25 * math.random(), 1 + 0.3 * math.random(), true, 10)
		end)
	end

	if not object:_AnimationWait(script.Name, p2, 0.35 / p) then
		return
	end

	object:CreateSound("rbxassetid://17803360572", 1, 2, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.15 / p) then
		return
	end

	object:CreateSound("rbxassetid://17803360572", 1, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.1 / p) then
		return
	end

	object:CreateSound("rbxassetid://17803368105", 0.5, 0.75 + 0.25 * math.random(), true, 10)
end
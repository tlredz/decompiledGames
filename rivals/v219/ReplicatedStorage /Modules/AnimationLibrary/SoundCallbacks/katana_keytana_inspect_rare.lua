local v = { "rbxassetid://14000023581", "rbxassetid://14000023392" }
return function(object, p, p2)
	if not object:_AnimationWait(script.Name, p2, 2 / p) then
		return
	end

	object:CreateSound("rbxassetid://14427935597", 0.5, 1.125, true, 10)
	object:CreateSound("rbxassetid://96253147006478", 0.75, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://96253147006478", 0.5, 1.375, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://96253147006478", 0.25, 1.5, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.375 / p) then
		return
	end

	for _ = 1, 15 do
		object:CreateSound(v[math.random(#v)], 1, 1 + 0.25 * math.random(), true, 10)
		object:CreateSound("rbxassetid://96253147006478", 0.375, 1 + 0.5 * math.random(), true, 10)

		if not object:_AnimationWait(script.Name, p2, 0.058333333333333334 / p) then
			return
		end
	end

	if not object:_AnimationWait(script.Name, p2, 0.15 / p) then
		return
	end

	object:CreateSound("rbxassetid://96253147006478", 0.2, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.25 / p) then
		return
	end

	object:CreateSound("rbxassetid://96253147006478", 0.1, 1.5, true, 10)
	object:CreateSound("rbxassetid://89056031983351", 0.75, 1.117, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.933 / p) then
		return
	end

	object:CreateSound("rbxassetid://133090858473825", 0.75, 1, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://90757583550672", 0.75, 1 + 0.125 * math.random(), true, 5)

	for i = 1, 3 do
		object:CreateSound("rbxassetid://14427782350", 1, (i - 1) * 0.25 + 1, true, 10)

		if not object:_AnimationWait(script.Name, p2, 0.05 / p) then
			return
		end
	end

	if not object:_AnimationWait(script.Name, p2, 0.5 / p) then
		return
	end

	object:CreateSound("rbxassetid://71387264231358", 1, 0.875, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.767 / p) then
		return
	end

	local sound = object:CreateSound("rbxassetid://82637145735352", 0.5, 1 + 0.1 * math.random(), true)
	task.spawn(function()
		if not object:_AnimationWait(script.Name, p2, 2.5 / p) then
			return
		end

		if sound then
			sound:Destroy()
		end
	end)

	if not object:_AnimationWait(script.Name, p2, 1.45 / p) then
		return
	end

	for _ = 1, 5 do
		object:CreateSound("rbxassetid://13160326139", 0.75, 1 + 0.25 * math.random(), true, 10)

		if not object:_AnimationWait(script.Name, p2, 0.2 / p) then
			break
		end
	end
end
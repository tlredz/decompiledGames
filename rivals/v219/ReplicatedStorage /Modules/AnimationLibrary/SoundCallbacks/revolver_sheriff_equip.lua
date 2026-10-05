return function(object, p, p2)
	local sound = object:CreateSound("rbxassetid://13456860578", 1.25, 1.25, true, 10)

	if not object:_AnimationWait(script.Name, p2, 0.4 / p) then
		return
	end

	if sound then
		sound:Destroy()
	end

	object:CreateSound("rbxassetid://13483008798", 1, 2, true, 10)
end
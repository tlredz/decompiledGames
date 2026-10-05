return function(object, _, _)
	local sound = object:CreateSound("rbxassetid://73325703605178", 0.5, 1, true, 5, 100, 400)

	if sound then
		sound:SetAttribute("DontClearSound", true)
	end

	local sound2 = object:CreateSound("rbxassetid://94406584083681", 0.5, 1, true, 5, 100, 400)

	if sound2 then
		sound2:SetAttribute("DontClearSound", true)
	end

	local sound3 = object:CreateSound("rbxassetid://101461584188367", 1, 1, true, 5, 100, 400)

	if sound3 then
		sound3:SetAttribute("DontClearSound", true)
	end
end
return function(_, list, value)
	local cFrame = nil

	if typeof(value) == "Instance" then
		if value.Character and value.Character:FindFirstChild("HumanoidRootPart") then
			cFrame = value.Character.HumanoidRootPart.CFrame
		else
			return "Target player has no character."
		end
	elseif typeof(value) == "Vector3" then
		cFrame = CFrame.new(value)
	end

	for _, v in ipairs(list) do
		if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
			v.Character.HumanoidRootPart.CFrame = cFrame
		end
	end

	return ("Teleported %d players."):format(#list)
end
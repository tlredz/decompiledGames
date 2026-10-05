local PlayerToolsUtil = {
	GetPlayerTools = function(player)
		local tools = {}

		for _, tool in player.Backpack:GetChildren() do
			if tool:IsA("Tool") then
				table.insert(tools, tool)
			end
		end

		for _, tool in player.Character:GetChildren() do
			if tool:IsA("Tool") then
				table.insert(tools, tool)
			end
		end

		for _, tool in player.StarterGear:GetChildren() do
			if tool:IsA("Tool") then
				table.insert(tools, tool)
			end
		end

		return tools
	end
}

function PlayerToolsUtil.GetCurrentEquippedGunSkinsByDictionary(p)
	local playerTools = PlayerToolsUtil.GetPlayerTools(p)
	local result = {}

	for _, playerTool in playerTools do
		local gunName = playerTool:FindFirstChild("GunName")

		if gunName then
			result[gunName.Value] = true
		end
	end

	return result
end

function PlayerToolsUtil.GetPlayerToolByDictionary(p)
	local playerTools = PlayerToolsUtil.GetPlayerTools(p)
	local playerToolsByName = {}

	for _, playerTool in playerTools do
		playerToolsByName[playerTool.Name] = playerTool
	end

	return playerToolsByName
end

return PlayerToolsUtil
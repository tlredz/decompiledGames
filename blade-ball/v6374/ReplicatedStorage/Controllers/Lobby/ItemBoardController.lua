local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Swords)
local v2 = require3(ReplicatedStorage2.Shared.LobbyLimitedSwords.ItemBoardData)

function GetAbilityData(p, childName)
	if p == "LimitedAbility" then
		return ReplicatedStorage2.Misc.DataAbilities:FindFirstChild(childName)
	end

	return v2.CustomItems[childName]
end

function NewBoard(instance)
	local screen = instance:WaitForChild("Screen")
	local surfaceGui = screen:WaitForChild("SurfaceGui")
	local surfaceGui2 = screen:WaitForChild("SurfaceGui2")
	surfaceGui.Enabled = false
	surfaceGui2.Enabled = false

	local function updateScreen()
		surfaceGui.Enabled = false
		surfaceGui2.Enabled = false

		if screen:GetAttribute("ShowCustomItem") then
			local limitedCustomItem = screen:GetAttribute("LimitedCustomItem")
			local v3 = GetAbilityData("LimitedCustomItem", limitedCustomItem)

			if not v3 then
				surfaceGui.Enabled = false
				return
			end

			local abilityTile = surfaceGui.Bottom.AbilityTile
			abilityTile.AbilityIcon.Image = v3.Icon
			abilityTile.Header.Text = v3.Name
			surfaceGui.Bottom.DescriptionTile.Header.Text = v3.Description
			surfaceGui.Top.Header.Text = v3.TitleText
			surfaceGui.Enabled = true
			surfaceGui2.Enabled = false
		else
			surfaceGui.Enabled = false

			if screen:GetAttribute("ShowLimitedAbility") then
				local limitedAbility = screen:GetAttribute("LimitedAbility")
				local v3 = GetAbilityData("LimitedAbility", limitedAbility)

				if not v3 then
					surfaceGui.Enabled = false
					return
				end

				local abilityTile = surfaceGui.Bottom.AbilityTile
				abilityTile.AbilityIcon.Image = v3:GetAttribute("Icon")
				abilityTile.Header.Text = ("%s\nAbility"):format(v3.Name)
				surfaceGui.Bottom.DescriptionTile.Header.Text = v3:GetAttribute("Description")
				surfaceGui.Top.Header.Text = v3:GetAttribute("TitleText") or v3.Name
				surfaceGui.Enabled = true
				surfaceGui2.Enabled = false
			else
				surfaceGui.Enabled = false

				if not screen:GetAttribute("ShowLimitedSword") then
					surfaceGui2.Enabled = false
					return
				end

				local limitedSword = screen:GetAttribute("LimitedSword")
				local sword = limitedSword and v:GetSword(limitedSword)

				if not sword then
					surfaceGui.Enabled = false
					return
				end

				local name = sword.Name
				local parts = sword.Name:split(" ")

				if #parts > 1 then
					name = string.rep("%s ", #parts - 1):format(table.unpack(parts, 1, #parts - 1)) .. "\n" .. parts[#parts]
				end

				local color = v2.RarityColors[sword.Rarity] or Color3.fromRGB(255, 255, 255)
				local abilityTile = surfaceGui2.Bottom.AbilityTile
				abilityTile.AbilityIcon.UIStroke.Color = color
				abilityTile.AbilityIcon.Image = sword.Icon or ""
				abilityTile.Header.Text = name
				surfaceGui2.Enabled = true
				surfaceGui.Enabled = false
			end
		end
	end

	local v3 = {
		screen:GetAttributeChangedSignal("ShowLimitedSword"):Connect(updateScreen),
		screen:GetAttributeChangedSignal("ShowLimitedAbility"):Connect(updateScreen),
		screen:GetAttributeChangedSignal("ShowCustomItem"):Connect(updateScreen),
		screen:GetAttributeChangedSignal("Carousel"):Connect(function()
			task.wait(1)
			updateScreen()
		end)
	}
	instance.Destroying:Connect(function()
		for _, connection in ipairs(v3) do
			connection:Disconnect()
		end

		table.clear(v3)
	end)
	updateScreen()
end

function NewCarousel(instance)
	return task.spawn(function()
		local screen = instance:WaitForChild("Screen", 60)

		while true do
			for _, cycleReward in v2.CycleRewards do
				for _, itemType in v2.ItemTypes do
					if itemType == `Limited{cycleReward.ItemType}` then
						screen:SetAttribute(itemType, cycleReward.ItemName)
					else
						screen:SetAttribute(itemType, "")
					end
				end

				screen:SetAttribute("ShowCustomItem", false)
				screen:SetAttribute("ShowLimitedAbility", false)
				screen:SetAttribute("ShowLimitedSword", false)
				local v3 = cycleReward
				task.defer(function()
					screen:SetAttribute("ShowCustomItem", v3.ItemType == "CustomItem")
					screen:SetAttribute("ShowLimitedAbility", v3.ItemType == "Ability")
					screen:SetAttribute("ShowLimitedSword", v3.ItemType == "Sword")
				end)
				task.wait(10)
			end
		end
	end)
end

function OnAbilityBoardAdded(instance)
	local screen = instance:WaitForChild("Screen", 60)

	if not screen then
		return
	end

	NewBoard(instance)
	local v3 = nil

	local function shiftCarousel()
		if typeof(v3) == "thread" and coroutine.status(v3) == "suspended" then
			task.cancel(v3)
		end

		if screen:GetAttribute("Carousel") then
			v3 = NewCarousel(instance)
		end
	end

	screen:GetAttributeChangedSignal("Carousel"):Connect(shiftCarousel)
	shiftCarousel()
end

return {
	Start = function(_)
		task.delay(3, function()
			if not workspace:WaitForChild("Spawn"):FindFirstChild("Boards") then
				return
			end

			for _, v3 in ipairs(CollectionService:GetTagged("AbilityBoard")) do
				task.spawn(OnAbilityBoardAdded, v3)
			end

			CollectionService:GetInstanceAddedSignal("AbilityBoard"):Connect(OnAbilityBoardAdded)
		end)
	end
}
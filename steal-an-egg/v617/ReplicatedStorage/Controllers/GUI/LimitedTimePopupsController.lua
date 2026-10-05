local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local ShopNavigation = require(ReplicatedStorage.Client.ShopNavigation)
local LimitedTimePopups = require(ReplicatedStorage.Data.LimitedTimePopups)
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local GamepadBindings = require(ReplicatedStorage.Client.GamepadBindings)
local limitedTimePopupsUI = Players.LocalPlayer.PlayerGui:WaitForChild("LimitedTimePopupsUI")
local FindRootFrame

FindRootFrame = function(parent)
	if parent.Parent == limitedTimePopupsUI or not parent.Parent then
		return parent
	end

	return FindRootFrame(parent.Parent)
end

local function toDHMS(p: number)
	if p > 86400 then
		return string.format("%id %ih %02im %02is", p / 86400, p / 3600 % 24, p / 60 % 60, p % 60)
	end

	if p > 3600 then
		return string.format("%ih %02im %02is", p / 3600 % 24, p / 60 % 60, p % 60)
	end

	return string.format("%02im %02is", p / 60 % 60, p % 60)
end

return {
	Start = function()
		Remotes.LimitedTimePopups.ShowLimitedTimePopup.OnClientEvent:Connect(function(childName: string)
			local child = limitedTimePopupsUI:FindFirstChild(childName)

			if not child then
				return
			end

			if child:FindFirstChild("Animation") then
				child:SetAttribute("Open", true)
			else
				child.Visible = true
			end
		end)

		for _, guiObject in limitedTimePopupsUI:GetDescendants() do
			if guiObject:IsA("GuiButton") and guiObject.Name == "Close" then
				local v = guiObject
				ButtonFX(guiObject, 1.08, function()
					local v2 = v

					if v2.Parent ~= limitedTimePopupsUI and v2.Parent then
						v2 = FindRootFrame(v2.Parent)
					end

					if v2:FindFirstChild("Animation") then
						v2:SetAttribute("Open", false)
					else
						v2.Visible = false
					end
				end)
				GamepadBindings.Inspect(guiObject)
			elseif guiObject:IsA("GuiButton") and guiObject:GetAttribute("Nav") == "Shop" then
				local v = guiObject
				ButtonFX(guiObject, 1.08, function()
					local v2 = v

					if v2.Parent ~= limitedTimePopupsUI and v2.Parent then
						v2 = FindRootFrame(v2.Parent)
					end

					v2.Visible = false
					v2:SetAttribute("Open", nil)
					ShopNavigation.Open("Featured")
				end)
				GamepadBindings.Inspect(guiObject)
			elseif guiObject:IsA("TextLabel") and guiObject.Name == "Timer" then
				local v

				if guiObject.Parent == limitedTimePopupsUI or not guiObject.Parent then
					v = guiObject
				else
					v = FindRootFrame(guiObject.Parent)
				end

				local limitedTimePopup = LimitedTimePopups[v.Name]

				if limitedTimePopup then
					if os.time() > limitedTimePopup.EndTime then
						guiObject.Text = "LAST CHANCE!"
					else
						local v2 = limitedTimePopup
						local v3 = guiObject
						task.spawn(function()
							while true do
								task.wait(1)
								local v4 = v2.EndTime - os.time()
								v3.Text = v4 > 0 and toDHMS(v4) or "LAST CHANCE!"
							end
						end)
					end
				end
			end
		end
	end
}
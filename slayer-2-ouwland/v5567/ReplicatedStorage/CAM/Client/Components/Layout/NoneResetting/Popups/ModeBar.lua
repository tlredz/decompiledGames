local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local ClanSkills = require(ReplicatedStorage.CAM.Clans.ClanSkills)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
require(ReplicatedStorage.Packages.faye)
local localPlayer = Players.LocalPlayer
local data = Utility.GetData(localPlayer, true)
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local HUD = ReplicatedStorage.CAM.Client.Components.Layout.Visibility.HUD
local color = Color3.new(1, 0.666667, 0)

local function modeNameFor()
	local clan = data:FindFirstChild("Clan")
	local v = clan ~= nil and ClanSkills.SkillSets[clan.Value] or nil

	if v == nil then
		return ""
	end

	for _, skill in v.Skills do
		if skill.RequiresModeBar then
			return skill.Name
		end
	end

	return ""
end

return function(object, parent)
	if gameSettings.IsMenu then
		return
	end

	local value = object:Value(getvaluesfolder:FindFirstChild("ModeBar"))
	object:Connect(getvaluesfolder.ChildAdded, function(p2)
		if p2.Name == "ModeBar" then
			value:Set(p2)
		end
	end)
	object:Connect(getvaluesfolder.ChildRemoved, function(p2)
		if p2.Name == "ModeBar" then
			value:Set(nil)
		end
	end)
	local clan = data:FindFirstChild("Clan")
	local v

	if clan ~= nil then
		v = ClanSkills.SkillSets[clan.Value] or nil
	end

	local name

	if v == nil then
		name = ""
	else
		local flag = true

		for _, skill in v.Skills do
			if not skill.RequiresModeBar then
				continue
			end

			name = skill.Name
			flag = false
			break
		end

		if flag then
			name = ""
		end
	end

	local text = object:Value(name)
	local clan2 = data:FindFirstChild("Clan")

	if clan2 ~= nil then
		object:Connect(clan2:GetPropertyChangedSignal("Value"), function()
			local clan3 = data:FindFirstChild("Clan")
			local v3

			if clan3 ~= nil then
				v3 = ClanSkills.SkillSets[clan3.Value] or nil
			end

			local name2

			if v3 == nil then
				name2 = ""
			else
				local flag = true

				for _, skill in v3.Skills do
					if not skill.RequiresModeBar then
						continue
					end

					name2 = skill.Name
					flag = false
					break
				end

				if flag then
					name2 = ""
				end
			end

			text:Set(name2)
		end)
	end

	local visible = object:Value(false)

	local function refreshShown()
		visible:Set(value:Get() ~= nil and HUD.Value == true)
	end

	object:Connect(value.Changed, refreshShown)
	object:Connect(HUD.Changed, refreshShown)
	local v2

	if value:Get() == nil then
		v2 = false
	else
		v2 = HUD.Value == true
	end

	visible:Set(v2)
	return object:Create("Frame")({
		Parent = parent,
		Name = "ModeBar",
		Visible = visible,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 6),
		Size = UDim2.fromScale(1, 0.015),
		ZIndex = 1001,
		BackgroundTransparency = 1,
		object:Create("UIAspectRatioConstraint")({
			AspectRatio = 11,
			DominantAxis = Enum.DominantAxis.Height
		}),
		object:State(function(callback, object2)
			local v3 = callback(value)

			if v3 == nil then
				return
			end

			local function progress()
				return Vector2.new(v3.Value / math.max(1, v3.MaxValue) - 0.5, 0)
			end

			local offset = object2:Value(progress())

			local function sync()
				offset:Set(progress())
			end

			object2:Connect(v3.Changed, sync)
			object2:Connect(v3:GetPropertyChangedSignal("MaxValue"), sync)
			return object2:Create("Frame")({
				Name = "Contents",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				object2:Create("TextLabel")({
					ZIndex = 2,
					Size = UDim2.fromScale(2, 1.2),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0),
					BackgroundTransparency = 1,
					Text = text,
					TextScaled = true,
					Font = Enum.Font.SourceSansSemibold,
					TextColor3 = Color3.new(1, 1, 1),
					object2:Create("UIStroke")({
						Transparency = 0.5
					})
				}),
				object2:Create("ImageLabel")({
					Name = "Bg",
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Image = "rbxassetid://96530286290212",
					ImageColor3 = Color3.new(0.15, 0.15, 0.15),
					ImageTransparency = 0.35
				}),
				object2:Create("ImageLabel")({
					Name = "Fill",
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					Image = "rbxassetid://129967009443470",
					ImageColor3 = color,
					object2:Create("UIGradient")({
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(0.499, 0),
							NumberSequenceKeypoint.new(0.501, 1),
							NumberSequenceKeypoint.new(1, 1)
						}),
						Offset = offset
					})
				})
			})
		end)
	})
end
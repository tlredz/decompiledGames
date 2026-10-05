local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Titles = require(ReplicatedStorage.CAM.Global.Titles)
local TitleParticles = require(ReplicatedStorage.CAM.Client.Modules.TitleParticles)
local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
local SettingsKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.SettingsKeys)
local faye = require(ReplicatedStorage.Packages.faye)
local v = DataValue.new(SettingsKeys.Titles.Path, SettingsKeys.Titles.Default, SettingsKeys.Scope)
local v2 = DataValue.new(SettingsKeys.TitleEffects.Path, SettingsKeys.TitleEffects.Default, SettingsKeys.Scope)
local color = Color3.fromRGB(205, 205, 205)
return function(instance, instance2, _, p)
	local maid = faye.new()
	local text = maid:Value("")
	local text2 = maid:Value("")
	local color2 = maid:Value(ColorSequence.new(Color3.new(1, 1, 1)))
	local transparency = maid:Value(0.75)
	local billboardGui = instance:FindFirstAncestorOfClass("BillboardGui")
	local v3 = nil

	local function labelOf()
		return v3
	end

	local function refresh()
		local vanityTitle = instance2:GetAttribute("VanityTitle")
		local v4

		if type(vanityTitle) == "string" and v:Get() ~= false then
			v4 = Titles.Get(vanityTitle)
		end

		local season

		if v4 ~= nil then
			season = v4.season
		end

		text2:Set(season or "")
		local displayName

		if v4 == nil then
			displayName = ""
		elseif season == nil then
			displayName = v4.displayName
		else
			displayName = string.sub(v4.displayName, #season + 2)
		end

		text:Set(displayName)

		if v4 ~= nil then
			color2:Set(Titles.GetColor(vanityTitle))
		end

		local v6

		if not (v4 == nil or v2:Get() == false) then
			v6 = TitleParticles.TemplateFor(v4.particle or v4.displayName)
		end

		transparency:Set(v6 == nil and 0.75 or 0.2)

		if v6 == nil or billboardGui == nil or p == nil then
			TitleParticles.Remove(instance2)
		else
			TitleParticles.Add(instance2, p, billboardGui, labelOf, v6)
		end
	end

	refresh()
	maid:Connect(instance2:GetAttributeChangedSignal("VanityTitle"), refresh)
	maid:Add(v.Changed:Connect(refresh))
	maid:Add(v2.Changed:Connect(refresh))
	maid:Create("TextLabel")({
		Name = "KVanityTitleSeason",
		Parent = instance,
		Size = UDim2.fromScale(1, 0.2),
		BackgroundTransparency = 1,
		Visible = maid:Do(function(callback)
			return callback(text2) ~= ""
		end),
		Font = Enum.Font.SourceSansBold,
		Text = text2,
		TextColor3 = color,
		TextScaled = true,
		maid:Create("UIStroke")({
			Thickness = 1.5,
			Transparency = 0.35
		})
	})
	maid:Create("TextLabel")({
		Name = "LVanityTitle",
		Parent = instance,
		function(p2)
			v3 = p2
		end,
		Size = UDim2.fromScale(1, 0.28),
		BackgroundTransparency = 1,
		Visible = maid:Do(function(callback)
			return callback(text) ~= ""
		end),
		Font = Enum.Font.SourceSansBold,
		Text = text,
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
		maid:Create("UIStroke")({
			Thickness = 1.5,
			Transparency = transparency
		}),
		maid:Create("UIGradient")({
			Color = color2,
			Rotation = -90
		})
	})
	return function()
		TitleParticles.Remove(instance2)
		maid:Destroy()
	end
end
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local faye = require(ReplicatedStorage.Packages.faye)
return function(parent, character, _, _)
	local playerFromCharacter = Players:GetPlayerFromCharacter(character)

	if playerFromCharacter == nil then
		return
	end

	local v = faye.new()
	local image = v:Value("")

	local function refresh()
		local factionBanner = playerFromCharacter:GetAttribute("FactionBanner")

		if type(factionBanner) ~= "string" then
			image:Set("")
			return
		end

		if factionBanner == "" then
			factionBanner = BunchaIcons.NoFactionIcon
		end

		image:Set(factionBanner)
	end

	local factionBanner = playerFromCharacter:GetAttribute("FactionBanner")

	if type(factionBanner) == "string" then
		if factionBanner == "" then
			factionBanner = BunchaIcons.NoFactionIcon
		end

		image:Set(factionBanner)
	else
		image:Set("")
	end

	v:Connect(playerFromCharacter:GetAttributeChangedSignal("FactionBanner"), refresh)
	v:Create("Frame")({
		Name = "IFaction",
		Parent = parent,
		Size = UDim2.fromScale(1, 0.6),
		BackgroundTransparency = 1,
		Visible = v:Do(function(callback)
			return callback(image) ~= ""
		end),
		v:Create("ImageLabel")({
			Name = "Banner",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ImageTransparency = 0.1,
			ScaleType = Enum.ScaleType.Fit,
			Image = image,
			v:Create("UIAspectRatioConstraint")({
				AspectRatio = 1,
				AspectType = Enum.AspectType.ScaleWithParentSize,
				DominantAxis = Enum.DominantAxis.Height
			})
		})
	})
	return function()
		v:Destroy()
	end
end
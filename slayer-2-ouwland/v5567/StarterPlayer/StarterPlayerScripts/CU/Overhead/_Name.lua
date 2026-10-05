local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local interfaceutility = require(ReplicatedStorage.Packages.interfaceutility)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Ranked = require(ReplicatedStorage.CAM.Global.Ranked)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local v = {
	Mobile = BunchaIcons.Devices.Mobile,
	Xbox = BunchaIcons.Devices.Console,
	Playstation = BunchaIcons.Devices.Console
}
return function(parent, instance, p2, _)
	local v2 = faye.new()
	local displayName

	if p2 == nil then
		displayName = false
	else
		displayName = p2.DisplayName
	end

	if displayName == nil or displayName == "" then
		displayName = instance == nil and "Invalid Name" or instance.Name or "Invalid Name"
	end

	local function clanName()
		local clan = instance:GetAttribute("Clan")

		if typeof(clan) == "string" and clan ~= "" then
			return clan
		end

		return nil
	end

	local function withClan()
		local clan = instance:GetAttribute("Clan")

		if typeof(clan) ~= "string" or clan == "" then
			clan = nil
		end

		if clan == nil then
			return displayName
		end

		return (`{displayName} {clan}`)
	end

	local font = instance:GetAttribute("Font")

	local function badge(name: string, fn)
		return v2:Create("ImageLabel")({
			Name = name,
			Size = UDim2.fromScale(0, 1),
			BackgroundTransparency = 1,
			Visible = false,
			v2:Create("UIAspectRatioConstraint")({
				AspectRatio = 1,
				AspectType = Enum.AspectType.ScaleWithParentSize,
				DominantAxis = Enum.DominantAxis.Height
			}),
			After = fn
		})
	end

	local v3 = v2:Create("Frame")
	local v4 = {
		Size = UDim2.fromScale(1, 0.35),
		Parent = parent,
		Name = "NameHolder",
		BackgroundTransparency = 1
	}
	local v5 = v2:Create("UIListLayout")({
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.Name,
		Padding = UDim.new(0.02, 0)
	})
	local v6 = v2:Create("TextLabel")
	local v7 = {
		Name = "AAName",
		Size = UDim2.fromScale(3, 1),
		BackgroundTransparency = 1
	}
	local clan = instance:GetAttribute("Clan")

	if typeof(clan) ~= "string" or clan == "" then
		clan = nil
	end

	local text

	if clan == nil then
		text = displayName
	else
		text = `{displayName} {clan}`
	end

	v7.Text = text
	v7.TextColor3 = Color3.new(1, 1, 1)
	v7.TextScaled = true
	v7.FontFace = font or Font.fromEnum(Enum.Font.SourceSansSemibold)
	v7[1] = (v2:Create("UIStroke")({
	Thickness = 1.5,
	Transparency = 0.75
}))

	function v7:After()
		local function fit()
			local v9 = self
			local clan2 = instance:GetAttribute("Clan")

			if typeof(clan2) ~= "string" or clan2 == "" then
				clan2 = nil
			end

			local text2

			if clan2 == nil then
				text2 = displayName
			else
				text2 = `{displayName} {clan2}`
			end

			v9.Text = text2

			if font == nil then
				local scaledTextSize = interfaceutility.GetScaledTextSize(self)
				self.Size = UDim2.fromScale(scaledTextSize, 1)
			end
		end

		local clan2 = instance:GetAttribute("Clan")

		if typeof(clan2) ~= "string" or clan2 == "" then
			clan2 = nil
		end

		local text3

		if clan2 == nil then
			text3 = displayName
		else
			text3 = `{displayName} {clan2}`
		end

		self.Text = text3

		if font == nil then
			local scaledTextSize = interfaceutility.GetScaledTextSize(self)
			self.Size = UDim2.fromScale(scaledTextSize, 1)
		end

		v2:Connect(instance:GetAttributeChangedSignal("Clan"), fit)
	end

	do local _values = table.pack(v5, v6(v7), badge("AVerified", function(p3)
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if playerFromCharacter == nil or playerFromCharacter.HasVerifiedBadge ~= true then
		return
	end

	p3.Image = BunchaIcons.Verified
	p3.Visible = true
end), badge("Device", function(p3)
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if playerFromCharacter == nil then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function refresh()
		local v9 = v[playerFromCharacter:GetAttribute("Device")]
		p3.Image = v9 or ""
		p3.Visible = v9 ~= nil
	end

	refresh() -- equivalent call inferred; original call site unknown
	v2:Connect(playerFromCharacter:GetAttributeChangedSignal("Device"), refresh)
end), badge("ZRank", function(p3)
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if playerFromCharacter == nil then
		return
	end

	v2:Spawn(function()
		local _, v9 = Utility.GetData(playerFromCharacter, true)

		if v9 == nil then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refresh()
			local highestIcon = Ranked.HighestIcon(v9)
			p3.Image = highestIcon or ""
			p3.Visible = highestIcon ~= nil
		end

		local v10 = {}

		local function watch(valueBase)
			if v10[valueBase] or not valueBase:IsA("ValueBase") then
				return
			end

			v10[valueBase] = true
			v2:Connect(valueBase.Changed, refresh)
		end

		local function hook(instance2)
			v2:Connect(instance2.DescendantAdded, function(valueBase)
				if not v10[valueBase] and valueBase:IsA("ValueBase") then
					v10[valueBase] = true
					v2:Connect(valueBase.Changed, refresh)
				end

				refresh() -- equivalent call inferred; original call site unknown
			end)
			local modes = instance2:FindFirstChild("Modes")

			if modes ~= nil then
				for _, child in modes:GetChildren() do
					for _, valueBase in child:GetChildren() do
						if v10[valueBase] or not valueBase:IsA("ValueBase") then
							continue
						end

						v10[valueBase] = true
						v2:Connect(valueBase.Changed, refresh)
					end
				end
			end

			refresh() -- equivalent call inferred; original call site unknown
		end

		local ranked = v9:FindFirstChild("Ranked")

		if ranked == nil then
			v2:Connect(v9.ChildAdded, function(p4)
				if p4.Name == "Ranked" then
					hook(p4)
				end
			end)
		else
			hook(ranked)
		end
	end)
end)); for _k = 1, _values.n do v4[_k] = _values[_k] end end
	Imgl = v3(v4)
	return function()
		v2:Destroy()
	end
end
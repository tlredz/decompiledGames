local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {
	Weapons = true,
	Pets = true
}
local rarities = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync")).Rarities
local v2 = {
	Chroma = function(p, p2)
		p.Tags.Chroma.Visible = p2.Chroma == true
	end,
	FX = function(p, p2)
		p.Tags.FX.Visible = p2.FX == true
	end,
	Evo = function(p, p2)
		p.Tags.Evo.Visible = p2.EvoBaseID ~= nil
	end,
	Halloween = function(p, data)
		if not v[data.DataType] then
			p.Tags.Halloween.Visible = data.Event == "Halloween"
			p.Tags.Halloween.Year.Text = data.Year or ""
		end
	end,
	Christmas = function(p, data)
		if not v[data.DataType] then
			p.Tags.Christmas.Visible = data.Event == "Christmas"
			p.Tags.Christmas.Year.Text = data.Year or ""
		end
	end
}
local ItemModule = {}

function ItemModule.GetImage(p)
	if _G.Cache[p] ~= nil then
		return _G.Cache[p]
	end

	local v2

	if tonumber(p) then
		v2 = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. p or p
	else
		v2 = p
	end

	local v3 = v2 .. "&bust=" .. math.random(1, 10000)
	_G.Cache[p] = v3
	return v3
end

function ItemModule.GetImageSmall(p)
	if _G.SmallCache[p] ~= nil then
		return _G.SmallCache[p]
	end

	local v2

	if tonumber(p) then
		v2 = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=110&height=110&assetId=" .. p or p
	else
		v2 = p
	end

	local v3 = v2 .. "&bust=" .. math.random(1, 10000)
	_G.SmallCache[p] = v3
	return v3
end

function ItemModule.DisplayItem(instance, state, p, p2)
	if state == nil then
		instance.ItemName.Label.Text = ""
		instance.Container.Icon.Image = ""
		instance.Container.Amount.Text = ""
		instance.ItemName.BackgroundColor3 = Color3.fromRGB(95, 95, 95)

		for _, frame in pairs(instance.Tags:GetChildren()) do
			if frame:IsA("Frame") then
				frame.Visible = false
			end
		end
	else
		instance.ItemName.Label.Text = state.ItemName or state.Name
		state.Rarity = state.Rarity or "Common"
		local color = rarities[state.Rarity].Color
		local color2 = Color3.fromRGB(color.r, color.g, color.b) or Color3.new(1, 1, 1)
		instance.ItemName.BackgroundColor3 = color2
		local icon = instance.Container.Icon
		local image = state.Image
		local image2

		if _G.Cache[image] == nil then
			local v4

			if tonumber(image) then
				v4 = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. image or image
			else
				v4 = image
			end

			image2 = v4 .. "&bust=" .. math.random(1, 10000)
			_G.Cache[image] = image2
		else
			image2 = _G.Cache[image]
		end

		icon.Image = image2

		if instance.Container:FindFirstChild("Amount") then
			local v4 = p or state.Amount
			instance.Container.Amount.Text = v4 and v4 > 1 and "x" .. v4 or ""
		end

		if instance.Container:FindFirstChild("Classic") then
			instance.Container.Classic.Visible = state.Classic ~= nil
		end

		if instance.ItemName:FindFirstChild("ColoredName") then
			instance.ItemName.ColoredName.Text = state.ItemName or state.Name

			if state.Rarity == "Common" then
				color2 = Color3.new(1, 1, 1)
			end

			instance.ItemName.ColoredName.TextColor3 = color2
			instance.ItemName.RarityBar.BackgroundColor3 = color2
		end

		if instance:FindFirstChild("Tags") then
			for childName, v4 in pairs(v2) do
				if instance.Tags:FindFirstChild(childName) then
					v4(instance, state)
				end
			end
		end

		if state.Signature then
			local signature = state.Signature

			if signature ~= "" then
				instance.Tags.Unique.PlayerName.Text = signature .. "'s"
				instance.Tags.Unique.Visible = true

				if tonumber(signature) then
					spawn(function()
						instance.Tags.Unique.PlayerName.Text = game.Players:GetNameFromUserIdAsync((math.abs(state.Signature))) .. "'s"
					end)
				end
			end

			instance.Container.Amount.Text = state.Rank and "#" .. state.Rank or ""
		end

		if p2 and instance:FindFirstChild("Tags") then
			for _, frame in pairs(instance.Tags:GetChildren()) do
				if frame:IsA("Frame") and frame.Visible == false then
					frame:Destroy()
				end
			end

			if #instance.Tags:GetChildren() == 1 then
				instance.Tags:Destroy()
			end
		end
	end
end

function ItemModule.Commafy(p)
	local v3 = tostring(p)

	repeat
		local v4
		v3, v4 = string.gsub(v3, "^(-?%d+)(%d%d%d)", "%1,%2")
		k = v4
	until k == 0

	return v3
end

function ItemModule.AnimateItemIconIntoInventory(instance, p, parent)
	local clone = instance:Clone()
	local X = instance.AbsoluteSize.X
	local Y = instance.AbsoluteSize.Y
	local X2 = instance.AbsolutePosition.X
	local Y2 = instance.AbsolutePosition.Y
	clone.Size = UDim2.new(0, X, 0, Y)
	clone.BackgroundTransparency = 1
	clone.Position = UDim2.new(0, X2 + X / 2, 0, Y2 + Y / 2)
	clone.AnchorPoint = Vector2.new(0.5, 0.5)
	clone.ZIndex = 10
	clone.Parent = parent
	spawn(function()
		clone:TweenSizeAndPosition(
			UDim2.new(0, 25, 0, 25),
			UDim2.new(
				0,
				p.AbsolutePosition.X + p.AbsoluteSize.X / 2 - 3,
				0,
				p.AbsolutePosition.Y + p.AbsoluteSize.Y / 2 - 20
			),
			"InOut",
			"Sine",
			0.5
		)
		wait(0.5)
		clone:Destroy()
	end)
end

return ItemModule
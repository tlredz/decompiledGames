local function child(parent, className, name)
	local instance = parent:FindFirstChild(name)

	if not instance then
		instance = Instance.new(className)
		instance.Name = name
		instance.Parent = parent
	end

	return instance
end

local v = {
	ResetAvatar = { "Reset Avatar", "84538386904749", Color3.fromRGB(220, 140, 145) },
	CommunityButton = { "Community", "100273117108727", Color3.fromRGB(127, 156, 240) },
	WearingButton = { "Outfit", "130193323472333", Color3.fromRGB(113, 204, 151) },
	SaveOutfit = { "Save Outfit", "117122377185502", Color3.fromRGB(191, 143, 242) }
}

local function skin(button, text, p, color)
	button:SetAttribute("IconNavigation", true)
	button.BackgroundColor3 = Color3.fromRGB(25, 30, 42)
	button.BackgroundTransparency = 0.08
	button.BorderSizePixel = 0
	button.AutoButtonColor = false

	if button:IsA("TextButton") then
		button.TextTransparency = 1
	else
		button.ImageTransparency = 1
	end

	for _, childName in ipairs({ "NavTitle", "NavIndex" }) do
		local child2 = button:FindFirstChild(childName)

		if child2 then
			child2.Visible = false
		end
	end

	local uIPadding = button:FindFirstChildOfClass("UIPadding")

	if uIPadding then
		uIPadding.PaddingLeft = UDim.new()
		uIPadding.PaddingRight = UDim.new()
	end

	local v2 = button:FindFirstChild("IconCorner")

	if not v2 then
		v2 = Instance.new("UICorner")
		v2.Name = "IconCorner"
		v2.Parent = button
	end

	v2.CornerRadius = UDim.new(0, 16)
	local uICorner = button:FindFirstChildOfClass("UICorner")

	if uICorner ~= v2 then
		uICorner.CornerRadius = v2.CornerRadius
	end

	local v3 = button:FindFirstChildOfClass("UIStroke") or button:FindFirstChild("IconStroke")

	if not v3 then
		v3 = Instance.new("UIStroke")
		v3.Name = "IconStroke"
		v3.Parent = button
	end

	v3.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	v3.Color = color
	v3.Transparency = 0.4
	v3.Thickness = 1.5
	local v4 = button:FindFirstChild("IconGradient")

	if not v4 then
		v4 = Instance.new("UIGradient")
		v4.Name = "IconGradient"
		v4.Parent = button
	end

	v4.Rotation = 90
	v4.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(165, 177, 205))
	local v5 = button:FindFirstChild("NavigationArt")

	if not v5 then
		v5 = Instance.new("ImageLabel")
		v5.Name = "NavigationArt"
		v5.Parent = button
	end

	v5.BackgroundTransparency = 1
	v5.Image = "rbxassetid://" .. p
	v5.ScaleType = Enum.ScaleType.Fit

	if not button:GetAttribute("IconHoverBound") then
		v5.Position = UDim2.new(0.5, -45, 0, 4)
		v5.Size = UDim2.fromOffset(90, 90)
	end

	v5.ZIndex = button.ZIndex + 2
	local v6 = button:FindFirstChild("NavigationCaption")

	if not v6 then
		v6 = Instance.new("TextLabel")
		v6.Name = "NavigationCaption"
		v6.Parent = button
	end

	v6.BackgroundTransparency = 1
	v6.Text = text
	v6.Font = Enum.Font.GothamBold
	v6.TextSize = 14
	v6.TextColor3 = Color3.fromRGB(246, 248, 255)
	v6.TextWrapped = true
	v6.Position = UDim2.new(0, 4, 1, -30)
	v6.Size = UDim2.new(1, -8, 0, 26)
	v6.ZIndex = button.ZIndex + 2

	if not button:GetAttribute("IconHoverBound") then
		local RunService = game:GetService("RunService")

		if RunService:IsRunning() then
			local RunService2 = game:GetService("RunService")

			if RunService2:IsClient() then
				button:SetAttribute("IconHoverBound", true)
				local v7 = nil

				local function hover(p2)
					if game.Players.LocalPlayer:GetAttribute("MobileHUDActive") then
						return
					end

					if game.Players.LocalPlayer:GetAttribute("ReducedMotion") then
						p2 = false
					end

					if v7 then
						v7:Cancel()
					end

					local TweenService = game:GetService("TweenService")
					v7 = TweenService:Create(
						v5,
						TweenInfo.new(game.Players.LocalPlayer:GetAttribute("ReducedMotion") and 0 or 0.14),
						{
							Size = UDim2.fromOffset(p2 and 104 or 90, p2 and 104 or 90),
							Position = UDim2.new(0.5, p2 and -52 or -45, 0, p2 and -3 or 4)
						}
					)
					v7:Play()
					v3.Transparency = p2 and 0.05 or 0.4
				end

				button.MouseEnter:Connect(function()
					hover(true)
				end)
				button.MouseLeave:Connect(function()
					hover(false)
				end)
			end
		end
	end
end

return {
	Apply = function(instance, p, value)
		local v2 = p or workspace.CurrentCamera.ViewportSize
		local scale = math.min(value or 1, v2.X / 1000, v2.Y / 800)
		local screenGui = instance:FindFirstChild("ScreenGui")

		if not screenGui then
			return
		end

		local v4 = { screenGui:FindFirstChild("WearingButton"), screenGui:FindFirstChild("CommunityButton") }

		for i, v5 in ipairs(v4) do
			local v6 = v[v5.Name]
			skin(v5, v6[1], v6[2], v6[3])
			local uIScales = {}

			for _, uIScale in v5:GetChildren() do
				if uIScale:IsA("UIScale") then
					table.insert(uIScales, uIScale)
				end
			end

			if #uIScales == 0 then
				table.insert(uIScales, Instance.new("UIScale", v5))
			end

			for i2, v7 in ipairs(uIScales) do
				v7.Scale = i2 == 1 and scale or 1
			end

			v5.AnchorPoint = Vector2.zero
			v5.Size = UDim2.fromOffset(132, 128)
			v5.Position = UDim2.new(0, 18, 0.5, (-220 + (i - 1) * 140) * scale)
		end

		for _, v5 in ipairs({
			{ "CatalogButton", "98780419114971" },
			{ "CatelogButton", "115285162722758" }
		}) do
			local child2 = screenGui.Frame:FindFirstChild(v5[1])

			if not child2 then
				continue
			end

			local topPolish = child2.TopPolish
			local v6 = topPolish:FindFirstChild("FeatureIcon")

			if not v6 then
				v6 = Instance.new("ImageLabel")
				v6.Name = "FeatureIcon"
				v6.Parent = topPolish
			end

			v6.BackgroundTransparency = 1
			v6.Image = "rbxassetid://" .. v5[2]
			v6.ScaleType = Enum.ScaleType.Fit
			v6.AnchorPoint = Vector2.new(0.5, 0.5)
			v6.Position = UDim2.fromOffset(52, 48)

			if not child2:GetAttribute("FeatureHoverBound") then
				v6.Size = UDim2.fromOffset(80, 80)
			end

			v6.ZIndex = 7
			child2.NavTitle.Position = UDim2.fromOffset(104, 0)
			child2.NavTitle.Size = UDim2.new(1, -144, 1, 0)
			child2.NavTitle.TextXAlignment = Enum.TextXAlignment.Left
			child2.NavTitle.TextSize = 24
			local RunService = game:GetService("RunService")

			if not RunService:IsRunning() then
				continue
			end

			local RunService2 = game:GetService("RunService")

			if not RunService2:IsClient() or child2:GetAttribute("FeatureHoverBound") then
				continue
			end

			child2:SetAttribute("FeatureHoverBound", true)
			local v7 = nil
			local v8 = v6

			local function hover(p2)
				if game.Players.LocalPlayer:GetAttribute("MobileHUDActive") then
					return
				end

				if v7 then
					v7:Cancel()
				end

				local v9 = p2 and not game.Players.LocalPlayer:GetAttribute("ReducedMotion") and 94 or 80
				local TweenService = game:GetService("TweenService")
				v7 = TweenService:Create(v8, TweenInfo.new(0.15), {
					Size = UDim2.fromOffset(v9, v9)
				})
				v7:Play()
			end

			local hover2 = hover
			child2.MouseEnter:Connect(function()
				hover2(true)
			end)
			local hover3 = hover
			child2.MouseLeave:Connect(function()
				hover3(false)
			end)
		end

		local preferencesGui = instance:FindFirstChild("PreferencesGui")

		if preferencesGui then
			local settingsButton = preferencesGui.SettingsButton
			skin(settingsButton, "Settings", "81227607256600", Color3.fromRGB(173, 185, 210))
			settingsButton.AnchorPoint = Vector2.new(1, 1)
			settingsButton.Size = UDim2.fromOffset(132, 128)
			settingsButton.Position = UDim2.new(1, -18, 1, -18);
			(settingsButton:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", settingsButton)).Scale = scale
		end

		local uGCClaimGui = instance:FindFirstChild("UGCClaimGui")

		if uGCClaimGui then
			local coinHUD = uGCClaimGui.CoinHUD
			coinHUD.Size = UDim2.fromOffset(248, 78)
			coinHUD.AnchorPoint = Vector2.new(0, 1)
			coinHUD.Position = UDim2.new(0, 18, 1, -18 - scale * 58)
			local count = 0

			for _, uIScale in coinHUD:GetChildren() do
				if not uIScale:IsA("UIScale") then
					continue
				end

				count += 1
				uIScale.Scale = count == 1 and scale or 1
			end

			coinHUD.BackgroundColor3 = Color3.fromRGB(28, 31, 40)
			local v5 = coinHUD:FindFirstChild("GoldCoin")

			if not v5 then
				v5 = Instance.new("ImageLabel")
				v5.Name = "GoldCoin"
				v5.Parent = coinHUD
			end

			v5.BackgroundTransparency = 1
			v5.Image = "rbxassetid://102152720861132"
			v5.ScaleType = Enum.ScaleType.Fit
			v5.Position = UDim2.fromOffset(10, 13)
			v5.Size = UDim2.fromOffset(52, 52)
			coinHUD.Balance.Position = UDim2.fromOffset(72, 10)
			coinHUD.Balance.Size = UDim2.new(1, -82, 0, 28)
			coinHUD.Balance.Font = Enum.Font.GothamBold
			coinHUD.Balance.TextSize = 20
			coinHUD.Balance.TextXAlignment = Enum.TextXAlignment.Left
			coinHUD.Timer.Position = UDim2.fromOffset(72, 42)
			coinHUD.Timer.Size = UDim2.new(1, -80, 0, 24)
			coinHUD.Timer.TextSize = 15
			coinHUD.Timer.TextColor3 = Color3.fromRGB(235, 240, 250)
			coinHUD.Timer.TextXAlignment = Enum.TextXAlignment.Left
		end

		local leaderboardGui = instance:FindFirstChild("LeaderboardGui")

		if leaderboardGui then
			local leaderboardButton = leaderboardGui.LeaderboardButton
			leaderboardButton.Size = UDim2.fromOffset(248, 46)
			leaderboardButton.Position = UDim2.new(0, 18, 1, -18)
			local count = 0

			for _, uIScale in leaderboardButton:GetChildren() do
				if not uIScale:IsA("UIScale") then
					continue
				end

				count += 1
				uIScale.Scale = count == 1 and scale or 1
			end
		end
	end
}
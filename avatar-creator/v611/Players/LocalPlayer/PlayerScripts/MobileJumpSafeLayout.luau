local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local v = {}
local flag = false

local function set(p, p2, p3)
	if not p or p[p2] == p3 then
		return
	end

	local v2 = v[p]

	if not v2 then
		v2 = {}
		v[p] = v2
	end

	if v2[p2] == nil then
		v2[p2] = {
			value = p[p2]
		}
	end

	p[p2] = p3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function object(childName, childName2)
	local child = playerGui:FindFirstChild(childName)
	return child and child:FindFirstChild(childName2, true)
end

local function scaleOne(instance)
	for _, uIScale in instance:GetChildren() do
		if uIScale:IsA("UIScale") then
			set(uIScale, "Scale", 1)
		end
	end
end

local function place(instance, p, p2, p3, p4)
	if not (instance and instance.Parent) then
		return
	end

	scaleOne(instance)
	set(instance, "BackgroundTransparency", 0.28)

	for _, uIStroke in instance:GetChildren() do
		if uIStroke:IsA("UIStroke") then
			set(uIStroke, "Transparency", 0.65)
		end
	end

	set(instance, "AnchorPoint", Vector2.zero)
	set(instance, "Size", UDim2.fromOffset(p3, p4))
	local absolutePosition = instance.Parent.AbsolutePosition
	set(instance, "Position", UDim2.fromOffset(p - absolutePosition.X, p2 - absolutePosition.Y))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function text(p, p2)
	if not p then
		return
	end

	set(p, "TextSize", p2)
	set(p, "TextScaled", false)
	set(p, "TextWrapped", true)
end

local function iconButton(instance, p, p2, p3, p4, value, value2, p5)
	if not instance then
		return
	end

	place(instance, p, p2, p3, p4)
	local child = instance:FindFirstChild(value or "NavigationArt")

	if child then
		set(child, "AnchorPoint", Vector2.new(0.5, 0))
		set(child, "Position", UDim2.new(0.5, 0, 0, p4 <= 68 and 1 or 3))
		set(child, "Size", UDim2.fromOffset(p5, p5))
	end

	local child2 = instance:FindFirstChild(value2 or "NavigationCaption")

	if child2 then
		local v2

		if p4 <= 64 then
			v2 = 18
		elseif p4 <= 68 then
			v2 = 26
		elseif p4 < 80 then
			v2 = 26
		else
			v2 = 28
		end

		local v3

		if p4 <= 64 then
			v3 = 16
		elseif p4 <= 68 then
			v3 = 24
		elseif p4 < 80 then
			v3 = 24
		else
			v3 = 26
		end

		set(child2, "Position", UDim2.new(0, 4, 1, -v2))
		set(child2, "Size", UDim2.new(1, -8, 0, v3))
		text(child2, p3 <= 68 and 11 or 12) -- equivalent call inferred; original call site unknown
	end

	local uICorner = instance:FindFirstChildOfClass("UICorner")

	if uICorner then
		set(uICorner, "CornerRadius", UDim.new(0, 10))
	end
end

local function feature(instance, p, p2, p3, p4, p5)
	if not instance then
		return
	end

	place(instance, p, p2, p3, p4)
	local topPolish = instance:FindFirstChild("TopPolish")
	local featureIcon = topPolish and topPolish:FindFirstChild("FeatureIcon")

	if featureIcon then
		set(featureIcon, "AnchorPoint", Vector2.new(0, 0.5))
		set(featureIcon, "Position", UDim2.new(0, 8, 0.5, 0))
		set(featureIcon, "Size", UDim2.fromOffset(32, 32))
	end

	local arrow = topPolish and topPolish:FindFirstChild("Arrow")

	if arrow then
		set(arrow, "Visible", false)
	end

	local navTitle = instance:FindFirstChild("NavTitle")

	if navTitle then
		set(navTitle, "Position", UDim2.fromOffset(46, 0))
		set(navTitle, "Size", UDim2.new(1, p5 and -94 or -52, 1, 0))
		set(navTitle, "TextXAlignment", Enum.TextXAlignment.Left)
		text(navTitle, 14) -- equivalent call inferred; original call site unknown
	end

	local freeBadge = instance:FindFirstChild("FreeBadge")

	if freeBadge then
		set(freeBadge, "Visible", false)
	end

	local coinFAQ = instance:FindFirstChild("CoinFAQ")

	if coinFAQ then
		scaleOne(coinFAQ)
		set(coinFAQ, "AnchorPoint", Vector2.new(1, 0.5))
		set(coinFAQ, "Position", UDim2.new(1, -4, 0.5, 0))
		set(coinFAQ, "Size", UDim2.fromOffset(44, 44))
		text(coinFAQ, 18) -- equivalent call inferred; original call site unknown
	end
end

local function restore()
	for k, v2 in pairs(v) do
		if not k.Parent then
			continue
		end

		for k2, v3 in pairs(v2) do
			k[k2] = v3.value
		end
	end

	v = {}
end

local function layout()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	if UserInputService.TouchEnabled and (currentCamera.ViewportSize.X < 1400 or currentCamera.ViewportSize.Y < 800) then
		local screenGui = playerGui:FindFirstChild("ScreenGui")
		local uGCClaimGui = playerGui:FindFirstChild("UGCClaimGui")

		if not (screenGui and uGCClaimGui) then
			return
		end

		if not flag then
			flag = true
			localPlayer:SetAttribute("MobileHUDActive", true)
		end

		local absoluteSize = screenGui.AbsoluteSize
		local absolutePosition = screenGui.AbsolutePosition

		if absoluteSize.X < 1 or absoluteSize.Y < 1 then
			return
		end

		local X = absoluteSize.X
		local Y = absoluteSize.Y
		local v2 = X < Y
		local X2 = absolutePosition.X
		local Y2 = absolutePosition.Y
		local _ = v2 and Y < 680
		local catalogButton = screenGui.Frame:FindFirstChild("CatalogButton")
		local catelogButton = screenGui.Frame:FindFirstChild("CatelogButton")
		local v3 = object("GamepassStoreGui", "StoreButton") -- equivalent call inferred; original call site unknown
		local v4 = object("PreferencesGui", "SettingsButton") -- equivalent call inferred; original call site unknown
		local v5 = { screenGui:FindFirstChild("WearingButton"), screenGui:FindFirstChild("CommunityButton") }

		if v5[1] then
			set(v5[1]:FindFirstChild("NavigationCaption"), "Text", "Outfit")
		end

		local coinHUD = uGCClaimGui:FindFirstChild("CoinHUD")
		local v6 = object("GiveawayGui", "GiveawayButton") -- equivalent call inferred; original call site unknown
		local v7 = object("LeaderboardGui", "LeaderboardButton") -- equivalent call inferred; original call site unknown
		local v8 = not coinHUD and {} or {
			coinHUD:FindFirstChild("InviteFriends"),
			coinHUD:FindFirstChild("JoinGroup"),
			coinHUD:FindFirstChild("FavoriteReward")
		} or {}
		local v9, v10, v11, v12, v13, v14, v15

		if v2 then
			v9 = (X - 24) / 2
			feature(catalogButton, X2 + 8, Y2 + 4, v9, 44, false)
			feature(catelogButton, X2 + 16 + v9, Y2 + 4, v9, 44, true)
			v10 = X2 + 8
			v11 = Y2 + 54
			v12 = X2 + 16 + v9
			local v16 = { v5[2], v3 }
			local v17 = { v5[1], v4 }
			v13 = v9
			v14 = v11
			v15 = 44

			for i = 1, 2 do
				local v18 = Y2 + 106 + (i - 1) * 60

				for i2, v19 in ipairs({ v16, v17 }) do
					local v20 = v19[i]
					iconButton(
						v20,
						X2 + (i2 == 1 and 8 or X - 68 - 8),
						v18,
						68,
						54,
						v20 == v3 and "Icon" or nil,
						v20 == v3 and "Caption" or nil,
						32
					)
				end
			end

			local v18 = (X - 40) / 4
			place(v7, X2 + 8, Y2 + Y - 48, v18, 44)
			text(v7, 12) -- equivalent call inferred; original call site unknown

			for i, v19 in ipairs(v8) do
				place(v19, X2 + 8 + i * (v18 + 8), Y2 + Y - 48, v18, 44)
				text(v19, 12) -- equivalent call inferred; original call site unknown
			end
		else
			local v16 = 8
			local v17 = (X - 16 - 116 - 3 * v16) / 2
			feature(catalogButton, X2 + 8, Y2 + 2, v17, 44, false)
			feature(catelogButton, X2 + 16 + v17, Y2 + 2, v17, 44, true)
			local v18 = X2 + 8 + 2 * (v17 + v16)
			iconButton(v3, v18, Y2 + 2, 58, 44, "Icon", "Caption", 26)
			iconButton(v4, v18 + 58 + v16, Y2 + 2, 58, 44, nil, nil, 26)

			for i, v19 in ipairs(v5) do
				local v20 = i == 1 and 1 or 2
				local v21 = math.max(0, i - 2)
				iconButton(v19, X2 + (v20 == 1 and v21 * 76 + 8 or X - 76 - v21 * 76), Y2 + 54, 68, 54, nil, nil, 32)
			end

			local v19 = math.min(440, X - 204)
			local v20 = (X - v19) / 2
			v9 = v19 * 0.38
			v13 = v19 * 0.37
			local v21 = v19 - v9 - v13 - 16
			v10 = X2 + v20
			v11 = Y2 + Y - 94
			v12 = v10 + v9 + 8
			v15 = 44
			place(v7, v12 + v13 + 8, v11, v21, 44)
			text(v7, 12) -- equivalent call inferred; original call site unknown
			local v22 = (v19 - 16) / 3
			v14 = v11

			for i, v23 in ipairs(v8) do
				place(v23, X2 + v20 + (i - 1) * (v22 + 8), Y2 + Y - 46, v22, 44)
				text(v23, 12) -- equivalent call inferred; original call site unknown
			end
		end

		place(coinHUD, v10, v11, v9, v15)

		if coinHUD then
			local goldCoin = coinHUD:FindFirstChild("GoldCoin")

			if goldCoin then
				set(goldCoin, "Position", UDim2.fromOffset(6, 4))
				set(goldCoin, "Size", UDim2.fromOffset(24, 24))
			end

			local balance = coinHUD:FindFirstChild("Balance")

			if balance then
				set(balance, "Position", UDim2.fromOffset(34, 2))
				set(balance, "Size", UDim2.new(1, -38, 0, 22))
				text(balance, 15) -- equivalent call inferred; original call site unknown
			end

			local timer = coinHUD:FindFirstChild("Timer")

			if timer then
				set(timer, "Position", UDim2.fromOffset(6, v15 - 23))
				set(timer, "Size", UDim2.new(1, -12, 0, 22))
				text(timer, 12) -- equivalent call inferred; original call site unknown
			end
		end

		place(v6, v12, v14, v13, v15)

		if v6 then
			local title = v6:FindFirstChild("Title")

			if title then
				set(title, "Position", UDim2.fromOffset(6, 1))
				set(title, "Size", UDim2.new(1, -12, 0, 22))
				text(title, 15) -- equivalent call inferred; original call site unknown
			end

			local countdown = v6:FindFirstChild("Countdown")

			if countdown then
				set(countdown, "Position", UDim2.fromOffset(6, v15 - 23))
				set(countdown, "Size", UDim2.new(1, -12, 0, 22))
				text(countdown, 12) -- equivalent call inferred; original call site unknown
			end
		end
	elseif flag then
		flag = false
		localPlayer:SetAttribute("MobileHUDActive", false)
		restore()
		local IconNavigation = require(game.ReplicatedStorage.IconNavigation)
		IconNavigation.Apply(playerGui)
	end
end

RunService:BindToRenderStep("OrganizedMobileHUD", Enum.RenderPriority.Last.Value + 10, layout)
script.Destroying:Connect(function()
	RunService:UnbindFromRenderStep("OrganizedMobileHUD")

	if flag then
		localPlayer:SetAttribute("MobileHUDActive", false)
		restore()
	end
end)
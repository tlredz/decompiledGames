local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalizationService = game:GetService("LocalizationService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local v = require3("@game/ReplicatedStorage/Packages/Net")
local v2 = require3("@game/ReplicatedStorage/ClientGameModules/GuiHandler")
local v3 = require3("@game/ReplicatedStorage/ClientGameModules/UIHover")
local v4 = require3("@game/ReplicatedStorage/ClientGameModules/DeviceListener")
local v5 = require3("@game/ReplicatedStorage/Shared/ServerBrowserData")
local v6 = require3("@game/ReplicatedStorage/Shared/ServerRanking")
local v7 = require3("@game/ReplicatedStorage/Shared/ServerRanking/Config")
local v8 = require3("@game/ReplicatedStorage/Shared/GetServerType")
local v9 = require3("@game/ReplicatedStorage/Common/Utils")
local v10 = require3("@game/ReplicatedStorage/Shared/UniverseIds")
local v11 = require3("@game/ReplicatedStorage/Shared/UseNewServerBrowser")
local v12 = require3("@game/ReplicatedStorage/Controllers/PromptController")
local v13 = require3("@game/ReplicatedStorage/Controllers/NotificationController")
local v14 = require3("@game/ReplicatedStorage/Packages/Vide")
local v15 = require3("@self/Simulation")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local remoteEvent = v:RemoteEvent("ServerBrowserRankingSample")
local serverBrowser = playerGui:WaitForChild("ServerBrowser")
local main = serverBrowser:WaitForChild("Main")
local v16 = {
	{
		Name = "Recommended"
	},
	{
		Name = "Friends"
	},
	{
		Name = "Europe",
		Continent = "EU"
	},
	{
		Name = "N.America",
		Continent = "NA"
	},
	{
		Name = "Asia",
		Continent = "AS"
	},
	{
		Name = "Oceania",
		Continent = "OC"
	},
	{
		Name = "S.America",
		Continent = "SA"
	}
}
local v17 = {
	{
		Label = "Casual",
		ServerType = "Normal",
		PlaceKey = "Default"
	},
	{
		Label = "Ranked",
		ServerType = "Ranked",
		PlaceKey = "Ranked",
		FFlag = "RankedModeEnabled"
	},
	{
		Label = "Pro Server",
		ServerType = "Pro",
		PlaceKey = "Pro"
	},
	{
		Label = "Duels",
		ServerType = "Duel",
		PlaceKey = "Duel",
		FFlag = "DuelsEnabled"
	},
	{
		Label = "Trade Plaza",
		ServerType = "TradingPlaza",
		PlaceKey = "TradingPlaza",
		FFlag = "TradePlazaEnabled"
	},
	{
		Label = "Voice Chat",
		ServerType = "Voice",
		PlaceKey = "Voice"
	},
	{
		Label = "50 Players",
		ServerType = "Fifty",
		PlaceKey = "FiftyPlayers",
		FFlag = "FiftyPlayersEnabled"
	},
	{
		Label = "Mobile",
		ServerType = "Mobile",
		PlaceKey = "MobileServers"
	}
}
local isStudio = RunService:IsStudio()
local serversPerContinent = v5.ServersPerContinent
local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local color = Color3.fromRGB(90, 255, 120)
local color2 = Color3.fromRGB(255, 214, 90)
local color3 = Color3.fromRGB(255, 96, 96)
local color4 = Color3.fromRGB(255, 197, 71)
local latencyGoodMs = v7.Gates.LatencyGoodMs
local v18 = latencyGoodMs * 2
local tweenInfo4 = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo5 = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo6 = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo7 = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo8 = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local tweenInfo9 = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local source = v14.source
local effect = v14.effect
local apply = v14.apply
local v19 = source("Recommended")
local v20 = source("Casual")
local v21 = source("")
local v22 = source(0)
local v23 = source(10)
local servers = {}
local v24 = nil
local v25 = {}
local jobId = nil
local v26 = {}
local now = 0
local myCountry = "US"
local v28 = {}
local v29 = {}
local flag = false
local v30 = nil
local total = 60
local latestPlaceVersion = nil
local v31 = {}
local v32 = nil
local v33 = ""
local jobIds = {}
local v34 = ""
local v35 = -1
local v36 = {}
local serverBrowserFrom = nil
local v37 = 0
local oldBuildsExcluded = false
local updatedAt = 0
local count = 0
local counts = {}
local v38 = {}
local v39 = {}
local v40 = {}
local v41 = {}
local myPing = 0
local ServerBrowserController = {
	IsEnabled = function()
		return v11()
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function getPlainText(label)
	if label and label:IsA("TextLabel") then
		return (string.gsub(label.Text, "<[^>]->", ""))
	end

	return ""
end

local function bindSounds(p)
	p.MouseEnter:Connect(function()
		v3.Enter(nil)
	end)
	p.Activated:Connect(function()
		local click = ReplicatedStorage2.Misc:FindFirstChild("click")

		if click and click:IsA("Sound") then
			click:Play()
		end
	end)
end

local function enableButton(instance)
	instance.Active = true
	instance.Selectable = true

	if not instance:GetAttribute("SelectorSounds") then
		instance:SetAttribute("SelectorSounds", true)
		bindSounds(instance)
	end

	return instance
end

local function labelOf(instance)
	local label = instance:FindFirstChild("Label") or instance:FindFirstChildWhichIsA("TextLabel", true)

	if label and label:IsA("TextLabel") then
		return label
	end

	return nil
end

local function readLook(instance)
	local v43 = {
		Image = instance.Image,
		Hover = instance.HoverImage
	}
	local label = instance:FindFirstChild("Label") or instance:FindFirstChildWhichIsA("TextLabel", true)

	if not (label and label:IsA("TextLabel")) then
		label = nil
	end

	if not label then
		return v43
	end

	v43.TextColor = label.TextColor3
	local uIStroke = label:FindFirstChildWhichIsA("UIStroke")

	if uIStroke then
		v43.StrokeColor = uIStroke.Color
		v43.StrokeThickness = uIStroke.Thickness
		v43.StrokeTransparency = uIStroke.Transparency
	end

	return v43
end

local function paintSelection(buttonByLabel, flag2: boolean, list)
	local v43

	if flag2 then
		v43 = list[1]
	else
		v43 = list[2]
	end

	if not v43 then
		return
	end

	buttonByLabel.Image = v43.Image
	buttonByLabel.HoverImage = v43.Hover
	local label = buttonByLabel:FindFirstChild("Label") or buttonByLabel:FindFirstChildWhichIsA("TextLabel", true)

	if not (label and label:IsA("TextLabel")) then
		label = nil
	end

	if label then
		if v43.TextColor then
			label.TextColor3 = v43.TextColor
		end

		local uIStroke = label:FindFirstChildWhichIsA("UIStroke")

		if uIStroke and v43.StrokeColor then
			uIStroke.Color = v43.StrokeColor
			uIStroke.Thickness = v43.StrokeThickness or uIStroke.Thickness
			uIStroke.Transparency = v43.StrokeTransparency or uIStroke.Transparency
		end
	end

	buttonByLabel.Interactable = not flag2
end

local function scaleOf(parent)
	local uIScale = parent:FindFirstChildOfClass("UIScale")

	if uIScale then
		return uIScale
	end

	local uIScale2 = Instance.new("UIScale")
	uIScale2.Parent = parent
	return uIScale2
end

local function paintTab(buttonByLabel, flag2: boolean)
	local v43 = buttonByLabel:FindFirstChildOfClass("UIScale")

	if not v43 then
		v43 = Instance.new("UIScale")
		v43.Parent = buttonByLabel
	end

	local scale = flag2 and 1.08 or 1

	if v43.Scale ~= scale then
		TweenService:Create(v43, tweenInfo9, {
			Scale = scale
		}):Play()
	end

	buttonByLabel.Interactable = not flag2
end

local function asButton(button)
	if button:IsA("GuiButton") then
		button.Active = true
		button.Selectable = true

		if not button:GetAttribute("SelectorSounds") then
			button:SetAttribute("SelectorSounds", true)
			bindSounds(button)
		end

		return button
	else
		local guiButton = button:FindFirstChildWhichIsA("GuiButton", true)

		if not guiButton then
			return nil
		end

		guiButton.Active = true
		guiButton.Selectable = true

		if not guiButton:GetAttribute("SelectorSounds") then
			guiButton:SetAttribute("SelectorSounds", true)
			bindSounds(guiButton)
		end

		return guiButton
	end
end

local function findButtonByLabel(instance, list: string)
	local guiButton = nil

	for _, button in instance:GetChildren() do
		local label = button:FindFirstChild("Label") or button:FindFirstChildWhichIsA("TextLabel", true)
		local v43 = string.gsub(getPlainText(label), "^%s*(.-)%s*$", "%1")

		if v43 == list then
			if button:IsA("GuiButton") then
				button.Active = true
				button.Selectable = true

				if not button:GetAttribute("SelectorSounds") then
					button:SetAttribute("SelectorSounds", true)
					bindSounds(button)
				end

				return button
			else
				local guiButton2 = button:FindFirstChildWhichIsA("GuiButton", true)

				if not guiButton2 then
					return nil
				end

				guiButton2.Active = true
				guiButton2.Selectable = true

				if not guiButton2:GetAttribute("SelectorSounds") then
					guiButton2:SetAttribute("SelectorSounds", true)
					bindSounds(guiButton2)
				end

				return guiButton2
			end
		elseif not guiButton and string.sub(v43, 1, #list) == list then
			if button:IsA("GuiButton") then
				button.Active = true
				button.Selectable = true

				if not button:GetAttribute("SelectorSounds") then
					button:SetAttribute("SelectorSounds", true)
					bindSounds(button)
				end

				guiButton = button
			else
				guiButton = button:FindFirstChildWhichIsA("GuiButton", true)

				if guiButton then
					guiButton.Active = true
					guiButton.Selectable = true

					if not guiButton:GetAttribute("SelectorSounds") then
						guiButton:SetAttribute("SelectorSounds", true)
						bindSounds(guiButton)
					end
				else
					guiButton = nil
				end
			end
		end
	end

	return guiButton
end

local function pulseGlow(image)
	if image and image:IsA("ImageLabel") then
		TweenService:Create(image, tweenInfo3, {
			ImageTransparency = 0.65
		}):Play()
	end
end

local function qualityColor(flag2: boolean, flag3: boolean)
	if flag2 then
		return color
	end

	if flag3 then
		return color2
	end

	return color3
end

local function paintLabel(label, textColor: Color3?)
	if not (textColor and label and label:IsA("TextLabel")) then
		return
	end

	label.TextColor3 = textColor
	local uIStroke = label:FindFirstChildWhichIsA("UIStroke")

	if uIStroke then
		uIStroke.Color = textColor:Lerp(Color3.new(), 0.65)
	end
end

local function setText(instance, childName: string, text: string)
	if not instance then
		return
	end

	local guiObject = instance:FindFirstChild(childName, true)

	if guiObject and (guiObject:IsA("TextLabel") or guiObject:IsA("TextButton")) then
		apply(guiObject)({
			Text = text
		})
	end
end

local function replaceVisibleCount(text: string, p: number)
	local v43 = 1
	local v44 = {}

	while v43 <= #text do
		local v45 = string.find(text, "<", v43)

		if not v45 then
			table.insert(v44, (string.gsub(string.sub(text, v43), "%d+", tostring(p), 1)))
			break
		end

		local v46 = string.find(text, ">", v45) or #text
		table.insert(v44, (string.gsub(string.sub(text, v43, v45 - 1), "%d+", tostring(p), 1)))
		table.insert(v44, (string.sub(text, v45, v46)))
		v43 = v46 + 1
	end

	return table.concat(v44)
end

local function spinIcon(instance, flag2: boolean)
	if not instance then
		return
	end

	local icon = instance:FindFirstChild("Icon") or instance:FindFirstChildWhichIsA("ImageLabel")

	if icon and icon:IsA("GuiObject") then
		TweenService:Create(icon, tweenInfo, {
			Rotation = flag2 and 180 or 0
		}):Play()
	end
end

local function setDropdownOpen(instance, flag2: boolean)
	if instance.Visible == flag2 then
		return
	end

	if not instance:GetAttribute("OpenSize") then
		instance:SetAttribute("OpenSize", instance.Size)
		instance:SetAttribute("OpenPosition", instance.Position)
	end

	local openSize = instance:GetAttribute("OpenSize")
	local openPosition = instance:GetAttribute("OpenPosition")
	local v43 = openPosition.Y.Scale + openSize.Y.Scale
	local uDim = UDim2.fromScale(openSize.X.Scale, 0)
	local uDim2 = UDim2.fromScale(openPosition.X.Scale, v43)
	local guiObject = instance:FindFirstChildWhichIsA("GuiObject")
	local parent = instance.Parent

	if guiObject and parent and parent:IsA("GuiObject") and parent.AbsoluteSize.Y > 0 then
		guiObject.AnchorPoint = Vector2.new(0, 1)
		guiObject.Position = UDim2.fromScale(0, 1)
		guiObject.Size = UDim2.fromOffset(instance.AbsoluteSize.X, parent.AbsoluteSize.Y * openSize.Y.Scale)
	end

	instance.ClipsDescendants = true

	if flag2 then
		instance.Size = uDim
		instance.Position = uDim2
		instance.Visible = true
		TweenService:Create(instance, tweenInfo, {
			Size = openSize,
			Position = openPosition
		}):Play()
	else
		local tween = TweenService:Create(instance, tweenInfo, {
			Size = uDim,
			Position = uDim2
		})
		tween.Completed:Once(function()
			instance.Visible = false
			instance.Size = openSize
			instance.Position = openPosition
		end)
		tween:Play()
	end
end

local function reasonPanel()
	local serverInfo = main.Right.RankedReason:FindFirstChild("ServerInfo")

	if serverInfo and serverInfo:IsA("GuiObject") then
		return serverInfo
	end

	return nil
end

local function closeDropdowns(p)
	local modeSwitcher = main.Mode.ModeSwitcher

	if modeSwitcher ~= p and modeSwitcher.Visible then
		setDropdownOpen(modeSwitcher, false)
		spinIcon(main.Mode.Main, false)
	end

	local serverInfo = main.Right.RankedReason:FindFirstChild("ServerInfo")

	if not (serverInfo and serverInfo:IsA("GuiObject")) then
		serverInfo = nil
	end

	if serverInfo and serverInfo ~= p and serverInfo.Visible then
		setDropdownOpen(serverInfo, false)
		spinIcon(main.Right.RankedReason.Ranked, false)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setSwitcherOpen(flag2: boolean)
	if flag2 then
		closeDropdowns(main.Mode.ModeSwitcher)
	end

	setDropdownOpen(main.Mode.ModeSwitcher, flag2)
	spinIcon(main.Mode.Main, flag2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setFirstLabel(instance, formatted: string)
	if not instance then
		return
	end

	local textLabel = instance:FindFirstChildWhichIsA("TextLabel", true)

	if textLabel then
		apply(textLabel)({
			Text = formatted
		})
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getModeConfig(p: string)
	for _, v43 in v17 do
		if v43.Label == p then
			return v43
		end
	end

	return v17[1]
end

local function isModeAvailable(data)
	if data.ServerType == v8() then
		return true
	end

	if data.ServerType == "Mobile" then
		return v4:IsMobile()
	end

	if data.FFlag and v9.FFlag.GetInstantFFlag(data.FFlag, false) ~= true then
		return false
	end

	local v43

	if data.PlaceKey then
		v43 = v10[data.PlaceKey]
	end

	if not v43 then
		return true
	end

	local accessible = v43.Accessible

	if type(accessible) == "boolean" then
		return accessible
	end

	return type(accessible) ~= "function" or accessible(localPlayer) == true
end

local function refreshSwitcher()
	local v43 = {}

	for _, v44 in v17 do
		if isModeAvailable(v44) then
			table.insert(v43, v44)
		end
	end

	local v44 = math.min(#v43, #v36)

	if #v43 > #v36 then
		warn((`[ServerBrowser] switcher has {#v36} slots for {#v43} modes`))
	end

	local scale = main.Mode.ModeSwitcher.Main.Frame.UIListLayout.Padding.Scale
	local v45 = not (v44 > 0) and 0 or (1 - math.max(v44 - 1, 0) * scale) / v44

	for i = 1, v44 do
		local v46 = v36[i]
		local mode = v43[i]
		v46.Mode = mode
		v46.Holder.LayoutOrder = i
		v46.Holder.Visible = true
		v46.Holder.Size = UDim2.new(v46.Holder.Size.X.Scale, v46.Holder.Size.X.Offset, v45, 0)
		local button = v46.Button
		local label = button:FindFirstChild("Label") or button:FindFirstChildWhichIsA("TextLabel", true)

		if not (label and label:IsA("TextLabel")) then
			label = nil
		end

		if label then
			label.Text = mode.Label
		end
	end

	for i = v44 + 1, #v36 do
		local v46 = v36[i]
		v46.Mode = nil
		v46.Holder.Visible = false
		local button = v46.Button
		local label = button:FindFirstChild("Label") or button:FindFirstChildWhichIsA("TextLabel", true)

		if not (label and label:IsA("TextLabel")) then
			label = nil
		end

		if label then
			label.Text = ""
		end
	end

	local modeSwitcher = main.Mode.ModeSwitcher
	local fullSize = modeSwitcher:GetAttribute("FullSize")
	local fullPosition = modeSwitcher:GetAttribute("FullPosition")

	if not fullSize or not fullPosition or #v36 == 0 then
		return
	end

	local v46 = fullSize.Y.Scale * (v44 / #v36)
	local v47 = fullPosition.Y.Scale + fullSize.Y.Scale
	modeSwitcher:SetAttribute("OpenSize", UDim2.fromScale(fullSize.X.Scale, v46))
	modeSwitcher:SetAttribute("OpenPosition", UDim2.fromScale(fullPosition.X.Scale, v47 - v46))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getTabContinent(p: string)
	for _, v43 in v16 do
		if v43.Name == p then
			return v43.Continent
		end
	end

	return nil
end

local function getMyPing()
	return localPlayer:GetNetworkPing() * 1000
end

local function getEstimatedPing(p)
	local jobId2 = p.jobId
	local selected

	if jobId2 then
		selected = v40[jobId2]
	end

	if selected then
		return selected
	end

	local estimatedPing = v5.getEstimatedPing(
		myPing,
		myCountry,
		ReplicatedStorage2:GetAttribute("ServerCountryCode") or myCountry,
		p.country
	)

	if jobId2 then
		v40[jobId2] = estimatedPing
	end

	return estimatedPing
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hasPingEstimate(p)
	return v5.isLocated(myCountry) and v5.isLocated(p.country)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatPing(p)
	if not hasPingEstimate(p) then
		return "--"
	end

	local jobId2 = p.jobId
	local v44

	if jobId2 then
		v44 = v40[jobId2]
	end

	if not v44 then
		v44 = v5.getEstimatedPing(
			myPing,
			myCountry,
			ReplicatedStorage2:GetAttribute("ServerCountryCode") or myCountry,
			p.country
		)

		if jobId2 then
			v40[jobId2] = v44
		end
	end

	return (`{math.round(v44)}ms`)
end

local function getFriendsIn(p: string?)
	local v43

	if not p then
		return {}
	end

	v43 = v26[p]
	return v43 or {}
end

local v43 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveSimulatedIds(list)
	if #list == 0 then
		return
	end

	task.spawn(function()
		for _, v44 in list do
			if v43[v44] then
				continue
			end

			local success, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, Players, v44)
			v43[v44] = not success and 0 or userIdFromNameAsync
		end

		now = 0
		count += 1
		v22(count)
	end)
end

local function refreshFriends()
	if os.clock() - now < 45 then
		return
	end

	now = os.clock()

	if isStudio then
		v26 = {}
		local v44 = {}

		for k, v45 in v15.getFriends() do
			local v46 = {}

			for _, name in v45 do
				local v48 = v43[name]

				if not v48 then
					table.insert(v44, name)
				end

				table.insert(v46, {
					userId = v48 or 0,
					name = name
				})
			end

			v26[k] = v46
		end

		resolveSimulatedIds(v44) -- equivalent call inferred; original call site unknown
	else
		local success, friendsOnline = pcall(localPlayer.GetFriendsOnline, localPlayer, 200)

		if not success or type(friendsOnline) ~= "table" then
			return
		end

		v26 = {}

		for _, v44 in friendsOnline do
			local gameId = v44.GameId

			if not gameId then
				continue
			end

			local v45 = v26[gameId] or {}
			table.insert(v45, {
				userId = v44.VisitorId,
				name = v44.DisplayName or v44.UserName or "?"
			})
			v26[gameId] = v45
		end
	end
end

local function rankingContext(p)
	local v44 = {
		myPing = myPing,
		myCountry = myCountry,
		myServerCountry = ReplicatedStorage2:GetAttribute("ServerCountryCode") or myCountry,
		friendsInServer = 0,
		leftSecondsAgo = 0,
		latestPlaceVersion = 0,
		oldBuildsExcluded = 0
	}
	local jobId2 = p.jobId
	v44.friendsInServer = #(not jobId2 and {} or v26[jobId2] or {})
	local leftSecondsAgo

	if serverBrowserFrom and p.jobId == serverBrowserFrom then
		leftSecondsAgo = os.time() - v37
	end

	v44.leftSecondsAgo = leftSecondsAgo
	v44.latestPlaceVersion = latestPlaceVersion
	v44.oldBuildsExcluded = oldBuildsExcluded
	return v44
end

local function getBreakdown(p)
	local jobId2 = p.jobId
	local selected

	if jobId2 then
		selected = v39[jobId2]
	end

	if selected then
		return selected
	end

	local score = v6.score(p, (rankingContext(p)))

	if jobId2 then
		v39[jobId2] = score
	end

	return score
end

local function getMatchScore(p)
	local jobId2 = p.jobId
	local v44

	if jobId2 then
		v44 = v39[jobId2]
	end

	if not v44 then
		v44 = v6.score(p, (rankingContext(p)))

		if jobId2 then
			v39[jobId2] = v44
		end
	end

	return v44.Score
end

local function isPoorQuality(data)
	local v44 = true
	local jobId2 = data.jobId
	local v45

	if jobId2 then
		v45 = v40[jobId2]
	end

	if not v45 then
		v45 = v5.getEstimatedPing(
			myPing,
			myCountry,
			ReplicatedStorage2:GetAttribute("ServerCountryCode") or myCountry,
			data.country
		)

		if jobId2 then
			v40[jobId2] = v45
		end
	end

	if not (v45 > 200) then
		return data.fps < 40 or data.memMb > 6500
	end

	return v44
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isJoinable(data)
	if data.jobId == game.JobId or data.players >= data.maxPlayers or data.flags.ShuttingDown or os.time() - data.lastUpdate > v5.StaleAfterSeconds then
		return false
	end

	return true
end

local function isJoinCandidate(data)
	local jobId2 = data.jobId

	if not jobId2 then
		return false
	end

	local v44 = v41[jobId2]

	if v44 ~= nil then
		return v44
	end

	local v45 = v6.isEligible(data, (rankingContext(data))) and isJoinable(data)
	v41[jobId2] = v45
	return v45
end

local function isListed(data, p: string)
	local jobId2 = data.jobId
	local v44

	if jobId2 then
		v44 = v41[jobId2]

		if v44 == nil then
			v44 = v6.isEligible(data, (rankingContext(data))) and isJoinable(data)
			v41[jobId2] = v44
		end
	else
		v44 = false
	end

	if not v44 then
		return false
	end

	if p == "Friends" then
		local jobId3 = data.jobId
		return #(not jobId3 and {} or v26[jobId3] or {}) > 0
	end

	local tabContinent = getTabContinent(p) -- equivalent call inferred; original call site unknown
	return tabContinent == nil or v5.getContinent(data.country) == tabContinent
end

local function countListed(p: string)
	local count2 = 0

	for _, v44 in servers do
		local jobId2 = v44.jobId
		local v45

		if jobId2 then
			v45 = v41[jobId2]

			if v45 == nil then
				v45 = v6.isEligible(v44, (rankingContext(v44))) and isJoinable(v44)
				v41[jobId2] = v45
			end
		else
			v45 = false
		end

		local v46

		if v45 then
			if p == "Friends" then
				local jobId3 = v44.jobId
				v46 = #(not jobId3 and {} or v26[jobId3] or {}) > 0
			else
				local tabContinent = getTabContinent(p) -- equivalent call inferred; original call site unknown

				if tabContinent == nil then
					v46 = true
				elseif v5.getContinent(v44.country) == tabContinent then
					v46 = true
				else
					v46 = false
				end
			end
		else
			v46 = false
		end

		if v46 then
			count2 += 1
		end
	end

	return count2
end

local function getVisibleServers()
	local v44 = v19()
	local v45 = string.lower(v21())
	local v46 = {}
	local result = {}

	for _, v47 in servers do
		local jobId2 = v47.jobId
		local v48

		if jobId2 then
			v48 = v41[jobId2]

			if v48 == nil then
				v48 = v6.isEligible(v47, (rankingContext(v47))) and isJoinable(v47)
				v41[jobId2] = v48
			end
		else
			v48 = false
		end

		local v49

		if v48 then
			if v44 == "Friends" then
				local jobId3 = v47.jobId
				v49 = #(not jobId3 and {} or v26[jobId3] or {}) > 0
			else
				local tabContinent = getTabContinent(v44) -- equivalent call inferred; original call site unknown

				if tabContinent == nil then
					v49 = true
				elseif v5.getContinent(v47.country) == tabContinent then
					v49 = true
				else
					v49 = false
				end
			end
		else
			v49 = false
		end

		if not v49 or v46[v47.jobId] then
			continue
		end

		v46[v47.jobId] = true

		if v45 ~= "" then
			local v50 = string.lower((`{v47.region} {v47.country} {v5.getDisplayName(v47.country)}`))

			if not string.find(v50, v45, 1, true) then
				continue
			end
		end

		table.insert(result, v47)
	end

	local function ordered(p, p2, p3: number, p4: number)
		if p3 == p4 then
			return p.jobId < p2.jobId
		end

		return p4 < p3
	end

	if v44 == "Friends" then
		table.sort(result, function(a, b)
			local jobId2 = a.jobId
			local count2 = #(not jobId2 and {} or v26[jobId2] or {})
			local jobId3 = b.jobId
			local count3 = #(not jobId3 and {} or v26[jobId3] or {})

			if count2 ~= count3 then
				return count3 < count2
			end

			local jobId4 = a.jobId
			local v47

			if jobId4 then
				v47 = v39[jobId4]
			end

			if not v47 then
				v47 = v6.score(a, (rankingContext(a)))

				if jobId4 then
					v39[jobId4] = v47
				end
			end

			local score = v47.Score
			local jobId5 = b.jobId
			local v48

			if jobId5 then
				v48 = v39[jobId5]
			end

			if not v48 then
				v48 = v6.score(b, (rankingContext(b)))

				if jobId5 then
					v39[jobId5] = v48
				end
			end

			local score2 = v48.Score

			if score == score2 then
				return a.jobId < b.jobId
			end

			return score2 < score
		end)
	elseif v44 == "Recommended" then
		table.sort(result, function(a, b)
			local jobId2 = a.jobId
			local v47

			if jobId2 then
				v47 = v39[jobId2]
			end

			if not v47 then
				v47 = v6.score(a, (rankingContext(a)))

				if jobId2 then
					v39[jobId2] = v47
				end
			end

			local score = v47.Score
			local jobId3 = b.jobId
			local v48

			if jobId3 then
				v48 = v39[jobId3]
			end

			if not v48 then
				v48 = v6.score(b, (rankingContext(b)))

				if jobId3 then
					v39[jobId3] = v48
				end
			end

			local score2 = v48.Score

			if score == score2 then
				return a.jobId < b.jobId
			end

			return score2 < score
		end)
	else
		table.sort(result, function(a, b)
			local jobId2 = a.jobId
			local v47

			if jobId2 then
				v47 = v40[jobId2]
			end

			if not v47 then
				v47 = v5.getEstimatedPing(
					myPing,
					myCountry,
					ReplicatedStorage2:GetAttribute("ServerCountryCode") or myCountry,
					a.country
				)

				if jobId2 then
					v40[jobId2] = v47
				end
			end

			local v48 = -v47
			local jobId3 = b.jobId
			local v49

			if jobId3 then
				v49 = v40[jobId3]
			end

			if not v49 then
				v49 = v5.getEstimatedPing(
					myPing,
					myCountry,
					ReplicatedStorage2:GetAttribute("ServerCountryCode") or myCountry,
					b.country
				)

				if jobId3 then
					v40[jobId3] = v49
				end
			end

			local v50 = -v49

			if v48 == v50 then
				return a.jobId < b.jobId
			end

			return v50 < v48
		end)
	end

	local v47

	if v44 == "Friends" then
		v47 = 8
	elseif v44 == "Recommended" then
		v47 = 6
	else
		v47 = v23()
	end

	while v47 < #result do
		table.remove(result)
	end

	if v44 == "Recommended" then
		for _, v49 in servers do
			if v49.jobId ~= game.JobId then
				continue
			end

			table.insert(result, v49)
			break
		end
	end

	if v44 ~= "Recommended" or not (#result > 1) then
		return result
	end

	local formatted = `{v44}|{v20()}`

	if v33 ~= formatted then
		v32 = nil
		v33 = formatted
	end

	local v48 = nil

	for k, v50 in result do
		if v50.jobId ~= v32 then
			continue
		end

		v48 = k
		break
	end

	if not v48 then
		local v50 = {}

		for _, v51 in result do
			local v52 = {
				jobId = v51.jobId,
				score = 0
			}
			local jobId2 = v51.jobId
			local v53

			if jobId2 then
				v53 = v39[jobId2]
			end

			if not v53 then
				v53 = v6.score(v51, (rankingContext(v51)))

				if jobId2 then
					v39[jobId2] = v53
				end
			end

			v52.score = v53.Score
			table.insert(v50, v52)
		end

		v32 = v6.pickHero(v50, localPlayer.UserId)

		for k, v52 in result do
			if v52.jobId ~= v32 then
				continue
			end

			v48 = k
			break
		end
	end

	if v48 and v48 > 1 then
		table.insert(result, 1, table.remove(result, v48))
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isRoundless(p)
	return p.serverType == "TradingPlaza" or p.serverType == "ProTradingPlaza"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isDuel(p)
	return p.serverType == "Duel" or p.maxPlayers <= 2
end

local function formatStatus(data)
	if isRoundless(data) then
		return "OPEN", color
	end

	if data.roundSeconds > 0 then
		if isDuel(data) then
			return "IN DUEL", color2
		end

		return string.format("IN ROUND: %d:%02d", data.roundSeconds // 60, data.roundSeconds % 60), color2
	else
		return "LOBBY", color
	end
end

local function formatMemory(p)
	if p.memMb == 0 then
		return "Unknown", nil
	end

	local v44 = p.memMb < 4000
	local v45 = p.memMb < 7000
	local v46 = v44 and "Good" or v45 and "Fair" or "Poor"

	if v44 then
		return v46, color
	end

	if v45 then
		return v46, color2
	end

	return v46, color3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pingColor(p)
	if not hasPingEstimate(p) then
		return nil
	end

	local jobId2 = p.jobId
	local v44

	if jobId2 then
		v44 = v40[jobId2]
	end

	if not v44 then
		v44 = v5.getEstimatedPing(
			myPing,
			myCountry,
			ReplicatedStorage2:GetAttribute("ServerCountryCode") or myCountry,
			p.country
		)

		if jobId2 then
			v40[jobId2] = v44
		end
	end

	local v45 = v44 <= latencyGoodMs
	local v46 = v44 <= v18

	if v45 then
		return color
	end

	if v46 then
		return color2
	end

	return color3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fpsColor(fps: number)
	local v44 = v7.Performance.FpsGood <= fps
	local v45 = v7.Performance.FpsBad <= fps

	if v44 then
		return color
	end

	if v45 then
		return color2
	end

	return color3
end

local function getCurrentSnapshot()
	local serverFps = ReplicatedStorage2:GetAttribute("ServerFps")
	return {
		country = ReplicatedStorage2:GetAttribute("ServerCountryCode") or myCountry,
		region = ReplicatedStorage2:GetAttribute("ServerRegionCode") or "???",
		players = #Players:GetPlayers(),
		maxPlayers = Players.MaxPlayers,
		fps = serverFps or total
	}
end

local function isBetterThanCurrent(data)
	local jobId2 = data.jobId
	local v44

	if jobId2 then
		v44 = v41[jobId2]

		if v44 == nil then
			v44 = v6.isEligible(data, (rankingContext(data))) and isJoinable(data)
			v41[jobId2] = v44
		end
	else
		v44 = false
	end

	if not v44 then
		return false
	end

	local v45 = v24

	if not v45 then
		return false
	end

	local jobId3 = data.jobId
	local v46

	if jobId3 then
		v46 = v40[jobId3]
	end

	if not v46 then
		v46 = v5.getEstimatedPing(
			myPing,
			myCountry,
			ReplicatedStorage2:GetAttribute("ServerCountryCode") or myCountry,
			data.country
		)

		if jobId3 then
			v40[jobId3] = v46
		end
	end

	local jobId4 = v45.jobId
	local v47

	if jobId4 then
		v47 = v40[jobId4]
	end

	if not v47 then
		v47 = v5.getEstimatedPing(
			myPing,
			myCountry,
			ReplicatedStorage2:GetAttribute("ServerCountryCode") or myCountry,
			v45.country
		)

		if jobId4 then
			v40[jobId4] = v47
		end
	end

	if v47 < v46 or data.fps < v45.fps then
		return false
	end

	local jobId5 = data.jobId
	local v48

	if jobId5 then
		v48 = v39[jobId5]
	end

	if not v48 then
		v48 = v6.score(data, (rankingContext(data)))

		if jobId5 then
			v39[jobId5] = v48
		end
	end

	local score = v48.Score
	local jobId6 = v45.jobId
	local v49

	if jobId6 then
		v49 = v39[jobId6]
	end

	if not v49 then
		v49 = v6.score(v45, (rankingContext(v45)))

		if jobId6 then
			v39[jobId6] = v49
		end
	end

	return v49.Score < score
end

function ServerBrowserController:Join(p: string, p2: number)
	if p == game.JobId then
		return
	end

	local v44 = v28[p]

	if v44 then
		local joining = v44:FindFirstChild("Joining", true)

		if joining then
			joining.Visible = true
		end

		local join = v44:FindFirstChild("Join", true)

		if join then
			join.Visible = false
		end
	end

	if isStudio then
		print((`[ServerBrowser] {v15.describeJoin(p, servers)}`))
		task.wait(1)
		local joining = v44 and v44:FindFirstChild("Joining", true)

		if joining then
			joining.Visible = false
		end

		v2:Close("ServerBrowser", true)
	else
		local success, result = pcall(function()
			return v:Invoke("ServerBrowserTeleport", p, p2)
		end)

		if success and result == true then
			return
		end

		local joining = v44 and v44:FindFirstChild("Joining", true)

		if joining then
			joining.Visible = false
		end

		local v45 = false

		for _, v46 in v25 do
			if v46.jobId == p then
				v45 = true
			elseif v45 and v46.jobId ~= game.JobId then
				self:Join(v46.jobId, v46.placeId)
				return
			end
		end
	end
end

local function bindJoin(clone, _)
	local template = clone:FindFirstChild("Template") or clone
	local join = template:FindFirstChild("Join")
	local template2 = main.Left.LeftBg.ScrollingFrame.Selected.Template

	if not join then
		local join2 = template2:FindFirstChild("Join")

		if join2 then
			join = join2:Clone()
			join.Parent = template
		end
	end

	if not join then
		return
	end

	if join:IsA("GuiButton") then
		join.Active = true
		join.Selectable = true

		if not join:GetAttribute("SelectorSounds") then
			join:SetAttribute("SelectorSounds", true)
			bindSounds(join)
		end
	else
		join = join:FindFirstChildWhichIsA("GuiButton", true)

		if join then
			join.Active = true
			join.Selectable = true

			if not join:GetAttribute("SelectorSounds") then
				join:SetAttribute("SelectorSounds", true)
				bindSounds(join)
			end
		else
			join = nil
		end
	end

	if not join then
		return
	end

	join.Activated:Connect(function()
		local v44 = v29[clone]

		if not v44 then
			return
		end

		v12:CreatePrompt({
			PromptType = "Accept",
			Description = `Join {v5.getDisplayName(v44.country)}, {v44.players}/{v44.maxPlayers} players?`,
			AcceptButtonText = "Join",
			DeclineButtonText = "Cancel"
		}, function(flag2: boolean)
			if flag2 then
				ServerBrowserController:Join(v44.jobId, v44.placeId)
			end
		end)
	end)
end

local function highlightOf(instance)
	local template = instance:FindFirstChild("Template") or instance
	local selected = template:FindFirstChild("Selected")

	if not selected then
		local selected2 = main.Left.LeftBg.ScrollingFrame.Selected.Template:FindFirstChild("Selected")

		if not selected2 then
			return nil
		end

		selected = selected2:Clone()
		selected.Parent = template
	end

	if not selected:IsA("ImageLabel") then
		return nil
	end

	if not selected:GetAttribute("SelectorHighlight") then
		selected:SetAttribute("SelectorHighlight", true)
		selected.ImageTransparency = 1
		selected.Visible = true
	end

	return selected
end

local function bannerOf(instance)
	local template = instance:FindFirstChild("Template") or instance
	local bestMatch = template:FindFirstChild("Best Match", true)

	if not bestMatch then
		local bestMatch2 = main.Left.LeftBg.ScrollingFrame.Selected.Template:FindFirstChild("Best Match")

		if not bestMatch2 then
			return nil
		end

		bestMatch = bestMatch2:Clone()
		bestMatch.Parent = template
		local mode = template:FindFirstChild("Mode")

		if mode and mode:IsA("GuiObject") and bestMatch:IsA("GuiObject") then
			bestMatch.Position = UDim2.fromScale(
				mode.Position.X.Scale,
				(math.max(0, mode.Position.Y.Scale - bestMatch.Size.Y.Scale))
			)
		end
	end

	if bestMatch:IsA("TextLabel") then
		return bestMatch
	end

	return nil
end

local function paintRankBox(instance, flag2: boolean)
	local rank = (instance:FindFirstChild("Template") or instance):FindFirstChild("Rank")
	local imageLabel

	if rank then
		imageLabel = rank:FindFirstChildWhichIsA("ImageLabel")
	else
		imageLabel = nil
	end

	if not imageLabel then
		return
	end

	local image = flag2 and "rbxassetid://107894640126789" or "rbxassetid://110487141601381"

	if imageLabel:GetAttribute("RankBox") == image then
		return
	end

	local v45 = imageLabel:GetAttribute("RankBox") == nil
	imageLabel:SetAttribute("RankBox", image)

	if v45 then
		imageLabel.Image = image
		return
	end

	local tween = TweenService:Create(imageLabel, tweenInfo6, {
		ImageTransparency = 1
	})
	tween.Completed:Once(function()
		imageLabel.Image = imageLabel:GetAttribute("RankBox")
		TweenService:Create(imageLabel, tweenInfo6, {
			ImageTransparency = 0
		}):Play()
	end)
	tween:Play()
end

local function bindSelect(clone)
	local template = clone:FindFirstChild("Template") or clone

	if not template:IsA("GuiObject") then
		return
	end

	template.Active = true
	template.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local v44 = v29[clone]

		if not v44 or v44.jobId == jobId then
			return
		end

		jobId = v44.jobId
		count += 1
		v22(count)
	end)
end

local function bindCardHover(clone)
	local template = clone:FindFirstChild("Template")

	if not (template and template:IsA("GuiObject")) then
		return
	end

	local v44 = template:FindFirstChildOfClass("UIScale")

	if not v44 then
		v44 = Instance.new("UIScale")
		v44.Parent = template
	end

	template.MouseEnter:Connect(function()
		TweenService:Create(v44, tweenInfo4, {
			Scale = 1.02
		}):Play()
	end)
	template.MouseLeave:Connect(function()
		TweenService:Create(v44, tweenInfo4, {
			Scale = 1
		}):Play()
	end)
end

local function paintRow(clone, data, k: number)
	local template = clone:FindFirstChild("Template") or clone
	local v44 = v5.getContinent(data.country) or data.region
	v29[clone] = data
	setText(template, "Mode", `{v20()} - {v5.getDisplayName(data.country)}`)
	setText(template, "Players", `Players {data.players}/{data.maxPlayers} - {v44}`)
	local v45, v46

	if isRoundless(data) then
		v45 = color
		v46 = "OPEN"
	elseif data.roundSeconds > 0 then
		if isDuel(data) then
			v45 = color2
			v46 = "IN DUEL"
		else
			v46 = string.format("IN ROUND: %d:%02d", data.roundSeconds // 60, data.roundSeconds % 60)
			v45 = color2
		end
	else
		v45 = color
		v46 = "LOBBY"
	end

	setText(template, "Countdown", v46)
	paintLabel(template:FindFirstChild("Countdown", true), v45)
	local ping = template:FindFirstChild("Ping")
	local fps = template:FindFirstChild("Fps")
	local text = formatPing(data) -- equivalent call inferred; original call site unknown
	setText(ping, "Amount", text)
	setText(fps, "Amount", string.format("%.1f", data.fps))
	setText(template:FindFirstChild("Rank"), "#1", `#{k}`)
	local amount

	if ping then
		amount = ping:FindFirstChild("Amount", true)
	end

	local textColor = pingColor(data) -- equivalent call inferred; original call site unknown
	paintLabel(amount, textColor)
	local amount2

	if fps then
		amount2 = fps:FindFirstChild("Amount", true)
	end

	local textColor2 = fpsColor(data.fps) -- equivalent call inferred; original call site unknown
	paintLabel(amount2, textColor2)
	local v54 = data.jobId == game.JobId
	local v55

	if v19() == "Friends" then
		v55 = true
		local jobId2 = data.jobId
		local v56

		if jobId2 then
			v56 = v40[jobId2]
		end

		if not v56 then
			v56 = v5.getEstimatedPing(
				myPing,
				myCountry,
				ReplicatedStorage2:GetAttribute("ServerCountryCode") or myCountry,
				data.country
			)

			if jobId2 then
				v40[jobId2] = v56
			end
		end

		if not (v56 > 200) then
			v55 = data.fps < 40 or data.memMb > 6500
		end
	else
		v55 = false
	end

	local v56 = not v54

	if v56 then
		if k == 1 then
			v56 = false
		else
			v56 = isBetterThanCurrent(data)
		end
	end

	local text2

	if v54 then
		text2 = "You are here"
	elseif v55 then
		text2 = "Join anyway"
	elseif k == 1 then
		text2 = "Best Match"
	elseif v56 then
		text2 = "Better Server"
	else
		text2 = ""
	end

	local v58 = bannerOf(clone)

	if v58 then
		v58.Text = text2
		v58.Visible = text2 ~= ""
		local color5

		if v54 then
			color5 = Color3.fromRGB(190, 200, 215)
		elseif v55 then
			color5 = Color3.fromRGB(255, 170, 60)
		elseif v56 then
			color5 = color4
		else
			color5 = color
		end

		paintLabel(v58, color5)
	end

	if template:IsA("ImageLabel") then
		template.ImageTransparency = v54 and 0.45 or 0
	end

	local join = template:FindFirstChild("Join")

	if join then
		join.Visible = not v54
	end

	local joining = template:FindFirstChild("Joining")

	if joining then
		joining.Visible = false
	end

	local v59 = data.jobId == jobId
	local v60 = highlightOf(clone)

	if v60 then
		local imageTransparency = v59 and 0 or 1

		if v60.ImageTransparency ~= imageTransparency then
			TweenService:Create(v60, tweenInfo5, {
				ImageTransparency = imageTransparency
			}):Play()
		end
	end

	paintRankBox(clone, v59)
end

local function renderReason(data, data2)
	local list = main.Right.RankedReason.ServerInfo.Main.List
	local jobId2 = data.jobId
	local v44 = #(not jobId2 and {} or v26[jobId2] or {})
	local amount = formatPing(data) -- equivalent call inferred; original call site unknown
	local v46 = {
		Title = "PING",
		Amount = amount,
		Value = data2.Latency
	}
	local v48 = {
		Title = "FPS",
		Amount = string.format("%.1f", data.fps),
		Value = data2.Performance
	}
	local amount2

	if data.memMb == 0 then
		amount2 = "Unknown"
	else
		local v51 = data.memMb < 4000
		local v52 = data.memMb < 7000
		amount2 = v51 and "Good" or v52 and "Fair" or "Poor"
	end

	local v45 = {
		v46,
		v48,
		{
			Title = "MEMORY",
			Amount = amount2,
			Value = data2.Memory
		},
		{
			Title = "STABILITY",
			Amount = `{math.round(data2.Stability * 100)}%`,
			Value = data2.Stability
		},
		{
			Title = "PLAYERS",
			Amount = `{data.players}/{data.maxPlayers}`,
			Value = data2.Population
		},
		{
			Title = "FRIENDS",
			Amount = tostring(v44),
			Value = data2.Social
		}
	}
	local count2 = 0

	for _, guiObject in list:GetChildren() do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		count2 += 1
		local v51 = v45[count2]
		guiObject.Visible = v51 ~= nil

		if not v51 then
			continue
		end

		guiObject.LayoutOrder = count2
		setText(guiObject, "TItle", v51.Title)
		setText(guiObject, "Amount", v51.Amount)
		local progressBar = guiObject:FindFirstChild("ProgressBar")
		local fill = progressBar and progressBar:FindFirstChild("Fill")

		if fill and fill:IsA("GuiObject") then
			TweenService:Create(fill, tweenInfo, {
				Size = UDim2.new(math.clamp(v51.Value, 0, 1), 0, 1, 0)
			}):Play()
		end
	end
end

local function renderFriendAvatars(p)
	local count2 = 0

	for _, guiObject in main.Right.Players.Players:GetChildren() do
		local icon = guiObject:FindFirstChild("Icon", true)

		if not (guiObject:IsA("GuiObject") and icon and icon:IsA("ImageLabel")) then
			continue
		end

		count2 += 1
		local v44 = p[count2]
		guiObject.Visible = v44 ~= nil

		if v44 then
			icon.Image = `rbxthumb://type=AvatarBust&id={v44.userId}&w=100&h=100`
		end
	end
end

local function setBestMatchBadge(shown: boolean)
	local bestMatch = main.Right.BestMatch

	if bestMatch:GetAttribute("Shown") == shown then
		return
	end

	bestMatch:SetAttribute("Shown", shown)
	local v44 = bestMatch:FindFirstChildOfClass("UIScale")

	if not v44 then
		v44 = Instance.new("UIScale")
		v44.Parent = bestMatch
	end

	local v45 = shown and 0 or 1
	local v46

	if shown then
		v46 = tweenInfo7
	else
		v46 = tweenInfo8
	end

	if shown then
		bestMatch.Visible = true
		v44.Scale = 0.7
	end

	local tween = TweenService:Create(v44, v46, {
		Scale = shown and 1 or 0.86
	})

	if not shown then
		tween.Completed:Once(function()
			if bestMatch:GetAttribute("Shown") == false then
				bestMatch.Visible = false
			end
		end)
	end

	tween:Play()

	for _, descendant in bestMatch:GetDescendants() do
		if descendant:IsA("ImageLabel") then
			TweenService:Create(descendant, v46, {
				ImageTransparency = v45
			}):Play()
		elseif descendant:IsA("TextLabel") then
			TweenService:Create(descendant, v46, {
				TextTransparency = v45
			}):Play()
		elseif descendant:IsA("UIStroke") then
			TweenService:Create(descendant, v46, {
				Transparency = v45
			}):Play()
		end
	end
end

local function renderDetail()
	local v44 = nil

	for _, v46 in v25 do
		if v46.jobId ~= jobId then
			continue
		end

		v44 = v46
		break
	end

	local right = main.Right
	right.Visible = v44 ~= nil

	if not v44 then
		return
	end

	setBestMatchBadge(v25[1] ~= nil and v25[1].jobId == jobId)
	local currentSnapshot = getCurrentSnapshot()
	local jobId2 = v44.jobId
	local v48

	if jobId2 then
		v48 = v40[jobId2]
	end

	if not v48 then
		v48 = v5.getEstimatedPing(
			myPing,
			myCountry,
			ReplicatedStorage2:GetAttribute("ServerCountryCode") or myCountry,
			v44.country
		)

		if jobId2 then
			v40[jobId2] = v48
		end
	end

	local jobId3 = v44.jobId
	local v49

	if jobId3 then
		v49 = v39[jobId3]
	end

	if not v49 then
		v49 = v6.score(v44, (rankingContext(v44)))

		if jobId3 then
			v39[jobId3] = v49
		end
	end

	setText(right.Top, "Mode", `{v20()} - {v5.getDisplayName(v44.country)}`)
	setText(right.Top, "Server", `{v5.getContinent(v44.country) or v44.region} - v{v44.placeVersion}`)
	local grid = right.Grid
	local v50, v51

	if v44.memMb == 0 then
		v50 = "Unknown"
	else
		local v52 = v44.memMb < 4000
		local v53 = v44.memMb < 7000
		v50 = v52 and "Good" or v53 and "Fair" or "Poor"

		if v52 then
			v51 = color
		elseif v53 then
			v51 = color2
		else
			v51 = color3
		end
	end

	local v52, v53

	if isRoundless(v44) then
		v52 = color
		v53 = "OPEN"
	elseif v44.roundSeconds > 0 then
		if isDuel(v44) then
			v52 = color2
			v53 = "IN DUEL"
		else
			v53 = string.format("IN ROUND: %d:%02d", v44.roundSeconds // 60, v44.roundSeconds % 60)
			v52 = color2
		end
	else
		v52 = color
		v53 = "LOBBY"
	end

	local ping = grid.Ping
	local text = formatPing(v44) -- equivalent call inferred; original call site unknown
	setText(ping, "Label2", text)
	setText(grid.Fps, "Label2", string.format("%.2f", v44.fps))
	setText(grid.Players, "Label2", `{v44.players}/{v44.maxPlayers}`)
	setText(grid.InRound, "Label2", v53)
	setText(grid.Memory, "Label2", v50)
	setText(grid.Build, "Label2", `V{v44.placeVersion}`)
	local label2 = grid.Ping:FindFirstChild("Label2", true)
	local textColor = pingColor(v44) -- equivalent call inferred; original call site unknown
	paintLabel(label2, textColor)
	local label22 = grid.Fps:FindFirstChild("Label2", true)
	local textColor2 = fpsColor(v44.fps) -- equivalent call inferred; original call site unknown
	paintLabel(label22, textColor2)
	paintLabel(grid.Memory:FindFirstChild("Label2", true), v51)
	paintLabel(grid.InRound:FindFirstChild("Label2", true), v52)
	setText(right.Top.MatchScore, "Amount", tostring((math.round(v49.Score * 100))))
	local description = right.Description
	setText(
		description,
		"Fps",
		not (currentSnapshot.fps > 0) and "FPS" or string.format("%+d FPS", (math.round(v44.fps - currentSnapshot.fps)))
	)
	setText(
		description,
		"Ping",
		not hasPingEstimate(v44) and "MS PING" or string.format(
			"%+d MS PING",
			(math.round(v48 - localPlayer:GetNetworkPing() * 1000))
		)
	)
	setText(description, "Players", string.format("%+d PLAYERS", v44.players - currentSnapshot.players))
	local jobId4 = v44.jobId
	local v61 = not jobId4 and {} or v26[jobId4] or {}
	right.Players.Visible = #v61 > 0

	if #v61 > 0 then
		local v62 = #v61 > 2 and "s" or ""
		local name

		if #v61 == 1 then
			name = v61[1].name
		else
			name = `{v61[1].name} and {#v61 - 1} other{v62}`
		end

		local v63 = #v61 == 1 and "is" or "are"
		setText(right.Players, "Name", `{name} {v63} playing here.`)
		renderFriendAvatars(v61)
	end

	local v62

	if #v49.Reasons > 0 then
		v62 = table.concat(v49.Reasons, ", ")
	else
		v62 = `{v5.getDisplayName(v44.country)} datacenter`
	end

	setText(right.RankedReason:FindFirstChild("ServerInfo"), "Desc", v62)
	renderReason(v44, v49)
end

local function growRow(guiObject, k: number)
	if not guiObject:IsA("GuiObject") then
		return
	end

	local size = guiObject.Size
	guiObject.Size = UDim2.new()
	TweenService:Create(
		guiObject,
		TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, k * 0.03),
		{
			Size = size
		}
	):Play()
end

local function shrinkRow(guiObject)
	v29[guiObject] = nil

	if not guiObject:IsA("GuiObject") then
		guiObject:Destroy()
		return
	end

	local tween = TweenService:Create(guiObject, tweenInfo2, {
		Size = UDim2.new()
	})
	tween.Completed:Once(function()
		guiObject:Destroy()
	end)
	tween:Play()
end

local function freezeOrder(items)
	local formatted = `{v19()}|{v20()}|{v21()}`

	if v34 ~= formatted then
		v34 = formatted
		jobIds = {}
	end

	local v44 = {}

	for _, item in items do
		v44[item.jobId] = item
	end

	local result = {}
	local v45 = {}

	for _, v46 in jobIds do
		local v47 = v44[v46]

		if not v47 then
			continue
		end

		table.insert(result, v47)
		v45[v46] = true
	end

	for _, item in items do
		if not v45[item.jobId] then
			table.insert(result, item)
		end
	end

	jobIds = {}

	for _, v46 in result do
		table.insert(jobIds, v46.jobId)
	end

	return result
end

local function sampleRanking(list)
	if isStudio or v35 == count then
		return
	end

	v35 = count

	if #list == 0 or math.random() > 0.02 then
		return
	end

	local v44 = {}

	for i = 1, math.min(5, #list) do
		local v45 = list[i]
		local jobId2 = v45.jobId
		local v46

		if jobId2 then
			v46 = v39[jobId2]
		end

		if not v46 then
			v46 = v6.score(v45, (rankingContext(v45)))

			if jobId2 then
				v39[jobId2] = v46
			end
		end

		table.insert(v44, {
			jobId = v45.jobId,
			score = v46.Score,
			viability = v46.Viability,
			desirability = v46.Desirability,
			ping = v46.EstimatedPing,
			perf = v46.Performance,
			memory = v46.Memory,
			stability = v46.Stability,
			players = v45.players,
			fps = v45.fps
		})
	end

	remoteEvent:FireServer(v44)
end

local function renderList()
	local v44 = freezeOrder(getVisibleServers())
	local scrollingFrame = main.Left.LeftBg.ScrollingFrame
	v25 = v44
	local v45 = false

	for _, v47 in v44 do
		if v47.jobId ~= jobId then
			continue
		end

		v45 = true
		break
	end

	if not v45 then
		local v47

		if v44[1] then
			v47 = v44[1].jobId
		end

		jobId = v47
	end

	sampleRanking(v44)
	local v47 = {}

	for k, v48 in v44 do
		local jobId2 = v48.jobId
		v47[jobId2] = true
		local v49 = k == 1
		local clone = v28[jobId2]
		local flag2 = false

		if clone and clone:GetAttribute("IsHero") ~= v49 then
			v29[clone] = nil
			clone:Destroy()
			v28[jobId2] = nil
			clone = nil
		end

		if not clone then
			flag2 = true
			local v50

			if v49 then
				v50 = scrollingFrame.Selected
			else
				v50 = scrollingFrame.Template
			end

			clone = v50:Clone()
			clone.Name = jobId2
			clone:SetAttribute("IsHero", v49)
			clone.Visible = true
			bindJoin(clone, v48)
			bindCardHover(clone)
			bindSelect(clone)
			clone.Parent = scrollingFrame
			v28[jobId2] = clone
		end

		clone.LayoutOrder = k
		paintRow(clone, v48, k)

		if flag2 then
			growRow(clone, k)
		end
	end

	for k, v48 in v28 do
		if v47[k] then
			continue
		end

		v28[k] = nil
		shrinkRow(v48)
	end

	setText(main.Left, "Recommended", string.upper(v19()))
	setText(main.Left, "Casual", `{v20()} - Ranked for your connection`)
	setText(main.Mode.Main, "Mode", `MODE: {string.upper(v20())}`)
	local frame = main.Mode.ModeSwitcher.Main.Frame

	for _, v48 in v17 do
		local buttonByLabel = findButtonByLabel(frame, v48.Label)

		if buttonByLabel and buttonByLabel:IsA("ImageButton") then
			paintSelection(buttonByLabel, v48.Label == v20(), v31)
		end
	end

	for _, v48 in v16 do
		local buttonByLabel = findButtonByLabel(main.TopButton, v48.Name)

		if buttonByLabel then
			paintTab(buttonByLabel, v48.Name == v19())
		end
	end
end

local function renderYourServer()
	local currentSnapshot = getCurrentSnapshot()
	local group = main.Details.Group
	setText(group, "Mode", `{v8()} - {v5.getDisplayName(currentSnapshot.country)}`)
	setText(group, "Continent", v5.getContinent(currentSnapshot.country) or currentSnapshot.region)
	setText(group, "Fps", `FPS {math.round(currentSnapshot.fps)}`)
	setText(group, "Ping", `PING {math.round(localPlayer:GetNetworkPing() * 1000)}ms`)
	setText(group, "Players", `PLAYERS {currentSnapshot.players}/{currentSnapshot.maxPlayers}`)
	local count2 = 0

	for _, v44 in servers do
		if isBetterThanCurrent(v44) then
			count2 += 1
		end
	end

	group.BetterServers.Visible = count2 > 0
end

local function countRecommended()
	local count2 = 0

	for _, v45 in servers do
		local jobId2 = v45.jobId
		local v46

		if jobId2 then
			v46 = v41[jobId2]

			if v46 == nil then
				v46 = v6.isEligible(v45, (rankingContext(v45))) and isJoinable(v45)
				v41[jobId2] = v46
			end
		else
			v46 = false
		end

		local flag2

		if v46 then
			local tabContinent = getTabContinent("Recommended") -- equivalent call inferred; original call site unknown

			if tabContinent == nil then
				flag2 = true
			elseif v5.getContinent(v45.country) == tabContinent then
				flag2 = true
			else
				flag2 = false
			end
		else
			flag2 = false
		end

		if flag2 then
			count2 += 1
		end
	end

	return (math.min(6, count2))
end

local function updateTabCounts()
	local v44 = v5.getContinent(myCountry) or "NA"

	for k, v45 in v16 do
		local buttonByLabel = findButtonByLabel(main.TopButton, v45.Name)

		if not buttonByLabel then
			continue
		end

		local v46

		if v45.Name == "Recommended" then
			local count2 = 0

			for _, v48 in servers do
				local jobId2 = v48.jobId
				local v49

				if jobId2 then
					v49 = v41[jobId2]

					if v49 == nil then
						v49 = v6.isEligible(v48, (rankingContext(v48))) and isJoinable(v48)
						v41[jobId2] = v49
					end
				else
					v49 = false
				end

				local flag2

				if v49 then
					local tabContinent = getTabContinent("Recommended") -- equivalent call inferred; original call site unknown

					if tabContinent == nil then
						flag2 = true
					elseif v5.getContinent(v48.country) == tabContinent then
						flag2 = true
					else
						flag2 = false
					end
				else
					flag2 = false
				end

				if flag2 then
					count2 += 1
				end
			end

			v46 = math.min(6, count2)
		elseif v45.Continent then
			v46 = math.min(counts[v45.Continent] or 0, v5.ServersPerContinent)
		else
			local name = v45.Name
			v46 = 0

			for _, v47 in servers do
				local jobId2 = v47.jobId
				local v48

				if jobId2 then
					v48 = v41[jobId2]

					if v48 == nil then
						v48 = v6.isEligible(v47, (rankingContext(v47))) and isJoinable(v47)
						v41[jobId2] = v48
					end
				else
					v48 = false
				end

				local v49

				if v48 then
					if name == "Friends" then
						local jobId3 = v47.jobId
						v49 = #(not jobId3 and {} or v26[jobId3] or {}) > 0
					else
						local tabContinent = getTabContinent(name) -- equivalent call inferred; original call site unknown

						if tabContinent == nil then
							v49 = true
						elseif v5.getContinent(v47.country) == tabContinent then
							v49 = true
						else
							v49 = false
						end
					end
				else
					v49 = false
				end

				if v49 then
					v46 += 1
				end
			end
		end

		local label = buttonByLabel:FindFirstChild("Label") or buttonByLabel:FindFirstChildWhichIsA("TextLabel", true)

		if label and label:IsA("TextLabel") then
			local text = replaceVisibleCount(label.Text, v46)

			if text ~= label.Text then
				apply(label)({
					Text = text
				})
			end
		end

		local continent = v45.Continent

		if continent then
			k = 100 + v5.getContinentDistance(v44, continent)
		end

		buttonByLabel.LayoutOrder = k

		if v45.Name == "Friends" then
			buttonByLabel.Visible = v46 > 0
		end
	end
end

local function enforceTabAvailability()
	local v44 = v19()

	if v44 == "Recommended" then
		return true
	end

	local count2 = 0

	for _, v45 in servers do
		local jobId2 = v45.jobId
		local v46

		if jobId2 then
			v46 = v41[jobId2]

			if v46 == nil then
				v46 = v6.isEligible(v45, (rankingContext(v45))) and isJoinable(v45)
				v41[jobId2] = v46
			end
		else
			v46 = false
		end

		local v47

		if v46 then
			if v44 == "Friends" then
				local jobId3 = v45.jobId
				v47 = #(not jobId3 and {} or v26[jobId3] or {}) > 0
			else
				local tabContinent = getTabContinent(v44) -- equivalent call inferred; original call site unknown

				if tabContinent == nil then
					v47 = true
				elseif v5.getContinent(v45.country) == tabContinent then
					v47 = true
				else
					v47 = false
				end
			end
		else
			v47 = false
		end

		if v47 then
			count2 += 1
		end
	end

	if not (count2 > 0) then
		v19("Recommended")
		v13:SendNotification(`No servers in {v44} right now.`, 3)
		return false
	end

	return true
end

local function makeSimulatedSelf(serverType: string, p)
	local currentSnapshot = getCurrentSnapshot()
	local v44 = {
		jobId = game.JobId,
		players = currentSnapshot.players,
		maxPlayers = 0,
		country = 0,
		region = 0,
		serverType = 0,
		placeId = 0,
		fps = 0,
		jitter = 1.2,
		heartbeatMs = 0,
		memMb = 3200,
		luaHeapMb = 1300,
		instanceCount = 60000,
		avgPing = 0,
		playerDelta = 0,
		bouncePct = 4,
		errorsPerMin = 0,
		datastoreFailPct = 0,
		phase = 0,
		gamemode = 0,
		map = 0,
		roundSeconds = 0,
		uptimeMin = 5,
		placeVersion = 0,
		lastUpdate = 0,
		flags = 0
	}
	local maxPlayers

	if p then
		maxPlayers = p.maxPlayers
	else
		maxPlayers = currentSnapshot.maxPlayers
	end

	v44.maxPlayers = maxPlayers
	v44.country = currentSnapshot.country
	v44.region = currentSnapshot.region
	v44.serverType = serverType
	v44.placeId = game.PlaceId
	v44.fps = math.min(currentSnapshot.fps, 60)
	v44.heartbeatMs = 1000 / math.max(currentSnapshot.fps, 1)
	v44.avgPing = math.round(localPlayer:GetNetworkPing() * 1000)
	v44.placeVersion = game.PlaceVersion
	v44.lastUpdate = os.time()
	v44.flags = {
		ShuttingDown = false,
		Joinable = true,
		MidRound = false,
		EventActive = false
	}
	return v44
end

local function emptyFleet()
	return {
		servers = {},
		counts = {},
		updatedAt = 0,
		latestPlaceVersion = nil,
		oldBuildsExcluded = false
	}
end

local function applyFleet(data)
	servers = data.servers
	counts = data.counts
	updatedAt = data.updatedAt
	latestPlaceVersion = data.latestPlaceVersion
	oldBuildsExcluded = data.oldBuildsExcluded
	v39 = {}
	v40 = {}
	v41 = {}

	for _, server in servers do
		if server.jobId ~= game.JobId then
			continue
		end

		v24 = server
		break
	end
end

local live_Hover = nil
local textLabel = nil
local text3 = "LIVE"

local function isLoading()
	return flag or v30 == v20()
end

local function paintLiveStatus()
	if flag or v30 == v20() then
		if textLabel then
			apply(textLabel)({
				Text = "REFRESHING"
			})
		end

		setFirstLabel(live_Hover, `loading {v20()}, waiting for the server queue`) -- equivalent call inferred; original call site unknown
	elseif textLabel then
		apply(textLabel)({
			Text = text3
		})
	end
end

function ServerBrowserController:Refresh()
	if flag then
		return
	end

	flag = true
	local v45 = v20()
	local modeConfig = getModeConfig(v45) -- equivalent call inferred; original call site unknown
	local servers2 = {}
	local counts2 = {}
	local latestPlaceVersion2 = nil
	local oldBuildsExcluded2 = false
	local flag2 = false

	if isStudio then
		servers2 = v15.getServers(modeConfig.ServerType, modeConfig.PlaceKey, getCurrentSnapshot().country)
		flag2 = true

		for _, v50 in servers2 do
			local continent = v5.getContinent(v50.country)

			if continent then
				counts2[continent] = (counts2[continent] or 0) + 1
			end
		end

		if modeConfig.ServerType == v8() then
			table.insert(servers2, (makeSimulatedSelf(modeConfig.ServerType, servers2[1])))
		end
	else
		local success, result, v50 = pcall(function()
			return v:Invoke("RefreshServerBrowser", nil, modeConfig.ServerType)
		end)

		if success and v50 == "loading" then
			v30 = v45
			flag = false
			paintLiveStatus()
			task.delay(2, function()
				if v20() == v45 then
					ServerBrowserController:Refresh()
				end
			end)
			return
		else
			if success and type(result) == "table" then
				flag2 = true

				for _, v51 in result do
					if typeof(v51) ~= "buffer" then
						continue
					end

					local replicationBuffer = v5.readReplicationBuffer(v51)

					if replicationBuffer then
						table.insert(servers2, replicationBuffer)
					end
				end
			end

			latestPlaceVersion2 = 0
			local count2 = 0

			for _, v51 in servers2 do
				latestPlaceVersion2 = math.max(latestPlaceVersion2, v51.placeVersion)
			end

			for _, v51 in servers2 do
				if latestPlaceVersion2 <= v51.placeVersion then
					count2 += 1
				end
			end

			if not (latestPlaceVersion2 > 0) then
				latestPlaceVersion2 = nil
			end

			if #servers2 > 0 then
				oldBuildsExcluded2 = count2 / #servers2 >= 0.4
			else
				oldBuildsExcluded2 = false
			end

			local success2, result2 = pcall(function()
				return v:Invoke("ServerBrowserCounts", modeConfig.ServerType)
			end)

			if success2 and type(result2) == "table" then
				counts2 = result2
			end
		end
	end

	flag = false

	if v30 == v45 then
		v30 = nil
	end

	paintLiveStatus()
	local v50 = v38[v45] or emptyFleet()

	if flag2 then
		v50.servers = servers2
		v50.counts = counts2
		v50.latestPlaceVersion = latestPlaceVersion2
		v50.oldBuildsExcluded = oldBuildsExcluded2
	end

	v50.updatedAt = os.time()
	v38[v45] = v50

	if v20() ~= v45 then
		return
	end

	applyFleet(v50)
	myPing = localPlayer:GetNetworkPing() * 1000
	count += 1
	v22(count)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshAsync()
	task.spawn(function()
		ServerBrowserController:Refresh()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function selectMode(label: string)
	if label == v20() then
		return
	end

	local v45 = v38[label]
	jobId = nil
	applyFleet(v45 or emptyFleet())
	v20(label)

	if not v45 then
		refreshAsync() -- equivalent call inferred; original call site unknown
	end
end

local function bindOpenAndClose()
	v2:OnGuiOpen("ServerBrowser", function()
		if updatedAt == 0 or os.time() - updatedAt >= 20 then
			refreshAsync() -- equivalent call inferred; original call site unknown
			return
		end

		count += 1
		v22(count)
	end)
	v2:OnGuiClose("ServerBrowser", function()
		for k, v45 in v28 do
			v28[k] = nil
			v29[v45] = nil
			v45:Destroy()
		end

		jobIds = {}
		v34 = ""
	end)
end

function ServerBrowserController.Init(_)
	myPing = localPlayer:GetNetworkPing() * 1000

	for _, v45 in v17 do
		if v45.ServerType ~= v8() then
			continue
		end

		v20(v45.Label)
		break
	end

	local localPlayerTeleportData = TeleportService:GetLocalPlayerTeleportData()

	if type(localPlayerTeleportData) == "table" and type(localPlayerTeleportData.ServerBrowserFrom) == "string" then
		serverBrowserFrom = localPlayerTeleportData.ServerBrowserFrom
		local v45

		if type(localPlayerTeleportData.ServerBrowserAt) == "number" then
			v45 = localPlayerTeleportData.ServerBrowserAt
		else
			v45 = os.time()
		end

		v37 = v45
	end

	local success, countryRegionForPlayerAsync = pcall(
		LocalizationService.GetCountryRegionForPlayerAsync,
		LocalizationService,
		localPlayer
	)

	if success and countryRegionForPlayerAsync then
		myCountry = countryRegionForPlayerAsync
	end
end

function ServerBrowserController:Start()
	if not ServerBrowserController.IsEnabled() then
		serverBrowser.Enabled = false
		return
	end

	serverBrowser.Enabled = false
	local scrollingFrame = main.Left.LeftBg.ScrollingFrame
	scrollingFrame.Selected.Visible = false
	scrollingFrame.Template.Visible = false
	main.Right.Visible = false
	main.Mode.ModeSwitcher:SetAttribute("FullSize", main.Mode.ModeSwitcher.Size)
	main.Mode.ModeSwitcher:SetAttribute("FullPosition", main.Mode.ModeSwitcher.Position)
	main.Mode.ModeSwitcher:SetAttribute("OpenSize", main.Mode.ModeSwitcher.Size)
	main.Mode.ModeSwitcher:SetAttribute("OpenPosition", main.Mode.ModeSwitcher.Position)
	main.Mode.ModeSwitcher.Visible = false
	main.Mode.ModeSwitcher.ClipsDescendants = true
	main.Mode.ModeSwitcher.Main.ScaleType = Enum.ScaleType.Stretch
	main.Mode.ModeSwitcher.Main.Frame.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	main.Right.RankedReason.Visible = true
	local serverInfo = main.Right.RankedReason:FindFirstChild("ServerInfo")

	if not (serverInfo and serverInfo:IsA("GuiObject")) then
		serverInfo = nil
	end

	if serverInfo then
		serverInfo:SetAttribute("OpenSize", serverInfo.Size)
		serverInfo:SetAttribute("OpenPosition", serverInfo.Position)
		serverInfo.Visible = false
		local ranked = main.Right.RankedReason.Ranked
		ranked.Active = true
		ranked.Selectable = true

		if not ranked:GetAttribute("SelectorSounds") then
			ranked:SetAttribute("SelectorSounds", true)
			bindSounds(ranked)
		end

		main.Right.RankedReason.Ranked.Activated:Connect(function()
			local v45 = not serverInfo.Visible

			if v45 then
				closeDropdowns(serverInfo)
			end

			setDropdownOpen(serverInfo, v45)
			spinIcon(main.Right.RankedReason.Ranked, v45)
		end)
	end

	main.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			closeDropdowns(nil)
		end
	end)
	serverBrowser:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not serverBrowser.Enabled then
			closeDropdowns(nil)
		end
	end)
	bindOpenAndClose()
	RunService.RenderStepped:Connect(function(dt: number)
		total += (1 / dt - total) * 0.05
	end)

	for _, v45 in v16 do
		local buttonByLabel = findButtonByLabel(main.TopButton, v45.Name)

		if buttonByLabel then
			local v46 = v45
			buttonByLabel.Activated:Connect(function()
				jobId = nil
				v19(v46.Name)
				v23(10)
			end)
		else
			warn((`[ServerBrowser] tab button not found: {v45.Name}`))
		end
	end

	scrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if scrollingFrame.CanvasPosition.Y > 0 and v23() < serversPerContinent then
			v23(serversPerContinent)
		end
	end)
	local guiButtons = {}

	for _, guiObject in main.Mode.ModeSwitcher.Main.Frame:GetChildren() do
		local guiButton

		if guiObject:IsA("GuiObject") then
			if guiObject:IsA("GuiButton") then
				guiObject.Active = true
				guiObject.Selectable = true

				if not guiObject:GetAttribute("SelectorSounds") then
					guiObject:SetAttribute("SelectorSounds", true)
					bindSounds(guiObject)
				end

				guiButton = guiObject
			else
				guiButton = guiObject:FindFirstChildWhichIsA("GuiButton", true)

				if guiButton then
					guiButton.Active = true
					guiButton.Selectable = true

					if not guiButton:GetAttribute("SelectorSounds") then
						guiButton:SetAttribute("SelectorSounds", true)
						bindSounds(guiButton)
					end
				else
					guiButton = nil
				end
			end
		end

		if not (guiButton and guiButton:IsA("ImageButton")) then
			continue
		end

		local v45 = {
			Holder = guiObject,
			Button = guiButton,
			Mode = nil
		}
		table.insert(v36, v45)
		table.insert(guiButtons, guiButton)
		guiButton.Activated:Connect(function()
			local mode = v45.Mode

			if not mode then
				return
			end

			setSwitcherOpen(false) -- equivalent call inferred; original call site unknown
			selectMode(mode.Label) -- equivalent call inferred; original call site unknown
		end)
	end

	refreshSwitcher()
	v9.FFlag.OnChange(refreshSwitcher)

	if #guiButtons >= 2 then
		v31 = { readLook(guiButtons[1]), (readLook(guiButtons[2])) }
	end

	local main2 = main.Mode.Main
	main2.Active = true
	main2.Selectable = true

	if not main2:GetAttribute("SelectorSounds") then
		main2:SetAttribute("SelectorSounds", true)
		bindSounds(main2)
	end

	main.Mode.Main.Activated:Connect(function()
		local v45 = not main.Mode.ModeSwitcher.Visible

		if v45 then
			refreshSwitcher()
		end

		setSwitcherOpen(v45) -- equivalent call inferred; original call site unknown
	end)
	local main3 = main.Refresh.Main
	main3.Active = true
	main3.Selectable = true

	if not main3:GetAttribute("SelectorSounds") then
		main3:SetAttribute("SelectorSounds", true)
		bindSounds(main3)
	end

	main.Refresh.Main.Activated:Connect(function()
		main.Refresh.Main.Interactable = false
		task.delay(10, function()
			main.Refresh.Main.Interactable = true
		end)
		refreshAsync() -- equivalent call inferred; original call site unknown
	end)
	local close = main.Close
	close.Active = true
	close.Selectable = true

	if not close:GetAttribute("SelectorSounds") then
		close:SetAttribute("SelectorSounds", true)
		bindSounds(close)
	end

	main.Close.Activated:Connect(function()
		v2:Close("ServerBrowser", true)
	end)
	UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
		if gameProcessed or not serverBrowser.Enabled then
			return
		end

		if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB then
			v2:Close("ServerBrowser", true)
		end
	end)
	local search = main.Search.Main.Search
	search:GetPropertyChangedSignal("Text"):Connect(function()
		v21(search.Text)
	end)
	v14.root(function()
		effect(function()
			v19()
			v20()
			v21()
			v22()
			v23()
			refreshFriends()
			local v45 = v19()
			local v46

			if v45 == "Recommended" then
				v46 = true
			else
				local count2 = 0

				for _, server in servers do
					local jobId2 = server.jobId
					local v47

					if jobId2 then
						v47 = v41[jobId2]

						if v47 == nil then
							v47 = v6.isEligible(server, (rankingContext(server))) and isJoinable(server)
							v41[jobId2] = v47
						end
					else
						v47 = false
					end

					local v48

					if v47 then
						if v45 == "Friends" then
							local jobId3 = server.jobId
							v48 = #(not jobId3 and {} or v26[jobId3] or {}) > 0
						else
							local tabContinent = getTabContinent(v45) -- equivalent call inferred; original call site unknown

							if tabContinent == nil then
								v48 = true
							elseif v5.getContinent(server.country) == tabContinent then
								v48 = true
							else
								v48 = false
							end
						end
					else
						v48 = false
					end

					if v48 then
						count2 += 1
					end
				end

				if count2 > 0 then
					v46 = true
				else
					v19("Recommended")
					v13:SendNotification(`No servers in {v45} right now.`, 3)
					v46 = false
				end
			end

			if not v46 then
				return
			end

			renderList()
			renderDetail()
			renderYourServer()
			updateTabCounts()
		end)
	end)
	live_Hover = main.Live:FindFirstChild("Live_Hover")
	textLabel = main.Live.Main:FindFirstChildWhichIsA("TextLabel", true)
	text3 = not textLabel and "LIVE" or textLabel.Text

	if live_Hover then
		live_Hover.Visible = false
		local main4 = main.Live.Main
		main4.Active = true
		main4.MouseEnter:Connect(function()
			live_Hover.Visible = true
		end)
		main4.MouseLeave:Connect(function()
			live_Hover.Visible = false
		end)
	end

	pulseGlow(main.Live:FindFirstChild("Glow"))
	pulseGlow(main.Details.Group.BetterServers:FindFirstChild("Glow"))
	task.spawn(function()
		while true do
			task.wait(1)

			if not serverBrowser.Enabled then
				continue
			end

			paintLiveStatus()

			if flag or v30 == v20() then
				continue
			end

			local v45 = not (updatedAt > 0) and 0 or os.time() - updatedAt
			local v46 = v45 < 2 and "just now" or `{v45}s ago`
			local v47 = live_Hover
			local formatted = `updated {v46} - next refresh {math.max(0, 20 - v45)}s`
			local textLabel2 = v47 and v47:FindFirstChildWhichIsA("TextLabel", true)

			if textLabel2 then
				apply(textLabel2)({
					Text = formatted
				})
			end

			if updatedAt == 0 or v45 >= 20 then
				self:Refresh()
			end
		end
	end)
end

return ServerBrowserController
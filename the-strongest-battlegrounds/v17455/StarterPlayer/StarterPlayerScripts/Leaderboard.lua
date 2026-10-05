local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local tweenInfo = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local UserInputService2 = game:GetService("UserInputService")

if UserInputService2.TouchEnabled then
	return
end

task.spawn(function()
	local lastTime = tick()

	while tick() - lastTime < 5 do
		local success, coreGuiEnabled = pcall(StarterGui.GetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.PlayerList)

		if success and coreGuiEnabled then
			pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.PlayerList, false)
		end

		task.wait()
	end

	while true do
		task.wait(3)
		local success, coreGuiEnabled = pcall(StarterGui.GetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.PlayerList)

		if success and coreGuiEnabled then
			pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.PlayerList, false)
		end
	end
end)
pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.PlayerList, false)
localPlayer.CharacterAdded:Connect(function()
	pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.PlayerList, false)
end)
local parent = script.Parent
local mainHolder = parent:WaitForChild("MainHolder")
local templates = parent:WaitForChild("Templates")
local playerEntry = templates:WaitForChild("PlayerEntry")
local gameStat = templates:WaitForChild("GameStat")
local statHeader = templates:WaitForChild("StatHeader")
local teamList = templates:WaitForChild("TeamList")
local playerDropdown = templates:WaitForChild("PlayerDropdown")
local uIListLayout = teamList:FindFirstChildWhichIsA("UIListLayout", true)

if uIListLayout then
	uIListLayout.Padding = UDim.new(0, 5)
end

local nameFrame = playerEntry:FindFirstChild("NameFrame", true)

if nameFrame then
	local layout = nameFrame:FindFirstChild("Layout")

	if layout and layout:IsA("UIListLayout") then
		layout.Padding = UDim.new(0, 5)
	end

	local initialPadding = nameFrame:FindFirstChild("InitialPadding")

	if initialPadding then
		warn(initialPadding)
		initialPadding.PaddingLeft = UDim2.new(0, 11)
		initialPadding.Value = UDim.new(0, 11)
	end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RankedPlayerList"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 5
screenGui.Parent = playerGui
local clone = mainHolder:Clone()
clone.Parent = screenGui
local offsetFrame = clone:FindFirstChild("OffsetFrame", true)
local position

if offsetFrame and offsetFrame:IsA("GuiObject") then
	position = offsetFrame.Position
else
	position = nil
end

local offsetUndoFrame

if clone then
	offsetUndoFrame = clone:FindFirstChild("OffsetUndoFrame", true)
else
	offsetUndoFrame = nil
end

local childrenFrame

if clone then
	childrenFrame = clone:FindFirstChild("ChildrenFrame", true)
else
	childrenFrame = nil
end

local dismissButton

if clone then
	dismissButton = clone:FindFirstChild("DismissButton", true)
end

local scrollingFrameContainer

if clone then
	scrollingFrameContainer = clone:FindFirstChild("ScrollingFrameContainer", true)
else
	scrollingFrameContainer = nil
end

if teamList:IsA("GuiObject") then
	teamList.AutomaticSize = Enum.AutomaticSize.Y
end

if offsetUndoFrame:IsA("GuiObject") then
	offsetUndoFrame.AutomaticSize = Enum.AutomaticSize.Y
end

if scrollingFrameContainer:IsA("GuiObject") then
	scrollingFrameContainer.AutomaticSize = Enum.AutomaticSize.None
end

local sizeOffsetFrame = clone:FindFirstChild("SizeOffsetFrame", true)

if sizeOffsetFrame and sizeOffsetFrame:IsA("GuiObject") then
	sizeOffsetFrame.AutomaticSize = Enum.AutomaticSize.XY
	sizeOffsetFrame.Size = UDim2.new(sizeOffsetFrame.Size.X.Scale, 0, sizeOffsetFrame.Size.Y.Scale, 0)
end

local titleBar = clone:FindFirstChild("TitleBar", true)

if titleBar and titleBar:IsA("GuiObject") then
	titleBar.AutomaticSize = Enum.AutomaticSize.X
	titleBar.Size = UDim2.new(titleBar.Size.X.Scale, 0, titleBar.Size.Y.Scale, titleBar.Size.Y.Offset)
end

if childrenFrame and childrenFrame:IsA("GuiObject") then
	childrenFrame.AutomaticSize = Enum.AutomaticSize.X
	childrenFrame.Size = UDim2.new(
		childrenFrame.Size.X.Scale,
		0,
		childrenFrame.Size.Y.Scale,
		childrenFrame.Size.Y.Offset
	)
end

for _, childName in pairs({ "TopRoundedRect", "BottomRoundedRect" }) do
	local guiObject = clone:FindFirstChild(childName, true)

	if not (guiObject and guiObject:IsA("GuiObject")) then
		continue
	end

	local size = guiObject.Size
	guiObject.Size = UDim2.new(1, 0, size.Y.Scale, size.Y.Offset)
end

if scrollingFrameContainer and scrollingFrameContainer:IsA("GuiObject") then
	local size = scrollingFrameContainer.Size
	scrollingFrameContainer.Size = UDim2.new(1, 0, size.Y.Scale, size.Y.Offset)
end

local scrollingFrame = clone:FindFirstChild("ScrollingFrame", true)
local scrollingFrameClippingFrame = clone:FindFirstChild("ScrollingFrameClippingFrame", true)
local uIListLayout2 = offsetUndoFrame:FindFirstChildWhichIsA("UIListLayout")

if scrollingFrame and scrollingFrame:IsA("ScrollingFrame") then
	scrollingFrame.AutomaticSize = Enum.AutomaticSize.None
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.None
end

if scrollingFrameClippingFrame and scrollingFrameClippingFrame:IsA("GuiObject") then
	scrollingFrameClippingFrame.AutomaticSize = Enum.AutomaticSize.None
end

if uIListLayout2 and scrollingFrame and scrollingFrame:IsA("ScrollingFrame") then
	local function fn()
		local Y = uIListLayout2.AbsoluteContentSize.Y
		local v = math.min(Y, 280)
		scrollingFrame.Size = UDim2.new(scrollingFrame.Size.X.Scale, scrollingFrame.Size.X.Offset, 0, v)
		scrollingFrame.CanvasSize = UDim2.fromOffset(0, Y)

		if scrollingFrameClippingFrame and scrollingFrameClippingFrame:IsA("GuiObject") then
			scrollingFrameClippingFrame.Size = UDim2.new(1, 0, 0, v)
		end

		if scrollingFrameContainer:IsA("GuiObject") then
			scrollingFrameContainer.Size = UDim2.new(
				scrollingFrameContainer.Size.X.Scale,
				scrollingFrameContainer.Size.X.Offset,
				0,
				v
			)
		end
	end

	uIListLayout2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(fn)
	fn()
end

local v = {}
local v2 = {}
local v3 = {}
local v4 = true
local v5 = nil
local v6 = {}
local v7 = {}
local v8 = {}
local v9 = {}
local v10 = {}
local flag = false

local function fn(instance)
	local v11 = {}

	for _, guiObject in pairs(instance:GetChildren()) do
		if not (guiObject.Name:sub(1, 12) == "PlayerEntry_" and guiObject:IsA("GuiObject")) then
			continue
		end

		local v12 = tonumber(guiObject.Name:sub(13))
		local kills2 = 0
		local v13 = v12 and v[v12]

		if v13 and v13.player then
			local leaderstats = v13.player:FindFirstChild("leaderstats")
			local kills = leaderstats and leaderstats:FindFirstChild("Kills")

			if kills then
				kills2 = tonumber(kills.Value) or 0
			end
		end

		table.insert(v11, {
			row = guiObject,
			kills = kills2,
			name = guiObject.Name
		})
	end

	table.sort(v11, function(a, b)
		if a.kills == b.kills then
			return a.name < b.name
		end

		return a.kills > b.kills
	end)

	for i, v12 in ipairs(v11) do
		v12.row.LayoutOrder = i
	end
end

local function fn2()
	local v11 = false

	for _, v13 in pairs(Players:GetPlayers()) do
		local leaderstats = v13:FindFirstChild("leaderstats")

		if not (leaderstats and leaderstats:FindFirstChild("Kills")) then
			continue
		end

		v11 = true
		break
	end

	if not v11 then
		return
	end

	for _, v13 in pairs(v3) do
		if v13 and v13.Parent then
			fn(v13)
		end
	end
end

local function fn3()
	if flag then
		return
	end

	flag = true
	task.defer(function()
		flag = false
		fn2()
	end)
end

local _ = {
	dev = "rbxassetid://110353950052677",
	tester = "rbxassetid://106336800379939",
	specialtester = "rbxassetid://113461886527989"
}
local v11 = {
	[3350014406] = true,
	[747447782] = true,
	[1001242712] = true,
	[56721213] = true,
	[1446694201] = true,
	[76707998] = true
}
local v12 = {
	[422755031] = true,
	[117723419] = true,
	[971193650] = true,
	[278097946] = true,
	[1526501409] = true,
	[3350014406] = true,
	[41022405] = true,
	[156112298] = true,
	[9684094059] = true,
	[77342385] = true,
	[292707170] = true,
	[38307780] = true,
	[221681529] = true,
	[2544664287] = true,
	[66105529] = true,
	[60862201] = true,
	[123755248] = true,
	[1974829690] = true
}
local playerIcon = playerEntry:FindFirstChild("PlayerIcon", true)
local v13 = not (playerIcon and playerIcon:IsA("TextLabel")) and "" or playerIcon.Text

local function fn4(clone2, p, instance)
	local playerIcon2 = clone2:FindFirstChild("PlayerIcon", true)

	if not playerIcon2 then
		return
	end

	local visible = p == "dev"
	local v15 = visible and "rbxassetid://110353950052677" or p == "tester" and "rbxassetid://106336800379939" or nil
	local image = (instance.UserId == 292707170 or instance.UserId == 278097946) and "rbxassetid://113461886527989" or v15

	if playerIcon2:IsA("TextLabel") then
		playerIcon2.Text = visible and v13 or ""
	end

	if playerIcon2:IsA("GuiObject") then
		playerIcon2.Visible = visible
	end

	if image then
		local clone3 = script.Parent.Templates.AvatarImage:Clone()
		clone3.Parent = clone2.PlayerEntryContentFrame.OverlayFrame.NameFrame
		clone3.Image = image
		clone3.Name = "extraimgae"
		clone3.Size = visible and UDim2.new(0, 31, 0, 31) or UDim2.new(0, 37, 0, 37)
		task.delay(0.25, function()
			local avatarImage = clone2:FindFirstChild("AvatarImage", true)

			if avatarImage then
				avatarImage.Visible = false
			end

			playerIcon2.Visible = false

			for _, v18 in pairs({ avatarImage, playerIcon2 }) do
				local v19 = v18
				v18:GetPropertyChangedSignal("Visible"):Connect(function()
					v19.Visible = false
				end)
			end

			local uIListLayout = clone3.Parent:FindFirstChildOfClass("UIListLayout")
			uIListLayout.Padding = UDim.new(0, 3)
		end)
	end
end

local function fn5(value)
	if typeof(value) ~= "number" then
		return (tostring(value))
	end

	local v14 = tostring((math.floor(value + 0.5)))

	repeat
		local v15
		v14, v15 = string.gsub(v14, "^(-?%d+)(%d%d%d)", "%1,%2")
	until v15 == 0

	return v14
end

local function fn6(folder)
	local playerStatDisplay = folder:FindFirstChild("PlayerStatDisplay")

	if playerStatDisplay and playerStatDisplay:IsA("TextLabel") then
		return playerStatDisplay
	end

	for _, label in pairs(folder:GetDescendants()) do
		if label:IsA("TextLabel") then
			return label
		end
	end

	return nil
end

local function fn7(folder)
	for _, label in pairs(folder:GetDescendants()) do
		if label:IsA("TextLabel") and label.Name == "PlayerName" then
			return label
		end
	end

	return nil
end

local uDim = UDim2.new(0, 35, 0, 35)
local v14 = {
	["1v1s"] = {
		{
			name = "God",
			min = 3700
		},
		{
			name = "Calamity",
			min = 3200
		},
		{
			name = "Cosmic Threat",
			min = 2600
		},
		{
			name = "Dragon",
			min = 1900
		},
		{
			name = "Demon",
			min = 1200
		},
		{
			name = "Tiger",
			min = 600
		},
		{
			name = "Wolf",
			min = 100
		},
		{
			name = "Unranked",
			min = 0
		}
	},
	["2v2s"] = {
		{
			name = "God",
			min = 3200
		},
		{
			name = "Calamity",
			min = 2700
		},
		{
			name = "Cosmic Threat",
			min = 2200
		},
		{
			name = "Dragon",
			min = 1600
		},
		{
			name = "Demon",
			min = 1000
		},
		{
			name = "Tiger",
			min = 500
		},
		{
			name = "Wolf",
			min = 100
		},
		{
			name = "Unranked",
			min = 0
		}
	},
	["3v3s"] = {
		{
			name = "God",
			min = 3000
		},
		{
			name = "Calamity",
			min = 2500
		},
		{
			name = "Cosmic Threat",
			min = 2000
		},
		{
			name = "Dragon",
			min = 1400
		},
		{
			name = "Demon",
			min = 800
		},
		{
			name = "Tiger",
			min = 400
		},
		{
			name = "Wolf",
			min = 100
		},
		{
			name = "Unranked",
			min = 0
		}
	}
}
local v15 = {
	Unranked = "rbxassetid://125981469994303",
	Wolf = "rbxassetid://78355287626071",
	Tiger = "rbxassetid://76227211350676",
	Demon = "rbxassetid://83066656945371",
	Dragon = "rbxassetid://104728265939518",
	["Cosmic Threat"] = "rbxassetid://111531290254363",
	Calamity = "rbxassetid://98907003282973",
	God = "rbxassetid://106265317134078"
}
local v16 = {
	Unranked = { Color3.fromRGB(200, 200, 200), Color3.fromRGB(120, 120, 120) },
	Wolf = { Color3.fromRGB(225, 235, 245), Color3.fromRGB(110, 135, 165) },
	Tiger = { Color3.fromRGB(255, 170, 55), Color3.fromRGB(170, 70, 20) },
	Demon = { Color3.fromRGB(225, 50, 50), Color3.fromRGB(75, 8, 14) },
	Dragon = { Color3.fromRGB(255, 205, 70), Color3.fromRGB(35, 130, 70) },
	["Cosmic Threat"] = { Color3.fromRGB(170, 100, 240), Color3.fromRGB(55, 90, 220) },
	Calamity = { Color3.fromRGB(255, 100, 30), Color3.fromRGB(212, 19, 22) },
	God = { Color3.fromRGB(255, 255, 240), Color3.fromRGB(255, 210, 75) }
}
local v17 = {
	Unranked = 0,
	Wolf = 1,
	Tiger = 2,
	Demon = 3,
	Dragon = 4,
	["Cosmic Threat"] = 5,
	Calamity = 6,
	God = 7
}

local function fn8(rankDatas)
	if typeof(rankDatas) ~= "string" or rankDatas == "" then
		return {}
	end

	local success, result = pcall(function()
		return HttpService:JSONDecode(rankDatas)
	end)

	if success and typeof(result) == "table" then
		return result
	end

	return {}
end

local function fn9(p, p2)
	local v18 = v14[p2]

	if not v18 then
		return "Unranked"
	end

	local v19 = math.max(0, tonumber(p) or 0)

	for _, v20 in pairs(v18) do
		if v20.min <= v19 then
			return v20.name
		end
	end

	return "Unranked"
end

local function fn10(instance)
	local rankDatas = instance:GetAttribute("RankDatas")
	local v18 = typeof(rankDatas) == "string" and rankDatas or ""
	local v19 = v9[instance.UserId]

	if v19 and v19.key == v18 then
		return v19.result
	end

	local v20 = fn8(rankDatas)
	local v21 = nil

	for _, mode in pairs({ "1v1s", "2v2s", "3v3s" }) do
		local elo = tonumber(v20[mode]) or 0
		local name = fn9(elo, mode)
		local tieridx = v17[name] or 0

		if not v21 or v21.tieridx < tieridx or tieridx == v21.tieridx and v21.elo < elo then
			v21 = {
				name = name,
				elo = elo,
				mode = mode,
				tieridx = tieridx
			}
		end
	end

	local selected = v21 or {
		name = "Unranked",
		elo = 0,
		mode = "1v1s"
	}
	v9[instance.UserId] = {
		key = v18,
		result = selected
	}
	return selected
end

local function fn11(realrank, name)
	if not realrank then
		return
	end

	local uIGradient = realrank:FindFirstChildOfClass("UIGradient")

	if not uIGradient then
		return
	end

	local v18 = v16[name]

	if not v18 then
		return
	end

	uIGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, v18[1]), ColorSequenceKeypoint.new(1, v18[2]) })
end

local function fn12(clone2, instance)
	local avatarImage = clone2:FindFirstChild("AvatarImage")

	if avatarImage and avatarImage:IsA("ImageLabel") then
		if instance then
			avatarImage.Image = v15[fn10(instance).name] or "rbxassetid://125981469994303"
		end

		return avatarImage
	else
		local playerIcon2 = clone2:FindFirstChild("PlayerIcon", true)

		if not (playerIcon2 and playerIcon2:IsA("GuiObject")) then
			return nil
		end

		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "AvatarImage"
		imageLabel.BackgroundTransparency = 1
		imageLabel.BorderSizePixel = 0
		imageLabel.Size = uDim
		imageLabel.Position = playerIcon2.Position
		imageLabel.AnchorPoint = playerIcon2.AnchorPoint
		imageLabel.ScaleType = Enum.ScaleType.Fit
		imageLabel.ZIndex = playerIcon2.ZIndex
		warn(instance)

		if instance and v11[instance.UserId] ~= true and v12[instance.UserId] ~= true then
			imageLabel.Image = v15[fn10(instance).name] or "rbxassetid://125981469994303"
		else
			imageLabel.Image = "rbxassetid://125981469994303"
		end

		imageLabel.Parent = playerIcon2.Parent
		playerIcon2.ZIndex += 1
		return imageLabel
	end
end

local function fn13(instance)
	local friendIcon = instance:FindFirstChild("FriendIcon", true)

	if friendIcon and friendIcon:IsA("TextLabel") then
		return friendIcon
	end

	local playerIcon2 = instance:FindFirstChild("PlayerIcon", true)

	if not (playerIcon2 and playerIcon2:IsA("TextLabel")) then
		return nil
	end

	local clone2 = playerIcon2:Clone()
	clone2.Name = "FriendIcon"
	clone2.Text = "person-fill"
	clone2.Visible = false
	local avatarImage = instance:FindFirstChild("AvatarImage", true)
	local v18 = avatarImage or playerIcon2
	local v19 = not v18.Size and 35 or v18.Size.X.Offset or 35
	clone2.AnchorPoint = v18.AnchorPoint
	clone2.Position = v18.Position + UDim2.fromOffset(v19 + 6, 0)
	clone2.ZIndex = (avatarImage and avatarImage.ZIndex or playerIcon2.ZIndex) + 1
	clone2.Parent = playerIcon2.Parent
	return clone2
end

local v18 = {}
local flag2 = false
local v19 = {}
local fn14

local function fn15()
	if flag2 then
		return
	end

	flag2 = true
	task.spawn(function()
		while true do
			local v20 = table.remove(v18, 1)

			if not v20 then
				break
			end

			if v[v20.UserId] and v8[v20.UserId] == nil then
				local v21 = v20
				local success, result = pcall(function()
					return localPlayer:IsFriendsWith(v21.UserId)
				end)

				if success then
					v8[v20.UserId] = result == true
					v19[v20.UserId] = nil
					local v22 = v[v20.UserId]

					if v22 then
						local v23 = fn13(v22.row)

						if v23 then
							local visible

							if v8[v20.UserId] == true then
								visible = v7[v20.UserId] ~= true
							else
								visible = false
							end

							v23.Visible = visible
						end
					end
				else
					local v22 = (v19[v20.UserId] or 0) + 1
					v19[v20.UserId] = v22
					local v23 = math.min(2 ^ math.min(v22 - 1, 6) * 0.5, 30)
					local v24 = v20
					task.delay(v23, function()
						if v[v24.UserId] and v8[v24.UserId] == nil then
							fn14(v24)
						end
					end)
				end
			end

			task.wait(0.15)
		end

		flag2 = false
	end)
end

fn14 = function(p)
	for _, v20 in ipairs(v18) do
		if v20 == p then
			return
		end
	end

	table.insert(v18, p)
	fn15()
end

local v20 = {}
local v21 = {}

local function fn16(leaderstats)
	local result = {}

	if not leaderstats then
		return result
	end

	for _, valueBase in pairs(leaderstats:GetChildren()) do
		if valueBase:IsA("ValueBase") then
			table.insert(result, {
				instance = valueBase,
				name = valueBase.Name,
				order = tonumber(valueBase:GetAttribute("LeaderboardOrder")) or 1e999
			})
		end
	end

	table.sort(result, function(a, b)
		if a.order == b.order then
			return a.name < b.name
		end

		return a.order < b.order
	end)
	return result
end

local function fn17()
	local leaderboardOrdersByName = {}

	for _, v22 in pairs(Players:GetPlayers()) do
		local leaderstats = v22:FindFirstChild("leaderstats")

		if not leaderstats then
			continue
		end

		for _, valueBase in pairs(leaderstats:GetChildren()) do
			if not valueBase:IsA("ValueBase") then
				continue
			end

			local v23 = leaderboardOrdersByName[valueBase.Name]
			local leaderboardOrder = tonumber(valueBase:GetAttribute("LeaderboardOrder")) or 1e999

			if v23 == nil or leaderboardOrder < v23 then
				leaderboardOrdersByName[valueBase.Name] = leaderboardOrder
			end
		end
	end

	local result = {}

	for k, order in pairs(leaderboardOrdersByName) do
		table.insert(result, {
			name = k,
			order = order
		})
	end

	table.sort(result, function(a, b)
		if a.order == b.order then
			return a.name < b.name
		end

		return a.order < b.order
	end)
	return result
end

local children = clone:FindFirstChild("Children")

local function fn18()
	if not (children and children:IsA("GuiObject")) then
		return
	end

	local total = 0

	for _, guiObject in pairs(childrenFrame:GetChildren()) do
		if guiObject:IsA("GuiObject") and guiObject.Visible then
			total += guiObject.Size.X.Offset
		end
	end

	if total <= 0 then
		return
	end

	children.Size = UDim2.new(0, total + 8, children.Size.Y.Scale, children.Size.Y.Offset)
end

local function fn19()
	local v22 = fn17()
	local v23 = {}

	for _, v24 in pairs(v22) do
		v23[v24.name] = true
	end

	for k, v24 in pairs(v2) do
		if v23[k] then
			continue
		end

		v24:Destroy()
		v2[k] = nil
	end

	for k, v24 in pairs(v22) do
		local clone2 = v2[v24.name]

		if not clone2 then
			clone2 = statHeader:Clone()
			clone2.Name = "stat_" .. v24.name
			local name = v24.name

			if clone2:IsA("TextLabel") then
				clone2.Text = name
			else
				local textLabel = clone2:FindFirstChildWhichIsA("TextLabel", true)

				if textLabel then
					textLabel.Text = name
				end
			end

			clone2.Parent = childrenFrame
			v2[v24.name] = clone2
		end

		if clone2:IsA("GuiObject") then
			clone2.LayoutOrder = k + 1
		end
	end

	fn18()
end

local function fn20()
	for k, v22 in pairs(v3) do
		if v22.Parent then
			local v23 = false

			for _, child in pairs(v22:GetChildren()) do
				if child.Name:sub(1, 12) ~= "PlayerEntry_" then
					continue
				end

				v23 = true
				break
			end

			if not v23 then
				v22:Destroy()
				v3[k] = nil
			end
		else
			v3[k] = nil
		end
	end
end

local function fn21(data)
	local overlayFrame = data.row:FindFirstChild("OverlayFrame", true)

	if overlayFrame then
		for _, child in pairs(overlayFrame:GetChildren()) do
			if child.Name:sub(1, 9) == "GameStat_" then
				child:Destroy()
			end
		end
	end

	for k, statconn in pairs(data.statconns) do
		statconn:Disconnect()
		data.statconns[k] = nil
	end

	for k in pairs(data.statcells) do
		data.statcells[k] = nil
	end
end

local function fn22(instance, data)
	local leaderstats = instance:FindFirstChild("leaderstats")

	if not leaderstats then
		return
	end

	local overlayFrame = data.row:FindFirstChild("OverlayFrame", true)

	if not overlayFrame then
		return
	end

	for k, v22 in pairs((fn16(leaderstats))) do
		local clone2 = gameStat:Clone()
		clone2.Name = "GameStat_" .. v22.name

		if clone2:IsA("GuiObject") then
			clone2.LayoutOrder = k
		end

		clone2.Parent = overlayFrame
		local v23 = fn6(clone2)

		if v23 then
			data.statcells[v22.name] = v23
			v23.Text = fn5(v22.instance.Value)
		end

		local v24 = v22
		data.statconns[v22.name] = v22.instance:GetPropertyChangedSignal("Value"):Connect(function()
			local statcell = data.statcells[v24.name]

			if statcell then
				statcell.Text = fn5(v24.instance.Value)
			end

			if v24.name == "Kills" then
				fn3()
			end
		end)
	end

	fn3()
end

local function fn23(instance, p, instance2)
	for _, lsconn in ipairs(p.lsconns) do
		lsconn:Disconnect()
	end

	table.clear(p.lsconns)
	fn21(p)
	fn22(instance, p)
	fn19()
	table.insert(p.lsconns, instance2.ChildAdded:Connect(function(valueBase)
		if valueBase:IsA("ValueBase") then
			local v22 = instance
			local v23 = p

			if v10[v22.UserId] then
				return
			end

			v10[v22.UserId] = true
			task.defer(function()
				v10[v22.UserId] = nil

				if not v[v22.UserId] then
					return
				end

				local v25 = v23
				fn21(v25)
				fn22(v22, v25)
				fn19()
			end)
		end
	end))
	table.insert(p.lsconns, instance2.ChildRemoved:Connect(function(valueBase)
		if valueBase:IsA("ValueBase") then
			local v22 = instance
			local v23 = p

			if v10[v22.UserId] then
				return
			end

			v10[v22.UserId] = true
			task.defer(function()
				v10[v22.UserId] = nil

				if not v[v22.UserId] then
					return
				end

				local v25 = v23
				fn21(v25)
				fn22(v22, v25)
				fn19()
			end)
		end
	end))
end

local function fn24(button)
	if button:IsA("GuiButton") then
		return button
	end

	local dismissInputHandler = button:FindFirstChild("DismissInputHandler", true)

	if dismissInputHandler and dismissInputHandler:IsA("GuiButton") then
		return dismissInputHandler
	end

	for _, button2 in pairs(button:GetDescendants()) do
		if button2:IsA("GuiButton") then
			return button2
		end
	end

	return nil
end

local v22 = {}

local function fn25(p, tweenInfo3, p2, callback)
	local v23 = v22[p]

	if v23 then
		v23:Cancel()
		v22[p] = nil
	end

	local tween = TweenService:Create(p, tweenInfo3, p2)
	v22[p] = tween
	tween.Completed:Connect(function()
		if v22[p] == tween then
			v22[p] = nil
		end

		if callback then
			callback()
		end
	end)
	tween:Play()
	return tween
end

local function fn26(instance, p)
	local playerEntryContentFrame = instance:FindFirstChild("PlayerEntryContentFrame", true)

	if playerEntryContentFrame and playerEntryContentFrame:IsA("GuiObject") then
		fn25(playerEntryContentFrame, tweenInfo, {
			BackgroundTransparency = p and 0.85 or 1
		})
	end
end

local function fn27(guiObject)
	if not guiObject:IsA("GuiObject") then
		return
	end

	local size = guiObject.Size
	guiObject.Size = UDim2.new(size.X.Scale, 0, size.Y.Scale, size.Y.Offset)
	fn25(guiObject, tweenInfo, {
		Size = size
	})
end

local function fn28(guiObject, fn29)
	if guiObject:IsA("GuiObject") then
		local size = guiObject.Size
		fn25(guiObject, tweenInfo2, {
			Size = UDim2.new(size.X.Scale, 0, size.Y.Scale, size.Y.Offset)
		}, fn29)
	elseif fn29 then
		fn29()
	end
end

local fn29

local function fn30(folder)
	local text = folder:FindFirstChild("Text", true)

	if text and text:IsA("TextLabel") then
		return text
	end

	for _, label in pairs(folder:GetDescendants()) do
		if label:IsA("TextLabel") then
			return label
		end
	end

	return nil
end

local function fn31(clone2, instance, instance2, p)
	local v23 = false

	local function fn32()
		if v23 or not instance.Parent then
			return
		end

		if instance2.HasVerifiedBadge == true then
			v23 = true
			local visible = instance2.HasVerifiedBadge == true and true
			local emoji = clone2:FindFirstChild("Emoji", true)

			if emoji and emoji:IsA("GuiObject") then
				emoji.Visible = visible
			end

			local v26 = instance
			local v27 = instance2
			v26.RichText = true
			v26.TextTruncate = Enum.TextTruncate.AtEnd
			local displayName = v27.DisplayName
			local _ = v27.HasVerifiedBadge == true
			v26.Text = displayName .. (v27.MembershipType ~= Enum.MembershipType.Premium and "" or string.format(
				" <font family=\"%s\">premium</font>",
				"rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"
			))
			task.defer(function()
				if instance.Parent and not instance.TextFits then
					local visible2 = instance2.HasVerifiedBadge == true and false
					local emoji2 = clone2:FindFirstChild("Emoji", true)

					if emoji2 and emoji2:IsA("GuiObject") then
						emoji2.Visible = visible2
					end

					local v30 = instance
					local v31 = instance2
					v30.RichText = true
					v30.TextTruncate = Enum.TextTruncate.AtEnd
					local displayName2 = v31.DisplayName
					local v32 = ""

					if v31.HasVerifiedBadge == true then
						v32 = " "
					elseif v31.MembershipType == Enum.MembershipType.Premium then
						v32 = string.format(
							" <font family=\"%s\">premium</font>",
							"rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"
						)
					end

					v30.Text = displayName2 .. v32
				end

				v23 = false
			end)
		else
			local visible = instance2.HasVerifiedBadge == true and true
			local emoji = clone2:FindFirstChild("Emoji", true)

			if emoji and emoji:IsA("GuiObject") then
				emoji.Visible = visible
			end

			local v26 = instance
			local v27 = instance2
			v26.RichText = true
			v26.TextTruncate = Enum.TextTruncate.AtEnd
			local displayName = v27.DisplayName
			local _ = v27.HasVerifiedBadge == true
			v26.Text = displayName .. (v27.MembershipType ~= Enum.MembershipType.Premium and "" or string.format(
				" <font family=\"%s\">premium</font>",
				"rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"
			))
		end
	end

	fn32()

	if p and p.conns then
		table.insert(p.conns, instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(fn32))
	end

	return fn32
end

local function fn32(friendButton, p)
	if v7[p.UserId] == true then
		local v23 = fn30(friendButton)

		if v23 then
			v23.Text = "BLOCKED"
		end

		local icon = friendButton:FindFirstChild("Icon", true)

		if icon and icon:IsA("TextLabel") then
			icon.Text = "shield-lock"
		end
	else
		local v23 = v8[p.UserId] == true
		local v24 = v6[p.UserId] == true

		if v23 then
			local v25 = fn30(friendButton)

			if v25 then
				v25.Text = "Unfriend"
			end

			local icon = friendButton:FindFirstChild("Icon", true)

			if icon and icon:IsA("TextLabel") then
				icon.Text = "person-circle-slash"
			end
		elseif v24 then
			local v25 = fn30(friendButton)

			if v25 then
				v25.Text = "Cancel Request"
			end

			local icon = friendButton:FindFirstChild("Icon", true)

			if icon and icon:IsA("TextLabel") then
				icon.Text = "circle-slash"
			end
		else
			local v25 = fn30(friendButton)

			if v25 then
				v25.Text = "Friend request"
			end

			local icon = friendButton:FindFirstChild("Icon", true)

			if icon and icon:IsA("TextLabel") then
				icon.Text = "person-plus"
			end
		end
	end
end

local function fn33()
	if not v5 then
		return
	end

	local instance = v5.instance

	if not instance.Parent then
		return
	end

	local innerFrame = instance:FindFirstChild("InnerFrame", true)

	if not innerFrame then
		return
	end

	local friendButton = innerFrame:FindFirstChild("FriendButton")
	local blockButton = innerFrame:FindFirstChild("BlockButton")

	if friendButton then
		fn32(friendButton, v5.player)
	end

	if blockButton then
		if v7[v5.player.UserId] == true then
			local v23 = fn30(blockButton)

			if v23 then
				v23.Text = "Unblock"
			end

			local icon = blockButton:FindFirstChild("Icon", true)

			if icon and icon:IsA("TextLabel") then
				icon.Text = "shield-check"
			end
		else
			local v23 = fn30(blockButton)

			if v23 then
				v23.Text = "Block"
			end

			local icon = blockButton:FindFirstChild("Icon", true)

			if icon and icon:IsA("TextLabel") then
				icon.Text = "circle-slash"
			end
		end
	end
end

local function fn34(instance, guiObject)
	if v5 and v5.player == instance and v5.instance.Parent then
		fn29()
		return
	end

	fn29()
	local clone2 = playerDropdown:Clone()
	clone2.Name = "ActiveDropdown"
	local innerFrame = clone2:FindFirstChild("InnerFrame", true)

	if not innerFrame then
		clone2:Destroy()
		return
	end

	local playerHeader = innerFrame:FindFirstChild("PlayerHeader", true)

	if playerHeader then
		local avatarImage = playerHeader:FindFirstChild("AvatarImage", true)

		if avatarImage and (avatarImage:IsA("ImageLabel") or avatarImage:IsA("ImageButton")) then
			local userId = instance.UserId

			if avatarImage then
				local image = v20[userId]

				if image then
					avatarImage.Image = image
				elseif not (v20[userId] or v21[userId]) then
					v21[userId] = true
					local v24 = nil
					task.spawn(function()
						local success, result = pcall(function()
							return Players:GetUserThumbnailAsync(
								userId,
								Enum.ThumbnailType.HeadShot,
								Enum.ThumbnailSize.Size420x420
							)
						end)
						v21[userId] = nil

						if success and result then
							v20[userId] = result

							if v5 and v5.player.UserId == userId then
								local avatarImage2 = v5.instance:FindFirstChild("AvatarImage", true)

								if avatarImage2 and (avatarImage2:IsA("ImageLabel") or avatarImage2:IsA("ImageButton")) then
									avatarImage2.Image = result
								end
							end

							if v24 then
								v24(result)
							end
						end
					end)
				end
			end
		end

		local displayName = playerHeader:FindFirstChild("DisplayName", true)

		if displayName and displayName:IsA("TextLabel") then
			local v23 = false
			(function()
				if v23 or not displayName.Parent then
					return
				end

				if instance.HasVerifiedBadge == true then
					v23 = true
					local visible = instance.HasVerifiedBadge == true and true
					local emoji = playerHeader:FindFirstChild("Emoji", true)

					if emoji and emoji:IsA("GuiObject") then
						emoji.Visible = visible
					end

					local v26 = displayName
					local v27 = instance
					v26.RichText = true
					v26.TextTruncate = Enum.TextTruncate.AtEnd
					local displayName2 = v27.DisplayName
					local _ = v27.HasVerifiedBadge == true
					v26.Text = displayName2 .. (v27.MembershipType ~= Enum.MembershipType.Premium and "" or string.format(
						" <font family=\"%s\">premium</font>",
						"rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"
					))
					task.defer(function()
						if displayName.Parent and not displayName.TextFits then
							local visible2 = instance.HasVerifiedBadge == true and false
							local emoji2 = playerHeader:FindFirstChild("Emoji", true)

							if emoji2 and emoji2:IsA("GuiObject") then
								emoji2.Visible = visible2
							end

							local v30 = displayName
							local v31 = instance
							v30.RichText = true
							v30.TextTruncate = Enum.TextTruncate.AtEnd
							local displayName3 = v31.DisplayName
							local v32 = ""

							if v31.HasVerifiedBadge == true then
								v32 = " "
							elseif v31.MembershipType == Enum.MembershipType.Premium then
								v32 = string.format(
									" <font family=\"%s\">premium</font>",
									"rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"
								)
							end

							v30.Text = displayName3 .. v32
						end

						v23 = false
					end)
				else
					local visible = instance.HasVerifiedBadge == true and true
					local emoji = playerHeader:FindFirstChild("Emoji", true)

					if emoji and emoji:IsA("GuiObject") then
						emoji.Visible = visible
					end

					local v26 = displayName
					local v27 = instance
					v26.RichText = true
					v26.TextTruncate = Enum.TextTruncate.AtEnd
					local displayName2 = v27.DisplayName
					local _ = v27.HasVerifiedBadge == true
					v26.Text = displayName2 .. (v27.MembershipType ~= Enum.MembershipType.Premium and "" or string.format(
						" <font family=\"%s\">premium</font>",
						"rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"
					))
				end
			end)()
		else
			local v23 = false
			local v24 = nil
			local v25 = nil

			local function fn35()
				if v23 or not v24.Parent then
					return
				end

				if v25.HasVerifiedBadge == true then
					v23 = true
					local visible = v25.HasVerifiedBadge == true and true
					local emoji = instance:FindFirstChild("Emoji", true)

					if emoji and emoji:IsA("GuiObject") then
						emoji.Visible = visible
					end

					local v28 = v24
					local v29 = v25
					v28.RichText = true
					v28.TextTruncate = Enum.TextTruncate.AtEnd
					local displayName2 = v29.DisplayName
					local _ = v29.HasVerifiedBadge == true
					v28.Text = displayName2 .. (v29.MembershipType ~= Enum.MembershipType.Premium and "" or string.format(
						" <font family=\"%s\">premium</font>",
						"rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"
					))
					task.defer(function()
						if v24.Parent and not v24.TextFits then
							local visible2 = v25.HasVerifiedBadge == true and false
							local emoji2 = instance:FindFirstChild("Emoji", true)

							if emoji2 and emoji2:IsA("GuiObject") then
								emoji2.Visible = visible2
							end

							local v32 = v24
							local v33 = v25
							v32.RichText = true
							v32.TextTruncate = Enum.TextTruncate.AtEnd
							local displayName3 = v33.DisplayName
							local v34 = ""

							if v33.HasVerifiedBadge == true then
								v34 = " "
							elseif v33.MembershipType == Enum.MembershipType.Premium then
								v34 = string.format(
									" <font family=\"%s\">premium</font>",
									"rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"
								)
							end

							v32.Text = displayName3 .. v34
						end

						v23 = false
					end)
				else
					local visible = v25.HasVerifiedBadge == true and true
					local emoji = instance:FindFirstChild("Emoji", true)

					if emoji and emoji:IsA("GuiObject") then
						emoji.Visible = visible
					end

					local v28 = v24
					local v29 = v25
					v28.RichText = true
					v28.TextTruncate = Enum.TextTruncate.AtEnd
					local displayName2 = v29.DisplayName
					local _ = v29.HasVerifiedBadge == true
					v28.Text = displayName2 .. (v29.MembershipType ~= Enum.MembershipType.Premium and "" or string.format(
						" <font family=\"%s\">premium</font>",
						"rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"
					))
				end
			end

			fn35()
			local emoji = playerHeader:FindFirstChild("Emoji", true)

			if emoji and emoji:IsA("GuiObject") then
				emoji.Visible = fn35
			end
		end

		local playerName = playerHeader:FindFirstChild("PlayerName", true)

		if playerName and playerName:IsA("TextLabel") then
			playerName.Text = "@" .. instance.Name
		end
	end

	local friendButton = innerFrame:FindFirstChild("FriendButton")
	local inspectButton = innerFrame:FindFirstChild("InspectButton")
	local blockButton = innerFrame:FindFirstChild("BlockButton")
	local v23 = instance == localPlayer
	local visible3 = not v23

	if friendButton and friendButton:IsA("GuiObject") then
		friendButton.Visible = visible3
	end

	local visible4 = not v23

	if blockButton and blockButton:IsA("GuiObject") then
		blockButton.Visible = visible4
	end

	if inspectButton and inspectButton:IsA("GuiObject") then
		inspectButton.Visible = true
	end

	local connections = {}
	local info = innerFrame:FindFirstChild("Info")

	if info then
		local realrank = info:FindFirstChild("realrank", true)
		local rank = info:FindFirstChild("rank", true)

		if realrank or rank then
			local function fn35()
				local v26 = fn10(instance)

				if realrank and (realrank:IsA("TextLabel") or realrank:IsA("TextButton") or realrank:IsA("TextBox")) then
					realrank.Text = string.format(
						"%s · %d",
						v26.name == "Cosmic Threat" and "COSMIC" or v26.name:upper(),
						v26.elo
					)
					fn11(realrank, v26.name)
				end

				if rank and (rank:IsA("ImageLabel") or rank:IsA("ImageButton")) then
					rank.Image = v15[v26.name] or "rbxassetid://125981469994303"
				end
			end

			fn35()
			table.insert(connections, instance:GetAttributeChangedSignal("RankDatas"):Connect(fn35))
			table.insert(connections, instance:GetAttributeChangedSignal("RankPlacements"):Connect(fn35))
		end

		local deviceIcon = info:FindFirstChild("DeviceIcon", true)

		if deviceIcon and deviceIcon:IsA("ImageLabel") then
			local v26 = {
				console = "rbxassetid://129198507017926",
				mobile = "rbxassetid://133053870869209",
				pc = "rbxassetid://82272812405182"
			}

			-- equivalent calls inferred from this helper; original call sites unknown
			local function fn35()
				deviceIcon.Image = v26[instance:GetAttribute("Console") and "console" or instance:GetAttribute("Mobile") and "mobile" or "pc"] or ""
			end

			deviceIcon.Image = v26[instance:GetAttribute("Console") and "console" or instance:GetAttribute("Mobile") and "mobile" or "pc"] or ""
			table.insert(connections, instance:GetAttributeChangedSignal("Console"):Connect(fn35))
			table.insert(connections, instance:GetAttributeChangedSignal("Mobile"):Connect(fn35))

			for _, duration in pairs({ 0.5, 1.5, 3 }) do
				task.delay(duration, function()
					if v5 and v5.player == instance then
						fn35() -- equivalent call inferred; original call site unknown
					end
				end)
			end
		end

		local ping = info:FindFirstChild("Ping", true)

		if ping and ping:IsA("TextLabel") then
			for _, uIGradient in pairs(ping:GetChildren()) do
				if uIGradient:IsA("UIGradient") then
					uIGradient.Enabled = false
				end
			end

			local color = Color3.fromRGB(80, 220, 100)
			local color2 = Color3.fromRGB(230, 200, 60)
			local color3 = Color3.fromRGB(230, 80, 80)
			local color4 = Color3.fromRGB(200, 200, 200)
			ping.RichText = true

			local function fn35()
				local ping2 = instance:GetAttribute("Ping")

				if typeof(ping2) == "number" then
					local v26 = math.ceil(ping2)
					local textColor

					if v26 <= 30 then
						textColor = color
					elseif v26 <= 70 then
						textColor = color:Lerp(color2, (v26 - 30) / 40)
					elseif v26 <= 180 then
						textColor = color2:Lerp(color3, (v26 - 70) / 110)
					else
						textColor = color3
					end

					local v28 = math.floor(textColor.R * 255 + 0.5)
					local v29 = math.floor(textColor.G * 255 + 0.5)
					local v30 = math.floor(textColor.B * 255 + 0.5)
					ping.Text = string.format("<font color=\"rgb(%d,%d,%d)\">%d ms</font>", v28, v29, v30, v26)
					ping.TextColor3 = textColor
				else
					ping.Text = "— ms"
					ping.TextColor3 = color4
				end
			end

			fn35()
			table.insert(connections, instance:GetAttributeChangedSignal("Ping"):Connect(fn35))
		end
	end

	local v26 = inspectButton and fn24(inspectButton)

	if v26 then
		table.insert(connections, v26.Activated:Connect(function()
			shared.sfx({
				SoundId = "rbxassetid://17582213219",
				Parent = workspace,
				Volume = 0.15
			}):Play()
			pcall(function()
				GuiService:InspectPlayerFromUserId(instance.UserId)
			end)
			fn29()
		end))
	end

	if friendButton and not v23 then
		fn32(friendButton, instance)
		local currentButtonContainer = friendButton:FindFirstChild("CurrentButtonContainer")
		local dropDownButton = currentButtonContainer and currentButtonContainer:FindFirstChild("DropDownButton") or nil

		if dropDownButton and dropDownButton:IsA("GuiButton") then
			table.insert(connections, dropDownButton.Activated:Connect(function()
				if v7[instance.UserId] == true then
					return
				end

				shared.sfx({
					SoundId = "rbxassetid://17582213219",
					Parent = workspace,
					Volume = 0.15
				}):Play()
				local v27 = v8[instance.UserId] == true
				local v28 = v6[instance.UserId] == true

				if v27 then
					local v29 = instance
					local v30 = "PromptUnfriend"
					task.spawn(function()
						if pcall(function()
							StarterGui:SetCore(v30, v29)
						end) then
							return
						end

						local lastTime = os.clock()

						repeat
							task.wait(0.1)
						until pcall(function()
							StarterGui:SetCore(v30, v29)
						end) or os.clock() - lastTime > 1
					end)
					v6[instance.UserId] = nil
					v8[instance.UserId] = nil
					local v31 = instance

					if v8[v31.UserId] == nil then
						fn14(v31)
					end

					fn29()
				elseif v28 then
					v6[instance.UserId] = nil
					v8[instance.UserId] = nil
					local v29 = instance

					if v8[v29.UserId] == nil then
						fn14(v29)
					end

					fn32(friendButton, instance)
				else
					local v29 = instance
					local v30 = "PromptSendFriendRequest"
					task.spawn(function()
						if pcall(function()
							StarterGui:SetCore(v30, v29)
						end) then
							return
						end

						local lastTime = os.clock()

						repeat
							task.wait(0.1)
						until pcall(function()
							StarterGui:SetCore(v30, v29)
						end) or os.clock() - lastTime > 1
					end)
					v6[instance.UserId] = true
					v8[instance.UserId] = nil
					local v31 = instance

					if v8[v31.UserId] == nil then
						fn14(v31)
					end

					fn32(friendButton, instance)
				end
			end))
		end
	end

	if blockButton and not v23 then
		if v7[instance.UserId] == true then
			local v27 = fn30(blockButton)

			if v27 then
				v27.Text = "Unblock"
			end

			local icon = blockButton:FindFirstChild("Icon", true)

			if icon and icon:IsA("TextLabel") then
				icon.Text = "shield-check"
			end
		else
			local v27 = fn30(blockButton)

			if v27 then
				v27.Text = "Block"
			end

			local icon = blockButton:FindFirstChild("Icon", true)

			if icon and icon:IsA("TextLabel") then
				icon.Text = "circle-slash"
			end
		end

		local v27 = fn24(blockButton)

		if v27 then
			table.insert(connections, v27.Activated:Connect(function()
				shared.sfx({
					SoundId = "rbxassetid://17582213219",
					Parent = workspace,
					Volume = 0.15
				}):Play()
				local v28 = v7[instance.UserId] == true and "PromptUnblockPlayer" or "PromptBlockPlayer"
				local v29 = instance
				task.spawn(function()
					if pcall(function()
						StarterGui:SetCore(v28, v29)
					end) then
						return
					end

					local lastTime = os.clock()

					repeat
						task.wait(0.1)
					until pcall(function()
						StarterGui:SetCore(v28, v29)
					end) or os.clock() - lastTime > 1
				end)
				fn29()
			end))
		end
	end

	clone2.Parent = scrollingFrameContainer

	if clone2:IsA("GuiObject") then
		clone2.ZIndex = 50
	end

	task.defer(function()
		if not (clone2.Parent and guiObject:IsA("GuiObject") and scrollingFrameContainer:IsA("GuiObject") and clone2:IsA("GuiObject")) then
			return
		end

		local v27 = (guiObject:FindFirstChild("PlayerEntryContentFrame", true) or guiObject).AbsolutePosition.Y - scrollingFrameContainer.AbsolutePosition.Y
		local position2 = clone2.Position
		clone2.Position = UDim2.new(position2.X.Scale, position2.X.Offset, 0, v27)
		fn27(clone2)
	end)
	fn26(guiObject, true)
	table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB then
			fn29()
		end
	end))
	table.insert(connections, UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch or not (clone2.Parent and clone:IsA("GuiObject") and clone2:IsA("GuiObject")) then
			return
		end

		local position2 = input.Position
		local absolutePosition = clone.AbsolutePosition
		local absoluteSize = clone.AbsoluteSize

		if position2.X >= absolutePosition.X and position2.X <= absolutePosition.X + absoluteSize.X and position2.Y >= absolutePosition.Y and position2.Y <= absolutePosition.Y + absoluteSize.Y then
			return
		end

		local absolutePosition2 = clone2.AbsolutePosition
		local absoluteSize2 = clone2.AbsoluteSize

		if position2.X >= absolutePosition2.X and position2.X <= absolutePosition2.X + absoluteSize2.X and position2.Y >= absolutePosition2.Y and position2.Y <= absolutePosition2.Y + absoluteSize2.Y then
			return
		end

		fn29()
	end))
	table.insert(connections, Players.PlayerRemoving:Connect(function(player)
		if player == instance then
			fn29()
		end
	end))
	v5 = {
		instance = clone2,
		player = instance,
		conns = connections
	}
end

fn29 = function()
	if not v5 then
		return
	end

	local v23 = v5
	v5 = nil
	local conns = v23.conns

	for _, conn in ipairs(conns) do
		conn:Disconnect()
	end

	table.clear(conns)
	local v24 = v[v23.player.UserId]

	if v24 then
		fn26(v24.row, false)
	end

	local flag3 = false

	local function fn35()
		if flag3 then
			return
		end

		flag3 = true

		if v23.instance and v23.instance.Parent then
			v23.instance:Destroy()
		end
	end

	fn28(v23.instance, fn35)
	task.delay(0.225, fn35)
end

local function fn35()
	if not v5 then
		return
	end

	local v23 = v5
	v5 = nil
	local conns = v23.conns

	for _, conn in ipairs(conns) do
		conn:Disconnect()
	end

	table.clear(conns)
	local v24 = v[v23.player.UserId]

	if v24 then
		fn26(v24.row, false)
	end

	if v23.instance and v23.instance:IsA("GuiObject") then
		v23.instance.Visible = false
	end

	if v23.instance and v23.instance.Parent then
		v23.instance:Destroy()
	end
end

local function onPlayerAdded(instance)
	if v[instance.UserId] then
		return
	end

	local userId = instance.UserId

	if not (v20[userId] or v21[userId]) then
		v21[userId] = true
		local v23 = nil
		task.spawn(function()
			local success, result = pcall(function()
				return Players:GetUserThumbnailAsync(
					userId,
					Enum.ThumbnailType.HeadShot,
					Enum.ThumbnailSize.Size420x420
				)
			end)
			v21[userId] = nil

			if success and result then
				v20[userId] = result

				if v5 and v5.player.UserId == userId then
					local avatarImage = v5.instance:FindFirstChild("AvatarImage", true)

					if avatarImage and (avatarImage:IsA("ImageLabel") or avatarImage:IsA("ImageButton")) then
						avatarImage.Image = result
					end
				end

				if v23 then
					v23(result)
				end
			end
		end)
	end

	local clone2 = playerEntry:Clone()
	clone2.Name = "PlayerEntry_" .. instance.UserId
	local overlayFrame = clone2:FindFirstChild("OverlayFrame", true)

	if overlayFrame then
		for _, child in pairs(overlayFrame:GetChildren()) do
			if child.Name:sub(1, 9) == "GameStat_" then
				child:Destroy()
			end
		end
	end

	local v23 = fn7(clone2)
	fn4(clone2, v11[instance.UserId] == true and "dev" or v12[instance.UserId] == true and "tester" or nil, instance)

	if v11[instance.UserId] ~= true and v12[instance.UserId] ~= true then
		fn12(clone2, instance)
	end

	local avatarImage = clone2:FindFirstChild("AvatarImage")

	if avatarImage and avatarImage:IsA("ImageLabel") then
		avatarImage.Visible = localPlayer:GetAttribute("S_HideRanks") ~= true
	end

	if clone2:IsA("GuiObject") then
		clone2.Active = true
	end

	local v24 = not instance.Team and "Neutral" or instance.Team.Name
	local clone3 = v3[v24]

	if not (clone3 and clone3.Parent) then
		clone3 = teamList:Clone()
		clone3.Name = "TeamList_" .. v24

		if clone3:IsA("GuiObject") then
			clone3.LayoutOrder = instance.Team and 1 or 999
		end

		clone3.Parent = offsetUndoFrame
		v3[v24] = clone3
	end

	clone2.Parent = clone3
	local v25 = {
		player = instance,
		row = clone2,
		statcells = {},
		statconns = {},
		lsconns = {},
		conns = {}
	}
	v[instance.UserId] = v25
	local v26 = nil

	if v23 then
		v26 = fn31(clone2, v23, instance, v25)
	else
		local v27 = false
		local v28 = nil
		local v29 = nil

		local function fn36()
			if v27 or not v28.Parent then
				return
			end

			if v29.HasVerifiedBadge == true then
				v27 = true
				local visible = v29.HasVerifiedBadge == true and true
				local emoji = instance:FindFirstChild("Emoji", true)

				if emoji and emoji:IsA("GuiObject") then
					emoji.Visible = visible
				end

				local v32 = v28
				local v33 = v29
				v32.RichText = true
				v32.TextTruncate = Enum.TextTruncate.AtEnd
				local displayName = v33.DisplayName
				local _ = v33.HasVerifiedBadge == true
				v32.Text = displayName .. (v33.MembershipType ~= Enum.MembershipType.Premium and "" or string.format(
					" <font family=\"%s\">premium</font>",
					"rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"
				))
				task.defer(function()
					if v28.Parent and not v28.TextFits then
						local visible2 = v29.HasVerifiedBadge == true and false
						local emoji2 = instance:FindFirstChild("Emoji", true)

						if emoji2 and emoji2:IsA("GuiObject") then
							emoji2.Visible = visible2
						end

						local v36 = v28
						local v37 = v29
						v36.RichText = true
						v36.TextTruncate = Enum.TextTruncate.AtEnd
						local displayName2 = v37.DisplayName
						local v38 = ""

						if v37.HasVerifiedBadge == true then
							v38 = " "
						elseif v37.MembershipType == Enum.MembershipType.Premium then
							v38 = string.format(
								" <font family=\"%s\">premium</font>",
								"rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"
							)
						end

						v36.Text = displayName2 .. v38
					end

					v27 = false
				end)
			else
				local visible = v29.HasVerifiedBadge == true and true
				local emoji = instance:FindFirstChild("Emoji", true)

				if emoji and emoji:IsA("GuiObject") then
					emoji.Visible = visible
				end

				local v32 = v28
				local v33 = v29
				v32.RichText = true
				v32.TextTruncate = Enum.TextTruncate.AtEnd
				local displayName = v33.DisplayName
				local _ = v33.HasVerifiedBadge == true
				v32.Text = displayName .. (v33.MembershipType ~= Enum.MembershipType.Premium and "" or string.format(
					" <font family=\"%s\">premium</font>",
					"rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"
				))
			end
		end

		fn36()
		local emoji = clone2:FindFirstChild("Emoji", true)

		if emoji and emoji:IsA("GuiObject") then
			emoji.Visible = fn36
		end
	end

	local v27 = fn13(clone2)

	if v27 then
		local visible

		if v8[instance.UserId] == true then
			visible = v7[instance.UserId] ~= true
		else
			visible = false
		end

		v27.Visible = visible
	end

	if v8[instance.UserId] == nil then
		fn14(instance)
	end

	local leaderstats = instance:FindFirstChild("leaderstats")

	if leaderstats then
		fn23(instance, v25, leaderstats)
	end

	local playerEntryContentFrame = clone2:FindFirstChild("PlayerEntryContentFrame")

	if playerEntryContentFrame and playerEntryContentFrame:IsA("GuiButton") then
		table.insert(v25.conns, playerEntryContentFrame.Activated:Connect(function()
			shared.sfx({
				SoundId = "rbxassetid://17582213219",
				Parent = workspace,
				Volume = 0.15
			}):Play()
			fn34(instance, clone2)
		end))
	elseif clone2:IsA("GuiObject") then
		local textButton = Instance.new("TextButton")
		textButton.Size = UDim2.fromScale(1, 1)
		textButton.Position = UDim2.fromScale(0, 0)
		textButton.BackgroundTransparency = 1
		textButton.Text = ""
		textButton.Parent = clone2
		table.insert(v25.conns, textButton.Activated:Connect(function()
			shared.sfx({
				SoundId = "rbxassetid://17582213219",
				Parent = workspace,
				Volume = 0.15
			}):Play()
			fn34(instance, clone2)
		end))
	end

	table.insert(v25.conns, instance.ChildAdded:Connect(function(folder)
		if folder.Name == "leaderstats" and folder:IsA("Folder") then
			fn23(instance, v25, folder)
		end
	end))
	table.insert(v25.conns, instance.ChildRemoved:Connect(function(child)
		if child.Name == "leaderstats" then
			fn21(v25)
			fn19()
		end
	end))
	table.insert(v25.conns, instance:GetPropertyChangedSignal("DisplayName"):Connect(function()
		if v26 then
			v26()
			return
		end

		local v28 = fn7(clone2)

		if v28 then
			local v29 = instance
			v28.RichText = true
			v28.TextTruncate = Enum.TextTruncate.AtEnd
			local displayName = v29.DisplayName
			local _ = v29.HasVerifiedBadge == true
			v28.Text = displayName .. (v29.MembershipType ~= Enum.MembershipType.Premium and "" or string.format(
				" <font family=\"%s\">premium</font>",
				"rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"
			))
		end
	end))
	table.insert(v25.conns, instance:GetPropertyChangedSignal("Team"):Connect(function()
		local v28 = instance
		local v29 = not v28.Team and "Neutral" or v28.Team.Name
		local clone4 = v3[v29]

		if not (clone4 and clone4.Parent) then
			clone4 = teamList:Clone()
			clone4.Name = "TeamList_" .. v29

			if clone4:IsA("GuiObject") then
				clone4.LayoutOrder = v28.Team and 1 or 999
			end

			clone4.Parent = offsetUndoFrame
			v3[v29] = clone4
		end

		if clone2.Parent ~= clone4 then
			clone2.Parent = clone4
			fn20()
		end

		fn3()
	end))

	local function fn36()
		local v28 = instance

		if v11[v28.UserId] == true or v12[v28.UserId] == true then
			return warn("d")
		end

		local avatarImage2 = clone2:FindFirstChild("AvatarImage", true)

		if avatarImage2 and avatarImage2:IsA("ImageLabel") then
			avatarImage2.Image = v15[fn10(instance).name] or "rbxassetid://125981469994303"
		end
	end

	table.insert(v25.conns, instance:GetAttributeChangedSignal("RankDatas"):Connect(fn36))
	table.insert(v25.conns, instance:GetAttributeChangedSignal("RankPlacements"):Connect(fn36))
end

local function onPlayerRemoving(p)
	local v23 = v[p.UserId]

	if not v23 then
		return
	end

	for _, conn in ipairs(v23.conns) do
		conn:Disconnect()
	end

	for _, lsconn in ipairs(v23.lsconns) do
		lsconn:Disconnect()
	end

	for _, statconn in pairs(v23.statconns) do
		statconn:Disconnect()
	end

	if v23.row.Parent then
		v23.row:Destroy()
	end

	v[p.UserId] = nil
	v9[p.UserId] = nil
	v8[p.UserId] = nil
	v19[p.UserId] = nil
	v10[p.UserId] = nil
	fn20()
	fn19()
	fn3()

	if v5 and v5.player == p then
		fn29()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fn36(p)
	v4 = p

	if offsetFrame and offsetFrame:IsA("GuiObject") and position then
		local v23 = offsetFrame

		if p then
			if clone:IsA("GuiObject") then
				clone.Visible = true
			end

			fn25(v23, tweenInfo, {
				Position = position
			})
		else
			local X = v23.AbsoluteSize.X
			fn25(v23, tweenInfo2, {
				Position = UDim2.new(position.X.Scale, position.X.Offset + X + 32, position.Y.Scale, position.Y.Offset)
			}, function()
				if not v4 and clone:IsA("GuiObject") then
					clone.Visible = false
				end

				fn35()
			end)
		end
	else
		if clone:IsA("GuiObject") then
			clone.Visible = p
		else
			clone.Enabled = p
		end

		if not p then
			fn29()
		end
	end
end

if dismissButton:IsA("GuiButton") then
	dismissButton.Activated:Connect(function()
		shared.sfx({
			SoundId = "rbxassetid://17582213219",
			Parent = workspace,
			Volume = 0.15
		}):Play()
		fn36(false)
	end)
end

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Tab or input.KeyCode == Enum.KeyCode.ButtonSelect then
		fn36(not v4)
	end
end)

if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
	local textButton = Instance.new("TextButton")
	textButton.Name = "ShowListButton"
	textButton.Size = UDim2.fromOffset(48, 48)
	textButton.Position = UDim2.new(1, -56, 0, 8)
	textButton.AnchorPoint = Vector2.new(0, 0)
	textButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	textButton.BackgroundTransparency = 0.3
	textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	textButton.Font = Enum.Font.GothamBold
	textButton.TextSize = 22
	textButton.Text = "≡"
	textButton.AutoButtonColor = true
	textButton.Visible = false
	textButton.Parent = screenGui
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 10)
	uICorner.Parent = textButton
	textButton.Activated:Connect(function()
		shared.sfx({
			SoundId = "rbxassetid://17582213219",
			Parent = workspace,
			Volume = 0.15
		}):Play()
		fn36(true) -- equivalent call inferred; original call site unknown
	end)

	if clone:IsA("GuiObject") then
		clone:GetPropertyChangedSignal("Visible"):Connect(function()
			textButton.Visible = not clone.Visible
		end)
	end
end

local function fn37(p)
	local lastTime = os.clock()
	local result

	while true do
		local success
		success, result = pcall(function()
			return StarterGui:GetCore(p)
		end)

		if success and result then
			break
		end

		task.wait(0.1)

		if os.clock() - lastTime > 2 then
			return nil
		end
	end

	local event = result.Event

	if typeof(event) == "RBXScriptSignal" then
		return event
	end

	if typeof(result) == "RBXScriptSignal" then
		return result
	end

	return nil
end

task.spawn(function()
	local lastTime = os.clock()
	local result

	while true do
		local success
		success, result = pcall(function()
			return StarterGui:GetCore("GetBlockedUserIds")
		end)

		if success and typeof(result) == "table" then
			break
		end

		task.wait(0.2)

		if os.clock() - lastTime > 3 then
			return
		end
	end

	for _, v23 in pairs(result) do
		if typeof(v23) ~= "number" then
			continue
		end

		v7[v23] = true
		local v24 = v[v23]

		if not (v24 and v24.player) then
			continue
		end

		local row = v24.row
		local player = v24.player
		local v25 = fn13(row)

		if not v25 then
			continue
		end

		local visible

		if v8[player.UserId] == true then
			visible = v7[player.UserId] ~= true
		else
			visible = false
		end

		v25.Visible = visible
	end

	fn33()
end)
task.spawn(function()
	local v23 = fn37("PlayerBlockedEvent")

	if not v23 then
		return
	end

	v23:Connect(function(userId)
		if typeof(userId) == "Instance" and userId:IsA("Player") then
			userId = userId.UserId
		elseif typeof(userId) ~= "number" then
			userId = nil
		end

		if not userId then
			return
		end

		v7[userId] = true
		v8[userId] = false
		v6[userId] = nil
		local v24 = v[userId]

		if v24 and v24.player then
			local row = v24.row
			local player = v24.player
			local v25 = fn13(row)

			if v25 then
				local visible

				if v8[player.UserId] == true then
					visible = v7[player.UserId] ~= true
				else
					visible = false
				end

				v25.Visible = visible
			end
		end

		fn33()
	end)
end)
task.spawn(function()
	local v23 = fn37("PlayerUnblockedEvent")

	if not v23 then
		return
	end

	v23:Connect(function(userId)
		if typeof(userId) == "Instance" and userId:IsA("Player") then
			userId = userId.UserId
		elseif typeof(userId) ~= "number" then
			userId = nil
		end

		if not userId then
			return
		end

		v7[userId] = nil
		local v24 = v[userId]

		if v24 and v24.player then
			local row = v24.row
			local player = v24.player
			local v25 = fn13(row)

			if v25 then
				local visible

				if v8[player.UserId] == true then
					visible = v7[player.UserId] ~= true
				else
					visible = false
				end

				v25.Visible = visible
			end
		end

		fn33()
	end)
end)
task.spawn(function()
	local v23 = fn37("PlayerFriendedEvent")

	if not v23 then
		return
	end

	v23:Connect(function(userId)
		if typeof(userId) == "Instance" and userId:IsA("Player") then
			userId = userId.UserId
		elseif typeof(userId) ~= "number" then
			userId = nil
		end

		if not userId then
			return
		end

		v8[userId] = true
		v6[userId] = nil
		local v24 = v[userId]

		if v24 and v24.player then
			local row = v24.row
			local player = v24.player
			local v25 = fn13(row)

			if v25 then
				local visible

				if v8[player.UserId] == true then
					visible = v7[player.UserId] ~= true
				else
					visible = false
				end

				v25.Visible = visible
			end
		end

		fn33()
	end)
end)
task.spawn(function()
	local v23 = fn37("PlayerUnfriendedEvent")

	if not v23 then
		return
	end

	v23:Connect(function(userId)
		if typeof(userId) == "Instance" and userId:IsA("Player") then
			userId = userId.UserId
		elseif typeof(userId) ~= "number" then
			userId = nil
		end

		if not userId then
			return
		end

		v8[userId] = false
		v6[userId] = nil
		local v24 = v[userId]

		if v24 and v24.player then
			local row = v24.row
			local player = v24.player
			local v25 = fn13(row)

			if v25 then
				local visible

				if v8[player.UserId] == true then
					visible = v7[player.UserId] ~= true
				else
					visible = false
				end

				v25.Visible = visible
			end
		end

		fn33()
	end)
end)
task.spawn(function()
	while true do
		task.wait(60)

		for k, v23 in pairs(v) do
			local player = v23.player

			if not (player and player ~= localPlayer) then
				continue
			end

			v8[k] = nil
			v19[k] = nil
			fn14(player)
		end
	end
end)
localPlayer:GetAttributeChangedSignal("S_HideRanks"):Connect(function()
	for _, v23 in pairs(v) do
		local avatarImage = v23.row:FindFirstChild("AvatarImage")

		if avatarImage and avatarImage:IsA("ImageLabel") then
			avatarImage.Visible = localPlayer:GetAttribute("S_HideRanks") ~= true
		end
	end
end)

for _, v23 in pairs(Players:GetPlayers()) do
	onPlayerAdded(v23)
end

fn19()
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local Info = require(game.ReplicatedStorage.Info)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
localPlayer:GetMouse()
local ranked = ReplicatedStorage:WaitForChild("Ranked")
local v = {
	queuehandler = ranked:WaitForChild("QueueHandler"),
	receiver = ranked:WaitForChild("Receiver")
}
local RANKTIERS = {
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

local function fn(json)
	if typeof(json) ~= "string" or json == "" then
		return {}
	end

	local success, result = pcall(function()
		return HttpService:JSONDecode(json)
	end)

	if success and typeof(result) == "table" then
		return result
	end

	return {}
end

local function fn2(p, p2)
	local v3 = RANKTIERS[p2]

	if not v3 then
		return nil
	end

	local v4 = math.max(0, tonumber(p) or 0)

	for i, v5 in ipairs(v3) do
		if not (v5.min <= v4) then
			continue
		end

		local v6 = v3[i - 1]
		local result = {
			name = v5.name,
			min = v5.min,
			next = 0,
			nextmin = 0
		}
		local next2

		if v6 then
			next2 = v6.name or nil
		end

		result.next = next2
		result.nextmin = v6 and v6.min or nil
		return result
	end

	return {
		name = "Unranked",
		min = 0
	}
end

shared.RankedClient = shared.RankedClient or {}

function shared.RankedClient.getRankInfo(mode)
	if not RANKTIERS[mode] then
		return nil
	end

	local elo = tonumber(fn(localPlayer:GetAttribute("RankDatas"))[mode]) or 0
	local placementProgress = tonumber(fn(localPlayer:GetAttribute("RankPlacements"))[mode]) or 0
	local inPlacements = placementProgress < 10
	local v6 = fn2(elo, mode)
	local v7 = {
		mode = mode,
		elo = elo,
		tier = (inPlacements or not v6) and "Unranked" or v6.name or "Unranked",
		tierMin = not v6 and 0 or v6.min or 0,
		nextTier = 0,
		nextTierMin = 0,
		inPlacements = 0,
		placementProgress = 0,
		placementTarget = 10
	}
	local nextTier

	if v6 then
		nextTier = v6.next or nil
	end

	v7.nextTier = nextTier
	v7.nextTierMin = v6 and v6.nextmin or nil
	v7.inPlacements = inPlacements
	v7.placementProgress = placementProgress
	return v7
end

shared.RankedClient.RANKTIERS = RANKTIERS
local v3 = {
	Unranked = "rbxassetid://125981469994303",
	Wolf = "rbxassetid://78355287626071",
	Tiger = "rbxassetid://76227211350676",
	Demon = "rbxassetid://83066656945371",
	Dragon = "rbxassetid://104728265939518",
	["Cosmic Threat"] = "rbxassetid://111531290254363",
	Calamity = "rbxassetid://98907003282973",
	God = "rbxassetid://106265317134078"
}
local v4 = {
	Unranked = { Color3.fromRGB(200, 200, 200), Color3.fromRGB(120, 120, 120) },
	Wolf = { Color3.fromRGB(225, 235, 245), Color3.fromRGB(110, 135, 165) },
	Tiger = { Color3.fromRGB(255, 170, 55), Color3.fromRGB(170, 70, 20) },
	Demon = { Color3.fromRGB(225, 50, 50), Color3.fromRGB(75, 8, 14) },
	Dragon = { Color3.fromRGB(255, 205, 70), Color3.fromRGB(35, 130, 70) },
	["Cosmic Threat"] = { Color3.fromRGB(170, 100, 240), Color3.fromRGB(55, 90, 220) },
	Calamity = { Color3.fromRGB(245, 245, 245), Color3.fromRGB(20, 20, 20) },
	God = { Color3.fromRGB(255, 255, 240), Color3.fromRGB(255, 210, 75) }
}
local v5 = {
	["Cosmic Threat"] = {
		sequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 50, 160)),
			ColorSequenceKeypoint.new(0.3, Color3.fromRGB(160, 110, 230)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 200, 255)),
			ColorSequenceKeypoint.new(0.7, Color3.fromRGB(110, 140, 230)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 70, 180))
		}),
		animate = function(p, p2)
			local v6 = math.sin(p2 * 1.15) * 0.38 + math.sin(p2 * 0.62 + 1.7) * 0.14
			local v7 = math.cos(p2 * 0.47 + 0.8) * 0.09 + math.sin(p2 * 0.93) * 0.05
			p.Offset = Vector2.new(v6, v7)
			p.Rotation = math.sin(p2 * 0.31) * 12
		end
	},
	Calamity = {
		sequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
			ColorSequenceKeypoint.new(0.3, Color3.fromRGB(80, 80, 80)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(245, 245, 245)),
			ColorSequenceKeypoint.new(0.7, Color3.fromRGB(80, 80, 80)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))
		}),
		animate = function(p, p2)
			local v6 = math.sin(p2 * 1.15) * 0.38 + math.sin(p2 * 0.62 + 1.7) * 0.14
			local v7 = math.cos(p2 * 0.47 + 0.8) * 0.09 + math.sin(p2 * 0.93) * 0.05
			p.Offset = Vector2.new(-v6, -v7)
			p.Rotation = -math.sin(p2 * 0.31) * 12
		end
	},
	God = {
		sequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 100)),
			ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 245)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 235, 175)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 245)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 210, 80))
		}),
		animate = function(p, p2)
			local v6 = math.sin(p2 * 0.4) * 0.15 + 1
			p.Rotation = p2 * 24 * v6 % 360
			p.Offset = Vector2.new(math.sin(p2 * 0.55) * 0.12, math.cos(p2 * 0.41 + 0.3) * 0.07)
		end
	}
}
local v6 = {}
local lastTime = tick()
local heartbeatConnection = nil

local function onHeartbeat()
	local v7 = tick() - lastTime

	for k, v8 in pairs(v6) do
		if k.Parent then
			local v9 = v5[v8.tier]

			if v9 and v9.animate then
				v9.animate(k, v7 + v8.phase)
			end
		else
			v6[k] = nil
		end
	end
end

local visible = false
local visible2 = false
local ranked2 = playerGui:WaitForChild("Ranked")
local container = ranked2:WaitForChild("Container")
local rankedOther = container:WaitForChild("RankedOther")
local matchSearch = container:WaitForChild("MatchSearch")
task.delay(0.15, function()
	if UserInputService.TouchEnabled then
		matchSearch.Position = UDim2.new(0.5, 0, 1, -130)
	end
end)
local modeContainer = rankedOther:WaitForChild("ModeContainer")
local list = modeContainer:WaitForChild("List")
local rankedSwitch = modeContainer:WaitForChild("RankedSwitch")
local BACK = modeContainer:WaitForChild("BACK")
local regionVisible = modeContainer:WaitForChild("RegionVisible")
local playerHolder = modeContainer:WaitForChild("PlayerHolder")
local inviteUi = modeContainer:WaitForChild("InviteUi")
local receiver = inviteUi:WaitForChild("Receiver")
local scrollingFrame = receiver:WaitForChild("ScrollingFrame")
local textBox = receiver:WaitForChild("TextBox")
local dominant = playerHolder:WaitForChild("Dominant")
local counter = matchSearch:WaitForChild("Counter")
local modeWorker = matchSearch:WaitForChild("ModeWorker")
local uIGradient = matchSearch:WaitForChild("RealOverlay"):WaitForChild("UIGradient")
local color = Color3.fromRGB(72, 72, 72)
Color3.fromRGB(236, 154, 57)
local color2 = Color3.fromRGB(0, 125, 6)
local v7 = {
	["1v1"] = "rbxassetid://133795601107199",
	["1v1s"] = "rbxassetid://133795601107199",
	["2v2"] = "rbxassetid://117169709077351",
	["2v2s"] = "rbxassetid://117169709077351",
	["3v3"] = "rbxassetid://139669726267144",
	["3v3s"] = "rbxassetid://139669726267144"
}
spawn(function()
	local clone = table.clone(v7)

	for _, v8 in pairs({ "rbxassetid://93030332650834", "rbxassetid://89030584766632" }) do
		table.insert(clone, v8)
	end

	if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("MobileJunk") then
		return
	end

	for _, image in pairs(v7) do
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Image = image
		imageLabel.Size = UDim2.new(0, 0.001, 0, 0.001)
		imageLabel.Parent = game.Players.LocalPlayer.PlayerGui.MobileJunk
		game.Debris:AddItem(imageLabel, 1)
	end
end)
BACK.Visible = false
regionVisible.GameFrame.Visible = false
local holder = modeContainer:WaitForChild("holder")
local rankplate = script:WaitForChild("rankplate")
local rankVisibility = modeContainer:WaitForChild("RankVisibility")
local fake = modeContainer:WaitForChild("fake")
local rankplate2 = script:WaitForChild("rankplate2")
local clones = {}

local function fn3(p)
	local v8 = tostring((math.floor(tonumber(p) or 0)))

	repeat
		local v9
		v8, v9 = v8:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
	until v9 == 0

	return v8
end

local function fn4(instance, tier)
	if not instance then
		return
	end

	local uIGradient2 = instance:FindFirstChildOfClass("UIGradient")

	if not uIGradient2 then
		return
	end

	local v8 = v5[tier]

	if v8 then
		uIGradient2.Color = v8.sequence
		local v9 = v6[uIGradient2]

		if not v9 or v9.tier ~= tier then
			v6[uIGradient2] = {
				tier = tier,
				phase = math.random() * 100
			}
		end
	else
		if v6[uIGradient2] then
			v6[uIGradient2] = nil
			uIGradient2.Offset = Vector2.new(0, 0)
			uIGradient2.Rotation = 0
		end

		local v9 = v4[tier]

		if not v9 then
			return
		end

		uIGradient2.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, v9[1]),
			ColorSequenceKeypoint.new(1, v9[2])
		})
	end
end

local v8 = {}
local v9 = {}
local v10 = {}
local v11 = {}
local clones2 = {}
local v12 = {}
local v13 = "idle"
local flag = false
local connection = nil
local flag2 = false
local flag3 = false
local v14 = nil
local v15 = nil
local v16 = 0
local thread = nil
local flag4 = false
local v17 = { "1v1s", "2v2s", "3v3s" }
local v18 = 0
local thread2 = nil
local v19 = false
local flag5 = false
local clone = nil

for _, guiObject in ipairs(holder:GetChildren()) do
	if guiObject:IsA("GuiObject") and guiObject.Name ~= "UIListLayout" and guiObject.Name ~= "UIGridLayout" then
		guiObject:Destroy()
	end
end

local line = script:WaitForChild("line")
local v20 = { "1v1s", "2v2s", "3v3s" }

for i, name2 in ipairs(v20) do
	local clone2 = rankplate:Clone()
	clone2.Name = name2
	clone2.LayoutOrder = 2 * i - 1
	clone2.Parent = holder
	clones[name2] = clone2

	if name2 ~= "1v1s" then
		clone2.mode.Position = UDim2.new(0.55, 0, 0.15, 0)
	end

	if not (i < #v20) then
		continue
	end

	local clone3 = line:Clone()
	clone3.LayoutOrder = 2 * i
	clone3.Parent = holder
end

local function fn5(value)
	local v21 = clones[value]

	if not (v21 and v21.Parent) then
		return
	end

	localPlayer:GetAttribute("RankDatas")
	local v22 = tonumber(fn(localPlayer:GetAttribute("RankDatas"))[value]) or 0
	local v23 = fn2(v22, value)
	local tier = not v23 and "Unranked" or v23.name or "Unranked"
	local v25 = {}

	for _, child in ipairs(v21:GetChildren()) do
		table.insert(v25, child.Name)
	end

	local mode = v21:FindFirstChild("mode")

	if mode then
		mode.Text = value:gsub("s$", "")
	end

	local elo = v21:FindFirstChild("elo")

	if elo then
		elo.Text = fn3(v22)
		fn4(elo, tier)
	end

	local rank = v21:FindFirstChild("rank")

	if rank and (rank:IsA("ImageLabel") or rank:IsA("ImageButton")) then
		rank.Image = v3[tier] or "rbxassetid://125981469994303"
	end

	local current = v21:FindFirstChild("current")

	if current then
		current.Text = tier:upper()
	end

	local next2 = v23 and v23.next
	local nextmin = v23 and v23.nextmin
	local target = v21:FindFirstChild("target")
	local data = v21:FindFirstChild("data")
	local v26

	if nextmin then
		if target then
			target.Text = next2 and next2:upper() or ""
		end

		if data then
			data.Text = string.format("%d/%d", v22, nextmin)
		end

		v26 = math.clamp(v22 / nextmin, 0, 1)
	else
		if target then
			target.Text = "MAX"
		end

		if data then
			data.Text = fn3(v22) .. " ELO"
		end

		v26 = 1
	end

	local realfiller = v21:FindFirstChild("barback") and v21.barback:FindFirstChild("realfiller")

	if realfiller then
		if v8[value] then
			v8[value]:Cancel()
		end

		v8[value] = TweenService:Create(
			realfiller,
			TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = UDim2.new(v26, 0, 1, 0)
			}
		)
		v8[value]:Play()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fn6()
	for k in pairs(clones) do
		fn5(k)
	end
end

task.delay(1.5, function()
	local lastTime2 = tick()

	repeat
		task.wait(0.25)
	until localPlayer:GetAttribute("RankDatas") or tick() - lastTime2 >= 4.5

	wait(0.5)
	localPlayer:GetAttributeChangedSignal("RankDatas"):Connect(fn6)
	localPlayer:GetAttributeChangedSignal("RankPlacements"):Connect(fn6)
	fn6() -- equivalent call inferred; original call site unknown
end)
holder.Visible = false
rankedSwitch.MouseButton1Click:Connect(function()
	shared.sfx({
		SoundId = "rbxassetid://6895079853",
		Parent = Workspace,
		Volume = 0.5
	}):Play()

	if holder.Visible then
		holder.Visible = false
		return
	end

	fake.Visible = false
	holder.Visible = true
	fn6() -- equivalent call inferred; original call site unknown
end)
local flag6 = false

local function fn7()
	if flag6 then
		return
	end

	flag6 = true

	for _, guiObject in ipairs(fake:GetChildren()) do
		if guiObject:IsA("GuiObject") and guiObject.Name ~= "UIListLayout" and guiObject.Name ~= "UIGridLayout" then
			guiObject:Destroy()
		end
	end

	local _1v1s = RANKTIERS["1v1s"]
	local count = #_1v1s

	for i = 1, count do
		local _1v1 = _1v1s[count - i + 1]
		local clone2 = rankplate2:Clone()
		clone2.Name = _1v1.name
		clone2.LayoutOrder = i
		clone2.target.Text = _1v1.name:upper()
		clone2.elo.Text = fn3(_1v1.min)
		fn4(clone2.elo, _1v1.name)
		fn4(clone2.target, _1v1.name)

		if clone2:FindFirstChild("rank") and clone2.rank:IsA("ImageLabel") then
			clone2.rank.Image = v3[_1v1.name] or "rbxassetid://78355287626071"
		end

		clone2.Parent = fake
	end
end

local uIGridLayout = fake:FindFirstChildOfClass("UIGridLayout") or fake:FindFirstChildOfClass("UIListLayout")
fake:FindFirstChildOfClass("UIPadding")

-- equivalent calls inferred from this helper; original call sites unknown
local function fn8()
	if uIGridLayout then
		fake.CanvasSize = UDim2.new(0, 0, 0, uIGridLayout.AbsoluteContentSize.Y + 20)
	end
end

if uIGridLayout then
	fn8() -- equivalent call inferred; original call site unknown
	uIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(fn8)
end

fake.Visible = false
rankVisibility.MouseButton1Click:Connect(function()
	shared.sfx({
		SoundId = "rbxassetid://6895079853",
		Parent = Workspace,
		Volume = 0.25
	}):Play()

	if fake.Visible then
		fake.Visible = false
		return
	end

	holder.Visible = false

	if not flag6 then
		fn7()
	end

	fake.Visible = true
end)
holder:GetPropertyChangedSignal("Visible"):Connect(function()
	visible = holder.Visible

	if visible or visible2 then
		if not heartbeatConnection then
			heartbeatConnection = RunService.Heartbeat:Connect(onHeartbeat)
		end
	elseif heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end)
fake:GetPropertyChangedSignal("Visible"):Connect(function()
	visible2 = fake.Visible

	if visible or visible2 then
		if not heartbeatConnection then
			heartbeatConnection = RunService.Heartbeat:Connect(onHeartbeat)
		end
	elseif heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end)
visible = holder.Visible

if visible or visible2 then
	if not heartbeatConnection then
		heartbeatConnection = RunService.Heartbeat:Connect(onHeartbeat)
	end
elseif heartbeatConnection then
	heartbeatConnection:Disconnect()
	heartbeatConnection = nil
end

visible2 = fake.Visible

if visible or visible2 then
	if not heartbeatConnection then
		heartbeatConnection = RunService.Heartbeat:Connect(onHeartbeat)
	end
elseif heartbeatConnection then
	heartbeatConnection:Disconnect()
	heartbeatConnection = nil
end

for _, button in ipairs(playerHolder:GetChildren()) do
	if not (button:IsA("ImageButton") and button.Name ~= "Dominant") then
		continue
	end

	clone = button:Clone()
	clone.Parent = script
	clone.Name = "SlotTemplate"
	clone.Image = ""
	local textLabel = clone:FindFirstChildOfClass("TextLabel")

	if textLabel then
		textLabel.Text = "+"
	end

	break
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fn9(userId)
	local success, result = pcall(function()
		return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	end)
	return success and result or ""
end

local v22 = {
	token = 0,
	task = nil
}

local function fn10(p, value, p2)
	v22.token += 1

	if v22.task then
		task.cancel(v22.task)
		v22.task = nil
	end

	local token = v22.token
	local v24 = value or 0.6
	local v25 = p2 or { p .. ".", p .. "..", p .. "..." }
	modeWorker.Text = v25[1]
	v22.task = task.spawn(function()
		local v26 = 1

		while v22.token == token and matchSearch.Visible do
			modeWorker.Text = v25[v26]
			v26 = v26 % #v25 + 1
			task.wait(v24)
		end
	end)
end

local function fn11(name, displayName, userId)
	if not name or not displayName or not userId or userId == localPlayer.UserId then
		return
	end

	local v23 = v9[userId]

	if v23 and v23.Parent then
		return v23
	end

	local imageButton = script:FindFirstChild("ImageButton")

	if not imageButton then
		return
	end

	local clone2 = imageButton:Clone()
	clone2.Parent = scrollingFrame
	clone2:SetAttribute("Username", name)
	clone2:SetAttribute("DisplayName", displayName)
	clone2:SetAttribute("UserId", userId)
	clone2.TextLabel.Text = displayName
	clone2.TextLabel.TextLabel.Text = "(@" .. name .. ")"
	local success, result = pcall(function()
		return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)

	if success then
		clone2.Avatar.Image = result
	end

	clone2.MouseButton1Up:Connect(function()
		local v24 = "Invite_" .. userId

		if localPlayer:GetAttribute("TeleportingNow") then
			if shared and shared.createNotification then
				shared.createNotification({
					Title = "RANKED",
					Text = "You are currently being teleported..",
					Duration = 2
				})
			end
		else
			local playerByUserId = Players:GetPlayerByUserId(userId)

			if playerByUserId and playerByUserId:GetAttribute("InQueue") then
				if shared and shared.createNotification then
					shared.createNotification({
						Title = "PARTY",
						Text = "Cannot invite - player is in queue",
						Duration = 2
					})
				end
			else
				if playerByUserId then
					local character = playerByUserId.Character
					local humanoid = character and character:FindFirstChildOfClass("Humanoid")

					if character then
						if humanoid then
							if humanoid.Health > 0 then
								humanoid = not playerByUserId:GetAttribute("Lost")
							else
								humanoid = false
							end
						end
					else
						humanoid = character
					end

					if not humanoid then
						if shared and shared.createNotification then
							shared.createNotification({
								Title = "PARTY",
								Text = "Cannot invite - player is out of the match",
								Duration = 2
							})
						end

						return
					end
				end

				if v10[v24] and tick() - v10[v24] < 20 then
					local v25 = math.ceil(20 - (tick() - v10[v24]))

					if shared and shared.createNotification then
						shared.createNotification({
							Title = "PARTY",
							Text = "Recently rejected. Wait " .. v25 .. " seconds",
							Duration = 2
						})
					end
				else
					for _, v25 in ipairs(v11) do
						if v25.UserId ~= userId then
							continue
						end

						if shared and shared.createNotification then
							shared.createNotification({
								Title = "PARTY",
								Text = "Already in your party",
								Duration = 2
							})
						end

						return
					end

					v.queuehandler:FireServer("InvitePlayer", userId)
				end
			end
		end
	end)
	table.insert(clones2, clone2)
	v9[userId] = clone2
	return clone2
end

local function fn12()
	for _, guiObject in ipairs(scrollingFrame:GetChildren()) do
		if guiObject:IsA("Frame") or guiObject:IsA("ImageButton") then
			guiObject:Destroy()
		end
	end

	clones2 = {}
	v9 = {}

	for _, v23 in ipairs(Players:GetPlayers()) do
		if v23 ~= localPlayer then
			fn11(v23.Name, v23.DisplayName, v23.UserId)
		end
	end
end

Players.PlayerRemoving:Connect(function(player)
	if not player then
		return
	end

	local v23 = v9[player.UserId]

	for i = #clones2, 1, -1 do
		local v24 = clones2[i]

		if not (v24 == v23 or v24 and v24:GetAttribute("UserId") == player.UserId) then
			continue
		end

		if v24 then
			v24:Destroy()
		end

		table.remove(clones2, i)
		v9[player.UserId] = nil
		break
	end
end)
Players.PlayerAdded:Connect(function(player)
	if player ~= localPlayer then
		task.delay(0.5, function()
			fn11(player.Name, player.DisplayName, player.UserId)
		end)
	end
end)
local uIListLayout = scrollingFrame:FindFirstChildOfClass("UIListLayout")

-- equivalent calls inferred from this helper; original call sites unknown
local function fn13()
	local uIGridLayout2 = scrollingFrame.UIGridLayout

	if uIGridLayout2 then
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uIGridLayout2.AbsoluteContentSize.Y)
	end
end

if uIListLayout then
	fn13() -- equivalent call inferred; original call site unknown
	uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(fn13)
end

local function fn14(value)
	return tostring(value or ""):match("^%s*(.-)%s*$")
end

local function fn15(instance, list2)
	if list2 == "" then
		return true
	end

	local username = instance:GetAttribute("Username")
	local displayName = instance:GetAttribute("DisplayName")

	if not (username and displayName) and instance:FindFirstChild("TextLabel") then
		displayName = displayName or instance.TextLabel.Text

		if instance.TextLabel:FindFirstChild("TextLabel") then
			username = username or instance.TextLabel.TextLabel.Text:match("@(.+)%)")
		end
	end

	local v23 = string.lower((tostring(username or "")))
	local v24 = string.lower((tostring(displayName or "")))
	return string.sub(v23, 1, #list2) == list2 or string.sub(v24, 1, #list2) == list2
end

local function fn16(text)
	local v23 = string.lower(fn14(text))
	scrollingFrame.CanvasPosition = Vector2.new(0, 0)

	for i = #clones2, 1, -1 do
		local v24 = clones2[i]

		if v24 and v24.Parent then
			v24.Visible = fn15(v24, v23)
		else
			table.remove(clones2, i)
		end
	end

	fn13() -- equivalent call inferred; original call site unknown
end

textBox:GetPropertyChangedSignal("Text"):Connect(function()
	fn16(textBox.Text)
end)

for _, v23 in ipairs({ list:WaitForChild("DUELS"), list:WaitForChild("BATTLE ROYALE"), list:WaitForChild("HUB") }) do
	v12[v23.Name] = {
		Text = v23:WaitForChild("TextLabel").Text,
		TextSize = v23:WaitForChild("TextLabel").TextSize,
		Image = v23:WaitForChild("ImageLabel").Image
	}
end

local textColor3 = counter.TextColor3
local count = 0
local v23 = {
	threadtoken = 0,
	colortween = nil
}

local function fn17(p)
	v23.threadtoken += 1
	local threadtoken = v23.threadtoken
	count = 0
	counter.Text = "00:00"
	local color3 = p and Color3.fromRGB(209, 61, 64) or textColor3

	if v23.colortween then
		v23.colortween:Cancel()
		v23.colortween = nil
	end

	counter.TextColor3 = color3
	task.spawn(function()
		while v23.threadtoken == threadtoken do
			local v25 = count
			counter.Text = string.format("%02d:%02d", math.floor(v25 / 60), v25 % 60)
			count += 1
			task.wait(1)
		end
	end)
end

local function fn18(color3, p)
	local value = uIGradient.Color.Keypoints[1].Value

	if value == color3 then
		return
	end

	if p then
		uIGradient.Color = ColorSequence.new(color3)
		return
	end

	local lastTime2 = tick()
	local heartbeatConnection2 = nil
	heartbeatConnection2 = RunService.Heartbeat:Connect(function()
		local v24 = math.min((tick() - lastTime2) / 0.2, 1)
		uIGradient.Color = ColorSequence.new(value:Lerp(color3, v24))

		if v24 >= 1 and heartbeatConnection2 then
			heartbeatConnection2:Disconnect()
		end
	end)
	task.delay(0.35, function()
		if heartbeatConnection2 then
			heartbeatConnection2:Disconnect()
		end
	end)
end

local function fn19(imageLabel, image)
	if imageLabel.Image == image then
		return
	end

	local clone2 = imageLabel:Clone()
	clone2.Parent = imageLabel.Parent
	clone2.Image = imageLabel.Image
	clone2.ZIndex = imageLabel.ZIndex + 1
	imageLabel.Image = image
	imageLabel.ImageTransparency = 1
	TweenService:Create(imageLabel, TweenInfo.new(0.2), {
		ImageTransparency = 0
	}):Play()
	TweenService:Create(clone2, TweenInfo.new(0.2), {
		ImageTransparency = 1
	}):Play()
	Debris:AddItem(clone2, 0.2)
end

local function fn20()
	v22.token += 1

	if v22.task then
		task.cancel(v22.task)
		v22.task = nil
	end

	if connection then
		connection:Disconnect()
		connection = nil
	end

	v23.threadtoken += 1

	if v23.colortween then
		v23.colortween:Cancel()
		v23.colortween = nil
	end

	counter.TextColor3 = textColor3
	counter.Text = "00:00"
	count = 0
	matchSearch.Visible = false
	v13 = "idle"
	flag = false
	local visible3 = not shared or shared.globalswitch ~= false
	local character = localPlayer.Character

	if character:FindFirstChild("Freeze") or character:FindFirstChild("Ragdoll") or character:FindFirstChild("Slowed") then
		visible3 = false
	end

	rankedOther.Visible = visible3
	modeWorker.Text = ""
	local v27 = color

	if uIGradient.Color.Keypoints[1].Value == v27 then
		return
	end

	uIGradient.Color = ColorSequence.new(v27)
end

local function fn21(text)
	local connections = {}
	local threads = {}
	local flag7 = false
	local color3 = Color3.fromRGB(135, 0, 2)
	local color4 = Color3.fromRGB(72, 72, 72)
	local lastTime2 = tick()
	local v24 = false
	fn18(color4)

	local function onMouseEnter()
		if flag then
			return
		end

		if localPlayer:GetAttribute("TeleportingNow") or flag7 or v24 or tick() - lastTime2 <= 0.8265 then
			return
		end

		v24 = true
		fn18(color3)
		script["tsb UI 1v1 queue exit hover (1)"]:Play()
		v22.token += 1

		if v22.task then
			task.cancel(v22.task)
			v22.task = nil
		end

		modeWorker.Text = "Exit Queue?"

		if threads[1] then
			task.cancel(threads[1])
		end

		threads[1] = task.delay(3, function()
			if not flag7 then
				fn18(color4)
				v22.token += 1

				if v22.task then
					task.cancel(v22.task)
					v22.task = nil
				end

				modeWorker.Text = "Exit Queue?"
			end
		end)
	end

	connections[1] = matchSearch.MouseEnter:Connect(onMouseEnter)
	connections[2] = matchSearch.MouseLeave:Connect(function()
		if flag or (flag7 or tick() - lastTime2 <= 0.8265) then
			return
		end

		v24 = false

		if threads[1] then
			task.cancel(threads[1])
		end

		fn18(color4)
		modeWorker.Text = text
	end)
	task.delay(0.8265, function()
		local v25 = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
		local guiObjectsAtPosition = playerGui:GetGuiObjectsAtPosition(v25.X, v25.Y)

		for _, v26 in pairs(guiObjectsAtPosition) do
			if tostring(v26) ~= tostring(matchSearch) then
				continue
			end

			onMouseEnter()
			break
		end
	end)

	local function fn22()
		local isLeader = true

		for _, v26 in ipairs(v11) do
			if v26.UserId ~= localPlayer.UserId then
				continue
			end

			isLeader = v26.IsLeader
			break
		end

		if isLeader then
			return true
		end

		if shared and shared.createNotification then
			shared.createNotification({
				Title = "PARTY",
				Text = "You are not the party leader",
				Duration = 3
			})
		end

		return false
	end

	connections[3] = matchSearch.MouseButton1Up:Connect(function()
		if flag or (tick() - lastTime2 <= 0.8265 or not fn22() or localPlayer:GetAttribute("TeleportingNow")) then
			return
		end

		if flag7 then
			local color5 = Color3.fromRGB(209, 61, 64)

			if v23.colortween then
				v23.colortween:Cancel()
				v23.colortween = nil
			end

			v23.colortween = TweenService:Create(counter, TweenInfo.new(0.5), {
				TextColor3 = color5
			})
			v23.colortween:Play()
			v23.threadtoken += 1
			counter.Text = "00:00"
			count = 0

			for _, connection2 in pairs(connections) do
				if connection2 then
					connection2:Disconnect()
				end
			end

			if threads[2] then
				task.cancel(threads[2])
			end

			if v13 == "teleporting" then
				return
			end

			v.queuehandler:FireServer("LeaveQueue")
			flag2 = true
			flag = true
			v13 = "leaving"
			fn10("Leaving", 0.45, { "Leaving.", "Leaving..", "Leaving..." })
			task.delay(3, function()
				if v13 == "leaving" then
					flag2 = false
					flag = false

					if flag3 then
						v13 = "queued"

						if v14 then
							local v26 = v14
							v22.token += 1

							if v22.task then
								task.cancel(v22.task)
								v22.task = nil
							end

							modeWorker.Text = v26 or ""
						end

						fn18(color)
					else
						v13 = "idle"
					end
				end
			end)
			script["tsb UI 1v1 queue exit confirm (1)"]:Play()
			fn18(Color3.fromRGB(125, 0, 2))
		else
			flag7 = true
			script["tsb UI 1v1 queue exit first click (1)"]:Play()
			v22.token += 1

			if v22.task then
				task.cancel(v22.task)
				v22.task = nil
			end

			modeWorker.Text = "Sure?"

			if threads[1] then
				task.cancel(threads[1])
			end

			if threads[2] then
				task.cancel(threads[2])
			end

			threads[2] = task.delay(3, function()
				flag7 = false
				v22.token += 1

				if v22.task then
					task.cancel(v22.task)
					v22.task = nil
				end

				modeWorker.Text = text or ""
				fn18(color4)
			end)
		end
	end)
end

local function fn22(title, text, value)
	local v24 = tostring(title) .. "::" .. tostring(text)
	local now = tick()

	if v15 == v24 and now - v16 < 1.2 then
		return
	end

	v15 = v24
	v16 = now

	if shared and shared.createNotification then
		shared.createNotification({
			Title = title,
			Text = text,
			Duration = value or 2
		})
	end
end

local function fn23()
	local v24 = v11 and #v11 or 0
	local v25

	if v24 > 1 then
		v25 = false

		for _, v26 in ipairs(v11) do
			if v26.UserId == localPlayer.UserId then
				return v24, v26.IsLeader == true
			end
		end
	else
		v25 = true
	end

	return v24, v25
end

local function fn24(mode)
	if flag2 or flag3 or localPlayer:GetAttribute("TeleportingNow") or not mode then
		return
	end

	local v24, v25 = fn23()

	if v24 > 1 and not v25 then
		fn22("PARTY", "Only the party leader can queue.", 3)
		return
	end

	if mode == "1v1s" and v24 > 1 then
		fn22("QUEUE", "Party too big for 1v1s.", 3)
		return
	end

	if mode == "2v2s" and v24 > 2 then
		fn22("QUEUE", "Party too big for 2v2s.", 3)
		return
	end

	if mode == "3v3s" and v24 > 3 then
		fn22("QUEUE", "Party too big for 3v3s.", 3)
		return
	end

	if mode == "BR Solos" and v24 > 1 then
		fn22("QUEUE", "BR Solos can't be queued with a party.", 3)
		return
	end

	if mode == "BR Duos" and v24 > 2 then
		fn22("QUEUE", "Party too big for BR Duos.", 3)
		return
	end

	local isRanked

	if mode == "BR Solos" then
		isRanked = false
	else
		isRanked = mode ~= "BR Duos"
	end

	flag2 = true
	v14 = mode
	v.queuehandler:FireServer("JoinQueue", {
		Mode = mode,
		IsRanked = isRanked
	})
	v13 = "queued"
	flag = false
	local v27 = color

	if uIGradient.Color.Keypoints[1].Value ~= v27 then
		uIGradient.Color = ColorSequence.new(v27)
	end

	v22.token += 1

	if v22.task then
		task.cancel(v22.task)
		v22.task = nil
	end

	modeWorker.Text = "Joining Queue.."
	rankedOther.Visible = false
	matchSearch.Visible = true
	local realholder = container:FindFirstChild("realholder")

	if realholder then
		realholder.Visible = false
	end

	fn17()
	fn10("Joining", 0.6)

	if thread then
		task.cancel(thread)
	end

	thread = task.delay(11, function()
		if flag2 then
			flag3 = false
			flag2 = false
			fn20()
			fn22("QUEUE", "Queue request timed out. Try again.", 3)
		end
	end)
end

local v24 = {
	DUELS = function()
		if flag4 then
			fn24(list.DUELS:GetAttribute("Mode") or "1v1s")
			return
		end

		flag4 = true
		BACK.Visible = true
		list["BATTLE ROYALE"].ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
		list["BATTLE ROYALE"].TextLabel.TextTransparency = 0
		local comingsoon = list["BATTLE ROYALE"]:FindFirstChild("comingsoon")

		if comingsoon then
			comingsoon.Visible = false
		end

		local v25 = { list.DUELS, list["BATTLE ROYALE"], list.HUB }
		local textSize = v12.DUELS.TextSize
		local v26 = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
		local guiObjectsAtPosition = playerGui:GetGuiObjectsAtPosition(v26.X, v26.Y)

		for _, v27 in pairs(guiObjectsAtPosition) do
			if tostring(v27) ~= tostring("DUELS") then
				continue
			end

			BACK.Position = UDim2.new(0.0355, 0, 0.6945, 0)
			break
		end

		script["tsb ui icon fade"]:Play()

		for i, v27 in ipairs(v25) do
			local textLabel = v27.TextLabel
			fn19(v27.ImageLabel, v7[v17[i]])
			textLabel.Text = v17[i]
			textLabel.TextSize = textSize
			v27:SetAttribute("Duel", true)
			v27:SetAttribute("Mode", v17[i])
		end
	end,
	["BATTLE ROYALE"] = function()
		local BATTLEROYALE = list["BATTLE ROYALE"]

		if BATTLEROYALE:GetAttribute("Duel") then
			fn24(BATTLEROYALE:GetAttribute("Mode"))
		end
	end,
	HUB = function()
		local HUB = list.HUB

		if HUB:GetAttribute("Duel") then
			fn24(HUB:GetAttribute("Mode"))
			return
		end

		if #v11 > 1 then
			local v25 = false

			for _, v27 in ipairs(v11) do
				if not (v27.UserId == localPlayer.UserId and v27.IsLeader) then
					continue
				end

				v25 = true
				break
			end

			if not v25 then
				if shared and shared.createNotification then
					shared.createNotification({
						Title = "PARTY",
						Text = "Only the party leader can perform this action",
						Duration = 3
					})
				end

				return
			end
		end

		local textLabel = HUB.TextLabel
		local tweenInfo = TweenInfo.new(0.065)

		if v18 == 0 then
			v18 = 1

			if thread2 then
				task.cancel(thread2)
			end

			TweenService:Create(textLabel, tweenInfo, {
				TextTransparency = 1
			}):Play()
			task.delay(0.065, function()
				textLabel.Text = "SURE?"
				TweenService:Create(textLabel, tweenInfo, {
					TextTransparency = 0
				}):Play()
			end)
			thread2 = task.delay(5, function()
				v18 = 0
				TweenService:Create(textLabel, tweenInfo, {
					TextTransparency = 1
				}):Play()
				task.delay(0.065, function()
					textLabel.Text = (game:GetAttribute("RankedOnes") or Workspace:GetAttribute("RankedTwos") or Workspace:GetAttribute("RankedThrees")) and "MAIN GAME" or "HUB"
					TweenService:Create(textLabel, tweenInfo, {
						TextTransparency = 0
					}):Play()
				end)
			end)
		else
			v18 = 0

			if thread2 then
				task.cancel(thread2)
			end

			TweenService:Create(textLabel, tweenInfo, {
				TextTransparency = 1
			}):Play()
			task.delay(0.065, function()
				textLabel.Text = (game:GetAttribute("RankedOnes") or Workspace:GetAttribute("RankedTwos") or Workspace:GetAttribute("RankedThrees")) and "MAIN GAME" or "HUB"
				TweenService:Create(textLabel, tweenInfo, {
					TextTransparency = 0
				}):Play()
			end)
		end
	end,
	BACK = function()
		if not flag4 then
			return
		end

		script.Sounds.Click:Play()
		flag4 = false
		BACK.Visible = false
		v18 = 0
		v19 = false
		list["BATTLE ROYALE"].ImageLabel.ImageColor3 = Color3.fromRGB(74, 74, 74)
		local v25 = { list.DUELS, list["BATTLE ROYALE"], list.HUB }
		script["tsb ui icon fade"]:Play()

		for _, v26 in ipairs(v25) do
			local v27 = v12[v26.Name]

			if not v27 then
				continue
			end

			local textLabel = v26.TextLabel
			fn19(v26.ImageLabel, v27.Image)

			if v26.Name ~= "BATTLE ROYALE" then
				textLabel.Text = v27.Text
			end

			textLabel.TextSize = v27.TextSize
			v26:SetAttribute("Duel", nil)
			v26:SetAttribute("Mode", nil)
		end

		list["BATTLE ROYALE"].TextLabel.Text = "???"
		list["BATTLE ROYALE"].TextLabel.TextTransparency = 0.9
		local comingsoon = list["BATTLE ROYALE"]:FindFirstChild("comingsoon")

		if comingsoon then
			comingsoon.Visible = true
		end
	end
}
rankedOther:GetPropertyChangedSignal("Visible"):Connect(function()
	if not rankedOther.Visible then
		v24.BACK()
	end
end)
local Type = require(script.Type)
local v25 = {}

local function fn25()
	local allDown = Workspace:GetAttribute("AllDown")
	local downRegions = Workspace:GetAttribute("DownRegions")
	local v26 = {}

	if allDown ~= true and downRegions then
		local success, result = pcall(function()
			return HttpService:JSONDecode(downRegions)
		end)

		if success and result then
			for _, v27 in pairs(result) do
				table.insert(v26, v27)
			end
		end
	end

	local serverRegion = localPlayer:GetAttribute("ServerRegion")
	local live = regionVisible.live

	if serverRegion and table.find(v26, serverRegion) then
		TweenService:Create(live, TweenInfo.new(0.25), {
			ImageColor3 = Color3.fromRGB(255, 55, 55)
		}):Play()

		if modeContainer.Visible or matchSearch.Visible then
			local v27 = not flag3

			if v27 then
				if v13 == "waiting_sync" then
					v27 = false
				else
					v27 = v13 ~= "teleporting"
				end
			end

			if v27 and not v25[serverRegion] then
				v25[serverRegion] = true
				shared.createNotification({
					Title = "QUEUE",
					Text = "Your region is currently down, please swap for now.",
					Duration = 3
				})
			end
		end
	elseif live.ImageColor3 ~= Color3.fromRGB(151, 255, 133) then
		TweenService:Create(live, TweenInfo.new(0.25), {
			ImageColor3 = Color3.fromRGB(151, 255, 133)
		}):Play()
	end

	for _, button in pairs(regionVisible.GameFrame.ScrollingFrame:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		if table.find(v26, string.upper(button.Name)) then
			TweenService:Create(button.ImageLabel, TweenInfo.new(0.25), {
				ImageColor3 = Color3.fromRGB(255, 55, 55)
			}):Play()

			if regionVisible.GameFrame.Visible then
				Type.play(button.isactive, "INACTIVE", {
					cps = 70,
					NoSound = false
				})
			else
				button.isactive.Text = "INACTIVE"
			end
		else
			if regionVisible.GameFrame.Visible then
				Type.play(button.isactive, "ACTIVE", {
					cps = 70,
					NoSound = false
				})
			else
				button.isactive.Text = "ACTIVE"
			end

			TweenService:Create(button.ImageLabel, TweenInfo.new(0.25), {
				ImageColor3 = Color3.fromRGB(151, 255, 133)
			}):Play()
		end
	end
end

local function fn26()
	local library = require(ReplicatedStorage.library)
	local Pulse = require(script.Pulse)
	local playTween = library.PlayTween

	local function fn27(button)
		if button:IsA("TextButton") or button:IsA("ImageButton") then
			button.MouseButton1Up:Connect(function()
				script.Sounds.Click:Play()
			end)
			button.MouseEnter:Connect(function()
				SoundService:PlayLocalSound(script.Sounds.Hover)
			end)
		end
	end

	local playerGui2 = game.Players.LocalPlayer.PlayerGui

	function shared.rankedgui(visible3, p)
		local rankedOther2 = playerGui2.Ranked:FindFirstChild("Container"):FindFirstChild("RankedOther")

		if not rankedOther2 then
			return
		end

		if p then
			return rankedOther2.Visible
		end

		if rankedOther2.Visible then
			shared.virtualcursor()
		else
			Info.hideGUI(playerGui2.Ranked)
			shared.virtualcursor(playerGui2.Ranked)
		end

		if visible3 == nil then
			rankedOther2.Visible = not rankedOther2.Visible
		else
			rankedOther2.Visible = visible3
		end

		if rankedOther2.Visible then
			for _, button in pairs(modeContainer.List:GetChildren()) do
				if not button:IsA("ImageButton") then
					continue
				end

				button.TextLabel.Text = ""
				local v26 = button.Name == "BATTLE ROYALE" and "???" or button.Name
				Type.play(button.TextLabel, v26, {
					cps = 70,
					NoSound = false
				})

				if button.Name == "BATTLE ROYALE" then
					button.TextLabel.TextTransparency = 0.9
				end
			end
		end
	end

	local size = BACK.Size
	BACK.MouseEnter:Connect(function()
		script.Sounds.Hover:Play()
		BACK:TweenSize(UDim2.new(0.136, 0, 0.094, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.15, true)
	end)
	BACK.MouseLeave:Connect(function()
		BACK:TweenSize(size, Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.15, true)
	end)
	local v26 = false
	local flag7 = false

	for _, button in pairs(list:GetChildren()) do
		if not button:IsA("ImageButton") then
			continue
		end

		local v27 = button.Name == "BATTLE ROYALE"
		local imageLabel = button:FindFirstChild("ImageLabel")
		local uIGradient2 = imageLabel:FindFirstChildOfClass("UIGradient")

		if v27 then
			button.MouseButton1Up:Connect(function()
				if flag4 then
					script.Sounds.Click:Play()
				end
			end)
			button.MouseEnter:Connect(function()
				if flag4 then
					SoundService:PlayLocalSound(script.Sounds.Hover)
				end
			end)
		else
			fn27(button)
		end

		local transparency = uIGradient2.Transparency
		local color3 = uIGradient2.Color
		button:SetAttribute("OGSize", button.Size)
		local uDim = UDim2.new(0.048, 0, 0.668, 0)
		local v29 = button
		button.MouseEnter:Connect(function()
			if v27 and not flag4 then
				return
			end

			if flag4 and BACK then
				BACK:TweenPosition(
					UDim2.new(0.0355, 0, tostring(v29) == "DUELS" and 0.6945 or 0.668, 0),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Sine,
					0.115,
					true
				)
			end

			v29:TweenSize(UDim2.new(0.31, 0, 0.697, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.15, true)
			playTween(uIGradient2, {
				EasingStyle = "Sine",
				Time = 0.2,
				Goal = {
					Transparency = NumberSequence.new(0),
					Color = ColorSequence.new(Color3.new(1, 1, 1))
				}
			})
			imageLabel:TweenSize(UDim2.new(1.1, 0, 1.1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.3, true)
		end)
		local v32 = v27
		local v34 = button
		local v35 = uIGradient2
		local v38 = imageLabel
		button.MouseLeave:Connect(function()
			if v32 and not flag4 then
				return
			end

			if flag4 and BACK then
				BACK:TweenPosition(uDim, Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.15, true)
			end

			v34:TweenSize(v34:GetAttribute("OGSize"), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.15, true)
			playTween(v35, {
				EasingStyle = "Sine",
				Time = 0.2,
				Goal = {
					Transparency = transparency,
					Color = color3
				}
			})
			v38:TweenSize(UDim2.new(1, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.3, true)
		end)
	end

	local function fn28()
		inviteUi.Receiver.Visible = true

		for _, guiObject in pairs(scrollingFrame:GetChildren()) do
			if guiObject:IsA("Frame") or guiObject:IsA("ImageButton") then
				guiObject:Destroy()
			end
		end

		fn12()
		fn16(textBox.Text)
	end

	local v27 = {}

	local function fn29(uIStroke, tweenInfo, p)
		if v27[uIStroke] then
			v27[uIStroke]:Cancel()
			v27[uIStroke] = nil
		end

		local tween = TweenService:Create(uIStroke, tweenInfo, p)
		v27[uIStroke] = tween
		tween:Play()
		tween.Completed:Connect(function()
			if v27[uIStroke] == tween then
				v27[uIStroke] = nil
			end
		end)
	end

	for _, button in pairs(playerHolder:GetChildren()) do
		if not (button:IsA("ImageButton") and button.Name ~= "Dominant") then
			continue
		end

		fn27(button)
		local uIStroke = button:FindFirstChildOfClass("UIStroke") or button:FindFirstChild("UIStroke", true)
		local color3 = uIStroke and uIStroke.Color or Color3.new(1, 1, 1)
		local transparency = not uIStroke and 0 or uIStroke.Transparency or 0
		local v29 = button
		button.MouseButton1Up:Connect(function()
			local textLabel = v29:FindFirstChildOfClass("TextLabel")

			if textLabel and textLabel.Text == "+" or v29.Image == "" or v29.Image == nil then
				v26 = not v26

				if v26 then
					fn28()
				else
					inviteUi.Receiver.Visible = false
				end
			else
				local memberUserId = v29:GetAttribute("MemberUserId")

				if not memberUserId then
					return
				end

				if memberUserId == localPlayer.UserId then
					v.queuehandler:FireServer("LeaveParty")

					if not uIStroke then
						return
					end

					fn29(uIStroke, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						Color = color3,
						Transparency = transparency
					})
				else
					local flag8 = true
					local v32

					for i, v33 in ipairs(v11) do
						if v33.UserId ~= localPlayer.UserId then
							continue
						end

						v32 = v33.IsLeader == true
						flag8 = false
						break
					end

					if flag8 then
						v32 = true
					end

					if v32 then
						v.queuehandler:FireServer("KickPartyMember", memberUserId)
					else
						fn22("PARTY", "Only party leader can do this", 3)
					end
				end
			end
		end)
		local v32 = button
		local v33 = color3
		local transparency2 = transparency
		button.MouseEnter:Connect(function()
			-- [DEDUP] synthesized from 2 duplicated terminal regions
			local function deduplicatedTail()
				local color4

				if not uIStroke then
					return
				end

				color4 = Color3.fromRGB(255, 70, 70) or v33
				fn29(uIStroke, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Color = color4,
					Transparency = transparency2
				})
			end

			local memberUserId = v32:GetAttribute("MemberUserId")

			if not memberUserId then
				return
			end

			if memberUserId == localPlayer.UserId then
				return deduplicatedTail()
			else
				local flag8 = true
				local v36

				for i, v37 in ipairs(v11) do
					if v37.UserId ~= localPlayer.UserId then
						continue
					end

					v36 = v37.IsLeader == true
					flag8 = false
					break
				end

				if flag8 then
					v36 = true
				end

				if not v36 then
					return
				end

				return deduplicatedTail()
			end
		end)
		local color5 = color3
		local transparency3 = transparency
		button.MouseLeave:Connect(function()
			if not uIStroke then
				return
			end

			fn29(uIStroke, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Color = color5,
				Transparency = transparency3
			})
		end)
	end

	local gameFrame = regionVisible:WaitForChild("GameFrame")
	local scrollingFrame2 = gameFrame:WaitForChild("ScrollingFrame")

	local function fn30(folder, _, textTransparency, duration)
		local descendants = { folder }

		for _, descendant in ipairs(folder:GetDescendants()) do
			table.insert(descendants, descendant)
		end

		for _, instance in ipairs(descendants) do
			if not instance:IsA("GuiObject") then
				continue
			end

			local v28 = {}

			if instance:IsA("Frame") then
				instance.BackgroundTransparency = instance.BackgroundTransparency
				v28.BackgroundTransparency = instance == gameFrame and 0.5 or 0.6
			end

			if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
				instance.TextTransparency = instance.TextTransparency
				v28.TextTransparency = textTransparency
			end

			if next(v28) then
				TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Sine), v28):Play()
			end
		end
	end

	local function fn31()
		SoundService:PlayLocalSound(script.Sounds.RegionClick)
		flag7 = true
		gameFrame.Visible = true
		regionVisible.ImageLabel.Rotation = 180
		fn30(gameFrame, 1, 0, 0.2)
		gameFrame.Size = UDim2.new(1.001, 0, 0, 0)
		gameFrame:TweenSize(UDim2.new(1.001, 0, 6.378, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.1, true)

		for _, button in pairs(scrollingFrame2:GetChildren()) do
			if not button:IsA("TextButton") then
				continue
			end

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1.07, 0, 1, 0)
			frame.Position = UDim2.new(-0.07, 0, 0, 0)
			frame.BorderSizePixel = 0
			frame.BackgroundColor3 = Color3.new(1, 1, 1)
			frame.Parent = button
			Debris:AddItem(frame, 0.2)
			TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
				BackgroundTransparency = 1
			}):Play()
			SoundService:PlayLocalSound(script.Sounds.Load)
			task.wait(Random.new():NextNumber(0.025, 0.065))
		end
	end

	local function fn32()
		flag7 = false
		regionVisible.ImageLabel.Rotation = 0
		fn30(gameFrame, 0, 1, 0.2)
		gameFrame:TweenSize(UDim2.new(1.001, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.1, true)
		task.delay(0.1, function()
			if not flag7 then
				gameFrame.Visible = false
			end
		end)
	end

	regionVisible.MouseEnter:Connect(function()
		script.Sounds.Hover:Play()
		regionVisible.Frame:TweenSize(
			UDim2.new(1.1, 0, 1, 0),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Sine,
			0.2,
			true
		)
	end)
	regionVisible.MouseLeave:Connect(function()
		regionVisible.Frame:TweenSize(UDim2.new(1, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.2, true)
	end)
	regionVisible.MouseButton1Up:Connect(function()
		script.Sounds.ogclick:Play()

		if flag7 then
			fn32()
		else
			fn31()
		end
	end)

	local function fn33(serverRegion)
		if regionVisible.TextLabel.Text ~= serverRegion then
			regionVisible.TextLabel.Text = ""
			Type.play(regionVisible.TextLabel, serverRegion, {
				cps = 12
			})
			local live = regionVisible.live

			if live.ImageColor3 ~= Color3.fromRGB(151, 255, 133) then
				TweenService:Create(live, TweenInfo.new(0.25), {
					ImageColor3 = Color3.fromRGB(151, 255, 133)
				}):Play()
			end
		end
	end

	localPlayer:GetAttributeChangedSignal("ServerRegion"):Connect(function()
		fn33(localPlayer:GetAttribute("ServerRegion"))
	end)

	for _, button in pairs(scrollingFrame2:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		button.MouseEnter:Connect(function()
			SoundService:PlayLocalSound(script.Sounds.Hover)
		end)
		local v28 = button
		button.MouseButton1Up:Connect(function()
			if flag5 then
				return
			end

			flag5 = true
			SoundService:PlayLocalSound(script.Sounds.Click)
			task.delay(1, function()
				flag5 = false
			end)

			if localPlayer:GetAttribute("ServerRegion") == tostring(v28.Name) then
				if shared and shared.createNotification then
					shared.createNotification({
						Title = "REGION",
						Text = "You already have this region selected",
						Duration = 2
					})
				end
			else
				v.queuehandler:FireServer({
					Type = "RegionFire",
					Region = tostring(v28.Name)
				})
				fn32()
			end
		end)
	end

	local imageLabels = { regionVisible.live }

	for _, button in pairs(scrollingFrame2:GetChildren()) do
		if button:IsA("TextButton") and button:FindFirstChild("ImageLabel") then
			table.insert(imageLabels, button.ImageLabel)
		end
	end

	Pulse.start(imageLabels, {
		min = 0.3,
		max = 0.9,
		speed = 0.4,
		property = "ImageTransparency",
		syncGroup = "global"
	})
end

(function(folder)
	for _, button in pairs(folder:GetDescendants()) do
		if not (button:IsA("TextButton") or button:IsA("ImageButton")) then
			continue
		end

		local v26 = v24[button.Name]

		if v26 then
			button.MouseButton1Up:Connect(v26)
		end
	end
end)(ranked2)
fn26()
fn25()
fn12()
dominant.Image = fn9(localPlayer.UserId)
Workspace:GetAttributeChangedSignal("AllDown"):Connect(fn25)
Workspace:GetAttributeChangedSignal("DownRegions"):Connect(fn25)
v.receiver.OnClientEvent:Connect(function(p, data)
	if not (p and p ~= "RegionUpdate") then
		return
	end

	if p == "QueueLeftSoon" then
		v23.threadtoken += 1

		if v23.colortween then
			v23.colortween:Cancel()
			v23.colortween = nil
		end

		counter.TextColor3 = textColor3
		counter.Text = "00:00"
		count = 0
		local color3 = Color3.fromRGB(209, 61, 64)

		if v23.colortween then
			v23.colortween:Cancel()
			v23.colortween = nil
		end

		v23.colortween = TweenService:Create(counter, TweenInfo.new(0.5), {
			TextColor3 = color3
		})
		v23.colortween:Play()
	elseif p == "PartyUpdate" then
		local members = data.Members or {}
		local event = data.Event
		local leftPlayer = data.LeftPlayer
		v11 = members
		local userId = nil

		for _, member in ipairs(members) do
			if not member.IsLeader then
				continue
			end

			userId = member.UserId
			break
		end

		dominant.Image = fn9(userId or localPlayer.UserId)

		if event == "LeaderLeft" then
			local v29 = false

			for _, member in ipairs(members) do
				if not (member.UserId == localPlayer.UserId and member.IsLeader) then
					continue
				end

				v29 = true
				break
			end

			if v29 and shared and shared.createNotification then
				shared.createNotification({
					Title = "PARTY",
					Text = "YOU ARE NOW THE LEADER OF THIS PARTY",
					Duration = 5
				})
			elseif leftPlayer and shared and shared.createNotification then
				shared.createNotification({
					Title = "PARTY",
					Text = leftPlayer .. " LEFT. NEW LEADER ASSIGNED",
					Duration = 4
				})
			end
		elseif event == "MemberLeft" then
			if leftPlayer and shared and shared.createNotification then
				shared.createNotification({
					Title = "PARTY",
					Text = leftPlayer .. " HAS LEFT THE PARTY",
					Duration = 3
				})
			end
		elseif event ~= "AutoParty" then
			local member = members[#members]

			if member and #members > 1 and member.UserId ~= localPlayer.UserId and shared and shared.createNotification then
				shared.createNotification({
					Title = "PARTY",
					Text = member.DisplayName .. " HAS JOINED THE PARTY",
					Duration = 3
				})
			end
		end

		local v29 = {}

		for _, button in ipairs(playerHolder:GetChildren()) do
			if button:IsA("ImageButton") and button.Name ~= "Dominant" then
				table.insert(v29, button)
			end
		end

		while #v29 < 2 and clone do
			local clone2 = clone:Clone()
			clone2.Parent = playerHolder
			table.insert(v29, clone2)
		end

		local v30 = 1

		for _, v31 in ipairs(v29) do
			local v32 = nil

			while v30 <= #members and members[v30].IsLeader do
				v30 += 1
			end

			if v30 <= #members then
				v32 = members[v30]
				v30 += 1
			end

			local textLabel = v31:FindFirstChildOfClass("TextLabel")

			if v32 then
				v31.Image = fn9(v32.UserId)
				v31:SetAttribute("MemberUserId", v32.UserId)

				if textLabel then
					textLabel.Text = ""
				end
			else
				v31.Image = ""
				v31:SetAttribute("MemberUserId", nil)

				if textLabel then
					textLabel.Text = "+"
				end
			end
		end
	elseif p == "PartyLeft" then
		dominant.Image = fn9(localPlayer.UserId)
		v11 = {}
		local reason = data and data.Reason
		local text, duration

		if reason == "PartyDisbanded" then
			text = "PARTY HAS BEEN DISBANDED"
			duration = 4
		elseif reason == "Kicked" then
			text = "YOU HAVE BEEN KICKED"
			duration = 4
		else
			text = "YOU HAVE LEFT THE PARTY"
			duration = 3
		end

		if shared and shared.createNotification then
			shared.createNotification({
				Title = "PARTY",
				Text = text,
				Duration = duration
			})
		end

		for _, button in ipairs(playerHolder:GetChildren()) do
			if not (button:IsA("ImageButton") and button.Name ~= "Dominant") then
				continue
			end

			button.Image = ""
			button.ImageColor3 = Color3.new(1, 1, 1)
			button:SetAttribute("MemberUserId", nil)
			local textLabel = button:FindFirstChildOfClass("TextLabel")

			if textLabel then
				textLabel.Text = "+"
			end
		end
	elseif p == "PartyOwner" then
		if shared and shared.createNotification then
			shared.createNotification({
				Title = "PARTY",
				Text = "YOU CREATED A NEW PARTY",
				Duration = 3
			})
		end
	elseif p == "InviteRejected" then
		local userId = data.UserId

		if userId then
			v10["Invite_" .. userId] = tick()
			task.delay(20, function()
				v10["Invite_" .. userId] = nil
			end)
		end
	elseif p == "QueueJoined" then
		flag3 = true
		flag2 = false
		v13 = "queued"
		flag = false
		script.Parent.Container.realholder.Visible = false
		script["tsb UI 1v1 queue green (1)"]:Play()
		fn18(color2)
		task.delay(0.35, function()
			fn18(color)
		end)

		if thread then
			task.cancel(thread)
		end

		local mode = data and data.Mode
		local isRanked = data and data.IsRanked

		if not mode then
			return
		end

		v14 = mode

		if mode == "1v1s" or mode == "2v2s" or mode == "3v3s" then
			mode = isRanked and mode .. " Ranked" or mode .. " Unranked" or mode
		end

		st = tick()
		v13 = "queued"
		flag = false
		local v26 = color

		if uIGradient.Color.Keypoints[1].Value ~= v26 then
			uIGradient.Color = ColorSequence.new(v26)
		end

		v22.token += 1

		if v22.task then
			task.cancel(v22.task)
			v22.task = nil
		end

		modeWorker.Text = mode or ""
		rankedOther.Visible = false
		matchSearch.Visible = true
		local realholder = container:FindFirstChild("realholder")

		if realholder then
			realholder.Visible = false
		end

		fn17()
		fn21(mode)

		if data.IsPartyMember and shared and shared.createNotification then
			shared.createNotification({
				Title = "QUEUE",
				Text = data.PartyLeader .. " queued the party for " .. mode,
				Duration = 3
			})
		end
	elseif p == "QueueRequeued" then
		flag3 = true
		flag2 = false
		v13 = "queued"
		flag = false

		if thread then
			task.cancel(thread)
		end

		local mode = data and data.Mode
		local isRanked = data and data.IsRanked

		if mode then
			v14 = mode
			local v26

			if mode == "1v1s" or mode == "2v2s" or mode == "3v3s" then
				v26 = isRanked and mode .. " Ranked" or mode .. " Unranked" or mode
			else
				v26 = mode
			end

			v13 = "queued"
			flag = false
			local v27 = color

			if uIGradient.Color.Keypoints[1].Value ~= v27 then
				uIGradient.Color = ColorSequence.new(v27)
			end

			v22.token += 1

			if v22.task then
				task.cancel(v22.task)
				v22.task = nil
			end

			modeWorker.Text = v26 or ""
			rankedOther.Visible = false
			matchSearch.Visible = true
			local realholder = container:FindFirstChild("realholder")

			if realholder then
				realholder.Visible = false
			end

			fn17()
			fn21(v26)
			fn10("Requeueing", 0.45, { "Requeueing.", "Requeueing..", "Requeueing..." })
			task.delay(1.8, function()
				if flag3 and v13 == "queued" and not flag and v14 == mode then
					v22.token += 1

					if v22.task then
						task.cancel(v22.task)
						v22.task = nil
					end

					modeWorker.Text = v26 or ""
				end
			end)
		end
	elseif p == "QueueWin" then
		if thread then
			task.cancel(thread)
		end

		flag3 = false
		flag2 = false

		if not matchSearch.Visible then
			local v26 = v14 or "Queue"
			v13 = "queued"
			flag = false
			local v27 = color

			if uIGradient.Color.Keypoints[1].Value ~= v27 then
				uIGradient.Color = ColorSequence.new(v27)
			end

			v22.token += 1

			if v22.task then
				task.cancel(v22.task)
				v22.task = nil
			end

			modeWorker.Text = v26 or ""
			rankedOther.Visible = false
			matchSearch.Visible = true
			local realholder = container:FindFirstChild("realholder")

			if realholder then
				realholder.Visible = false
			end

			fn17()
		end

		v13 = "teleporting"
		flag = true
		v22.token += 1

		if v22.task then
			task.cancel(v22.task)
			v22.task = nil
		end

		shared.sfx({
			SoundId = "rbxassetid://121123673885020",
			Parent = Workspace,
			Volume = 0.35
		}):Play()
		fn10("TELEPORTING", 0.33, { "TELEPORTING.", "TELEPORTING..", "TELEPORTING..." })

		if v23.colortween then
			v23.colortween:Cancel()
			v23.colortween = nil
		end

		v23.colortween = TweenService:Create(counter, TweenInfo.new(0.2), {
			TextColor3 = color2
		})
		v23.colortween:Play()
		fn18(color2)
	elseif p == "QueueLeft" then
		if data and data.Delay then
			task.wait(data.Delay)
		end

		flag3 = false
		flag2 = false
		v14 = nil
		v13 = "idle"
		flag = false

		if thread then
			task.cancel(thread)
		end

		fn20()
		local message = data and (data.Message or data.IsParty and "Party has left the queue")

		if message then
			fn22("QUEUE", message, data.Message and 3 or 2)
		end
	end
end)
local realholder = container:WaitForChild("realholder")
realholder.Visible = false
local info = realholder:WaitForChild("Info")
local elocount = realholder:WaitForChild("elocount")
local barback = realholder:WaitForChild("barback")
local realfiller = barback:WaitForChild("realfiller")
local visualizedcontainer = realholder:WaitForChild("visualizedcontainer")
local rank = visualizedcontainer:WaitForChild("rank")
local info2 = visualizedcontainer:WaitForChild("Info")
local rematch = realholder:WaitForChild("rematch")
local info3 = rematch:WaitForChild("Info")
local newgame = realholder:WaitForChild("newgame")
local maingame = realholder:WaitForChild("maingame")
local hub = realholder:WaitForChild("hub")
local readyup = container:WaitForChild("readyup")
local info4 = readyup:WaitForChild("Info")
local v26 = {
	visualizedcontainer,
	barback,
	rematch,
	newgame,
	maingame,
	hub
}

local function fn27(data)
	local anchorPoint = data.AnchorPoint
	local position = data.Position
	local size = data.Size
	return UDim2.new(
		position.X.Scale + size.X.Scale * (0.5 - anchorPoint.X),
		position.X.Offset + size.X.Offset * (0.5 - anchorPoint.X),
		position.Y.Scale + size.Y.Scale * (0.5 - anchorPoint.Y),
		position.Y.Offset + size.Y.Offset * (0.5 - anchorPoint.Y)
	)
end

local uIScales = {}
local v27 = "1v1s"
local v28 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function onMouseButton1Click()
	if shared and shared.sfx then
		shared.sfx({
			SoundId = "rbxassetid://6895079853",
			Parent = Workspace,
			Volume = 0.5
		}):Play()
	end
end

for _, parent in pairs(v26) do
	parent.Position = fn27(parent)
	parent.AnchorPoint = Vector2.new(0.5, 0.5)
	local uIScale = parent:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	uIScale.Parent = parent
	uIScales[parent] = uIScale
end

rank.Position = fn27(rank)
rank.AnchorPoint = Vector2.new(0.5, 0.5)
local uIScale = rank:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
uIScale.Parent = rank
local count2 = 0
local RunService2 = game:GetService("RunService")
local isStudio = RunService2:IsStudio()
local v29 = nil

local function fn28()
	local v30 = v29

	if not v30 then
		local v31 = v27
		v30 = tonumber(fn(localPlayer:GetAttribute("RankDatas"))[v31]) or 0
	end

	local v31 = v27
	local v32 = tonumber(fn(localPlayer:GetAttribute("RankPlacements"))[v31]) or 0
	local v33

	if v29 == nil then
		v33 = v32 < 10
	else
		v33 = false
	end

	local v34 = fn2(v30, v27)
	local name2 = not v34 and "Unranked" or v34.name or "Unranked"
	local nextmin

	if v33 then
		nextmin = v34 and v34.nextmin or 100
	else
		nextmin = v34 and v34.nextmin or nil
	end

	local pct = not nextmin and 1 or math.clamp(v30 / nextmin, 0, 1) or 1
	local et, mt

	if nextmin then
		et = string.format("%d / %d ELO", v30, nextmin)

		if v33 then
			mt = string.format("%d/%d MATCHES", v32, 10)
		else
			local count3 = 0

			while v30 < nextmin and count3 < 999 do
				v30 += math.floor(math.clamp((v30 >= 2600 and 24 or v30 >= 1200 and 32 or 40) * 0.5, 8, 50) + 0.5)
				count3 += 1
			end

			local v39 = math.max(1, count3)
			mt = string.format("%d WIN%s TO RANK", v39, v39 == 1 and "" or "S")
		end
	else
		et = string.format("%d ELO", v30)
		mt = "MAX RANK"
	end

	return {
		pct = pct,
		name = name2,
		et = et,
		mt = mt
	}
end

local v30 = {}

local function fn29()
	for _, v31 in pairs(v30) do
		local v32 = v31
		pcall(function()
			v32:stop()
		end)
	end

	v30 = {}
end

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://123957138451971"
sound.Volume = 0.6
sound.Parent = Workspace
sound.PlaybackSpeed = 1.15

local function fn30(data)
	fn29()
	info2.Text = ""
	elocount.Text = ""
	info.Text = ""
	local v31 = Type.play(info2, data.name:upper(), {
		cps = 35
	})
	local v32 = Type.play(elocount, data.et, {
		cps = 35
	})
	local v33 = Type.play(info, data.mt, {
		cps = 35
	})

	if v31 then
		table.insert(v30, v31)
	end

	if v32 then
		table.insert(v30, v32)
	end

	if v33 then
		table.insert(v30, v33)
	end
end

local function fn31(p)
	if v28 then
		v28:Cancel()
	end

	v28 = TweenService:Create(realfiller, TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.new(p.pct, 0, 1, 0)
	})
	v28:Play()
end

local function fn32(data)
	rank.Image = v3[data.name] or "rbxassetid://125981469994303"
	fn4(info2, data.name)
	info2.Text = data.name:upper()
	elocount.Text = data.et
	info.Text = data.mt
	realfiller.Size = UDim2.new(data.pct, 0, 1, 0)
end

local name = nil

local function fn33(data)
	name = data.name
	fn29()
	shared.sfx({
		SoundId = "rbxassetid://4612386227",
		Parent = Workspace,
		Volume = 2
	}):Play()
	TweenService:Create(uIScale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Scale = 0
	}):Play()
	task.wait(0.1)
	rank.Image = v3[data.name] or "rbxassetid://125981469994303"
	fn4(info2, data.name)
	info2.Text = data.name:upper()
	elocount.Text = data.et
	info.Text = data.mt
	realfiller.Size = UDim2.new(0, 0, 1, 0)
	TweenService:Create(uIScale, TweenInfo.new(0.085, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Scale = 1.3
	}):Play()
	task.wait(0.08)
	fn31(data)
	TweenService:Create(uIScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
end

local function fn34(p)
	fn29()

	if v28 then
		v28:Cancel()
	end

	v29 = 0
	local name2 = fn28().name
	local lastTime2 = tick()

	while count2 == p do
		local v31 = math.clamp((tick() - lastTime2) / 1.5, 0, 1)
		v29 = math.floor(v31 * 100 + 0.5)
		local v32 = fn28()

		if v32.name ~= name2 then
			fn33(v32)
			break
		end

		fn32(v32)

		if v31 >= 1 then
			break
		else
			task.wait()
		end
	end

	if count2 == p then
		v29 = nil
	end
end

local function fn35()
	local v31 = fn28()

	if name and name ~= v31.name then
		fn33(v31)
		return
	end

	name = v31.name
	rank.Image = v3[v31.name] or "rbxassetid://125981469994303"
	fn4(info2, v31.name)
	fn29()
	info2.Text = v31.name:upper()
	elocount.Text = v31.et
	info.Text = v31.mt
	fn31(v31)
end

local function fn36(p)
	count2 += 1
	local v31 = count2

	if p and isStudio then
		v29 = 0
	end

	local v32 = fn28()
	name = v32.name

	for _, v33 in pairs(v26) do
		uIScales[v33].Scale = 0
	end

	realfiller.Size = UDim2.new(0, 0, 1, 0)
	fn29()
	info2.Text = ""
	elocount.Text = ""
	info.Text = ""
	rank.Image = v3[v32.name] or "rbxassetid://125981469994303"
	fn4(info2, v32.name)

	for _, v33 in pairs(v26) do
		TweenService:Create(uIScales[v33], TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Scale = 1
		}):Play()
	end

	task.delay(0.15, function()
		if count2 ~= v31 then
			return
		end

		fn30(v32)
	end)
	task.delay(0.04999999999999999, function()
		if count2 ~= v31 then
			return
		end

		fn31(v32)
	end)
	local v33 = 0.95

	if p and isStudio then
		task.delay(v33, function()
			if count2 ~= v31 then
				return
			end

			fn34(v31)
		end)
		return v33 + 1.5 + 1
	end

	return v33
end

task.spawn(function()
	repeat
		task.wait(0.1)
	until localPlayer:GetAttribute("RankDatas") and localPlayer:GetAttribute("RankPlacements")

	task.wait(0.05)
	fn35()
end)
localPlayer:GetAttributeChangedSignal("RankDatas"):Connect(fn35)
localPlayer:GetAttributeChangedSignal("RankPlacements"):Connect(fn35)
container:GetPropertyChangedSignal("Visible"):Connect(function()
	if container.Visible then
		fn35()
	end
end)
shared.RankedEndScreen = shared.RankedEndScreen or {}

function shared.RankedEndScreen.setMode(p)
	if RANKTIERS[p] then
		v27 = p
		fn35()
	end
end

function shared.RankedEndScreen.setRematch(value, value2)
	info3.Text = string.format("%d/%d", value or 0, value2 or 2)
end

info3.Text = "0/2"
rematch.MouseButton1Click:Connect(onMouseButton1Click)
realholder:GetPropertyChangedSignal("Visible"):Connect(function()
	if realholder.Visible then
		local v31 = Workspace:GetAttribute("RankedThrees") and "3v3s" or Workspace:GetAttribute("RankedTwos") and "2v2s" or Workspace:GetAttribute("RankedOnes") and "1v1s" or nil or v27
		local v33 = fn2(tonumber(fn(localPlayer:GetAttribute("RankDatas"))[v31]) or 0, v31)
		local name2 = v33 and v33.name or "Unranked"
		rank.Image = v3[name2] or v3.Unranked
	end
end)
newgame.MouseButton1Click:Connect(function()
	onMouseButton1Click() -- equivalent call inferred; original call site unknown
	local mode = Workspace:GetAttribute("RankedThrees") and "3v3s" or Workspace:GetAttribute("RankedTwos") and "2v2s" or Workspace:GetAttribute("RankedOnes") and "1v1s" or nil

	if not mode then
		return
	end

	fn24(mode)
end)
hub.MouseButton1Click:Connect(function()
	onMouseButton1Click() -- equivalent call inferred; original call site unknown
	pcall(function()
		local TeleportService = game:GetService("TeleportService")
		TeleportService:Teleport(12360882630, localPlayer)
	end)
end)
maingame.MouseButton1Click:Connect(function()
	onMouseButton1Click() -- equivalent call inferred; original call site unknown
	pcall(function()
		local TeleportService = game:GetService("TeleportService")
		TeleportService:Teleport(10449761463, localPlayer)
	end)
end)
readyup.Visible = false
local flag7 = false

local function fn37()
	local rankedReadyCount = Workspace:GetAttribute("RankedReadyCount") or 0
	local rankedReadyMax = Workspace:GetAttribute("RankedReadyMax") or 0
	local rankedReadyLocked = Workspace:GetAttribute("RankedReadyLocked") == true
	local gameStarted = Workspace:GetAttribute("GameStarted") == true

	if rankedReadyMax <= 0 or rankedReadyLocked or gameStarted then
		readyup.Visible = false
	else
		info4.Text = string.format("%d/%d", rankedReadyCount, rankedReadyMax)
	end
end

task.delay(3.5, function()
	local rankedReadyLocked = Workspace:GetAttribute("RankedReadyLocked") == true
	local gameStarted = Workspace:GetAttribute("GameStarted") == true
	local rankedReadyMax = Workspace:GetAttribute("RankedReadyMax") or 0

	if rankedReadyLocked or gameStarted or rankedReadyMax <= 0 then
		return
	end

	repeat
		task.wait()
	until game:IsLoaded()

	readyup.Visible = true
	fn37()
end)
readyup.MouseButton1Click:Connect(function()
	if flag7 or (Workspace:GetAttribute("RankedReadyLocked") or Workspace:GetAttribute("GameStarted")) then
		return
	end

	flag7 = true
	onMouseButton1Click() -- equivalent call inferred; original call site unknown
	local character = localPlayer.Character
	local communicate = character and character:FindFirstChild("Communicate")

	if communicate then
		communicate:FireServer({
			Goal = "Ranked Ready Up"
		})
	end
end)
Workspace:GetAttributeChangedSignal("RankedReadyCount"):Connect(fn37)
Workspace:GetAttributeChangedSignal("RankedReadyMax"):Connect(fn37)
Workspace:GetAttributeChangedSignal("RankedReadyLocked"):Connect(fn37)
Workspace:GetAttributeChangedSignal("GameStarted"):Connect(fn37)
local rankedDebugWin = game.ReplicatedStorage:FindFirstChild("RankedDebugWin")

if not rankedDebugWin then
	task.spawn(function()
		rankedDebugWin = game.ReplicatedStorage:WaitForChild("RankedDebugWin", 10)
	end)
end

local sound2 = Instance.new("Sound")
sound2.SoundId = "rbxassetid://132488321213072"
sound2.Volume = 0.7
sound2.Parent = Workspace
sound2.TimePosition = 0.06
sound2.PlaybackSpeed = 1.03
local flag8 = false

local function fn38()
	if flag8 or not (Workspace:GetAttribute("RankedOnes") or Workspace:GetAttribute("RankedTwos") or Workspace:GetAttribute("RankedThrees")) or not Workspace:GetAttribute("FoundWinner") then
		return
	end

	task.wait(6)

	for _, label in pairs(ranked:GetDescendants()) do
		if label:IsA("TextLabel") and label.Text == "Hub" then
			label.Text = "MAIN GAME"
		end
	end

	flag8 = true
	flag3 = false
	flag2 = false
	flag = false
	v13 = "idle"
	v22.token += 1

	if v22.task then
		task.cancel(v22.task)
		v22.task = nil
	end

	v23.threadtoken += 1

	if v23.colortween then
		v23.colortween:Cancel()
		v23.colortween = nil
	end

	counter.TextColor3 = textColor3
	counter.Text = "00:00"
	count = 0
	matchSearch.Visible = false
	readyup.Visible = false
	rankedOther.Visible = false
	realholder.Visible = true
	v27 = Workspace:GetAttribute("RankedThrees") and "3v3s" or Workspace:GetAttribute("RankedTwos") and "2v2s" or Workspace:GetAttribute("RankedOnes") and "1v1s" or nil or v27
	fn36()

	if shared.virtualcursor then
		pcall(shared.virtualcursor, ranked2)
	end
end

if Workspace:GetAttribute("FoundWinner") then
	fn38()
end

Workspace:GetAttributeChangedSignal("FoundWinner"):Connect(function()
	if Workspace:GetAttribute("FoundWinner") then
		fn38()
	end
end)
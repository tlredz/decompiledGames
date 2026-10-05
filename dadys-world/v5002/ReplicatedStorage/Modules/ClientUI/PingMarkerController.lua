local createVector = vector.create
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local PingConfig = require(script.Parent.Parent.Services.PingConfig)
local StickerNotificationUI = require(script.Parent.Parent.UI.StickerNotificationUI)
local PendingUpdates = require(script.Parent.Parent.Core.PendingUpdates)
local iconsByChildName = {}
local iconsByChildName2 = {}
local iconsByChildName3 = {}

local function FindMonsterAtPosition(position, value)
	local tagged = CollectionService:GetTagged("Twisted")
	local v = value or 20

	for _, model in ipairs(tagged) do
		if not model:IsA("Model") then
			local parent = model.Parent

			while parent and parent ~= workspace do
				if parent:IsA("Model") then
					model = parent
					break
				else
					parent = parent.Parent
				end
			end
		end

		if not (model and model:IsA("Model")) then
			continue
		end

		local primaryPart = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")

		if primaryPart and (primaryPart.Position - position).Magnitude < v then
			return model
		end
	end

	return nil
end

local function GetMonsterIcon(childName)
	if not childName then
		return nil
	end

	if iconsByChildName2[childName] then
		return iconsByChildName2[childName]
	end

	local monsterData = ReplicatedStorage:FindFirstChild("MonsterData")

	if not monsterData then
		return nil
	end

	local moduleScript = monsterData:FindFirstChild(childName)

	if moduleScript and moduleScript:IsA("ModuleScript") then
		local success, result = pcall(function()
			return require(moduleScript)
		end)

		if success and result and result.Icon then
			iconsByChildName2[childName] = result.Icon
			return result.Icon
		end
	end

	return nil
end

local function GetCharacterIcon(childName)
	if not childName then
		return nil
	end

	if iconsByChildName3[childName] then
		return iconsByChildName3[childName]
	end

	local towerData = ReplicatedStorage:FindFirstChild("TowerData")

	if not towerData then
		return nil
	end

	local init = towerData:FindFirstChild(childName)

	if not init then
		for _, child in ipairs(towerData:GetChildren()) do
			if child.Name:lower() ~= childName:lower() then
				continue
			end

			init = child
			break
		end
	end

	if not init then
		return nil
	end

	if init:IsA("Folder") then
		init = init:FindFirstChild("init")
	end

	if init and init:IsA("ModuleScript") then
		local success, result = pcall(function()
			return require(init)
		end)

		if success and result and result.Icon then
			iconsByChildName3[childName] = result.Icon
			return result.Icon
		end
	end

	return nil
end

local function GetItemIcon(childName)
	if not childName then
		return nil
	end

	if iconsByChildName[childName] then
		return iconsByChildName[childName]
	end

	local itemModules = ReplicatedStorage:FindFirstChild("ItemModules")

	if not itemModules then
		return nil
	end

	local moduleScript = itemModules:FindFirstChild(childName) or itemModules:FindFirstChild((childName:gsub(" ", "")))

	if not moduleScript then
		for _, child in ipairs(itemModules:GetChildren()) do
			if not (child.Name:lower() == childName:lower() or child.Name:lower():gsub(" ", "") == childName:lower():gsub(
				" ",
				""
			)) then
				continue
			end

			moduleScript = child
			break
		end
	end

	if moduleScript and moduleScript:IsA("ModuleScript") then
		local success, result = pcall(function()
			return require(moduleScript)
		end)

		if success and result and result.Icon then
			iconsByChildName[childName] = result.Icon
			return result.Icon
		end
	end

	return nil
end

local PingMarkerController = {}
local v = {}
local v2 = {}

local function CreatePingBillboard(p, label, childName, color, p2)
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "PingMarker"
	billboardGui.Size = UDim2.new(0, 120, 0, 80)
	billboardGui.StudsOffset = Vector3.new(0, PingConfig.MARKER_HEIGHT_OFFSET, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.MaxDistance = 500
	billboardGui.LightInfluence = 0
	local frame = Instance.new("Frame")
	frame.Name = "Frame"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.Parent = billboardGui
	local image = p2 or PingConfig.Types[p] and PingConfig.Types[p].icon or PingConfig.Types.Location.icon
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Icon"
	imageLabel.Size = UDim2.new(0, 40, 0, 40)
	imageLabel.Position = UDim2.new(0.5, -20, 0, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = image
	local imageColor

	if p2 then
		imageColor = Color3.new(1, 1, 1) or color
	else
		imageColor = color
	end

	imageLabel.ImageColor3 = imageColor
	imageLabel.Parent = frame
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Label"
	textLabel.Size = UDim2.new(1, 0, 0, 20)
	textLabel.Position = UDim2.new(0, 0, 0, 42)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = label
	textLabel.TextColor3 = color
	textLabel.TextSize = 14
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextStrokeTransparency = 0
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.Parent = frame
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "PlayerName"
	textLabel2.Size = UDim2.new(1, 0, 0, 16)
	textLabel2.Position = UDim2.new(0, 0, 0, 60)
	textLabel2.BackgroundTransparency = 1
	textLabel2.Text = childName .. " pinged"
	textLabel2.TextColor3 = Color3.fromRGB(200, 200, 200)
	textLabel2.TextSize = 11
	textLabel2.Font = Enum.Font.Gotham
	textLabel2.TextStrokeTransparency = 0.5
	textLabel2.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel2.Parent = frame
	local uIScale = Instance.new("UIScale")
	uIScale.Name = "UIScale"
	uIScale.Scale = 0
	uIScale.Parent = frame
	return billboardGui
end

local function CreateHighlight(instance, p)
	if not (instance and instance:IsA("Instance")) then
		return nil
	end

	local parent

	if instance:IsA("BasePart") then
		parent = instance.Parent

		if not parent:IsA("Model") then
			parent = instance
		end
	else
		parent = instance
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = "PingHighlight"
	highlight.FillTransparency = 0.8
	highlight.FillColor = p
	highlight.OutlineColor = p
	highlight.OutlineTransparency = 0
	highlight.Parent = parent
	return highlight
end

local function CreateAnchorPart(position)
	local part = Instance.new("Part")
	part.Name = "PingAnchor"
	part.Size = createVector(0.5, 0.5, 0.5)
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Parent = workspace
	return part
end

local function CreateGroundBeam(parent, color)
	local attachment = Instance.new("Attachment")
	attachment.Name = "TopAttachment"
	attachment.Parent = parent
	local part = Instance.new("Part")
	part.Name = "PingGroundAnchor"
	part.Size = createVector(0.5, 0.1, 0.5)
	part.Position = Vector3.new(parent.Position.X, parent.Position.Y - 50, parent.Position.Z)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Parent = workspace
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { parent, part }
	local raycastResult = workspace:Raycast(parent.Position, createVector(0, -100, 0), raycastParams)

	if raycastResult then
		part.Position = raycastResult.Position
	end

	local attachment2 = Instance.new("Attachment")
	attachment2.Name = "BottomAttachment"
	attachment2.Parent = part
	local beam = Instance.new("Beam")
	beam.Name = "PingBeam"
	beam.Attachment0 = attachment
	beam.Attachment1 = attachment2
	beam.Color = ColorSequence.new(color)
	beam.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 0.8) })
	beam.Width0 = 0.3
	beam.Width1 = 0.5
	beam.FaceCamera = true
	beam.Parent = parent
	return part, beam
end

local function AnimatePingIn(instance)
	local frame = instance:FindFirstChild("Frame")

	if not frame then
		return
	end

	local uIScale = frame:FindFirstChild("UIScale")

	if not uIScale then
		return
	end

	TweenService:Create(uIScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
end

local function StartPulseAnimation(instance, _)
	local frame = instance:FindFirstChild("Frame")

	if not frame then
		return nil
	end

	local uIScale = frame:FindFirstChild("UIScale")
	local icon = frame:FindFirstChild("Icon")

	if not (uIScale and icon) then
		return nil
	end

	local lastTime = tick()
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if instance and instance.Parent then
			local scale = math.sin((tick() - lastTime) * PingConfig.PULSE_SPEED * 3.141592653589793) * 0.08 + 1

			if uIScale then
				uIScale.Scale = scale
			end
		elseif heartbeatConnection then
			heartbeatConnection:Disconnect()
		end
	end)
	return heartbeatConnection
end

local function AnimatePingOut(instance, p, _, _, fn)
	local tweenInfo = TweenInfo.new(PingConfig.FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local frame = instance:FindFirstChild("Frame")

	if frame then
		local icon = frame:FindFirstChild("Icon")
		local label = frame:FindFirstChild("Label")
		local playerName = frame:FindFirstChild("PlayerName")

		if icon then
			TweenService:Create(icon, tweenInfo, {
				ImageTransparency = 1
			}):Play()
		end

		if label then
			TweenService:Create(label, tweenInfo, {
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}):Play()
		end

		if playerName then
			TweenService:Create(playerName, tweenInfo, {
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}):Play()
		end
	end

	if p then
		TweenService:Create(p, tweenInfo, {
			OutlineTransparency = 1,
			FillTransparency = 1
		}):Play()
	end

	task.delay(PingConfig.FADE_TIME, function()
		if fn then
			fn()
		end
	end)
end

local function PlayPingSound(_)
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return
	end

	local playerGui = localPlayer:FindFirstChild("PlayerGui")

	if not playerGui then
		return
	end

	Audio:Play("Sounds.UI.Ping", {
		Volume = 0.5,
		Parent = playerGui
	})
end

local function EnforcePingLimit(childName)
	if not v[childName] then
		return
	end

	while #v[childName] > PingConfig.MAX_PINGS_PER_PLAYER do
		local v3 = table.remove(v[childName], 1)

		if v3 and v3.cleanup then
			v3.cleanup()
		end
	end
end

function PingMarkerController.CreatePing(childName, p, position, targetModel, p3)
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return
	end

	local v3 = PingConfig.Types[p] or PingConfig.Types.Location
	local color = v3.color
	local label = v3.label

	if p == "Teammate" and p3 then
		label = tostring(p3)
	elseif p == "Item" and p3 then
		label = string.upper((tostring(p3)))
	end

	if PendingUpdates.StickerNotifications then
		local icon = v3.icon
		local v4

		if p == "Twisted" then
			v4 = "DANGER!"

			if p3 then
				local monsterIcon = GetMonsterIcon(p3)

				if monsterIcon then
					icon = monsterIcon
				end
			end
		elseif p == "NeedHealing" then
			v4 = "NEEDS HEALING!"

			if p3 then
				local characterIcon = GetCharacterIcon(p3)

				if characterIcon then
					icon = characterIcon
				end
			end
		elseif label == "" or label == "HERE" then
			v4 = "Pinged location"
		else
			v4 = label
		end

		if (p == "Item" or p == "Tape") and p3 then
			icon = GetItemIcon(p3) or icon
		end

		StickerNotificationUI.ShowNotification(childName, icon, v4)
	end

	local v4 = nil

	if p == "Twisted" and p3 then
		v4 = GetMonsterIcon(p3)
	elseif p == "NeedHealing" and p3 then
		v4 = GetCharacterIcon(p3)
	elseif (p == "Item" or p == "Tape") and p3 then
		v4 = GetItemIcon(p3)
	end

	if p == "NeedHealing" or p == "Twisted" then
		local humanoidRootPart = nil
		local character = nil

		if p == "NeedHealing" then
			local child = Players:FindFirstChild(childName)
			character = child and child.Character
			humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		elseif p == "Twisted" then
			local monsterAtPosition = FindMonsterAtPosition(position, 30)

			if monsterAtPosition then
				humanoidRootPart = monsterAtPosition:FindFirstChild("Head") or monsterAtPosition:FindFirstChild("HumanoidRootPart") or monsterAtPosition.PrimaryPart
				character = monsterAtPosition
			end
		end

		if character and v2[character] then
			local v5 = v2[character]

			if v5.cleanup then
				v5.cleanup()
			end
		end

		if humanoidRootPart then
			local billboard = CreatePingBillboard(p, label, childName, color, v4)
			billboard.Adornee = humanoidRootPart
			billboard.Parent = localPlayer:FindFirstChild("PlayerGui")
			local _ = childName == localPlayer.Name
			local localPlayer2 = Players.LocalPlayer
			local playerGui = localPlayer2 and localPlayer2:FindFirstChild("PlayerGui")

			if playerGui then
				Audio:Play("Sounds.UI.Ping", {
					Volume = 0.5,
					Parent = playerGui
				})
			end

			AnimatePingIn(billboard)
			local pulseConnection = StartPulseAnimation(billboard, color)

			if not v[childName] then
				v[childName] = {}
			end

			local v7 = {
				billboard = billboard,
				anchor = nil,
				highlight = nil,
				groundPart = nil,
				pulseConnection = pulseConnection,
				followConnection = nil,
				targetModel = character,
				cleanup = nil
			}

			if character then
				v2[character] = v7
			end

			local child = p == "NeedHealing" and Players:FindFirstChild(childName)

			if child then
				v7.followConnection = child.CharacterAdded:Connect(function(character2)
					local humanoidRootPart2 = character2:WaitForChild("HumanoidRootPart", 5)

					if humanoidRootPart2 and v7.billboard then
						v7.billboard.Adornee = humanoidRootPart2
					end
				end)
			end

			function v7.cleanup()
				if v7.pulseConnection then
					v7.pulseConnection:Disconnect()
					v7.pulseConnection = nil
				end

				if v7.followConnection then
					v7.followConnection:Disconnect()
					v7.followConnection = nil
				end

				if v7.billboard then
					v7.billboard:Destroy()
				end

				if v7.targetModel and v2[v7.targetModel] == v7 then
					v2[v7.targetModel] = nil
				end

				if v[childName] then
					for i, v8 in ipairs(v[childName]) do
						if v8 ~= v7 then
							continue
						end

						table.remove(v[childName], i)
						return
					end
				end
			end

			table.insert(v[childName], v7)
			EnforcePingLimit(childName)
			task.delay(PingConfig.DURATION - PingConfig.FADE_TIME, function()
				if v7.pulseConnection then
					v7.pulseConnection:Disconnect()
					v7.pulseConnection = nil
				end

				AnimatePingOut(billboard, nil, nil, nil, function()
					v7.cleanup()
				end)
			end)
			return v7
		end
	end

	if targetModel and v2[targetModel] then
		local v5 = v2[targetModel]

		if v5.cleanup then
			v5.cleanup()
		end
	end

	local part = Instance.new("Part")
	part.Name = "PingAnchor"
	part.Size = createVector(0.5, 0.5, 0.5)
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Parent = workspace
	local billboard2 = CreatePingBillboard(p, label, childName, color, v4)
	billboard2.Adornee = part
	billboard2.Parent = localPlayer:FindFirstChild("PlayerGui")
	local groundPart = CreateGroundBeam(part, color)
	local _ = childName == localPlayer.Name
	local localPlayer2 = Players.LocalPlayer
	local playerGui = localPlayer2 and localPlayer2:FindFirstChild("PlayerGui")

	if playerGui then
		Audio:Play("Sounds.UI.Ping", {
			Volume = 0.5,
			Parent = playerGui
		})
	end

	AnimatePingIn(billboard2)
	local pulseConnection2 = StartPulseAnimation(billboard2, color)

	if not v[childName] then
		v[childName] = {}
	end

	local v9 = {
		billboard = billboard2,
		anchor = part,
		highlight = nil,
		groundPart = groundPart,
		pulseConnection = pulseConnection2,
		targetModel = targetModel,
		cleanup = nil
	}

	if targetModel then
		v2[targetModel] = v9
	end

	function v9.cleanup()
		if v9.pulseConnection then
			v9.pulseConnection:Disconnect()
			v9.pulseConnection = nil
		end

		if v9.billboard then
			v9.billboard:Destroy()
		end

		if v9.anchor then
			v9.anchor:Destroy()
		end

		if v9.highlight then
			v9.highlight:Destroy()
		end

		if v9.groundPart then
			v9.groundPart:Destroy()
		end

		if v9.targetModel and v2[v9.targetModel] == v9 then
			v2[v9.targetModel] = nil
		end

		if v[childName] then
			for i, v10 in ipairs(v[childName]) do
				if v10 ~= v9 then
					continue
				end

				table.remove(v[childName], i)
				return
			end
		end
	end

	table.insert(v[childName], v9)
	EnforcePingLimit(childName)
	task.delay(PingConfig.DURATION - PingConfig.FADE_TIME, function()
		if v9.pulseConnection then
			v9.pulseConnection:Disconnect()
			v9.pulseConnection = nil
		end

		AnimatePingOut(billboard2, nil, part, groundPart, function()
			v9.cleanup()
		end)
	end)
	return v9
end

function PingMarkerController.ClearPlayerPings(p)
	if not v[p] then
		return
	end

	for _, v3 in ipairs(v[p]) do
		if v3.cleanup then
			v3.cleanup()
		end
	end

	v[p] = {}
end

function PingMarkerController.ClearAllPings()
	for k, _ in pairs(v) do
		PingMarkerController.ClearPlayerPings(k)
	end
end

function PingMarkerController.GetPingCount(p)
	if v[p] then
		return #v[p]
	end

	return 0
end

return PingMarkerController
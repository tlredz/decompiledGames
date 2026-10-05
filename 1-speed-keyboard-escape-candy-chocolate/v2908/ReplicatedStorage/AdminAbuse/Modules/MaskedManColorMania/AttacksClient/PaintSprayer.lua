local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebris = require(script.Parent.ClientDebris)
local MaskedManColorManiaConfig = require(ReplicatedStorage.AdminAbuse.Modules.MaskedManColorMania.MaskedManColorManiaConfig)
local v = {}
local v2 = {}
local flag = false
local connections = {}
local connections2 = {}
local sprayTickSec = 0
local flag2 = false
local v3 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function getAssetsFolder()
	local adminAbuse = ReplicatedStorage:FindFirstChild("AdminAbuse")
	local maskedManColorMania = adminAbuse and adminAbuse:FindFirstChild("MaskedManColorMania")
	return maskedManColorMania and maskedManColorMania:FindFirstChild("Assets")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ensureSpinBound()
	if flag then
		return
	end

	flag = true
	RunService:BindToRenderStep("PaintSprayerPickupSpin", Enum.RenderPriority.Last.Value, function()
		local now = os.clock()

		for _, v4 in v do
			local part = v4.part

			if not part.Parent then
				continue
			end

			local v5 = math.sin(now * v4.pitchPerSec) * v4.pitchAmplitudeRad
			part.CFrame = CFrame.new(v4.basePosition) * CFrame.Angles(0, now * v4.yawPerSec, 0) * CFrame.Angles(
				v5,
				0,
				0
			)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unbindSpinIfEmpty()
	if flag and next(v) == nil then
		RunService:UnbindFromRenderStep("PaintSprayerPickupSpin")
		flag = false
	end
end

local function popAndDestroy(instance)
	local tween = TweenService:Create(instance, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Size = instance.Size * 1.6,
		Transparency = 1
	})
	tween.Completed:Once(function()
		pcall(function()
			instance:Destroy()
		end)
	end)
	tween:Play()
end

local PaintSprayer = {
	SpawnPaintSprayerPickup = function(data)
		local id = data.id

		if type(id) ~= "number" then
			return
		end

		local pickupAssetName = MaskedManColorManiaConfig.PaintSprayer.PickupAssetName
		local assetsFolder = getAssetsFolder() -- equivalent call inferred; original call site unknown
		local part = assetsFolder and assetsFolder:FindFirstChild(pickupAssetName)

		if not (part and part:IsA("BasePart")) then
			warn(("[MaskedManColorMania] PaintSprayer: %s not found in RS.AdminAbuse.MaskedManColorMania.Assets"):format(pickupAssetName))
			return
		end

		local clone = part:Clone()
		clone.Anchored = true
		clone.CanCollide = false
		clone.CanQuery = false
		clone.CastShadow = false
		local vector2 = Vector3.new(data.x or 0, data.y or 0, data.z or 0)
		clone.CFrame = CFrame.new(vector2)
		clone.Parent = ClientDebris()
		v[id] = {
			part = clone,
			basePosition = vector2,
			yawPerSec = math.rad((math.random(30, 70))) * (math.random(0, 1) == 0 and -1 or 1),
			pitchPerSec = math.random(150, 250) / 100,
			pitchAmplitudeRad = math.rad((math.random(15, 30)))
		}
		ensureSpinBound() -- equivalent call inferred; original call site unknown
	end,
	DespawnPaintSprayerPickup = function(p)
		local v4 = v[p.id]

		if not v4 then
			return
		end

		v[p.id] = nil
		unbindSpinIfEmpty() -- equivalent call inferred; original call site unknown
		popAndDestroy(v4.part)
	end
}

local function spawnBubble(position: Vector3, vector2: Vector3, p: number)
	local bubbleAssetName = MaskedManColorManiaConfig.PaintSprayer.BubbleAssetName
	local assetsFolder = getAssetsFolder() -- equivalent call inferred; original call site unknown
	local part = assetsFolder and assetsFolder:FindFirstChild(bubbleAssetName)
	local v4

	if part and part:IsA("BasePart") then
		v4 = part:Clone()
	else
		v4 = Instance.new("Part")
		v4.Shape = Enum.PartType.Ball
		v4.Size = createVector(1, 1, 1)
		v4.Material = Enum.Material.SmoothPlastic
		v4.Transparency = 0.15
	end

	v4.Anchored = true
	v4.CanCollide = false
	v4.CanQuery = false
	v4.CastShadow = false
	v4.Size *= MaskedManColorManiaConfig.PaintSprayer.BubbleScale or 1
	v4.CFrame = CFrame.new(position)
	local colored = MaskedManColorManiaConfig.KeycapColors.Colored
	v4.Color = colored[math.random(1, #colored)]
	v4.Parent = ClientDebris()
	table.insert(v2, v4)
	local position2 = position:Lerp(vector2, 0.5) + createVector(0, 3, 0)
	local tween = TweenService:Create(v4, TweenInfo.new(p * 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Position = position2
	})
	local tween2 = TweenService:Create(v4, TweenInfo.new(p * 0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		Position = vector2
	})
	local flag3 = false

	local function onLand()
		if flag3 then
			return
		end

		flag3 = true

		for k, v6 in v2 do
			if v6 ~= v4 then
				continue
			end

			table.remove(v2, k)
			break
		end

		popAndDestroy(v4)
	end

	tween.Completed:Once(function()
		if v4.Parent then
			tween2:Play()
		end
	end)
	tween2.Completed:Once(onLand)
	task.delay(p + 0.15, onLand)
	tween:Play()
end

local function sprayTickLocal(data)
	local character = Players.LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local sprayConeHalfAngleDeg = math.rad(data.SprayConeHalfAngleDeg)
	local v4 = (math.random() * 2 - 1) * sprayConeHalfAngleDeg
	local v5 = (math.random() * 2 - 1) * sprayConeHalfAngleDeg
	local v6 = data.SprayRangeMinStuds + math.random() * (data.SprayRangeStuds - data.SprayRangeMinStuds)
	local v7 = humanoidRootPart.CFrame * CFrame.Angles(0, v4, 0) * CFrame.Angles(v5, 0, 0)
	spawnBubble(
		humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 2 + createVector(0, 2, 0),
		v7.Position + v7.LookVector * v6,
		math.clamp(v6 / data.BubbleSpeedStudsPerSec, data.BubbleTravelTimeMinSec, data.BubbleTravelTimeMaxSec)
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopSprayLoop()
	if flag2 then
		RunService:UnbindFromRenderStep("PaintSprayerLocalTick")
	end

	local sound = v3 and v3.Handle:FindFirstChildOfClass("Sound")

	if sound then
		sound:Stop()
	end

	flag2 = false
	sprayTickSec = 0
end

local function startSprayLoop(p)
	if flag2 then
		return
	end

	flag2 = true
	sprayTickSec = p.SprayTickSec
	local sound = v3 and v3.Handle:FindFirstChildOfClass("Sound")

	if sound then
		sound:Play()
	end

	RunService:BindToRenderStep("PaintSprayerLocalTick", Enum.RenderPriority.Last.Value, function(p2: number)
		sprayTickSec += p2

		if sprayTickSec >= p.SprayTickSec then
			sprayTickSec = 0
			sprayTickLocal(p)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disconnectTool()
	for _, connection in connections2 do
		connection:Disconnect()
	end

	table.clear(connections2)
	v3 = nil
	stopSprayLoop() -- equivalent call inferred; original call site unknown
end

local function watchTool(tool, p)
	if v3 == tool then
		return
	end

	disconnectTool() -- equivalent call inferred; original call site unknown
	v3 = tool
	table.insert(connections2, tool.Activated:Connect(function()
		startSprayLoop(p)
	end))
	table.insert(connections2, tool.Deactivated:Connect(stopSprayLoop))
	table.insert(connections2, tool.Unequipped:Connect(stopSprayLoop))
	table.insert(connections2, tool.AncestryChanged:Connect(function()
		if not tool.Parent then
			disconnectTool() -- equivalent call inferred; original call site unknown
		end
	end))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tryWatch(tool, p)
	if v3 then
		return
	end

	if tool:IsA("Tool") and tool.Name == p.ToolAssetName then
		watchTool(tool, p)
	end
end

function PaintSprayer.start(p)
	local paintSprayer = p.PaintSprayer
	local localPlayer = Players.LocalPlayer

	local function watchContainer(instance)
		table.insert(connections, instance.ChildAdded:Connect(function(child)
			tryWatch(child, paintSprayer) -- equivalent call inferred; original call site unknown
		end))

		for _, child in instance:GetChildren() do
			tryWatch(child, paintSprayer) -- equivalent call inferred; original call site unknown
		end
	end

	local backpack = localPlayer:FindFirstChild("Backpack")

	if backpack then
		watchContainer(backpack)
	end

	table.insert(connections, localPlayer.ChildAdded:Connect(function(child)
		if child.Name == "Backpack" then
			watchContainer(child)
		end
	end))

	if localPlayer.Character then
		watchContainer(localPlayer.Character)
	end

	table.insert(connections, localPlayer.CharacterAdded:Connect(watchContainer))
end

function PaintSprayer.cleanup()
	disconnectTool() -- equivalent call inferred; original call site unknown

	for _, connection in connections do
		connection:Disconnect()
	end

	table.clear(connections)

	if flag then
		RunService:UnbindFromRenderStep("PaintSprayerPickupSpin")
		flag = false
	end

	for _, v4 in v do
		local v5 = v4
		pcall(function()
			v5.part:Destroy()
		end)
	end

	table.clear(v)

	for _, v4 in v2 do
		local v5 = v4
		pcall(function()
			v5:Destroy()
		end)
	end

	table.clear(v2)
end

return PaintSprayer
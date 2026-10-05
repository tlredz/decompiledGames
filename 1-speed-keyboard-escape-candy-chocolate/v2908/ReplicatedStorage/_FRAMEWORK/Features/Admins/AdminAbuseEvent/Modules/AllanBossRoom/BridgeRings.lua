local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local InstanceUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.InstanceUtils)
local VFXUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.VFXUtils)
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v = nil
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getContainer()
	if v and v.Parent then
		return v
	end

	local folder = Instance.new("Folder")
	folder.Name = "AllanBossRoomBridgeRings"
	folder.Parent = Workspace
	v = folder
	return folder
end

local function checkTemplate()
	local potentialInstance = InstanceUtils.getPotentialInstance(
		ReplicatedStorage,
		"AdminAbuse/AllanBossRoom/Assets/BridgeRepairWinRig"
	)

	if not (potentialInstance and potentialInstance:IsA("Model")) then
		return
			nil,
			"[AllanBossRoom] BridgeRings: no Model at ReplicatedStorage.AdminAbuse/AllanBossRoom/Assets/BridgeRepairWinRig"
	end

	local cylinder = potentialInstance:FindFirstChild("Cylinder")

	if cylinder and cylinder:IsA("BasePart") then
		return potentialInstance, nil
	end

	return nil, "[AllanBossRoom] BridgeRings: template has no 'Cylinder' BasePart"
end

local function setBarProgress(bar, value: number, flag: boolean)
	local Y = bar.Size.Y
	local uDim = UDim2.new(math.clamp(value, 0, 1), 0, Y.Scale, Y.Offset)

	if flag then
		TweenService:Create(bar, tweenInfo, {
			Size = uDim
		}):Play()
	else
		bar.Size = uDim
	end
end

local function playSpawnEffect(clone)
	local potentialInstance = InstanceUtils.getPotentialInstance(clone, "Root/Attachment")

	if not potentialInstance then
		return
	end

	VFXUtils.emitAttachment(potentialInstance)
	local potentialInstance2 = InstanceUtils.getPotentialInstance(
		ReplicatedStorage,
		"AdminAbuse/AllanBossRoom/SFX/MagicAppear"
	)

	if potentialInstance2 then
		local clone2 = potentialInstance2:Clone()
		clone2.Volume = 0.4
		clone2.RollOffMinDistance = 60
		clone2.RollOffMaxDistance = 250
		clone2.RollOffMode = Enum.RollOffMode.InverseTapered
		clone2.Parent = potentialInstance
		Debris:AddItem(clone2, 6)
		clone2:Play()
	end

	local pointLight = potentialInstance:FindFirstChildOfClass("PointLight")

	if pointLight then
		pointLight.Enabled = true
		pointLight.Brightness = 40
		TweenService:Create(pointLight, TweenInfo.new(2.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Brightness = 1
		}):Play()
	end
end

local function createRing(p: string, p2: number, position: Vector3, p3: number)
	local potentialInstance = InstanceUtils.getPotentialInstance(
		ReplicatedStorage,
		"AdminAbuse/AllanBossRoom/Assets/BridgeRepairWinRig"
	)
	local v3

	if potentialInstance and potentialInstance:IsA("Model") then
		local cylinder = potentialInstance:FindFirstChild("Cylinder")

		if not (cylinder and cylinder:IsA("BasePart")) then
			potentialInstance = nil
			v3 = "[AllanBossRoom] BridgeRings: template has no 'Cylinder' BasePart"
		end
	else
		potentialInstance = nil
		v3 = "[AllanBossRoom] BridgeRings: no Model at ReplicatedStorage.AdminAbuse/AllanBossRoom/Assets/BridgeRepairWinRig"
	end

	if not potentialInstance then
		warn(v3)
		return nil
	end

	local clone = potentialInstance:Clone()
	clone.Name = `BridgeRing_{p}_{p2}`
	local potentialInstance2 = InstanceUtils.getPotentialInstance(clone, "Root/BillboardGui/Top/TextLabel")

	if potentialInstance2 then
		potentialInstance2.Text = "REPAIR BRIDGE = WINS"
	end

	local cylinder = clone:FindFirstChild("Cylinder")
	cylinder.Size = Vector3.new(p3 * 2, cylinder.Size.Y, p3 * 2)
	clone:PivotTo(CFrame.new(position) * potentialInstance:GetPivot().Rotation)
	local container = getContainer() -- equivalent call inferred; original call site unknown
	clone.Parent = container
	local potentialInstance3 = InstanceUtils.getPotentialInstance(clone, "Root/BillboardGui/Bottom/ProgressBar/Bar")

	if potentialInstance3 then
		local Y = potentialInstance3.Size.Y
		potentialInstance3.Size = UDim2.new(0, 0, Y.Scale, Y.Offset)
	end

	playSpawnEffect(clone)
	return {
		model = clone,
		bar = potentialInstance3
	}
end

local BridgeRings = {}

function BridgeRings.handleSpawn(p: string, p2: number, vector: Vector3, p3: number)
	if RunService:IsServer() then
		return
	end

	local rings = v2[p]

	if not rings then
		rings = {}
		v2[p] = rings
	end

	if rings[p2] then
		return
	end

	local ring = createRing(p, p2, vector, p3)

	if ring then
		rings[p2] = ring
	end
end

function BridgeRings.handleProgress(p: string, p2: number)
	local v3 = v2[p]

	if v3 then
		for _, v4 in v3 do
			if v4.bar then
				setBarProgress(v4.bar, p2, true)
			end
		end
	end
end

function BridgeRings.handleDespawn(p: string)
	local v3 = v2[p]

	if not v3 then
		return
	end

	v2[p] = nil

	for _, v4 in v3 do
		local model = v4.model
		local potentialInstance = InstanceUtils.getPotentialInstance(model, "Root/Attachment")

		if potentialInstance then
			VFXUtils.emitAttachment(potentialInstance)
		end

		for _, part in model:GetDescendants() do
			if part:IsA("BasePart") then
				TweenService:Create(part, tweenInfo2, {
					Transparency = 1
				}):Play()
			end
		end

		Debris:AddItem(model, tweenInfo2.Time + 0.05)
	end
end

function BridgeRings.cleanup()
	table.clear(v2)

	if v then
		v:Destroy()
		v = nil
	end
end

return BridgeRings
local createVector = vector.create
local v = {
	DEFAULT = {
		ID = "sounds/action_footsteps_plastic.mp3",
		Speed = 1.85
	},
	[Enum.Material.Brick] = {
		ID = 178190837,
		Speed = 1
	},
	[Enum.Material.Foil] = {
		ID = 3542369667,
		Speed = 1.5
	},
	[Enum.Material.Cobblestone] = {
		ID = 178190837,
		Speed = 1
	},
	[Enum.Material.Concrete] = {
		ID = 277067660,
		Speed = 1
	},
	[Enum.Material.CorrodedMetal] = {
		ID = 177940974,
		Speed = 1
	},
	[Enum.Material.DiamondPlate] = {
		ID = 177940974,
		Speed = 1
	},
	[Enum.Material.Slate] = {
		ID = 178054124,
		Speed = 1
	},
	[Enum.Material.Fabric] = {
		ID = 133705377,
		Speed = 1.6
	},
	[Enum.Material.Water] = {
		ID = 184795891,
		Speed = 1
	},
	[Enum.Material.Granite] = {
		ID = 178054124,
		Speed = 1
	},
	[Enum.Material.Grass] = {
		ID = 177940963,
		Speed = 1
	},
	[Enum.Material.Ice] = {
		ID = 178190837,
		Speed = 1
	},
	[Enum.Material.Marble] = {
		ID = 178190837,
		Speed = 1
	},
	[Enum.Material.Metal] = {
		ID = 177940974,
		Speed = 1
	},
	[Enum.Material.Pebble] = {
		ID = 133761546,
		Speed = 1.85
	},
	[Enum.Material.Plastic] = {
		ID = 177940974,
		Speed = 1
	},
	[Enum.Material.SmoothPlastic] = {
		ID = 177940974,
		Speed = 1
	},
	[Enum.Material.Sand] = {
		ID = 212011266,
		Speed = 1
	},
	[Enum.Material.Wood] = {
		ID = 177940988,
		Speed = 1
	},
	[Enum.Material.WoodPlanks] = {
		ID = 211987063,
		Speed = 1
	},
	MAMMOTH = {
		ID = 14582831014,
		Speed = 2.5
	},
	TREX = {
		ID = 14582831014,
		Speed = 2
	},
	HYBRID_DRAGON = {
		ID = 86890219898712,
		Speed = 1.5
	},
	YETI = {
		ID = 88740254217838,
		Speed = 2.8
	},
	TIGER = {
		ID = 87192169815286,
		Speed = 1
	},
	TIGER_AWAKENED = {
		ID = 126718255891063,
		Speed = 1
	}
}
local parent = script.Parent
local humanoid = parent:WaitForChild("Humanoid")
local humanoidRootPart = parent:WaitForChild("HumanoidRootPart")
local running = humanoidRootPart:WaitForChild("Running")
running:Play()

-- equivalent calls inferred from this helper; original call sites unknown
local function getHeightScale()
	if not humanoid then
		return 1
	end

	if humanoid.AutomaticScalingEnabled then
		return 1 + (humanoid.HipHeight - 2.66) * 0.2 / 2.66
	end

	return 1
end

local v2 = newproxy()

local function update(p)
	local floorMaterial = humanoid.FloorMaterial

	if floorMaterial == Enum.Material.Air then
		running.Volume = 0
		return
	end

	if p == v2 then
		return
	end

	local mammoth = parent:FindFirstChild("Mammoth")
	local tRex = parent:FindFirstChild("TRex")
	local dragon = parent:FindFirstChild("Dragon")
	local dragonHybrid = parent:FindFirstChild("DragonHybrid")
	local gasRig = parent:FindFirstChild("GasRig")
	local yetiRig = parent:FindFirstChild("YetiRig")
	local tigerRig = parent:FindFirstChild("TigerRig")
	local auraActive = parent:GetAttribute("AuraActive")
	local magnetRig = parent:FindFirstChild("MagnetRig")

	if dragon or auraActive or magnetRig then
		return
	end

	local v3 = v[floorMaterial]
	local MAMMOTH = v3 or v.DEFAULT

	if mammoth then
		MAMMOTH = v.MAMMOTH
	elseif tRex then
		MAMMOTH = v.TREX
	elseif yetiRig then
		MAMMOTH = v.YETI
	elseif dragonHybrid then
		MAMMOTH = v.HYBRID_DRAGON
	elseif tigerRig then
		if tigerRig:GetAttribute("Awakened") then
			MAMMOTH = v.TIGER_AWAKENED
		else
			MAMMOTH = v.TIGER
		end
	end

	local soundId = (v3 and "rbxassetid://" or "rbxasset://") .. MAMMOTH.ID

	if running.SoundId ~= soundId then
		running.SoundId = soundId
	end

	local v5 = math.min(
		humanoid.WalkSpeed,
		(humanoidRootPart.Velocity * createVector(1, 0, 1)).Magnitude * (humanoid.Jump and 0 or 1)
	)
	local typeName = typeof(p)
	local v6

	if typeName == "number" and p < 1 or typeName == "EnumItem" and p == Enum.HumanoidStateType.Jumping or humanoid.PlatformStand or typeName == "EnumItem" and p == Enum.HumanoidStateType.Physics or gasRig then
		v6 = 0
	else
		local Global = require(game.ReplicatedStorage.Global)

		if Global.Dodging then
			v6 = 0
		else
			local bodyVelocity = humanoidRootPart:FindFirstChild("BodyVelocity")

			if bodyVelocity and bodyVelocity.MaxForce.Magnitude > 10 then
				v6 = 0
			else
				local bodyPosition = humanoidRootPart:FindFirstChild("BodyPosition")
				v6 = bodyPosition and bodyPosition.MaxForce.Magnitude > 10 and 0 or v5
			end
		end
	end

	local heightScale = getHeightScale() -- equivalent call inferred; original call site unknown
	local v7 = 1

	if mammoth then
		heightScale = 3.475
		v7 = 0.0325
	elseif tRex then
		heightScale = 4.5
		v7 = 0.0325
	elseif yetiRig then
		heightScale = 4
		v7 = 0.0325
	elseif dragonHybrid then
		v7 = 0.5
	end

	local v8 = 1 + (heightScale - 1) * 2.5
	local v9 = v6 == 0 and 0 or 1
	local Global = require(game.ReplicatedStorage.Global)
	local v10 = v6 / (Global.Running and 26 or 22)
	running.PlaybackSpeed = math.clamp(MAMMOTH.Speed * v10, 0, 3.7 * heightScale) * v9 / heightScale
	running.EmitterSize = math.clamp(v10 * 6, 3, 6 * heightScale) * v9 * v8
	running.Volume = math.clamp(v10 * 0.15, 0.15, 0.3 * heightScale) * v9 * v8 * v7
end

humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(update)
humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(update)
humanoid.Running:Connect(update)
humanoid.StateChanged:Connect(update)
update()

while task.wait(0.1) and script:IsDescendantOf(workspace) do
	update(v2)
end
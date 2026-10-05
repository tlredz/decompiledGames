local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Players = game:GetService("Players")
game:GetService("UserInputService")
game:GetService("TweenService")
game:GetService("SoundService")
game:GetService("ProximityPromptService")
game:GetService("MarketplaceService")
game:GetService("CollectionService")
game:GetService("AnalyticsService")
game:GetService("HttpService")
local DynamicString = require(ReplicatedStorage.shared.modules.DynamicString)
local statuseffects = require(ReplicatedStorage.shared.modules.library.statuseffects)
local module = require("./StatusEffectsController")
require("./ZoneController")
local packages = ReplicatedStorage:WaitForChild("packages")
local Trove = require(packages.Trove)
local maid = Trove.new()
ReplicatedStorage:WaitForChild("events")
local localPlayer = Players.LocalPlayer
local WalkSpeedController = {}
local v = {
	GlimmerfinSuitBoots = "Terrain",
	JacksTreads = "Terrain",
	Flippers = "Water",
	SuperFlippers = "Water",
	GliderSpeed = "Air",
	SoulwalkerSpeed = "Terrain",
	AmphibianBootsSpeed = "Terrain",
	WinterBoots = "Snow",
	DeveloperBoots = "All",
	ScoriaArmor = "MultiplyFinal",
	ShamrockCoil = "Terrain",
	WaterShoes = "Sand",
	WaterShoes2 = "Water",
	DuneBoots = "Sand",
	TrenchRunningEnhancer = "Water",
	SpeedCoil = "All",
	VelocityCoil = "Terrain",
	GhostElixir = "Terrain",
	IceCream = "Terrain",
	PogoStick2 = "ForceSet",
	PogoStick = "All",
	FreezingWater = "All",
	SnowSlow = "Terrain",
	HoneySlow = "MultiplyFinal",
	FishingWalkSpeed = "ForceSet",
	ReelActive = "ForceSet",
	HarpoonLock = "ForceSet",
	HarpoonMinigameActive = "ForceSet",
	SpearfishingWalkSpeed = "ForceSet",
	NicoTug = "ForceSet",
	RelicConstructHug = "ForceSet",
	PlayingLunarLander = "ForceSet",
	EmotingWalkSpeed = "ForceSet",
	ScyllaBoss = "ForceSet",
	BaitCatching = "ForceSet",
	DJingWalkSpeed = "ForceSet",
	GetSmackedByAFishIdiot = "ForceSet",
	PlayingArcade = "ForceSet",
	ZoneCutscenePlaying = "ForceSet",
	KrakenDeathAnim = "ForceSet",
	LBCutscene1 = "ForceSet",
	TheAttributeThatGetsAddedWhenUsingAPlasticShovelToDigLikeTheGameDigButItsFisch = "ForceSet",
	DevGiftOpen = "ForceSet",
	StarRiddlesMenu = "ForceSet"
}
local v2 = {
	GliderJump = "ForceSet",
	ReelActive = "ForceSet",
	HarpoonLock = "ForceSet",
	HarpoonMinigameActive = "ForceSet",
	PlayingArcade = "ForceSet",
	FishingJumpPower = "MultiplyFinal",
	BoatJump = "ForceSet",
	BaitCatching = "ForceSet",
	GlassBridgeJump = "ForceSet",
	FreezingWaterJump = "All",
	NicoTug = "ForceSet",
	RelicConstructHug = "ForceSet",
	SpearfishingWalkSpeed = "ForceSet",
	AmphibianBootsJump = "MultiplyFinal",
	PogoStickJump = "MultiplyFinal",
	LBCutscene2 = "ForceSet",
	TheAttributeThatGetsAddedWhenUsingAPlasticShovelToDigLikeTheGameDigButItsFisch = "ForceSet",
	DevGiftOpen = "ForceSet",
	StarRiddlesMenu = "ForceSet"
}

function SetupChar(instance)
	maid:Clean()
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart", 10)
	local humanoid = instance:WaitForChild("Humanoid", 10)

	if not (humanoidRootPart and humanoid) then
		return
	end

	local total = 0
	local raycastParams = RaycastParams.new()
	raycastParams.RespectCanCollide = true
	raycastParams.CollisionGroup = "Players"
	raycastParams.ExcludeInstances = { instance }
	raycastParams.IgnoreWater = false

	local function updateSpeed()
		total = 0
		local v3 = 1
		local raycastResult = workspace:Raycast(humanoidRootPart.Position, createVector(0, -5, 0), raycastParams)
		local instance2 = raycastResult and raycastResult.Instance
		local v4, v5

		if instance2 then
			local v6
			v6, v4, v5 = instance2.Color:ToHSV()
		else
			v5 = 0
			v4 = 0
		end

		for attributeName, v6 in pairs(v) do
			local attribute = instance:GetAttribute(attributeName)

			if typeof(attribute) ~= "number" then
				continue
			end

			if v6 == "ForceSet" then
				humanoid.WalkSpeed = attribute
				return
			end

			if not (v6 ~= "Snow" or instance:GetAttribute("SnowSlow") or humanoid.FloorMaterial == Enum.Material.Snow or humanoid.FloorMaterial == Enum.Material.Sand and v5 > 0.8 and v4 < 0.1) then
				continue
			end

			if not (v6 ~= "Sand" or humanoid.FloorMaterial == Enum.Material.Sand and not (v4 < 0.1 or v5 < 0.5)) then
				continue
			end

			if not (v6 ~= "Terrain" or humanoid.FloorMaterial ~= nil and humanoid.FloorMaterial ~= Enum.Material.Water and humanoid:GetState() ~= Enum.HumanoidStateType.Swimming) then
				continue
			end

			if v6 == "Water" then
				if humanoid:GetStateEnabled(Enum.HumanoidStateType.Swimming) then
					if humanoid:GetState() ~= Enum.HumanoidStateType.Swimming then
						continue
					end
				elseif not humanoid:GetAttribute("InFakeWater") then
					local v7 = humanoidRootPart.Position // 4 * 4
					local expandToGrid = Region3.new(v7, v7 + createVector(1, 1, 1)):ExpandToGrid(4)
					local voxels = workspace.Terrain:ReadVoxels(expandToGrid, 4)

					if (voxels[1] and voxels[1][1] and voxels[1][1][1]) ~= Enum.Material.Water then
						continue
					end
				end
			end

			if not (v6 ~= "Air" or humanoid.FloorMaterial == Enum.Material.Air) then
				continue
			end

			if v6 == "MultiplyFinal" then
				v3 *= attribute
			else
				total += attribute
			end
		end

		for _, v6 in module:GetAllStatuses() do
			local statuseffect = statuseffects[v6.Id]

			if not statuseffect then
				continue
			end

			if statuseffect.WalkSpeedAdd then
				total += DynamicString:ResolveObject(statuseffect.WalkSpeedAdd, v6.Data)
			end

			if statuseffect.WalkSpeedMultiply then
				v3 *= DynamicString:ResolveObject(statuseffect.WalkSpeedMultiply, v6.Data)
			end
		end

		if localPlayer.Name == "BossSpax" then
			total += 30
		end

		humanoid.WalkSpeed = math.max((total + 16) * v3, 0)
	end

	local total2 = 0

	local function updateJump()
		total2 = 0
		local v3 = 1

		for attributeName, v4 in pairs(v2) do
			local attribute = instance:GetAttribute(attributeName)

			if typeof(attribute) ~= "number" then
				continue
			end

			if v4 == "ForceSet" then
				humanoid.JumpPower = attribute
				return
			end

			if v4 == "MultiplyFinal" then
				v3 *= attribute
			else
				total2 += attribute
			end
		end

		humanoid.JumpPower = math.max((total2 + 50) * v3, 0)
	end

	for k, _ in pairs(v) do
		maid:Add(instance:GetAttributeChangedSignal(k):Connect(updateSpeed))
	end

	for k, _ in pairs(v2) do
		maid:Add(instance:GetAttributeChangedSignal(k):Connect(updateJump))
	end

	maid:Add(humanoid:GetPropertyChangedSignal("Sit"):Connect(updateSpeed))
	maid:Add(humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(updateSpeed))
	maid:Add(localPlayer:GetAttributeChangedSignal("GliderEquipped"):Connect(updateSpeed))
	maid:Add(instance.ChildAdded:Connect(function(tool)
		if tool:IsA("Tool") then
			task.wait(0.1)
			updateSpeed()
		end
	end))
	maid:Add(instance.ChildRemoved:Connect(function(tool)
		if tool:IsA("Tool") then
			task.wait(0.1)
			task.spawn(updateSpeed)
		end
	end))
	maid:Add(module.StatusAdded:Connect(updateSpeed))
	maid:Add(module.StatusRemoved:Connect(updateSpeed))
	maid:Add(module.StatusChanged:Connect(updateSpeed))
	maid:Add(humanoid.StateChanged:Connect(updateSpeed))
	task.spawn(updateSpeed)
	task.spawn(updateJump)
end

function WalkSpeedController.Start(_)
	local localPlayer2 = Players.LocalPlayer
	localPlayer2.CharacterAdded:Connect(SetupChar)

	if localPlayer2.Character then
		SetupChar(localPlayer2.Character)
	end
end

return WalkSpeedController
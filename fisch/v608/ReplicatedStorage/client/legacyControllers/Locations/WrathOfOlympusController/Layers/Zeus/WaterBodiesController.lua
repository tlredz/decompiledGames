local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)
local color = Color3.fromRGB(255, 240, 100)
local color2 = Color3.fromRGB(255, 255, 255)
local terrain = workspace.Terrain
local waterColor = terrain.WaterColor
local flag = false
local v = false
local v2 = {}

local function updateAnyFullyCharged()
	local v3 = flag
	flag = false

	for _, v4 in v2 do
		if not v4.fullyCharged then
			continue
		end

		flag = true
		break
	end

	if not flag and v3 then
		TweenService:Create(terrain, TweenInfo.new(1, Enum.EasingStyle.Quad), {
			WaterColor = waterColor
		}):Play()
	end
end

local function updateInZeusZone()
	local v3 = v
	v = FischUtils.GetPlayerZone(localPlayer) == "Zeus's Thunder of Chaos"

	if not v and v3 then
		TweenService:Create(terrain, TweenInfo.new(1, Enum.EasingStyle.Quad), {
			WaterColor = waterColor
		}):Play()
	end
end

local function registerPart(instance)
	if v2[instance] then
		return
	end

	v2[instance] = {
		fullyCharged = instance:GetAttribute("FullyCharged") or false
	}

	if v2[instance].fullyCharged then
		flag = true
	end

	instance:GetAttributeChangedSignal("FullyCharged"):Connect(function()
		local v3 = v2[instance]

		if not v3 then
			return
		end

		v3.fullyCharged = instance:GetAttribute("FullyCharged") or false
		updateAnyFullyCharged()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setupCharacter(character)
	local zone = character:WaitForChild("zone")
	updateInZeusZone()
	zone.Changed:Connect(updateInZeusZone)
end

local WaterBodiesController = {}

function WaterBodiesController.OnStrike(_, _)
	if not v then
		return
	end

	terrain.WaterColor = Color3.fromRGB(255, 255, 255)
	task.delay(0.15, function()
		if flag then
			return
		end

		TweenService:Create(terrain, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
			WaterColor = waterColor
		}):Play()
	end)
end

function WaterBodiesController.Start(_)
	for _, v3 in CollectionService:GetTagged("ZeusVisualPart") do
		registerPart(v3)
	end

	CollectionService:GetInstanceAddedSignal("ZeusVisualPart"):Connect(registerPart)
	RunService.RenderStepped:Connect(function()
		if flag and v then
			terrain.WaterColor = color:Lerp(color2, (math.sin(os.clock() * 1.5 * 3.141592653589793) + 1) / 2)
		end
	end)
	localPlayer.CharacterAdded:Connect(setupCharacter)

	if localPlayer.Character then
		setupCharacter(localPlayer.Character) -- equivalent call inferred; original call site unknown
	end
end

return WaterBodiesController
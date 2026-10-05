local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local AreaLocator = require(ReplicatedStorage.CAM.Global.Subsets.Areas.AreaLocator)
local NightIllumination = require(ReplicatedStorage.CAM.Client.Modules.NightIllumination)
local cframe = CFrame.Angles(0, 0, 1.5707963267948966)
local basePart = script:FindFirstChildWhichIsA("BasePart")

if basePart == nil then
	warn("[SnowBiome] no BasePart directly under the script, snow particles are off. Children:", script:GetChildren())
end

local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function stop()
	if v ~= nil then
		RunService:UnbindFromRenderStep("SnowBiomeFollow")
		v:Destroy()
		v = nil
	end
end

local function start()
	if basePart == nil or v ~= nil then
		return
	end

	local clone = basePart:Clone()
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CanTouch = false
	clone.Parent = workspace.Debree
	v = clone
	RunService:BindToRenderStep("SnowBiomeFollow", Enum.RenderPriority.Camera.Value + 1, function()
		clone.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position + createVector(0, 10, 0)) * cframe
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function apply(biome: string?)
	if biome == "Snow" then
		start()
		NightIllumination.SetDensityBonus("Snow", 0.1)
	else
		stop() -- equivalent call inferred; original call site unknown
		NightIllumination.SetDensityBonus("Snow", nil)
	end
end

AreaLocator.AreaEquipped.BiomeUpdate:Connect(apply)
apply(AreaLocator.AreaEquipped.Biome) -- equivalent call inferred; original call site unknown
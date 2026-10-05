game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
require(game.ReplicatedStorage.Util.KnockbackLines)
require(game.ReplicatedStorage.Util.ScaleParticle)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local hybridFlight = FX:WaitForChild("Phoenix1").HybridFlight

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { map }

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cFrame, instance, p, model)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = model or _WorldOrigin
	return clone
end

local v = {
	"RightLowerArm",
	"LeftLowerArm",
	"RightHand",
	"LeftHand",
	"RightUpperArm",
	"LeftUpperArm"
}
return function(player)
	local character = player.Character
	local humanoidRootPart = character.HumanoidRootPart
	local _ = character.Humanoid

	if player.Adding then
		local model = Instance.new("Model")
		model.Name = "__PhoenixHybridModel"
		model.Parent = character
		Util.Sound:Play("Phoenix1Appear", humanoidRootPart)

		for i = 1, 3 do
			local effect = createEffect(
				humanoidRootPart.CFrame,
				hybridFlight["Accessory" .. i],
				"HybridFlight" .. character.Name,
				model
			) -- equivalent call inferred; original call site unknown
			effect.Weld.Part0 = character[effect.Weld:GetAttribute("WeldTo")]
		end

		local effect = createEffect(
			humanoidRootPart.CFrame,
			hybridFlight.Wings,
			"HybridFlight" .. character.Name,
			model
		) -- equivalent call inferred; original call site unknown
		effect.Weld.C1 = CFrame.new(0, 1.5, 0.5)
		effect.Weld.Part1 = character.UpperTorso
		effect.AnimationController:LoadAnimation(effect.Anim):Play(nil, nil, 2)

		for _, childName in pairs(v) do
			local child = character:FindFirstChild(childName)

			if child then
				child.Transparency = 1
			end
		end

		local cFrame2 = humanoidRootPart.CFrame
		local clone = hybridFlight.release:Clone()
		clone.Name = clone.Name
		clone.CFrame = cFrame2
		clone.Parent = _WorldOrigin
		Debris:AddItem(clone, 2)

		for _, child in pairs(clone.Attachment:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end
	else
		local v2 = false

		while true do
			local __PhoenixHybridModel = character:FindFirstChild("__PhoenixHybridModel")

			if not __PhoenixHybridModel then
				break
			end

			__PhoenixHybridModel:Destroy()
			v2 = true
		end

		if not v2 then
			return
		end

		Util.Sound:Play("Phoenix1Disappear", humanoidRootPart)

		for _, childName in pairs(v) do
			local child = character:FindFirstChild(childName)

			if child then
				child.Transparency = 0
			end
		end

		local cFrame = humanoidRootPart.CFrame
		local clone = hybridFlight.release:Clone()
		clone.Name = clone.Name
		clone.CFrame = cFrame
		clone.Parent = _WorldOrigin
		Debris:AddItem(clone, 2)

		for _, child in pairs(clone.Attachment:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end
	end
end
game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
require(game.ReplicatedStorage.Util.ScaleParticle)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Sound = require(game.ReplicatedStorage.Util.Sound)

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { map }
local _ = { TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out) }

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
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
	local humanoid = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart

	for i = 1, 2 do
		local v2 = i == 1 and "Left" or "Right"
		local cFrame = humanoidRootPart.CFrame
		local v3 = script[v2 .. "Part"]
		local v4 = "SmokeFly" .. character.Name
		local effect_2 = createEffect(cFrame, v3, v4)
		effect_2.Weld.Part0 = character[v2 .. "LowerArm"]
	end

	for _, childName in pairs(v) do
		local child = character:FindFirstChild(childName)

		if child then
			child.Transparency = 1
		end
	end

	Sound:Play("SmokeFlightStart", humanoidRootPart)
	local v2 = nil
	task.delay(0.15, function()
		if v2 == false then
			return
		end

		v2 = Sound:Play("SmokeFlightLoop", humanoidRootPart)
	end)

	repeat
		wait()
	until not player.Holding or not player.Holding:IsDescendantOf(workspace) or not character:IsDescendantOf(workspace) or humanoid.Health <= 0 or not player.Holding.Value

	if v2 then
		Sound:FadeOut(v2, 0.5)
	end

	v2 = false

	for _, child in pairs(_WorldOrigin:GetChildren()) do
		if child.Name ~= "SmokeFly" .. character.Name then
			continue
		end

		child.Name = "SmokeFly"
		local weld = child:FindFirstChildOfClass("Weld")

		if weld then
			weld:Destroy()
		end

		child.Anchored = true

		for _, effect in pairs(child:GetChildren()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		Debris:AddItem(child, 1)
	end

	for _, childName in pairs(v) do
		local child = character:FindFirstChild(childName)

		if child then
			child.Transparency = 0
		end
	end
end
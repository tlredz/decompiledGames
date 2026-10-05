local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local ScaleParticle = require(game.ReplicatedStorage.Util.ScaleParticle)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local WrapHighlight = require(game.ReplicatedStorage.Util.WrapHighlight)

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { map }
local v = { TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out) }

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

return function(player)
	local character = player.Character

	if not (character and character:WaitForChild("Humanoid", 1)) then
		return
	end

	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 1)

	if not humanoidRootPart then
		return
	end

	local head = character:WaitForChild("Head", 1)

	if not head or character ~= game.Players.LocalPlayer.Character and (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 300 then
		return
	end

	Sound:Play("RespawnSound", head)
	local color = Color3.new(0.278431, 1, 0.894118)
	local clone = WrapHighlight(script.Highlight):Clone()
	clone.FillColor = color
	clone.Parent = character
	clone.Adornee = character
	local tween = TweenService:Create(clone, v[1], {
		FillTransparency = 1
	})
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween:Play()
	local cFrame = humanoidRootPart.CFrame * CFrame.Angles(-1.57, 1.57, 0)
	local clone2 = script.eff:Clone()
	clone2.Name = clone2.Name
	clone2.CFrame = cFrame
	clone2.Parent = _WorldOrigin
	Debris:AddItem(clone2, 2)

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		ScaleParticle({
			Emitter = emitter,
			Scale = humanoidRootPart.Size.Z,
			Time = 0,
			EasingStyle = Enum.EasingStyle.Linear,
			EasingDirection = Enum.EasingDirection.Out
		})
		emitter.Color = ColorSequence.new(color)
		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end
end
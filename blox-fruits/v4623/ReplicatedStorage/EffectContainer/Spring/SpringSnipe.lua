local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local KnockbackLines = require(game.ReplicatedStorage.Util.KnockbackLines)
local ScaleParticle = require(game.ReplicatedStorage.Util.ScaleParticle)
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { map }
local v = { TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out) }

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

for _, child in pairs(script.eff.Attachment:GetChildren()) do
	local lifetime = child.Lifetime
	child.Lifetime = NumberRange.new(lifetime.Min * 0.8, lifetime.Max * 0.8)
	ScaleParticle({
		Emitter = child,
		Scale = 2,
		Time = 0
	})
end

return function(player)
	local character = player.Character
	local position = player.Position

	if (position - workspace.CurrentCamera.CFrame.p).Magnitude > 600 then
		return
	end

	local rootPart = character.Humanoid.RootPart
	Sound:Play("SpringLeap", rootPart.Position)
	local ray = Ray.new(CFrame.new(rootPart.Position).Position, createVector(0, -10, 0))
	local part, _ = game.Workspace:FindPartOnRayWithWhitelist(ray, { map })
	local cFrame = CFrame.new(rootPart.Position, position) * CFrame.Angles(0, 3.14, 0)
	local clone = script.eff:Clone()
	clone.Name = clone.Name
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	Debris:AddItem(clone, 1)

	for i = 1, player.Nerf and 1 or 2 do
		local cFrame2 = clone.CFrame * CFrame.new(0, 1, 25) * CFrame.Angles(0, 1.57, 1.57) * (i == 1 and CFrame.new(
			0,
			5,
			0
		) or CFrame.new())
		local clone2 = script.Shockwave:Clone()
		clone2.Name = clone2.Name
		clone2.CFrame = cFrame2
		clone2.Parent = _WorldOrigin
		Debris:AddItem(clone2, 0.5)

		if i == 1 then
			TweenService:Create(clone2, v[1], {
				CFrame = clone2.CFrame * CFrame.new(0, -12, 0),
				Size = Vector3.new(clone2.Size.X * 3, 0, clone2.Size.Z * 3),
				Transparency = 1
			}):Play()
		else
			TweenService:Create(clone2, v[1], {
				CFrame = clone2.CFrame * CFrame.new(0, -17, 0),
				Size = Vector3.new(clone2.Size.X * 4, 0, clone2.Size.Z * 4),
				Transparency = 1
			}):Play()
		end
	end

	if not player.Nerf then
		KnockbackLines({
			MAX = 1,
			ITERATION = 5,
			WIDTH = 0.25,
			LENGTH = 5,
			SPEED = 1,
			COLOR1 = Color3.fromRGB(255, 255, 255),
			COLOR2 = Color3.fromRGB(93, 93, 93),
			STARTPOS = clone.CFrame * CFrame.new(0, 0, 20),
			ENDGOAL = CFrame.new(0, 0, -20)
		})
	end

	for _, child in pairs(clone.Attachment:GetChildren()) do
		if child.Name == "sm2" or child.Name == "rocks" then
			if part then
				child.Color = ColorSequence.new(part.Color)
				child:Emit((math.ceil(child:GetAttribute("EmitCount") * (player.Nerf and 0.2 or 1))))
			end
		else
			child:Emit((math.ceil(child:GetAttribute("EmitCount") * (player.Nerf and 0.4 or 1))))
		end
	end
end
local createVector = vector.create
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local scaleParticle = Util.ScaleParticle
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local map = workspace:WaitForChild("Map")
local particle = Util.ParticleScaler.Particle

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Parent = p2 or _WorldOrigin
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	return clone
end

return function(list)
	local parent = list[1]
	local v2 = list[2] or 0.25
	local humanoid = parent:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	local rootPart = humanoid.RootPart or parent.PrimaryPart
	local clone = script.DashTrail:Clone()
	clone.Parent = parent
	clone.Attachment0 = rootPart.RootRigAttachment
	clone.Attachment1 = parent.UpperTorso.NeckAttachment
	task.delay(v2, function()
		clone.Enabled = false
		Util.Debris:AddItem(clone, 0.5)
	end)
	local v3 = rootPart.Size.Magnitude / 3
	local v4 = rootPart.Size.Y * 0.5 + humanoid.HipHeight + 0.5
	local rayCastWhitelist, _ = Util.RayCastWhitelist(
		rootPart.Position + createVector(0, 1, 0) * rootPart.Size.Y,
		Vector3.new(0, -(v4 + rootPart.Size.Y), 0),
		{ map }
	)

	if rayCastWhitelist then
		local cFrame = rootPart.CFrame
		local clone2 = script.Dust:Clone()
		clone2.Parent = _WorldOrigin
		clone2.Name = clone2.Name
		clone2.CFrame = cFrame
		clone2.Anchored = false
		clone2.Weld.Part0 = rootPart
		clone2.Weld.C0 = CFrame.new(0, -v4 * 0.75, 0)
		clone2.Attachment.sm2.Color = ColorSequence.new(rayCastWhitelist.Color)
		particle(clone2.Attachment.sm2, v3)
		task.delay(v2, function()
			clone2.Attachment.sm2.Enabled = false
			Util.Debris:AddItem(clone2, clone2.Attachment.sm2.Lifetime.Max + 0.7)
		end)
	end

	local cFrame2 = rootPart.CFrame * CFrame.Angles(0, 3.14, 0)
	local clone2 = script.eff:Clone()
	clone2.Parent = _WorldOrigin
	clone2.Name = clone2.Name
	clone2.CFrame = cFrame2
	local v6 = 0

	for _, child in pairs(clone2.Attachment:GetChildren()) do
		v6 = math.max(v6, child.Lifetime.Max)

		if child.Name:find("Smoke") and rayCastWhitelist then
			child.Color = ColorSequence.new(rayCastWhitelist.Color)
		end

		scaleParticle({
			Emitter = child,
			Scale = 1.5 * v3,
			Time = 0.05,
			EasingStyle = Enum.EasingStyle.Sine,
			EasingDirection = Enum.EasingDirection.Out
		})
		child:Emit(child:GetAttribute("EmitCount"))
	end

	Util.Debris:AddItem(clone2, v6 + 0.5 + v2)
	local color = rootPart.Parent.Head.Color
	local color2 = rootPart.Parent.UpperTorso.Color

	if (Vector3.new(color.r, color.g, color.b) - Vector3.new(color2.r, color2.g, color2.b)).Magnitude < 0.1 then
		color = Color3.new()
	end

	for i = 1, 2 do
		local clone3 = script["Lines" .. i]:Clone()

		if i == 1 then
			clone3.Color = ColorSequence.new(color)
		else
			clone3.Color = ColorSequence.new(color2)
		end

		particle(clone3, v3)
		clone3.Parent = rootPart
		clone3:Emit(2)
		Util.Debris:AddItem(clone3, clone3.Lifetime.Max + 1.25)
	end
end
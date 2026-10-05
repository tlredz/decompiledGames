local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
require(game.ReplicatedStorage.Util.MeshRockModule)
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
local v = {
	TweenInfo.new(1.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
}

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

return function(player)
	local hit = player.Hit
	local position = player.Position
	local normal = player.Normal
	local scale = player.Scale
	local character = player.Character
	local _ = character.Humanoid
	local _ = character.HumanoidRootPart

	if player.Spawn then
		if not player.Part then
			return
		end

		Sound:Play("Click", player.Part.Position)
		local part = Instance.new("Part")
		part.CanTouch = false
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1
		part.Material = "Neon"
		part.Color = Color3.new(1, 0.33, 0)
		part.Shape = "Cylinder"
		part.Size = Vector3.new(0.25, player.Part.Size.X * 1.75, player.Part.Size.X * 1.75)
		part.CFrame = player.Part.CFrame * CFrame.Angles(0, 0, 1.5707963267948966)
		part.Parent = workspace._WorldOrigin
		TweenService:Create(part, TweenInfo.new(0.33, Enum.EasingStyle.Quad), {
			Transparency = 0.75,
			Size = Vector3.new(0.25, player.Part.Size.X, player.Part.Size.X)
		}):Play()

		while player.Part and player.Part:IsDescendantOf(workspace) do
			wait(0.1)
		end

		part:Destroy()
	else
		if (position - workspace.CurrentCamera.CFrame.p).Magnitude > 600 then
			return
		end

		Sound:Play("BombShot", position)
		local cFrame = CFrame.new(position) * CFrame.new(0, 0.5, 0)
		local clone = script.eff:Clone()
		clone.Name = clone.Name
		clone.CFrame = cFrame
		clone.Parent = _WorldOrigin
		Debris:AddItem(clone, 1.25)

		for _, child in pairs(clone.Attachment:GetChildren()) do
			local speed = child.Speed
			child.Speed = NumberRange.new(speed.Min * scale, speed.Max * scale)

			if child.Name == "fire" then
				ScaleParticle({
					Emitter = child,
					Scale = scale * 1.25,
					Time = 0.05,
					EasingStyle = Enum.EasingStyle.Linear,
					EasingDirection = Enum.EasingDirection.Out
				})
			else
				ScaleParticle({
					Emitter = child,
					Scale = scale,
					Time = 0.05,
					EasingStyle = Enum.EasingStyle.Linear,
					EasingDirection = Enum.EasingDirection.Out
				})
			end

			if child.Name == "sm2" then
				if hit then
					child.Color = ColorSequence.new(hit.Color)
					child:Emit(child:GetAttribute("EmitCount"))
				end
			else
				child:Emit((math.ceil(child:GetAttribute("EmitCount") * 0.25)))
			end
		end

		if hit then
			local v3 = CFrame.new(position, position + normal * 10) * CFrame.Angles(-1.5707963267948966, 0, 0)
			local cFrame2 = v3 * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0)
			local clone2 = script.Scar:Clone()
			clone2.Name = clone2.Name
			clone2.CFrame = cFrame2
			clone2.Parent = _WorldOrigin
			clone2.Size *= scale

			for _, child in pairs(clone2:GetChildren()) do
				TweenService:Create(child, v[1], {
					Transparency = 1
				}):Play()
			end

			Debris:AddItem(clone2, 1.25)
			local cFrame3 = v3 * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0)
			local clone3 = script.Shockwave:Clone()
			clone3.Name = clone3.Name
			clone3.CFrame = cFrame3
			clone3.Parent = _WorldOrigin
			clone3.Size *= scale
			Debris:AddItem(clone3, 0.5)
			TweenService:Create(clone3, v[2], {
				CFrame = clone3.CFrame * CFrame.new(0, 10 * scale, 0),
				Size = Vector3.new(clone3.Size.X * 3, 0, clone3.Size.Z * 3),
				Transparency = 1
			}):Play()
		end
	end
end
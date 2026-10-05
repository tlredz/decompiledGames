local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
require(game.ReplicatedStorage.Util.MeshRockModule)
require(game.ReplicatedStorage.Util.ScaleParticle)
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
	local character = player.Character
	local _ = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart

	if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 600 then
		return
	end

	Sound:Play("BombLeap", humanoidRootPart)
	local ray = Ray.new(humanoidRootPart.Position, createVector(0, -10, 0))
	local part, _, v2 = game.Workspace:FindPartOnRayWithWhitelist(ray, { map })

	for i = 1, 2 do
		local v3 = i == 1 and -1 or 1
		local cFrame = humanoidRootPart.CFrame * CFrame.new(10 * v3, -1, 0)
		local clone = script.eff:Clone()
		clone.Name = clone.Name
		clone.CFrame = cFrame
		clone.Parent = _WorldOrigin
		Debris:AddItem(clone, 1.25)

		for _, child in pairs(clone.Attachment:GetChildren()) do
			if child.Name == "sm2" then
				if part then
					child.Color = ColorSequence.new(part.Color)
					child:Emit(child:GetAttribute("EmitCount"))
				end
			else
				child:Emit(child:GetAttribute("EmitCount"))
			end
		end

		if not part then
			continue
		end

		local cFrame2 = CFrame.new(clone.Position, clone.Position + v2 * 10) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
			0,
			math.random(-10, 10) / 10 * 3.141592653589793,
			0
		)
		local clone2 = script.Scar:Clone()
		clone2.Name = clone2.Name
		clone2.CFrame = cFrame2
		clone2.Parent = _WorldOrigin

		for _, child in pairs(clone2:GetChildren()) do
			TweenService:Create(child, v[1], {
				Transparency = 1
			}):Play()
		end

		Debris:AddItem(clone2, 1.25)
	end
end
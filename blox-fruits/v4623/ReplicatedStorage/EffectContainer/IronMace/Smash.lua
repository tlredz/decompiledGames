local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local Util = require(game.ReplicatedStorage.Util)
local _WorldOrigin = workspace._WorldOrigin
local _ = workspace.Map
local debris = Util.Debris

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies }
local v = {
	TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true),
	TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
}

local function createEffect(cFrame, model, p, p2)
	local clone = model:Clone()
	clone.Name = p or clone.Name

	if model:IsA("Model") then
		clone.Parent = p2 or _WorldOrigin
		clone.PrimaryPart.CFrame = cFrame
	else
		clone.CFrame = cFrame
		clone.Parent = p2 or _WorldOrigin
	end

	return clone
end

return function(player)
	local cFrame = player.CFrame

	if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).magnitude > 600 then
		return
	end

	if player.Character == game.Players.LocalPlayer.Character then
		Util.CameraShaker:ShakeOnce(10, 8, 0.1, 1, createVector(1, 1, 1), createVector(1, 1, 5))
	end

	local cFrame2 = cFrame * CFrame.new(0, -2, -6)
	local slam = script.Slam
	local clone = slam:Clone()
	clone.Name = clone.Name

	if slam:IsA("Model") then
		clone.Parent = _WorldOrigin
		clone.PrimaryPart.CFrame = cFrame2
	else
		clone.CFrame = cFrame2
		clone.Parent = _WorldOrigin
	end

	debris:AddItem(clone, 1)

	for _, child in pairs(clone.Attachment:GetChildren()) do
		if child.Name == "Blunt" then
			local lifetime = child.Lifetime
			child.Lifetime = NumberRange.new(lifetime.Min * 1.1, lifetime.Max * 1.1)
		else
			local lifetime = child.Lifetime
			child.Lifetime = NumberRange.new(lifetime.Min * 0.85, lifetime.Max * 0.85)
			local speed = child.Speed
			child.Speed = NumberRange.new(speed.Min * 1.33333333, speed.Max * 1.33333333)
		end

		child:Emit(child:GetAttribute("EmitCount"))
	end

	Util.Sound:Play("IronMaceZ", cFrame)
	task.wait(0.075)
	Util.PathDebris({
		CF = cFrame * CFrame.new(0, 0, -4),
		Length = 27,
		Width = 3,
		Size = 2,
		LengthSpace = 2,
		WidthProgress = 10,
		Progressive = 3,
		Lifetime = 0.2
	})
	local cFrame3 = cFrame * CFrame.new(0, 0, -30)
	local smash = script.Smash
	local clone2 = smash:Clone()
	clone2.Name = clone2.Name

	if smash:IsA("Model") then
		clone2.Parent = _WorldOrigin
		clone2.PrimaryPart.CFrame = cFrame3
	else
		clone2.CFrame = cFrame3
		clone2.Parent = _WorldOrigin
	end

	debris:AddItem(clone2, 2)
	local raycastResult = workspace:Raycast(
		cFrame * CFrame.new(0, 0, -30).Position,
		createVector(0, -5, 0),
		raycastParams
	)

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local lifetime = emitter.Lifetime
		emitter.Lifetime = NumberRange.new(lifetime.Min * 1.5, lifetime.Max * 1.5)

		if emitter.Name == "Dust" and raycastResult then
			emitter.Color = ColorSequence.new(raycastResult.Instance.Color)
			local lifetime2 = emitter.Lifetime
			emitter.Lifetime = NumberRange.new(lifetime2.Min * 0.8, lifetime2.Max * 0.8)
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		elseif emitter.Name ~= "Dust" and (emitter.Name ~= "Rocks" or raycastResult) then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	if raycastResult then
		local cFrame4 = cFrame * CFrame.new(0, -2, -40.5) * CFrame.Angles(0, 3.14, 0)
		local groundSlash = script.GroundSlash
		local clone3 = groundSlash:Clone()
		clone3.Name = clone3.Name

		if groundSlash:IsA("Model") then
			clone3.Parent = _WorldOrigin
			clone3.PrimaryPart.CFrame = cFrame4
		else
			clone3.CFrame = cFrame4
			clone3.Parent = _WorldOrigin
		end

		debris:AddItem(clone3, 3)
		TweenService:Create(clone3.tex, v[2], {
			Transparency = 1
		}):Play()
	end
end
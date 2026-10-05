local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local RocksModule = require(game.ReplicatedStorage.Util.RocksModule)
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
local v = { TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out) }

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

return function(player)
	local character = player.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart
	local position = humanoidRootPart.Position

	if (position - workspace.CurrentCamera.CFrame.p).Magnitude > 400 then
		return
	end

	Sound:Play("SpringCannon1", position)
	task.wait(0.35)
	Sound:Play("SpringCannon2", position)
	local ray = Ray.new(humanoidRootPart.Position, createVector(0, -20, 0))
	local part, v3 = workspace:FindPartOnRayWithWhitelist(ray, { map })
	local cFrame = humanoidRootPart.CFrame

	if player.GroundSnap then
		if part and v3 then
			cFrame = CFrame.new(v3) * humanoidRootPart.CFrame.Rotation
		else
			local hipHeight = humanoid and humanoid.HipHeight or 0
			local v4 = humanoidRootPart.Size.Y * 0.5
			cFrame = humanoidRootPart.CFrame - Vector3.new(0, hipHeight + v4, 0)
		end
	end

	local offset = tonumber(player.Offset) or 0

	if offset ~= 0 then
		cFrame -= Vector3.new(0, offset, 0)
	end

	local clone = script.eff:Clone()
	clone.Name = clone.Name
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	Debris:AddItem(clone, 1.25)

	for _, child in pairs(clone.Attachment:GetChildren()) do
		if child.Name == "groundeffs" then
			if part then
				child.Color = ColorSequence.new(part.Color)
				child:Emit(child:GetAttribute("EmitCount"))
			end
		else
			child:Emit(child:GetAttribute("EmitCount"))
		end
	end

	for i = 1, 2 do
		local cFrame2 = clone.CFrame
		local clone2 = script.Shockwave:Clone()
		clone2.Name = clone2.Name
		clone2.CFrame = cFrame2
		clone2.Parent = _WorldOrigin
		Debris:AddItem(clone2, 0.5)

		if i == 1 then
			TweenService:Create(clone2, v[1], {
				CFrame = clone2.CFrame * CFrame.new(0, 8, 0),
				Size = Vector3.new(clone2.Size.X * 4, 0, clone2.Size.Z * 4),
				Transparency = 1
			}):Play()
		else
			clone2.CFrame *= CFrame.new(0, 8, 0)
			clone2.Size = Vector3.new(clone2.Size.X * 3, clone2.Size.Y / 2, clone2.Size.Z * 3)
			TweenService:Create(clone2, v[1], {
				CFrame = clone2.CFrame * CFrame.new(0, 8, 0),
				Size = Vector3.new(clone2.Size.X * 0.5, 0, clone2.Size.Z * 0.5),
				Transparency = 1
			}):Play()
		end
	end

	RocksModule.Ground(humanoidRootPart.Position, 25, createVector(3.5, 6, 3.5), { map }, 10, false, 1, true)
end
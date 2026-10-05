local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ScaleParticle = require(game.ReplicatedStorage.Util.ScaleParticle)
local _ = coroutine.resume
local _ = coroutine.create
local MeshRockModule = require(game.ReplicatedStorage.Util.MeshRockModule)
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local map = workspace:WaitForChild("Map")
local Effect = require(game.ReplicatedStorage.Effect)
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local darkRocks = FX:WaitForChild("Dark").DarkRocks
local debris = Util.Debris
local sound = Util.Sound

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local v = {
	TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
}
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { map }

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Parent = p2 or _WorldOrigin
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	return clone
end

return function(data)
	local effectId = data.EffectId
	local timestamp = data.Timestamp
	local target = data.Target
	local position = data.Position
	local speed = data.Speed or 100
	local scale = data.Scale or 1
	local riseDuration = data.RiseDuration or data.FadeIn or 1
	local stage = data.Stage or 1

	if stage == 1 then
		if (workspace.CurrentCamera.CFrame.Position - position).magnitude > 1000 then
			return
		end

		if (workspace.CurrentCamera.CFrame.Position - position).magnitude < 300 then
			local v2 = (workspace.CurrentCamera.CFrame.Position - position).magnitude / 300
			Effect.new("ShakeCam"):replicate({
				Preset = "Bump4",
				Power = 1 - v2
			})
		end

		local v2 = riseDuration - (Util.MasterClock:GetTime() - timestamp)
		local ray = Ray.new(position, createVector(0, -20, 0))
		local part, v3, v4 = game.Workspace:FindPartOnRayWithWhitelist(ray, { map })
		local clone = darkRocks.Rock:Clone()
		clone.Name = effectId
		clone.CFrame = CFrame.new(position, target)

		if part ~= nil then
			clone.CFrame = CFrame.new(v3, target) - v4 * scale
			clone.Color = part.Color
			clone.Material = part.Material
			local clone2 = darkRocks.groundSpawn:Clone()
			clone2.CFrame = CFrame.new(v3) + v4
			clone2.Parent = _WorldOrigin

			for _, child in pairs(clone2.Ground:GetChildren()) do
				if child.Name ~= "Wind" then
					child.Color = ColorSequence.new(part.Color)
				end

				if child:GetAttribute("EmitCount") then
					child:Emit(child:GetAttribute("EmitCount"))
				else
					child:Emit(3)
				end
			end

			debris:AddItem(clone2, 1)
		end

		clone.Parent = _WorldOrigin
		sound:Play("DarkRocksSpawn", clone, nil, 1)
		debris:AddItem(clone, 3)

		if part == nil then
			TweenService:Create(clone, TweenInfo.new(v2, v[1].EasingStyle, v[1].EasingDirection), {
				Size = createVector(1.20325, 1.20325, 1.20325) * scale
			}):Play()
		else
			TweenService:Create(clone, TweenInfo.new(v2, v[1].EasingStyle, v[1].EasingDirection), {
				Size = createVector(1.20325, 1.20325, 1.20325) * scale,
				Position = position
			}):Play()
			MeshRockModule({
				Cframe = clone.CFrame,
				Amount = 7,
				Iteration = 5,
				Max = 1.5,
				FirstDuration = 0.1,
				RocksLength = 0.405
			})
		end

		task.wait(v2)
		local v5 = position
		local unit = (target - position).Unit
		local vector2 = Vector3.new()
		Util.DistributedLoop:add(function(p, p2)
			if not (clone and clone:IsDescendantOf(workspace) and clone.Transparency < 0.99 and p < 10) then
				return true
			end

			v5 += unit * speed * p2
			vector2 += createVector(0.05, 0.05, 0.05)
			clone.CFrame = (CFrame.new(Vector3.new(), unit) + v5) * CFrame.Angles(vector2.X, vector2.Y, vector2.Z)
		end)
	elseif stage == 2 then
		local child = _WorldOrigin:FindFirstChild(effectId)

		if not child then
			return
		end

		child.Transparency = 1
		child.Anchored = true

		for _, child2 in pairs(child.Aura:GetChildren()) do
			child2.Enabled = false
		end

		local cFrame = child.CFrame * CFrame.Angles(
			math.rad((math.random(0, 180))),
			math.rad((math.random(0, 180))),
			(math.rad((math.random(0, 180))))
		)
		local clone = darkRocks.Color1:Clone()
		clone.Parent = _WorldOrigin
		clone.Name = clone.Name
		clone.CFrame = cFrame
		TweenService:Create(clone, v[2], {
			Size = Vector3.new(child.Size.X * 8, child.Size.Y / 2, child.Size.Z * 8),
			Transparency = 1
		}):Play()
		debris:AddItem(clone, 1)
		local ray = Ray.new(position, child.CFrame.LookVector * (speed * 1 / 30 + scale * 2))
		local part, v3, v4 = game.Workspace:FindPartOnRayWithWhitelist(ray, { map })

		if not part then
			local ray2 = Ray.new(position, (Vector3.new(0, -(10 + scale * 2), 0)))
			part, v3, v4 = game.Workspace:FindPartOnRayWithWhitelist(ray2, { map })
		end

		if (workspace.CurrentCamera.CFrame.Position - position).magnitude < 300 then
			local v5 = (workspace.CurrentCamera.CFrame.Position - position).magnitude / 300
			Effect.new("ShakeCam"):replicate({
				Preset = "Bump4",
				Power = 1 - v5
			})
		end

		local cframe = CFrame.new(part and v3 or child.Position)
		local clone2 = darkRocks.Explosion:Clone()
		clone2.Parent = _WorldOrigin
		clone2.Name = clone2.Name
		clone2.CFrame = cframe

		for _, child2 in pairs(clone2.Attachment:GetChildren()) do
			if not child2:GetAttribute("EmitCount") then
				continue
			end

			if child2.Name == "D" or child2.Name == "Dust" then
				local speed2 = child2.Speed
				child2.Speed = NumberRange.new(speed2.Min * 2, speed2.Max * 2)
			end

			ScaleParticle({
				Emitter = child2,
				Scale = scale / 2,
				Time = 0.05,
				EasingStyle = Enum.EasingStyle.Linear,
				EasingDirection = Enum.EasingDirection.Out
			})
			child2:Emit(child2:GetAttribute("EmitCount"))
		end

		sound:Play("DarkRockExplosion", clone2, nil, 1)
		debris:AddItem(clone2, 2)

		if part then
			local clone3 = darkRocks.Scar:Clone()
			clone3.Size *= scale / 3.2
			clone3.CFrame = Util.Misc.AlignCFrame(CFrame.new(v3), v4) * CFrame.Angles(
				0,
				math.random(-10, 10) / 10 * 3.141592653589793,
				0
			) + v4 * 0.1
			clone3.Parent = _WorldOrigin
			TweenService:Create(clone3.Decal, v[3], {
				Transparency = 1
			}):Play()
			debris:AddItem(clone3, 1.25)
		end
	end
end
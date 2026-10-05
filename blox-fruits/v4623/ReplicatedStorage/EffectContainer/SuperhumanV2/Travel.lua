local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local fn

fn = function(data)
	local lastTime = tick()
	local anchor = data.Anchor or data.Root
	local duration = data.Duration or 1
	local scale = data.Scale
	local ignoreTrail = data.IgnoreTrail
	local attachment = Instance.new("Attachment")
	attachment.CFrame = anchor.CFrame
	attachment.Parent = workspace.Terrain
	local effects = {
		ForceFlyingRocks = data.ForceFlyingRocks or false,
		ForceRockSpawn = data.ForceRockSpawn or false,
		NoFlyingRocks = data.NoFlyingRocks or false,
		Burnt = data.Burnt or false,
		Rocks = true,
		Particles = {
			Rocks = true,
			Dust = true,
			Misc = true
		},
		FireMark = not ignoreTrail,
		FadeInMod = data.FadeInMod or 1
	}

	if data.IgnoreParticles then
		effects.Particles.Misc = false
		effects.Particles.Dust = false
		effects.IgnoreParticles = true
	end

	if data.Fast then
		effects.Fast = true
	end

	Effect.new("Dough.Misc.Debris.Trail"):replicate({
		Root = attachment,
		Color = data.Color or Color3.fromRGB(83, 143, 255),
		Scale = scale,
		Duration = duration,
		Effects = effects,
		isBlue = data.isBlue
	})
	local flag = false
	local cFrame = anchor.CFrame
	local rayBuff = data.RayBuff or 0
	Util.DistributedLoop:add(function(p, _)
		local v2 = math.min(1, p / duration)
		local rayCastWhitelist, v3, v4 = Util.RayCastWhitelist(
			anchor.Position + Vector3.new(0, scale, 0),
			Vector3.new(0, -(10 + scale + rayBuff), 0),
			{ workspace:FindFirstChild("Map") }
		)

		if rayCastWhitelist then
			local v5 = cFrame
			cFrame = Util.Misc.AlignCFrame(CFrame.new(Vector3.new(), (v3 - cFrame.p).Unit) + v3, v4)
			local dot = (cFrame.p - v5.p):Dot(v5.LookVector)

			if dot == dot and not (dot >= 0 or p < duration / 2) then
				attachment:Destroy()
				return true
			else
				attachment.CFrame = cFrame
				flag = true
			end
		else
			if data.StopWithoutSurface then
				flag = true
			end

			if flag then
				attachment:Destroy()

				if v2 < 1 and duration - (tick() - lastTime) > 0.03333333333333333 then
					task.defer(function()
						local v5 = data
						v5.Duration = duration - (tick() - lastTime)

						if v5.Duration > 0.03333333333333333 then
							fn(v5)
						end
					end)
				end

				return true
			end
		end

		if v2 ~= 1 and anchor and anchor:IsDescendantOf(workspace) then
			return
		end

		attachment:Destroy()
		return true
	end)
end

return fn
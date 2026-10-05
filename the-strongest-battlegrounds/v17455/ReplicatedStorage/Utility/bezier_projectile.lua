local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function spawnSingleProjectile(position, p, instance, callback, p2, p3, p4)
	local clone = instance:Clone()
	clone.CFrame = CFrame.new(position)
	clone.Parent = workspace.Thrown
	local lastTime = tick()
	local heartbeatConnection = nil
	local RunService = game:GetService("RunService")
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local v = (tick() - lastTime) / p2

		if v >= 1 then
			clone:Destroy()

			if callback then
				callback(p, nil)
			end

			heartbeatConnection:Disconnect()
		else
			local v2 = position
			local v3 = position + Vector3.new(0, p3, 0)
			local v4 = p + Vector3.new(0, p3, 0)
			local v6 = v2 + (v3 - v2) * v
			local v7 = v3 + (v4 - v3) * v
			local v8 = v4 + (p - v4) * v
			local v9 = v6 + (v7 - v6) * v
			local position2 = v9 + (v7 + (v8 - v7) * v - v9) * v
			clone.Position = position2

			if p4 then
				clone.CFrame = CFrame.new(position2) * CFrame.Angles(0, v * 6.283185307179586, 0)
			end
		end
	end)
	task.delay(20, function()
		if heartbeatConnection then
			heartbeatConnection:Disconnect()
		end

		if clone and clone.Parent then
			clone:Destroy()
		end
	end)
end

return {
	SpawnProjectiles = function(data)
		local root = data.root
		local projectile = data.projectile
		local onHit = data.onHit or function() end
		local count = data.count or 1
		local spreadRadius = data.spreadRadius or 5
		local startHeight = data.startHeight or 5
		local duration = data.duration or 1
		local arcHeight = data.arcHeight or 10
		local evenlySpaced = data.evenlySpaced or false
		local rotate = data.rotate or false
		local spawnDelay = data.spawnDelay or 0
		local lifetime = data.lifetime or 1
		local v = root.Position + Vector3.new(0, startHeight, 0)

		for i = 1, count do
			local vector

			if evenlySpaced then
				local v2 = i / count * 3.141592653589793 * 2
				vector = Vector3.new(math.cos(v2) * spreadRadius, 0, math.sin(v2) * spreadRadius)
			else
				vector = Vector3.new(
					math.random(-spreadRadius, spreadRadius),
					0,
					math.random(-spreadRadius, spreadRadius)
				)
			end

			local v2 = root.Position + vector
			local v3 = math.random() * spawnDelay
			task.delay(v3, function()
				local clone = projectile:Clone()
				clone.CFrame = CFrame.new(v)
				clone.Parent = workspace.Thrown
				local v5 = (v + v2) / 2 + Vector3.new(0, arcHeight, 0)
				local v6 = duration / 30
				local total = 0

				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function bezierPoint(p, p2, p3, p4)
					return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
				end

				local heartbeatConnection = nil
				task.delay(20, function()
					if heartbeatConnection then
						heartbeatConnection:Disconnect()
					end

					if clone and clone.Parent then
						clone:Destroy()
					end
				end)
				local RunService = game:GetService("RunService")
				heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
					total += dt / v6

					if total >= 30 then
						heartbeatConnection:Disconnect()

						if clone and clone.Parent then
							for i2, emitter in ipairs(clone:GetChildren()) do
								if emitter:IsA("ParticleEmitter") then
									emitter:Emit(emitter:GetAttribute("EmitCount") or 30)
								end
							end

							onHit(clone.Position, clone)
							task.delay(lifetime, function()
								if clone and clone.Parent then
									clone:Destroy()
								end
							end)
						end
					else
						local v11 = bezierPoint(total / 30, v, v5, v2)
						clone.CFrame = CFrame.new(v11)

						if rotate then
							local unit = (v2 - v11).Unit
							clone.CFrame = CFrame.new(v11, v11 + unit)
						end
					end
				end)
			end)
		end
	end
}
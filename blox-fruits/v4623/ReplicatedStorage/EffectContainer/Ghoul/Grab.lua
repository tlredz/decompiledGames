local createVector = vector.create
local RunService = game:GetService("RunService")
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local ghoulLifeSteal = FX:WaitForChild("Ghoul").Grab.GhoulLifeSteal

local function GetNumberDependingDistance(p, p2, p3, p4, p5)
	if p <= p4 then
		return p2
	end

	if p4 < p and p <= p5 then
		return p2 + (p3 - p2) * ((p - p4) / (p5 - p4))
	end

	return p3
end

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cubicBezier(p, p2, p3, p4, p5)
	local v = p2 + (p3 - p2) * p
	local v2 = p3 + (p4 - p3) * p
	local v3 = p4 + (p5 - p4) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function B(value, position, p, p2, position2)
	return (1 - value) ^ 3 * position + 3 * (1 - value) ^ 2 * value * p + 3 * (1 - value) * value ^ 2 * p2 + value ^ 3 * position2
end

local function CrowsTrail(items, p, p2, _, p3)
	coroutine.wrap(function()
		for _, item in pairs(items) do
			local v = item
			coroutine.wrap(function()
				if p3 == "Grab" then
					task.wait(5e-13)
				else
					task.wait(0.005)
				end

				local folder = v

				if p3 == "First" then
					folder.Position = p + Vector3.new(
						math.random(-10, 10) / 3,
						math.random(-10, 10) / 3,
						math.random(-10, 10) / 3
					)
				end

				for i, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				local position = folder.Position
				local v2 = p2 + Vector3.new(
					math.random(-10, 10) / 3,
					math.random(-10, 10) / 3,
					math.random(-10, 10) / 3
				)
				local magnitude = (position - v2).Magnitude
				folder.CFrame = CFrame.new(position, v2)
				local v3 = (position - v2) / 2
				local position2 = CFrame.new(CFrame.new(position) * (v3 / -1.5)).Position
				local position3 = CFrame.new(CFrame.new(v2) * (v3 / 1.5)).Position
				local v4 = magnitude / 1.9
				local v5 = position2 + Vector3.new(math.random(-v4, v4), math.random(-v4, v4), math.random(-v4, v4))
				local v6 = position3 + Vector3.new(math.random(-v4, v4), math.random(-v4, v4), math.random(-v4, v4))
				local v7 = 4 * math.random(10, 20) / 10

				if p3 == "Grab" then
					v7 = 6 * math.random(10, 15) / 3
				elseif p3 == "Final" then
					v7 = math.random(10, 15) / 7
				end

				local v8 = math.random(99999999)
				folder:SetAttribute("id", v8)
				local lastTime = tick()
				local v9 = magnitude / v7 / 60

				while tick() - lastTime < v9 and folder:GetAttribute("id") == v8 do
					local v10 = (tick() - lastTime) / v9
					local v11 = cubicBezier(v10, position, v5, v6, v2)
					folder.CFrame = folder.CFrame:Lerp(CFrame.new(v11, v2), v10)
					RunService.Heartbeat:Wait()
				end

				if folder:GetAttribute("id") ~= v8 then
					return
				end

				if p3 == "Final" then
					local position4 = folder.Position
					local v10 = position4 + Vector3.new(
						math.random(-20, 20) * 2,
						math.random(5, 25) * 2,
						math.random(-20, 20) * 2
					)
					local magnitude2 = (position4 - v10).Magnitude
					folder.CFrame = CFrame.new(position4, v10)
					local v11 = (position4 - v10) / 2
					local position5 = CFrame.new(CFrame.new(position4) * (v11 / -1.5)).Position
					local position6 = CFrame.new(CFrame.new(v10) * (v11 / 1.5)).Position
					local halfMagnitude2 = magnitude2 / 2
					local v13 = position5 + Vector3.new(
						math.random(-halfMagnitude2, halfMagnitude2),
						math.random(-halfMagnitude2, halfMagnitude2),
						math.random(-halfMagnitude2, halfMagnitude2)
					)
					local v14 = position6 + Vector3.new(
						math.random(-halfMagnitude2, halfMagnitude2),
						math.random(-halfMagnitude2, halfMagnitude2),
						math.random(-halfMagnitude2, halfMagnitude2)
					)
					coroutine.wrap(function()
						for i = 1, 5 do
							for i2, emitter in pairs(folder:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("Kaw") then
									emitter.Size = NumberSequence.new(i / 2)
								end
							end

							task.wait(0.05)
						end
					end)()
					local v15 = math.random(99999999)
					folder:SetAttribute("id", v15)
					local lastTime2 = tick()
					local v16 = magnitude2 / v7 / 60

					while tick() - lastTime2 < v16 and folder:GetAttribute("id") == v15 do
						local v17 = (tick() - lastTime2) / v16
						local v18 = cubicBezier(v17, position4, v13, v14, v10)
						folder.CFrame = folder.CFrame:Lerp(CFrame.new(v18, v10), v17)
						RunService.Heartbeat:Wait()
					end

					if folder:GetAttribute("id") ~= v15 then
						return
					end

					for i, effect in pairs(folder:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end
				elseif p3 == "Grab" then
					local v10 = p
					local position4 = folder.Position
					local magnitude2 = (position4 - v10).Magnitude
					folder.CFrame = CFrame.new(position4, v10)
					local v11 = (position4 - v10) / 2
					local position5 = CFrame.new(CFrame.new(position4) * (v11 / -1.5)).Position
					local position6 = CFrame.new(CFrame.new(v10) * (v11 / 1.5)).Position
					local v12 = magnitude2 / 3
					local v13 = position5 + Vector3.new(
						math.random(-v12, v12),
						math.random(-v12, v12),
						math.random(-v12, v12)
					)
					local v14 = position6 + Vector3.new(
						math.random(-v12, v12),
						math.random(-v12, v12),
						math.random(-v12, v12)
					)
					local v15 = math.random(99999999)
					folder:SetAttribute("id", v15)
					local lastTime2 = tick()
					local v16 = magnitude2 / v7 / 60

					while tick() - lastTime2 < v16 and folder:GetAttribute("id") == v15 do
						local v17 = (tick() - lastTime2) / v16
						local v18 = cubicBezier(v17, position4, v13, v14, v10)
						folder.CFrame = folder.CFrame:Lerp(CFrame.new(v18, v10), v17)
						RunService.Heartbeat:Wait()
					end

					if folder:GetAttribute("id") ~= v15 then
						return
					end

					folder.Size = createVector(0.1, 0.1, 0.1)
					local v17 = math.random(1, 3)

					for i, emitter in pairs(folder:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						if emitter.Name == "Particle_" .. tostring(v17) then
							emitter.Size = NumberSequence.new(10)
							emitter.Rate = 5
							emitter.Enabled = true
						elseif emitter.Name == "Particle_5" or emitter.Name == "Particle_6" then
							emitter.Enabled = true
						else
							emitter.Enabled = false
							emitter:Destroy()
						end
					end

					local v18 = math.random(99999999)
					folder:SetAttribute("id", v18)
					local lastTime3 = os.clock()

					while folder:GetAttribute("id") == v18 do
						folder.Position = position4 + Vector3.new(
							math.random(-10, 10) / 1,
							math.random(-10, 10) / 1,
							math.random(-10, 10) / 1
						)

						for i, effect in pairs(folder:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = true
							end
						end

						local position7 = folder.Position
						local v19 = v10 + Vector3.new(
							math.random(-10, 10) / 1,
							math.random(-10, 10) / 1,
							math.random(-10, 10) / 1
						)
						local magnitude3 = (position7 - v19).Magnitude
						folder.CFrame = CFrame.new(position7, v19)
						local v20 = (position7 - v19) / 2
						local position8 = CFrame.new(CFrame.new(position7) * (v20 / -1.5)).Position
						local position9 = CFrame.new(CFrame.new(v19) * (v20 / 1.5)).Position
						local v21 = math.random(15, 20)
						local v22 = position8 + Vector3.new(
							math.random(-v21, v21),
							math.random(-v21, v21),
							math.random(-v21, v21)
						)
						local v23 = position9 + Vector3.new(
							math.random(-v21, v21),
							math.random(-v21, v21),
							math.random(-v21, v21)
						)
						local v24 = math.random(10, 20) / math.random(5, 15)
						local lastTime4 = tick()
						local v25 = magnitude3 / v24 / 60

						while tick() - lastTime4 < v25 do
							local v26 = (tick() - lastTime4) / v25
							local v27 = cubicBezier(v26, position7, v22, v23, v19)
							folder.CFrame = folder.CFrame:Lerp(CFrame.new(v27, v19), v26)
							RunService.Heartbeat:Wait()
						end

						for i, effect in pairs(folder:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = false
							end
						end

						task.wait()

						if os.clock() - lastTime3 >= 0.8500000000000001 then
							break
						end
					end

					if folder:GetAttribute("id") ~= v18 then
						return
					end

					for i, effect in pairs(folder:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = true
						end
					end

					local v19 = CFrame.new(position4, v2) * CFrame.new(0, 0, -50).Position
					local position7 = folder.Position
					local v20 = v19 + Vector3.new(
						math.random(-20, 20) / 3,
						math.random(5, 25) / 3,
						math.random(-20, 20) / 3
					)
					local magnitude3 = (position7 - v20).Magnitude
					folder.CFrame = CFrame.new(position7, v20)
					local v21 = (position7 - v20) / 2
					local position8 = CFrame.new(CFrame.new(position7) * (v21 / -1.5)).Position
					local position9 = CFrame.new(CFrame.new(v20) * (v21 / 1.5)).Position
					local halfMagnitude3 = magnitude3 / 2
					local v23 = position8 + Vector3.new(
						math.random(-halfMagnitude3, halfMagnitude3),
						math.random(-halfMagnitude3, halfMagnitude3),
						math.random(-halfMagnitude3, halfMagnitude3)
					)
					local v24 = position9 + Vector3.new(
						math.random(-halfMagnitude3, halfMagnitude3),
						math.random(-halfMagnitude3, halfMagnitude3),
						math.random(-halfMagnitude3, halfMagnitude3)
					)
					coroutine.wrap(function()
						for i = 1, 5 do
							for i2, emitter in pairs(folder:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("Kaw") then
									emitter.Size = NumberSequence.new(i / 2)
								end
							end

							task.wait(0.05)
						end
					end)()
					local v25 = math.random(10, 13) / 3
					local v26 = math.random(99999999)
					folder:SetAttribute("id", v26)
					local lastTime4 = tick()
					local v27 = magnitude3 / v25 / 60

					while tick() - lastTime4 < v27 and folder:GetAttribute("id") == v26 do
						local v28 = (tick() - lastTime4) / v27
						local v29 = cubicBezier(v28, position7, v23, v24, v20)
						folder.CFrame = folder.CFrame:Lerp(CFrame.new(v29, v20), v28)
						RunService.Heartbeat:Wait()
					end

					if folder:GetAttribute("id") ~= v26 then
						return
					end

					for i, effect in pairs(folder:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end
				end
			end)()
		end

		if p3 == "Final" then
			for _, item in pairs(items) do
				Util.Debris:AddItem(item, 3)
			end

			items = nil
		elseif p3 == "Grab" then
			for _, item in pairs(items) do
				Util.Debris:AddItem(item, 5)
			end

			items = nil
		end
	end)()
end

local function Dash(folder, root, cFrame)
	local clone = ghoulLifeSteal.StartImpact:Clone()
	clone.CFrame = cFrame
	clone.Parent = folder

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	local clone2 = ghoulLifeSteal.Dash:Clone()
	clone2.CFrame = cFrame
	clone2.Parent = folder
	clone2.Weld.Part0 = root

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	coroutine.wrap(function()
		task.wait(0.25)
		clone2.Weld.Enabled = false
		clone2.Anchored = true

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)()
end

local function DrainTrail(clonesByClone, p, position)
	local lastTime = os.clock()

	repeat
		for _, item in pairs(clonesByClone) do
			if item:GetAttribute("Move") ~= false then
				continue
			end

			local v = item
			coroutine.wrap(function()
				v:SetAttribute("Move", true)
				task.wait(0.005)
				local folder = v
				folder.Position = p + Vector3.new(
					math.random(-10, 10) / 3,
					math.random(-10, 10) / 3,
					math.random(-10, 10) / 3
				)

				for i, effect in pairs(folder:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = true
					end
				end

				local position2 = folder.Position
				local v2 = position + Vector3.new(
					math.random(-10, 10) / 3,
					math.random(-10, 10) / 3,
					math.random(-10, 10) / 3
				)
				local magnitude = (position2 - v2).Magnitude
				folder.CFrame = CFrame.new(position2, v2)
				local v3 = (position2 - v2) / 2
				local position3 = CFrame.new(CFrame.new(position2) * (v3 / -1.5)).Position
				local position4 = CFrame.new(CFrame.new(v2) * (v3 / 1.5)).Position
				local v4 = math.random(12, 17)
				local v5 = position3 + Vector3.new(math.random(-v4, v4), math.random(-v4, v4), math.random(-v4, v4))
				local v6 = position4 + Vector3.new(math.random(-v4, v4), math.random(-v4, v4), math.random(-v4, v4))
				local v7 = math.random(12, 20) / 30
				local lastTime2 = tick()
				local v8 = magnitude / v7 / 60

				while tick() - lastTime2 < v8 do
					local v9 = (tick() - lastTime2) / v8
					local v10 = cubicBezier(v9, position2, v5, v6, v2)
					folder.CFrame = folder.CFrame:Lerp(CFrame.new(v10, v2), v9)
					RunService.Heartbeat:Wait()
				end

				for i, effect in pairs(folder:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				task.wait(0.15)
				v:SetAttribute("Move", false)
			end)()
		end

		task.wait()
	until os.clock() - lastTime >= 1
end

local function LifeDrain(dashCFrame, folder)
	coroutine.wrap(function()
		local clone = ghoulLifeSteal.MainSpikes:Clone()
		clone.CFrame = dashCFrame
		clone.Parent = folder

		for _, child in pairs(clone:GetChildren()) do
			for _, child2 in pairs(child:GetChildren()) do
				local v = child2
				local v2 = child
				coroutine.wrap(function()
					local attachment0 = v.Attachment0
					local attachment1 = v.Attachment1
					local numberValue = Instance.new("NumberValue")
					numberValue.Value = 0
					local tween = TweenService:Create(
						numberValue,
						TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Value = 1
						}
					)
					local curveSize0 = attachment1.Beam.CurveSize0
					local curveSize1 = attachment1.Beam.CurveSize1
					local position = attachment0.Position
					local cframe = CFrame.new(position)
					local orientation = attachment0.Orientation
					attachment0.Orientation = attachment1.Orientation
					attachment0.Position = attachment1.Position

					for i, child3 in pairs(attachment1:GetChildren()) do
						child3.CurveSize0 = 0
						child3.CurveSize1 = 0
					end

					if v.Name == "Part2" then
						task.wait(0.1)
					elseif v.Name == "Part3" then
						task.wait(0.2)
					elseif v.Name == "Part4" then
						task.wait(0.30000000000000004)
					elseif v.Name == "Part5" then
						task.wait(0.4)
					end

					task.wait(v2:GetAttribute("Delay"))
					tween:Play()
					coroutine.wrap(function()
						for i, child3 in pairs(attachment1:GetChildren()) do
							local v3 = child3
							coroutine.wrap(function()
								local tween2 = TweenService:Create(
									v3,
									TweenInfo.new(0.025, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
									{
										CurveSize0 = curveSize0 / 4,
										CurveSize1 = curveSize1 / 4
									}
								)
								tween2:Play()
								tween2.Completed:Wait()
								local tween3 = TweenService:Create(
									v3,
									TweenInfo.new(0.025, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
									{
										CurveSize0 = curveSize0 / 3,
										CurveSize1 = curveSize1 / 3
									}
								)
								tween3:Play()
								tween3.Completed:Wait()
								local tween4 = TweenService:Create(
									v3,
									TweenInfo.new(0.025, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
									{
										CurveSize0 = curveSize0 / 2,
										CurveSize1 = curveSize1 / 2
									}
								)
								tween4:Play()
								tween4.Completed:Wait()
								local tween5 = TweenService:Create(
									v3,
									TweenInfo.new(0.025, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
									{
										CurveSize0 = curveSize0,
										CurveSize1 = curveSize1
									}
								)
								tween5:Play()
								tween5.Completed:Wait()
								task.wait(1.05)
								TweenService:Create(v3, TweenInfo.new(0.01), {
									Width0 = 0,
									Width1 = 0
								}):Play()
							end)()
						end
					end)()

					for i, child3 in pairs(attachment0:GetChildren()) do
						child3.Enabled = true
					end

					attachment0.Orientation = orientation
					local cFrame = attachment0.CFrame
					local position2 = attachment0.Position

					repeat
						attachment0.Position = B(
							numberValue.Value,
							position2,
							(cFrame * CFrame.new(curveSize0, 0, 0)).p,
							(cframe * CFrame.new(-curveSize1, 0, 0)).p,
							position
						)
						RunService.Heartbeat:Wait()
					until numberValue.Value == 1

					for i, child3 in pairs(attachment0:GetChildren()) do
						child3.Enabled = false
					end

					attachment0.Position = B(
						numberValue.Value,
						position2,
						(cFrame * CFrame.new(curveSize0, 0, 0)).p,
						(cframe * CFrame.new(-curveSize1, 0, 0)).p,
						position
					)
					numberValue:Destroy()
				end)()
			end
		end
	end)()
	coroutine.wrap(function()
		local clone = ghoulLifeSteal.MainSpikes2:Clone()
		clone.CFrame = dashCFrame
		clone.Parent = folder

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				local v = descendant
				coroutine.wrap(function()
					v.Enabled = false
					task.wait(math.random(1, 10) / 100)
					v.Enabled = true
					task.wait(1.1500000000000001)
					v.Enabled = false
				end)()
			elseif descendant:IsA("Attachment") then
				local tween = TweenService:Create(descendant, TweenInfo.new(math.random(10, 20) / 100), {
					CFrame = descendant.CFrame
				})
				descendant.CFrame *= CFrame.new(0, 0, math.random(5, 10))
				tween:Play()
			end
		end
	end)()
	coroutine.wrap(function()
		task.wait(0.15)
		local clone = ghoulLifeSteal.Drain:Clone()
		clone.CFrame = dashCFrame
		clone.Parent = folder

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			coroutine.wrap(function()
				v.Enabled = true
				task.wait(1.1500000000000001)
				v.Enabled = false

				if v:GetAttribute("Spook") then
					v.Lifetime = NumberRange.new(0.15)
					v.Size = NumberSequence.new(5, 8, 10)
					v.Transparency = NumberSequence.new(0, 1)
					v:Emit(1)
				end
			end)()
		end
	end)()
	coroutine.wrap(function()
		task.wait(0.25)
		local clonesByClone = {}

		for _ = 1, 15 do
			local clone = ghoulLifeSteal.Trail:Clone()
			clone.Parent = folder
			clone:SetAttribute("Move", false)
			clonesByClone[clone] = clone
		end

		DrainTrail(clonesByClone, dashCFrame * CFrame.new(0, 3, -7).Position, dashCFrame.Position)

		for _, v2 in pairs(clonesByClone) do
			Util.Debris:AddItem(v2, 3)
		end
	end)()
	task.wait(1.3)
	Util.Sound:Play("SanguineArtZHit2", dashCFrame)
	local clone = ghoulLifeSteal.FinalHit:Clone()
	clone.CFrame = dashCFrame
	clone.Parent = folder

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	local clone2 = ghoulLifeSteal.FinalHit2:Clone()
	clone2.CFrame = dashCFrame
	clone2.Parent = folder

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local tween = TweenService:Create(clone2, TweenInfo.new(0.25), {
		CFrame = clone2.CFrame * CFrame.new(0, 0, -75)
	})
	tween:Play()
	coroutine.wrap(function()
		tween.Completed:Wait()

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)()
end

return function(data)
	local root = data.Root

	if not root or (workspace.CurrentCamera.CFrame.Position - root.Position).Magnitude > 1250 then
		return
	end

	if data.Holding then
		local root2 = data.Root
		local v = Util.Sound:Play("GenericDarkSkillCharge", root2)
		local clone = ghoulLifeSteal.HoldHand:Clone()
		clone.CFrame = root2.Parent.RightHand.CFrame
		clone.Parent = root2.Parent
		clone.Weld.Part0 = root2.Parent.RightHand
		local clone2 = ghoulLifeSteal.HoldHand:Clone()
		clone2.CFrame = root2.Parent.LeftHand.CFrame
		clone2.Parent = root2.Parent
		clone2.Weld.Part0 = root2.Parent.LeftHand

		repeat
			wait()
		until data.Holding.Value == false or not data.Holding:IsDescendantOf(workspace)

		Util.Sound:FadeOut(v, 0.25)
		task.wait(0.1)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(1)
		clone:Destroy()
		clone2:Destroy()
	else
		local dashPosition = data.DashPosition

		if data.Grab then
			local folder = Instance.new("Folder")
			folder.Parent = _WorldOrigin
			local dashCFrame = data.DashCFrame
			local childrenByChild = {}
			local child = _WorldOrigin:FindFirstChild(root.Parent.Name .. "CrowsGrab")

			if child then
				child.Name = "Folder"

				for i = 1, 7 do
					local child2 = child:FindFirstChild("Trail" .. i)

					if child2 then
						childrenByChild[child2] = child2
					end
				end
			end

			if data.Hit then
				Util.Sound:Play("SanguineArtZHit", root)
				local v = dashPosition + Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5)
				local position = dashCFrame.Position
				local v2 = childrenByChild
				local v3 = "Grab"
				coroutine.wrap(function()
					for _, v4 in pairs(v2) do
						local v5 = v4
						coroutine.wrap(function()
							if v3 == "Grab" then
								task.wait(5e-13)
							else
								task.wait(0.005)
							end

							local folder2 = v5

							if v3 == "First" then
								folder2.Position = v + Vector3.new(
									math.random(-10, 10) / 3,
									math.random(-10, 10) / 3,
									math.random(-10, 10) / 3
								)
							end

							for i, emitter in pairs(folder2:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = true
								end
							end

							local position2 = folder2.Position
							local v6 = position + Vector3.new(
								math.random(-10, 10) / 3,
								math.random(-10, 10) / 3,
								math.random(-10, 10) / 3
							)
							local magnitude = (position2 - v6).Magnitude
							folder2.CFrame = CFrame.new(position2, v6)
							local v7 = (position2 - v6) / 2
							local position3 = CFrame.new(CFrame.new(position2) * (v7 / -1.5)).Position
							local position4 = CFrame.new(CFrame.new(v6) * (v7 / 1.5)).Position
							local v8 = magnitude / 1.9
							local v9 = position3 + Vector3.new(
								math.random(-v8, v8),
								math.random(-v8, v8),
								math.random(-v8, v8)
							)
							local v10 = position4 + Vector3.new(
								math.random(-v8, v8),
								math.random(-v8, v8),
								math.random(-v8, v8)
							)
							local v11 = 4 * math.random(10, 20) / 10

							if v3 == "Grab" then
								v11 = 6 * math.random(10, 15) / 3
							elseif v3 == "Final" then
								v11 = math.random(10, 15) / 7
							end

							local v12 = math.random(99999999)
							folder2:SetAttribute("id", v12)
							local lastTime = tick()
							local v13 = magnitude / v11 / 60

							while tick() - lastTime < v13 and folder2:GetAttribute("id") == v12 do
								local v14 = (tick() - lastTime) / v13
								local v15 = cubicBezier(v14, position2, v9, v10, v6)
								folder2.CFrame = folder2.CFrame:Lerp(CFrame.new(v15, v6), v14)
								RunService.Heartbeat:Wait()
							end

							if folder2:GetAttribute("id") ~= v12 then
								return
							end

							if v3 == "Final" then
								local position5 = folder2.Position
								local v14 = position5 + Vector3.new(
									math.random(-20, 20) * 2,
									math.random(5, 25) * 2,
									math.random(-20, 20) * 2
								)
								local magnitude2 = (position5 - v14).Magnitude
								folder2.CFrame = CFrame.new(position5, v14)
								local v15 = (position5 - v14) / 2
								local position6 = CFrame.new(CFrame.new(position5) * (v15 / -1.5)).Position
								local position7 = CFrame.new(CFrame.new(v14) * (v15 / 1.5)).Position
								local halfMagnitude2 = magnitude2 / 2
								local v17 = position6 + Vector3.new(
									math.random(-halfMagnitude2, halfMagnitude2),
									math.random(-halfMagnitude2, halfMagnitude2),
									math.random(-halfMagnitude2, halfMagnitude2)
								)
								local v18 = position7 + Vector3.new(
									math.random(-halfMagnitude2, halfMagnitude2),
									math.random(-halfMagnitude2, halfMagnitude2),
									math.random(-halfMagnitude2, halfMagnitude2)
								)
								coroutine.wrap(function()
									for i = 1, 5 do
										for i2, emitter in pairs(folder2:GetDescendants()) do
											if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("Kaw") then
												emitter.Size = NumberSequence.new(i / 2)
											end
										end

										task.wait(0.05)
									end
								end)()
								local v19 = math.random(99999999)
								folder2:SetAttribute("id", v19)
								local lastTime2 = tick()
								local v20 = magnitude2 / v11 / 60

								while tick() - lastTime2 < v20 and folder2:GetAttribute("id") == v19 do
									local v21 = (tick() - lastTime2) / v20
									local v22 = cubicBezier(v21, position5, v17, v18, v14)
									folder2.CFrame = folder2.CFrame:Lerp(CFrame.new(v22, v14), v21)
									RunService.Heartbeat:Wait()
								end

								if folder2:GetAttribute("id") ~= v19 then
									return
								end

								for i, effect in pairs(folder2:GetDescendants()) do
									if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
										effect.Enabled = false
									end
								end
							elseif v3 == "Grab" then
								local v14 = v
								local position5 = folder2.Position
								local magnitude2 = (position5 - v14).Magnitude
								folder2.CFrame = CFrame.new(position5, v14)
								local v15 = (position5 - v14) / 2
								local position6 = CFrame.new(CFrame.new(position5) * (v15 / -1.5)).Position
								local position7 = CFrame.new(CFrame.new(v14) * (v15 / 1.5)).Position
								local v16 = magnitude2 / 3
								local v17 = position6 + Vector3.new(
									math.random(-v16, v16),
									math.random(-v16, v16),
									math.random(-v16, v16)
								)
								local v18 = position7 + Vector3.new(
									math.random(-v16, v16),
									math.random(-v16, v16),
									math.random(-v16, v16)
								)
								local v19 = math.random(99999999)
								folder2:SetAttribute("id", v19)
								local lastTime2 = tick()
								local v20 = magnitude2 / v11 / 60

								while tick() - lastTime2 < v20 and folder2:GetAttribute("id") == v19 do
									local v21 = (tick() - lastTime2) / v20
									local v22 = cubicBezier(v21, position5, v17, v18, v14)
									folder2.CFrame = folder2.CFrame:Lerp(CFrame.new(v22, v14), v21)
									RunService.Heartbeat:Wait()
								end

								if folder2:GetAttribute("id") ~= v19 then
									return
								end

								folder2.Size = createVector(0.1, 0.1, 0.1)
								local v21 = math.random(1, 3)

								for i, emitter in pairs(folder2:GetDescendants()) do
									if not emitter:IsA("ParticleEmitter") then
										continue
									end

									if emitter.Name == "Particle_" .. tostring(v21) then
										emitter.Size = NumberSequence.new(10)
										emitter.Rate = 5
										emitter.Enabled = true
									elseif emitter.Name == "Particle_5" or emitter.Name == "Particle_6" then
										emitter.Enabled = true
									else
										emitter.Enabled = false
										emitter:Destroy()
									end
								end

								local v22 = math.random(99999999)
								folder2:SetAttribute("id", v22)
								local lastTime3 = os.clock()

								while folder2:GetAttribute("id") == v22 do
									folder2.Position = position5 + Vector3.new(
										math.random(-10, 10) / 1,
										math.random(-10, 10) / 1,
										math.random(-10, 10) / 1
									)

									for i, effect in pairs(folder2:GetDescendants()) do
										if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
											effect.Enabled = true
										end
									end

									local position8 = folder2.Position
									local v23 = v14 + Vector3.new(
										math.random(-10, 10) / 1,
										math.random(-10, 10) / 1,
										math.random(-10, 10) / 1
									)
									local magnitude3 = (position8 - v23).Magnitude
									folder2.CFrame = CFrame.new(position8, v23)
									local v24 = (position8 - v23) / 2
									local position9 = CFrame.new(CFrame.new(position8) * (v24 / -1.5)).Position
									local position10 = CFrame.new(CFrame.new(v23) * (v24 / 1.5)).Position
									local v25 = math.random(15, 20)
									local v26 = position9 + Vector3.new(
										math.random(-v25, v25),
										math.random(-v25, v25),
										math.random(-v25, v25)
									)
									local v27 = position10 + Vector3.new(
										math.random(-v25, v25),
										math.random(-v25, v25),
										math.random(-v25, v25)
									)
									local v28 = math.random(10, 20) / math.random(5, 15)
									local lastTime4 = tick()
									local v29 = magnitude3 / v28 / 60

									while tick() - lastTime4 < v29 do
										local v30 = (tick() - lastTime4) / v29
										local v31 = cubicBezier(v30, position8, v26, v27, v23)
										folder2.CFrame = folder2.CFrame:Lerp(CFrame.new(v31, v23), v30)
										RunService.Heartbeat:Wait()
									end

									for i, effect in pairs(folder2:GetDescendants()) do
										if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
											effect.Enabled = false
										end
									end

									task.wait()

									if os.clock() - lastTime3 >= 0.8500000000000001 then
										break
									end
								end

								if folder2:GetAttribute("id") ~= v22 then
									return
								end

								for i, effect in pairs(folder2:GetDescendants()) do
									if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
										effect.Enabled = true
									end
								end

								local v23 = CFrame.new(position5, v6) * CFrame.new(0, 0, -50).Position
								local position8 = folder2.Position
								local v24 = v23 + Vector3.new(
									math.random(-20, 20) / 3,
									math.random(5, 25) / 3,
									math.random(-20, 20) / 3
								)
								local magnitude3 = (position8 - v24).Magnitude
								folder2.CFrame = CFrame.new(position8, v24)
								local v25 = (position8 - v24) / 2
								local position9 = CFrame.new(CFrame.new(position8) * (v25 / -1.5)).Position
								local position10 = CFrame.new(CFrame.new(v24) * (v25 / 1.5)).Position
								local halfMagnitude3 = magnitude3 / 2
								local v27 = position9 + Vector3.new(
									math.random(-halfMagnitude3, halfMagnitude3),
									math.random(-halfMagnitude3, halfMagnitude3),
									math.random(-halfMagnitude3, halfMagnitude3)
								)
								local v28 = position10 + Vector3.new(
									math.random(-halfMagnitude3, halfMagnitude3),
									math.random(-halfMagnitude3, halfMagnitude3),
									math.random(-halfMagnitude3, halfMagnitude3)
								)
								coroutine.wrap(function()
									for i = 1, 5 do
										for i2, emitter in pairs(folder2:GetDescendants()) do
											if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("Kaw") then
												emitter.Size = NumberSequence.new(i / 2)
											end
										end

										task.wait(0.05)
									end
								end)()
								local v29 = math.random(10, 13) / 3
								local v30 = math.random(99999999)
								folder2:SetAttribute("id", v30)
								local lastTime4 = tick()
								local v31 = magnitude3 / v29 / 60

								while tick() - lastTime4 < v31 and folder2:GetAttribute("id") == v30 do
									local v32 = (tick() - lastTime4) / v31
									local v33 = cubicBezier(v32, position8, v27, v28, v24)
									folder2.CFrame = folder2.CFrame:Lerp(CFrame.new(v33, v24), v32)
									RunService.Heartbeat:Wait()
								end

								if folder2:GetAttribute("id") ~= v30 then
									return
								end

								for i, effect in pairs(folder2:GetDescendants()) do
									if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
										effect.Enabled = false
									end
								end
							end
						end)()
					end

					if v3 == "Final" then
						for _, v4 in pairs(v2) do
							Util.Debris:AddItem(v4, 3)
						end

						v2 = nil
					elseif v3 == "Grab" then
						for _, v4 in pairs(v2) do
							Util.Debris:AddItem(v4, 5)
						end

						v2 = nil
					end
				end)()
				LifeDrain(dashCFrame, folder)
			else
				local position = dashCFrame.Position
				local v = dashCFrame * createVector(0, 0, -50)
				local v2 = childrenByChild
				local v3 = "Final"
				coroutine.wrap(function()
					for _, v4 in pairs(v2) do
						local v5 = v4
						coroutine.wrap(function()
							if v3 == "Grab" then
								task.wait(5e-13)
							else
								task.wait(0.005)
							end

							local folder2 = v5

							if v3 == "First" then
								folder2.Position = position + Vector3.new(
									math.random(-10, 10) / 3,
									math.random(-10, 10) / 3,
									math.random(-10, 10) / 3
								)
							end

							for i, emitter in pairs(folder2:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = true
								end
							end

							local position2 = folder2.Position
							local v6 = v + Vector3.new(
								math.random(-10, 10) / 3,
								math.random(-10, 10) / 3,
								math.random(-10, 10) / 3
							)
							local magnitude = (position2 - v6).Magnitude
							folder2.CFrame = CFrame.new(position2, v6)
							local v7 = (position2 - v6) / 2
							local position3 = CFrame.new(CFrame.new(position2) * (v7 / -1.5)).Position
							local position4 = CFrame.new(CFrame.new(v6) * (v7 / 1.5)).Position
							local v8 = magnitude / 1.9
							local v9 = position3 + Vector3.new(
								math.random(-v8, v8),
								math.random(-v8, v8),
								math.random(-v8, v8)
							)
							local v10 = position4 + Vector3.new(
								math.random(-v8, v8),
								math.random(-v8, v8),
								math.random(-v8, v8)
							)
							local v11 = 4 * math.random(10, 20) / 10

							if v3 == "Grab" then
								v11 = 6 * math.random(10, 15) / 3
							elseif v3 == "Final" then
								v11 = math.random(10, 15) / 7
							end

							local v12 = math.random(99999999)
							folder2:SetAttribute("id", v12)
							local lastTime = tick()
							local v13 = magnitude / v11 / 60

							while tick() - lastTime < v13 and folder2:GetAttribute("id") == v12 do
								local v14 = (tick() - lastTime) / v13
								local v15 = cubicBezier(v14, position2, v9, v10, v6)
								folder2.CFrame = folder2.CFrame:Lerp(CFrame.new(v15, v6), v14)
								RunService.Heartbeat:Wait()
							end

							if folder2:GetAttribute("id") ~= v12 then
								return
							end

							if v3 == "Final" then
								local position5 = folder2.Position
								local v14 = position5 + Vector3.new(
									math.random(-20, 20) * 2,
									math.random(5, 25) * 2,
									math.random(-20, 20) * 2
								)
								local magnitude2 = (position5 - v14).Magnitude
								folder2.CFrame = CFrame.new(position5, v14)
								local v15 = (position5 - v14) / 2
								local position6 = CFrame.new(CFrame.new(position5) * (v15 / -1.5)).Position
								local position7 = CFrame.new(CFrame.new(v14) * (v15 / 1.5)).Position
								local halfMagnitude2 = magnitude2 / 2
								local v17 = position6 + Vector3.new(
									math.random(-halfMagnitude2, halfMagnitude2),
									math.random(-halfMagnitude2, halfMagnitude2),
									math.random(-halfMagnitude2, halfMagnitude2)
								)
								local v18 = position7 + Vector3.new(
									math.random(-halfMagnitude2, halfMagnitude2),
									math.random(-halfMagnitude2, halfMagnitude2),
									math.random(-halfMagnitude2, halfMagnitude2)
								)
								coroutine.wrap(function()
									for i = 1, 5 do
										for i2, emitter in pairs(folder2:GetDescendants()) do
											if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("Kaw") then
												emitter.Size = NumberSequence.new(i / 2)
											end
										end

										task.wait(0.05)
									end
								end)()
								local v19 = math.random(99999999)
								folder2:SetAttribute("id", v19)
								local lastTime2 = tick()
								local v20 = magnitude2 / v11 / 60

								while tick() - lastTime2 < v20 and folder2:GetAttribute("id") == v19 do
									local v21 = (tick() - lastTime2) / v20
									local v22 = cubicBezier(v21, position5, v17, v18, v14)
									folder2.CFrame = folder2.CFrame:Lerp(CFrame.new(v22, v14), v21)
									RunService.Heartbeat:Wait()
								end

								if folder2:GetAttribute("id") ~= v19 then
									return
								end

								for i, effect in pairs(folder2:GetDescendants()) do
									if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
										effect.Enabled = false
									end
								end
							elseif v3 == "Grab" then
								local v14 = position
								local position5 = folder2.Position
								local magnitude2 = (position5 - v14).Magnitude
								folder2.CFrame = CFrame.new(position5, v14)
								local v15 = (position5 - v14) / 2
								local position6 = CFrame.new(CFrame.new(position5) * (v15 / -1.5)).Position
								local position7 = CFrame.new(CFrame.new(v14) * (v15 / 1.5)).Position
								local v16 = magnitude2 / 3
								local v17 = position6 + Vector3.new(
									math.random(-v16, v16),
									math.random(-v16, v16),
									math.random(-v16, v16)
								)
								local v18 = position7 + Vector3.new(
									math.random(-v16, v16),
									math.random(-v16, v16),
									math.random(-v16, v16)
								)
								local v19 = math.random(99999999)
								folder2:SetAttribute("id", v19)
								local lastTime2 = tick()
								local v20 = magnitude2 / v11 / 60

								while tick() - lastTime2 < v20 and folder2:GetAttribute("id") == v19 do
									local v21 = (tick() - lastTime2) / v20
									local v22 = cubicBezier(v21, position5, v17, v18, v14)
									folder2.CFrame = folder2.CFrame:Lerp(CFrame.new(v22, v14), v21)
									RunService.Heartbeat:Wait()
								end

								if folder2:GetAttribute("id") ~= v19 then
									return
								end

								folder2.Size = createVector(0.1, 0.1, 0.1)
								local v21 = math.random(1, 3)

								for i, emitter in pairs(folder2:GetDescendants()) do
									if not emitter:IsA("ParticleEmitter") then
										continue
									end

									if emitter.Name == "Particle_" .. tostring(v21) then
										emitter.Size = NumberSequence.new(10)
										emitter.Rate = 5
										emitter.Enabled = true
									elseif emitter.Name == "Particle_5" or emitter.Name == "Particle_6" then
										emitter.Enabled = true
									else
										emitter.Enabled = false
										emitter:Destroy()
									end
								end

								local v22 = math.random(99999999)
								folder2:SetAttribute("id", v22)
								local lastTime3 = os.clock()

								while folder2:GetAttribute("id") == v22 do
									folder2.Position = position5 + Vector3.new(
										math.random(-10, 10) / 1,
										math.random(-10, 10) / 1,
										math.random(-10, 10) / 1
									)

									for i, effect in pairs(folder2:GetDescendants()) do
										if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
											effect.Enabled = true
										end
									end

									local position8 = folder2.Position
									local v23 = v14 + Vector3.new(
										math.random(-10, 10) / 1,
										math.random(-10, 10) / 1,
										math.random(-10, 10) / 1
									)
									local magnitude3 = (position8 - v23).Magnitude
									folder2.CFrame = CFrame.new(position8, v23)
									local v24 = (position8 - v23) / 2
									local position9 = CFrame.new(CFrame.new(position8) * (v24 / -1.5)).Position
									local position10 = CFrame.new(CFrame.new(v23) * (v24 / 1.5)).Position
									local v25 = math.random(15, 20)
									local v26 = position9 + Vector3.new(
										math.random(-v25, v25),
										math.random(-v25, v25),
										math.random(-v25, v25)
									)
									local v27 = position10 + Vector3.new(
										math.random(-v25, v25),
										math.random(-v25, v25),
										math.random(-v25, v25)
									)
									local v28 = math.random(10, 20) / math.random(5, 15)
									local lastTime4 = tick()
									local v29 = magnitude3 / v28 / 60

									while tick() - lastTime4 < v29 do
										local v30 = (tick() - lastTime4) / v29
										local v31 = cubicBezier(v30, position8, v26, v27, v23)
										folder2.CFrame = folder2.CFrame:Lerp(CFrame.new(v31, v23), v30)
										RunService.Heartbeat:Wait()
									end

									for i, effect in pairs(folder2:GetDescendants()) do
										if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
											effect.Enabled = false
										end
									end

									task.wait()

									if os.clock() - lastTime3 >= 0.8500000000000001 then
										break
									end
								end

								if folder2:GetAttribute("id") ~= v22 then
									return
								end

								for i, effect in pairs(folder2:GetDescendants()) do
									if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
										effect.Enabled = true
									end
								end

								local v23 = CFrame.new(position5, v6) * CFrame.new(0, 0, -50).Position
								local position8 = folder2.Position
								local v24 = v23 + Vector3.new(
									math.random(-20, 20) / 3,
									math.random(5, 25) / 3,
									math.random(-20, 20) / 3
								)
								local magnitude3 = (position8 - v24).Magnitude
								folder2.CFrame = CFrame.new(position8, v24)
								local v25 = (position8 - v24) / 2
								local position9 = CFrame.new(CFrame.new(position8) * (v25 / -1.5)).Position
								local position10 = CFrame.new(CFrame.new(v24) * (v25 / 1.5)).Position
								local halfMagnitude3 = magnitude3 / 2
								local v27 = position9 + Vector3.new(
									math.random(-halfMagnitude3, halfMagnitude3),
									math.random(-halfMagnitude3, halfMagnitude3),
									math.random(-halfMagnitude3, halfMagnitude3)
								)
								local v28 = position10 + Vector3.new(
									math.random(-halfMagnitude3, halfMagnitude3),
									math.random(-halfMagnitude3, halfMagnitude3),
									math.random(-halfMagnitude3, halfMagnitude3)
								)
								coroutine.wrap(function()
									for i = 1, 5 do
										for i2, emitter in pairs(folder2:GetDescendants()) do
											if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("Kaw") then
												emitter.Size = NumberSequence.new(i / 2)
											end
										end

										task.wait(0.05)
									end
								end)()
								local v29 = math.random(10, 13) / 3
								local v30 = math.random(99999999)
								folder2:SetAttribute("id", v30)
								local lastTime4 = tick()
								local v31 = magnitude3 / v29 / 60

								while tick() - lastTime4 < v31 and folder2:GetAttribute("id") == v30 do
									local v32 = (tick() - lastTime4) / v31
									local v33 = cubicBezier(v32, position8, v27, v28, v24)
									folder2.CFrame = folder2.CFrame:Lerp(CFrame.new(v33, v24), v32)
									RunService.Heartbeat:Wait()
								end

								if folder2:GetAttribute("id") ~= v30 then
									return
								end

								for i, effect in pairs(folder2:GetDescendants()) do
									if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
										effect.Enabled = false
									end
								end
							end
						end)()
					end

					if v3 == "Final" then
						for _, v4 in pairs(v2) do
							Util.Debris:AddItem(v4, 3)
						end

						v2 = nil
					elseif v3 == "Grab" then
						for _, v4 in pairs(v2) do
							Util.Debris:AddItem(v4, 5)
						end

						v2 = nil
					end
				end)()
			end

			Util.Debris:AddItem(folder, 6)
		else
			Util.Sound:Play("SanguineArtZFire", root)
			local folder = Instance.new("Folder")
			folder.Name = root.Parent.Name .. "CrowsGrab"
			folder.Parent = _WorldOrigin
			local cFrame = root.CFrame * CFrame.new(0, 0, -10)
			local clonesByClone = {}

			for i = 1, 7 do
				local clone = ghoulLifeSteal.Crow:Clone()
				clone.Name = "Trail" .. i
				clone.Position = cFrame.Position + Vector3.new(
					math.random(-10, 10) / 3,
					math.random(-10, 10) / 3,
					math.random(-10, 10) / 3
				)
				clone.Parent = folder
				clonesByClone[clone] = clone
			end

			local position = cFrame.Position
			local v2 = clonesByClone
			local v3 = "First"
			coroutine.wrap(function()
				for _, v4 in pairs(v2) do
					local v5 = v4
					coroutine.wrap(function()
						if v3 == "Grab" then
							task.wait(5e-13)
						else
							task.wait(0.005)
						end

						local folder2 = v5

						if v3 == "First" then
							folder2.Position = position + Vector3.new(
								math.random(-10, 10) / 3,
								math.random(-10, 10) / 3,
								math.random(-10, 10) / 3
							)
						end

						for i, emitter in pairs(folder2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = true
							end
						end

						local position2 = folder2.Position
						local v6 = dashPosition + Vector3.new(
							math.random(-10, 10) / 3,
							math.random(-10, 10) / 3,
							math.random(-10, 10) / 3
						)
						local magnitude = (position2 - v6).Magnitude
						folder2.CFrame = CFrame.new(position2, v6)
						local v7 = (position2 - v6) / 2
						local position3 = CFrame.new(CFrame.new(position2) * (v7 / -1.5)).Position
						local position4 = CFrame.new(CFrame.new(v6) * (v7 / 1.5)).Position
						local v8 = magnitude / 1.9
						local v9 = position3 + Vector3.new(
							math.random(-v8, v8),
							math.random(-v8, v8),
							math.random(-v8, v8)
						)
						local v10 = position4 + Vector3.new(
							math.random(-v8, v8),
							math.random(-v8, v8),
							math.random(-v8, v8)
						)
						local v11 = 4 * math.random(10, 20) / 10

						if v3 == "Grab" then
							v11 = 6 * math.random(10, 15) / 3
						elseif v3 == "Final" then
							v11 = math.random(10, 15) / 7
						end

						local v12 = math.random(99999999)
						folder2:SetAttribute("id", v12)
						local lastTime = tick()
						local v13 = magnitude / v11 / 60

						while tick() - lastTime < v13 and folder2:GetAttribute("id") == v12 do
							local v14 = (tick() - lastTime) / v13
							local v15 = cubicBezier(v14, position2, v9, v10, v6)
							folder2.CFrame = folder2.CFrame:Lerp(CFrame.new(v15, v6), v14)
							RunService.Heartbeat:Wait()
						end

						if folder2:GetAttribute("id") ~= v12 then
							return
						end

						if v3 == "Final" then
							local position5 = folder2.Position
							local v14 = position5 + Vector3.new(
								math.random(-20, 20) * 2,
								math.random(5, 25) * 2,
								math.random(-20, 20) * 2
							)
							local magnitude2 = (position5 - v14).Magnitude
							folder2.CFrame = CFrame.new(position5, v14)
							local v15 = (position5 - v14) / 2
							local position6 = CFrame.new(CFrame.new(position5) * (v15 / -1.5)).Position
							local position7 = CFrame.new(CFrame.new(v14) * (v15 / 1.5)).Position
							local halfMagnitude2 = magnitude2 / 2
							local v17 = position6 + Vector3.new(
								math.random(-halfMagnitude2, halfMagnitude2),
								math.random(-halfMagnitude2, halfMagnitude2),
								math.random(-halfMagnitude2, halfMagnitude2)
							)
							local v18 = position7 + Vector3.new(
								math.random(-halfMagnitude2, halfMagnitude2),
								math.random(-halfMagnitude2, halfMagnitude2),
								math.random(-halfMagnitude2, halfMagnitude2)
							)
							coroutine.wrap(function()
								for i = 1, 5 do
									for i2, emitter in pairs(folder2:GetDescendants()) do
										if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("Kaw") then
											emitter.Size = NumberSequence.new(i / 2)
										end
									end

									task.wait(0.05)
								end
							end)()
							local v19 = math.random(99999999)
							folder2:SetAttribute("id", v19)
							local lastTime2 = tick()
							local v20 = magnitude2 / v11 / 60

							while tick() - lastTime2 < v20 and folder2:GetAttribute("id") == v19 do
								local v21 = (tick() - lastTime2) / v20
								local v22 = cubicBezier(v21, position5, v17, v18, v14)
								folder2.CFrame = folder2.CFrame:Lerp(CFrame.new(v22, v14), v21)
								RunService.Heartbeat:Wait()
							end

							if folder2:GetAttribute("id") ~= v19 then
								return
							end

							for i, effect in pairs(folder2:GetDescendants()) do
								if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = false
								end
							end
						elseif v3 == "Grab" then
							local v14 = position
							local position5 = folder2.Position
							local magnitude2 = (position5 - v14).Magnitude
							folder2.CFrame = CFrame.new(position5, v14)
							local v15 = (position5 - v14) / 2
							local position6 = CFrame.new(CFrame.new(position5) * (v15 / -1.5)).Position
							local position7 = CFrame.new(CFrame.new(v14) * (v15 / 1.5)).Position
							local v16 = magnitude2 / 3
							local v17 = position6 + Vector3.new(
								math.random(-v16, v16),
								math.random(-v16, v16),
								math.random(-v16, v16)
							)
							local v18 = position7 + Vector3.new(
								math.random(-v16, v16),
								math.random(-v16, v16),
								math.random(-v16, v16)
							)
							local v19 = math.random(99999999)
							folder2:SetAttribute("id", v19)
							local lastTime2 = tick()
							local v20 = magnitude2 / v11 / 60

							while tick() - lastTime2 < v20 and folder2:GetAttribute("id") == v19 do
								local v21 = (tick() - lastTime2) / v20
								local v22 = cubicBezier(v21, position5, v17, v18, v14)
								folder2.CFrame = folder2.CFrame:Lerp(CFrame.new(v22, v14), v21)
								RunService.Heartbeat:Wait()
							end

							if folder2:GetAttribute("id") ~= v19 then
								return
							end

							folder2.Size = createVector(0.1, 0.1, 0.1)
							local v21 = math.random(1, 3)

							for i, emitter in pairs(folder2:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								if emitter.Name == "Particle_" .. tostring(v21) then
									emitter.Size = NumberSequence.new(10)
									emitter.Rate = 5
									emitter.Enabled = true
								elseif emitter.Name == "Particle_5" or emitter.Name == "Particle_6" then
									emitter.Enabled = true
								else
									emitter.Enabled = false
									emitter:Destroy()
								end
							end

							local v22 = math.random(99999999)
							folder2:SetAttribute("id", v22)
							local lastTime3 = os.clock()

							while folder2:GetAttribute("id") == v22 do
								folder2.Position = position5 + Vector3.new(
									math.random(-10, 10) / 1,
									math.random(-10, 10) / 1,
									math.random(-10, 10) / 1
								)

								for i, effect in pairs(folder2:GetDescendants()) do
									if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
										effect.Enabled = true
									end
								end

								local position8 = folder2.Position
								local v23 = v14 + Vector3.new(
									math.random(-10, 10) / 1,
									math.random(-10, 10) / 1,
									math.random(-10, 10) / 1
								)
								local magnitude3 = (position8 - v23).Magnitude
								folder2.CFrame = CFrame.new(position8, v23)
								local v24 = (position8 - v23) / 2
								local position9 = CFrame.new(CFrame.new(position8) * (v24 / -1.5)).Position
								local position10 = CFrame.new(CFrame.new(v23) * (v24 / 1.5)).Position
								local v25 = math.random(15, 20)
								local v26 = position9 + Vector3.new(
									math.random(-v25, v25),
									math.random(-v25, v25),
									math.random(-v25, v25)
								)
								local v27 = position10 + Vector3.new(
									math.random(-v25, v25),
									math.random(-v25, v25),
									math.random(-v25, v25)
								)
								local v28 = math.random(10, 20) / math.random(5, 15)
								local lastTime4 = tick()
								local v29 = magnitude3 / v28 / 60

								while tick() - lastTime4 < v29 do
									local v30 = (tick() - lastTime4) / v29
									local v31 = cubicBezier(v30, position8, v26, v27, v23)
									folder2.CFrame = folder2.CFrame:Lerp(CFrame.new(v31, v23), v30)
									RunService.Heartbeat:Wait()
								end

								for i, effect in pairs(folder2:GetDescendants()) do
									if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
										effect.Enabled = false
									end
								end

								task.wait()

								if os.clock() - lastTime3 >= 0.8500000000000001 then
									break
								end
							end

							if folder2:GetAttribute("id") ~= v22 then
								return
							end

							for i, effect in pairs(folder2:GetDescendants()) do
								if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = true
								end
							end

							local v23 = CFrame.new(position5, v6) * CFrame.new(0, 0, -50).Position
							local position8 = folder2.Position
							local v24 = v23 + Vector3.new(
								math.random(-20, 20) / 3,
								math.random(5, 25) / 3,
								math.random(-20, 20) / 3
							)
							local magnitude3 = (position8 - v24).Magnitude
							folder2.CFrame = CFrame.new(position8, v24)
							local v25 = (position8 - v24) / 2
							local position9 = CFrame.new(CFrame.new(position8) * (v25 / -1.5)).Position
							local position10 = CFrame.new(CFrame.new(v24) * (v25 / 1.5)).Position
							local halfMagnitude3 = magnitude3 / 2
							local v27 = position9 + Vector3.new(
								math.random(-halfMagnitude3, halfMagnitude3),
								math.random(-halfMagnitude3, halfMagnitude3),
								math.random(-halfMagnitude3, halfMagnitude3)
							)
							local v28 = position10 + Vector3.new(
								math.random(-halfMagnitude3, halfMagnitude3),
								math.random(-halfMagnitude3, halfMagnitude3),
								math.random(-halfMagnitude3, halfMagnitude3)
							)
							coroutine.wrap(function()
								for i = 1, 5 do
									for i2, emitter in pairs(folder2:GetDescendants()) do
										if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("Kaw") then
											emitter.Size = NumberSequence.new(i / 2)
										end
									end

									task.wait(0.05)
								end
							end)()
							local v29 = math.random(10, 13) / 3
							local v30 = math.random(99999999)
							folder2:SetAttribute("id", v30)
							local lastTime4 = tick()
							local v31 = magnitude3 / v29 / 60

							while tick() - lastTime4 < v31 and folder2:GetAttribute("id") == v30 do
								local v32 = (tick() - lastTime4) / v31
								local v33 = cubicBezier(v32, position8, v27, v28, v24)
								folder2.CFrame = folder2.CFrame:Lerp(CFrame.new(v33, v24), v32)
								RunService.Heartbeat:Wait()
							end

							if folder2:GetAttribute("id") ~= v30 then
								return
							end

							for i, effect in pairs(folder2:GetDescendants()) do
								if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = false
								end
							end
						end
					end)()
				end

				if v3 == "Final" then
					for _, v4 in pairs(v2) do
						Util.Debris:AddItem(v4, 3)
					end

					v2 = nil
				elseif v3 == "Grab" then
					for _, v4 in pairs(v2) do
						Util.Debris:AddItem(v4, 5)
					end

					v2 = nil
				end
			end)()
			Dash(folder, root, cFrame)
			Util.Debris:AddItem(folder, 6)
		end
	end
end
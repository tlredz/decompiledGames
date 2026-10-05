local createVector = vector.create
local RunService = game:GetService("RunService")
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ghoulClawProjectile = script.GhoulClawProjectile
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
local magnitude = 120

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

local function StartClawSlash(folder, folder2, _)
	coroutine.wrap(function()
		task.wait(0.125)
		folder2.CFrame = folder.CFrame * CFrame.new(0, -5, -11)

		for _, emitter in pairs(folder2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end)()
	coroutine.wrap(function()
		for _, beam in pairs(folder:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Enabled = true
			local startDelay = beam:GetAttribute("StartDelay")
			local v = beam
			local v2 = beam:GetAttribute("EndDelay")
			coroutine.wrap(function()
				local tween = TweenService:Create(
					v,
					TweenInfo.new(v2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						Width0 = v.Width0,
						Width1 = v.Width1
					}
				)
				v.Width0 = 0
				v.Width1 = 0
				task.wait(startDelay)
				tween:Play()
				task.wait(v2)

				if v:IsDescendantOf(folder.Slash2) then
					task.wait(0.05)
				elseif v:IsDescendantOf(folder.Slash3) then
					task.wait(0.06)
				elseif v:IsDescendantOf(folder) and not (v:IsDescendantOf(folder.Slash3) or v:IsDescendantOf(folder.Slash2)) then
					task.wait(0.07)
				end

				local tween2 = TweenService:Create(
					v,
					TweenInfo.new(v2 / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween2:Play()
				tween2.Completed:Wait()
				v:Destroy()
			end)()
		end
	end)()
	local tween = TweenService:Create(
		folder.Weld,
		TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			C0 = folder.Weld.Part0.CFrame:ToObjectSpace(folder.Weld.Part1.CFrame) * CFrame.Angles(
				-2.6179938779914944,
				0,
				0
			)
		}
	)
	tween.Completed:Connect(function()
		if folder:FindFirstChild("Weld") then
			folder.Weld.Enabled = false
			folder.Anchored = true
			tween = TweenService:Create(folder, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				CFrame = folder.CFrame * CFrame.Angles(-1.3089969389957472, 0, 0)
			})
			tween:Play()
		end
	end)
	tween:Play()
end

local function StartProjectileSlash(folder, duration, magnitude2)
	coroutine.wrap(function()
		for _, beam in pairs(folder:GetDescendants()) do
			if beam:IsA("Beam") then
				beam.Enabled = true
			end
		end
	end)()
	local numberValue = Instance.new("NumberValue", folder)
	numberValue.Value = 0.5

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ScaleIt()
		folder.Parent:ScaleTo(numberValue.Value)
	end

	numberValue.Changed:Connect(ScaleIt)
	ScaleIt() -- equivalent call inferred; original call site unknown
	TweenService:Create(numberValue, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		Value = 1
	}):Play()
	local tween = TweenService:Create(
		folder,
		TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{
			CFrame = folder.CFrame * CFrame.new(0, 0, -magnitude2) * CFrame.Angles(0, 0, 0)
		}
	)
	tween:Play()
	tween.Completed:Wait()

	for _, effect in pairs(folder:GetDescendants()) do
		if effect:IsA("Beam") then
			local v = effect
			coroutine.wrap(function()
				v:GetAttribute("EndDelay")
				local tween2 = TweenService:Create(
					v,
					TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween2:Play()
				tween2.Completed:Wait()
				v:Destroy()
			end)()
		elseif effect:IsA("ParticleEmitter") then
			effect.Enabled = false
		end
	end
end

return function(state)
	local root = state.Root

	if not root then
		return
	end

	local arcDegrees = state.arcDegrees or 130
	local radius = state.radius or 300

	if state.Holding then
		if (workspace.CurrentCamera.CFrame.Position - root.Position).Magnitude > 1250 then
			return
		end

		local v = Util.Sound:Play("GenericDarkSkillCharge", root)
		local clone = ghoulClawProjectile.HoldHand:Clone()
		clone.CFrame = root.Parent.RightHand.CFrame
		clone.Parent = root.Parent
		clone.Weld.Part0 = root.Parent.RightHand
		local clone2 = ghoulClawProjectile.HoldHand:Clone()
		clone2.CFrame = root.Parent.LeftHand.CFrame
		clone2.Parent = root.Parent
		clone2.Weld.Part0 = root.Parent.LeftHand

		repeat
			wait()
		until state.Holding.Value == false or not state.Holding:IsDescendantOf(workspace)

		Util.Sound:FadeOut(v, 0.25)
		task.wait(0.1)

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = false
			elseif effect:IsA("Beam") then
				Util.BoatTween:Create(effect, {
					Time = 0.4,
					EasingStyle = "Sine",
					EasingDirection = "In",
					StepType = "Heartbeat",
					Goal = {
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(1, 1)
						})
					}
				}):Play()
			end
		end

		for _, effect in pairs(clone2:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = false
			elseif effect:IsA("Beam") then
				Util.BoatTween:Create(effect, {
					Time = 0.4,
					EasingStyle = "Sine",
					EasingDirection = "In",
					StepType = "Heartbeat",
					Goal = {
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(1, 1)
						})
					}
				}):Play()
			end
		end

		task.wait(0.8)
		clone:Destroy()
		clone2:Destroy()
	else
		local part2 = {
			CFrame = root.CFrame,
			Position = root.Position
		}

		if state.EndPosition then
			state.EndPosition = (CFrame.new(part2.Position, state.EndPosition) * CFrame.new(0, 0, -radius)).Position
		end

		local _, v2 = Util.RayMap(part2.Position, createVector(0, -100, 0))
		local v3 = v2 or part2.Position + createVector(0, -3, 0)
		local arcMesh = Util.ArcMesh.new(
			arcDegrees,
			radius,
			CFrame.new(v3, (Vector3.new(state.EndPosition.X, v3.Y, state.EndPosition.Z)))
		)
		local tweenTransparency = arcMesh:TweenTransparency(
			TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			0
		)
		tweenTransparency:Play()
		tweenTransparency.Completed:Wait()
		arcMesh:TweenTransparency(TweenInfo.new(0.1, Enum.EasingStyle.Linear), 1):Play()
		game.Debris:AddItem(arcMesh._meshPart, 1)
		local endPosition = state.EndPosition

		if (workspace.CurrentCamera.CFrame.Position - endPosition).Magnitude > 1250 then
			return
		end

		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 3.5)
		local cframe = CFrame.new(part2.CFrame.Position, endPosition)
		Util.Sound:Play("ScarletTearProjectile", cframe)
		local raycastParams = RaycastParams.new()
		raycastParams.IgnoreWater = false
		raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
		magnitude = (cframe.Position - endPosition).Magnitude

		for i = 1, 2 do
			local v4 = i
			coroutine.wrap(function()
				local v5 = nil
				local v6 = nil

				if v4 == 1 then
					v6 = 3
					v5 = -15
				elseif v4 == 2 then
					v6 = -3
					v5 = 15
				end

				local clone = ghoulClawProjectile.ClawSlash:Clone()
				local clone2 = ghoulClawProjectile.SlashHit:Clone()
				clone.CFrame = cframe * CFrame.new(v6, 0, 0)
				clone.Weld.Part0 = part2
				clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.Angles(
					0,
					0,
					(math.rad(v5))
				) * CFrame.Angles(2.9670597283903604, 0, 0)
				clone.Parent = folder
				clone2.Parent = folder
				StartClawSlash(clone, clone2, cframe)
			end)()
		end

		local v4 = cframe * CFrame.new(0, 0, -5).Position
		local rayMap, v5 = Util.RayMap(v4 + createVector(0, 1, 0), CFrame.new(v4).UpVector * -11)

		if rayMap and v5 then
			local clone = ghoulClawProjectile.GroundSlash:Clone()
			clone.CFrame = CFrame.new(v5, v5 + cframe.LookVector * createVector(1, 0, 1))
			clone.CFrame *= CFrame.new(0, 0.6, 0)
			clone.Parent = folder
			local parts = {}

			for _, part in pairs(clone:GetChildren()) do
				if not (part.Name == "GroundSlash" and part:IsA("BasePart")) then
					continue
				end

				table.insert(parts, part)
				local weld = part:FindFirstChildOfClass("Weld")

				if weld then
					weld.Part0 = nil
				end

				part.Anchored = true
			end

			for k, v6 in pairs(parts) do
				local v7 = math.random()
				local v8 = (k == 1 or k == #parts) and 0.5 or v7
				v6.CFrame = clone.CFrame * CFrame.Angles(
					0,
					math.rad(-arcDegrees / 2 + 5 * v8 - 2.5 + arcDegrees / #parts * (k - 1)),
					0
				) * CFrame.new(0, 0, -v6.Size.Z / 2)
			end

			local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

			for _, descendant in pairs(clone:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") then
					if descendant.Name == "Particle_1" and descendant.Parent.Name == "GroundSlash" then
						descendant.LockedToPart = true
					end

					local v6 = descendant
					coroutine.wrap(function()
						v6.Enabled = true
						task.wait(0.5)
						v6.Enabled = false
					end)()
				elseif descendant:IsA("Attachment") then
					local tween = TweenService:Create(descendant, tweenInfo, {
						Position = Vector3.new(0, 0, -radius / 2)
					})
					tween:Play()
					local v7 = descendant
					coroutine.wrap(function()
						tween.Completed:Wait()
						v7.Particle_1.Enabled = false
					end)()
				elseif descendant:IsA("BasePart") then
					local v6 = descendant
					coroutine.wrap(function()
						task.wait(0.1)
						v6.Anchored = true
						TweenService:Create(v6, tweenInfo, {
							Size = Vector3.new(v6.Size.X, v6.Size.Y, radius),
							CFrame = v6.CFrame * CFrame.new(0, 0, -radius / 2)
						}):Play()
					end)()
				elseif descendant:IsA("Weld") then
					local v6 = descendant
					task.delay(0.1, function()
						v6:Destroy()
					end)
				end
			end
		end

		task.wait(0.05)
		coroutine.wrap(function()
			task.wait(0.05)

			for _ = 1, 10 do
				coroutine.wrap(function()
					task.wait(0.005)
					local clone = ghoulClawProjectile.Trail:Clone()
					clone.CFrame = cframe * CFrame.new(
						math.random(-20, 20) / 1,
						math.random(-15, 15) * 1.5,
						math.random(-1, 1)
					)
					clone.Parent = folder

					for _, emitter in pairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end

					local position = clone.Position
					local v6 = cframe * CFrame.new(math.random(-15, 15), math.random(-15, 15) * 1.5, -magnitude).Position
					local magnitude2 = (position - v6).Magnitude
					clone.CFrame = CFrame.new(position, v6)
					local v7 = (position - v6) / 2
					local position2 = CFrame.new(CFrame.new(position) * (v7 / -1.5)).Position
					local position3 = CFrame.new(CFrame.new(v6) * (v7 / 1.5)).Position
					local v8 = magnitude2 / 12
					local v9 = position2 + Vector3.new(
						math.random(-v8, v8),
						math.random(-3, 8) * 3,
						math.random(-v8, v8)
					)
					local v10 = position3 + Vector3.new(
						math.random(-v8, v8),
						math.random(-3, 8) * 3,
						math.random(-v8, v8)
					)
					local v11 = math.random(12, 20) / 1.15
					local lastTime = tick()
					local v12 = magnitude2 / v11 / 60

					while tick() - lastTime < v12 do
						local v13 = (tick() - lastTime) / v12
						local v14 = cubicBezier(v13, position, v9, v10, v6)
						clone.CFrame = clone.CFrame:Lerp(CFrame.new(v14, v6), v13)
						RunService.Heartbeat:Wait()
					end

					for _, emitter in pairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					Util.Debris:AddItem(clone, 1)
				end)()
			end
		end)()
		local clone = ghoulClawProjectile.StartImpact:Clone()
		clone.CFrame = cframe * CFrame.new(0, 0, -5)
		clone.Parent = folder
		Util.Debris:AddItem(clone, 1)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local v6 = radius * 2 * math.sin(math.rad(arcDegrees) / 2) / 10
		task.wait(0.07)
		local clone2 = ghoulClawProjectile.ProjectileSlash:Clone()

		for _, descendant in pairs(clone2:GetDescendants()) do
			if descendant:IsA("Beam") then
				descendant.CurveSize0 *= v6
				descendant.CurveSize1 *= v6
				descendant.Width0 *= v6 * 1.5
				descendant.Width1 *= v6 * 1.5
			elseif descendant:IsA("Attachment") then
				descendant.Position = Vector3.new(
					descendant.Position.X * v6,
					descendant.Position.Y * v6,
					descendant.Position.Z * v6
				)
			elseif descendant:IsA("ParticleEmitter") then
				descendant.Enabled = true
			end
		end

		clone2.CFrame = cframe * CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0)
		clone2.Parent = Instance.new("Model", folder)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				task.delay(0.016666666666666666, function() end)
			end
		end

		StartProjectileSlash(clone2, 0.25, magnitude)
	end
end
local createVector = vector.create
local _ = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local FX = require(game.ReplicatedStorage.FX)
local angelGrab = FX:WaitForChild("Angel").AngelGrab
local Effect = require(game.ReplicatedStorage.Effect)
local Util = require(game.ReplicatedStorage.Util)
local cameraShaker = Util.CameraShaker
local WrapHighlight = require(game.ReplicatedStorage.Util.WrapHighlight)
local _WorldOrigin = workspace._WorldOrigin

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

local function TornadoSlash(folder, data)
	local multiplier = data.Multiplier
	local multiplier2 = data.Multiplier2
	local mutliplier2Time = data.Mutliplier2Time
	local beamOutTime = data.BeamOutTime
	local slashAngle = data.SlashAngle
	local slashAngle2 = data.SlashAngle2
	local slashType = data.SlashType
	local slashCFrame = data.SlashCFrame
	local slashSpeed = data.SlashSpeed
	local slashSpeed2 = data.SlashSpeed2
	local spinIterations = data.SpinIterations
	local clone = slashType:Clone()
	clone.CFrame = slashCFrame
	clone.Parent = folder

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("Beam") then
			descendant.CurveSize0 *= multiplier
			descendant.CurveSize1 *= multiplier
			descendant.Width0 *= multiplier
			descendant.Width1 *= multiplier
		elseif descendant:IsA("Attachment") then
			descendant.Position = Vector3.new(
				descendant.Position.X * multiplier,
				descendant.Position.Y * multiplier,
				descendant.Position.Z * multiplier
			)
		end
	end

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("Beam") then
			descendant.Enabled = true
			local v = descendant
			task.spawn(function()
				local tween = TweenService:Create(
					v,
					TweenInfo.new(mutliplier2Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						CurveSize0 = v.CurveSize0 * multiplier2,
						CurveSize1 = v.CurveSize1 * multiplier2,
						Width0 = v.Width0 * multiplier2,
						Width1 = v.Width1 * multiplier2
					}
				)
				v.Width0 = 0
				v.Width1 = 0
				tween:Play()
			end)
		elseif descendant:IsA("Attachment") then
			TweenService:Create(
				descendant,
				TweenInfo.new(mutliplier2Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					Position = Vector3.new(
						descendant.Position.X * multiplier2,
						descendant.Position.Y * multiplier2,
						descendant.Position.Z * multiplier2
					)
				}
			):Play()
		end
	end

	for _ = 1, spinIterations do
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(slashSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				CFrame = clone.CFrame * slashAngle
			}
		)
		tween:Play()
		tween.Completed:Wait()
	end

	for _, beam in pairs(clone:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		local v = beam
		task.spawn(function()
			local tween = TweenService:Create(
				v,
				TweenInfo.new(beamOutTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Width0 = 0,
					Width1 = 0
				}
			)
			tween:Play()
			tween.Completed:Wait()
			v:Destroy()
		end)
	end

	TweenService:Create(clone, TweenInfo.new(slashSpeed2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		CFrame = clone.CFrame * slashAngle2
	}):Play()
end

local function ExplosionTrail(instance, position)
	local position2 = instance.Position
	local magnitude = (position2 - position).Magnitude
	instance.CFrame = CFrame.new(position2, position)
	local v = (position2 - position) / 2
	local position3 = CFrame.new(CFrame.new(position2) * (v / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position) * (v / 1.5)).Position
	local v2 = math.random(7, 15)
	local v3 = position3 + Vector3.new(math.random(-v2, v2), math.random(-v2, v2), math.random(-v2, v2))
	local v4 = position4 + Vector3.new(math.random(-v2, v2), math.random(-v2, v2), math.random(-v2, v2))
	local v5 = math.random(10, 25) / 10
	local lastTime = tick()
	local v6 = magnitude / v5 / 60

	while tick() - lastTime < v6 do
		local v7 = (tick() - lastTime) / v6
		local v8 = cubicBezier(v7, position2, v3, v4, position)
		instance.CFrame = instance.CFrame:Lerp(CFrame.new(v8, position), v7)
		RunService.Heartbeat:Wait()
	end
end

local function DashTrail(instance, position)
	local position2 = instance.Position
	local magnitude = (position2 - position).Magnitude
	instance.CFrame = CFrame.new(position2, position)
	local v = (position2 - position) / 2
	local position3 = CFrame.new(CFrame.new(position2) * (v / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position) * (v / 1.5)).Position
	local v2 = math.random(30, 50)
	local v3 = position3 + Vector3.new(math.random(-v2, v2), math.random(-2, 2), math.random(-v2, v2))
	local v4 = position4 + Vector3.new(math.random(-v2, v2), math.random(-2, 2), math.random(-v2, v2))
	local v5 = math.random(5, 7)
	local lastTime = tick()
	local v6 = magnitude / v5 / 60

	while tick() - lastTime < v6 do
		local v7 = (tick() - lastTime) / v6
		local v8 = cubicBezier(v7, position2, v3, v4, position)
		instance.CFrame = instance.CFrame:Lerp(CFrame.new(v8, position), v7)
		RunService.Heartbeat:Wait()
	end
end

local v = {
	Head = true,
	UpperTorso = true,
	LowerTorso = true,
	RightUpperArm = true,
	RightLowerArm = true,
	LeftUpperArm = true,
	LeftLowerArm = true,
	RightUpperLeg = true,
	RightLowerLeg = true,
	LeftUpperLeg = true,
	LeftLowerLeg = true,
	RightHand = true,
	LeftHand = true,
	RightFoot = true,
	LeftFoot = true,
	HumanoidRootPart = true
}

local function CloneBody(folder, enemyRoot, root, p)
	local cframe = CFrame.new(Vector3.new(enemyRoot.Position.X, root.Position.Y, enemyRoot.Position.Z), root.Position)

	local function BodyPartTweens(folder2)
		local cFrame = folder2.HumanoidRootPart.CFrame

		for _, part in pairs(folder2:GetDescendants()) do
			if not (part:IsA("BasePart") or part:IsA("MeshPart")) then
				continue
			end

			if part.Name == "HumanoidRootPart" then
				part:Destroy()
			else
				part.Anchored = true
				part.CanCollide = false
				part.CanTouch = false
				part.Material = Enum.Material.Neon
				part.Color = Color3.fromRGB(204, 179, 104)
				local v2 = part
				task.spawn(function()
					local tween = TweenService:Create(
						v2,
						TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = v2.Transparency
						}
					)
					v2.Transparency = 1
					tween:Play()
					tween.Completed:Wait()
					task.wait(0.7 + p)
					TweenService:Create(v2, TweenInfo.new(0.05, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
				end)
			end
		end

		local clone_2 = WrapHighlight(angelGrab.Highlight):Clone()
		clone_2.Parent = folder2
		local clone = angelGrab.CloneAura:Clone()
		clone.CFrame = cFrame
		clone.Parent = folder

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end

		local attachment = clone.Attachment
		attachment.Parent = folder2.UpperTorso
		clone.Attach_0A.Parent = enemyRoot
		local clone2 = angelGrab.ChainBreak:Clone()
		local magnitude = (folder2.UpperTorso.Position - cframe.Position).Magnitude
		clone2.Size = Vector3.new(0.001, 0.001, magnitude)
		clone2.CFrame = CFrame.new(folder2.UpperTorso.Position, cframe.Position) * CFrame.new(0, 0, -magnitude / 2)
		clone2.Parent = folder

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		task.wait(0.4 + p)

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = false
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end

		task.wait(0.3)

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = true
				effect:Emit(effect:GetAttribute("EmitCount"))
			elseif effect:IsA("Beam") then
				TweenService:Create(effect, TweenInfo.new(0.15), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end
		end

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		task.wait(0.2)
		attachment:Destroy()

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = false
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	task.spawn(function()
		for i = 1, 2 do
			local model = Instance.new("Model")

			for _, child in pairs(root.Parent:GetChildren()) do
				if not v[child.Name] then
					continue
				end

				local clone = child:Clone()
				clone:ClearAllChildren()
				clone.Parent = model
			end

			model.PrimaryPart = model.HumanoidRootPart
			model.Parent = folder
			Util.Debris:AddItem(model, 1.5 + p)
			local v2 = CFrame.new(cframe * CFrame.new(5 * (i == 1 and 1 or -1), 0, 0).Position, cframe.Position) * CFrame.new(
				0,
				0,
				10
			)

			if i == 1 then
				model:SetPrimaryPartCFrame(v2)
			elseif i == 2 then
				model:SetPrimaryPartCFrame(v2)
			end

			task.spawn(function()
				BodyPartTweens(model)
			end)
		end
	end)
end

local function Hakai(enemyRoot, folder)
	local hakaiAura = angelGrab.HakaiAura
	local cFrame = enemyRoot.CFrame
	local clone = angelGrab.StartImpact:Clone()
	clone.CFrame = CFrame.new(cFrame.Position)
	clone.Parent = folder

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v2 = emitter
		task.spawn(function()
			if v2:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v2:GetAttribute("EmitDelay"))
			end

			v2:Emit(v2:GetAttribute("EmitCount"))
		end)
	end

	for _, descendant in pairs(enemyRoot.Parent:GetDescendants()) do
		if descendant:IsA("BasePart") or descendant:IsA("MeshPart") then
			if descendant.Name ~= "HumanoidRootPart" then
				local v2

				if descendant.Name == "Head" then
					v2 = 0.05
				elseif descendant.Name == "RightUpperArm" or descendant.Name == "LeftUpperArm" then
					v2 = 0.1
				elseif descendant.Name == "UpperTorso" then
					v2 = 0.15
				elseif descendant.Name == "RightLowerArm" or descendant.Name == "LeftLowerArm" then
					v2 = 0.2
				elseif descendant.Name == "LowerTorso" then
					v2 = 0.25
				elseif descendant.Name == "RightUpperLeg" or descendant.Name == "LeftUpperLeg" then
					v2 = 0.3
				elseif descendant.Name == "RightLowerLeg" or descendant.Name == "LeftLowerLeg" then
					v2 = 0.35
				elseif descendant.Name == "RightFoot" or descendant.Name == "LeftFoot" then
					v2 = 0.4
				else
					descendant:Destroy()
					continue
				end

				descendant:ClearAllChildren()
				descendant.Material = Enum.Material.Neon
				TweenService:Create(descendant, TweenInfo.new(0.25), {
					Color = Color3.fromRGB(255, 146, 83)
				}):Play()

				for _, emitter in pairs(hakaiAura:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local clone2 = emitter:Clone()
					clone2.Parent = descendant
					local v3 = descendant
					task.spawn(function()
						TweenService:Create(v3, TweenInfo.new(v2 * 2 + 1.25), {
							CFrame = v3.CFrame * CFrame.Angles(
								math.random() - 0.5,
								math.random() - 0.5,
								math.random() - 0.5
							) + Vector3.new(math.random() - 0.5, math.random() + 0.5, math.random() - 0.5) * 9
						}):Play()
						task.wait(v2 * 2)
						clone2.Enabled = true

						if clone2:GetAttribute("Funky") then
							task.spawn(function()
								task.wait(1.25)

								for i = 1, 25 do
									clone2.Acceleration = Vector3.new(
										math.random(-50, 50) / 2,
										math.random(-50, 50) / 2,
										math.random(-50, 50) / 2
									)
									task.wait(math.random(10, 20) / 200)
								end

								clone2.Acceleration = Vector3.new(
									math.random(-5, 5),
									math.random(-5, 5),
									math.random(-5, 5)
								)
							end)
						end

						task.wait(1)
						TweenService:Create(v3, TweenInfo.new(0.25), {
							Transparency = 1
						}):Play()
						clone2.Enabled = false
						Util.Debris:AddItem(clone2, 3)
					end)
				end

				descendant.Anchored = true
			end
		elseif not descendant:IsA("Decal") then
			if descendant:IsA("Accessory") then
				descendant:Destroy()
			elseif descendant:IsA("Shirt") or descendant:IsA("Pants") then
				descendant:Destroy()
			end
		end
	end

	task.spawn(function()
		local clone2 = angelGrab.HakaiImpact:Clone()
		clone2.CFrame = cFrame
		clone2.Parent = folder

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function LightningTick(part, parent)
	task.spawn(function()
		local clone = angelGrab.LightningTick:Clone()
		clone.CFrame = part.CFrame
		clone.Parent = parent
		clone.Weld.Part0 = part

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		task.wait(2)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
end

local function GrabExplosion(cFrame, root, folder, enemyRoot, explosionPos)
	local clone = angelGrab.GrabExplosion:Clone()
	clone.CFrame = root.CFrame * CFrame.new(0, 0, -2)
	clone.Parent = folder

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v2 = emitter
		task.spawn(function()
			if v2:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v2:GetAttribute("EmitDelay"))
			end

			v2:Emit(v2:GetAttribute("EmitCount"))
		end)
	end

	task.wait(0.2)
	task.spawn(function()
		enemyRoot.Anchored = true
		local cframe = CFrame.new(enemyRoot.Position, explosionPos)
		local magnitude = (explosionPos - enemyRoot.Position).Magnitude
		local lastTime = os.clock()

		while os.clock() - lastTime < 0.15 do
			local v2 = (os.clock() - lastTime) / 0.15
			enemyRoot.CFrame = cframe * CFrame.new(0, 0, -magnitude * v2 ^ 1.4) * CFrame.Angles(0, 3.141592653589793, 0)
			RunService.PreSimulation:Wait()
		end

		enemyRoot.CFrame = cframe * CFrame.new(0, 0, -magnitude) * CFrame.Angles(0, 3.141592653589793, 0)
		enemyRoot.Anchored = false
	end)
	local cframe = CFrame.new(explosionPos, explosionPos + cFrame.LookVector)
	local cFrame2 = cFrame * CFrame.new(0, 0, 5)
	local clone2 = angelGrab.ThunderBolt:Clone()
	clone2.CFrame = cFrame2
	clone2.Parent = folder

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local tween = TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		CFrame = cframe
	})
	tween:Play()
	task.spawn(function()
		local clone3 = angelGrab.TeleportTrail:Clone()
		clone3.CFrame = cFrame2
		clone3.Parent = folder
		TweenService:Create(clone3, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			CFrame = cframe
		}):Play()
		task.wait(0.13)

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
	local clone3 = angelGrab.ProjectileStartImpact:Clone()
	clone3.CFrame = clone2.CFrame
	clone3.Parent = folder

	for _, emitter in pairs(clone3:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v3 = emitter
		task.spawn(function()
			if v3:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v3:GetAttribute("EmitDelay"))
			end

			v3:Emit(v3:GetAttribute("EmitCount"))
		end)
	end

	tween.Completed:Wait()

	for _, effect in pairs(clone2:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
			effect.Enabled = false
		end
	end

	local clone4 = angelGrab.ProjectileExplosion:Clone()
	clone4.CFrame = clone2.CFrame
	clone4.Parent = folder

	for _, emitter in pairs(clone4:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v3 = emitter
		task.spawn(function()
			if v3:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v3:GetAttribute("EmitDelay"))
			end

			v3:Emit(v3:GetAttribute("EmitCount"))
		end)
	end

	local clone5 = angelGrab.ProjectileExplosion2:Clone()
	clone5.CFrame = clone2.CFrame
	clone5.Parent = folder

	for _, emitter in pairs(clone5:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	LightningTick(enemyRoot, folder) -- equivalent call inferred; original call site unknown
	task.wait(0.75)

	for _, emitter in pairs(clone5:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end
end

local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
return function(data)
	local root = data.Root

	if (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 900 then
		return
	end

	if data.Holding then
		local v2 = math.min(9.5, root.Size.Y * 0.5 + root.Parent.Humanoid.HipHeight)
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		local clone = angelGrab.HoldAura:Clone()
		clone.CFrame = root.CFrame
		clone.Parent = folder
		clone.Weld.Part0 = root
		clone.Weld.C0 = CFrame.new(0, -v2 + 2.31, 1) * CFrame.Angles(0, 0, 1.5707963267948966)

		repeat
			task.wait()
		until not (data.Holding and data.Holding.Value and data.Holding:IsDescendantOf(workspace))

		clone:Destroy()
		Util.Debris:AddItem(folder, 1)
	else
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 7)
		local cFrame = root.CFrame
		local cFrame2 = data.CFrame
		task.spawn(function()
			task.wait(0.05)
			local clone = angelGrab.StartImpact:Clone()
			clone.CFrame = cFrame
			clone.Parent = folder

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v2 = emitter
				task.spawn(function()
					if v2:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v2:GetAttribute("EmitDelay"))
					end

					v2:Emit(v2:GetAttribute("EmitCount"))
				end)
			end
		end)
		root.CFrame = cFrame2
		local clone = angelGrab.TeleportImpact:Clone()
		clone.CFrame = cFrame2
		clone.Parent = folder

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v2 = emitter
			task.spawn(function()
				if v2:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v2:GetAttribute("EmitDelay"))
				end

				v2:Emit(v2:GetAttribute("EmitCount"))
			end)
		end

		task.spawn(function()
			local slashCFrame = cFrame2 * CFrame.new(0, -0.5, 0)
			TornadoSlash(folder, {
				Multiplier = 0.5,
				Multiplier2 = 1.85,
				Mutliplier2Time = 0.125,
				BeamOutTime = 0.25,
				SlashAngle = CFrame.Angles(0, -2.9670597283903604, 0),
				SlashAngle2 = CFrame.Angles(0, -2.9670597283903604, 0),
				SlashType = angelGrab.BeamSlash,
				SlashCFrame = slashCFrame,
				SlashSpeed = 0.07,
				SlashSpeed2 = 0.75,
				SpinIterations = 5
			})
		end)
		task.spawn(function()
			local slashCFrame = cFrame2 * CFrame.new(0, 15, 0)
			TornadoSlash(folder, {
				Multiplier = 0.5,
				Multiplier2 = 1.3,
				Mutliplier2Time = 0.125,
				BeamOutTime = 0.35,
				SlashAngle = CFrame.Angles(0, 2.9670597283903604, 0),
				SlashAngle2 = CFrame.Angles(0, 1.7453292519943295, 0),
				SlashType = angelGrab.BeamSlash,
				SlashCFrame = slashCFrame,
				SlashSpeed = 0.075,
				SlashSpeed2 = 0.75,
				SpinIterations = 3
			})
		end)
		task.spawn(function()
			task.wait(0.1)
			local raycastResult = workspace:Raycast(
				cFrame2.Position + createVector(0, 1, 0),
				CFrame.new(cFrame2.Position).UpVector * -10,
				raycastParams
			)

			if raycastResult then
				local clone2 = angelGrab.TeleportGroundCrack:Clone()
				clone2.CFrame = CFrame.new(raycastResult.Position + createVector(0, 0.5, 0))
				clone2.Parent = folder

				for _, emitter in pairs(clone2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					if emitter:GetAttribute("Color") then
						emitter.Color = ColorSequence.new(raycastResult.Instance.Color, raycastResult.Instance.Color)
					end

					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end)
		local enemyRoot = data.EnemyRoot

		if enemyRoot then
			local clone2 = angelGrab.GrabImpact:Clone()
			clone2.CFrame = root.CFrame * CFrame.new(0, 0, -3)
			clone2.Parent = folder

			for _, emitter in pairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v2 = emitter
				coroutine.wrap(function()
					if v2:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v2:GetAttribute("EmitDelay"))
					end

					v2:Emit(v2:GetAttribute("EmitCount"))
				end)()
			end

			local clone3 = angelGrab.GrabImpact2:Clone()
			clone3.CFrame = clone3.CFrame
			clone3.Weld.Part0 = enemyRoot
			clone3.Parent = folder

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			task.spawn(function()
				task.wait(0.1)
				CloneBody(folder, enemyRoot, root, data.Hakai and 1 or 0)
			end)
			coroutine.wrap(function()
				local lastTime = os.clock()

				repeat
					coroutine.wrap(function()
						local position = clone3.Position
						local clone4 = angelGrab.GrabTrail:Clone()
						clone4.CFrame = clone3.CFrame * CFrame.new(
							math.random(-25, 25),
							math.random(2, 10),
							math.random(-25, 25)
						)
						clone4.Parent = folder
						local position2 = clone4.Position
						local magnitude = (position2 - position).Magnitude
						clone4.CFrame = CFrame.new(position2, position)
						local v2 = (position2 - position) / 2
						local position3 = CFrame.new(CFrame.new(position2) * (v2 / -1.5)).Position
						local position4 = CFrame.new(CFrame.new(position) * (v2 / 1.5)).Position
						local halfMagnitude = magnitude / 2
						local v4 = position3 + Vector3.new(
							math.random(-halfMagnitude, halfMagnitude),
							math.random(-3, 8) * 2,
							math.random(-halfMagnitude, halfMagnitude)
						)
						local v5 = position4 + Vector3.new(
							math.random(-halfMagnitude, halfMagnitude),
							math.random(-3, 8) * 2,
							math.random(-halfMagnitude, halfMagnitude)
						)
						local v6 = math.random(10, 15) / 10
						local lastTime2 = tick()
						local v7 = magnitude / v6 / 60

						while tick() - lastTime2 < v7 do
							local v8 = (tick() - lastTime2) / v7
							local v9 = cubicBezier(v8, position2, v4, v5, position)
							clone4.CFrame = clone4.CFrame:Lerp(CFrame.new(v9, position), v8)
							RunService.Heartbeat:Wait()
						end

						for _, emitter in pairs(clone4:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						Util.Debris:AddItem(clone4, 1)
					end)()
					task.wait(0.05)
				until os.clock() - lastTime >= 0.35
			end)()
			task.spawn(function()
				local slashCFrame = cFrame2 * CFrame.Angles(1.5707963267948966, 0, 0)
				TornadoSlash(folder, {
					Multiplier = 0.35,
					Multiplier2 = 1.7,
					Mutliplier2Time = 0.125,
					BeamOutTime = 0.25,
					SlashAngle = CFrame.Angles(0, -1.7453292519943295, 0),
					SlashAngle2 = CFrame.Angles(0, -2.9670597283903604, 0),
					SlashType = angelGrab.BeamSlash,
					SlashCFrame = slashCFrame,
					SlashSpeed = 0.07,
					SlashSpeed2 = 0.75,
					SpinIterations = 5
				})
			end)

			if data.Hakai then
				local clone4 = angelGrab.PreHakaiImpact:Clone()
				clone4.CFrame = enemyRoot.CFrame
				clone4.Weld.Part0 = enemyRoot
				clone4.Parent = folder

				for _, emitter in pairs(clone4:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					if emitter.Name == "Star" then
						emitter.Size = NumberSequence.new(35, 0)
						local v2 = emitter
						task.delay(1.8, function()
							v2:Emit(1)
						end)
					else
						emitter:Emit(5)
					end
				end

				task.delay(1.5, function()
					for _, emitter in pairs(clone4:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end)

				if enemyRoot.Parent == game.Players.LocalPlayer.Character or root.Parent == game.Players.LocalPlayer.Character then
					task.spawn(function()
						Effect.new("ColorCorrection"):replicate({
							TintColor = Color3.fromRGB(255, 255, 255),
							Brightness = 0,
							Saturation = -0.8,
							Contrast = 0.2,
							FadeIn = 1.9,
							FadeOut = 0.1,
							Lifetime = 0
						})
					end)
					task.spawn(function()
						for _ = 1, 19 do
							cameraShaker:ShakeOnce(4, 4, 0.15, 0.2)
							task.wait(0.1)
						end
					end)
				end
			else
				local clone4 = angelGrab.ThunderBoltHand:Clone()
				clone4.CFrame = root.Parent.RightHand.CFrame
				clone4.Weld.Part0 = root.Parent.RightHand
				clone4.Parent = folder
				task.delay(1.2, function()
					for _, emitter in pairs(clone4:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						emitter.Enabled = false
						emitter:Clear()
					end
				end)
				local clone5 = angelGrab.ThunderBoltHand:Clone()
				clone5.CFrame = root.Parent.LeftHand.CFrame
				clone5.Weld.Part0 = root.Parent.LeftHand
				clone5.Parent = folder
				task.delay(1.2, function()
					for _, emitter in pairs(clone5:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						emitter.Enabled = false
						emitter:Clear()
					end
				end)
			end

			task.wait(data.Hakai and 1.7 or 1)
			pcall(function()
				clone3.Weld:Destroy()
			end)
			clone3.Anchored = true

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			if data.Hakai then
				task.wait(0.2)

				if enemyRoot.Parent == game.Players.LocalPlayer.Character or root.Parent == game.Players.LocalPlayer.Character then
					local currentCamera = workspace.CurrentCamera
					task.spawn(function()
						local angelC = FX:WaitForChild("Angel").AngelC
						task.spawn(function()
							cameraShaker:ShakeOnce(14, 8, 0.15, 0.2)
							local clone4 = angelC.Phase2.ScreenColor1:Clone()
							clone4.Parent = currentCamera
							local tween = TweenService:Create(clone4, TweenInfo.new(0.05), {
								Brightness = clone4.Brightness,
								Contrast = clone4.Contrast,
								Saturation = clone4.Saturation,
								TintColor = clone4.TintColor
							})
							clone4.Brightness = 0
							clone4.Contrast = 0
							clone4.Saturation = 0
							clone4.TintColor = Color3.fromRGB(255, 255, 255)
							tween:Play()
							tween.Completed:Wait()
							local tween2 = TweenService:Create(clone4, TweenInfo.new(0.1), {
								TintColor = Color3.fromRGB(255, 255, 255),
								Brightness = 0,
								Contrast = 0,
								Saturation = 0
							})
							tween2:Play()
							tween2.Completed:Wait()
							clone4:Destroy()
						end)
						task.spawn(function()
							local clone4 = angelC.Phase2.Bloom:Clone()
							clone4.Parent = game.Lighting
							local tween = TweenService:Create(clone4, TweenInfo.new(0.1), {
								Size = 40,
								Threshold = 0.25
							})
							tween:Play()
							tween.Completed:Wait()
							local tween2 = TweenService:Create(clone4, TweenInfo.new(0.25), {
								Size = 8,
								Threshold = 2
							})
							tween2:Play()
							tween2.Completed:Wait()
							clone4:Destroy()
						end)
					end)
				end

				Hakai(enemyRoot, folder)
			else
				if enemyRoot.Parent == game.Players.LocalPlayer.Character or root.Parent == game.Players.LocalPlayer.Character then
					cameraShaker:ShakeOnce(14, 8, 0.15, 0.2)
				end

				GrabExplosion(cFrame2, root, folder, enemyRoot, data.ExplosionPos)
			end
		end
	end
end
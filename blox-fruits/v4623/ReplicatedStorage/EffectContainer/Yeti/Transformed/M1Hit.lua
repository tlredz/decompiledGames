local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local Spikes = require(script.Parent.Parent.Modules.Spikes)

local function emitAll(folder)
	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam")) then
			continue
		end

		if effect:IsA("Beam") then
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v = effect:GetAttribute("EmitDuration")
			local v2 = effect
			task.delay(tonumber(emitDelay) or 0, function()
				if tonumber(v) and v ~= 0 then
					v2.Enabled = true

					if not v2:GetAttribute("pr3") then
						v2:SetAttribute("pr3", 0)
					end

					local v3 = (v2:GetAttribute("pr3") + 1) % 1000
					v2:SetAttribute("pr3", v3)
					task.wait(v)

					if v3 == v2:GetAttribute("pr3") then
						v2.Enabled = false
					end
				end
			end)
		else
			local emitCount = effect:GetAttribute("EmitCount")
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v = effect
			local v3 = effect:GetAttribute("EmitDuration")
			task.delay(tonumber(emitDelay) or 0, function()
				v:Emit(emitCount or 0)

				if tonumber(v3) and v3 ~= 0 then
					v.Enabled = true

					if not v:GetAttribute("pr3") then
						v:SetAttribute("pr3", 0)
					end

					local v4 = (v:GetAttribute("pr3") + 1) % 1000
					v:SetAttribute("pr3", v4)
					task.wait(v3)

					if v4 == v:GetAttribute("pr3") then
						v.Enabled = false
					end
				end
			end)
		end
	end
end

local FX = require(ReplicatedStorage.FX)
local m1s = FX:WaitForChild("YetiEffects").M1s
Util.ResizeModel(m1s.M1SlamAir, 2)
Util.ResizeModel(m1s.floor, 2)

local function mockPart(instance)
	local part = Instance.new("Part")
	part.Size = instance.Size
	part.CFrame = instance.CFrame
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.Parent = _WorldOrigin
	Util.Debris:AddItem(part, 4)
	return part
end

local function hit(player, plr, hrp, _, _, stage)
	local function BasicSlash(folder)
		task.spawn(function()
			for _, beam in pairs(folder:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				beam.Enabled = true
				local v = beam:GetAttribute("StartDelay") / 2
				local v3 = beam
				local v4 = beam:GetAttribute("EndDelay") / 2
				task.spawn(function()
					local tween = TweenService:Create(
						v3,
						TweenInfo.new(v4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							Width0 = v3.Width0,
							Width1 = v3.Width1
						}
					)
					v3.Width0 = 0
					v3.Width1 = 0
					task.wait(v)
					tween:Play()
					task.wait(v4)
					local tween2 = TweenService:Create(
						v3,
						TweenInfo.new(v4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Width0 = 0,
							Width1 = 0
						}
					)
					tween2:Play()
					tween2.Completed:Wait()
					v3:Destroy()
				end)
			end
		end)
		local tween = TweenService:Create(
			folder.Weld,
			TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				C0 = folder.Weld.Part0.CFrame:ToObjectSpace(folder.Weld.Part1.CFrame) * CFrame.Angles(
					-2.6179938779914944,
					0,
					0
				)
			}
		)
		tween:Play()
		tween.Completed:Wait()
		folder.Weld.Enabled = false
		folder.Anchored = true
		TweenService:Create(folder, TweenInfo.new(0.075, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			CFrame = folder.CFrame * CFrame.Angles(-1.3089969389957472, 0, 0)
		}):Play()
	end

	if stage == 1 then
		Util.Sound:Play("YETI_TNSFM_M1_Slash_01", hrp)
		local part = Instance.new("Part")
		part.Size = hrp.Size
		part.CFrame = hrp.CFrame
		part.Transparency = 1
		part.Anchored = true
		part.CanCollide = false
		part.Parent = _WorldOrigin
		Util.Debris:AddItem(part, 4)
		task.wait(0.185)

		if hrp.Parent == game.Players.LocalPlayer.Character then
			Util.CameraShaker:ShakeOnce(6, 5, 0.05, 0.4, createVector(0.7, 0.7, 0.7), createVector(0.7, 0.7, 0.7))
		end

		local cFrame = hrp.CFrame
		local cframe = CFrame.Angles(0, 0, -0.6108652381980153)
		local cframe2 = CFrame.Angles(-2.9670597283903604, 0, 0)
		local _ = hrp.CFrame * cframe
		local _ = hrp.CFrame * CFrame.new(0, 0, -9) * cframe
		local clone = m1s.ClawPart1:Clone()
		clone.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone, 1.5)
		clone.Weld.Part0 = hrp
		clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * cframe * cframe2 * CFrame.new(
			5,
			0,
			6
		)
		BasicSlash(clone)
		emitAll(clone)
		part.CFrame = hrp.CFrame * CFrame.new(3, 5, -5)

		if (workspace.CurrentCamera.CFrame.p - part.Position).Magnitude <= 30 then
			Util.CameraShaker:ShakeOnce(8, 8, 0.1, 0.42, createVector(-0.7, 0.2, 0.1), createVector(0.5, 0.5, 0.5))
		end

		local ray = Util.Ray
		local v = part.Position + createVector(0, 1, 0)
		local v2 = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
		local v3, _, _ = ray(v, createVector(-0, -32, -0), v2)

		if v3 ~= nil then
			local clone2 = m1s.Shocks.M1Shocks:Clone()
			Util.SetParentOverrideWithColor(clone2, part, player, "YetiFruitVFXColor")
			emitAll(clone2)
			local clone3 = m1s.floor:Clone()

			for _, child in pairs(clone3:GetChildren()) do
				if child.Name ~= "scratchL" then
					continue
				end

				Util.SetParentOverrideWithColor(child, part, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(child, 2)
				emitAll(child)
			end
		end
	elseif stage == 2 then
		Util.Sound:Play("YETI_TNSFM_M1_Slash_02", hrp)
		local part = Instance.new("Part")
		part.Size = hrp.Size
		part.CFrame = hrp.CFrame
		part.Transparency = 1
		part.Anchored = true
		part.CanCollide = false
		part.Parent = _WorldOrigin
		Util.Debris:AddItem(part, 4)
		task.wait(0.185)

		if hrp.Parent == game.Players.LocalPlayer.Character then
			Util.CameraShaker:ShakeOnce(6, 5, 0.05, 0.4, createVector(0.7, 0.7, 0.7), createVector(0.7, 0.7, 0.7))
		end

		local cFrame = hrp.CFrame
		local cframe = CFrame.Angles(0, 0, 0.6108652381980153)
		local cframe2 = CFrame.Angles(2.9670597283903604, 0, 0)
		local _ = hrp.CFrame * cframe
		local _ = hrp.CFrame * CFrame.new(0, 0, -9) * cframe
		local clone = m1s.ClawPart1:Clone()
		clone.CFrame = cFrame * CFrame.new(0, 0, -15)
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone, 1.5)
		clone.Weld.Part0 = hrp
		clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * cframe * cframe2 * CFrame.new(
			-5,
			0,
			6
		)
		emitAll(clone)
		BasicSlash(clone)
		part.CFrame = hrp.CFrame * CFrame.new(-3, 5, -5)

		if (workspace.CurrentCamera.CFrame.p - part.Position).Magnitude <= 30 then
			Util.CameraShaker:ShakeOnce(8, 8, 0.1, 0.42, createVector(0.7, 0.2, 0.1), createVector(0.5, 0.5, 0.5))
		end

		local ray = Util.Ray
		local v = part.Position + createVector(0, 1, 0)
		local v2 = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
		local v3, _, _ = ray(v, createVector(-0, -32, -0), v2)

		if v3 then
			local clone2 = m1s.Shocks.M1Shocks:Clone()
			Util.SetParentOverrideWithColor(clone2, part, player, "YetiFruitVFXColor")
			emitAll(clone2)
			local clone3 = m1s.floor:Clone()

			for _, child in pairs(clone3:GetChildren()) do
				if child.Name ~= "scratchR" then
					continue
				end

				Util.SetParentOverrideWithColor(child, part, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(child, 2)
				emitAll(child)
			end
		end
	elseif stage == 3 then
		Util.Sound:Play("YETI_TNSFM_M1_Slash_03", hrp)
		task.wait(0.24)
		local cFrame = hrp.CFrame
		local cframe = CFrame.Angles(0, 0, 0)
		local cframe2 = CFrame.Angles(-2.6179938779914944, 0, 0)
		local _ = hrp.CFrame * cframe
		local _ = hrp.CFrame * CFrame.new(0, 0, -9) * cframe
		local clone = m1s.ClawPart2:Clone()
		clone.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone, 1.5)
		clone.Weld.Part0 = hrp
		clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * cframe * cframe2 * CFrame.new(
			0,
			0,
			6
		)
		BasicSlash(clone)
		emitAll(clone)
		task.wait(0.043999999999999984)
		local _ = plr.Character.PrimaryPart.CFrame.LookVector

		if hrp.Parent == game.Players.LocalPlayer.Character then
			task.spawn(function()
				Util.CameraShaker:ShakeOnce(9, 9, 0.05, 0.7, createVector(1, 1, 1), createVector(1, 1, 1))
				local clone2 = script.DOF:Clone()
				Util.SetParentOverrideWithColor(clone2, game.Lighting, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone2, 2)
				TweenService:Create(clone2, TweenInfo.new(0.833, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
					FarIntensity = 0,
					FocusDistance = 0,
					InFocusRadius = 0,
					NearIntensity = 0
				}):Play()
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						FieldOfView = 45
					}
				):Play()
				task.wait(0.12)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						FieldOfView = 85
					}
				):Play()
				task.wait(0.12)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
					{
						FieldOfView = 70
					}
				):Play()
			end)
		end

		local ray = Util.Ray
		local v = hrp.Position + createVector(0, 1, 0)
		local v2 = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
		local v3, v4, _ = ray(v, createVector(-0, -25, -0), v2)

		if v3 == nil then
			local clone2 = m1s.M1SlamAir:Clone()
			clone2.CFrame = hrp.CFrame
			Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "YetiFruitVFXColor")
			emitAll(clone2)
			Util.Debris:AddItem(clone2, 2)
		else
			local cframe3 = CFrame.new(v4)
			local clone2 = m1s.smash:Clone()
			clone2.CFrame = cframe3
			Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "YetiFruitVFXColor")
			Util.Debris:AddItem(clone2, 4)
			emitAll(clone2)
			Spikes.Ring(player, 8, 2, clone2, nil, 12, 9, 12, 3.4, nil, _WorldOrigin)
			Spikes.Ring(player, 10, 1, clone2, nil, 18, 3.6, 12, 4, nil, _WorldOrigin)
			Spikes.Ring(player, 8, 2, clone2, nil, 21, 7, 12, 3.4, nil, _WorldOrigin)
		end
	elseif stage == 4 then
		Util.Sound:Play("YETI_TNSFM_M1_Slash_04", hrp)
		task.wait(0.25)

		if hrp.Parent == game.Players.LocalPlayer.Character then
			task.spawn(function()
				Util.CameraShaker:ShakeOnce(12, 14, 0.05, 0.7, createVector(1, 1, 1), createVector(1, 1, 1))
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						FieldOfView = 35
					}
				):Play()
				task.wait(0.12)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						FieldOfView = 105
					}
				):Play()
				task.wait(0.12)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						FieldOfView = 70
					}
				):Play()
			end)
		end

		task.spawn(function()
			task.wait(0.16)
			local yetiRig = hrp.Parent.YetiRig:FindFirstChild("YetiRig")
			emitAll(yetiRig.TransformParticles.eyeL)
			emitAll(yetiRig.TransformParticles.eyeR)
		end)
		task.spawn(function()
			local clone = m1s.HRPFX.Impact3:Clone()
			local clone2 = m1s.HRPFX.Roar:Clone()
			Util.SetParentOverrideWithColor(clone, hrp, player, "YetiFruitVFXColor")
			Util.SetParentOverrideWithColor(clone2, hrp, player, "YetiFruitVFXColor")
			Util.Debris:AddItem(clone, 3)
			Util.Debris:AddItem(clone2, 3)
			emitAll(clone)
			emitAll(clone2)
			local part = Instance.new("Part")
			part.CanTouch = false
			part.CanQuery = false
			part.CanCollide = false
			part.Anchored = true
			part.Transparency = 1
			part.CFrame = hrp.CFrame
			Util.SetParentOverrideWithColor(part, _WorldOrigin, player, "YetiFruitVFXColor")
			Util.Debris:AddItem(part, 3)
			task.spawn(function()
				task.wait(0.2)

				for _ = 1, 19 do
					local clone3 = m1s.IceWind:Clone()
					clone3.CFrame = part.CFrame * CFrame.Angles(
						math.rad(math.random(-3600, 3600) / 10),
						math.rad(math.random(-3600, 3600) / 10),
						(math.rad(math.random(-3600, 3600) / 10))
					)
					clone3.Position = part.position
					clone3.Anchored = false
					Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "YetiFruitVFXColor")
					local v = math.random(2, 10) / 5
					local v2 = math.random(20, 40) / 5

					if math.random(2) == 1 then
						v2 *= -1
					end

					for _, attachment in pairs(clone3:GetDescendants()) do
						if not attachment:IsA("Attachment") then
							continue
						end

						attachment.Position = Vector3.new(0, attachment.Name == "Top" and v or -v, 0)
						attachment.Position += Vector3.new(0, v2, 0)
					end

					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
					bodyVelocity.Velocity = clone3.CFrame.LookVector * math.random(160, 340)
					Util.SetParentOverrideWithColor(bodyVelocity, clone3, player, "YetiFruitVFXColor")
					local v3 = math.random(22, 41) / 1.5
					clone3.RotVelocity = clone3.CFrame.LookVector * v3
					coroutine.resume(coroutine.create(function()
						task.wait(math.random(40, 70) / 100)
						clone3.Anchored = true
						Util.Debris:AddItem(clone3, 1.5)
					end))
				end
			end)
			local ray = Util.Ray
			local v = hrp.Position + createVector(0, 1, 0)
			local v2 = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
			local v3, v4, _ = ray(v, createVector(-0, -25, -0), v2)

			if v3 ~= nil then
				local cframe = CFrame.new(v4)
				local clone3 = m1s.CracksGround:Clone()
				clone3.CFrame = cframe

				if player:GetAttribute("RedYeti") then
					for _, emitter in ipairs(clone3:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						emitter.Color = ColorSequence.new(Color3.new(1, 0, 0))

						if emitter.Orientation == Enum.ParticleOrientation.VelocityPerpendicular then
							emitter.LightEmission = math.min(0.2, emitter.LightEmission)
						end
					end

					clone3.Parent = _WorldOrigin
				else
					Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "YetiFruitVFXColor")
				end

				Util.Debris:AddItem(clone3, 5)
				emitAll(clone3)
				Spikes.Ring(player, 7, 1, clone3, nil, 34, 28, 9, 2, "DefrostBear", _WorldOrigin)
				Spikes.Ring(player, 8, 2, clone3, nil, 45, 12, 9, 2, nil, _WorldOrigin)
				Spikes.Ring(player, 8, 2, clone3, nil, 33, 9, 12, 3.4, nil, _WorldOrigin)
			end
		end)
	end
end

return function(data)
	local player = data.player
	local plr = data.plr
	local hrp = data.hrp

	if not hrp then
		return
	end

	local cframe = CFrame.lookAt(hrp.Position, hrp.Position + data.shootDir)
	local stage = data.stage

	if (cframe.p - workspace.CurrentCamera.CFrame.p).magnitude > 800 or not hrp then
		return
	end

	local yetiRig = hrp.Parent:FindFirstChild("YetiRig")

	if not yetiRig then
		return
	end

	hit(player, plr, hrp, cframe, yetiRig, stage)
end
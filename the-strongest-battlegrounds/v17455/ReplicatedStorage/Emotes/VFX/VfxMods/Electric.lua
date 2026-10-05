local createVector = vector.create
local Electric = {}
local library = require(game.ReplicatedStorage.library)
local _ = library.PlayAttachment
local _ = library.Maid
local _ = library.PlayTween
local _ = library.CamShake
local _ = library.PlayFlipBook
local _ = library.dtwait
local _ = library.EFP
local _ = library.PlayMesh
local _ = library.Impact
local _ = library.GlassLight
local _ = library.RaiseZIndex
local _ = library.Able
local _ = library.LifeScale
local _ = library.QuickFX
local _ = library.QuickWeld
local _ = library.Yield
local _ = library.ProcessPart
local _ = library.WeldObject
local _ = library.Bezier
local _ = script.VFX
local class = {}
class.__index = class
Random.new()
game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera
local _ = {
	{
		name = "Sword",
		attachTo = "Right Arm"
	},
	{
		name = "Sheath",
		attachTo = "Torso"
	}
}

function Electric.FirstEvent(data)
	local char = data.Char
	local _ = char == game.Players.LocalPlayer.Character
	shared.NerfVfx({
		Script = script,
		Char = char
	})
	local _ = data.CleanupTable
	local realAnim = data.RealAnim
	local targChar = data.targChar
	local bind = data.Bind
	tick()
	local _ = char.Humanoid
	local _ = char.HumanoidRootPart
	local v = char ~= game.Players.LocalPlayer.Character

	local function GetTorsoCF()
		local _, v2, _ = char.HumanoidRootPart.CFrame:ToOrientation()
		return CFrame.new(char.Torso.Position) * CFrame.Angles(0, v2, 0)
	end

	local v2 = false
	local v3 = {}

	local function loadFOVKeyframes()
		if v then
			return
		end

		local eaiwsubriawu = char:WaitForChild("CamRigWithLetterBox4"):FindFirstChild("eaiwsubriawu")

		if not eaiwsubriawu then
			return
		end

		v3 = {}

		for _, folder in pairs(eaiwsubriawu:GetChildren()) do
			if not folder:IsA("Folder") then
				continue
			end

			local name = tonumber(folder.Name)
			local values = folder:FindFirstChild("Values")

			if not values then
				continue
			end

			local _0 = values:FindFirstChild("0")

			if name and _0 and _0:IsA("NumberValue") then
				v3[name] = _0.Value
			end
		end
	end

	local S_FOV = game.Players.LocalPlayer:GetAttribute("S_FOV") or 70

	local function interpolateFOV(p)
		if not next(v3) then
			return S_FOV
		end

		local v4 = S_FOV
		local v5 = S_FOV
		local v6 = nil
		local v7 = nil

		for k, v8 in pairs(v3) do
			if k <= p and (not v6 or v6 < k) then
				v4 = v8
				v6 = k
			end

			if not (p <= k and (not v7 or k < v7)) then
				continue
			end

			v5 = v8
			v7 = k
		end

		if v6 == v7 or not (v6 and v7) then
			return v4 or v5 or S_FOV
		end

		local v8 = (p - v6) / (v7 - v6)
		return v4 + (v5 - v4) * v8
	end

	local parentChangedConnection = nil
	local v4 = false
	local fn

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v4 then
			v4 = true

			if parentChangedConnection then
				parentChangedConnection:Disconnect()
			end

			if fn then
				fn()
			end
		end
	end

	parentChangedConnection = bind:GetPropertyChangedSignal("Parent"):Connect(function()
		if bind and bind.Parent then
			return
		end

		v2 = true
		Clean() -- equivalent call inferred; original call site unknown
		return parentChangedConnection:Disconnect()
	end)
	task.delay(20, function()
		if parentChangedConnection then
			return parentChangedConnection:Disconnect()
		end
	end)
	task.delay(20, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local v5

	if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
		v2 = true
		v5 = false
	else
		v5 = true
	end

	if not v5 then
		return
	end

	local v6 = {
		{
			name = "Sword",
			attachTo = "Right Arm"
		},
		{
			name = "Sheath",
			attachTo = "Torso"
		}
	}
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	game:GetService("UserInputService")
	local Workspace = game:GetService("Workspace")
	local Lighting = game:GetService("Lighting")
	local localPlayer = Players.LocalPlayer
	local currentCamera = Workspace.CurrentCamera
	local fieldOfView = currentCamera.FieldOfView
	local v7 = {
		Brightness = Lighting.Brightness,
		Ambient = Lighting.Ambient,
		ColorShift_Top = Lighting.ColorShift_Top,
		ColorShift_Bottom = Lighting.ColorShift_Bottom,
		ClockTime = Lighting.ClockTime
	}
	local v8 = {
		connections = {},
		animations = {},
		objects = {},
		tweens = {},
		particles = {},
		beams = {},
		trails = {},
		lights = {}
	}

	local function trackInstance(instance, p, value)
		if instance and instance:IsA("Instance") then
			table.insert(p or v8.objects, instance)
			task.delay(value or 17, function()
				if instance and instance.Parent then
					pcall(function()
						instance:Destroy()
					end)
				end
			end)
		end

		return instance
	end

	local flag = false
	local v9 = 0
	local v10 = -1
	local flag2 = false

	local function trackParticleEffect(instance)
		if instance:IsA("ParticleEmitter") then
			table.insert(v8.particles, instance)
		elseif instance:IsA("Beam") then
			table.insert(v8.beams, instance)
		elseif instance:IsA("Trail") then
			table.insert(v8.trails, instance)
		elseif instance:IsA("PointLight") then
			table.insert(v8.lights, instance)
		end
	end

	local function enableParticleEffects(folder)
		if not (folder and folder.Parent) then
			return
		end

		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") then
				descendant.Enabled = true
				trackParticleEffect(descendant)
			elseif descendant:IsA("PointLight") then
				descendant.Enabled = true
				trackParticleEffect(descendant)
			end
		end
	end

	local function disableParticleEffects(folder)
		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") then
				descendant.Enabled = false
			elseif descendant:IsA("PointLight") then
				descendant.Enabled = false
			end
		end
	end

	local v11 = {
		imagelabel = {
			ImageColor3 = {
				[16] = Color3.new(0, 0, 0),
				[52] = Color3.new(0, 0, 0),
				[62] = Color3.new(0, 0, 0),
				[436] = Color3.new(0, 0, 0),
				[649] = Color3.new(0, 0, 0),
				[659] = Color3.new(0, 0, 0)
			},
			ImageTransparency = {
				[16] = 0,
				[52] = 0,
				[62] = 1,
				[436] = 1,
				[649] = 0,
				[659] = 1
			}
		}
	}

	local function impactPulse(p, list, duration)
		local v12 = trackInstance(Instance.new("ColorCorrectionEffect"), v8.objects)

		if not v12 then
			return
		end

		v12.Name = "ImpactFrame"
		v12.Parent = Lighting
		task.spawn(function()
			for _, childName in ipairs(list) do
				if flag then
					break
				end

				local child = p.vfx:FindFirstChild(childName)

				if not child then
					continue
				end

				local v13 = trackInstance(child:Clone(), v8.objects)

				if not v13 then
					continue
				end

				v13.Parent = Lighting
				local saturation = v12.Saturation
				v12.Saturation = 0
				task.wait(duration)

				if v12 and v12.Parent then
					v12.Saturation = saturation
				end

				if v13 and v13.Parent then
					v13:Destroy()
				end
			end
		end)
	end

	local v12 = nil
	local v13 = {
		victim = {
			Enabled = {
				[0] = true
			},
			OutlineTransparency = {
				[0] = 1,
				[334] = 0.6
			},
			OutlineColor = {
				[0] = Color3.new(1, 1, 1),
				[334] = Color3.new(0, 0, 0)
			},
			FillTransparency = {
				[0] = 1
			},
			FillColor = {
				[0] = Color3.new(1, 0.65098, 0.0941177)
			}
		},
		user = {
			Enabled = {
				[0] = true,
				[443] = true,
				[448] = true,
				[479] = true,
				[726] = true
			},
			OutlineTransparency = {
				[0] = 1
			},
			OutlineColor = {
				[0] = Color3.new(1, 1, 1)
			},
			FillTransparency = {
				[0] = 1,
				[443] = 1,
				[448] = 0.6,
				[479] = 1,
				[726] = 1
			},
			FillColor = {
				[0] = Color3.new(1, 0.65098, 0.0941177),
				[443] = Color3.new(1, 0.65098, 0.0941177),
				[448] = Color3.new(1, 0.65098, 0.0941177),
				[479] = Color3.new(1, 0.65098, 0.0941177),
				[726] = Color3.new(1, 0.65098, 0.0941177)
			}
		}
	}
	local v14 = nil
	local v15 = {
		[19] = function(p)
			enableParticleEffects(p.character.Sword.Attachment)

			if not v then
				enableParticleEffects(p.cameraRig.camera.Beam)
			end
		end,
		[26] = function(p)
			enableParticleEffects(p.character.Sheath)
		end,
		[62] = function(data2)
			enableParticleEffects(data2.vfx.Beam)
			disableParticleEffects(data2.character.Sword.Attachment)
			disableParticleEffects(data2.character.Sheath)

			if not v then
				disableParticleEffects(data2.cameraRig.camera.Beam)
			end

			for _, emitter in pairs(data2.vfx.Beam:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			if not v then
				enableParticleEffects(data2.vfx.Rock)
				task.spawn(function()
					task.wait(0.1)

					for _, emitter in pairs(data2.vfx.Rock:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v16 = emitter
						task.spawn(function()
							v16.TimeScale = 0.02
						end)
					end
				end)
				local attachment = data2.cameraRig.camera:FindFirstChild("Attachment")

				if attachment and attachment:FindFirstChild("Flare") then
					enableParticleEffects(attachment.Flare)
				end

				impactPulse(data2, {
					"White",
					"Blue",
					"White",
					"Black",
					"White"
				}, 0.022222222222222223)
			end
		end,
		[73] = function(p)
			disableParticleEffects(p.vfx.Beam)

			for _, emitter in pairs(p.vfx.Hit1:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter:Emit(emitter:GetAttribute("EmitCount"))
				trackParticleEffect(emitter)
			end

			if not v then
				enableParticleEffects(p.vfx.Rock)
				task.spawn(function()
					task.wait(0.1)
					local vfx = p.vfx

					if not (vfx and vfx:FindFirstChild("Rock")) then
						return
					end

					for _, emitter in pairs(p.vfx.Rock:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v16 = emitter
						task.spawn(function()
							v16.TimeScale = 0.02
						end)
					end
				end)
			end
		end,
		[85] = function(p)
			if not v then
				impactPulse(p, {
					"White",
					"Blue",
					"White",
					"Black",
					"White"
				}, 0.025)
			end
		end,
		[91] = function(p)
			local attachment = not v and p.cameraRig.camera:FindFirstChild("Attachment")

			if attachment then
				enableParticleEffects(attachment)
			end

			if p.vfx.MeshVFX then
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local success, result = pcall(function()
					return require(ReplicatedStorage.MeshEmitModule)
				end)

				if success and result then
					local v16 = {
						MeshVFX = p.vfx.MeshVFX.VFX1
					}

					for _, v17 in pairs(v16) do
						if v17 and v17:FindFirstChild("Start") then
							result(v17.Start)
						end
					end
				end
			end

			disableParticleEffects(p.vfx.Beam)
		end,
		[158] = function(p)
			local attachment = not v and p.cameraRig.camera:FindFirstChild("Attachment")

			if attachment then
				disableParticleEffects(attachment)
				local flare = attachment:FindFirstChild("Flare")

				if flare then
					disableParticleEffects(flare)
				end
			end
		end,
		[174] = function(p)
			enableParticleEffects(p.vfx.Charge)
			local charge = p.vfx:FindFirstChild("Charge")

			if charge then
				local attachment = charge:FindFirstChild("Attachment")
				local pointLight = attachment and attachment:FindFirstChild("PointLight")

				if pointLight then
					pointLight.Enabled = true
					trackParticleEffect(pointLight)
				end
			end
		end,
		[196] = function(p)
			if v12 then
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Built }
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				local raycastResult = workspace:Raycast(char.Torso.Position, createVector(0, -15, 0), raycastParams)

				if raycastResult then
					for _, part in pairs(v12:GetChildren()) do
						if not part:IsA("BasePart") then
							continue
						end

						if raycastResult then
							part.Material = raycastResult.Material
							part.Color = raycastResult.Instance.Color
						end

						local texture = part:FindFirstChildOfClass("Texture")

						if texture then
							texture:Destroy()
						end
					end
				end
			end

			if not v and p.cameraRig:FindFirstChild("camera2") then
				for _, emitter in pairs(p.cameraRig.camera2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter:Emit(emitter:GetAttribute("EmitCount"))
					trackParticleEffect(emitter)
				end
			end

			disableParticleEffects(p.vfx.Charge)

			if v then
				for _, effect in pairs(p.vfx.Charge2:GetDescendants()) do
					if effect:IsA("Beam") or effect:IsA("Trail") then
						effect.Enabled = true
					end

					if not effect:IsA("ParticleEmitter") or effect:GetAttribute("crep") then
						continue
					end

					local v16 = tostring(effect)

					if v16:find("Rocks") or v16:find("Dust") then
						continue
					end

					effect.Enabled = true
				end
			else
				enableParticleEffects(p.vfx.Charge2)
			end

			local charge = p.vfx:FindFirstChild("Charge")

			if charge then
				local attachment = charge:FindFirstChild("Attachment")
				local pointLight = attachment and attachment:FindFirstChild("PointLight")

				if pointLight then
					pointLight.Enabled = true
					trackParticleEffect(pointLight)
				end
			end

			if not v then
				impactPulse(p, {
					"White",
					"Blue",
					"White",
					"Black",
					"White",
					"White",
					"Blue",
					"White",
					"Black",
					"White"
				}, 0.043478260869565216)
			end
		end,
		[261] = function(p)
			if v then
				return
			end

			local attachment = p.cameraRig.camera:FindFirstChild("Attachment")

			if attachment then
				enableParticleEffects(attachment)
				local flare = attachment:FindFirstChild("Flare")

				if flare then
					enableParticleEffects(flare)
				end
			end
		end,
		[317] = function(p)
			local beamLine = p.vfx:FindFirstChild("BeamLine")

			if beamLine then
				local v16 = nil

				for _, part in pairs(beamLine:GetChildren()) do
					if not (part.Name == "Beam1" and part:IsA("Part")) then
						continue
					end

					v16 = part
					break
				end

				if v16 then
					enableParticleEffects(v16)
				end
			end

			if not v then
				impactPulse(p, {
					"White",
					"Blue",
					"White",
					"Black",
					"White",
					"White",
					"Blue",
					"White",
					"Black",
					"White"
				}, 0.043478260869565216)
			end
		end,
		[329] = function(p)
			disableParticleEffects(p.vfx.Charge2)
			local charge = p.vfx:FindFirstChild("Charge")

			if charge then
				local attachment = charge:FindFirstChild("Attachment")
				local pointLight = attachment and attachment:FindFirstChild("PointLight")

				if pointLight then
					pointLight.Enabled = false
				end
			end
		end,
		[350] = function(p)
			for _, emitter in pairs(v14:GetChildren()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter:Emit(emitter:GetAttribute("EmitCount"))
				trackParticleEffect(emitter)
			end

			if v then
				return
			end

			local attachment = p.cameraRig.camera:FindFirstChild("Attachment")

			if attachment then
				disableParticleEffects(attachment)
			end
		end,
		[359] = function(p)
			local beamLine = p.vfx:FindFirstChild("BeamLine")

			if beamLine then
				local v16 = nil

				for _, part in pairs(beamLine:GetChildren()) do
					if not (part.Name == "Beam2" and part:IsA("Part")) then
						continue
					end

					v16 = part
					break
				end

				if v16 then
					enableParticleEffects(v16)
				end
			end

			for _, emitter in pairs(v14:GetChildren()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter:Emit(emitter:GetAttribute("EmitCount"))
				trackParticleEffect(emitter)
			end

			if v then
				return
			end

			local attachment = p.cameraRig.camera:FindFirstChild("Attachment")
			local flare = attachment and attachment:FindFirstChild("Flare")

			if flare then
				disableParticleEffects(flare)
			end
		end,
		[368] = function(p)
			local beamLine = p.vfx:FindFirstChild("BeamLine")

			if beamLine then
				local v16 = nil

				for _, part in pairs(beamLine:GetChildren()) do
					if not (part.Name == "Beam3" and part:IsA("Part")) then
						continue
					end

					v16 = part
					break
				end

				if v16 then
					enableParticleEffects(v16)
				end
			end
		end,
		[376] = function(p)
			local beamLine = p.vfx:FindFirstChild("BeamLine")

			if beamLine then
				local v16 = nil

				for _, part in pairs(beamLine:GetChildren()) do
					if not (part.Name == "Beam4" and part:IsA("Part")) then
						continue
					end

					v16 = part
					break
				end

				if v16 then
					enableParticleEffects(v16)
				end
			end

			for _, emitter in pairs(v14:GetChildren()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter:Emit(emitter:GetAttribute("EmitCount"))
				trackParticleEffect(emitter)
			end
		end,
		[383] = function(p)
			local beamLine = p.vfx:FindFirstChild("BeamLine")

			if beamLine then
				local v16 = nil

				for _, part in pairs(beamLine:GetChildren()) do
					if not (part.Name == "Beam5" and part:IsA("Part")) then
						continue
					end

					v16 = part
					break
				end

				if v16 then
					enableParticleEffects(v16)
				end
			end

			for _, emitter in pairs(v14:GetChildren()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter:Emit(emitter:GetAttribute("EmitCount"))
				trackParticleEffect(emitter)
			end
		end,
		[391] = function(p)
			local beamLine = p.vfx:FindFirstChild("BeamLine")

			if beamLine then
				local v16 = nil

				for _, part in pairs(beamLine:GetChildren()) do
					if not (part.Name == "Beam6" and part:IsA("Part")) then
						continue
					end

					v16 = part
					break
				end

				if v16 then
					enableParticleEffects(v16)
				end
			end
		end,
		[397] = function(p)
			local beamLine = p.vfx:FindFirstChild("BeamLine")

			if beamLine then
				local v16 = nil

				for _, part in pairs(beamLine:GetChildren()) do
					if not (part.Name == "Beam7" and part:IsA("Part")) then
						continue
					end

					v16 = part
					break
				end

				if v16 then
					enableParticleEffects(v16)
				end
			end
		end,
		[403] = function(p)
			local beamLine = p.vfx:FindFirstChild("BeamLine")

			if beamLine then
				local v16 = nil

				for _, part in pairs(beamLine:GetChildren()) do
					if not (part.Name == "Beam8" and part:IsA("Part")) then
						continue
					end

					v16 = part
					break
				end

				if v16 then
					enableParticleEffects(v16)
				end
			end
		end,
		[409] = function(p)
			local beamLine = p.vfx:FindFirstChild("BeamLine")

			if beamLine then
				local v16 = nil

				for _, part in pairs(beamLine:GetChildren()) do
					if not (part.Name == "Beam9" and part:IsA("Part")) then
						continue
					end

					v16 = part
					break
				end

				if v16 then
					enableParticleEffects(v16)
				end
			end

			for _, emitter in pairs(v14:GetChildren()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter:Emit(emitter:GetAttribute("EmitCount"))
				trackParticleEffect(emitter)
			end
		end,
		[436] = function(p)
			local beamLine = p.vfx:FindFirstChild("BeamLine")

			if beamLine then
				for i = 1, 9 do
					local v16 = nil

					for _, part in pairs(beamLine:GetChildren()) do
						if not (part.Name == "Beam" .. i and part:IsA("Part")) then
							continue
						end

						v16 = part
						break
					end

					if v16 then
						disableParticleEffects(v16)
					end
				end
			end

			enableParticleEffects(p.vfx.Speed)

			for _, emitter in pairs(p.vfx.Ground:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter:Emit(emitter:GetAttribute("EmitCount"))
				trackParticleEffect(emitter)
			end

			local v16 = nil

			for _, part in pairs(p.vfx.Slash:GetChildren()) do
				if not (part.Name == "Slash" and part:IsA("Part")) then
					continue
				end

				v16 = part
				break
			end

			if v16 then
				enableParticleEffects(v16)
			end

			if v then
				return
			end

			if p.cameraRig:FindFirstChild("camera3") then
				enableParticleEffects(p.cameraRig.camera3)
			end

			local attachment = p.cameraRig.camera:FindFirstChild("Attachment")

			if attachment then
				enableParticleEffects(attachment)
				local flare = attachment:FindFirstChild("Flare")

				if flare then
					enableParticleEffects(flare)
				end
			end

			impactPulse(p, {
				"White",
				"Blue",
				"White",
				"Black",
				"White"
			}, 0.041666666666666664)
		end,
		[452] = function(p)
			disableParticleEffects(p.vfx.Speed)

			if not v and p.cameraRig:FindFirstChild("camera3") then
				disableParticleEffects(p.cameraRig.camera3)
			end
		end,
		[591] = function(p)
			enableParticleEffects(p.character.Sword.Attachment)

			if not v then
				enableParticleEffects(p.cameraRig.camera.Beam)
			end
		end,
		[635] = function(data2)
			local character = game.Players.LocalPlayer.Character
			local v16 = targChar == character or char == character
			task.delay(0.1, function()
				if game.Players.LocalPlayer.Character == char then
					shared.sfx({
						SoundId = "rbxassetid://76591847117263",
						Parent = v16 and game.Players.LocalPlayer.PlayerGui or char.PrimaryPart,
						Volume = v16 and 2 or 4
					}):Play()
				end
			end)
			enableParticleEffects(data2.vfx.HitLast)
			disableParticleEffects(data2.character.Sword.Attachment)
			local v17 = nil

			for _, part in pairs(data2.vfx.Slash:GetChildren()) do
				if not (part.Name == "Slash" and part:IsA("Part")) then
					continue
				end

				v17 = part
				break
			end

			if v17 then
				disableParticleEffects(v17)
			end

			if v then
				return
			end

			disableParticleEffects(data2.cameraRig.camera.Beam)
			impactPulse(data2, {
				"White",
				"Blue",
				"White",
				"Black",
				"White"
			}, 0.041666666666666664)
		end,
		[697] = function(p)
			disableParticleEffects(p.vfx.HitLast)
		end,
		[705] = function(p)
			local flash = p.vfx:FindFirstChild("Flash")

			if flash then
				enableParticleEffects(flash)
			end
		end,
		[726] = function(p)
			disableParticleEffects(p.vfx.Flash)
		end,
		[742] = function(p)
			disableParticleEffects(p.vfx.Rock)

			for _, emitter in pairs(p.vfx.Rock:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v16 = emitter
				task.spawn(function()
					v16.TimeScale = 1
				end)
			end
		end
	}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function executeFrameEvents(p, p2)
		local v16 = math.floor(p + 0.5)

		if v16 ~= v10 and v15[v16] then
			local success, result = pcall(v15[v16], p2)

			if not success then
				warn("Frame event error at frame", v16, ":", result)
			end

			v10 = v16
		end
	end

	local function getCurrentFrame(p)
		return p * 60
	end

	fn = function()
		if flag then
			return
		end

		flag = true
		flag2 = false
		local character = game.Players.LocalPlayer.Character

		for _, connection in pairs(v8.connections) do
			if connection then
				connection:Disconnect()
			end
		end

		for _, animation in pairs(v8.animations) do
			if not animation then
				continue
			end

			animation:Stop()
			animation:Destroy()
		end

		if character and character:FindFirstChild("Humanoid") then
			local _ = character.Humanoid
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				local position = humanoidRootPart.Position
				humanoidRootPart.CFrame = CFrame.new(position)
				humanoidRootPart.Anchored = false
				humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
				humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
			end
		end

		for _, object in pairs(v8.objects) do
			if object and object.Parent then
				object:Destroy()
			end
		end

		for _, tween in pairs(v8.tweens) do
			if tween then
				tween:Cancel()
			end
		end

		for _, particle in pairs(v8.particles) do
			if particle and particle.Parent then
				particle.Enabled = false
			end
		end

		for _, beam in pairs(v8.beams) do
			if beam and beam.Parent then
				beam.Enabled = false
			end
		end

		for _, trail in pairs(v8.trails) do
			if trail and trail.Parent then
				trail.Enabled = false
			end
		end

		for _, light in pairs(v8.lights) do
			if light and light.Parent then
				light.Enabled = false
			end
		end

		currentCamera.CameraType = Enum.CameraType.Custom
		currentCamera.FieldOfView = fieldOfView

		for k, v16 in pairs(v7) do
			Lighting[k] = v16
		end

		local impactFrame = Lighting:FindFirstChild("ImpactFrame")

		if impactFrame then
			impactFrame:Destroy()
		end

		v8.connections = {}
		v8.animations = {}
		v8.objects = {}
		v8.tweens = {}
		v8.particles = {}
		v8.beams = {}
		v8.trails = {}
		v8.lights = {}
		flag = false
	end

	local function interpolateHighlightProperty(items, p, p2)
		if not next(items) then
			return nil
		end

		local v16 = nil
		local v17 = nil
		local v18 = nil
		local v19 = nil

		for k, item in pairs(items) do
			if k <= p and (not v16 or v16 < k) then
				v18 = item
				v16 = k
			end

			if not (p <= k and (not v17 or k < v17)) then
				continue
			end

			v19 = item
			v17 = k
		end

		if v16 == v17 or not (v16 and v17) then
			return v18 or v19
		end

		local v20 = (p - v16) / (v17 - v16)

		if p2 == "Color3" then
			return v18:lerp(v19, v20)
		elseif p2 == "number" then
			return v18 + (v19 - v18) * v20
		end

		return v19
	end

	local function updateHighlights(char2, instance, p)
		local highlight = char2:FindFirstChild("Highlight")
		local highlight2 = instance:FindFirstChild("Highlight")

		if highlight and v13.user then
			local user = v13.user
			highlight.Enabled = interpolateHighlightProperty(user.Enabled, p, "boolean") or true
			highlight.OutlineTransparency = interpolateHighlightProperty(user.OutlineTransparency, p, "number") or 1
			highlight.OutlineColor = interpolateHighlightProperty(user.OutlineColor, p, "Color3") or Color3.new(1, 1, 1)
			highlight.FillTransparency = interpolateHighlightProperty(user.FillTransparency, p, "number") or 1
			highlight.FillColor = interpolateHighlightProperty(user.FillColor, p, "Color3") or Color3.new(
				1,
				0.65098,
				0.0941177
			)
		end

		if highlight2 and v13.victim then
			local victim = v13.victim
			highlight2.Enabled = interpolateHighlightProperty(victim.Enabled, p, "boolean") or true
			highlight2.OutlineTransparency = interpolateHighlightProperty(victim.OutlineTransparency, p, "number") or 1
			highlight2.OutlineColor = interpolateHighlightProperty(victim.OutlineColor, p, "Color3") or Color3.new(
				1,
				1,
				1
			)
			highlight2.FillTransparency = interpolateHighlightProperty(victim.FillTransparency, p, "number") or 1
			highlight2.FillColor = interpolateHighlightProperty(victim.FillColor, p, "Color3") or Color3.new(
				1,
				0.65098,
				0.0941177
			)
		end
	end

	local function updateImageLabel(vignetteImage, p)
		if not (vignetteImage and v11.imagelabel) then
			return
		end

		local imagelabel = v11.imagelabel

		if imagelabel.ImageColor3 then
			vignetteImage.ImageColor3 = interpolateHighlightProperty(imagelabel.ImageColor3, p, "Color3") or Color3.new(
				1,
				1,
				1
			)
		end

		if imagelabel.ImageTransparency then
			vignetteImage.ImageTransparency = interpolateHighlightProperty(imagelabel.ImageTransparency, p, "number") or 0
		end
	end

	local function loadAnimation(animator, animation, p)
		local track = animator:LoadAnimation(animation)
		v8.animations[p] = track
		return track
	end

	local function runCutscene()
		local DELAY_DURATION = 15

		if flag2 then
			return
		end

		local v16 = targChar
		local camRigWithLetterBox4 = char:WaitForChild("CamRigWithLetterBox4", 3)

		if not (v or camRigWithLetterBox4) then
			return warn("nah")
		end

		loadFOVKeyframes()
		local v17 = trackInstance(Instance.new("Highlight"))
		v17.OutlineTransparency = 1
		v17.FillTransparency = 1
		v17.Parent = char
		local v18 = trackInstance(Instance.new("Highlight"))
		v18.OutlineTransparency = 1
		v18.FillTransparency = 1
		v18.Parent = v16
		local vfx = trackInstance(script.VFX:Clone(), v8.objects)
		task.delay(DELAY_DURATION, function()
			if vfx and vfx.Parent then
				vfx:Destroy()
			end
		end)
		vfx.Name = "VFX"
		vfx:PivotTo(char.HumanoidRootPart.CFrame * CFrame.new(0, -3.65, 0))

		if v then
			for _, effect in pairs(vfx.CloudFx:GetDescendants()) do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
					continue
				end

				effect.Enabled = false
			end
		end

		vfx.Parent = workspace.Thrown
		local v20 = trackInstance(script.Misc.vignetteUI:Clone(), v8.objects)
		task.delay(DELAY_DURATION, function()
			if v20 and v20.Parent then
				v20:Destroy()
			end
		end)

		if not v then
			v20.Parent = localPlayer.PlayerGui
		end

		local vignette = v20:FindFirstChild("Vignette")
		v14 = trackInstance(vfx.HitVictim.Attachment:Clone(), v8.objects)
		task.delay(10, function()
			if v14 and v14.Parent then
				v14:Destroy()
			end
		end)
		game.Debris:AddItem(v14, 10)
		v14.Parent = v16.Torso
		local equipment = {}

		for _, v22 in pairs(v6) do
			local part = trackInstance(script.Misc[v22.name]:Clone(), v8.objects)
			local child = char:FindFirstChild(v22.attachTo)

			if not child then
				continue
			end

			part.Parent = char
			local motor6D = part:FindFirstChildOfClass("Motor6D")

			if motor6D then
				motor6D.Part1 = part
				motor6D.Part0 = child
				motor6D.Enabled = true
			end

			equipment[v22.name] = part
		end

		char:WaitForChild("Humanoid")
		v16:WaitForChild("Humanoid")

		if not (camRigWithLetterBox4 or v) then
			camRigWithLetterBox4:WaitForChild("AnimationController")
		end

		local v22 = {}
		local v23 = {
			character = char,
			victim = v16,
			cameraRig = camRigWithLetterBox4,
			vfx = vfx,
			equipment = equipment,
			meshVFX = vfx:FindFirstChild("MeshVFX"),
			vignetteImage = vignette
		}

		if camRigWithLetterBox4 then
			camRigWithLetterBox4:WaitForChild("camera")
		end

		if not v then
			Lighting.ClockTime = 0
			Lighting.Brightness = 0.5
			Lighting.Ambient = Color3.new(0.1, 0.1, 0.2)
			Lighting.ColorShift_Top = Color3.new(0.8, 0.8, 1)
			Lighting.ColorShift_Bottom = Color3.new(0.2, 0.2, 0.4)
		end

		for _, v24 in pairs(v22) do
			v24:Play()
		end

		flag2 = true
		local cutscene = nil

		if camRigWithLetterBox4 then
			for _, v25 in pairs(camRigWithLetterBox4.AnimationController:GetPlayingAnimationTracks()) do
				cutscene = v25
			end
		end

		v22.user = data.RealAnim
		v22.cutscene = cutscene
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Built }
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		v12 = trackInstance(script.Misc.Crack:Clone(), v8.objects)
		task.delay(DELAY_DURATION, function()
			if v12 and v12.Parent then
				v12:Destroy()
			end
		end)
		v12:PivotTo(char.PrimaryPart.CFrame * CFrame.new(0, -3, 0))
		v12.Parent = Workspace.Thrown
		v12.AnimationController:LoadAnimation(script.Crack):Play()

		if v and camRigWithLetterBox4 then
			for _, descendant in pairs(camRigWithLetterBox4:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") then
					descendant.Enabled = false
				end

				if descendant:IsA("Decal") then
					descendant.Transparency = 1
				end

				if not table.find({ "Beam", "BeamBack", "Attachment" }, (tostring(descendant))) then
					continue
				end

				descendant:Destroy()
			end
		end

		v8.connections.renderStepped = RunService.RenderStepped:Connect(function()
			if flag then
				return
			end

			v9 = v22.user.TimePosition * 60
			executeFrameEvents(v9, v23) -- equivalent call inferred; original call site unknown

			if not v then
				updateHighlights(char, v16, v9)
				updateImageLabel(v23.vignetteImage, v9)
				workspace.CurrentCamera.FieldOfView = interpolateFOV(v9)
			end
		end)
	end

	v8.connections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
		if player == localPlayer then
			fn()
		end
	end)
	runCutscene()
	wait(20)
	Clean() -- equivalent call inferred; original call site unknown
end

return Electric
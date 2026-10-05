local createVector = vector.create
local RunService = game:GetService("RunService")
local rollOffMaxDistance = workspace:FindFirstChild("Duel Choice") and 37.5 or 85
local library = require(game.ReplicatedStorage.library)
local maid = library.Maid
local thrown = game.Workspace.Thrown
local Threader = require(script.Threader)
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local vfx = script.vfx
local thrown2 = workspace.Thrown
local Lighting = game:GetService("Lighting")
local v2 = {
	Brightness = 0,
	Contrast = 0,
	Saturation = 0.2,
	Tint = Color3.fromRGB(255, 255, 255)
}
local _ = {
	Intensity = 2,
	Size = 35,
	Threshold = 2
}
local v3 = {
	{
		Time = 0.317,
		Threaded = true,
		Fn = function(player)
			local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
			colorCorrectionEffect.Parent = Lighting
			table.insert(player.cleanup, colorCorrectionEffect)
			local character = player.Character
			local vfxModel = player.VfxModel
			local clone = vfxModel.Torso.Ignite:Clone()
			clone.Parent = character.Torso
			table.insert(player.cleanup, clone)

			for _, child in clone.Emit:GetChildren() do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			Debris:AddItem(clone, 4)
			local clone2 = vfxModel.Arm.Slap:Clone()
			clone2.Parent = character["Right Arm"]
			clone2.Flame.Flame:Emit(1)
			Debris:AddItem(clone2, 3)
			table.insert(player.cleanup, clone2)

			if not player.isOutsider then
				Lighting.ColorCorrection.Contrast = 1
				Lighting.ColorCorrection.Saturation = 1
				Lighting.Bloom.Size = 120
				Lighting.Bloom.Intensity = 5
				task.wait(0.05)
				Lighting.ColorCorrection.Contrast = 0.3
				Lighting.ColorCorrection.Saturation = -0.6
				Lighting.Bloom.Size = 60
				Lighting.Bloom.Intensity = 5
				local v4 = {
					Contrast = v2.Contrast,
					Saturation = v2.Saturation
				}
				local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear)
				TweenService:Create(Lighting.ColorCorrection, tweenInfo, v4):Play()
				local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Linear)
				TweenService:Create(Lighting.Bloom, tweenInfo2, {
					Size = 35,
					Intensity = 2
				}):Play()
			end
		end
	},
	{
		Time = 0.967,
		Threaded = true,
		Fn = function(player)
			local character = player.Character
			local _ = player.VfxModel
			local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear)
			TweenService:Create(Lighting.ColorCorrection, tweenInfo, {
				Contrast = 0.3,
				Saturation = 1
			}):Play()
			local pointLight = character["Right Arm"].Slap.SecondThing.PointLight
			pointLight.Enabled = true
			pointLight.Range = 0
			TweenService:Create(pointLight, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
				Range = 6
			}):Play()

			for _, emitter in character["Right Arm"].Slap.SecondThing:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end
		end
	},
	{
		Time = 1.8,
		Threaded = true,
		Fn = function(player)
			local character = player.Character
			local vfxModel = player.VfxModel
			character.Torso.Ignite.Constant.Fire.Enabled = false
			character.Torso.Ignite.Constant.FireBack.Enabled = false

			for _, emitter in character["Right Arm"].Slap:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			character["Right Arm"].Slap.SecondThing.PointLight.Enabled = false

			if not player.isOutsider then
				Lighting.ColorCorrection.Contrast = 1
				Lighting.ColorCorrection.Saturation = 2
				local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
				TweenService:Create(Lighting.ColorCorrection, tweenInfo, {
					Contrast = 0.4
				}):Play()
			end

			vfxModel.PunchUp.Star.Enabled = true

			for _, attachment in ipairs(vfxModel.PunchUp.Light:GetChildren()) do
				if not attachment:IsA("Attachment") then
					attachment.Enabled = true
				end
			end

			vfxModel.PunchUp.GroundSmoke.Attachment.Beam.Enabled = true

			for _, emitter in ipairs(vfxModel.PunchUp.GroundSmoke.Attachment:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			vfxModel.PunchUp.Beams.Beams.Enabled = true
			local clone = vfxModel.PunchWind:Clone()
			clone.Parent = thrown2
			clone.Transparency = 0
			Debris:AddItem(clone, 0.5)
			local v4 = {
				Size = createVector(3, 8, 3),
				Position = clone.Position + createVector(0, -2, 0),
				Transparency = 1
			}
			TweenService:Create(clone, TweenInfo.new(0.5), v4):Play()
			local clone2 = vfxModel.PunchThing2:Clone()
			clone2.Parent = thrown2
			clone2.Transparency = 0
			Debris:AddItem(clone2, 0.125)
			local v5 = {
				Size = createVector(1, 10, 1),
				Position = clone2.Position + createVector(0, -5, 0),
				Transparency = 1
			}
			TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Linear), v5):Play()
			local clone3 = vfxModel.SwirlWind:Clone()
			clone3.Parent = thrown2
			clone3.Transparency = 0
			Debris:AddItem(clone3, 0.75)
			local v6 = {
				Size = createVector(10, 14, 10),
				Orientation = clone3.Orientation + createVector(0, 180, 0),
				Position = clone3.Position + createVector(0, -2, 0),
				Transparency = 1
			}
			TweenService:Create(clone3, TweenInfo.new(0.75, Enum.EasingStyle.Quad), v6):Play()
			local clone4 = vfxModel.PunchWindBeams:Clone()
			clone4.Parent = thrown2
			Debris:AddItem(clone4, 3)
			local v7 = {
				Orientation = clone4.Orientation + createVector(0, 180, 0)
			}
			TweenService:Create(clone4, TweenInfo.new(0.75, Enum.EasingStyle.Quad), v7):Play()

			for _, beam in ipairs(clone4:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				beam.Enabled = true
				TweenService:Create(beam, TweenInfo.new(0.75, Enum.EasingStyle.Linear), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end

			task.wait(0.1)

			for _, emitter in ipairs(vfxModel.PunchUp.Punch:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			vfxModel.PunchUp.CameraFlickers.Click.Enabled = true
		end
	},
	{
		Time = 2.517,
		Threaded = true,
		Fn = function(player)
			local _ = player.Character
			local vfxModel = player.VfxModel
			vfxModel.PunchUp.CameraFlickers.Click.Enabled = false

			for _, descendant in vfxModel.PunchUp:GetDescendants() do
				if not (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("SpotLight")) then
					continue
				end

				descendant.Enabled = false
			end
		end
	},
	{
		Time = 3.233,
		Threaded = true,
		Fn = function(player)
			local _ = player.Character
			local vfxModel = player.VfxModel
			task.wait(0.15)

			for _, emitter in vfxModel.SecondSlap:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end
	},
	{
		Time = 3.843,
		Threaded = true,
		Fn = function(player)
			local _ = player.Character
			local vfxModel = player.VfxModel
			local v4

			if not player.isOutsider then
				local v5 = {
					Contrast = Lighting.ColorCorrection.Contrast,
					Saturation = Lighting.ColorCorrection.Saturation,
					Brightness = Lighting.ColorCorrection.Brightness
				}
				local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear)
				v4 = TweenService:Create(Lighting.ColorCorrection, tweenInfo, v5)
				Lighting.ColorCorrection.Saturation = -1
				Lighting.ColorCorrection.Contrast = 5
				Lighting.ColorCorrection.Brightness = 0.3
			end

			for _, emitter in ipairs(vfxModel.Hit2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			vfxModel.Hit2.Light.SpotLight.Enabled = true
			task.wait(0.05)
			vfxModel.Hit2.Light.SpotLight.Enabled = false

			if v4 then
				v4:Play()
			end
		end
	},
	{
		Time = 3.867,
		Threaded = true,
		Fn = function(player)
			local _ = player.Character
			local vfxModel = player.VfxModel
			task.wait(0.15)

			for _, emitter in vfxModel.ThirdSlap:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end
	},
	{
		Time = 4.033,
		Threaded = true,
		Fn = function(player)
			local _ = player.Character
			local vfxModel = player.VfxModel
			local v4

			if player.isOutsider then
				local v5 = {
					Contrast = Lighting.ColorCorrection.Contrast,
					Saturation = Lighting.ColorCorrection.Saturation,
					Brightness = Lighting.ColorCorrection.Brightness
				}
				local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear)
				v4 = TweenService:Create(Lighting.ColorCorrection, tweenInfo, v5)
				Lighting.ColorCorrection.Saturation = -1
				Lighting.ColorCorrection.Contrast = 5
				Lighting.ColorCorrection.Brightness = 0.3
			end

			for _, emitter in ipairs(vfxModel.Hit3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			vfxModel.Hit3.Light.SpotLight.Enabled = true
			task.wait(0.05)
			vfxModel.Hit3.Light.SpotLight.Enabled = false

			if v4 then
				v4:Play()
			end
		end
	},
	{
		Time = 4.617,
		Threaded = true,
		Fn = function(player)
			local _ = player.Character
			local vfxModel = player.VfxModel
			task.wait(0.22)

			for _, emitter in vfxModel.ForthSlap:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end
	},
	{
		Time = 4.967,
		Threaded = true,
		Fn = function(player)
			local _ = player.Character
			local vfxModel = player.VfxModel
			local v4, v5

			if not player.isOutsider then
				local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear)
				v4 = TweenService:Create(Lighting.ColorCorrection, tweenInfo, {
					Contrast = 0,
					Saturation = 0.2,
					Brightness = 0
				})
				v5 = TweenService:Create(Lighting, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {
					ClockTime = 14.5
				})
				Lighting.ColorCorrection.Saturation = -1
				Lighting.ColorCorrection.Contrast = 5
				Lighting.ColorCorrection.Brightness = 0.3
			end

			for _, emitter in ipairs(vfxModel.Hit4:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			vfxModel.Hit4.Light.SpotLight.Enabled = true
			print("hi")
			task.wait(0.05)
			vfxModel.Hit4.Light.SpotLight.Enabled = false
			local clone = vfx.SlapFace.Slap:Clone()
			clone.Parent = player.targetCharacter.Head
			Debris:AddItem(clone, 0.7)
			v4:Play()
			v5:Play()
		end
	},
	{
		Time = 5.65,
		Threaded = true,
		Fn = function(player)
			task.wait(0.05)

			if not player.isOutsider then
				Lighting.ColorCorrection.Brightness = 0.3
				Lighting.ColorCorrection.Contrast = 0.2
				Lighting.ColorCorrection.Saturation = 0.6
				local v4 = {
					Contrast = v2.Contrast,
					Saturation = v2.Saturation,
					Brightness = v2.Brightness
				}
				local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
				TweenService:Create(Lighting.ColorCorrection, tweenInfo, v4):Play()
			end

			local _ = player.Character
			local vfxModel = player.VfxModel
			local clone = vfxModel.GroundWindMesh:Clone()
			clone.Parent = thrown2
			clone.Transparency = 0.5
			Debris:AddItem(clone, 0.5)
			local v4 = {
				Size = createVector(20, 3, 20),
				Orientation = clone.Orientation + createVector(0, 180, 0),
				Transparency = 1
			}
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad), v4):Play()

			for _, emitter in vfxModel.SmackGround:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end
	}
}
local SumoSlap = {}
local class = {}
class.__index = class

function SumoSlap.FirstEvent(data)
	local char = data.Char
	local _ = char.HumanoidRootPart
	local bind = data.Bind
	local object = setmetatable({}, class)
	object._maid = maid.new()
	shared.NerfVfx({
		Script = script,
		Char = char
	})
	local isOutsider = char ~= game.Players.LocalPlayer.Character or data.targChar ~= game.Players.LocalPlayer.Character
	local v5 = false
	local cleanupTable = data.CleanupTable
	local realAnim = data.RealAnim
	local parentChangedConnection = nil
	local v6 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v6 then
			v6 = true

			if parentChangedConnection then
				parentChangedConnection:Disconnect()
			end

			object._maid:doCleaning()
		end
	end

	parentChangedConnection = bind:GetPropertyChangedSignal("Parent"):Connect(function()
		if bind and bind.Parent then
			return
		end

		v5 = true
		Clean() -- equivalent call inferred; original call site unknown
		return parentChangedConnection:Disconnect()
	end)

	local function FirstEvent()
		local character = char
		character:FindFirstChild("CamRig")
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local clone = script.vfx:Clone()
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -2, 0.461532593))
		clone.Parent = thrown
		table.insert(cleanupTable, clone)
		character:FindFirstChild("Left Arm")
		character:FindFirstChild("Right Arm")
		game.Debris:AddItem(clone, 15)
		table.insert(cleanupTable, clone)
		local v8 = {}
		local v9 = {}

		local function parent(instance, folder)
			local parent2 = folder[tostring(instance)]

			if not parent2 then
				return
			end

			if not v8[folder] then
				v8[folder] = {}
			end

			for _, child in pairs(instance:GetChildren()) do
				local v11

				if v5 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v5 = true
					v11 = false
				else
					v11 = true
				end

				if not v11 then
					return
				end

				local clone2 = child:Clone()
				game.Debris:AddItem(clone2, 15)
				table.insert(cleanupTable, clone2)
				clone2.Parent = parent2
				table.insert(v8[folder], clone2)

				for _, trail in pairs(clone2:GetDescendants()) do
					if not trail:IsA("Trail") then
						continue
					end

					table.insert(v8[folder], trail)

					if trail.Attachment0 and trail.Attachment1 then
						v9[trail] = {
							Attachment0 = trail.Attachment0.CFrame,
							Attachment1 = trail.Attachment1.CFrame
						}
					end
				end
			end

			if next(v9) then
				for k, v11 in pairs(v9) do
					local v12

					if v5 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v5 = true
						v12 = false
					else
						v12 = true
					end

					if not v12 then
						return
					end

					local attachment0 = v11.Attachment0
					local attachment1 = v11.Attachment1

					if not (k.Parent and k.Parent.Parent) then
						continue
					end

					for _, attachment in pairs(folder:GetDescendants()) do
						if not attachment:IsA("Attachment") then
							continue
						end

						local cFrame = attachment.CFrame

						if cFrame == attachment0 then
							k.Attachment0 = attachment
						elseif cFrame == attachment1 then
							k.Attachment1 = attachment
						end
					end
				end
			end
		end

		local effects = {}
		local descendantAddedConnection = char.DescendantAdded:Connect(function(effect)
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam") then
				if not effect:GetAttribute("Made") then
					return
				end

				table.insert(effects, effect)
				game.Debris:AddItem(effect, 15)
				table.insert(cleanupTable, effect)
			end
		end)
		table.insert(cleanupTable, descendantAddedConnection)
		task.delay(5, function()
			if descendantAddedConnection then
				descendantAddedConnection:Disconnect()
			end
		end)
		print(clone)
		local v10 = {
			Character = character,
			isOutsider = isOutsider,
			VfxModel = clone,
			EffectsContainer = {},
			targetCharacter = data.targChar,
			cleanup = cleanupTable
		}
		table.insert(cleanupTable, v10)
		local v11 = 1
		local total = 0
		local threader = Threader()

		if isOutsider then
			local sfx = shared.sfx({
				SoundId = "rbxassetid://130615527450500",
				Parent = char.PrimaryPart,
				RollOffMaxDistance = rollOffMaxDistance,
				Volume = 1.2
			})
			local sfx2 = shared.sfx({
				SoundId = "rbxassetid://73486330434629",
				Parent = data.targChar.PrimaryPart,
				RollOffMaxDistance = rollOffMaxDistance,
				Volume = 1.2
			})
			table.insert(cleanupTable, sfx)
			table.insert(cleanupTable, sfx2)
			sfx:Play()
			sfx2:Play()
		else
			local sfx = shared.sfx({
				SoundId = "rbxassetid://130615527450500",
				Parent = workspace,
				RollOffMaxDistance = rollOffMaxDistance,
				Volume = 1.2
			})
			local sfx2 = shared.sfx({
				SoundId = "rbxassetid://73486330434629",
				Parent = workspace,
				RollOffMaxDistance = rollOffMaxDistance,
				Volume = 1.2
			})
			table.insert(cleanupTable, sfx)
			table.insert(cleanupTable, sfx2)
			sfx:Play()
			sfx2:Play()
		end

		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
			local v13 = v3[v11]
			total += dt

			if v13 then
				local fn = v13.Fn

				if v13.Time and total > v13.Time then
					local v14

					if v5 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v5 = true
						v14 = false
					else
						v14 = true
					end

					if not v14 then
						return
					end

					if v13.Threaded then
						threader.RunFunction(fn, v10)
					else
						pcall(fn, v10)
					end

					v11 += 1
				end
			else
				heartbeatConnection:Disconnect()
			end
		end)
	end

	task.spawn(FirstEvent)
	wait(15)
	Clean() -- equivalent call inferred; original call site unknown
end

return SumoSlap
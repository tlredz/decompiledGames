local createVector = vector.create
local ConquestClient = {}
local libraryNew = require(script.Parent.libraryNew)
local playAttachment = libraryNew.PlayAttachment
local maid = libraryNew.Maid
local playTween = libraryNew.PlayTween
local _ = libraryNew.CamShake
local _ = libraryNew.PlayFlipBook
local dtwait = libraryNew.dtwait
local EFP = libraryNew.EFP
local playMesh = libraryNew.PlayMesh
local _ = libraryNew.Impact
local _ = libraryNew.GlassLight
local raiseZIndex = libraryNew.RaiseZIndex
local able = libraryNew.Able
local lifeScale = libraryNew.LifeScale
local quickFX = libraryNew.QuickFX
local quickWeld = libraryNew.QuickWeld
local _ = libraryNew.Yield
local _ = libraryNew.ProcessPart
local _ = libraryNew.WeldObject
local _ = libraryNew.Bezier
local vfx = script.vfx
local MechCache = require(game.ReplicatedStorage.Resources.MechCache)
local class = {}
class.__index = class
local random = Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local clones = {}
local camera = game.Workspace.Camera
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { game.Workspace.Map, game.Workspace.Built }
local MoonEmitter = require(game.ReplicatedStorage.Resources.MoonEmitter)
local ZLib = require(game.ReplicatedStorage.Resources.CosmicUtils.ZLib)
local Crater = require(game.ReplicatedStorage.Resources.CosmicUtils.ZLib.Crater)

function ConquestClient.FirstEvent(p)
	local data = p.Data
	local char = data.Char
	local primaryPart = char.PrimaryPart
	local victim = data.Victim
	local camera2 = data.Camera
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local lastTime = tick()

	local function New()
		local v2 = object._maid:give(vfx.Sky:Clone())
		game.Debris:AddItem(v2, 6)

		for _, emitter in pairs(v2.Fade.realback:GetChildren()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Rate *= 3
			emitter.ZOffset += 30
		end

		local v3 = object._maid:give(Instance.new("NumberValue"))
		object._maid:giveTask(v3.Changed:Connect(function()
			v2:ScaleTo(v3.Value)
		end))
		v3.Value = v2:GetScale()
		v2:PivotTo(char:GetPivot() * vfx.Sky:GetAttribute("Offset"):Inverse() * CFrame.new(0, 0, 0))
		v2.Parent = EFP
		v2.Speed.Value = -1.7
		v3.Value = 0.1
		TweenService:Create(v3, TweenInfo.new(2, Enum.EasingStyle.Sine), {
			Value = 4
		}):Play()
		task.delay(2, function() end)

		for _, part in pairs(v2:GetChildren()) do
			if not part:IsA("BasePart") then
				continue
			end

			if part.Transparency == 1 then
				if part.Name == "Sparks" then
					TweenService:Create(part, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
						Transparency = 0
					}):Play()
				end
			else
				TweenService:Create(part, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
					Transparency = 0.5
				}):Play()
				local surfaceAppearance = part:FindFirstChild("SurfaceAppearance")

				if surfaceAppearance then
					surfaceAppearance.Color = Color3.new(1, 1, 1)
				end
			end
		end
	end

	local function FirstEvent()
		task.spawn(function()
			local clone = script.Impact:Clone()
			clone.Enabled = true
			clone.Parent = game.Players.LocalPlayer.PlayerGui
			table.insert(clones, clone)
			local images = {}

			for _, image in pairs(clone:GetDescendants()) do
				if image:IsA("ImageLabel") then
					table.insert(images, image)
				end
			end

			local v2 = 10 / math.max(#images, 1)

			for _, v3 in pairs(images) do
				v3.Size = UDim2.new(0, 1, 0, 1)
				v3.Visible = true
				v3.Position = UDim2.new(0, 0, 0, 0)
				v3.ImageTransparency = 0
				task.wait(v2)
			end
		end)
		local v2 = object._maid:give(vfx["cutscene1 MeshEmitter"]:Clone())
		v2.Parent = EFP
		v2:PivotTo(primaryPart.CFrame * v2:GetAttribute("Offset"):Inverse())
		local v3 = MoonEmitter.new(v2)
		v3:StopTime()
		v3:Play()
		local FX = nil
		local FX2 = nil
		local FX3 = nil

		local function Test()
			local v7 = object._maid:give(Instance.new("NumberValue"))
			v7.Value = 1
			local v8 = {}
			FX = object._maid:give(vfx.Booster3:Clone())
			raiseZIndex({
				FX = FX,
				Count = 10
			})
			FX2 = object._maid:give(vfx.Booster:Clone())
			FX3 = object._maid:give(vfx.Booster:Clone())
			table.insert(v8, FX2)
			table.insert(v8, FX)
			FX.Parent = EFP
			FX2.Parent = EFP
			FX3.Parent = EFP
			local waist = MechCache.Get(primaryPart).Waist
			local v9 = {}
			local v10 = object._maid:give(Instance.new("NumberValue"))
			local v11 = object._maid:give(Instance.new("NumberValue"))
			object._maid:giveTask(v11.Changed:Connect(function()
				for _, v12 in pairs(v8) do
					if v12.Name == "Wind" then
						v12:ScaleTo(v11.Value * 0.7)
					else
						v12:ScaleTo(v11.Value)
					end
				end
			end))
			object._maid:giveTask(v10.Changed:Connect(function()
				for _, folder in pairs(v8) do
					for _, emitter in pairs(folder:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local speed, lifetime, rate

						if v9[emitter] then
							speed = v9[emitter].Speed
							lifetime = v9[emitter].Lifetime
							rate = v9[emitter].Rate
						else
							speed = emitter.Speed
							lifetime = emitter.Lifetime
							rate = emitter.Rate
							v9[emitter] = {
								Speed = emitter.Speed,
								Lifetime = emitter.Lifetime,
								Rate = emitter.Rate
							}
						end

						emitter.Speed = NumberRange.new(speed.Min * v10.Value, speed.Max * v10.Value)
						emitter.Lifetime = NumberRange.new(lifetime.Min / v10.Value, lifetime.Max / v10.Value)
						emitter.Rate = rate * v10.Value
					end
				end
			end))
			v10.Value = 1.5
			v11.Value = 0.75
			TweenService:Create(v11, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
				Value = 1.2000000000000002
			}):Play()
			local v12 = object._maid:give(Instance.new("PointLight"))
			v12.Brightness = 1
			v12.Color = Color3.new(1, 0.501961, 0)
			TweenService:Create(v12, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
				Range = 20
			}):Play()
			v12.Parent = waist
			game.Debris:AddItem(v12, 3)
			task.spawn(function()
				local lastTime2 = tick()
				local count = 0
				local count2 = 0

				while tick() - lastTime2 < 8 do
					count += 1
					FX:PivotTo(waist.WorldCFrame * CFrame.new(-4, -3, 0) * CFrame.Angles(3.141592653589793, 0, 0))
					FX2:PivotTo(waist.WorldCFrame * CFrame.new(-4, -2 + v11.Value, 0) * CFrame.Angles(
						3.141592653589793,
						0,
						0
					))
					FX3:PivotTo(waist.WorldCFrame * CFrame.new(-4, -2 + v11.Value, 0) * CFrame.Angles(
						3.141592653589793,
						0,
						0
					))

					for _, v13 in pairs(v8) do
						if v13.Name == "Wind" then
							v13:PivotTo(v13:GetPivot():Lerp(
								waist.Parent.WorldCFrame * CFrame.new(-4, -7 * v11.Value, 0) * CFrame.Angles(
									-1.5707963267948966,
									0,
									0
								),
								v7.Value
							))
						end
					end

					if count % 25 == 0 and tick() - lastTime2 < 2 and tick() - lastTime2 > 1.2 then
						count2 += 1
						local model = object._maid:give(vfx.Balls:Clone())
						model:ScaleTo(2)
						playMesh({
							Model = model,
							Anchor = primaryPart.CFrame * CFrame.new(0, -40, 0) * CFrame.Angles(
								0,
								0,
								-1.5707963267948966
							),
							Info = TweenInfo.new(count2 * 0.3, Enum.EasingStyle.Sine)
						})
					end

					dtwait(0.01)
				end

				task.wait(6)
				Clean() -- equivalent call inferred; original call site unknown
			end)
		end

		Test()

		local function Boostersss()
			local v7 = MechCache.Get(primaryPart)
			local v8 = object._maid:give(vfx.boosters:Clone())
			v8.Parent = EFP
			local v9 = {
				["Foot.L"] = v7["Foot.L"],
				["Foot.R"] = v7["Foot.R"]
			}

			for _, child in pairs(vfx.ats:GetChildren()) do
				local v10 = object._maid:give(child:Clone())
				v10.Parent = v9[v10.Name]
				v10.Name = "Attachment"
				task.delay(10, function()
					if v10 and v10.Parent then
						v10:Destroy()
					end
				end)
			end

			local v10 = {}
			local v11 = {}

			for _, child in pairs(v8:GetChildren()) do
				local bone = child:GetAttribute("Bone")

				if not v9[bone] then
					continue
				end

				v10[child] = {
					Offset = child:GetAttribute("Offset"),
					Bone = v9[bone]
				}
				table.insert(v11, child)
			end

			task.spawn(function()
				local lastTime2 = tick()

				while tick() - lastTime2 < 8 do
					for k, v12 in pairs(v10) do
						if string.match(string.lower(k.Name), "foot") then
							k:PivotTo(v12.Bone.Attachment.WorldCFrame * CFrame.new(0, 0.13, 0) * v12.Offset:Inverse())
						else
							k:PivotTo(v12.Bone.Attachment.WorldCFrame * CFrame.Angles(0, 0, 0) * v12.Offset:Inverse())
						end
					end

					dtwait(0.01)
				end

				v8:Destroy()
			end)
			local v12 = {
				["LowerLeg.L"] = v7["LowerLeg.L"],
				["LowerLeg.R"] = v7["LowerLeg.R"],
				["Jetpack.Main"] = v7["Jetpack.Main"]
			}

			for _, child in pairs(vfx.BoosterFolder:GetChildren()) do
				local parent = v12[child.Name]

				if not parent then
					continue
				end

				local v14 = object._maid:give(child:Clone())
				v14.Parent = parent

				for _, emitter in pairs(v14:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.LockedToPart = true
					end
				end

				table.insert(v11, v14)
			end

			task.delay(6, function()
				for _, folder in pairs(v11) do
					able({
						FX = folder,
						On = false
					})

					for _, descendant in pairs(folder:GetDescendants()) do
						if descendant:IsA("Beam") then
							descendant.Enabled = false
						elseif descendant:IsA("BasePart") and descendant.Material == Enum.Material.Neon then
							TweenService:Create(descendant, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
								Transparency = 1
							}):Play()
						end
					end
				end
			end)
		end

		Boostersss()
		v3:AddFrameEvent(function()
			local v7 = quickFX({
				FX = vfx.windtest2,
				Maid = object._maid,
				Anchor = primaryPart.CFrame * vfx.windtest2:GetAttribute("Offset"):Inverse()
			})
			shared.vfx.emit(v7)
		end, 83)
		v3:AddFrameEvent(function()
			local folder = quickFX({
				FX = vfx.Cloud1Fx,
				Maid = object._maid,
				Anchor = primaryPart.CFrame * vfx.Cloud1Fx:GetAttribute("Offset"):Inverse()
			})

			for _, emitter in pairs(folder:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local folder2 = quickFX({
				FX = vfx.Cloud2Fx,
				Maid = object._maid,
				Anchor = primaryPart.CFrame * vfx.Cloud2Fx:GetAttribute("Offset"):Inverse()
			})

			for _, emitter in pairs(folder2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local folder3 = quickFX({
				FX = vfx.Cloud3Fx,
				Maid = object._maid,
				Anchor = primaryPart.CFrame * vfx.Cloud3Fx:GetAttribute("Offset"):Inverse()
			})

			for _, emitter in pairs(folder3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end, 107)
		local folder = nil
		v3:AddFrameEvent(function()
			folder = quickFX({
				FX = vfx.Windparticle,
				Maid = object._maid,
				Anchor = primaryPart.CFrame * vfx.Windparticle:GetAttribute("Offset"):Inverse()
			})

			for _, emitter in pairs(folder:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end
		end, 133)
		local v7 = quickFX({
			FX = vfx.windtest,
			Maid = object._maid,
			Anchor = primaryPart.CFrame * vfx.windtest:GetAttribute("Offset"):Inverse()
		})
		shared.vfx.emit(v7)
		quickFX({
			FX = vfx.CloudScene2,
			Maid = object._maid,
			Anchor = primaryPart.CFrame * vfx.CloudScene2:GetAttribute("Offset"):Inverse()
		})
		local folder2 = quickFX({
			FX = vfx.wind,
			Maid = object._maid,
			Anchor = primaryPart.CFrame * vfx.wind:GetAttribute("Offset"):Inverse()
		})

		for _, emitter in pairs(folder2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		for _, beam in ipairs(folder2:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(beam, TweenInfo.new(0.5), {
				Brightness = 1
			}):Play()
		end

		local cloudCAM = camera2:FindFirstChild("cloudCAM")

		if not cloudCAM then
			cloudCAM = vfx.cloudCAM:Clone()
			cloudCAM.Parent = camera2
		end

		for _, emitter in pairs(cloudCAM:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		for _, childName in pairs({
			"Right Arm",
			"Left Arm",
			"Right Leg",
			"Left Leg",
			"Head",
			"Torso"
		}) do
			local child = victim:FindFirstChild(childName)

			if not child then
				continue
			end

			local v8 = object._maid:give(vfx.Trailstuf:Clone())

			for _, child2 in pairs(v8:GetChildren()) do
				child2.Parent = child
				object._maid:give(child2)
			end
		end

		v3:AddFrameEvent(function()
			local folder3 = cloudCAM

			for _, emitter in pairs(folder3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			for _, emitter in pairs(folder2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			for _, beam in ipairs(folder2:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(beam, TweenInfo.new(0.5), {
					Brightness = 0
				}):Play()
			end

			local cloud = folder2.cloud

			for _, beam in pairs(cloud:GetDescendants()) do
				if beam:IsA("Beam") then
					beam.Enabled = false
				end
			end
		end, 132)
		v3:AddFrameEvent(function()
			local folder3 = cloudCAM

			for _, emitter in pairs(folder3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end, 154)
		v3:AddFrameEvent(function()
			for _, emitter in pairs(folder:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.wait(0.3)
			able({
				FX = FX,
				On = false
			})
			able({
				FX = FX2,
				On = false
			})
			able({
				FX = FX3,
				On = false
			})
		end, 189)
		v3:AddFrameEvent(function()
			shared.vfx.emit(v2.Windinside_Assembly.Meshtest.Windduration1)
			able({
				FX = FX,
				On = true
			})
			able({
				FX = FX2,
				On = true
			})
			able({
				FX = FX3,
				On = true
			})
		end, 253)
		v3:AddFrameEvent(function()
			for _, emitter in pairs(cloudCAM:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			local windinside = v2.vfx.Windinside

			for _, emitter in pairs(windinside:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end, 326)
		v3:AddFrameEvent(function()
			local folder3 = quickFX({
				FX = vfx.Impact,
				Maid = object._maid,
				Anchor = primaryPart.CFrame * vfx.Impact:GetAttribute("Offset"):Inverse()
			})

			for _, emitter in pairs(folder3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			warn(tick() - lastTime)
			task.spawn(function()
				shared.repfire({
					Effect = "JustMod",
					Mod = "ConquestClient",
					Event = "FirstBuild",
					Char = char,
					Camera = camera2,
					Victim = victim
				})
			end)
		end, 410)
		v3:AddFrameEvent(function()
			local folder3 = quickFX({
				FX = vfx.Impact2,
				Maid = object._maid,
				Anchor = primaryPart.CFrame * vfx.Impact2:GetAttribute("Offset"):Inverse()
			})

			for _, emitter in pairs(folder3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			warn(tick() - lastTime)
			task.spawn(function()
				shared.repfire({
					Effect = "JustMod",
					Mod = "ConquestClient",
					Event = "SecondBuild",
					Char = char,
					Camera = camera2,
					Victim = victim
				})
			end)
		end, 444)
		v3:AddFrameEvent(function()
			local folder3 = quickFX({
				FX = vfx.Impact3,
				Maid = object._maid,
				Anchor = primaryPart.CFrame * vfx.Impact3:GetAttribute("Offset"):Inverse()
			})

			for _, emitter in pairs(folder3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			warn(tick() - lastTime)
			task.spawn(function()
				shared.repfire({
					Effect = "JustMod",
					Mod = "ConquestClient",
					Event = "ThirdBuild",
					Char = char,
					Camera = camera2,
					Victim = victim
				})
			end)
		end, 463)
		v3:AddFrameEvent(function()
			local folder3 = quickFX({
				FX = vfx.Impact4,
				Maid = object._maid,
				Anchor = primaryPart.CFrame * vfx.Impact4:GetAttribute("Offset"):Inverse()
			})

			for _, emitter in pairs(folder3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end, 478)
		v3:AddFrameEvent(function()
			local folder3 = cloudCAM

			for _, emitter in pairs(folder3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end, 486)
		v3:AddFrameEvent(function()
			local folder3 = quickFX({
				FX = vfx.Impact5,
				Maid = object._maid,
				Anchor = primaryPart.CFrame * vfx.Impact5:GetAttribute("Offset"):Inverse()
			})

			for _, emitter in pairs(folder3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end, 498)
		v3:AddFrameEvent(function() end, 519)
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function ConquestClient.FallEvent(p)
	local data = p.Data
	local char = data.Char
	local primaryPart = char.PrimaryPart
	local victim = data.Victim
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function FirstEvent()
		local v2 = object._maid:give(vfx["Conquest MeshEmitter"]:Clone())
		v2.Parent = EFP
		v2:PivotTo(primaryPart.CFrame * v2:GetAttribute("Offset"):Inverse())
		local v3 = MoonEmitter.new(v2)
		v3:StopTime()
		v3:Play()
		playTween(v2["bc flat speedlines"].speedline["top layer"], {
			Time = 2,
			EasingStyle = "Linear",
			Goal = {
				Transparency = NumberSequence.new(1)
			}
		})
		playTween(v2["bc flat speedlines"].speedline["beam bg"], {
			Time = 2,
			EasingStyle = "Linear",
			Goal = {
				Transparency = NumberSequence.new(1)
			}
		})
		v3:SetTime(5.333333333333333)
		local model = object._maid:give(vfx.moon.Ring3:Clone())
		model:ScaleTo(2)
		local _, v5, _ = primaryPart.CFrame:ToOrientation()
		playMesh({
			Model = model,
			T = 0,
			EndT = 1,
			Anchor = CFrame.new(victim.Torso.Position) * CFrame.Angles(0, v5, 0) * CFrame.Angles(
				1.0471975511965976,
				0,
				0
			) * CFrame.new(0, -100, 0),
			Info = TweenInfo.new(2.9, Enum.EasingStyle.Exponential)
		})
		task.spawn(function()
			local lastTime = tick()
			local count = 0

			while tick() - lastTime < 5 do
				count += 1

				if count % 2 == 0 then
					local model2 = object._maid:give(vfx.moon.Ring:Clone())
					model2:ScaleTo(1)
					local _, v7, _ = primaryPart.CFrame:ToOrientation()
					playMesh({
						Model = model2,
						T = 0.5,
						EndT = 1,
						Anchor = CFrame.new(victim.Torso.Position) * CFrame.Angles(0, v7, 0) * CFrame.Angles(
							1.0471975511965976,
							0,
							0
						) * CFrame.new(0, -100, 0),
						Info = TweenInfo.new(0.9, Enum.EasingStyle.Exponential)
					})
				end

				if count % 4 == 0 then
					local model2 = object._maid:give(vfx.moon.Ring2:Clone())
					model2:ScaleTo(0.5)
					local _, v7, _ = primaryPart.CFrame:ToOrientation()
					playMesh({
						Model = model2,
						T = 0.5,
						EndT = 1,
						Anchor = CFrame.new(victim.Torso.Position) * CFrame.Angles(0, v7, 0) * CFrame.Angles(
							1.0471975511965976,
							0,
							0
						) * CFrame.new(0, -200, 0),
						Info = TweenInfo.new(0.5, Enum.EasingStyle.Sine)
					})
				end

				dtwait(0.15)
			end
		end)

		local function WindStuff()
			local v6 = quickFX({
				FX = vfx.moon.Test,
				Maid = object._maid,
				Anchor = char:GetPivot() * CFrame.new(0, 47, 0)
			})
			game.Debris:AddItem(v6, 3.3)
			local v7 = object._maid:give(Instance.new("NumberValue"))
			object._maid:giveTask(v7.Changed:Connect(function()
				v6:ScaleTo(v7.Value)
			end))
			local v8 = object._maid:give(Instance.new("NumberValue"))
			v8.Value = 3
			TweenService:Create(v8, TweenInfo.new(1.4, Enum.EasingStyle.Sine), {
				Value = 3
			}):Play()
			v6:ScaleTo(2.1)
			v7.Value = v6:GetScale()
			TweenService:Create(v7, TweenInfo.new(4, Enum.EasingStyle.Sine), {
				Value = 1
			}):Play()
			task.spawn(function()
				local lastTime = tick()
				v6:GetPivot()
				local count = 0

				while tick() - lastTime < 1.5 do
					count += 1

					if tick() - lastTime < 1.5 then
						v6:PivotTo(CFrame.new(victim.Torso.Position) * CFrame.Angles(0, v5, 0) * CFrame.Angles(
							1.0471975511965976,
							0,
							0
						) * CFrame.Angles(3.141592653589793, 0, 0))
					end

					for i, part in pairs(v6:GetChildren()) do
						if part:IsA("BasePart") then
							part.CFrame *= CFrame.Angles(0, math.rad(i) * v8.Value, 0)
						end
					end

					dtwait(0.01)
				end
			end)
		end

		task.spawn(function()
			local folder = object._maid:give(vfx.moon.okkk:Clone())
			folder.Parent = EFP

			for _, beam in pairs(folder:GetDescendants()) do
				if beam:IsA("Beam") then
					beam.TextureSpeed *= 3
				end
			end

			game.Debris:AddItem(folder, 4)
			local lastTime = tick()
			local v6 = object._maid:give(vfx.moon.Start2:Clone())
			local cframe = nil

			while tick() - lastTime < 3.5 do
				if tick() - lastTime < 3 then
					v6:PivotTo(CFrame.new(victim.Torso.Position) * CFrame.Angles(0, v5, 0) * CFrame.Angles(
						1.0471975511965976,
						0,
						0
					) * CFrame.new(0, 10, 0) * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.Angles(
						random:NextNumber(-4, 4),
						0,
						0
					))
					folder:PivotTo(CFrame.new(victim.Torso.Position) * CFrame.Angles(0, v5, 0) * CFrame.Angles(
						1.0471975511965976,
						0,
						0
					) * CFrame.new(0, 10, 0) * CFrame.Angles(1.5707963267948966, 0, 0))
				else
					if not cframe then
						cframe = CFrame.new(victim.Torso.Position)
						game.Debris:AddItem(v6, 2)
					end

					v6:PivotTo(CFrame.new(cframe.Position) * CFrame.Angles(0, v5, 0) * CFrame.Angles(
						1.0471975511965976,
						0,
						0
					) * CFrame.new(0, 10, 0) * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.Angles(
						random:NextNumber(-4, 4),
						0,
						0
					))
				end

				v6:ScaleTo(random:NextNumber(1.9, 2.1))
				dtwait(0.001)
			end
		end)
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function ConquestClient.FirstBuild(p)
	local data = p.Data
	local primaryPart = data.Char.PrimaryPart
	local _ = data.Victim
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function FirstBuild()
		task.wait(0.5)
		playAttachment((quickFX({
			FX = vfx.moon.FirstBuild,
			Anchor = primaryPart.CFrame * vfx.moon.FirstBuild:GetAttribute("Offset"):Inverse(),
			Maid = object._maid
		})))
		Crater.FlyingRocks({
			Origin = vfx.moon.FirstBuild:GetPivot() * CFrame.new(10, 0, 0),
			Direction = "Forward",
			Amount = 7,
			MinSize = createVector(2.45, 2.45, 2.45),
			MaxSize = createVector(5.6, 5.6, 5.6),
			SpeedMin = 154,
			SpeedMax = 311.5,
			SpreadAngle = 43,
			Lifetime = 2,
			Gravity = workspace.Gravity * 0.1,
			Drag = 0.2,
			Bounciness = 0.5,
			Friction = 0.4,
			MaxBounces = 2,
			HardLifetime = 6,
			MinSpeed = 5,
			FadeTime = 0.5,
			LandSide = "up",
			Parent = workspace:FindFirstChild("Thrown"),
			done = function(anchor)
				playAttachment((quickFX({
					FX = vfx.moon.SmokeBoom,
					Maid = object._maid,
					Anchor = anchor
				})))
			end
		})
	end

	task.spawn(FirstBuild)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function ConquestClient.SecondBuild(p)
	local data = p.Data
	local primaryPart = data.Char.PrimaryPart
	local _ = data.Victim
	task.wait(0.5)
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function SecondBuild()
		playAttachment((quickFX({
			FX = vfx.moon.SecondBuild,
			Anchor = primaryPart.CFrame * vfx.moon.SecondBuild:GetAttribute("Offset"):Inverse(),
			Maid = object._maid
		})))
		Crater.FlyingRocks({
			Origin = vfx.moon.SecondBuild:GetPivot() * CFrame.new(10, 0, 0),
			Direction = "Forward",
			Amount = 7,
			MinSize = createVector(2.45, 2.45, 2.45),
			MaxSize = createVector(5.6, 5.6, 5.6),
			SpeedMin = 154,
			SpeedMax = 311.5,
			SpreadAngle = 43,
			Lifetime = 2,
			Gravity = workspace.Gravity * 0.1,
			Drag = 0.2,
			Bounciness = 0.5,
			Friction = 0.4,
			MaxBounces = 2,
			HardLifetime = 6,
			MinSpeed = 5,
			FadeTime = 0.5,
			LandSide = "up",
			Parent = workspace:FindFirstChild("Thrown"),
			done = function(anchor)
				playAttachment((quickFX({
					FX = vfx.moon.SmokeBoom,
					Maid = object._maid,
					Anchor = anchor
				})))
			end
		})
	end

	task.spawn(SecondBuild)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function ConquestClient.ThirdBuild(p)
	local data = p.Data
	local primaryPart = data.Char.PrimaryPart
	local victim = data.Victim
	task.wait(1)
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false
	local gravity = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()

			if gravity then
				workspace.Gravity = gravity
				gravity = nil
			end
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function ThirdBuild()
		local FX = quickFX({
			FX = vfx.moon.ThirdBuild,
			Anchor = primaryPart.CFrame * vfx.moon.ThirdBuild:GetAttribute("Offset"):Inverse(),
			Maid = object._maid
		})
		lifeScale({
			FX = FX,
			Scale = 3
		})
		playAttachment(FX)
		gravity = workspace.Gravity
		workspace.Gravity = workspace.Gravity * 0.1
		Crater.FlyingRocks({
			Origin = FX:GetPivot() * CFrame.new(10, 0, 0) * CFrame.Angles(0, 0, 0),
			Direction = "Forward",
			Amount = 7,
			MinSize = createVector(2.45, 2.45, 2.45),
			MaxSize = createVector(5.6, 5.6, 5.6),
			SpeedMin = 154,
			SpeedMax = 311.5,
			SpreadAngle = 43,
			Lifetime = 2,
			Gravity = workspace.Gravity * 0.1,
			Drag = 0.2,
			Bounciness = 0.5,
			Friction = 0.4,
			MaxBounces = 2,
			HardLifetime = 6,
			MinSpeed = 5,
			FadeTime = 0.5,
			LandSide = "up",
			Parent = workspace:FindFirstChild("Thrown")
		})
		task.spawn(function()
			local lastTime = tick()
			local count = 0

			while tick() - lastTime < 1.5 do
				count += 1

				if tick() - lastTime > 0.3 and count % 6 == 0 then
					local model = object._maid:give(vfx.moon.Wind:Clone())
					model:ScaleTo(1)
					local _, _, _ = primaryPart.CFrame:ToOrientation()
					playMesh({
						Model = model,
						EndT = 1,
						Anchor = CFrame.new(victim.Torso.Position, camera.CFrame.Position) * CFrame.Angles(0, 0, 0) * CFrame.Angles(
							0,
							-1.5707963267948966,
							0
						) * CFrame.Angles(random:NextNumber(-4, 4), 0, 0),
						Info = TweenInfo.new(0.9, Enum.EasingStyle.Exponential)
					})
				end

				dtwait(0.01)
			end
		end)
	end

	task.spawn(ThirdBuild)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function ConquestClient.LandEvent(p)
	local data = p.Data
	local char = data.Char
	local primaryPart = char.PrimaryPart
	local victim = data.Victim
	local camera2 = data.Camera
	warn("fireD??")
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(25, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function cancontinue()
		return true
	end

	local function LandEvent()
		local function ImpactFrames(p2, _)
			for _, impact2 in pairs(clones) do
				local v3 = tostring(p2)

				if tostring(impact2) ~= v3 then
					continue
				end

				object.Impact = impact2
				break
			end

			local impact = object.Impact

			if not impact then
				return
			end

			local v2 = 1
			local v3 = nil
			local v4 = nil
			v4 = shared.loop(function()
				local child = impact:FindFirstChild((tostring(v2)))

				if child and child ~= nil and child.Parent then
					v2 += 1
					child.Visible = true
					child.Size = UDim2.new(1, 0, 1, 0)

					if v3 then
						v3:Destroy()
					end

					v3 = child
				else
					for _, child2 in pairs(impact:GetChildren()) do
						child2:Destroy()
					end

					return v4()
				end
			end, 60)
		end

		local v2 = MechCache.Get(primaryPart)
		local v3 = object._maid:give(vfx["cutscene2 MeshEmitter"]:Clone())
		v3.Parent = EFP
		v3:PivotTo(primaryPart.CFrame * v3:GetAttribute("Offset"):Inverse())
		local v4 = MoonEmitter.new(v3)
		v4:StopTime()
		v4:Play()
		local v5 = {}

		for _, v6 in pairs({
			"Ambient",
			"Brightness",
			"ClockTime",
			"OutdoorAmbient",
			"ColorShift_Bottom",
			"ColorShift_Top",
			"EnvironmentDiffuseScale",
			"EnvironmentSpecularScale"
		}) do
			v5[v6] = game.Lighting[v6]
		end

		v4:AssignExternal("Lighting", game.Lighting)
		v4:AddFrameEvent(function()
			local v6 = object._maid:give(vfx.Bg:Clone())
			v6:PivotTo(primaryPart.CFrame * v6:GetAttribute("Offset"):Inverse())
			v6.Parent = EFP
			shared.vfx.emit(v6)
			local give = object._maid:give(vfx.Beam:Clone())
			give.Parent = camera2.camera
			local v7 = object._maid:give(vfx.ScreenEffectFall:Clone())
			v7:PivotTo(primaryPart.CFrame * v7:GetAttribute("Offset"):Inverse())
			v7.Parent = EFP
			playAttachment(v7)
		end, 1)
		v4:AddFrameEvent(function()
			local v6 = object._maid:give(vfx.ScreenEffect:Clone())
			v6:PivotTo(primaryPart.CFrame * v6:GetAttribute("Offset"):Inverse())
			v6.Parent = EFP
			shared.vfx.emit(v6)
		end, 24)
		v4:AddFrameEvent(function()
			local localPlayer = game.Players.LocalPlayer
			local s_FastMode = localPlayer:GetAttribute("S_FastMode") == true
			local s_PotatoMode = localPlayer:GetAttribute("S_PotatoMode") == true

			if s_FastMode or s_PotatoMode or shared.IsMobile then
				local v6 = object._maid:give(vfx.CloudFx_Fast:Clone())
				v6:PivotTo(primaryPart.CFrame * v6:GetAttribute("Offset"):Inverse())
				v6.Parent = EFP
				shared.vfx.emit(v6)
			else
				local v6 = object._maid:give(vfx.CloudFx:Clone())
				v6:PivotTo(primaryPart.CFrame * v6:GetAttribute("Offset"):Inverse())
				v6.Parent = EFP
				shared.vfx.emit(v6)
			end
		end, 181)
		v4:AddFrameEvent(function()
			local v6 = object._maid:give(vfx.Jet:Clone())
			v6.Parent = v2["Jetpack.Main"]
			local v7 = object._maid:give(vfx.Fall:Clone())
			v7.Parent = v2.Head
			shared.vfx.emit(v6, v7)
		end, 194)
		v4:AddFrameEvent(function()
			local v6 = object._maid:give(vfx.Fly:Clone())
			v6:PivotTo(primaryPart.CFrame * v6:GetAttribute("Offset"):Inverse())
			v6.Parent = EFP
			shared.vfx.emit(v6)
		end, 233)
		v4:AddFrameEvent(function()
			local v6 = object._maid:give(vfx.Fall2:Clone())
			v6.Parent = EFP
			v6:PivotTo(primaryPart.CFrame * v6:GetAttribute("Offset"):Inverse())
			shared.vfx.emit(v6)
		end, 330)
		v4:AddFrameEvent(function()
			local give = object._maid:give(vfx.Beam:Clone())
			give.Parent = camera2.camera
		end, 334)
		v4:AddFrameEvent(function()
			local v6 = object._maid:give(vfx.City:Clone())
			v6.Parent = EFP
			v6:PivotTo(primaryPart.CFrame * v6:GetAttribute("Offset"):Inverse())
			shared.vfx.emit(v6)

			for _ = 1, 4 do
				Crater.FlyingRocks({
					Origin = char.Mech.Position,
					Direction = "Forward",
					Amount = 10,
					MinSize = createVector(2.45, 2.45, 2.45),
					MaxSize = createVector(5.6, 5.6, 5.6),
					SpeedMin = 154,
					SpeedMax = 311.5,
					SpreadAngle = 180,
					Lifetime = 2,
					Gravity = workspace.Gravity * 0.3,
					Drag = 0.2,
					Bounciness = 0.5,
					Friction = 0.4,
					MaxBounces = 2,
					HardLifetime = 6,
					MinSpeed = 5,
					FadeTime = 0.5,
					LandSide = "up",
					Parent = workspace:FindFirstChild("Thrown")
				})
				task.wait(0.5)
			end
		end, 348)
		v4:AddFrameEvent(function()
			ImpactFrames("Impact")
		end, 358)
		v4:AddFrameEvent(function()
			local v6 = object._maid:give(vfx.stuff.EX1:Clone())

			for _, child in pairs(v6:GetChildren()) do
				child:PivotTo(primaryPart.CFrame * child:GetAttribute("Offset"):Inverse())
			end

			v6.Parent = EFP
			shared.vfx.emit(v6)
		end, 497)
		v4:AddFrameEvent(function()
			local v6 = quickFX({
				FX = vfx.stuff.BIG,
				Maid = object._maid,
				Anchor = primaryPart.CFrame * vfx.stuff.BIG:GetAttribute("Offset"):Inverse()
			})
			shared.vfx.emit(v6)
		end, 498)
		v4:AddFrameEvent(function()
			local v6 = quickFX({
				FX = vfx.stuff.firstimpact,
				Maid = object._maid,
				Anchor = primaryPart.CFrame * vfx.stuff.firstimpact:GetAttribute("Offset"):Inverse()
			})
			shared.vfx.emit(v6)
		end, 499)
		v4:AddFrameEvent(function()
			local v6 = object._maid:give(vfx.stuff.Last:Clone())

			for _, child in pairs(v6:GetChildren()) do
				child:PivotTo(primaryPart.CFrame * child:GetAttribute("Offset"):Inverse())
			end

			v6.Parent = EFP
			shared.vfx.emit(v6)
		end, 524)
		v4:AddFrameEvent(function()
			local v6 = object._maid:give(vfx.Fx:Clone())
			v6.Parent = EFP
			v6:PivotTo(primaryPart.CFrame * v6:GetAttribute("Offset"):Inverse())
			shared.vfx.emit(v6)
			task.wait(1)
			shared.originallighting()
		end, 551)

		local function First()
			local moon = vfx.moon
			local folder = quickFX({
				FX = moon.Spin,
				Maid = object._maid,
				Anchor = primaryPart.CFrame
			})
			local lastTime = tick()
			local orientation, v6, v7 = primaryPart.CFrame:ToOrientation()
			task.spawn(function()
				while tick() - lastTime < 2 do
					folder:PivotTo(CFrame.new(victim.Torso.Position) * CFrame.Angles(orientation, v6, v7) * CFrame.new(
						0,
						0,
						-3
					))
					dtwait(0.01)
				end
			end)

			for _, emitter in pairs(folder:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local rotSpeed = emitter.RotSpeed
				emitter.RotSpeed = NumberRange.new(rotSpeed.Min * 0.3, rotSpeed.Max * 0.3)
			end

			task.wait(0.4)
			able({
				FX = folder,
				On = false
			})
			local folder2 = quickFX({
				FX = moon.Bounce,
				Maid = object._maid,
				Anchor = CFrame.new(victim.Torso.Position) * CFrame.new(0, -1, -3)
			})
			folder2:ScaleTo(1.1)

			for _, emitter in pairs(folder2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					TweenService:Create(emitter, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
						TimeScale = 0.1
					}):Play()
				end
			end

			playAttachment(folder2)
		end
	end

	task.spawn(LandEvent)
	wait(25)
	Clean() -- equivalent call inferred; original call site unknown
end

function ConquestClient.ToppleEvent(p)
	local data = p.Data
	local primaryPart = data.Char.PrimaryPart
	local _ = data.Victim
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function ToppleEvent()
		task.spawn(function()
			for i = 1, 3 do
				local v2 = object._maid:give(vfx.moon.BigPunch:Clone())
				v2:ScaleTo(i * 2)

				for _, child in pairs(v2:GetChildren()) do
					child:PivotTo(primaryPart.CFrame * child:GetAttribute("Offset"):Inverse())
				end

				v2.Parent = EFP
				shared.vfx.emit(v2)
				task.wait(1)
			end
		end)
	end

	task.spawn(ToppleEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function ConquestClient.DastEvent(p)
	local data = p.Data
	local _ = data.Char.PrimaryPart
	local _ = data.Victim
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function DastEvent() end

	task.spawn(DastEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function ConquestClient.ZoomEvent(p)
	local data = p.Data
	local char = data.Char
	local primaryPart = char.PrimaryPart
	local victim = data.Victim
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function ZoomEvent()
		local v2 = object._maid:give(vfx["cutscene22 MeshEmitter"]:Clone())
		v2.Parent = EFP
		v2:PivotTo(primaryPart.CFrame * v2:GetAttribute("Offset"):Inverse())
		local v3 = MoonEmitter.new(v2)
		v3:StopTime()
		v3:Play()

		if victim then
			v3:SetTime(6.666666666666667)
		else
			v3:SetTime(8.2)
		end

		local folder = quickFX({
			FX = vfx.moon.Glow,
			Maid = object._maid,
			Anchor = primaryPart.CFrame * vfx.moon.Glow:GetAttribute("Offset"):Inverse() * CFrame.new(0, -50, 0)
		})
		folder.Attachment.BillboardGui.Enabled = true
		able({
			FX = folder,
			On = true
		})
		lifeScale({
			FX = folder,
			Scale = 0.3
		})
		task.delay(0.3, function()
			TweenService:Create(folder, TweenInfo.new(3, Enum.EasingStyle.Sine), {
				CFrame = folder:GetPivot() * CFrame.new(0, 500, 0)
			}):Play()
		end)
		task.delay(0.8, function()
			playAttachment(folder)
		end)

		for _, image in pairs(folder:GetDescendants()) do
			if not image:IsA("ImageLabel") then
				continue
			end

			local imageTransparency = image.ImageTransparency
			image.ImageTransparency = 1
			TweenService:Create(image, TweenInfo.new(2.1, Enum.EasingStyle.Sine), {
				ImageTransparency = imageTransparency
			}):Play()
		end

		Crater.FlyingRocks({
			Origin = char.Mech.Position - createVector(0, 100, 0),
			Direction = "Up",
			Amount = 30,
			MinSize = createVector(4.5499997, 4.5499997, 4.5499997),
			MaxSize = createVector(10.400001, 10.400001, 10.400001),
			SpeedMin = 156,
			SpeedMax = 448.5,
			SpreadAngle = 180,
			Lifetime = 2,
			Gravity = workspace.Gravity * 0.2,
			Drag = 0.2,
			Bounciness = 0.5,
			Friction = 0.4,
			MaxBounces = 2,
			HardLifetime = 6,
			MinSpeed = 5,
			FadeTime = 0.5,
			LandSide = "up",
			Parent = workspace:FindFirstChild("Thrown")
		})

		local function SmokeUp()
			local v4 = object._maid:give(Instance.new("Part"))
			v4.Anchored = true
			v4.CFrame = primaryPart.CFrame * CFrame.Angles(3.141592653589793, 0, 0)
			TweenService:Create(v4, TweenInfo.new(3, Enum.EasingStyle.Back), {
				CFrame = v4.CFrame * CFrame.new(0, -333, 0) * CFrame.Angles(0, 0, 0)
			}):Play()
			v4.Parent = EFP
			ZLib.MeshEmit:GroupEmit(vfx.FlyMeshes.FlyMeshes:GetChildren(), v4)
		end

		task.delay(0.1, function()
			local flyingRocks = Crater.FlyingRocks({
				Origin = camera.CFrame * CFrame.new(0, 60, -50),
				Direction = "Back",
				Amount = 16,
				Template = vfx.Cars:GetChildren()[math.random(1, #vfx.Cars:GetChildren())],
				SpeedMin = 250,
				SpeedMax = 500,
				Drag = 1,
				Gravity = workspace.Gravity * 0.2,
				SpreadAngle = 15
			})
			task.wait(1)

			for _, flyingRock in pairs(flyingRocks) do
				flyingRock:Destroy()
			end
		end)
		task.delay(1, function()
			Crater.FlyingRocks({
				Origin = char.Mech.Position,
				Direction = "Up",
				Amount = 30,
				MinSize = createVector(23.449999, 23.449999, 23.449999),
				MaxSize = createVector(53.600002, 53.600002, 53.600002),
				SpeedMin = 804,
				SpeedMax = 2311.5,
				SpreadAngle = 90,
				Lifetime = 2,
				Gravity = workspace.Gravity * 0.2,
				Drag = 0.2,
				Bounciness = 0.5,
				Friction = 0.4,
				MaxBounces = 2,
				HardLifetime = 6,
				MinSpeed = 5,
				FadeTime = 0.5,
				LandSide = "up",
				Parent = workspace:FindFirstChild("Thrown")
			})

			for _, image in pairs(folder:GetDescendants()) do
				if image:IsA("ImageLabel") then
					TweenService:Create(image, TweenInfo.new(1, Enum.EasingStyle.Sine), {
						Size = UDim2.new(0.7, 0, 0.7, 0)
					}):Play()
				end
			end

			local model = object._maid:give(vfx.moon.ZoomRing:Clone())
			model:ScaleTo(1)
			playMesh({
				Model = model,
				T = 0.5,
				EndT = 1,
				Anchor = folder:GetPivot() * CFrame.new(0, -180, 0),
				Info = TweenInfo.new(2.9, Enum.EasingStyle.Exponential)
			})
			task.wait(0.25)

			for _, image in pairs(folder:GetDescendants()) do
				if image:IsA("ImageLabel") then
					TweenService:Create(image, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
						ImageTransparency = 1
					}):Play()
				end
			end
		end)
		task.wait(0.1)
		local folder2 = quickFX({
			FX = vfx.moon.Zoom,
			Maid = object._maid,
			Anchor = primaryPart.CFrame * vfx.moon.Zoom:GetAttribute("Offset"):Inverse()
		})
		raiseZIndex({
			FX = folder2,
			Count = 100
		})
		folder2:ScaleTo(2)
		folder2:PivotTo(folder2:GetPivot() * CFrame.new(0, 30, 0))
		playAttachment(folder2)
		task.delay(0.5, function()
			local FX = quickFX({
				FX = vfx.moon.Okkk,
				Maid = object._maid,
				Anchor = primaryPart.CFrame * vfx.moon.Zoom:GetAttribute("Offset"):Inverse()
			})
			lifeScale({
				FX = FX,
				Scale = 7
			})
			FX:ScaleTo(200)
			FX:PivotTo(FX:GetPivot() * CFrame.new(0, -30, 0))
			playAttachment(FX)
			playAttachment(FX)
			playAttachment(FX)
		end)

		for _, emitter in pairs(folder2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				TweenService:Create(emitter, TweenInfo.new(4, Enum.EasingStyle.Sine), {
					TimeScale = 0.1
				}):Play()
			end
		end

		task.delay(2, function()
			local parent = object._maid:give(Instance.new("ScreenGui"))
			parent.IgnoreGuiInset = true
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 1, 0)
			frame.BackgroundColor3 = Color3.new(1, 1, 1)
			frame.Parent = parent
			parent.Parent = game.Players.LocalPlayer.PlayerGui
			task.wait(0.8)
			TweenService:Create(frame, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				BackgroundTransparency = 1
			}):Play()
		end)
	end

	task.spawn(ZoomEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function ConquestClient.StartupEvent(p)
	local data = p.Data
	local char = data.Char
	local primaryPart = char.PrimaryPart
	local _ = data.Victim
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local bind = data.bind
	local children = {}
	local v2 = {}
	bind.Destroying:Once(function()
		for _, trail in pairs(children) do
			if not trail:IsA("Trail") then
				continue
			end

			playTween(trail, {
				Time = 1,
				EasingStyle = "Sine",
				Goal = {
					Transparency = NumberSequence.new(1)
				}
			})
			game.Debris:AddItem(trail, 1)
		end

		for _, folder in pairs(v2) do
			able({
				FX = folder,
				On = false
			})

			for _, descendant in pairs(folder:GetDescendants()) do
				if descendant:IsA("Beam") then
					descendant.Enabled = false
				elseif descendant:IsA("BasePart") and descendant.Material == Enum.Material.Neon then
					TweenService:Create(descendant, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
						Transparency = 1
					}):Play()
				end
			end
		end

		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function StartupEvent()
		local count = 0

		for _, child in pairs(workspace.Live:GetChildren()) do
			if not (child:FindFirstChild("Mech") and child ~= char and child:FindFirstChild("coqnuestsetartup")) then
				continue
			end

			count += 1
			break
		end

		local function Boostersss()
			if count >= 2 then
				return
			end

			local v4 = object._maid:give(vfx.boosters:Clone())
			v4.Parent = EFP
			local v5 = MechCache.Get(primaryPart)
			local v6 = {
				["Foot.L"] = v5["Foot.L"],
				["Foot.R"] = v5["Foot.R"]
			}

			if not (bind and bind.Parent) then
				return
			end

			for _, child in pairs(vfx.ats:GetChildren()) do
				local v7 = object._maid:give(child:Clone())
				v7.Parent = v6[v7.Name]
				v7.Name = "Attachment"
				task.delay(10, function()
					if v7 and v7.Parent then
						v7:Destroy()
					end
				end)
			end

			local v7 = {}

			for _, child in pairs(v4:GetChildren()) do
				local bone = child:GetAttribute("Bone")

				if not v6[bone] then
					continue
				end

				v7[child] = {
					Offset = child:GetAttribute("Offset"),
					Bone = v6[bone]
				}
				table.insert(v2, child)
			end

			task.spawn(function()
				local lastTime = tick()

				while tick() - lastTime < 4 and bind and bind.Parent do
					for k, v8 in pairs(v7) do
						if string.match(string.lower(k.Name), "foot") then
							k:PivotTo(v8.Bone.Attachment.WorldCFrame * CFrame.new(0, 0.13, 0) * v8.Offset:Inverse())
						else
							k:PivotTo(v8.Bone.Attachment.WorldCFrame * CFrame.Angles(0, 0, 0) * v8.Offset:Inverse())
						end
					end

					dtwait(0.01)
				end

				v4:Destroy()
			end)
			local v8 = {
				["LowerLeg.L"] = v5["LowerLeg.L"],
				["LowerLeg.R"] = v5["LowerLeg.R"],
				["Jetpack.Main"] = v5["Jetpack.Main"]
			}

			for _, child in pairs(vfx.BoosterFolder:GetChildren()) do
				local parent = v8[child.Name]

				if not parent then
					continue
				end

				if not (bind and bind.Parent) then
					return
				end

				local v10 = object._maid:give(child:Clone())
				v10.Parent = parent
				task.delay(10, function()
					if v10 and v10.Parent then
						v10:Destroy()
					end
				end)

				for _, emitter in pairs(v10:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.LockedToPart = true
					end
				end

				table.insert(v2, v10)
			end

			task.delay(3, function()
				if not (bind and bind.Parent) then
					return
				end

				for _, folder in pairs(v2) do
					able({
						FX = folder,
						On = false
					})

					for _, descendant in pairs(folder:GetDescendants()) do
						if descendant:IsA("Beam") then
							descendant.Enabled = false
						elseif descendant:IsA("BasePart") and descendant.Material == Enum.Material.Neon then
							TweenService:Create(descendant, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
								Transparency = 1
							}):Play()
						end
					end
				end
			end)
		end

		Boostersss()

		if not (bind and bind.Parent) then
			return
		end

		local function Trails()
			if count >= 2 then
				return
			end

			local _ = char.Mech
			local v4 = MechCache.Get(char)

			for _, child in pairs(vfx.Trails:GetChildren()) do
				local parent = v4[child.Name]

				if not parent then
					continue
				end

				local v6 = object._maid:give(child:Clone())
				task.delay(10, function()
					if v6 and v6.Parent then
						v6:Destroy()
					end
				end)

				for _, child2 in pairs(v6:GetChildren()) do
					child2.Parent = parent
					local v8 = child2
					task.delay(10, function()
						if v8 and v8.Parent then
							v8:Destroy()
						end
					end)
					table.insert(children, child2)
				end
			end

			task.delay(2, function()
				for _, trail in pairs(children) do
					if not trail:IsA("Trail") then
						continue
					end

					playTween(trail, {
						Time = 1,
						EasingStyle = "Sine",
						Goal = {
							Transparency = NumberSequence.new(1)
						}
					})
					game.Debris:AddItem(trail, 1)
				end
			end)
		end

		task.delay(0.3, function()
			if not (bind and bind.Parent and count == 0) then
				return
			end

			playAttachment((quickFX({
				FX = vfx.Float,
				Maid = object._maid,
				Anchor = primaryPart.CFrame * CFrame.Angles(0.7853981633974483, 0, 0)
			})))
		end)
		task.spawn(function()
			if not (count == 0 and (bind and bind.Parent)) then
				return
			end

			local folder = quickFX({
				FX = vfx.ez.Float,
				Maid = object._maid,
				Anchor = primaryPart.CFrame * CFrame.Angles(0.7853981633974483, 0, 0)
			})

			for _, objectValue in pairs(folder:GetDescendants()) do
				if not objectValue:IsA("ObjectValue") then
					continue
				end

				if not (bind and bind.Parent) then
					return
				end

				local emitDuration = objectValue:GetAttribute("EmitDuration")
				local lifetime = objectValue:GetAttribute("Lifetime")

				if not emitDuration then
					continue
				end

				objectValue:SetAttribute("EmitDuration", emitDuration * 5)
				objectValue:SetAttribute("Lifetime", NumberRange.new(lifetime.Min * 1, lifetime.Max * 1))
			end

			task.wait(0.9)

			if not (bind and bind.Parent) then
				return
			end

			playAttachment(folder)
			local lastTime = tick()

			while tick() - lastTime < 1.5 and bind and bind.Parent do
				folder:PivotTo(primaryPart:GetPivot() * CFrame.Angles(1.5707963267948966, 0, 0))
				local RunService = game:GetService("RunService")
				RunService.RenderStepped:Wait()
			end

			if not (bind and bind.Parent) then
				return
			end

			local orientation, v4, v5 = primaryPart.CFrame:ToOrientation()
			local FX = quickFX({
				FX = vfx.LastJump,
				Maid = object._maid,
				Anchor = CFrame.new(primaryPart.Position) * CFrame.Angles(orientation, v4, v5)
			})
			lifeScale({
				FX = FX,
				Scale = 2
			})
			playAttachment(FX)
		end)
		Trails()
		task.wait(0.2)

		if not (bind and bind.Parent) then
			return
		end

		local raycastResult = game.Workspace:Raycast(primaryPart.Position, createVector(0, -50, 0), raycastParams)

		if raycastResult then
			local orientation, v4, v5 = primaryPart.CFrame:ToOrientation()
			local FX = quickFX({
				FX = vfx.Step,
				Maid = object._maid,
				Anchor = CFrame.new(raycastResult.Position + createVector(0, 0.2, 0)) * CFrame.Angles(
					orientation,
					v4,
					v5
				)
			})
			lifeScale({
				FX = FX,
				Scale = 2
			})
			playAttachment(FX, nil, {
				Decrease = count ~= 0 and 2 or false
			})
		end
	end

	task.spawn(StartupEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function ConquestClient.DashEvent(p)
	local data = p.Data
	local primaryPart = data.Char.PrimaryPart
	local _ = data.Victim
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local FX = nil
	local FX2 = nil
	data.bind.Destroying:Once(function()
		if FX then
			able({
				FX = FX,
				On = false
			})
		end

		if FX2 then
			able({
				FX = FX2,
				On = false
			})
		end
	end)
	local localPlayer = game.Players.LocalPlayer
	local s_FastMode = localPlayer:GetAttribute("S_FastMode") == true
	local s_PotatoMode = localPlayer:GetAttribute("S_PotatoMode") == true

	local function DashEvent()
		local FX3 = quickWeld({
			FX = vfx.Forward,
			Maid = object._maid,
			P = primaryPart,
			C0 = CFrame.new(0, 15, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
		})
		local folder = quickWeld({
			FX = vfx.Drag,
			Maid = object._maid,
			P = primaryPart,
			C0 = CFrame.new(0, 12, 1)
		})
		FX = FX3
		FX2 = folder

		if shared.IsMobile or s_FastMode or s_PotatoMode then
			for _, emitter in pairs(folder:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Rate *= 0.3
				end
			end
		end

		if not (data.bind and data.bind.Parent) then
			return
		end

		raiseZIndex({
			FX = folder,
			Count = 3
		})
		folder:ScaleTo(3)
		able({
			FX = folder,
			On = false
		})

		if not (data.bind and data.bind.Parent) then
			return
		end

		able({
			FX = FX3,
			On = false
		})
		task.delay(0.1, function()
			if data.bind and data.bind.Parent then
				able({
					FX = folder,
					On = true
				})
			end
		end)
		task.delay(1.35, function()
			if data.bind and data.bind.Parent then
				able({
					FX = FX3,
					On = false
				})
				able({
					FX = folder,
					On = false
				})
			end
		end)
	end

	task.spawn(DashEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function ConquestClient.DashEndEvent(p)
	local data = p.Data
	local char = data.Char
	local primaryPart = char.PrimaryPart
	local victim = data.Victim
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not flag then
			flag = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function DashEndEvent()
		if not (data.bind and data.bind.Parent) then
			return
		end

		local count = 0

		for _, child in pairs(workspace.Live:GetChildren()) do
			if not (child:FindFirstChild("Mech") and child ~= char and child:FindFirstChild("coqnuestsetartup")) then
				continue
			end

			count += 1
			break
		end

		local v2 = quickFX({
			FX = vfx.DashEnd,
			Maid = object._maid,
			Anchor = primaryPart.CFrame * CFrame.new(0, -12, -20) * CFrame.Angles(-1.5707963267948966, 0, 0)
		})
		v2:ScaleTo(3)
		playAttachment(v2, nil, {
			Decrease = count == 1 and 1.85 or count == 2 and 2.5 or false
		})
		Crater.FlyingRocks({
			Origin = primaryPart.CFrame * CFrame.new(0, -7, -10),
			Direction = "Forward",
			Amount = count == 0 and 13 or 5,
			MinSize = createVector(2.45, 2.45, 2.45),
			MaxSize = createVector(5.6, 5.6, 5.6),
			SpeedMin = 154,
			SpeedMax = 311.5,
			SpreadAngle = 43,
			Lifetime = 2,
			Gravity = workspace.Gravity,
			Drag = 0.2,
			Bounciness = 0.5,
			Friction = 0.4,
			MaxBounces = 2,
			HardLifetime = 6,
			MinSpeed = 5,
			FadeTime = 0.5,
			LandSide = "up",
			Parent = workspace:FindFirstChild("Thrown"),
			done = function(anchor)
				playAttachment((quickFX({
					FX = vfx.moon.SmokeBoom,
					Maid = object._maid,
					Anchor = anchor
				})))
			end
		})

		if victim then
			for _, childName in pairs({
				"Right Arm",
				"Left Arm",
				"Right Leg",
				"Left Leg",
				"Head",
				"Torso"
			}) do
				local child = victim:FindFirstChild(childName)

				if not child then
					continue
				end

				local v3 = object._maid:give(vfx.Trailstuf:Clone())

				for _, child2 in pairs(v3:GetChildren()) do
					child2.Parent = child
					object._maid:give(child2)
				end
			end

			task.spawn(function()
				local FX = object._maid:give(vfx.VictimWind:Clone())
				FX.Parent = EFP
				local lastTime = tick()
				local position = victim.Torso.Position

				while tick() - lastTime < 2 do
					if data.bind and data.bind.Parent then
						if position ~= victim.Torso.Position then
							FX:PivotTo(CFrame.new(victim.Torso.Position, position))
						end

						position = victim.Torso.Position
						local RunService = game:GetService("RunService")
						RunService.RenderStepped:Wait()
					else
						if flag then
							break
						end

						flag = true
						object._maid:doCleaning()
						break
					end
				end

				able({
					FX = FX,
					On = false
				})
			end)
		end
	end

	task.spawn(DashEndEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function ConquestClient.DoneDashEvent(p)
	local data = p.Data
	local primaryPart = data.Char.PrimaryPart
	local _ = data.Victim
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function DoneDashEvent()
		local raycastResult = game.Workspace:Raycast(
			primaryPart.CFrame * CFrame.new(0, 0, -5).Position,
			createVector(0, -50, 0),
			raycastParams
		)

		if raycastResult then
			local _, _, _ = primaryPart.CFrame:ToOrientation()
			local v2 = quickFX({
				FX = vfx.DashEnd,
				Maid = object._maid,
				Anchor = CFrame.new(raycastResult.Position)
			})
			v2:ScaleTo(1)
			playAttachment(v2)
		end
	end

	task.spawn(DoneDashEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function ConquestClient.RunEvent(p)
	local data = p.Data
	local primaryPart = data.Char.PrimaryPart
	local _ = data.Victim
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function RunEvent()
		local WAIT_INTERVAL = 0.2

		local function Step()
			local raycastResult = game.Workspace:Raycast(primaryPart.Position, createVector(0, -50, -14), raycastParams)

			if raycastResult then
				local orientation, v2, v3 = primaryPart.CFrame:ToOrientation()
				local FX = quickFX({
					FX = vfx.RunStep,
					Maid = object._maid,
					Anchor = CFrame.new(raycastResult.Position + createVector(0, 0.2, 0)) * CFrame.Angles(
						orientation,
						v2,
						v3
					)
				})
				FX:ScaleTo(random:NextNumber(0.8, 0.9))
				lifeScale({
					FX = FX,
					Scale = 0.2
				})
				playAttachment(FX)
			end
		end

		task.wait(WAIT_INTERVAL)
		Step()
		task.wait(WAIT_INTERVAL)
		Step()
		task.wait(WAIT_INTERVAL)
		Step()
		task.wait(WAIT_INTERVAL)
		Step()
		task.wait(WAIT_INTERVAL)
		Step()
		task.wait(WAIT_INTERVAL)
		Step()
		task.wait(0.1)
		Step()
		local raycastResult = game.Workspace:Raycast(primaryPart.Position, createVector(0, -50, -14), raycastParams)

		if raycastResult then
			local orientation, v2, v3 = primaryPart.CFrame:ToOrientation()
			local FX = quickFX({
				FX = vfx.RunStep,
				Maid = object._maid,
				Anchor = CFrame.new(raycastResult.Position + createVector(0, 0.2, 0)) * CFrame.Angles(
					orientation,
					v2,
					v3
				)
			})
			FX:ScaleTo(3)
			lifeScale({
				FX = FX,
				Scale = 2
			})
			playAttachment(FX)
		end
	end

	task.spawn(RunEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function ConquestClient.JumpEvent(p)
	local data = p.Data
	local primaryPart = data.Char.PrimaryPart
	local _ = data.Victim
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function JumpEvent()
		local folder = nil
		local folder2 = nil
		local folder3 = nil

		local function Test()
			local v2 = object._maid:give(Instance.new("NumberValue"))
			v2.Value = 1
			task.delay(0.2, function()
				local raycastResult = game.Workspace:Raycast(
					primaryPart.Position,
					createVector(0, -50, -14),
					raycastParams
				)

				if raycastResult then
					local orientation, v3, v4 = primaryPart.CFrame:ToOrientation()
					local FX = quickFX({
						FX = vfx.Burn,
						Maid = object._maid,
						Anchor = CFrame.new(raycastResult.Position + createVector(0, 0, 0)) * CFrame.Angles(
							orientation,
							v3,
							v4
						)
					})
					FX:ScaleTo(0.5)
					lifeScale({
						FX = FX,
						Scale = 2
					})
					playAttachment(FX)
				end
			end)
			local folders = {}
			folder = object._maid:give(vfx.Booster3:Clone())
			raiseZIndex({
				FX = folder,
				Count = 10
			})
			folder2 = object._maid:give(vfx.Booster:Clone())
			folder3 = object._maid:give(vfx.Booster:Clone())

			if shared.IsMobile or fastOn or potatoOn then
				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Rate *= 0.3
					end
				end

				for _, emitter in pairs(folder2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Rate *= 0.3
					end
				end

				for _, emitter in pairs(folder3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Rate *= 0.3
					end
				end
			end

			table.insert(folders, folder2)
			table.insert(folders, folder)
			folder.Parent = EFP
			folder2.Parent = EFP
			folder3.Parent = EFP
			local v3 = MechCache.Get(primaryPart)
			local waist = v3.Waist
			local v4 = {}
			local v5 = object._maid:give(Instance.new("NumberValue"))
			local v6 = object._maid:give(Instance.new("NumberValue"))
			object._maid:giveTask(v6.Changed:Connect(function()
				for _, v7 in pairs(folders) do
					if v7.Name == "Wind" then
						v7:ScaleTo(v6.Value * 0.7)
					else
						v7:ScaleTo(v6.Value)
					end
				end
			end))
			object._maid:giveTask(v5.Changed:Connect(function()
				for _, folder4 in pairs(folders) do
					for _, emitter in pairs(folder4:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local speed, lifetime, rate

						if v4[emitter] then
							speed = v4[emitter].Speed
							lifetime = v4[emitter].Lifetime
							rate = v4[emitter].Rate
						else
							speed = emitter.Speed
							lifetime = emitter.Lifetime
							rate = emitter.Rate
							v4[emitter] = {
								Speed = emitter.Speed,
								Lifetime = emitter.Lifetime,
								Rate = emitter.Rate
							}
						end

						emitter.Speed = NumberRange.new(speed.Min * v5.Value, speed.Max * v5.Value)
						emitter.Lifetime = NumberRange.new(lifetime.Min / v5.Value, lifetime.Max / v5.Value)
						emitter.Rate = rate * v5.Value
					end
				end
			end))
			v5.Value = 1
			v6.Value = 0.5
			TweenService:Create(v6, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
				Value = 2.8
			}):Play()
			TweenService:Create(v5, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
				Value = 2.8
			}):Play()
			local v7 = object._maid:give(Instance.new("PointLight"))
			v7.Brightness = 1
			v7.Color = Color3.new(1, 0.501961, 0)
			TweenService:Create(v7, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
				Range = 20
			}):Play()
			v7.Parent = waist
			game.Debris:AddItem(v7, 3)
			task.delay(1.5, function()
				able({
					FX = folder,
					On = false
				})
				able({
					FX = folder2,
					On = false
				})
				able({
					FX = folder3,
					On = false
				})
			end)
			task.spawn(function()
				local lastTime = tick()
				local count = 0

				while tick() - lastTime < 3 do
					count += 1
					folder:PivotTo(waist.WorldCFrame * CFrame.new(-4, -3, 0) * CFrame.Angles(3.141592653589793, 0, 0))
					folder2:PivotTo(waist.WorldCFrame * CFrame.new(-4, -2 + v6.Value, 0) * CFrame.Angles(
						3.141592653589793,
						0,
						0
					))
					folder3:PivotTo(waist.WorldCFrame * CFrame.new(-4, -2 + v6.Value, 0) * CFrame.Angles(
						3.141592653589793,
						0,
						0
					))

					for _, v8 in pairs(folders) do
						if v8.Name == "Wind" then
							v8:PivotTo(v8:GetPivot():Lerp(
								waist.Parent.WorldCFrame * CFrame.new(-4, -7 * v6.Value, 0) * CFrame.Angles(
									-1.5707963267948966,
									0,
									0
								),
								v2.Value
							))
						end
					end

					if count % 11 == 0 and tick() - lastTime < 1.5 and tick() - lastTime > 0.3 then
						local model = object._maid:give(vfx.Balls:Clone())
						model:ScaleTo(2)
						playMesh({
							Model = model,
							Anchor = v3.Root.WorldCFrame * CFrame.new(0, 0, 0) * CFrame.Angles(
								-0.4363323129985824,
								0,
								-1.5707963267948966
							),
							Info = TweenInfo.new(0.3, Enum.EasingStyle.Sine)
						})
					end

					dtwait(0.01)
				end

				task.wait(6)
				Clean() -- equivalent call inferred; original call site unknown
			end)
			print(folder)
		end

		Test()
	end

	task.spawn(JumpEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function ConquestClient.ComebackEvent(p)
	local data = p.Data
	local char = data.Char
	local primaryPart = char.PrimaryPart
	local _ = data.Victim
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function ComebackEvent()
		local v2 = object._maid:give(vfx["Comeback MeshEmitter"]:Clone())

		if game.Players.LocalPlayer.Character ~= char then
			v2.Blur:Destroy()
		end

		v2.Parent = EFP
		v2:PivotTo(primaryPart.CFrame * v2:GetAttribute("Offset"):Inverse())
		local v3 = MoonEmitter.new(v2)
		v3:StopTime()
		v3:Play()
		shared.vfx.emit(v2.Part_Assembly.vfx.mechFALL)
		local v4 = MechCache.Get(primaryPart)
		local v5 = {
			["LowerLeg.L"] = v4["LowerLeg.L"],
			["LowerLeg.R"] = v4["LowerLeg.R"],
			["Jetpack.Main"] = v4["Jetpack.Main"]
		}
		local v6 = nil

		for _, child in pairs(vfx.JetStuff:GetChildren()) do
			local v7 = object._maid:give(child:Clone())
			v7.Parent = v5["Jetpack.Main"]
			task.delay(10, function()
				if v7 and v7.Parent then
					v7:Destroy()
				end
			end)

			if v7.Name == "Jet" then
				v6 = v7
			end
		end

		shared.vfx.emit(v6)
		v3:AddFrameEvent(function()
			shared.vfx.emit(v2.Part_Assembly.vfx.mechFALL2)
		end, 131)
		v3:AddFrameEvent(function()
			local v7 = object._maid:give(vfx.Impact1:Clone())

			for _, child in pairs(v7:GetChildren()) do
				child:PivotTo(primaryPart.CFrame * child:GetAttribute("Offset"):Inverse())
			end

			v7.Parent = EFP
			shared.vfx.emit(v7)
		end, 206)
		v3:AddFrameEvent(function()
			local v7 = object._maid:give(vfx.Impact22:Clone())

			for _, child in pairs(v7:GetChildren()) do
				child:PivotTo(primaryPart.CFrame * child:GetAttribute("Offset"):Inverse())
			end

			v7.Parent = EFP
			shared.vfx.emit(v7)
		end, 212)
		v3:AddFrameEvent(function()
			local v7 = object._maid:give(vfx.Impact33:Clone())

			for _, child in pairs(v7:GetChildren()) do
				child:PivotTo(primaryPart.CFrame * child:GetAttribute("Offset"):Inverse())
			end

			v7.Parent = EFP
			shared.vfx.emit(v7)
		end, 221)
		v3:AddFrameEvent(function()
			local v7 = object._maid:give(vfx.Impact33:Clone())

			for _, child in pairs(v7:GetChildren()) do
				child:PivotTo(primaryPart.CFrame * child:GetAttribute("Offset"):Inverse())
			end

			v7.Parent = EFP
			shared.vfx.emit(v7)
		end, 234)
		v3:AddFrameEvent(function()
			local v7 = object._maid:give(vfx.Fall22:Clone())

			for _, child in pairs(v7:GetChildren()) do
				child:PivotTo(primaryPart.CFrame * child:GetAttribute("Offset"):Inverse())
			end

			v7.Parent = EFP
			shared.vfx.emit(v7)
		end, 244)
		v3:AddFrameEvent(function()
			local v7 = object._maid:give(vfx.Preheat:Clone())
			v7:PivotTo(primaryPart.CFrame * v7:GetAttribute("Offset"):Inverse())
			v7.Parent = EFP
			shared.vfx.emit(v7)
		end, 247)
		v3:AddFrameEvent(function()
			local v7 = object._maid:give(vfx.ComeLand:Clone())
			v7:PivotTo(primaryPart.CFrame * vfx.Preheat:GetAttribute("Offset"):Inverse() * CFrame.new(0, -10, 0))
			v7.Parent = EFP
			v7:ScaleTo(1)
			playAttachment(v7)
			local v8 = object._maid:give(vfx.EX:Clone())

			for _, child in pairs(v8:GetChildren()) do
				child:PivotTo(primaryPart.CFrame * child:GetAttribute("Offset"):Inverse())
			end

			v8.Parent = EFP
			shared.vfx.emit(v8)
			local raycastResult = game.Workspace:Raycast(primaryPart.Position, createVector(0, -50, 0), raycastParams)

			if raycastResult then
				Crater.FlyingRocks({
					Origin = raycastResult.Position,
					Direction = "Up",
					Amount = 7,
					MinSize = createVector(1.75, 1.75, 1.75),
					MaxSize = createVector(4, 4, 4),
					SpeedMin = 110,
					SpeedMax = 222.5,
					SpreadAngle = 43,
					Lifetime = 2,
					Gravity = workspace.Gravity * 1,
					Drag = 0.2,
					Bounciness = 0.5,
					Friction = 0.4,
					MaxBounces = 2,
					HardLifetime = 6,
					MinSpeed = 5,
					FadeTime = 0.5,
					LandSide = "up",
					Parent = workspace:FindFirstChild("Thrown")
				})
			end
		end, 270)
	end

	task.spawn(ComebackEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return ConquestClient
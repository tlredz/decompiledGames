local createVector = vector.create
local OutsideV2 = {}
local library = require(game.ReplicatedStorage.library)
local playAttachment = library.PlayAttachment
local maid = library.Maid
local playTween = library.PlayTween
local _ = library.CamShake
local _ = library.PlayFlipBook
local dtwait = library.dtwait
local EFP = library.EFP
local _ = library.PlayMesh
local _ = library.Impact
local _ = library.GlassLight
local raiseZIndex = library.RaiseZIndex
local able = library.Able
local _ = library.LifeScale
local quickFX = library.QuickFX
local _ = library.QuickWeld
local _ = library.Yield
local _ = library.ProcessPart
local _ = library.WeldObject
local _ = library.Bezier
local _ = library.EditableMeshShader
local vfx = script.vfx
local class = {}
class.__index = class
local random = Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera
local MoonEmitter = require(game.ReplicatedStorage.Resources.MoonEmitter)
local BezierChargeEffect = require(game.ReplicatedStorage.Emotes.VFX.VfxMods.libraryNew.BezierChargeEffect)

function OutsideV2.FirstEvent(p)
	local char = p.Char
	local humanoidRootPart = char:WaitForChild("HumanoidRootPart", 5)
	local humanoid = char:WaitForChild("Humanoid")

	if not humanoidRootPart then
		return
	end

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

	task.delay(35, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local module = require(char.CharacterHandler:FindFirstChild("AnimationPlayer") or char.CharacterHandler:WaitForChild("AnimationPlayer"))

	local function fn(p2)
		return module.playAnimation(game.FindFirstChild(char, "Humanoid"), p2)
	end

	local now = tick()
	local v2 = fn(91416745478196)
	v2:Play()
	shared.sfx({
		SoundId = "rbxassetid://74318442608519",
		Volume = 4,
		RollOffMaxDistance = 160,
		Parent = char.PrimaryPart,
		RollOffMode = Enum.RollOffMode.LinearSquare
	}):Play()
	local cFrame4 = char.PrimaryPart.CFrame * CFrame.new(0, 100, 0)
	local sfx = shared.sfx({
		SoundId = "rbxassetid://83004299542811",
		Volume = 3,
		RollOffMaxDistance = 240,
		CFrame = char.PrimaryPart.CFrame * CFrame.new(0, 7, 0),
		RollOffMode = Enum.RollOffMode.LinearSquare
	})
	sfx:Play()
	local TweenService2 = game:GetService("TweenService")
	TweenService2:Create(sfx.Parent, TweenInfo.new(3.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		CFrame = sfx.Parent.CFrame * CFrame.new(0, 10, 0)
	}):Play()
	task.delay(4, function()
		warn("agfain")
		local TweenService3 = game:GetService("TweenService")
		TweenService3:Create(sfx.Parent, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			CFrame = sfx.Parent.CFrame * CFrame.new(0, 10, 0)
		}):Play()
	end)
	local TweenService3 = game:GetService("TweenService")
	TweenService3:Create(sfx, TweenInfo.new(3.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Volume = 6
	}):Play()
	task.spawn(function()
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://105255202525634"
		sound.Volume = 0
		sound:SetAttribute("ExemptAtt", true)
		sound.RollOffMaxDistance = 950
		sound.RollOffMode = Enum.RollOffMode.LinearSquare
		local attachment = Instance.new("Attachment")
		attachment.Parent = workspace.Terrain
		attachment:SetAttribute("ExemptAtt", true)
		attachment.WorldCFrame = char.PrimaryPart.CFrame * CFrame.new(0, 150, 0)
		sound.Parent = attachment
		task.delay(30, function()
			if attachment and attachment.Parent then
				attachment:Destroy()
			end
		end)
		sound:Play()
		local TweenService4 = game:GetService("TweenService")
		TweenService4:Create(sound, TweenInfo.new(8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Volume = 4.5
		}):Play()
	end)
	task.delay(1, function()
		v2.TimePosition = 1
	end)
	local v4 = { "rbxassetid://107114358965793", "rbxassetid://99080785512879", "rbxassetid://80897999245441" }

	local function fn2()
		for _, v5 in pairs(humanoid:GetPlayingAnimationTracks()) do
			if table.find(v4, v5.Animation.AnimationId) then
				v5:Stop()
			end
		end
	end

	fn2()
	object._maid:give(humanoid.AnimationPlayed:Connect(function(p2)
		if table.find(v4, p2.Animation.AnimationId) then
			fn2()
		end
	end))
	local v5 = { "rbxassetid://107114358965793", "rbxassetid://990807855128793" }
	task.spawn(function()
		local lastTime = tick()

		while tick() - lastTime < 20 and char.Parent and humanoid and humanoid.Parent do
			for _, v6 in pairs(humanoid:GetPlayingAnimationTracks()) do
				if not table.find(v5, v6.Animation.AnimationId) then
					continue
				end

				v6:Stop()
				print("STOp")
			end

			dtwait(0.1)
		end
	end)

	local function FirstEvent()
		task.spawn(function()
			local clone = vfx["LilUpdate MeshEmitter"]:Clone()
			clone.Parent = EFP
			game.Debris:AddItem(clone, 16)
			local v6 = MoonEmitter.new(clone)
			v6:SetAnchor(humanoidRootPart.CFrame * clone:GetAttribute("Offset"):Inverse())
			v6:Play()
			v6:AssignExternal("Mesh", clone.vfx.storm1.Mesh)
			local transparency = clone.vfx.storm1.StormDecal.Transparency
			clone.vfx.storm1.StormDecal.Transparency = 1
			task.delay(0.5, function()
				TweenService:Create(clone.vfx.storm1.StormDecal, TweenInfo.new(1, Enum.EasingStyle.Sine), {
					Transparency = transparency
				}):Play()
			end)
			task.wait(0.2)
			playAttachment(clone.GoUp)
			playAttachment(clone.Wind)
		end)
		local nested = vfx.nested
		local clone = nested["dast1 MeshEmitter"]:Clone()
		clone.Parent = EFP
		game.Debris:AddItem(clone, 16)
		local cFrame = humanoidRootPart.CFrame
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { game.Workspace.Map, game.Workspace.Built }
		local cFrame2 = humanoidRootPart.CFrame
		local raycastResult = game.Workspace:Raycast(cFrame.Position, createVector(0, -10000, 0), raycastParams)

		if raycastResult then
			cFrame2 = CFrame.new(cFrame.Position.X, raycastResult.Position.Y, cFrame.Position.Z)
		end

		local v6 = MoonEmitter.new(clone)
		v6:SetAnchor(humanoidRootPart.CFrame)
		v6:Play()
		local cFrame3 = humanoidRootPart.CFrame
		local cFrameValue = Instance.new("CFrameValue")
		cFrameValue.Parent = game.Players.LocalPlayer.Character
		game.Debris:AddItem(cFrameValue, 30)
		v6:AssignExternal("endermen20008", cFrameValue, { "CFrame" })
		local lastTime = tick()
		task.spawn(function()
			while tick() - lastTime < 10 do
				if not (humanoidRootPart and humanoidRootPart.Parent and cFrameValue and cFrameValue.Parent) then
					break
				end

				local _, v7, _ = humanoidRootPart.CFrame:ToOrientation()
				humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(
					CFrame.new(
						humanoidRootPart.Position.X,
						cFrameValue.Value.Position.Y - 3,
						humanoidRootPart.Position.Z
					) * CFrame.Angles(0, v7, 0),
					0.1
				)
				local RunService = game:GetService("RunService")
				RunService.RenderStepped:Wait()
			end
		end)
		local v7 = object._maid:give(Instance.new("Highlight"))
		v7.Parent = char
		v6:AssignExternal("Highlight", v7)

		local function Trails()
			task.spawn(function()
				local v8 = {}
				local cframe = CFrame.new(0, -20, 0)
				task.spawn(function()
					for _ = 1, 20 do
						for _ = 1, 1 do
							local clone2 = nested.Part3:Clone()
							clone2.Shape = Enum.PartType.Ball
							clone2.Material = Enum.Material.Neon
							clone2.Parent = EFP
							clone2.Color = Color3.fromRGB(255, 255, 255)
							task.delay(10, function()
								if clone2 and clone2.Parent then
									clone2:Destroy()
								end
							end)
							object._maid:give(clone2)
							local v10 = random:NextNumber(0.2, 0.4) * 4
							clone2.Size = Vector3.new(v10, v10, v10)
							clone2.CFrame = cframe * CFrame.new(
								random:NextNumber(-20, 20),
								random:NextNumber(-20, 0),
								random:NextNumber(-20, 20)
							)
							local number = random:NextNumber(2, 3)
							local range = object._maid:give(Instance.new("NumberValue"))
							range.Value = random:NextNumber(10, 45)
							TweenService:Create(clone2, TweenInfo.new(number, Enum.EasingStyle.Sine), {
								Size = clone2.Size * 1.5
							}):Play()
							local v12 = clone2
							task.delay(number, function()
								TweenService:Create(v12, TweenInfo.new(number, Enum.EasingStyle.Sine), {
									Size = createVector(0, 0, 0)
								}):Play()
							end)
							v8[clone2] = {
								Range = range,
								Orientation = CFrame.Angles(
									math.rad((math.random(0, 360))),
									math.rad((math.random(0, 360))),
									(math.rad((math.random(0, 360))))
								),
								Speed = random:NextNumber(0.1, 1) * 0.1,
								Rise = random:NextNumber(0.05, 0.3) * 11
							}
						end

						task.wait(0.2)
					end
				end)
				local lastTime2 = tick()
				local count = 0

				while tick() - lastTime2 < 17.4 do
					count += 1

					for k, v9 in pairs(v8) do
						if k and k.Parent then
							k.CFrame *= CFrame.new(0, v9.Rise, 0)
						else
							v8[k] = nil
						end
					end

					dtwait(0.01)
				end
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function Bezier()
			task.spawn(function()
				task.wait(1.5)
				local lastTime2 = tick()

				while tick() - lastTime2 < 6 do
					if tick() - lastTime2 < 1.3 then
						BezierChargeEffect.Create(humanoidRootPart.CFrame, {
							Count = 1,
							Lifetime = random:NextNumber(2, 3),
							ParticleTemplate = nested.Part3
						})
					else
						BezierChargeEffect.Create(humanoidRootPart.CFrame * CFrame.new(0, 50, 0), {
							Count = 1,
							Lifetime = random:NextNumber(2, 3),
							ParticleTemplate = nested.Part3,
							SwirlStrength = random:NextNumber(3, 10),
							SpawnRadius = 100,
							ControlPointHeight = random:NextNumber(-50, 50)
						})
					end

					task.wait(0.2)
				end
			end)
		end

		v6:AddFrameEvent(function()
			Bezier() -- equivalent call inferred; original call site unknown
			warn("f")
		end, 47)
		v6:AddFrameEvent(function()
			local v8 = quickFX({
				FX = nested.smallishbeam1,
				Maid = object._maid,
				Anchor = cFrame
			})
			shared.vfx.emit(v8)
		end, 214)
		v6:AddFrameEvent(function()
			local give = object._maid:give(nested.Part2floater:Clone())
			give.Parent = char.Torso
			warn("here?")
		end, 300)
		v6:AddFrameEvent(function() end, 377)
		warn(";here?")
		task.wait(0.5)
		local v8 = quickFX({
			FX = nested.Downsmoke1,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * nested.Downsmoke1:GetAttribute("Offset"):Inverse()
		})
		shared.vfx.emit(v8)
		task.wait(1.8)
		local v9 = quickFX({
			FX = nested.Downsmoke2,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * nested.Downsmoke2:GetAttribute("Offset"):Inverse()
		})
		shared.vfx.emit(v9)
		local v10 = humanoidRootPart.CFrame * CFrame.new(-30, 0, -17.5)
		task.wait(17.25)
		local Mrcoolthing = require(script.Parent.Mrcoolthing)
		Mrcoolthing.pillarthingyemit(cFrame2, now)
		task.delay(1.365, function()
			local sfx2 = shared.sfx({
				SoundId = "rbxassetid://80152988297518",
				Volume = 3,
				RollOffMaxDistance = 500,
				CFrame = cFrame4,
				RollOffMode = Enum.RollOffMode.LinearSquare
			})
			sfx2:Play()
			local TweenService4 = game:GetService("TweenService")
			TweenService4:Create(sfx2.Parent, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				CFrame = cFrame4 * CFrame.new(0, -100, 0)
			}):Play()
			local TweenService5 = game:GetService("TweenService")
			TweenService5:Create(sfx2, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Volume = 7
			}):Play()
		end)
		task.wait(2.2)
		task.wait(2)
		char:PivotTo(cFrame3)
		humanoidRootPart.Anchored = false
		v6:AddFrameEvent(function()
			local v11 = quickFX({
				FX = nested.ok,
				Maid = object._maid,
				Anchor = v10 * nested.ok:GetAttribute("Offset"):Inverse()
			})
			shared.vfx.emit(v11)
		end, 38)
		v6:AddFrameEvent(function()
			local v11 = quickFX({
				FX = nested.ex,
				Maid = object._maid,
				Anchor = v10 * nested.ex:GetAttribute("Offset"):Inverse()
			})
			shared.vfx.emit(v11)
		end, 50)
		v6:AddFrameEvent(function()
			local v11 = object._maid:give(nested.Light2:Clone())

			for _, child in pairs(v11:GetChildren()) do
				if child:IsA("BasePart") or child:IsA("Model") then
					child:PivotTo(v10 * child:GetAttribute("Offset"):Inverse())
				end
			end

			v11.Parent = EFP
			shared.vfx.emit(v11)
		end, 119)
		v6:AddFrameEvent(function()
			local v11 = object._maid:give(nested.Light3:Clone())

			for _, child in pairs(v11:GetChildren()) do
				if child:IsA("BasePart") or child:IsA("Model") then
					child:PivotTo(v10 * child:GetAttribute("Offset"):Inverse())
				end
			end

			v11.Parent = EFP
			shared.vfx.emit(v11)
		end, 136)
		v6:AddFrameEvent(function()
			local v11 = object._maid:give(nested.BallGrow:Clone())

			for _, child in pairs(v11:GetChildren()) do
				if child:IsA("BasePart") or child:IsA("Model") then
					child:PivotTo(v10 * child:GetAttribute("Offset"):Inverse())
				end
			end

			v11.Parent = EFP
			shared.vfx.emit(v11)
		end, 139)
		v6:AddFrameEvent(function()
			local v11 = object._maid:give(nested.Burst:Clone())

			for _, child in pairs(v11:GetChildren()) do
				if child:IsA("BasePart") or child:IsA("Model") then
					child:PivotTo(v10 * child:GetAttribute("Offset"):Inverse())
				end
			end

			v11.Parent = EFP
			shared.vfx.emit(v11)
		end, 154)
		v6:AddFrameEvent(function()
			local folder = object._maid:give(nested.VFX2:Clone())

			for _, child in pairs(folder:GetChildren()) do
				if child:IsA("BasePart") or child:IsA("Model") then
					child:PivotTo(v10 * child:GetAttribute("Offset"):Inverse())
				elseif child:IsA("Folder") then
					for _, child2 in pairs(child:GetChildren()) do
						if child2:IsA("BasePart") or child2:IsA("Model") then
							child2:PivotTo(v10 * child2:GetAttribute("Offset"):Inverse())
						end
					end
				end
			end

			for _, descendant in pairs(folder:GetDescendants()) do
				local effectDuration = descendant:GetAttribute("EffectDuration")

				if not (effectDuration and effectDuration.Min < 0.1) then
					continue
				end

				descendant:SetAttribute("Rate", 0)
				print("UPDATED")
			end

			folder.Parent = EFP
			shared.vfx.emit(folder)
		end, 180)
	end

	task.spawn(FirstEvent)
	wait(30)
	Clean() -- equivalent call inferred; original call site unknown
end

function OutsideV2.StormEvent(p)
	local char = p.Char
	local humanoidRootPart = char:WaitForChild("HumanoidRootPart", 5)
	char:WaitForChild("Humanoid")
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

	task.delay(35, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function StormEvent()
		local vfx2 = script.vfx
		local random2 = Random.new()
		local TweenService2 = game:GetService("TweenService")
		local v2 = {}
		local cFrame = humanoidRootPart.CFrame
		local clone = vfx2.Storm:Clone()
		clone:PivotTo(cFrame * CFrame.new(0, 610, 0) * CFrame.Angles(0, 0, 1.5707963267948966))
		clone.Parent = EFP
		local objectValue = Instance.new("ObjectValue")
		objectValue.Value = clone
		objectValue.Parent = game.Workspace.Terrain
		task.delay(30, function()
			if objectValue.Parent then
				objectValue:Destroy()
			end
		end)
		local clone2 = vfx2.Nice:Clone()
		table.insert(v2, clone2)
		clone2:PivotTo(clone:GetPivot() * clone2:GetAttribute("Offset"):Inverse())
		clone2.Parent = EFP

		for _, beam in pairs(clone2:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			local transparency = beam.Transparency
			beam.Transparency = NumberSequence.new(1)
			playTween(beam, {
				Time = random2:NextNumber(2, 4),
				EasingStyle = "Sine",
				Goal = {
					Transparency = transparency
				}
			})
		end

		local clone3 = vfx2.Glow:Clone()
		table.insert(v2, clone3)
		clone3:PivotTo(clone:GetPivot() * clone3:GetAttribute("Offset"):Inverse())
		raiseZIndex({
			FX = clone3,
			Count = 270
		})

		for _, descendant in pairs(clone3:GetDescendants()) do
			if descendant:IsA("Decal") then
				descendant.Transparency = 1
				TweenService2:Create(descendant, TweenInfo.new(3, Enum.EasingStyle.Sine), {
					Transparency = 0
				}):Play()
			elseif descendant:IsA("Beam") then
				local transparency = descendant.Transparency
				descendant.Transparency = NumberSequence.new(1)
				playTween(descendant, {
					Time = 1,
					EasingStyle = "Sine",
					Goal = {
						Transparency = transparency
					}
				})
			end
		end

		clone3.Parent = EFP
		local v3 = {}
		local descendants = {}
		local descendants2 = {}

		for i, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("BasePart") and string.match(string.lower(descendant.Name), "cloud") then
				if i % 5 == 0 then
					local clone4 = vfx2.WindShockwave:Clone()
					clone4.Size *= 12
					clone4:PivotTo(descendant.CFrame * CFrame.Angles(0, 0, -1.5707963267948966))
					clone4.Parent = EFP
					clone4.Transparency = 1
					table.insert(v2, clone4)
					v3[descendant] = {
						Speed = random2:NextNumber(0.1, 0.6),
						Wind = clone4
					}
				else
					v3[descendant] = {
						Speed = random2:NextNumber(0.1, 0.6)
					}
					descendant.Decal.Transparency = 0.5
				end
			end

			if descendant:IsA("Decal") then
				local transparency = descendant.Transparency
				descendant.Transparency = 1

				if descendant.Color3.R > 2 then
					print(descendant.Color3.R)
					TweenService2:Create(descendant, TweenInfo.new(random2:NextNumber(1, 4), Enum.EasingStyle.Sine), {
						Transparency = 0.7
					}):Play()
				elseif transparency < 0 then
					TweenService2:Create(descendant, TweenInfo.new(random2:NextNumber(1, 4), Enum.EasingStyle.Sine), {
						Transparency = 0.9
					}):Play()
				else
					print(transparency)
					TweenService2:Create(descendant, TweenInfo.new(random2:NextNumber(1, 4), Enum.EasingStyle.Sine), {
						Transparency = transparency
					}):Play()
				end

				table.insert(descendants, descendant)
			elseif descendant:IsA("SpecialMesh") then
				local scale = descendant.Scale
				descendant.Scale = createVector(0, 0, 0)
				TweenService2:Create(descendant, TweenInfo.new(random2:NextNumber(2, 4), Enum.EasingStyle.Sine), {
					Scale = scale
				}):Play()
				table.insert(descendants2, descendant)
			elseif descendant:IsA("BasePart") then
				descendant.CastShadow = false
			end
		end

		local folder = nil
		task.delay(0.5, function()
			local transparenciesByDescendant = {}
			folder = quickFX({
				FX = vfx2.TheWorld,
				Maid = object._maid,
				Anchor = cFrame * vfx2.TheWorld:GetAttribute("Offset"):Inverse()
			})

			for _, descendant in pairs(folder:GetDescendants()) do
				if descendant:IsA("BasePart") or descendant:IsA("Decal") then
					transparenciesByDescendant[descendant] = descendant.Transparency
					descendant.Transparency = 1
				elseif descendant:IsA("ParticleEmitter") and descendant.TimeScale < 1 then
					local timeScale = descendant.TimeScale
					descendant.TimeScale = 1
					local v4 = descendant
					task.delay(5, function()
						TweenService2:Create(v4, TweenInfo.new(1, Enum.EasingStyle.Sine), {
							TimeScale = timeScale
						}):Play()
					end)
				end
			end

			raiseZIndex({
				FX = folder,
				Count = 20
			})
			task.delay(7, function()
				for k, transparency in pairs(transparenciesByDescendant) do
					TweenService2:Create(k, TweenInfo.new(2.5, Enum.EasingStyle.Sine), {
						Transparency = transparency
					}):Play()
				end
			end)
			table.insert(v2, folder)
			task.spawn(function()
				tick()

				while objectValue and objectValue.Parent do
					if folder and folder.Parent then
						for _, child in pairs(folder:GetChildren()) do
							local speed = child:GetAttribute("Speed")

							if not speed then
								speed = random2:NextNumber(0.001, 0.3)
								child:SetAttribute("Speed", speed)
							end

							if not string.match(string.lower(child.Name), "web") then
								continue
							end

							child.CFrame *= CFrame.Angles(0, 0, (math.rad(speed)))
						end
					end

					dtwait(0.02)
				end
			end)
		end)
		task.delay(6.5, function()
			able({
				FX = clone3,
				On = false
			})

			for _, descendant in pairs(clone3:GetDescendants()) do
				if descendant:IsA("BasePart") or descendant:IsA("Decal") then
					TweenService2:Create(descendant, TweenInfo.new(1, Enum.EasingStyle.Sine), {
						Transparency = 1
					}):Play()
				end
			end

			task.wait(1.9500000000000002)

			for _, v4 in pairs(descendants2) do
				local v5 = random2:NextNumber(2, 4) * 6 * 0.65
				TweenService2:Create(v4, TweenInfo.new(v5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
					Scale = createVector(0, 0, 0)
				}):Play()
				game.Debris:AddItem(v4, v5)
			end

			for _, v4 in pairs(descendants) do
				local v5 = random2:NextNumber(2, 4) * 3 * 0.65
				TweenService2:Create(v4, TweenInfo.new(v5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
					Transparency = 1
				}):Play()
				game.Debris:AddItem(v4, v5)
			end

			for _, beam in pairs(clone2:GetDescendants()) do
				if beam:IsA("Beam") then
					playTween(beam, {
						Time = random2:NextNumber(2, 4) * 0.65,
						EasingStyle = "Sine",
						Goal = {
							Transparency = NumberSequence.new(1)
						}
					})
				end
			end

			local v4 = quickFX({
				FX = vfx2.BeginningClouds1,
				Maid = object._maid,
				Anchor = cFrame * CFrame.new(0, 1010, 0)
			})
			shared.vfx.emit(v4)
			task.delay(9, function()
				for _, descendant in pairs(clone3:GetDescendants()) do
					if descendant:IsA("BasePart") or descendant:IsA("Decal") then
						TweenService2:Create(descendant, TweenInfo.new(1, Enum.EasingStyle.Sine), {
							Transparency = 1
						}):Play()
					elseif descendant:IsA("Beam") then
						playTween(descendant, {
							Time = 1,
							EasingStyle = "Sine",
							Goal = {
								Transparency = NumberSequence.new(1)
							}
						})
					end
				end
			end)
			task.wait(14)

			for _, descendant in pairs(folder:GetDescendants()) do
				if descendant:IsA("BasePart") or descendant:IsA("Decal") then
					TweenService2:Create(descendant, TweenInfo.new(1, Enum.EasingStyle.Sine), {
						Transparency = 1
					}):Play()
				elseif descendant:IsA("ParticleEmitter") then
					descendant.Enabled = false
				end
			end

			game.Debris:AddItem(objectValue, 19)
		end)
		local count = 0

		while objectValue and objectValue.Parent do
			for k, v4 in pairs(v3) do
				if k and k.Parent then
					k:PivotTo(k:GetPivot() * CFrame.Angles(math.rad(v4.Speed), 0, 0))

					if v4.Wind and v4.Wind.Parent then
						v4.Wind:PivotTo(v4.Wind:GetPivot() * CFrame.Angles(0, math.rad(v4.Speed), 0))
					end
				else
					v3[k] = nil
				end
			end

			count += 1
			dtwait(0.01)
		end

		clone:Destroy()

		for _, connection in pairs(v2) do
			if typeof(connection) == "RBXScriptConnection" then
				connection:Disconnect()
			else
				connection:Destroy()
			end
		end

		print("CLeaning")
	end

	task.spawn(StormEvent)
	wait(30)
	Clean() -- equivalent call inferred; original call site unknown
end

return OutsideV2
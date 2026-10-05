local createVector = vector.create
local FirstMoveRetrySend = {}
local libraryNew = require(game.ReplicatedStorage.Emotes.VFX.VfxMods.libraryNew)
local playAttachment = libraryNew.PlayAttachment
local maid = libraryNew.Maid
local playTween = libraryNew.PlayTween
local _ = libraryNew.CamShake
local _ = libraryNew.PlayFlipBook
local dtwait = libraryNew.dtwait
local EFP = libraryNew.EFP
local _ = libraryNew.PlayMesh
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
local class = {}
class.__index = class
local random = Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local rad = math.rad
local random2 = math.random
local _ = game.Workspace.Camera
local FrameMarker = require(game.ReplicatedStorage.Resources.FrameMarker)
local MeshEmit = require(game.ReplicatedStorage.Resources.Libraryyyy2.MeshEmit)

local function fn(folder)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitDelay = emitter:GetAttribute("EmitDelay")

		if emitDelay then
			local v = emitter
			task.delay(emitDelay, function()
				v:Emit(v:GetAttribute("EmitCount"))
			end)
		else
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end
end

local function fn2(effect)
	if effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam") then
		effect.Enabled = true
	end

	for _, effect2 in effect:GetDescendants() do
		if not (effect2:IsA("ParticleEmitter") or effect2:IsA("Trail") or effect2:IsA("Beam")) then
			continue
		end

		effect2.Enabled = true
	end
end

local filterDescendantsInstances = { workspace.Map, workspace.Built }

function FirstMoveRetrySend.FirstEvent(p)
	local char = p.Char
	local victim = p.Victim
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid

	local function fn3(p2)
		local character = game.Players.LocalPlayer.Character

		if character == char or character == victim then
			shared.repfire({
				Effect = "Camshake",
				Intensity = p2.Intensity,
				Last = p2.Last
			})
		end
	end

	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v2 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v2 then
			v2 = true
			object._maid:doCleaning()
		end
	end

	task.delay(3.5, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	tick()

	local function FirstEvent()
		local lastTime = tick()
		local v3 = nil

		while true do
			task.wait()

			for _, v5 in pairs(char.Humanoid:GetPlayingAnimationTracks()) do
				if v5.Animation.AnimationId ~= "rbxassetid://" .. 85025226664507 then
					continue
				end

				v3 = v5
				break
			end

			if not (v3 or tick() - lastTime >= 0.25) then
				continue
			end

			if not v3 then
				break
			end

			local v5 = false
			local v6 = "Left"

			local function Step(p2)
				local v7

				if v5 or not v3.IsPlaying then
					v5 = true
					v7 = false
				else
					v7 = true
				end

				if not v7 then
					return
				end

				fn3({
					Intensity = math.random(2, 3)
				})
				local v8 = p2 or {
					Scale = 1.5
				}
				local scale = v8.Scale

				if v6 == "Right" then
					v6 = "Left"
				else
					v6 = "Right"
				end

				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				raycastParams.FilterDescendantsInstances = filterDescendantsInstances
				local cframe = v6 == "Right" and CFrame.new(2, 0, -1) or CFrame.new(-0.5, 0, -1)
				local anchor = v8.Anchor or cframe
				local raycastResult = game.Workspace:Raycast(
					(humanoidRootPart.CFrame * anchor).Position,
					createVector(0, -10, 0),
					raycastParams
				)

				if raycastResult then
					local orientation, v9, v10 = humanoidRootPart.CFrame:ToOrientation()
					local v11 = quickFX({
						FX = vfx.Step,
						Maid = object._maid,
						Anchor = CFrame.new(raycastResult.Position) * CFrame.Angles(orientation, v9, v10)
					})
					v11:ScaleTo(scale)
					playAttachment(v11)
					libraryNew.MeshEmit.Emit(v11)

					for _ = 1, 10 do
						local v12

						if v5 or not v3.IsPlaying then
							v5 = true
							v12 = false
						else
							v12 = true
						end

						if not v12 then
							return
						end

						local v13 = object._maid:give(Instance.new("Part"))
						local v14 = random:NextNumber(0.3, 0.8) * 3
						v13.Size = Vector3.new(v14, v14, v14)
						v13.CanCollide = false
						v13.CanQuery = false
						v13.CanTouch = false
						v13.Material = raycastResult.Material
						v13.Color = raycastResult.Instance.Color
						v13.CFrame = CFrame.new(raycastResult.Position) * CFrame.Angles(
							random:NextNumber(-10, 10),
							random:NextNumber(-10, 10),
							random:NextNumber(-10, 10)
						)
						local v15 = humanoidRootPart.CFrame * CFrame.new(
							random:NextNumber(-5, 5),
							random:NextNumber(0, 3),
							random:NextNumber(5, 15)
						)
						v13.Parent = EFP
						local v16 = random:NextNumber(0.3, 0.6) * 1.5
						TweenService:Create(v13, TweenInfo.new(v16, Enum.EasingStyle.Quad), {
							Size = createVector(0, 0, 0),
							CFrame = v15 * CFrame.Angles(
								random:NextNumber(-10, 10),
								random:NextNumber(-10, 10),
								random:NextNumber(-10, 10)
							)
						}):Play()
						game.Debris:AddItem(v13, v16)
					end
				end
			end

			local Step2 = Step
			local Step3 = Step
			local Step4 = Step
			local Step5 = Step
			return FrameMarker.new({
				Framerate = 60
			}):Chain({
				[1] = function()
					local v7

					if v5 or not v3.IsPlaying then
						v5 = true
						v7 = false
					else
						v7 = true
					end

					if not v7 then
						return
					end

					for _, part in pairs({ char["Left Arm"], char["Right Arm"] }) do
						local v9 = object._maid:give(vfx.TrailArm:Clone())
						local weld = Instance.new("Weld")
						weld.Part0 = v9
						weld.Part1 = part
						weld.Parent = v9
						v9.Parent = EFP
						local v10

						if v5 or not v3.IsPlaying then
							v5 = true
							v10 = false
						else
							v10 = true
						end

						if not v10 then
							break
						end

						local folder = v9
						task.delay(1, function()
							local v11

							if v5 or not v3.IsPlaying then
								v5 = true
								v11 = false
							else
								v11 = true
							end

							if not v11 then
								return
							end

							for i, trail in pairs(folder:GetDescendants()) do
								if not trail:IsA("Trail") then
									continue
								end

								playTween(trail, {
									Time = 0.5,
									EasingStyle = "Sine",
									Goal = {
										Transparency = NumberSequence.new({
											NumberSequenceKeypoint.new(0, 1),
											NumberSequenceKeypoint.new(1, 1)
										})
									}
								})
								game.Debris:AddItem(trail, 0.5)
							end
						end)
					end
				end,
				[14] = function()
					local v7

					if v5 or not v3.IsPlaying then
						v5 = true
						v7 = false
					else
						v7 = true
					end

					if not v7 then
						return
					end

					Step2()
				end,
				[26] = function()
					local v7

					if v5 or not v3.IsPlaying then
						v5 = true
						v7 = false
					else
						v7 = true
					end

					if not v7 then
						return
					end

					Step3()
				end,
				[34] = function()
					local v7

					if v5 or not v3.IsPlaying then
						v5 = true
						v7 = false
					else
						v7 = true
					end

					if not v7 then
						return
					end

					Step4()
				end,
				[46] = function()
					local v7

					if v5 or not v3.IsPlaying then
						v5 = true
						v7 = false
					else
						v7 = true
					end

					if not v7 then
						return
					end

					Step5({
						Scale = 2,
						Anchor = CFrame.new(0, 0, -2)
					})
				end,
				[55] = function()
					local v7

					if v5 or not v3.IsPlaying then
						v5 = true
						v7 = false
					else
						v7 = true
					end

					if not v7 then
						return
					end

					local FX = quickFX({
						FX = vfx.LastJump,
						Maid = object._maid,
						Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, -5)
					})
					lifeScale({
						FX = FX,
						Scale = 2
					})
					playAttachment(FX)
					libraryNew.MeshEmit.Emit(FX)
					local FX2 = quickWeld({
						FX = vfx.Spinning,
						Maid = object._maid,
						P = char.Torso
					})
					able({
						FX = FX2,
						On = true
					})
					dtwait(0.35)
					local v10

					if v5 or not v3.IsPlaying then
						v5 = true
						v10 = false
					else
						v10 = true
					end

					if not v10 then
						return
					end

					able({
						FX = FX2,
						On = false
					})

					for _, part in pairs({ char["Left Leg"], char["Right Leg"] }) do
						local v12 = object._maid:give(vfx.TrailArm:Clone())
						local weld = Instance.new("Weld")
						weld.Part0 = v12
						weld.Part1 = part
						weld.Parent = v12
						v12.Parent = EFP
						local v13

						if v5 or not v3.IsPlaying then
							v5 = true
							v13 = false
						else
							v13 = true
						end

						if not v13 then
							break
						end

						local folder = v12
						task.delay(0.6, function()
							local v14

							if v5 or not v3.IsPlaying then
								v5 = true
								v14 = false
							else
								v14 = true
							end

							if not v14 then
								return
							end

							for i, trail in pairs(folder:GetDescendants()) do
								if not trail:IsA("Trail") then
									continue
								end

								playTween(trail, {
									Time = 0.5,
									EasingStyle = "Sine",
									Goal = {
										Transparency = NumberSequence.new({
											NumberSequenceKeypoint.new(0, 1),
											NumberSequenceKeypoint.new(1, 1)
										})
									}
								})
								game.Debris:AddItem(trail, 0.5)
							end
						end)
					end
				end,
				[25] = function()
					local v7

					if v5 or not v3.IsPlaying then
						v5 = true
						v7 = false
					else
						v7 = true
					end

					if not v7 then
						return
					end

					local FX = quickWeld({
						FX = vfx.LegThing,
						Maid = object._maid,
						P = char["Right Leg"]
					})
					able({
						FX = FX,
						On = true
					})
					dtwait(0.8)
					local v9

					if v5 or not v3.IsPlaying then
						v5 = true
						v9 = false
					else
						v9 = true
					end

					if not v9 then
						return
					end

					able({
						FX = FX,
						On = false
					})
				end,
				[80] = function()
					local v7

					if v5 or not v3.IsPlaying then
						v5 = true
						v7 = false
					else
						v7 = true
					end

					if not v7 then
						return
					end

					fn3({
						Intensity = 7
					})
					local v8

					if v5 or not v3.IsPlaying then
						v5 = true
						v8 = false
					else
						v8 = true
					end

					if not v8 then
						return
					end

					local FX = quickFX({
						FX = vfx.Swipe,
						Maid = object._maid,
						Anchor = humanoidRootPart.CFrame * CFrame.new(0, -1, -1)
					})
					lifeScale({
						FX = FX,
						Scale = 1
					})
					playAttachment(FX)
					libraryNew.MeshEmit.Emit(FX)
					local v10

					if v5 or not v3.IsPlaying then
						v5 = true
						v10 = false
					else
						v10 = true
					end

					if not v10 then
						return
					end

					local v11 = quickWeld({
						FX = vfx.CoolWave,
						Maid = object._maid,
						P = char.Torso
					})
					v11:ScaleTo(2)
					local _0F = v11.Part["0F"]
					playAttachment(_0F)
					libraryNew.MeshEmit.Emit(_0F)
					local light = _0F.Light
					light.Enabled = true
					TweenService:Create(light, TweenInfo.new(0.5), {
						Brightness = 0
					}):Play()
				end
			})
		end
	end

	task.spawn(FirstEvent)
	wait(20)
	Clean() -- equivalent call inferred; original call site unknown
end

function FirstMoveRetrySend.HitEvent(data)
	local fn3
	local char = data.Char
	local victim = data.Victim
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local character = game.Players.LocalPlayer.Character
	local flag = false
	local v2 = character == char or character == victim
	local object = setmetatable({}, class)
	object._maid = maid.new()
	tick()
	local v3 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v3 then
			v3 = true
			object._maid:doCleaning()
		end
	end

	task.delay(12, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local lastTime = tick()
	local v4 = nil

	while true do
		task.wait()

		for _, v6 in pairs(char.Humanoid:GetPlayingAnimationTracks()) do
			if v6.Animation.AnimationId ~= "rbxassetid://" .. 133207489574364 then
				continue
			end

			v4 = v6
			break
		end

		if not (v4 or tick() - lastTime >= 0.25) then
			continue
		end

		local v6 = false
		local v7 = false

		for _, v8 in pairs({ char, victim }) do
			local v9 = v8
			v8:GetPropertyChangedSignal("Parent"):Once(function()
				v6 = true

				if v9 == victim then
					for k, v10 in pairs(victim.Humanoid:GetPlayingAnimationTracks()) do
						if v10.Animation.AnimationId ~= "rbxassetid://123922174277846" then
							continue
						end

						v10:Stop()
						break
					end
				end

				workspace:SetAttribute("MapInvis", nil)
				data.Bind:Destroy()
			end)
		end

		local function fn4()
			if not v6 and data.Bind and data.Bind.Parent then
				return true
			end

			v6 = true
			workspace:SetAttribute("MapInvis", nil)

			if not flag then
				flag = true

				if fn3 then
					fn3(1)
				end
			end

			local RunService = game:GetService("RunService")
			RunService:UnbindFromRenderStep("BeastBreathingCamera")

			if not v7 then
				v7 = true
				Clean() -- equivalent call inferred; original call site unknown
			end

			return false
		end

		local HuntersMarkAdditions = require(script.Parent.HuntersMarkAdditions)
		HuntersMarkAdditions(humanoidRootPart, victim.PrimaryPart, victim)

		local function HitEvent()
			return FrameMarker.new({
				Framerate = 60
			}):Chain({
				[1] = function()
					if not fn4() then
						return
					end

					local v9 = {}

					for k, v10 in pairs({ char["Right Arm"], char["Left Arm"] }) do
						if not fn4() then
							return
						end

						local FX = quickWeld({
							FX = vfx.LegThing,
							Maid = object._maid,
							P = v10
						})
						able({
							FX = FX,
							On = true
						})
						playAttachment(FX)
						libraryNew.MeshEmit.Emit(FX)
						raiseZIndex({
							FX = FX,
							Count = 3
						})
						table.insert(v9, FX)
						task.delay(3, function()
							able({
								FX = FX,
								On = false
							})
						end)
					end

					for k, part in pairs({ char["Left Arm"], char["Right Arm"] }) do
						if not fn4() then
							break
						end

						local v11 = object._maid:give(vfx.TrailArm:Clone())
						local weld = Instance.new("Weld")
						weld.Part0 = v11
						weld.Part1 = part
						weld.Parent = v11
						v11.Parent = EFP
						local folder = v11
						task.delay(3, function()
							for i, trail in pairs(folder:GetDescendants()) do
								if not trail:IsA("Trail") then
									continue
								end

								playTween(trail, {
									Time = 0.5,
									EasingStyle = "Sine",
									Goal = {
										Transparency = NumberSequence.new({
											NumberSequenceKeypoint.new(0, 1),
											NumberSequenceKeypoint.new(1, 1)
										})
									}
								})
								game.Debris:AddItem(trail, 0.5)
							end
						end)
					end
				end,
				[114] = function()
					if not fn4() then
						return
					end

					local FX = quickFX({
						FX = vfx.TinyHit,
						Maid = object._maid,
						Anchor = victim.Head.CFrame
					})
					FX:ScaleTo(0.27999999999999997)
					raiseZIndex({
						FX = FX,
						Count = 2
					})
					lifeScale({
						FX = FX,
						Scale = 1.6
					})
					able({
						FX = FX,
						On = false
					})
					playAttachment(FX)
					libraryNew.MeshEmit.Emit(FX)
					local FX2 = quickFX({
						FX = vfx.Small,
						Maid = object._maid,
						Anchor = victim.Head.CFrame
					})
					FX2:ScaleTo(0.21)
					raiseZIndex({
						FX = FX2,
						Count = -4
					})
					lifeScale({
						FX = FX2,
						Scale = 0.7
					})
					playAttachment(FX2)
					libraryNew.MeshEmit.Emit(FX2)
				end,
				[132] = function()
					if not fn4() then
						return
					end

					local FX = quickFX({
						FX = vfx.TinyHit,
						Maid = object._maid,
						Anchor = victim.Head.CFrame
					})
					FX:ScaleTo(0.27999999999999997)
					raiseZIndex({
						FX = FX,
						Count = 2
					})
					lifeScale({
						FX = FX,
						Scale = 1.6
					})
					able({
						FX = FX,
						On = false
					})
					playAttachment(FX)
					libraryNew.MeshEmit.Emit(FX)
					local FX2 = quickFX({
						FX = vfx.Small,
						Maid = object._maid,
						Anchor = victim.Head.CFrame
					})
					FX2:ScaleTo(0.21)
					raiseZIndex({
						FX = FX2,
						Count = -4
					})
					lifeScale({
						FX = FX2,
						Scale = 0.7
					})
					playAttachment(FX2)
					libraryNew.MeshEmit.Emit(FX2)
				end,
				[145] = function()
					if not fn4() then
						return
					end

					local FX = quickFX({
						FX = vfx.TinyHit,
						Maid = object._maid,
						Anchor = victim.Head.CFrame
					})
					FX:ScaleTo(0.27999999999999997)
					raiseZIndex({
						FX = FX,
						Count = 2
					})
					lifeScale({
						FX = FX,
						Scale = 1.6
					})
					able({
						FX = FX,
						On = false
					})
					playAttachment(FX)
					libraryNew.MeshEmit.Emit(FX)
					local FX2 = quickFX({
						FX = vfx.Small,
						Maid = object._maid,
						Anchor = victim.Head.CFrame
					})
					FX2:ScaleTo(0.21)
					raiseZIndex({
						FX = FX2,
						Count = -4
					})
					lifeScale({
						FX = FX2,
						Scale = 0.7
					})
					playAttachment(FX2)
					libraryNew.MeshEmit.Emit(FX2)
				end,
				[154] = function()
					if not (fn4() and victim.Head) then
						return
					end

					local FX = quickFX({
						FX = vfx.TinyHit,
						Maid = object._maid,
						Anchor = victim.Head.CFrame
					})
					FX:ScaleTo(0.27999999999999997)
					raiseZIndex({
						FX = FX,
						Count = 2
					})
					lifeScale({
						FX = FX,
						Scale = 1.6
					})
					able({
						FX = FX,
						On = false
					})
					playAttachment(FX)
					libraryNew.MeshEmit.Emit(FX)
					local FX2 = quickFX({
						FX = vfx.Small,
						Maid = object._maid,
						Anchor = victim.Head.CFrame
					})
					FX2:ScaleTo(0.21)
					raiseZIndex({
						FX = FX2,
						Count = -4
					})
					lifeScale({
						FX = FX2,
						Scale = 0.7
					})
					playAttachment(FX2)
					libraryNew.MeshEmit.Emit(FX2)
				end
			})
		end

		task.spawn(HitEvent)
		local v9 = nil
		local v10 = fn4
		task.delay(3, function()
			if not v10() then
				return
			end

			local function LastHitEvent()
				return FrameMarker.new({
					Framerate = 60
				}):Chain({ function()
						if not v10() then
							return
						end

						local folder = quickFX({
							FX = vfx.Hit,
							Maid = object._maid,
							Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(
								0,
								-1.5707963267948966,
								0
							)
						})
						lifeScale({
							FX = folder.Hite.Mesh,
							Scale = 3
						})
						task.delay(0.1, function()
							if not v10() then
								return
							end

							for i, emitter in pairs(folder:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									TweenService:Create(emitter, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
										TimeScale = 0.2
									}):Play()
								end
							end
						end)
						playAttachment(folder)
						libraryNew.MeshEmit.Emit(folder)
						task.wait(0.4)

						if not v10() then
							return
						end

						folder:Destroy()
						local v11 = quickFX({
							FX = vfx.Hit2,
							Maid = object._maid,
							Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(
								0,
								-1.5707963267948966,
								0
							)
						})
						playAttachment(v11)
						libraryNew.MeshEmit.Emit(v11)
					end })
			end

			task.spawn(function()
				if not v10() then
					return
				end

				LastHitEvent()
			end)
			local clones = {}
			local playerGui = game.Players.LocalPlayer.PlayerGui
			local v11

			if v2 then
				if not v10() then
					return
				end

				v11 = object._maid:give(script.Dark:Clone())
				local frame = v11.Frame
				v11.Parent = playerGui
				frame.Size = UDim2.new(0, 1, 0, 1)
				frame.Visible = true
				frame.Position = UDim2.new(0, 0, 0, 0)
				frame.BackgroundTransparency = 0

				for k, v12 in pairs({ script.Impact }) do
					if v10() then
						local clone = v12:Clone()
						game.Debris:AddItem(clone, 8)
						clone.Enabled = true
						clone.Parent = game.Players.LocalPlayer.PlayerGui

						for i, image in pairs(clone:GetDescendants()) do
							if not image:IsA("ImageLabel") then
								continue
							end

							image.Size = UDim2.new(0, 1, 0, 1)
							image.Visible = true
							image.Position = UDim2.new(0, 0, 0, 0)
							image.ImageTransparency = 0
						end

						table.insert(clones, clone)
					else
						if v12 then
							v12:Destroy("")
						end

						return
					end
				end
			else
				v11 = nil
			end

			task.wait(0.77)

			if not (v10() and v2) then
				return
			end

			local function ImpactFrames(p, p2)
				if not v2 then
					return
				end

				for k, impact in pairs(clones) do
					local v13 = tostring(p)

					if tostring(impact) ~= v13 then
						continue
					end

					object.Impact = impact
					break
				end

				local frames = object.Impact.Frames

				if not frames then
					return
				end

				local v12 = nil
				local v13 = 1
				tick()
				local v14 = nil
				v14 = shared.loop(function()
					local child = frames:FindFirstChild((tostring(v13)))

					if child and child ~= nil and child.Parent and v10() then
						v13 += 1
						child.Size = UDim2.new(1, 0, 1, 0)

						if v12 then
							v12:Destroy()
						end

						v12 = child
					else
						for i, child2 in pairs(frames:GetChildren()) do
							child2:Destroy()
						end

						if v9 then
							v9:Destroy("")
						end

						return v14()
					end
				end, 30)
			end

			local function ScreenEvent()
				if v10() then
					return FrameMarker.new({
						Framerate = 60
					}):Chain({
						[0.55] = function()
							if not v10() then
								return
							end

							local function Try1()
								if not v10() then
									return
								end

								local frame = v11.Frame
								frame.Size = UDim2.new(1, 0, 1, 0)
								frame.BackgroundTransparency = 1
								v9 = frame
								task.delay(0.05, function()
									TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
										BackgroundTransparency = 0
									}):Play()
								end)
								task.delay(0.25, function()
									if not v10() then
										return
									end

									task.spawn(function()
										for i = 1, 10 do
											if not v10() then
												break
											end

											local clone = script.ScreenGui:Clone()
											clone.Parent = playerGui
											clone.ViewportFrame.CurrentCamera = workspace.CurrentCamera
											local clone2 = char:Clone()
											clone2:SetAttribute("ClonedChar2", true)

											for i2, script2 in pairs(clone2:GetDescendants()) do
												if script2:IsA("Script") or script2:IsA("LocalScript") then
													script2:Destroy("")
												end
											end

											game.Debris:AddItem(clone, 0.65)
											clone2.Parent = clone.ViewportFrame
											TweenService:Create(clone.ViewportFrame, TweenInfo.new(0.5), {
												BackgroundColor3 = Color3.new(0, 0, 0),
												ImageTransparency = 1
											}):Play()
											task.wait(0.185)
										end
									end)
									local cframe = CFrame.new(
										1.45696163,
										-2.16182137,
										-68.6793823,
										-0.928675592,
										0.0608669072,
										0.365865052,
										-0.00339892088,
										0.985004127,
										-0.172497019,
										-0.370877981,
										-0.161437303,
										-0.914542377
									)
									local part = Instance.new("Part")
									game.Debris:AddItem(part, 4)
									part.Anchored = true
									part.CanCollide = false
									part.CFrame = humanoidRootPart.CFrame * cframe
									part.Parent = workspace.Thrown
									part.Transparency = 1
									local currentCamera = workspace.CurrentCamera
									local accessory = Instance.new("Accessory")
									accessory.Name = "CameraSmoothTransition"
									accessory:SetAttribute("Monster", true)
									accessory.Parent = char
									game.Debris:AddItem(accessory, 7)
									object._maid:give(accessory)
									local RunService = game:GetService("RunService")
									RunService:BindToRenderStep(
										"BeastBreathingCamera",
										Enum.RenderPriority.Camera.Value,
										function()
											if not v10() then
												local RunService2 = game:GetService("RunService")
												return RunService2:UnbindFromRenderStep("BeastBreathingCamera")
											end

											if not (part and part.Parent) then
												local RunService2 = game:GetService("RunService")
												return RunService2:UnbindFromRenderStep("BeastBreathingCamera")
											end

											shared.SetCore(false, 3)
											currentCamera.CameraType = Enum.CameraType.Scriptable
											currentCamera.CameraSubject = part
											currentCamera.CFrame = humanoidRootPart.CFrame * cframe
										end
									)
									task.delay(3, function()
										local RunService2 = game:GetService("RunService")
										RunService2:UnbindFromRenderStep("BeastBreathingCamera")
									end)
								end)
								task.delay(2.5, function()
									if frame and frame.Parent then
										frame.Parent:Destroy()
									end
								end)
								dtwait(0.8)

								if v10() then
									ImpactFrames("Impact")
								else
									local RunService = game:GetService("RunService")
									return RunService:UnbindFromRenderStep("BeastBreathingCamera")
								end
							end

							Try1()
						end,
						[0.615] = function()
							if not v10() then
								local RunService = game:GetService("RunService")
								return RunService:UnbindFromRenderStep("BeastBreathingCamera")
							end

							local trails = {}

							local function setTrailLifetime(lifetime, p2)
								for k, trail in trails do
									if trail:IsA("Trail") then
										TweenService:Create(trail, p2, {
											Lifetime = lifetime
										}):Play()
									end
								end
							end

							for k, part in pairs({ char["Left Arm"], char["Right Arm"] }) do
								if not v10() then
									local RunService = game:GetService("RunService")
									return RunService:UnbindFromRenderStep("BeastBreathingCamera")
								end

								local folder = object._maid:give(vfx.TrailArm:Clone())
								local weld = Instance.new("Weld")
								weld.Part0 = folder
								weld.Part1 = part
								weld.Parent = folder
								folder.Parent = EFP

								for i, trail in pairs(folder:GetDescendants()) do
									if trail:IsA("Trail") then
										table.insert(trails, trail)
									end
								end

								local folder2 = folder
								task.delay(4, function()
									for i, trail in pairs(folder2:GetDescendants()) do
										if not trail:IsA("Trail") then
											continue
										end

										if v10() then
											playTween(trail, {
												Time = 0.5,
												EasingStyle = "Sine",
												Goal = {
													Transparency = NumberSequence.new({
														NumberSequenceKeypoint.new(0, 1),
														NumberSequenceKeypoint.new(1, 1)
													})
												}
											})
											game.Debris:AddItem(trail, 0.5)
										else
											local RunService = game:GetService("RunService")
											return RunService:UnbindFromRenderStep("BeastBreathingCamera")
										end
									end
								end)
							end
						end
					})
				end
			end

			task.spawn(ScreenEvent)
		end)
		local v11 = fn4
		task.delay(3, function()
			if not (v11() and (victim and victim:FindFirstChild("Torso"))) then
				return
			end

			local part = Instance.new("Part")
			game.Debris:AddItem(part, 10)
			part.Size = createVector(160, 160, 160)
			part.Anchored = true
			part.CanQuery = false
			part.CanTouch = false
			part.CanCollide = false
			part.CFrame = victim.Torso.CFrame
			part.Parent = workspace.Thrown
			part.Transparency = 1
			part.CastShadow = false
			local overlapParams = OverlapParams.new()
			overlapParams.FilterType = Enum.RaycastFilterType.Exclude
			overlapParams.FilterDescendantsInstances = { workspace.Live }
			local partsInPart = workspace:GetPartsInPart(part, overlapParams)
			data.Bind.Destroying:Once(function()
				workspace:SetAttribute("MapInvis", nil)

				for k, part2 in pairs(partsInPart) do
					if part2:IsA("BasePart") then
						part2.LocalTransparencyModifier = 0
					end
				end
			end)

			fn3 = function(localTransparencyModifier)
				if not v2 then
					return
				end

				if localTransparencyModifier == 0 then
					workspace:SetAttribute("MapInvis", nil)

					for k, part2 in pairs(partsInPart) do
						if part2:IsA("BasePart") then
							part2.LocalTransparencyModifier = 0
						end
					end
				else
					if flag then
						return
					end

					for k, part2 in pairs(partsInPart) do
						if part2:IsA("BasePart") then
							part2.LocalTransparencyModifier = localTransparencyModifier
						end
					end
				end
			end
		end)
		local v12 = fn4
		task.delay(6.01, function()
			if not v12() then
				return
			end

			local function FinalEvent()
				if v2 then
					return FrameMarker.new({
						Framerate = 60
					}):Chain({ function()
							if not v12() then
								local RunService = game:GetService("RunService")
								return RunService:UnbindFromRenderStep("BeastBreathingCamera")
							end

							if v2 then
								local RunService = game:GetService("RunService")
								RunService:UnbindFromRenderStep("BeastBreathingCamera")
							end

							if v9 then
								v9:Destroy("")
							end

							local folder = nil

							local function EndingEvent()
								if not v12() then
									local RunService = game:GetService("RunService")
									return RunService:UnbindFromRenderStep("BeastBreathingCamera")
								end

								local clone = vfx.Hitstuff.HitFX:Clone()
								game.Debris:AddItem(clone, 10)
								folder = clone
								clone.Parent = EFP
								local v13 = CFrame.new(0, 0, -50) * CFrame.Angles(-1.5707963267948966, 0, 0)
								clone:PivotTo(humanoidRootPart.CFrame * v13)
								local v14 = TweenService
								local _367F = clone:WaitForChild("Fx")["367F"]
								local lingerMesh = _367F.LingerMesh
								lingerMesh.Transparency = 0.8
								v14:Create(lingerMesh, TweenInfo.new(2), {
									Transparency = 1,
									CFrame = lingerMesh.CFrame * CFrame.Angles(0, 2.9670597283903604, 0)
								}):Play()
								local swirl = _367F.Swirl
								swirl.Transparency = 0.75
								v14:Create(swirl, TweenInfo.new(1.5), {
									Transparency = 1,
									CFrame = lingerMesh.CFrame * CFrame.Angles(0, -1.5707963267948966, 0)
								}):Play()
								local whirl = _367F.Whirl
								whirl.Transparency = 0.6
								v14:Create(whirl, TweenInfo.new(1), {
									Transparency = 1,
									CFrame = lingerMesh.CFrame * CFrame.Angles(0, -0.8726646259971648, 0)
								}):Play()
								local flashMesh = _367F.FlashMesh
								flashMesh.Decal.Transparency = 0
								v14:Create(flashMesh.Decal, TweenInfo.new(0.7), {
									Transparency = 1
								}):Play()
								local largeMesh = _367F.LargeMesh
								largeMesh.Decal.Transparency = 0.7
								v14:Create(largeMesh.Decal, TweenInfo.new(0.7), {
									Transparency = 1
								}):Play()
								local kanji = _367F.Kanji
								kanji.WorldCFrame = victim.Torso.CFrame
								playAttachment(kanji)
								libraryNew.MeshEmit.Emit(kanji)
							end

							if not v12() then
								local RunService = game:GetService("RunService")
								return RunService:UnbindFromRenderStep("BeastBreathingCamera")
							end

							EndingEvent()

							if not v12() then
								local RunService = game:GetService("RunService")
								return RunService:UnbindFromRenderStep("BeastBreathingCamera")
							end

							local v13 = object._maid:give(vfx.Domain:Clone())
							v13:ScaleTo(1.4)
							v13:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 6.5, -40) * CFrame.Angles(
								0,
								3.141592653589793,
								0
							))
							v13.Parent = workspace.Thrown
							v13.Speed.Value = 1
							task.delay(0, function()
								if not v12() then
									local RunService = game:GetService("RunService")
									return RunService:UnbindFromRenderStep("BeastBreathingCamera")
								end

								fn3(1)
								workspace:SetAttribute("MapInvis", true)
							end)
							game.Debris:AddItem(v13, 3)
							TweenService:Create(v13.Speed, TweenInfo.new(4, Enum.EasingStyle.Sine), {
								Value = 5
							}):Play()
							task.delay(0.1, function()
								if not v12() then
									local RunService = game:GetService("RunService")
									return RunService:UnbindFromRenderStep("BeastBreathingCamera")
								end

								local folder2 = quickFX({
									FX = vfx.BlackDots,
									Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, -10) * CFrame.Angles(
										-1.5707963267948966,
										0,
										1.5707963267948966
									),
									Maid = object._maid
								})
								folder2:ScaleTo(5)
								playAttachment(folder2)
								libraryNew.MeshEmit.Emit(folder2)

								for i, emitter in pairs(folder2:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") then
										TweenService:Create(emitter, TweenInfo.new(0.7, Enum.EasingStyle.Sine), {
											TimeScale = 0.1
										}):Play()
									end
								end

								task.spawn(function()
									local lastTime2 = tick()

									while tick() - lastTime2 < 2.5 do
										task.wait(0.01)
										folder2:PivotTo(folder2:GetPivot() * CFrame.Angles(
											math.rad(1 * v13.Speed.Value),
											0,
											0
										))
									end
								end)
								dtwait(1.7)

								if not v12() then
									local RunService = game:GetService("RunService")
									return RunService:UnbindFromRenderStep("BeastBreathingCamera")
								end

								for i, emitter in pairs(folder2:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") then
										TweenService:Create(emitter, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
											TimeScale = 1
										}):Play()
									end
								end
							end)
							task.delay(0.3, function()
								if not v12() then
									local RunService = game:GetService("RunService")
									return RunService:UnbindFromRenderStep("BeastBreathingCamera")
								end

								local folder2 = quickFX({
									FX = vfx.TestSpeed,
									Maid = object._maid,
									Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, -40) * CFrame.Angles(
										0,
										-1.5707963267948966,
										0
									)
								})
								raiseZIndex({
									FX = folder2,
									Count = -5
								})
								able({
									FX = folder2,
									On = true
								})
								playAttachment(folder2)
								libraryNew.MeshEmit.Emit(folder2)
								dtwait(0.2)

								if not v12() then
									local RunService = game:GetService("RunService")
									return RunService:UnbindFromRenderStep("BeastBreathingCamera")
								end

								for i, emitter in pairs(folder2:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") then
										TweenService:Create(emitter, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
											TimeScale = 0.3
										}):Play()
									end
								end

								dtwait(1)

								if v12() then
									able({
										FX = folder2,
										On = false
									})
								else
									local RunService = game:GetService("RunService")
									return RunService:UnbindFromRenderStep("BeastBreathingCamera")
								end
							end)
							task.delay(1, function()
								if not v12() then
									local RunService = game:GetService("RunService")
									return RunService:UnbindFromRenderStep("BeastBreathingCamera")
								end

								local v14 = object._maid:give(Instance.new("NumberValue"))
								v14.Value = v13:GetScale()
								TweenService:Create(v14, TweenInfo.new(2, Enum.EasingStyle.Sine), {
									Value = 0.3
								}):Play()
								local scale = v13:GetScale()
								object._maid:giveTask(v14.Changed:Connect(function()
									v13:ScaleTo(v14.Value)
									v13:PivotTo(humanoidRootPart.CFrame * CFrame.new(
										0,
										6.5 * (v14.Value / scale),
										-40 * (scale / v14.Value)
									) * CFrame.Angles(0, 3.141592653589793, 0))
								end))
								dtwait(0.3)

								if not v12() then
									local RunService = game:GetService("RunService")
									return RunService:UnbindFromRenderStep("BeastBreathingCamera")
								end

								local FX = quickFX({
									FX = vfx.Test,
									Maid = object._maid,
									Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, -40)
								})
								raiseZIndex({
									FX = FX,
									Count = 15
								})
								playAttachment(FX)
								libraryNew.MeshEmit.Emit(FX)
							end)
							local folder2 = nil
							task.delay(0.3, function()
								if not v12() then
									local RunService = game:GetService("RunService")
									return RunService:UnbindFromRenderStep("BeastBreathingCamera")
								end

								local folder3 = quickFX({
									FX = vfx.Land2,
									Maid = object._maid,
									Anchor = humanoidRootPart.CFrame * CFrame.new(
										3,
										-humanoidRootPart.Size.Y * 1.5,
										-65
									) * CFrame.Angles(0, 3.141592653589793, 0)
								})
								folder2 = folder3
								task.delay(0.1, function()
									if not v12() then
										local RunService = game:GetService("RunService")
										return RunService:UnbindFromRenderStep("BeastBreathingCamera")
									end

									for i, beam in pairs(folder3:GetDescendants()) do
										if not beam:IsA("Beam") then
											continue
										end

										TweenService:Create(beam, TweenInfo.new(9, Enum.EasingStyle.Sine), {
											TextureSpeed = 0
										}):Play()
										playTween(beam, {
											Time = 6,
											EasingStyle = "Sine",
											Goal = {
												Transparency = NumberSequence.new({
													NumberSequenceKeypoint.new(0, 1),
													NumberSequenceKeypoint.new(1, 1)
												})
											}
										})
										local v14 = beam
										task.delay(5.65, function()
											v14.Enabled = false
										end)
										game.Debris:AddItem(beam, 6)
									end
								end)
							end)

							if not v12() then
								local RunService = game:GetService("RunService")
								return RunService:UnbindFromRenderStep("BeastBreathingCamera")
							end

							local v14 = {}

							for k, v15 in pairs({ char["Right Arm"], char["Left Arm"] }) do
								if not v12() then
									local RunService = game:GetService("RunService")
									return RunService:UnbindFromRenderStep("BeastBreathingCamera")
								end

								local FX = quickWeld({
									FX = vfx.LegThing2,
									Maid = object._maid,
									P = v15
								})
								able({
									FX = FX,
									On = true
								})
								playAttachment(FX)
								libraryNew.MeshEmit.Emit(FX)
								lifeScale({
									FX = FX,
									Scale = 2
								})
								raiseZIndex({
									FX = FX,
									Count = 6
								})
								table.insert(v14, FX)
								task.delay(2, function()
									if v12() then
										able({
											FX = FX,
											On = false
										})
									else
										local RunService = game:GetService("RunService")
										return RunService:UnbindFromRenderStep("BeastBreathingCamera")
									end
								end)
							end

							if not v12() then
								local RunService = game:GetService("RunService")
								return RunService:UnbindFromRenderStep("BeastBreathingCamera")
							end

							local v15 = object._maid:give(Instance.new("Highlight"))
							v15.FillTransparency = -16
							v15.OutlineTransparency = 1
							v15.FillColor = Color3.new(0.721569, 0.0784314, 0.0784314)
							v15.Parent = victim
							TweenService:Create(v15, TweenInfo.new(1, Enum.EasingStyle.Sine), {
								FillTransparency = 1
							}):Play()
							local v16 = object._maid:give(Instance.new("Highlight"))
							v16.FillTransparency = -16
							v16.OutlineTransparency = 1
							v16.FillColor = Color3.new(0.721569, 0.0784314, 0.0784314)
							v16.Parent = char
							TweenService:Create(v16, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
								FillTransparency = 1
							}):Play()
							local FX2 = quickFX({
								FX = vfx.Hit3,
								Maid = object._maid,
								Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, -10) * CFrame.Angles(
									0,
									-1.5707963267948966,
									0
								)
							})
							lifeScale({
								FX = FX2,
								Scale = 2
							})
							playAttachment(FX2)
							libraryNew.MeshEmit.Emit(FX2)
							dtwait(2.2)

							if not v12() then
								local RunService = game:GetService("RunService")
								return RunService:UnbindFromRenderStep("BeastBreathingCamera")
							end

							fn3(0)
							workspace:SetAttribute("MapInvis", nil)

							if folder then
								for i, effect in pairs(folder:GetDescendants()) do
									if not (effect:IsA("Beam") or effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
										continue
									end

									effect.Enabled = false
								end
							end

							if folder2 then
								for i, effect in pairs(folder2:GetDescendants()) do
									if not (effect:IsA("Beam") or effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
										continue
									end

									effect.Enabled = false
								end
							end
						end })
				end
			end

			task.spawn(FinalEvent)
		end)
		local v13 = fn4
		task.delay(8.1, function()
			local function TheHitEvent()
				if not v13() then
					local RunService = game:GetService("RunService")
					return RunService:UnbindFromRenderStep("BeastBreathingCamera")
				end

				local function New()
					if not v13() then
						local RunService = game:GetService("RunService")
						return RunService:UnbindFromRenderStep("BeastBreathingCamera")
					end

					local extra1 = vfx.Extra1
					local torso = victim.Torso
					local clone = extra1.Meshes.ImpactMesh:Clone()
					MeshEmit.new(clone):EmitRate(11, 2, torso.CFrame * CFrame.new(clone:GetAttribute("Offset")))
					dtwait(0.1)

					if not v13() then
						local RunService = game:GetService("RunService")
						return RunService:UnbindFromRenderStep("BeastBreathingCamera")
					end

					local FX = quickFX({
						FX = vfx.ExplosionFxNoKanji,
						Maid = object._maid,
						Anchor = CFrame.new(victim.Torso.Position)
					})
					FX:ScaleTo(0.5)
					lifeScale({
						FX = FX,
						Scale = 0.5
					})
					playAttachment(FX)
					libraryNew.MeshEmit.Emit(FX)
					local FX2 = quickFX({
						FX = vfx.Small,
						Maid = object._maid,
						Anchor = victim.Torso.CFrame
					})
					lifeScale({
						FX = FX2,
						Scale = 2
					})
					playAttachment(FX2)
					libraryNew.MeshEmit.Emit(FX2)
				end

				task.spawn(New)
				return FrameMarker.new({
					Framerate = 60
				}):Chain({ function()
						if not v13() then
							local RunService = game:GetService("RunService")
							return RunService:UnbindFromRenderStep("BeastBreathingCamera")
						end

						local FX = quickFX({
							FX = vfx.TinyHit,
							Maid = object._maid,
							Anchor = victim.Torso.CFrame
						})
						able({
							FX = FX,
							On = false
						})
						FX:ScaleTo(2)
						lifeScale({
							FX = FX,
							Scale = 5
						})
						playAttachment(FX)
						libraryNew.MeshEmit.Emit(FX)
						local FX2 = quickFX({
							FX = vfx.Marking,
							Maid = object._maid,
							Anchor = victim.Torso.CFrame
						})
						FX2:ScaleTo(2)
						able({
							FX = FX2,
							On = false
						})
						playAttachment(FX2)
						libraryNew.MeshEmit.Emit(FX2)
						local FX3 = quickFX({
							FX = vfx.Small,
							Maid = object._maid,
							Anchor = victim.Torso.CFrame
						})
						able({
							FX = FX3,
							On = false
						})
						FX3:ScaleTo(1)
						lifeScale({
							FX = FX3,
							Scale = 0.7
						})
						playAttachment(FX3)
						libraryNew.MeshEmit.Emit(FX3)

						if not v13() then
							local RunService = game:GetService("RunService")
							return RunService:UnbindFromRenderStep("BeastBreathingCamera")
						end

						local function Ok()
							if not v13() then
								local RunService = game:GetService("RunService")
								return RunService:UnbindFromRenderStep("BeastBreathingCamera")
							end

							local v17 = object._maid:give(vfx.Ok:Clone())
							v17:PivotTo(CFrame.new(victim.Torso.Position) * CFrame.new(0, 0, 0) * CFrame.Angles(
								1.5707963267948966,
								0,
								0
							))
							v17.Parent = EFP
							local fx = v17.Fx
							local _51F = fx["51F"]
							fn(_51F)

							for i, part in pairs(fx.Parent:GetChildren()) do
								if part:IsA("BasePart") and part.Name ~= "Fx" then
									part.Parent = _51F
								end
							end

							if not v13() then
								local RunService = game:GetService("RunService")
								return RunService:UnbindFromRenderStep("BeastBreathingCamera")
							end

							local longMesh = _51F.LongMesh
							longMesh.Decal.Transparency = 0
							TweenService:Create(longMesh.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
								Offset = createVector(-0, -9, -0),
								Scale = createVector(-0.225, -0.9, -0.225)
							}):Play()
							TweenService:Create(longMesh.Decal, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
								Transparency = 1
							}):Play()
							TweenService:Create(longMesh, TweenInfo.new(0.5), {
								CFrame = longMesh.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
							}):Play()
							local swirlMesh = _51F.SwirlMesh
							swirlMesh.Transparency = 0
							TweenService:Create(swirlMesh, TweenInfo.new(0.6), {
								Size = createVector(5, 38.25, 5),
								CFrame = swirlMesh.CFrame * CFrame.new(0, -33.75, 0) * CFrame.Angles(
									0,
									3.141592653589793,
									0
								),
								Transparency = 1
							}):Play()

							for i = 1, 2 do
								if not v13() then
									local RunService = game:GetService("RunService")
									return RunService:UnbindFromRenderStep("BeastBreathingCamera")
								end

								local v18 = i * 2 + 1
								local clone = _51F.AirMesh:Clone()
								clone.Parent = _51F
								clone.Mesh.Scale /= v18
								clone.Mesh.Offset /= v18
								clone.Decal.Transparency = 0.75
								clone.CFrame *= CFrame.Angles(0, rad((random2(-360, 360))), 0)
								TweenService:Create(clone, TweenInfo.new(3 / v18, Enum.EasingStyle.Quart), {
									Orientation = clone.Orientation - createVector(1, 0, 0) * (180 / i)
								}):Play()
								TweenService:Create(clone.Mesh, TweenInfo.new(3 / v18, Enum.EasingStyle.Quart), {
									Scale = clone.Mesh.Scale * (v18 * 2.5),
									Offset = clone.Mesh.Offset - createVector(0, 1, 0) * (i * 18)
								}):Play()
								TweenService:Create(clone.Decal, TweenInfo.new(3 / v18, Enum.EasingStyle.Quart), {
									Transparency = 1
								}):Play()
							end

							if not v13() then
								local RunService = game:GetService("RunService")
								return RunService:UnbindFromRenderStep("BeastBreathingCamera")
							end

							local hit = _51F.Hit
							local clone = hit.FlashMesh:Clone()
							clone.Parent = hit
							clone.Decal.Transparency = 0
							TweenService:Create(clone.Mesh, TweenInfo.new(0.25), {
								Scale = createVector(-0.9, -0.225, -0.225),
								Offset = createVector(11.25, 0, 0)
							}):Play()
							TweenService:Create(clone.Decal, TweenInfo.new(0.25), {
								Transparency = 1
							}):Play()

							if not v13() then
								local RunService = game:GetService("RunService")
								return RunService:UnbindFromRenderStep("BeastBreathingCamera")
							end

							for i = 1, 2 do
								if not v13() then
									local RunService = game:GetService("RunService")
									return RunService:UnbindFromRenderStep("BeastBreathingCamera")
								end

								local clone2 = hit.SwirlMesh:Clone()
								clone2.Parent = fx
								clone2.CFrame = _51F.WorldCFrame * CFrame.Angles(
									rad((random2(-360, 360))),
									rad((random2(-360, 360))),
									(rad((random2(-360, 360))))
								)
								TweenService:Create(clone2, TweenInfo.new(random2(5, 10) / 10), {
									Size = Vector3.new(random2(18, 27), random2(9, 18), random2(18, 27)),
									Orientation = createVector(0, 1, 0) * random2(90, 180),
									Transparency = 1,
									Color = Color3.new(0.5, 0, 0)
								}):Play()
							end

							local beams = _51F.Beams
							fn2(beams)
							TweenService:Create(beams, TweenInfo.new(0.5), {
								CFrame = beams.CFrame * CFrame.new(0, 0, -18)
							}):Play()

							for i, beam in beams:GetDescendants() do
								if beam:IsA("Beam") then
									TweenService:Create(beam, TweenInfo.new(0.5), {
										Brightness = 0,
										TextureSpeed = -0.1
									}):Play()
								end
							end

							if not v13() then
								local RunService = game:GetService("RunService")
								return RunService:UnbindFromRenderStep("BeastBreathingCamera")
							end

							local burstMesh = _51F.BurstMesh
							burstMesh.Transparency = 0.5
							TweenService:Create(burstMesh, TweenInfo.new(0.1), {
								Size = createVector(56.25, 0, 0),
								CFrame = burstMesh.CFrame * CFrame.new(-27, 0, 0) * CFrame.Angles(
									-2.530727415391778,
									0,
									0
								)
							}):Play()
							game.Debris:AddItem(burstMesh, 0.1)
							local shockMesh = _51F.ShockMesh
							shockMesh.Transparency = 0.5
							TweenService:Create(shockMesh, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
								Size = createVector(25, 78.75, 25),
								Transparency = 1,
								CFrame = shockMesh.CFrame * CFrame.new(0, -10, 0) * CFrame.Angles(
									0,
									-1.5707963267948966,
									0
								)
							}):Play()
							local whirlMesh = _51F.WhirlMesh
							whirlMesh.Transparency = 0.75
							TweenService:Create(whirlMesh, TweenInfo.new(1, Enum.EasingStyle.Quint), {
								Size = createVector(33.75, 56.25, 33.75),
								CFrame = whirlMesh.CFrame * CFrame.new(0, -18, 0) * CFrame.Angles(
									0,
									3.141592653589793,
									0
								),
								Transparency = 1
							}):Play()
							local light = _51F.Hit.Light
							light.Enabled = true
							TweenService:Create(light, TweenInfo.new(0.5), {
								Brightness = 0
							}):Play()
							local largeMesh = _51F.LargeMesh
							largeMesh.Decal.Transparency = 0
							TweenService:Create(largeMesh, TweenInfo.new(0.5), {
								Orientation = largeMesh.Orientation + createVector(180, 0, 0)
							}):Play()
							TweenService:Create(largeMesh.Mesh, TweenInfo.new(0.5), {
								Scale = createVector(-2.25, -1.1, -1.1),
								Offset = createVector(22.5, 0, 0)
							}):Play()
							TweenService:Create(largeMesh.Decal, TweenInfo.new(0.5), {
								Transparency = 1
							}):Play()
							local uglyMesh = _51F.UglyMesh
							uglyMesh.Transparency = 0.75
							TweenService:Create(uglyMesh, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {
								Size = createVector(56.25, 45, 56.25),
								Transparency = 1,
								Orientation = uglyMesh.Orientation + createVector(180, 0, 0),
								Position = uglyMesh.Position - createVector(0, 0, 6.75)
							}):Play()
							local lingerMesh = _51F.LingerMesh
							lingerMesh.Transparency = 0.7
							TweenService:Create(lingerMesh, TweenInfo.new(1, Enum.EasingStyle.Quint), {
								Size = createVector(33.75, 78.75, 33.75),
								Position = lingerMesh.Position - createVector(0, 0, 27),
								Transparency = 1,
								CFrame = lingerMesh.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
							}):Play()
							print(_51F:GetChildren())
							local contrastMesh = _51F.ContrastMesh
							contrastMesh.Decal.Transparency = -2
							TweenService:Create(contrastMesh.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
								Scale = createVector(-2, -0.8, -0.8),
								Offset = createVector(25, 0, 0)
							}):Play()
							TweenService:Create(contrastMesh.Decal, TweenInfo.new(0.5), {
								Transparency = 1,
								Color3 = Color3.new(0.25, 0, 0)
							}):Play()
						end

						dtwait(0.2)

						if not v13() then
							local RunService = game:GetService("RunService")
							return RunService:UnbindFromRenderStep("BeastBreathingCamera")
						end

						local v17 = quickFX({
							FX = vfx.Bubble2,
							Maid = object._maid,
							Anchor = victim.Torso.CFrame
						})
						v17:ScaleTo(2)
						playAttachment(v17)
						libraryNew.MeshEmit.Emit(v17)
						local v18 = object._maid:give(Instance.new("Highlight"))
						v18.FillTransparency = -1
						v18.DepthMode = Enum.HighlightDepthMode.Occluded
						v18.OutlineTransparency = 1
						v18.FillColor = Color3.new(0.721569, 0.0784314, 0.0784314)
						v18.Parent = victim
						TweenService:Create(v18, TweenInfo.new(2, Enum.EasingStyle.Sine), {
							FillTransparency = 1
						}):Play()
					end })
			end

			TheHitEvent()
		end)
		wait(15)
		Clean() -- equivalent call inferred; original call site unknown
		break
	end
end

return FirstMoveRetrySend
local createVector = vector.create
local Emerge = {}
local library = require(game.ReplicatedStorage.library)
local playAttachment = library.PlayAttachment
local maid = library.Maid
local _ = library.PlayTween
local _ = library.CamShake
local _ = library.PlayFlipBook
local dtwait = library.dtwait
local _ = library.EFP
local _ = library.PlayMesh
local _ = library.Impact
local _ = library.GlassLight
local _ = library.RaiseZIndex
local able = library.Able
local _ = library.LifeScale
local _ = library.QuickFX
local quickWeld = library.QuickWeld
local _ = library.Yield
local _ = library.ProcessPart
local _ = library.WeldObject
local _ = library.Bezier
local vfx = script.vfx
local class = {}
class.__index = class
Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local camera = game.Workspace.Camera

function Emerge.FirstEvent(data)
	local char = data.Char
	local _ = char == game.Players.LocalPlayer.Character
	shared.NerfVfx({
		Script = script,
		Char = char
	})
	local cleanupTable = data.CleanupTable
	local realAnim = data.RealAnim
	local bind = data.Bind
	tick()
	local _ = char.Humanoid
	local _ = char.HumanoidRootPart
	local v = char ~= game.Players.LocalPlayer.Character and char ~= data.targChar

	local function GetTorsoCF()
		local _, v2, _ = char.HumanoidRootPart.CFrame:ToOrientation()
		return CFrame.new(char.Torso.Position) * CFrame.Angles(0, v2, 0)
	end

	local object = setmetatable({}, class)
	object._maid = maid.new()
	local parentChangedConnection = nil
	local v2 = false
	local v3 = nil
	local _ = Color3.fromRGB
	local fn
	local v4 = false
	local thread = task.delay(5.05, function()
		v4 = true
	end)
	local v5 = nil
	local v6 = false

	local function fn2(p)
		if not v6 and realAnim and realAnim.IsPlaying and bind and bind.Parent then
			return true
		end

		if v4 and not p then
			if v5 and (not v5 or v5.Parent) then
				return true
			end
		else
			if thread then
				task.cancel(thread)
			end

			v6 = true
		end

		return false
	end

	local function Clean()
		if not v2 then
			v2 = true

			if v3 then
				game.Debris:AddItem(v3, 0.5)
				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(v3, TweenInfo.new(0.5), {
					Contrast = 0,
					Saturation = 0,
					Brightness = 0,
					TintColor = Color3.fromRGB(255, 255, 255)
				}):Play()
			end

			shared.originallighting({
				time = 0.5
			})

			if parentChangedConnection then
				parentChangedConnection:Disconnect()
			end

			if fn then
				fn(false)
			end

			if char:FindFirstChild("ConfirmedEmerge") then
				warn("fa")
			else
				object._maid:doCleaning()
			end
		end
	end

	parentChangedConnection = bind:GetPropertyChangedSignal("Parent"):Connect(function()
		if bind and bind.Parent then
			return
		end

		v6 = true
		Clean()
		return parentChangedConnection:Disconnect()
	end)
	task.delay(20, function()
		if parentChangedConnection then
			return parentChangedConnection:Disconnect()
		end
	end)
	task.delay(20, function()
		Clean()
	end)

	if not fn2() then
		return
	end

	local function thingable(folder, enabled, className)
		if not fn2() then
			return
		end

		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant:IsA(className) then
				descendant.Enabled = enabled
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function tween(instance, tweenInfo, data2)
		task.spawn(function()
			if instance:FindFirstChildWhichIsA("SpecialMesh") then
				TweenService:Create(instance, tweenInfo, {
					CFrame = data2.cframe
				}):Play()
				TweenService:Create(instance:FindFirstChildWhichIsA("SpecialMesh"), tweenInfo, {
					Scale = data2.scale
				}):Play()
			else
				TweenService:Create(instance, tweenInfo, {
					CFrame = data2.cframe,
					Size = data2.size,
					Transparency = data2.transparency1
				}):Play()
			end

			for _, decal in pairs(instance:GetChildren()) do
				if decal:IsA("Decal") then
					TweenService:Create(decal, tweenInfo, {
						Transparency = data2.transparency2
					}):Play()
				end
			end
		end)
	end

	local function tweensequence(data2)
		local twtype = data2.twtype
		local childtype = data2.childtype
		local newvalues = data2.newvalues
		local amount = data2.amount
		local particle = data2.particle
		local name = data2.name
		task.spawn(function()
			for _, child in pairs(particle:GetChildren()) do
				if name then
					if child:IsA(childtype) and child.name == name then
						local numberSequencesByTwtype = child
						local keypoints = {}
						local numberSequenceKeypoints = {}
						task.spawn(function()
							for i = 1, amount do
								for k, keypoint in pairs(numberSequencesByTwtype[twtype].Keypoints) do
									table.insert(keypoints, keypoint)
								end

								for k, v9 in pairs(keypoints) do
									local numberSequenceKeypoint = NumberSequenceKeypoint.new(
										v9.Time + newvalues[1],
										v9.Value + newvalues[2],
										v9.Envelope + newvalues[3]
									)
									table.insert(numberSequenceKeypoints, numberSequenceKeypoint)
								end

								numberSequencesByTwtype[twtype] = NumberSequence.new(numberSequenceKeypoints)
								table.clear(numberSequenceKeypoints)
								table.clear(keypoints)
								task.wait()
							end
						end)
					end
				elseif child:IsA(childtype) then
					local numberSequencesByTwtype = child
					local keypoints = {}
					local numberSequenceKeypoints = {}
					task.spawn(function()
						for i = 1, amount do
							for k, keypoint in pairs(numberSequencesByTwtype[twtype].Keypoints) do
								table.insert(keypoints, keypoint)
							end

							for k, v9 in pairs(keypoints) do
								local numberSequenceKeypoint = NumberSequenceKeypoint.new(
									v9.Time + newvalues[1],
									v9.Value + newvalues[2],
									v9.Envelope + newvalues[3]
								)
								table.insert(numberSequenceKeypoints, numberSequenceKeypoint)
							end

							numberSequencesByTwtype[twtype] = NumberSequence.new(numberSequenceKeypoints)
							table.clear(numberSequenceKeypoints)
							table.clear(keypoints)
							task.wait()
						end
					end)
				end
			end
		end)
	end

	local function makemesh(data2)
		local clone = data2.mesh:Clone()
		game.Debris:AddItem(clone, 15)
		clone.Parent = workspace.Thrown
		object._maid:give(clone)
		clone.CFrame = data2.cframe

		if clone:FindFirstChildWhichIsA("SpecialMesh") and data2.scale then
			local specialMesh = clone:FindFirstChildWhichIsA("SpecialMesh")
			specialMesh.Scale = data2.scale
		elseif data2.size then
			clone.Size = data2.size
		end

		local v7 = nil

		for _, decal in pairs(clone:GetChildren()) do
			if not decal:IsA("Decal") then
				continue
			end

			decal.Transparency = data2.transparency
			v7 = true
		end

		if not v7 then
			clone.Transparency = data2.transparency
		end

		return clone
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function changecc(p, data2)
		if not fn2() then
			return
		end

		p.Brightness = data2.b
		p.Contrast = data2.c
		p.TintColor = data2.tc
		p.Saturation = data2.s
		dtwait(data2.w)
	end

	local function FirstEvent()
		local thrown = workspace.Thrown
		local char2 = char
		local targChar = data.targChar
		local lastTime = tick()
		local folder = nil

		while true do
			task.wait()

			if not fn2() then
				break
			end

			for _, child in pairs(workspace.Thrown:GetChildren()) do
				local name = child.Name

				if not (name:find((tostring(targChar))) and name:find("EmergeClone")) then
					continue
				end

				folder = child
				break
			end

			if not (folder or tick() - lastTime >= 0.5) then
				continue
			end

			if not folder then
				return warn("no clone")
			end

			if not fn2() then
				break
			end

			v5 = folder
			local v10 = {}

			local function parent(child, folder2)
				local parent2 = folder2[tostring(child)]

				if not parent2 then
					return
				end

				for i, child2 in pairs(child:GetChildren()) do
					if not fn2() then
						return
					end

					local clone = child2:Clone()
					clone.Parent = parent2

					for i2, beam in pairs(clone:GetDescendants()) do
						if beam:IsA("Beam") and beam.Attachment0 and beam.Attachment1 then
							v10[beam] = {
								Attachment0 = beam.Attachment0.CFrame,
								Attachment1 = beam.Attachment1.CFrame
							}
						end
					end
				end

				if next(v10) then
					for k, v12 in pairs(v10) do
						if not fn2() then
							return
						end

						local attachment0 = v12.Attachment0
						local attachment1 = v12.Attachment1

						if not (k.Parent and k.Parent.Parent) then
							continue
						end

						for i, attachment in pairs(folder2:GetDescendants()) do
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

			local v11 = {}
			local instances = v11
			local descendantAddedConnection = targChar.DescendantAdded:Connect(function(instance)
				if instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("PointLight") or instance:IsA("Trail") then
					table.insert(instances, instance)
				end
			end)
			table.insert(cleanupTable, descendantAddedConnection)
			object._maid:give(descendantAddedConnection)
			task.delay(20, function()
				if descendantAddedConnection then
					descendantAddedConnection:Disconnect()
				end
			end)

			for _, child in pairs(targChar:GetChildren()) do
				if not fn2() then
					return
				end

				local child2 = script.Victim:FindFirstChild((tostring(child)))

				if child2 then
					parent(child2, targChar)
				end
			end

			fn = function(enabled)
				for k, v13 in pairs(v11) do
					v13.Enabled = enabled
				end
			end

			if not fn2() then
				break
			end

			local cFrame = char2.PrimaryPart.CFrame
			local clone = script.ColorCorrection:Clone()
			table.insert(cleanupTable, clone)
			game.Debris:AddItem(clone, 15)

			if not v then
				clone.Parent = game.Lighting
			end

			v3 = clone
			local clone2 = script.ScreenGui:Clone()
			table.insert(cleanupTable, clone2)
			game.Debris:AddItem(clone2, 15)
			clone2.Parent = game.StarterGui
			object._maid:give(clone2)
			local FX = quickWeld({
				FX = vfx.ShadowFloorFx,
				Maid = object._maid,
				P = char2.PrimaryPart,
				C0 = CFrame.new(-0.106, 2.9, 15.009)
			})
			local FX2 = quickWeld({
				FX = vfx.Bg,
				Maid = object._maid,
				P = char2.PrimaryPart,
				C0 = CFrame.new(-15.349, -5.041, 3.484) * CFrame.Angles(0, -1.5707963267948966, 0)
			})
			local v15 = quickWeld({
				FX = vfx.BgFloor1,
				Maid = object._maid,
				P = char2.PrimaryPart,
				C0 = CFrame.new(15.403, 4.369, -3) * CFrame.Angles(-1.5707963267948966, 1.5707963267948966, 0)
			})

			for _, v16 in pairs({ FX, FX2, v15 }) do
				game.Debris:AddItem(v16, 15)
				table.insert(cleanupTable, v16)
			end

			if v then
				FX2.Parent = nil
				v15.Parent = nil
			end

			dtwait(0.25)

			if not fn2() then
				break
			end

			local v16 = quickWeld({
				FX = vfx.ForTestFx,
				Maid = object._maid,
				P = char2.PrimaryPart,
				C0 = CFrame.new(-0.585, 0.175, 3.808)
			})
			playAttachment(v16)
			game.Debris:AddItem(v16, 15)
			table.insert(cleanupTable, v16)
			dtwait(0.65)

			if not fn2() then
				break
			end

			local folder2 = clone2
			task.delay(0.05, function()
				if not fn2() then
					return
				end

				for i, descendant in pairs(folder2:GetDescendants()) do
					TweenService:Create(descendant, TweenInfo.new(0.17, Enum.EasingStyle.Linear), {
						ImageTransparency = 0
					}):Play()
				end
			end)

			if not fn2() then
				break
			end

			local clone3 = vfx.TrailPart1:Clone()
			table.insert(cleanupTable, clone3)
			clone3.Parent = thrown
			game.Debris:AddItem(clone3, 15)
			clone3.CFrame = char2.PrimaryPart.CFrame * CFrame.new(-1.379, -2.5, -14.218) * CFrame.Angles(
				0,
				1.5813381154769424,
				0
			)
			object._maid:give(clone3)
			thingable(clone3, true, "Trail")
			local clone4 = vfx.TrailPart2:Clone()
			table.insert(cleanupTable, clone4)
			clone4.Parent = thrown
			clone4.CFrame = char2.PrimaryPart.CFrame * CFrame.new(-0.018, -1, -15.078) * CFrame.Angles(
				0,
				-3.135553814377893,
				0
			)
			object._maid:give(clone4)
			thingable(clone4, true, "Trail")
			game.Debris:AddItem(clone4, 15)
			local FX3 = quickWeld({
				FX = vfx.ShadowFx,
				Maid = object._maid,
				P = char2.PrimaryPart,
				C0 = CFrame.new(-0.002, 2.95, 15.09)
			})
			game.Debris:AddItem(FX3, 5)
			able({
				FX = FX3,
				On = true
			})
			game.Debris:AddItem(FX3, 15)
			task.spawn(function()
				for i = 1, 12 do
					if not fn2() then
						break
					end

					tween(clone3, TweenInfo.new(0.12, Enum.EasingStyle.Linear), {
						cframe = clone3.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
					}) -- equivalent call inferred; original call site unknown
					tween(clone4, TweenInfo.new(0.12, Enum.EasingStyle.Linear), {
						cframe = clone4.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
					}) -- equivalent call inferred; original call site unknown
					dtwait(0.121)
				end
			end)
			local pointLight = v15:FindFirstChild("PointLight", true)
			local pointLight2 = FX:FindFirstChild("PointLight", true)
			TweenService:Create(clone, TweenInfo.new(0.07), {
				Brightness = 0.05,
				Contrast = 0.2,
				Saturation = 0.2,
				TintColor = Color3.fromRGB(212, 226, 255)
			}):Play()
			task.delay(0.45, function()
				if not fn2(true) then
					return
				end

				TweenService:Create(pointLight, TweenInfo.new(0.12), {
					Brightness = 5
				}):Play()
				dtwait(0.83)

				if not fn2(true) then
					return
				end

				TweenService:Create(pointLight2, TweenInfo.new(0.19), {
					Brightness = 7
				}):Play()
				dtwait(0.39)

				if not fn2(true) then
					return
				end

				TweenService:Create(pointLight, TweenInfo.new(0.3), {
					Brightness = 0
				}):Play()
				dtwait(2.35)

				if not fn2(true) then
					return
				end

				TweenService:Create(pointLight2, TweenInfo.new(0.15), {
					Brightness = 0
				}):Play()
			end)
			dtwait(0.6)

			if not fn2() then
				break
			end

			fn(true)
			local clone5 = vfx.Beam1:Clone()
			table.insert(cleanupTable, clone5)
			clone5.Parent = thrown
			clone5.CFrame = char2.PrimaryPart.CFrame * CFrame.new(-0.006, -1.05, -15.495)
			object._maid:give(clone5)
			thingable(clone5, true, "Beam")
			game.Debris:AddItem(clone5, 15)
			local fromRGB = Color3.fromRGB

			if not fn2() then
				break
			end

			task.spawn(function()
				if not fn2() then
					return
				end

				changecc(clone, {
					b = 2,
					c = 5,
					s = -1,
					tc = fromRGB(149, 171, 255),
					w = 0.017
				}) -- equivalent call inferred; original call site unknown
				changecc(clone, {
					b = 0.2,
					c = -2,
					s = -1,
					tc = fromRGB(170, 189, 255),
					w = 0.017
				}) -- equivalent call inferred; original call site unknown
				changecc(clone, {
					b = 2,
					c = 5,
					s = -1,
					tc = fromRGB(149, 171, 255),
					w = 0.017
				}) -- equivalent call inferred; original call site unknown
				changecc(clone, {
					b = 1.125,
					c = 5,
					s = -1,
					tc = fromRGB(139, 162, 255),
					w = 0.017
				}) -- equivalent call inferred; original call site unknown
				changecc(clone, {
					b = 2,
					c = 5,
					s = -1,
					tc = fromRGB(149, 171, 255),
					w = 0.017
				}) -- equivalent call inferred; original call site unknown
				changecc(clone, {
					b = 0.25,
					c = 5,
					s = -1,
					tc = fromRGB(129, 152, 255),
					w = 0.017
				}) -- equivalent call inferred; original call site unknown
				TweenService:Create(clone, TweenInfo.new(0.07), {
					Brightness = -0.006,
					Contrast = 0.2,
					Saturation = 0.2,
					TintColor = Color3.fromRGB(212, 226, 255)
				}):Play()
			end)
			task.spawn(function()
				for i = 1, 11 do
					if not fn2() then
						break
					end

					tween(clone5, TweenInfo.new(0.12, Enum.EasingStyle.Linear), {
						cframe = clone5.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
					}) -- equivalent call inferred; original call site unknown
					dtwait(0.121)
				end
			end)
			thingable(FX2, true, "Beam")
			thingable(v15, true, "Beam")
			playAttachment(camera)
			FX2.Transparency = 0
			v15.Transparency = 0
			local v25 = quickWeld({
				FX = vfx.Ball,
				Maid = object._maid,
				P = char2.PrimaryPart,
				C0 = CFrame.new(0, 0, 15)
			})
			table.insert(cleanupTable, v25)

			if v then
				v25.Parent = nil
			end

			game.Debris:AddItem(v25, 15)
			tween(v25, TweenInfo.new(0.8, Enum.EasingStyle.Linear), {
				transparency1 = 0
			}) -- equivalent call inferred; original call site unknown
			tween(v25.Floor, TweenInfo.new(0.8, Enum.EasingStyle.Linear), {
				transparency1 = 0
			}) -- equivalent call inferred; original call site unknown
			dtwait(1)

			if not fn2() then
				break
			end

			thingable(clone3, false, "Trail")
			thingable(clone4, false, "Trail")
			thingable(clone5, false, "Beam")
			FX2.Transparency = 1
			v15.Transparency = 1
			thingable(FX, true, "Beam")
			thingable(v15, false, "Beam")
			thingable(FX2, false, "Beam")
			able({
				FX = FX2,
				On = true
			})
			dtwait(0.066)

			if not fn2() then
				break
			end

			local clone6 = vfx.Tornado:Clone()
			table.insert(cleanupTable, clone6)
			clone6.Parent = thrown
			clone6.CFrame = char2.PrimaryPart.CFrame * CFrame.new(-0.015, 1.805, -14.495) * CFrame.Angles(
				0,
				-1.913840791274382,
				0
			)
			object._maid:give(clone6)
			game.Debris:AddItem(clone6, 15)
			thingable(clone6, true, "Beam")
			able({
				FX = clone6,
				On = true
			})
			TweenService:Create(clone6, TweenInfo.new(0.12), {
				Transparency = 0.8
			}):Play()
			local clone7 = vfx.Tornado2:Clone()
			table.insert(cleanupTable, clone7)
			clone7.Parent = thrown
			clone7.CFrame = char2.PrimaryPart.CFrame * CFrame.new(-0.015, 3.754, -14.495) * CFrame.Angles(
				0,
				1.913840791274382,
				3.141592653589793
			)
			object._maid:give(clone7)
			game.Debris:AddItem(clone7, 15)
			thingable(clone7, true, "Beam")
			able({
				FX = FX,
				On = true
			})
			local FX4 = quickWeld({
				FX = vfx.TextFx,
				Maid = object._maid,
				P = char2.PrimaryPart,
				C0 = CFrame.new(-0.092, -2.727, 14.406)
			})
			able({
				FX = FX4,
				On = true
			})
			table.insert(cleanupTable, FX4)
			game.Debris:AddItem(FX4, 15)
			clone.Brightness = -0.1
			task.spawn(function()
				for i = 1, 100 do
					if not fn2() then
						break
					end

					tween(clone6, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
						cframe = clone6.CFrame * CFrame.Angles(0, 0.5759586531581288, 0)
					}) -- equivalent call inferred; original call site unknown
					tween(clone7, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
						cframe = clone7.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
					}) -- equivalent call inferred; original call site unknown
					dtwait(0.051)
				end
			end)
			local lighting = game.Lighting
			local tween2 = TweenService:Create(lighting, TweenInfo.new(0.2), {
				Brightness = 0,
				EnvironmentDiffuseScale = 0,
				EnvironmentSpecularScale = 0
			})

			if not v then
				tween2:Play()
			end

			local v31 = clone
			local v32 = fromRGB
			task.delay(0.05, function()
				if not fn2(true) then
					return
				end

				TweenService:Create(v31, TweenInfo.new(0.217), {
					Brightness = 0,
					Contrast = 0.5,
					Saturation = 0.2,
					TintColor = Color3.fromRGB(212, 226, 255)
				}):Play()
				dtwait(2.35)

				if not fn2(true) then
					return
				end

				task.spawn(function()
					if not fn2(true) then
						return
					end

					changecc(v31, {
						b = -0.5,
						c = 5,
						s = -1,
						tc = v32(149, 171, 255),
						w = 0.033
					}) -- equivalent call inferred; original call site unknown
					changecc(v31, {
						b = 0.1,
						c = -4,
						s = -1,
						tc = v32(162, 182, 255),
						w = 0.033
					}) -- equivalent call inferred; original call site unknown
					changecc(v31, {
						b = -9,
						c = 55,
						s = -1,
						tc = v32(174, 193, 255),
						w = 0.033
					}) -- equivalent call inferred; original call site unknown
					changecc(v31, {
						b = 15,
						c = -45,
						s = -1,
						tc = v32(187, 204, 255),
						w = 0.017
					}) -- equivalent call inferred; original call site unknown
					changecc(v31, {
						b = 2,
						c = -33,
						s = -1,
						tc = v32(193, 209, 255),
						w = 0.017
					}) -- equivalent call inferred; original call site unknown
					changecc(v31, {
						b = -1,
						c = 0.25,
						s = -0.4,
						tc = v32(205, 220, 255),
						w = 0.017
					}) -- equivalent call inferred; original call site unknown
					changecc(v31, {
						b = 0,
						c = 0.5,
						s = 0.2,
						tc = v32(212, 226, 255),
						w = 0
					}) -- equivalent call inferred; original call site unknown
					TweenService:Create(v31, TweenInfo.new(0.07), {
						Brightness = 0,
						Contrast = 0,
						Saturation = 0,
						TintColor = Color3.fromRGB(255, 255, 255)
					}):Play()

					if fn2(true) then
					end
				end)

				if not fn2(true) then
					return
				end

				local tween3 = TweenService:Create(lighting, TweenInfo.new(0.01), {
					Brightness = 3,
					EnvironmentDiffuseScale = 1,
					EnvironmentSpecularScale = 1
				})

				if not v then
					tween3:Play()
				end

				local clone8 = vfx.WindMesh:Clone()
				table.insert(cleanupTable, clone8)
				game.Debris:AddItem(clone8, 15)
				clone8.Parent = thrown
				clone8.CFrame = char2.PrimaryPart.CFrame * CFrame.new(-1.093, -0.5, -14.607) * CFrame.Angles(
					0,
					0,
					3.141592653589793
				)
				clone8.Transparency = 0
				object._maid:give(clone8)
				tween(clone8, TweenInfo.new(1.02), {
					cframe = clone8.CFrame * CFrame.Angles(0, -1.5707963267948966, 0),
					size = createVector(25, 25, 25)
				}) -- equivalent call inferred; original call site unknown
				tween(clone8, TweenInfo.new(0.7), {
					transparency1 = 1
				}) -- equivalent call inferred; original call site unknown
			end)
			dtwait(2.57)

			if not fn2() then
				break
			end

			TweenService:Create(clone6, TweenInfo.new(0.12), {
				Transparency = 1
			}):Play()
			able({
				FX = clone6,
				On = false
			})
			able({
				FX = FX4,
				On = false
			})
			able({
				FX = FX,
				On = false
			})
			able({
				FX = FX3,
				On = false
			})
			thingable(clone7, false, "Beam")
			thingable(clone6, false, "Beam")
			thingable(FX, false, "Beam")
			thingable(targChar, false, "Beam")

			for _, descendant in pairs(clone2:GetDescendants()) do
				descendant.ImageTransparency = 1
			end

			v25.Transparency = 1
			v25.Floor.Transparency = 1
			local clone8 = vfx.Shadow1Fx:Clone()
			table.insert(cleanupTable, clone8)
			clone8.Parent = workspace.Thrown
			clone8.CFrame = cFrame * CFrame.new(-0.002, -2.9, -15.09)
			playAttachment(clone8)
			game.Debris:AddItem(clone8, 15)

			for _, effect in pairs(folder:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
					effect.Enabled = true
				end
			end

			shared.originallighting({
				time = 0.5
			})

			if not fn2() then
				break
			end

			dtwait(2.84)

			if not fn2() then
				break
			end

			local cframe = CFrame.new(0.495, -3, -11.679)

			if fn2() then
				local clone9 = vfx[tostring("StepFx")]:Clone()
				clone9.Parent = workspace.Thrown
				clone9.CFrame = cFrame * cframe
				playAttachment(clone9)
			end

			dtwait(0.93)
			local cframe2 = CFrame.new(-0.912, -3, -9.71)

			if fn2() then
				local clone9 = vfx[tostring("Step1Fx")]:Clone()
				clone9.Parent = workspace.Thrown
				clone9.CFrame = cFrame * cframe2
				playAttachment(clone9)
			end

			dtwait(0.86)
			local cframe3 = CFrame.new(0.264, -3, -6.805)

			if fn2() then
				local clone9 = vfx[tostring("Step2Fx")]:Clone()
				clone9.Parent = workspace.Thrown
				clone9.CFrame = cFrame * cframe3
				playAttachment(clone9)
			end

			dtwait(0.9)
			local cframe4 = CFrame.new(-0.744, -3, -4.72)

			if fn2() then
				local clone9 = vfx[tostring("Step3Fx")]:Clone()
				clone9.Parent = workspace.Thrown
				clone9.CFrame = cFrame * cframe4
				playAttachment(clone9)
			end

			if not fn2() then
				break
			end

			local clone9 = vfx.TrailPart3:Clone()
			clone9.Parent = thrown
			clone9.CFrame = cFrame * CFrame.new(0, -2.3, -5.407) * CFrame.Angles(0, 1.5707963267948966, 0)
			object._maid:give(clone9)
			thingable(clone9, true, "Trail")
			game.Debris:AddItem(clone9, 15)
			local clone10 = vfx.TrailPart4:Clone()
			game.Debris:AddItem(clone10, 15)
			clone10.Parent = thrown
			clone10.CFrame = cFrame * CFrame.new(0, -2.3, -5.397) * CFrame.Angles(0, 1.5707963267948966, 0)
			object._maid:give(clone10)
			thingable(clone10, true, "Trail")
			task.spawn(function()
				for i = 1, 9 do
					if not fn2() then
						break
					end

					tween(clone9, TweenInfo.new(0.07, Enum.EasingStyle.Linear), {
						cframe = clone9.CFrame * CFrame.new(0, 0.34, 0) * CFrame.Angles(0, 1.5707963267948966, 0)
					}) -- equivalent call inferred; original call site unknown

					if i >= 4 then
						tween(clone10, TweenInfo.new(0.07, Enum.EasingStyle.Linear), {
							cframe = clone10.CFrame * CFrame.new(0, 0.25, 0) * CFrame.Angles(0, 1.5707963267948966, 0)
						}) -- equivalent call inferred; original call site unknown
					end

					dtwait(0.07)
				end
			end)
			break
		end
	end

	task.spawn(FirstEvent)
	wait(20)
	Clean()
end

return Emerge
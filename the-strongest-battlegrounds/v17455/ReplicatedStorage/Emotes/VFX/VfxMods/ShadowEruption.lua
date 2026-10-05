local createVector = vector.create
local ShadowEruption = {}
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

function ShadowEruption.FirstEvent(data)
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
	local v = char ~= game.Players.LocalPlayer.Character

	local function GetTorsoCF()
		local _, v2, _ = char.HumanoidRootPart.CFrame:ToOrientation()
		return CFrame.new(char.Torso.Position) * CFrame.Angles(0, v2, 0)
	end

	local v2 = false
	local v3 = nil
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local parentChangedConnection = nil
	local v4 = false
	local v5 = nil

	local function Clean()
		if not v4 then
			v4 = true

			if parentChangedConnection then
				parentChangedConnection:Disconnect()
			end

			if v3 then
				game.Debris:AddItem(v3, 0.5)

				if v5 then
					v5:Pause(0)
					v5:Destroy()
				end

				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(v3, TweenInfo.new(0.5), {
					Contrast = 0,
					Saturation = 0,
					Brightness = 0,
					TintColor = Color3.fromRGB(255, 255, 255)
				}):Play()
			end

			object._maid:doCleaning()
		end
	end

	parentChangedConnection = bind:GetPropertyChangedSignal("Parent"):Connect(function()
		if bind and bind.Parent then
			return
		end

		v2 = true
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
	local v6

	if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
		v2 = true
		v6 = false
	else
		v6 = true
	end

	if not v6 then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function tween(instance, tweenInfo, data2, p)
		task.spawn(function()
			if p then
				dtwait(p)
			end

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
				dtwait(tweenInfo.Time)
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

	-- equivalent calls inferred from this helper; original call sites unknown
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

	local thrown = workspace.Thrown

	local function makemesh(data2)
		local v7

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v7 = false
		else
			v7 = true
		end

		if not v7 then
			return
		end

		local clone = data2.mesh:Clone()
		game.Debris:AddItem(clone, 20)
		table.insert(cleanupTable, clone)
		clone.Parent = thrown
		object._maid:give(clone)
		clone.CFrame = data2.cframe

		if clone:FindFirstChildWhichIsA("SpecialMesh") and data2.scale then
			local specialMesh = clone:FindFirstChildWhichIsA("SpecialMesh")
			specialMesh.Scale = data2.scale
		elseif data2.size then
			clone.Size = data2.size
		end

		local v8 = nil

		for _, decal in pairs(clone:GetChildren()) do
			if not decal:IsA("Decal") then
				continue
			end

			decal.Transparency = data2.transparency
			v8 = true
		end

		if not v8 then
			clone.Transparency = data2.transparency
		end

		return clone
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function changecc(p, data2)
		local v7

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v7 = false
		else
			v7 = true
		end

		if not v7 then
			return
		end

		p.Brightness = data2.b
		p.Contrast = data2.c
		p.TintColor = data2.tc
		p.Saturation = data2.s
		dtwait(data2.w)
	end

	local function FirstEvent()
		local folder = char
		local v7 = {}
		local v8 = {}

		local function parent(child, char2)
			local parent4 = char2[tostring(child)]

			if not parent4 then
				return
			end

			if not v7[char2] then
				v7[char2] = {}
			end

			for _, child2 in pairs(child:GetChildren()) do
				local v10

				if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v2 = true
					v10 = false
				else
					v10 = true
				end

				if not v10 then
					return
				end

				local clone = child2:Clone()
				game.Debris:AddItem(clone, 20)
				table.insert(cleanupTable, clone)
				clone.Parent = parent4
				table.insert(v7[char2], clone)

				for _, effect in pairs(clone:GetDescendants()) do
					if effect:IsA("Trail") or effect:IsA("Beam") or effect:IsA("ParticleEmitter") then
						effect.Enabled = true
					end

					if not (effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					table.insert(v7[char2], effect)

					if effect.Attachment0 and effect.Attachment1 then
						v8[effect] = {
							Attachment0 = effect.Attachment0.CFrame,
							Attachment1 = effect.Attachment1.CFrame
						}
					end
				end
			end

			if next(v8) then
				for k, v10 in pairs(v8) do
					local attachment0 = v10.Attachment0
					local attachment1 = v10.Attachment1
					local parent2 = k.Parent.Parent

					for _, attachment in pairs(folder:GetDescendants()) do
						if not attachment:IsA("Attachment") then
							continue
						end

						local parent3 = attachment.Parent

						if not (parent3 and parent3:IsA("BasePart") and parent3 == parent2) then
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

		local function thingable(folder2, enabled, className)
			if folder2.Parent == char then
				for _, v9 in pairs(effects) do
					local v10

					if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v2 = true
						v10 = false
					else
						v10 = true
					end

					if not v10 then
						return
					end

					if v9:IsA(className) and v9:GetAttribute("Made") then
						v9.Enabled = enabled
					end
				end
			else
				for _, descendant in pairs(folder2:GetDescendants()) do
					if descendant:IsA(className) and descendant:GetAttribute("Made") then
						descendant.Enabled = enabled
					end
				end
			end
		end

		local _ = data.targChar
		local descendantAddedConnection = char.DescendantAdded:Connect(function(effect)
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam") then
				if not effect:GetAttribute("Made") then
					return
				end

				game.Debris:AddItem(effect, 20)
				table.insert(cleanupTable, effect)
				table.insert(effects, effect)
			end
		end)
		table.insert(cleanupTable, descendantAddedConnection)

		for _, child in pairs(char:GetChildren()) do
			local v9

			if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v2 = true
				v9 = false
			else
				v9 = true
			end

			if not v9 then
				return
			end

			local child2 = script.R6:FindFirstChild((tostring(child)))

			if not child2 then
				continue
			end

			local v10

			if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v2 = true
				v10 = false
			else
				v10 = true
			end

			if not v10 then
				return
			end

			parent(child2, char)
		end

		local v9

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v9 = false
		else
			v9 = true
		end

		if not v9 then
			return
		end

		local v10 = makemesh({
			mesh = vfx.TrailPart,
			transparency = 1,
			cframe = folder.PrimaryPart.CFrame * CFrame.new(-0.035, -1.8, -1.096) * CFrame.Angles(
				0,
				3.141592653589793,
				3.141592653589793
			),
			size = vfx.TrailPart.Size
		})
		thingable(v10, true, "Trail")
		game.Debris:AddItem(v10, 20)
		table.insert(cleanupTable, v10)
		local v11 = makemesh({
			mesh = vfx.Trail1Part,
			transparency = 1,
			cframe = folder.PrimaryPart.CFrame * CFrame.new(-0.035, -1.2, -1.096) * CFrame.Angles(
				0,
				-3.141592653589793,
				-3.141592653589793
			),
			size = vfx.Trail1Part.Size
		})
		thingable(v11, true, "Trail")
		game.Debris:AddItem(v11, 20)
		table.insert(cleanupTable, v11)
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		v3 = colorCorrectionEffect

		if folder == game.Players.LocalPlayer.Character then
			colorCorrectionEffect.Parent = game.Lighting
		end

		game.Debris:AddItem(colorCorrectionEffect, 15)
		local tween2 = TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.717), {
			Brightness = 0,
			Contrast = 0,
			Saturation = 0,
			TintColor = Color3.fromRGB(222, 189, 255)
		})
		tween2:Play()
		v5 = tween2
		task.spawn(function()
			for _ = 1, 4 do
				local v12

				if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v2 = true
					v12 = false
				else
					v12 = true
				end

				if not v12 then
					break
				end

				for _ = 1, 4 do
					local v13

					if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v2 = true
						v13 = false
					else
						v13 = true
					end

					if not v13 then
						return
					end

					tween(v10, TweenInfo.new(0.083), {
						cframe = v10.CFrame * CFrame.new(0, 3.3, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
					}, nil) -- equivalent call inferred; original call site unknown
					tween(v11, TweenInfo.new(0.083), {
						cframe = v10.CFrame * CFrame.new(0, 3.3, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
					}, nil) -- equivalent call inferred; original call site unknown
					dtwait(0.084)
				end

				tween(v10, TweenInfo.new(0.017), {
					cframe = folder.PrimaryPart.CFrame * CFrame.new(-0.035, -1.8, -1.096) * CFrame.Angles(
						0,
						3.141592653589793,
						3.141592653589793
					)
				}, nil) -- equivalent call inferred; original call site unknown
				tween(v11, TweenInfo.new(0.017), {
					cframe = folder.PrimaryPart.CFrame * CFrame.new(-0.035, -1.2, -1.096) * CFrame.Angles(
						0,
						-3.141592653589793,
						-3.141592653589793
					)
				}, nil) -- equivalent call inferred; original call site unknown
				dtwait(0.018)
			end
		end)
		thingable(camera, true, "Beam")
		local folder2 = quickWeld({
			FX = vfx.ShadowFx,
			Maid = object._maid,
			P = folder.PrimaryPart,
			C0 = CFrame.new(0.024, 3, 0.004)
		})
		able({
			FX = folder2,
			On = true
		})
		game.Debris:AddItem(folder2, 20)
		table.insert(cleanupTable, folder2)
		local pointLight = folder2.P.PointLight
		TweenService:Create(pointLight, TweenInfo.new(0.3), {
			Brightness = 2
		}):Play()
		pointLight.Enabled = true
		local v12 = makemesh({
			mesh = vfx.Beam["1"],
			transparency = 1,
			cframe = folder.PrimaryPart.CFrame * CFrame.new(-0.016, -2.85, 0.021),
			size = vfx.Beam["1"].Size
		})
		local v13 = makemesh({
			mesh = vfx.Beam["2"],
			transparency = 1,
			cframe = folder.PrimaryPart.CFrame * CFrame.new(-0.016, 0.22, 0.021),
			size = vfx.Beam["2"].Size
		})
		local v14 = makemesh({
			mesh = vfx.Beam["3"],
			transparency = 1,
			cframe = folder.PrimaryPart.CFrame * CFrame.new(-0.016, 5.083, 0.021),
			size = vfx.Beam["3"].Size
		})
		local v15 = makemesh({
			mesh = vfx.Beam["4"],
			transparency = 1,
			cframe = folder.PrimaryPart.CFrame * CFrame.new(-0.016, 13.882, 0.021),
			size = vfx.Beam["4"].Size
		})

		if v then
			for _, v17 in pairs({
				v12,
				v13,
				v14,
				v15
			}) do
				v17.Parent = nil
			end
		end

		task.spawn(function()
			local folder3 = makemesh({
				mesh = vfx.Beam.Up,
				transparency = 1,
				cframe = folder.PrimaryPart.CFrame * CFrame.new(-0.034, -2.75, -0.422),
				size = vfx.Beam.Up.Size
			})
			local v17 = makemesh({
				mesh = vfx.Beam.Down,
				transparency = 1,
				cframe = folder.PrimaryPart.CFrame * CFrame.new(-0.034, 30.935, -0.422),
				size = vfx.Beam.Down.Size
			})
			task.spawn(function()
				for _ = 1, 7 do
					local v18

					if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v2 = true
						v18 = false
					else
						v18 = true
					end

					if not v18 then
						return
					end

					TweenService:Create(folder3, TweenInfo.new(0.217), {
						CFrame = folder3.CFrame * CFrame.Angles(0, -1.5707963267948966, 0)
					}):Play()
					TweenService:Create(v17, TweenInfo.new(0.217), {
						CFrame = v17.CFrame * CFrame.Angles(0, -1.5707963267948966, 0)
					}):Play()
					dtwait(0.218)
				end

				dtwait(1.55)
				local v18

				if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v2 = true
					v18 = false
				else
					v18 = true
				end

				if not v18 then
					return
				end

				folder3.Orientation = createVector(0, 0, 0)
				v17.Orientation = createVector(0, 0, 0)

				for _ = 1, 6 do
					TweenService:Create(folder3, TweenInfo.new(0.217), {
						CFrame = folder3.CFrame * CFrame.Angles(0, -1.5707963267948966, 0)
					}):Play()
					TweenService:Create(v17, TweenInfo.new(0.217), {
						CFrame = v17.CFrame * CFrame.Angles(0, -1.5707963267948966, 0)
					}):Play()
					dtwait(0.218)
					local v19

					if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v2 = true
						v19 = false
					else
						v19 = true
					end

					if not v19 then
						break
					end
				end
			end)

			for _, beam in pairs(folder3:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				beam.Enabled = true
				beam.Attachment1 = nil
				beam.Attachment1 = v17:FindFirstChild(string.gsub(tostring(beam.Attachment0), "0", "") .. "1")
				local v18 = beam
				task.spawn(function()
					TweenService:Create(v18, TweenInfo.new(0.5), {
						Width0 = 5,
						Width1 = 15
					}):Play()
					local v19

					if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v2 = true
						v19 = false
					else
						v19 = true
					end

					if not v19 then
						return
					end

					dtwait(1.383)
					local v20

					if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v2 = true
						v20 = false
					else
						v20 = true
					end

					if not v20 then
						return
					end

					TweenService:Create(v18, TweenInfo.new(0.75), {
						TextureSpeed = 0
					}):Play()
					dtwait(1.55)
					local v21

					if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v2 = true
						v21 = false
					else
						v21 = true
					end

					if not v21 then
						return
					end

					TweenService:Create(v18, TweenInfo.new(0.65), {
						TextureSpeed = -6
					}):Play()
					dtwait(1.033)
					local v22

					if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v2 = true
						v22 = false
					else
						v22 = true
					end

					if not v22 then
						return
					end

					TweenService:Create(v18, TweenInfo.new(0.2), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end)
			end

			dtwait(1.18)
			local v18

			if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v2 = true
				v18 = false
			else
				v18 = true
			end

			if not v18 then
				return
			end

			for _, beam in pairs(camera:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				local v19 = beam
				task.spawn(function()
					TweenService:Create(v19, TweenInfo.new(0.784), {
						TextureSpeed = 0
					}):Play()
					dtwait(1.634)
					local v20

					if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v2 = true
						v20 = false
					else
						v20 = true
					end

					if not v20 then
						return
					end

					TweenService:Create(v19, TweenInfo.new(0.183), {
						TextureSpeed = -3
					}):Play()
					dtwait(0.184)
					local v21

					if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v2 = true
						v21 = false
					else
						v21 = true
					end

					if not v21 then
						return
					end

					TweenService:Create(v19, TweenInfo.new(0.4), {
						TextureSpeed = 0
					}):Play()
					dtwait(0.401)
					local v22

					if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v2 = true
						v22 = false
					else
						v22 = true
					end

					if not v22 then
						return
					end

					TweenService:Create(v19, TweenInfo.new(0.217), {
						TextureSpeed = 2
					}):Play()
				end)
			end
		end)
		task.spawn(function()
			thingable(v12, true, "Beam")
			thingable(v13, true, "Beam")
			thingable(v14, true, "Beam")
			thingable(v15, true, "Beam")

			local function tweenbeams(duration, p)
				local v17

				if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v2 = true
					v17 = false
				else
					v17 = true
				end

				if not v17 then
					return
				end

				tween(v12, TweenInfo.new(duration), {
					cframe = v12.CFrame * CFrame.Angles(0, math.rad(p), 0)
				}, nil) -- equivalent call inferred; original call site unknown
				tween(v14, TweenInfo.new(duration), {
					cframe = v14.CFrame * CFrame.Angles(0, math.rad(p), 0)
				}, nil) -- equivalent call inferred; original call site unknown
				tween(v15, TweenInfo.new(duration), {
					cframe = v15.CFrame * CFrame.Angles(0, math.rad(p), 0)
				}, nil) -- equivalent call inferred; original call site unknown
				dtwait(duration + 0.001)
			end

			tweenbeams(0.167, -90)
			local v17

			if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v2 = true
				v17 = false
			else
				v17 = true
			end

			if not v17 then
				return
			end

			task.spawn(function()
				for _ = 1, 15 do
					local v18

					if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v2 = true
						v18 = false
					else
						v18 = true
					end

					if not v18 then
						return
					end

					tween(v13, TweenInfo.new(0.083), {
						cframe = v13.CFrame * CFrame.Angles(0, -1.5707963267948966, 0)
					}, nil) -- equivalent call inferred; original call site unknown
					dtwait(0.083)
				end

				tween(v13, TweenInfo.new(0.333), {
					cframe = v13.CFrame * CFrame.Angles(0, -1.5707963267948966, 0)
				}, nil) -- equivalent call inferred; original call site unknown
				dtwait(0.333)
				local v21

				if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v2 = true
					v21 = false
				else
					v21 = true
				end

				if not v21 then
					return
				end

				tween(v13, TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					cframe = v13.CFrame * CFrame.Angles(0, -0.4363323129985824, 0)
				}, nil) -- equivalent call inferred; original call site unknown
			end)
			local v18

			if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v2 = true
				v18 = false
			else
				v18 = true
			end

			if not v18 then
				return
			end

			tweenbeams(0.2, -90)
			tweenbeams(0.133, -90)
			tweenbeams(0.167, -90)
			tweenbeams(0.166, -90)
			tweenbeams(0.15, -90)
			tweenbeams(0.15, -90)
			dtwait(0.184)
			local v19

			if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v2 = true
				v19 = false
			else
				v19 = true
			end

			if not v19 then
				return
			end

			tweenbeams(0.85, -10)
		end)
		dtwait(0.333)
		local v17

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v17 = false
		else
			v17 = true
		end

		if not v17 then
			return
		end

		thingable(v10, false, "Trail")
		thingable(v11, false, "Trail")
		dtwait(0.017)
		local v18

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v18 = false
		else
			v18 = true
		end

		if not v18 then
			return
		end

		thingable(v10, true, "Trail")
		thingable(v11, true, "Trail")
		dtwait(0.333)
		local v19

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v19 = false
		else
			v19 = true
		end

		if not v19 then
			return
		end

		thingable(v10, false, "Trail")
		thingable(v11, false, "Trail")
		dtwait(0.017)
		local v20

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v20 = false
		else
			v20 = true
		end

		if not v20 then
			return
		end

		thingable(v10, true, "Trail")
		thingable(v11, true, "Trail")
		dtwait(0.333)
		local v21

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v21 = false
		else
			v21 = true
		end

		if not v21 then
			return
		end

		thingable(v10, false, "Trail")
		thingable(v11, false, "Trail")
		dtwait(0.017)
		local v22

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v22 = false
		else
			v22 = true
		end

		if not v22 then
			return
		end

		thingable(v10, true, "Trail")
		thingable(v11, true, "Trail")
		task.delay(0.45, function()
			local v23

			if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v2 = true
				v23 = false
			else
				v23 = true
			end

			if not v23 then
				return
			end

			for _, emitter in pairs(folder2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					TweenService:Create(emitter, TweenInfo.new(0.65), {
						TimeScale = 0
					}):Play()
				end
			end
		end)
		dtwait(0.583)
		local v23

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v23 = false
		else
			v23 = true
		end

		if not v23 then
			return
		end

		local FX = quickWeld({
			FX = vfx.StarFx,
			Maid = object._maid,
			P = folder.PrimaryPart,
			C0 = CFrame.new(0, -1.336, 0.18)
		})
		able({
			FX = FX,
			On = true
		})
		game.Debris:AddItem(FX, 20)
		table.insert(cleanupTable, FX)
		dtwait(1.816)
		local v25

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v25 = false
		else
			v25 = true
		end

		if not v25 then
			return
		end

		for _, emitter in pairs(folder.Torso:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("Made") then
				emitter.Enabled = true
			end
		end

		thingable(folder, true, "Trail")
		FX:Destroy()
		folder2:Destroy()
		TweenService:Create(pointLight, TweenInfo.new(0.05), {
			Brightness = 0
		}):Play()

		for _, folder3 in pairs({
			v12,
			v13,
			v14,
			v15
		}) do
			for _, descendant in pairs(folder3:GetDescendants()) do
				tweensequence({
					childtype = "Beam",
					particle = descendant,
					twtype = "Transparency",
					amount = 46,
					newvalues = { 0, 0.023, 0 }
				}) -- equivalent call inferred; original call site unknown
			end
		end

		local pointLight2 = folder.Torso.P.PointLight
		TweenService:Create(pointLight2, TweenInfo.new(1.716), {
			Brightness = 15
		}):Play()
		pointLight2.Enabled = true
		dtwait(0.05)
		local v26

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v26 = false
		else
			v26 = true
		end

		if not v26 then
			return
		end

		local FX2 = quickWeld({
			FX = vfx.FloorFx,
			Maid = object._maid,
			P = folder.PrimaryPart,
			C0 = CFrame.new(0, 3, 0)
		})
		able({
			FX = FX2,
			On = true
		})
		game.Debris:AddItem(FX2, 20)
		table.insert(cleanupTable, FX2)
		local clone = vfx.Beam.TornadoBeams:Clone()
		game.Debris:AddItem(clone, 20)
		table.insert(cleanupTable, clone)
		clone.Parent = thrown

		if v then
			clone.Parent = nil
		end

		object._maid:give(clone)
		clone:SetPrimaryPartCFrame(folder.PrimaryPart.CFrame * CFrame.new(0.328, 20.629, 0))
		thingable(clone, true, "Beam")
		task.delay(0.033, function()
			local v28

			if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v2 = true
				v28 = false
			else
				v28 = true
			end

			if not v28 then
				return
			end

			local v29 = quickWeld({
				FX = vfx.Mesh.Floor,
				Maid = object._maid,
				P = folder.PrimaryPart,
				C0 = CFrame.new(0.102, 2.8, -0)
			})
			v29.Transparency = 0
			game.Debris:AddItem(v29, 20)
			table.insert(cleanupTable, v29)
			tween(v29, TweenInfo.new(0.117), {
				transparency1 = 1
			}, 3.035) -- equivalent call inferred; original call site unknown

			if v then
				v29.Parent = nil
			end

			local v32 = makemesh({
				mesh = vfx.Mesh.Ball,
				transparency = 0,
				cframe = folder.PrimaryPart.CFrame * CFrame.new(0.102, 0.167, 0),
				size = createVector(116.526, 116.526, 116.526)
			})

			if v then
				v32.Parent = nil
			end

			tween(v32, TweenInfo.new(0.134), {
				transparency1 = 1
			}, 3.3) -- equivalent call inferred; original call site unknown
			game.Debris:AddItem(v32, 20)
			table.insert(cleanupTable, v32)
			tween(v32, TweenInfo.new(3.034, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				size = createVector(135, 135, 135)
			}, nil) -- equivalent call inferred; original call site unknown
			tween(v32, TweenInfo.new(0.783, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				size = createVector(8, 8, 8)
			}, 2.935) -- equivalent call inferred; original call site unknown
			tween(v32, TweenInfo.new(0.783, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				cframe = v32.CFrame * CFrame.new(0, 20.4, 0)
			}, 2.935) -- equivalent call inferred; original call site unknown
			dtwait(0.3)
			local v41

			if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v2 = true
				v41 = false
			else
				v41 = true
			end

			if not v41 then
				return
			end

			local v42 = makemesh({
				mesh = vfx.Trail2Part,
				transparency = 1,
				cframe = folder.PrimaryPart.CFrame * CFrame.new(0, -1.155, 0) * CFrame.Angles(0, 0, 3.141592653589793),
				size = vfx.Trail2Part.Size
			})
			thingable(v42, true, "Trail")
			local v43 = makemesh({
				mesh = vfx.Trail3Part,
				transparency = 1,
				cframe = folder.PrimaryPart.CFrame * CFrame.new(0, -2, 0) * CFrame.Angles(0, 0, -3.141592653589793),
				size = vfx.Trail3Part.Size
			})
			thingable(v43, true, "Trail")
			local v44 = makemesh({
				mesh = vfx.Trail4Part,
				transparency = 1,
				cframe = folder.PrimaryPart.CFrame * CFrame.new(0, -4, -0) * CFrame.Angles(0, 0, -3.141592653589793),
				size = vfx.Trail4Part.Size
			})
			thingable(v44, true, "Trail")

			for _ = 1, 11 do
				local v45

				if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v2 = true
					v45 = false
				else
					v45 = true
				end

				if not v45 then
					return
				end

				tween(v42, TweenInfo.new(0.18), {
					cframe = v42.CFrame * CFrame.new(0, -0.82, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
				}, nil) -- equivalent call inferred; original call site unknown
				tween(v43, TweenInfo.new(0.18), {
					cframe = v43.CFrame * CFrame.new(0, -1.19, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
				}, nil) -- equivalent call inferred; original call site unknown
				tween(v44, TweenInfo.new(0.18), {
					cframe = v44.CFrame * CFrame.new(0, -0.9, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
				}, nil) -- equivalent call inferred; original call site unknown
				dtwait(0.181)
			end

			tween(v42, TweenInfo.new(0.25), {
				cframe = v42.CFrame * CFrame.new(0, -5, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
			}, nil) -- equivalent call inferred; original call site unknown
			tween(v43, TweenInfo.new(0.25), {
				cframe = v43.CFrame * CFrame.new(0, -4.3, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
			}, nil) -- equivalent call inferred; original call site unknown
			tween(v44, TweenInfo.new(0.25), {
				cframe = v44.CFrame * CFrame.new(0, -4.1, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
			}, nil) -- equivalent call inferred; original call site unknown
			dtwait(0.251)
			local v51

			if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v2 = true
				v51 = false
			else
				v51 = true
			end

			if not v51 then
				return
			end

			tween(v42, TweenInfo.new(0.25), {
				cframe = v42.CFrame * CFrame.new(0, -3.2, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
			}, nil) -- equivalent call inferred; original call site unknown
			tween(v43, TweenInfo.new(0.25), {
				cframe = v43.CFrame * CFrame.new(0, -3.2, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
			}, nil) -- equivalent call inferred; original call site unknown
			tween(v44, TweenInfo.new(0.25), {
				cframe = v44.CFrame * CFrame.new(0, -3.5, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
			}, nil) -- equivalent call inferred; original call site unknown
		end)
		local v28 = makemesh({
			mesh = vfx.Mesh.WindMesh1,
			transparency = 1,
			cframe = folder.PrimaryPart.CFrame * CFrame.new(-0, 23.489, 0) * CFrame.Angles(0, 0, -3.141592653589793),
			size = createVector(59.197, 49.054, 61.662)
		})
		local v29 = makemesh({
			mesh = vfx.Mesh.WindMesh2,
			transparency = 1,
			cframe = folder.PrimaryPart.CFrame * CFrame.new(-0, 17.75, 0) * CFrame.Angles(
				0,
				-3.141592653589793,
				3.141592653589793
			),
			size = createVector(59.197, 40.099, 61.662)
		})
		task.spawn(function()
			local v30

			if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v2 = true
				v30 = false
			else
				v30 = true
			end

			if not v30 then
				return
			end

			tween(v28, TweenInfo.new(0.5), {
				transparency1 = 0
			}, nil) -- equivalent call inferred; original call site unknown
			tween(v29, TweenInfo.new(0.5), {
				transparency1 = 0
			}, nil) -- equivalent call inferred; original call site unknown
			tween(v28, TweenInfo.new(3.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				transparency1 = 1
			}, 0.51) -- equivalent call inferred; original call site unknown
			tween(v29, TweenInfo.new(3.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				transparency1 = 1
			}, 0.51) -- equivalent call inferred; original call site unknown

			local function tweenmeshes(duration, p)
				local v43

				if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v2 = true
					v43 = false
				else
					v43 = true
				end

				if not v43 then
					return
				end

				tween(v28, TweenInfo.new(duration), {
					cframe = v28.CFrame * CFrame.Angles(0, math.rad(p), 0)
				}, nil) -- equivalent call inferred; original call site unknown
				tween(v29, TweenInfo.new(duration), {
					cframe = v29.CFrame * CFrame.Angles(0, math.rad(p), 0)
				}, nil) -- equivalent call inferred; original call site unknown
				dtwait(duration + 0.001)
			end

			tweenmeshes(0.663, -90)
			tweenmeshes(0.734, -90)
			tweenmeshes(0.667, -90)
			tweenmeshes(0.267, -90)
		end)
		local v30

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v30 = false
		else
			v30 = true
		end

		if not v30 then
			return
		end

		dtwait(3.01)
		local v31

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v31 = false
		else
			v31 = true
		end

		if not v31 then
			return
		end

		able({
			FX = FX2,
			On = false
		})
		thingable(clone, false, "Beam")
		thingable(camera, false, "Beam")
		local FX3 = quickWeld({
			FX = vfx.BallFx,
			Maid = object._maid,
			P = folder.PrimaryPart,
			C0 = CFrame.new(0, -17.714, 1.043)
		})
		able({
			FX = FX3,
			On = true
		})
		game.Debris:AddItem(FX3, 20)
		table.insert(cleanupTable, FX3)
		TweenService:Create(pointLight2, TweenInfo.new(0.047), {
			Brightness = 0
		}):Play()
		task.spawn(function()
			TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.267), {
				Brightness = 0,
				Contrast = 0,
				Saturation = 0,
				TintColor = Color3.fromRGB(255, 255, 255)
			}):Play()
			local v33

			if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v2 = true
				v33 = false
			else
				v33 = true
			end

			if not v33 then
				return
			end

			dtwait(1.632)
			local v34

			if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v2 = true
				v34 = false
			else
				v34 = true
			end

			if not v34 then
				return
			end

			changecc(colorCorrectionEffect, {
				b = -3,
				c = 15,
				s = -1,
				tc = Color3.fromRGB(255, 255, 255),
				w = 0.034
			}) -- equivalent call inferred; original call site unknown
			changecc(colorCorrectionEffect, {
				b = -3,
				c = -25,
				s = -1,
				tc = Color3.fromRGB(255, 255, 255),
				w = 0.034
			}) -- equivalent call inferred; original call site unknown
			changecc(colorCorrectionEffect, {
				b = -15,
				c = -125,
				s = -1,
				tc = Color3.fromRGB(255, 255, 255),
				w = 0.034
			}) -- equivalent call inferred; original call site unknown
			changecc(colorCorrectionEffect, {
				b = 0,
				c = 0,
				s = 0,
				tc = Color3.fromRGB(255, 255, 255),
				w = 0.034
			}) -- equivalent call inferred; original call site unknown
		end)
		dtwait(1.15)
		local v33

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v33 = false
		else
			v33 = true
		end

		if not v33 then
			return
		end

		for _, emitter in pairs(folder.Torso:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("Made") then
				emitter.Enabled = true
			end
		end

		thingable(folder, true, "Beam")
		local v34

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v34 = false
		else
			v34 = true
		end

		if not v34 then
			return
		end

		dtwait(0.017)
		local v35

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v35 = false
		else
			v35 = true
		end

		if not v35 then
			return
		end

		for _, emitter in pairs(folder.Torso:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("Made") then
				emitter.Enabled = false
			end
		end

		dtwait(0.25)
		local v36

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v36 = false
		else
			v36 = true
		end

		if not v36 then
			return
		end

		able({
			FX = FX3,
			On = false
		})
		dtwait(0.2)
		local v37

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v37 = false
		else
			v37 = true
		end

		if not v37 then
			return
		end

		playAttachment(FX3)
		dtwait(1.7)
		local v38

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v38 = false
		else
			v38 = true
		end

		if not v38 then
			return
		end

		local v39 = quickWeld({
			FX = vfx.Step1Fx,
			Maid = object._maid,
			P = folder.PrimaryPart,
			C0 = CFrame.new(0, 2.9, 0)
		})
		playAttachment(v39)
		game.Debris:AddItem(v39, 20)
		table.insert(cleanupTable, v39)
		dtwait(0.616)
		local v40

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v40 = false
		else
			v40 = true
		end

		if not v40 then
			return
		end

		thingable(folder, false, "Beam")
	end

	task.spawn(FirstEvent)
end

return ShadowEruption
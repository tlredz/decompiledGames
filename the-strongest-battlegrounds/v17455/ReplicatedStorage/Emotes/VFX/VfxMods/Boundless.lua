local createVector = vector.create
local Boundless = {}
local library = require(game.ReplicatedStorage.library)
local playAttachment = library.PlayAttachment
local maid = library.Maid
local playTween = library.PlayTween
local _ = library.CamShake
local _ = library.PlayFlipBook
local dtwait = library.dtwait
local EFP = library.EFP
local playMesh = library.PlayMesh
local _ = library.Impact
local _ = library.GlassLight
local _ = library.RaiseZIndex
local able = library.Able
local lifeScale = library.LifeScale
local quickFX = library.QuickFX
local quickWeld = library.QuickWeld
local _ = library.Yield
local _ = library.ProcessPart
local _ = library.WeldObject
local _ = library.Bezier
local vfx = script.vfx
local class = {}
class.__index = class
local random = Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera

function Boundless.FirstEvent(data)
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
	local humanoidRootPart = char.HumanoidRootPart
	local v = char ~= game.Players.LocalPlayer.Character

	local function GetTorsoCF()
		local _, v2, _ = char.HumanoidRootPart.CFrame:ToOrientation()
		return CFrame.new(char.Torso.Position) * CFrame.Angles(0, v2, 0)
	end

	local v2 = false
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local parentChangedConnection = nil
	local v3 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v3 then
			v3 = true

			if parentChangedConnection then
				parentChangedConnection:Disconnect()
			end

			object._maid:doCleaning()
		end
	end

	local _ = { "Ragdoll" }
	local lastTime = tick()
	local thread = task.delay(6, function()
		for _, v4 in pairs(cleanupTable) do
			if typeof(v4) == "thread" then
				continue
			end

			local v5 = tostring(v4)
			local v6 = nil

			for _, descendant in pairs(script:GetDescendants()) do
				if tostring(descendant) ~= v5 then
					continue
				end

				v6 = descendant
				break
			end

			if v6 then
				v4:SetAttribute("DelayDeletion", 2)
			end
		end
	end)
	table.insert(cleanupTable, thread)
	parentChangedConnection = bind:GetPropertyChangedSignal("Parent"):Connect(function()
		if bind and bind.Parent then
			return
		end

		v2 = true

		if tick() - lastTime >= 8.65 then
			return parentChangedConnection:Disconnect()
		end

		if thread then
			task.cancel(thread)
		end

		Clean() -- equivalent call inferred; original call site unknown
		return parentChangedConnection:Disconnect()
	end)
	task.delay(10, function()
		if parentChangedConnection then
			return parentChangedConnection:Disconnect()
		end
	end)
	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local v4

	if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
		v2 = true
		v4 = false
	else
		v4 = true
	end

	if not v4 then
		return
	end

	local impact = script.Impact
	object.Impact = object._maid:give(impact:Clone())
	object.Impact.Enabled = true
	object.Impact.Parent = game.Players.LocalPlayer.PlayerGui
	table.insert(cleanupTable, object.Impact)

	for _, image in pairs(object.Impact:GetDescendants()) do
		if not image:IsA("ImageLabel") then
			continue
		end

		image.Size = UDim2.new(0, 1, 0, 1)
		image.Visible = true
		image.Position = UDim2.new(0, 0, 0, 0)
		image.ImageTransparency = 0
	end

	local function ImpactFrames()
		local v5

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v5 = false
		else
			v5 = true
		end

		if not (v5 and char == game.Players.LocalPlayer.Character) then
			return
		end

		local v6 = nil
		local v7 = 1
		local frames = object.Impact:WaitForChild("Frames")
		local v8 = nil
		v8 = shared.loop(function()
			local child = frames:FindFirstChild((tostring(v7)))

			if child then
				local flag

				if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v2 = true
					flag = false
				else
					flag = true
				end

				if flag then
					v7 += 1
					child.Size = UDim2.new(1, 0, 1, 0)

					if v6 then
						v6:Destroy()
					end

					v6 = child
					return
				end
			end

			if frames and frames.Parent then
				frames:Destroy()
			end

			if v6 and v6.Parent then
				v6:Destroy()
			end

			return v8()
		end, 34)
		task.delay(5, function()
			if v8 then
				return v8()
			end
		end)
	end

	local function FirstEvent()
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

		local v6 = 11

		if char == game.Players.LocalPlayer.Character then
			shared.sfx({
				SoundId = "rbxassetid://134034110275182",
				Parent = workspace,
				AddTo = cleanupTable,
				TimePosition = realAnim.TimePosition,
				Volume = 5,
				RollOffMaxDistance = 80
			}):Resume()
			shared.sfx({
				SoundId = "rbxassetid://108374874178302",
				Parent = workspace,
				AddTo = cleanupTable,
				TimePosition = realAnim.TimePosition,
				Volume = 2.5,
				RollOffMaxDistance = 80
			}):Resume()
		else
			shared.sfx({
				SoundId = "rbxassetid://87109430723077",
				Parent = char.Torso,
				AddTo = cleanupTable,
				TimePosition = realAnim.TimePosition + 0.25,
				Volume = 10,
				RollOffMaxDistance = 80
			}):Resume()
			v6 = 0
		end

		local FX = quickFX({
			FX = vfx.Rocks,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, v6)
		})
		FX:ScaleTo(0.5)
		table.insert(cleanupTable, FX)
		able({
			FX = FX,
			On = true
		})
		local v8

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v8 = false
		else
			v8 = true
		end

		if not v8 then
			return
		end

		dtwait(0.5)
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

		local FX2 = quickFX({
			FX = vfx.Aura,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0),
			Maid = object._maid
		})

		if v then
			able({
				FX = FX2,
				On = true
			})
		end

		table.insert(cleanupTable, FX2)
		task.wait(0.25)
		local v11

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v11 = false
		else
			v11 = true
		end

		if not v11 then
			return
		end

		local thread2 = task.delay(0.8, function()
			local v12

			if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v2 = true
				v12 = false
			else
				v12 = true
			end

			if not v12 then
				return
			end

			local v13 = quickWeld({
				FX = vfx.Head2,
				Maid = object._maid,
				P = char.Head
			})
			playAttachment(v13)
			table.insert(cleanupTable, v13)
		end)
		table.insert(cleanupTable, thread2)
		local v12 = object._maid:give(Instance.new("ColorCorrectionEffect"))
		game.Debris:AddItem(v12, 5)
		table.insert(cleanupTable, v12)

		if char == game.Players.LocalPlayer.Character then
			v12.Parent = game.Lighting
			TweenService:Create(v12, TweenInfo.new(0.5, Enum.EasingStyle.Elastic), {
				Brightness = 0.1,
				Saturation = -1,
				Contrast = 1
			}):Play()
		end

		local thread3 = task.delay(0.4, function()
			local v13

			if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v2 = true
				v13 = false
			else
				v13 = true
			end

			if v13 and not v then
				ImpactFrames(script.Impact)
			end
		end)
		table.insert(cleanupTable, thread3)
		dtwait(0.8)
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

		able({
			FX = FX,
			On = false
		})
		TweenService:Create(v12, TweenInfo.new(1, Enum.EasingStyle.Elastic), {
			Brightness = -0.156,
			Saturation = 0.781,
			Contrast = 0.625
		}):Play()
		local thread4 = task.delay(0.15, function()
			dtwait(0.4)
			local v14

			if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v2 = true
				v14 = false
			else
				v14 = true
			end

			if not v14 then
				return
			end

			local FX3 = quickWeld({
				FX = vfx.StandWind,
				Maid = object._maid,
				P = humanoidRootPart,
				C0 = CFrame.new(0, humanoidRootPart.Size.Y * 1, 0)
			})
			table.insert(cleanupTable, FX3)
			able({
				FX = FX3,
				On = true
			})
			dtwait(1)
			local v16

			if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v2 = true
				v16 = false
			else
				v16 = true
			end

			if not v16 then
				return
			end

			able({
				FX = FX3,
				On = false
			})
		end)
		table.insert(cleanupTable, thread4)
		local v14

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v14 = false
		else
			v14 = true
		end

		if not v14 then
			return
		end

		local highlight = Instance.new("Highlight")
		table.insert(cleanupTable, highlight)
		highlight.FillColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 1
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.Parent = char
		game.Debris:AddItem(highlight, 3)
		TweenService:Create(highlight, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
			FillTransparency = 0
		}):Play()
		lifeScale({
			FX = FX2,
			Scale = 0.5
		})
		local v15 = object._maid:give(Instance.new("NumberValue"))
		object._maid:giveTask(v15.Changed:Connect(function()
			local v16

			if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v2 = true
				v16 = false
			else
				v16 = true
			end

			if not v16 then
				return
			end

			FX2:ScaleTo(v15.Value)
		end))
		v15.Value = FX2:GetScale()
		TweenService:Create(v15, TweenInfo.new(2, Enum.EasingStyle.Sine), {
			Value = 3
		}):Play()
		table.insert(cleanupTable, v15)
		local _ = vfx.Pillar.Size.Y
		local v16 = object._maid:give(vfx.Pillar:Clone())
		v16.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
		v16.Size = Vector3.new(v16.Size.X, 0.01, v16.Size.Z)
		local _ = char == game.Players.LocalPlayer.Character
		v16.Parent = EFP
		table.insert(cleanupTable, v16)
		local v17 = nil
		local v18 = nil
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

		if not v then
			local Y = vfx.Pillar.Size.Y
			local v20 = object._maid:give(vfx.Pillar:Clone())
			v20.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
			v20.Size = Vector3.new(v20.Size.X, 0.01, v20.Size.Z)
			v20.Parent = EFP
			table.insert(cleanupTable, v20)
			task.spawn(function()
				local lastTime2 = tick()

				while tick() - lastTime2 < 4 do
					dtwait(0.01)
					local v21

					if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v2 = true
						v21 = false
					else
						v21 = true
					end

					if not v21 then
						break
					end

					if v20.Parent then
						for _, texture in pairs(v20:GetChildren()) do
							if not texture:IsA("Texture") then
								continue
							end

							texture.OffsetStudsU += 5
							texture.OffsetStudsV += 5
						end
					end

					if v17 and v17.Parent then
						for _, texture in pairs(v17:GetChildren()) do
							if not texture:IsA("Texture") then
								continue
							end

							texture.OffsetStudsU += 1
							texture.OffsetStudsV += 1
						end
					end

					if v18 and v18.Parent then
						for _, texture in pairs(v18:GetChildren()) do
							if not texture:IsA("Texture") then
								continue
							end

							texture.OffsetStudsU += 1
							texture.OffsetStudsV += 1
						end
					end

					if v20 and v20.Parent then
						v20.CFrame *= CFrame.Angles(0, -0.03490658503988659, 0)
					else
						break
					end
				end
			end)
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

			local size = v20.Size
			v20.Size = createVector(0, 0, 0)
			TweenService:Create(v20, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				Size = size + Vector3.new(0, Y, 0),
				CFrame = v20.CFrame * CFrame.new(0, Y / 2, 0)
			}):Play()
			task.delay(0.5, function()
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

				TweenService:Create(v12, TweenInfo.new(1, Enum.EasingStyle.Elastic), {
					Brightness = 0,
					Saturation = 0,
					Contrast = 0
				}):Play()
				dtwait(0.6)

				if not (realAnim and realAnim.IsPlaying) then
					return v20:Destroy()
				end

				for _, child in pairs(v20:GetChildren()) do
					TweenService:Create(child, TweenInfo.new(2, Enum.EasingStyle.Sine), {
						Transparency = 1
					}):Play()
				end

				TweenService:Create(v20, TweenInfo.new(1, Enum.EasingStyle.Sine), {
					Size = Vector3.new(0, Y, 0)
				}):Play()
				game.Debris:AddItem(v20, 1)
				dtwait(0.5)
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

				local v24 = quickFX({
					FX = vfx.Lightning,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
				})
				table.insert(cleanupTable, v24)
				playAttachment(v24)

				for _ = 1, 5 do
					local v25

					if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v2 = true
						v25 = false
					else
						v25 = true
					end

					if not v25 then
						break
					end

					dtwait(0.1)
					playAttachment(v24)
				end
			end)
		end

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

		local FX4 = quickFX({
			FX = vfx.Floor,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
		})
		able({
			FX = FX4,
			On = true
		})
		table.insert(cleanupTable, FX4)
		local v22 = {}

		if not v then
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Built }

			for _ = 1, 16.5 do
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

				local cFrame = humanoidRootPart.CFrame
				local raycastResult = game.Workspace:Raycast(cFrame.Position, createVector(0, -50, 0), raycastParams)

				if not raycastResult then
					continue
				end

				local parent = object._maid:give(Instance.new("Part"))
				table.insert(cleanupTable, parent)
				parent.Material = raycastResult.Instance.Material
				parent.Color = raycastResult.Instance.Color
				parent.CanCollide = false
				parent.Anchored = true
				parent.CFrame = cFrame * CFrame.new(random:NextNumber(-50, 50), 0, random:NextNumber(-50, 50)) * CFrame.Angles(
					math.rad((math.random(0, 360))),
					math.rad((math.random(0, 360))),
					(math.rad((math.random(0, 360))))
				)
				parent.Position = Vector3.new(
					parent.Position.X,
					raycastResult.Position.Y - math.max(parent.Size.X, parent.Size.Y, parent.Size.Z),
					parent.Position.Z
				)
				local number = random:NextNumber(0.7, 1)
				parent.Size = Vector3.new(2 + math.random(), 2 + math.random(), 2 + math.random())
				parent.Size *= number
				parent.Parent = EFP
				vfx.RockAura:ScaleTo(number)

				for _, child in pairs(vfx.RockAura.RockAura:GetChildren()) do
					local clone = child:Clone()
					table.insert(cleanupTable, clone)
					clone.Parent = parent
					clone.Enabled = true
					object._maid:give(clone)
				end

				game.Debris:AddItem(parent, 2.5)
				local pointLight = Instance.new("PointLight")
				table.insert(cleanupTable, pointLight)
				pointLight.Parent = parent
				pointLight.Brightness = 8
				pointLight.Color = Color3.new(0.54902, 0.32549, 1)
				pointLight.Range = 10
				table.insert(v22, parent)
				TweenService:Create(parent, TweenInfo.new(random:NextNumber(3, 4), Enum.EasingStyle.Exponential), {
					CFrame = CFrame.new(parent.Position + Vector3.new(0, random:NextNumber(10, 35), 0)) * CFrame.Angles(
						math.rad((math.random(0, 360))),
						math.rad((math.random(0, 360))),
						(math.rad((math.random(0, 360))))
					)
				}):Play()
			end
		end

		local folder = quickFX({
			FX = vfx.BeamBack,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 40, 0) * CFrame.Angles(0, 0, 1.5707963267948966)
		})
		folder:ScaleTo(5)
		table.insert(cleanupTable, folder)

		for _, beam in pairs(folder:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			beam.TextureSpeed *= 2
			beam.Brightness += 5
		end

		local starts = {}
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

		if not v then
			v18 = object._maid:give(vfx.RoomFloor:Clone())
			table.insert(cleanupTable, v18)
			v18.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.6, 0) * CFrame.Angles(
				0,
				0,
				1.5707963267948966
			)
			v18.Size *= 3

			if char == game.Players.LocalPlayer.Character then
				v18.Parent = EFP
			end

			game.Debris:AddItem(v18, 5)
			TweenService:Create(v18, TweenInfo.new(2, Enum.EasingStyle.Sine), {
				Size = v18.Size * 3
			}):Play()
		end

		task.delay(1.6, function()
			local v24

			if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v2 = true
				v24 = false
			else
				v24 = true
			end

			if not v24 then
				return
			end

			if not v then
				v17 = object._maid:give(vfx.RoomReal:Clone())
				v17.CFrame = humanoidRootPart.CFrame
				table.insert(cleanupTable, v17)

				if char == game.Players.LocalPlayer.Character then
					v17.Parent = EFP
				end

				game.Debris:AddItem(v17, 5)
				TweenService:Create(v17, TweenInfo.new(2, Enum.EasingStyle.Sine), {
					Size = v17.Size * 2
				}):Play()
			end

			dtwait(0.2)
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

			if not v then
				for _, texture in pairs(v17:GetChildren()) do
					if texture:IsA("Texture") then
						TweenService:Create(texture, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
							Transparency = 1
						}):Play()
					end
				end

				TweenService:Create(v17, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
					Transparency = 1
				}):Play()

				for _, texture in pairs(v18:GetChildren()) do
					if texture:IsA("Texture") then
						TweenService:Create(texture, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
							Transparency = 1
						}):Play()
					end
				end

				TweenService:Create(v18, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
					Transparency = 1
				}):Play()
			end

			task.spawn(function()
				local lastTime2 = tick()
				local count = 0

				while tick() - lastTime2 < 0.5 do
					count += 1
					local v26

					if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v2 = true
						v26 = false
					else
						v26 = true
					end

					if not v26 then
						break
					end

					local clone = vfx.UpTime:Clone()
					table.insert(cleanupTable, clone)
					clone:ScaleTo(random:NextNumber(1, 1.3) + count * 0.05)
					local number = random:NextNumber(0.4, 0.7)
					playMesh({
						Model = clone,
						Anchor = humanoidRootPart.CFrame * CFrame.new(0, 53 * clone:GetScale(), 0) * CFrame.Angles(
							0,
							math.rad((math.random(0, 360))),
							1.5707963267948966
						),
						Info = TweenInfo.new(number, Enum.EasingStyle.Quad)
					})
					table.insert(starts, clone.Start)

					for _, v27 in pairs(starts) do
						for _, texture in pairs(v27:GetChildren()) do
							if not texture:IsA("Texture") then
								continue
							end

							texture.OffsetStudsU += 2
							texture.OffsetStudsV += 2
						end
					end

					dtwait(0.05)
				end
			end)
			dtwait(0.1)
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

			dtwait(0.2)
			lifeScale({
				FX = quickFX({
					FX = vfx.Up,
					Anchor = humanoidRootPart.CFrame * CFrame.new(0, 2, 0),
					Maid = object._maid
				}),
				Scale = 3
			})
		end)
		task.delay(0.8, function()
			local v24

			if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v2 = true
				v24 = false
			else
				v24 = true
			end

			if not v24 then
				return
			end

			local FX3 = quickFX({
				FX = vfx.Scribble,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
			})
			able({
				FX = FX3,
				On = true
			})
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

			dtwait(1.5)
			local v27

			if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v2 = true
				v27 = false
			else
				v27 = true
			end

			if not v27 then
				return
			end

			able({
				FX = FX3,
				On = false
			})
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

			dtwait(0.7)
			local v29

			if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v2 = true
				v29 = false
			else
				v29 = true
			end

			if not v29 then
				return
			end

			for _, effect in pairs(folder:GetDescendants()) do
				if effect:IsA("ParticleEmitter") then
					effect.Enabled = false
				elseif effect:IsA("Beam") then
					playTween(effect, {
						Time = 0.15,
						EasingStyle = "Sine",
						Goal = {
							Width0 = 0,
							Width1 = 0
						}
					})
					game.Debris:AddItem(effect, 0.15)
				end
			end
		end)
		dtwait(2)
		local v24

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v24 = false
		else
			v24 = true
		end

		if not v24 then
			return
		end

		able({
			FX = FX4,
			On = false
		})
		TweenService:Create(highlight, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			FillTransparency = 1
		}):Play()

		if not v then
			for _, v25 in pairs(v22) do
				table.insert(cleanupTable, v25)

				for _, child in pairs(v25:GetChildren()) do
					child.Enabled = false
				end

				local number = random:NextNumber(0.3, 0.7)
				TweenService:Create(v25, TweenInfo.new(number, Enum.EasingStyle.Sine), {
					Size = createVector(0, 0, 0)
				}):Play()
				game.Debris:AddItem(v25, number)
			end
		end

		local v25 = {}

		if not v then
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Built }

			for _ = 1, 25 do
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

				local v27 = humanoidRootPart.CFrame * CFrame.new(0, 0, 10)
				local raycastResult = game.Workspace:Raycast(v27.Position, createVector(0, -50, 0), raycastParams)

				if not raycastResult then
					continue
				end

				local part = Instance.new("Part")
				local Debris = game:GetService("Debris")
				Debris:AddItem(part, 5)
				table.insert(cleanupTable, part)
				part.Material = raycastResult.Instance.Material
				part.Color = raycastResult.Instance.Color
				part.CanCollide = false
				part.Anchored = true
				part.CFrame = v27 * CFrame.new(random:NextNumber(-10, 10), 0, random:NextNumber(-10, 10)) * CFrame.Angles(
					math.rad((math.random(0, 360))),
					math.rad((math.random(0, 360))),
					(math.rad((math.random(0, 360))))
				)
				part.Position = Vector3.new(
					part.Position.X,
					raycastResult.Position.Y - math.max(part.Size.X, part.Size.Y, part.Size.Z),
					part.Position.Z
				)
				local number = random:NextNumber(0.2, 0.4)
				part.Size = Vector3.new(2 + math.random(), 2 + math.random(), 2 + math.random())
				part.Size *= number
				part.Parent = EFP
				vfx.RockAura:ScaleTo(number)

				for _, child in pairs(vfx.RockAura.RockAura:GetChildren()) do
					local clone = child:Clone()
					clone.Parent = part
					clone.Enabled = true
				end

				table.insert(v25, part)
				TweenService:Create(part, TweenInfo.new(random:NextNumber(3, 4), Enum.EasingStyle.Exponential), {
					CFrame = CFrame.new(part.Position + Vector3.new(0, random:NextNumber(10, 35), 0)) * CFrame.Angles(
						math.rad((math.random(0, 360))),
						math.rad((math.random(0, 360))),
						(math.rad((math.random(0, 360))))
					)
				}):Play()
			end
		end

		dtwait(0.4)
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

		local v27 = quickFX({
			FX = vfx.explosion,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
		})
		table.insert(cleanupTable, v27)
		v27:ScaleTo(1.5)
		playAttachment(v27)
		local callback = data.Callback
		task.delay(2, function()
			for _, v28 in pairs(v22) do
				for _, emitter in pairs(v28:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				TweenService:Create(v28, TweenInfo.new(0, Enum.EasingStyle.Exponential), {
					CFrame = v28.CFrame
				}):Play()
				v28.Anchored = false
			end
		end)

		if callback then
			local _ = callback[1]
		end

		able({
			FX = FX2,
			On = false
		})
		lifeScale({
			FX = FX2,
			Scale = 3
		})
		dtwait(0.3)
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

		dtwait(1)
		local v29

		if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v2 = true
			v29 = false
		else
			v29 = true
		end

		if not v29 then
			return
		end

		if not v then
			for _, v30 in pairs(v25) do
				for _, child in pairs(v30:GetChildren()) do
					child.Enabled = false
				end

				local number = random:NextNumber(0.3, 0.7)
				TweenService:Create(v30, TweenInfo.new(number, Enum.EasingStyle.Sine), {
					Size = createVector(0, 0, 0)
				}):Play()
				game.Debris:AddItem(v30, number)
			end
		end
	end

	local function Outside()
		dtwait(1.7)
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

		local FX = quickFX({
			FX = vfx.explosion,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
		})
		table.insert(cleanupTable, FX)
		lifeScale({
			FX = FX,
			Scale = 3
		})
		FX:ScaleTo(2)
		playAttachment(FX)
		local starts = {}
		local lastTime2 = tick()
		local count = 0
		local cFrame = humanoidRootPart.CFrame

		local function Rocks()
			local v7 = {}

			for _ = 1, 20 do
				local v8

				if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v2 = true
					v8 = false
				else
					v8 = true
				end

				if not v8 then
					return
				end

				if not shared.OnScreen(humanoidRootPart.Position) then
					continue
				end

				local dist = object._maid:give(Instance.new("NumberValue"))
				local height = object._maid:give(Instance.new("NumberValue"))
				local spin = object._maid:give(Instance.new("NumberValue"))
				local number = random:NextNumber(0, 360)
				local part = Instance.new("Part")
				table.insert(cleanupTable, part)
				local random2 = Random.new()
				part.Size = Vector3.new(
					random2:NextNumber(5, 6.75),
					random2:NextNumber(1.25, 1.8),
					random2:NextNumber(6.75, 7.75)
				)
				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
				local number2 = random:NextNumber(0.7, 1.4)
				part.CFrame = cFrame
				part.Material = Enum.Material.Concrete
				local number3 = random:NextNumber(1.2, 2)
				local size = part.Size * number3
				part.Size = createVector(0, 0, 0)
				v7[part] = {
					Dist = dist,
					Height = height,
					StartRot = CFrame.Angles(math.random(0, 360), math.random(0, 360), math.random(0, 360)),
					Spin = spin,
					Rot = number,
					Size = size,
					amplitude = random:NextNumber(0.7, 1.3),
					frequency = random:NextNumber(0.5, 1.5),
					RotScale = number2
				}
				dist.Value = random:NextNumber(3, 6)
				part.Parent = EFP
				TweenService:Create(part, TweenInfo.new(random:NextNumber(0.1, 0.2), Enum.EasingStyle.Sine), {
					Size = size * 0.9
				}):Play()
				TweenService:Create(spin, TweenInfo.new(1, Enum.EasingStyle.Sine), {
					Value = random:NextNumber(0.03, 0.05)
				}):Play()
				TweenService:Create(dist, TweenInfo.new(0.05, Enum.EasingStyle.Sine), {
					Value = random:NextNumber(10, 35)
				}):Play()
				height.Value = random:NextNumber(-20, -10)
				TweenService:Create(height, TweenInfo.new(random:NextNumber(0.2, 0.4), Enum.EasingStyle.Quad), {
					Value = random:NextNumber(2, 38)
				}):Play()
				task.delay(0.8, function()
					local v15

					if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v2 = true
						v15 = false
					else
						v15 = true
					end

					if not v15 then
						return
					end

					TweenService:Create(spin, TweenInfo.new(2, Enum.EasingStyle.Sine), {
						Value = random:NextNumber(0.1, 0.2)
					}):Play()
					TweenService:Create(dist, TweenInfo.new(3, Enum.EasingStyle.Sine), {
						Value = random:NextNumber(30, 70)
					}):Play()
				end)
				local clone = vfx.RockAura:Clone()
				table.insert(cleanupTable, clone)
				clone:ScaleTo(clone:GetScale() * number3 * 3)

				for _, emitter in pairs(clone.RockAura:GetChildren()) do
					emitter.Parent = part

					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end

					object._maid:give(emitter)
				end

				clone:Destroy()
				local v15

				if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v2 = true
					v15 = false
				else
					v15 = true
				end

				if not v15 then
					return
				end
			end

			local lastTime3 = tick()
			local total = 0

			while v7 and tick() - lastTime3 < 4 do
				local v8

				if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v2 = true
					v8 = false
				else
					v8 = true
				end

				if not v8 then
					break
				end

				if shared.OnScreen(humanoidRootPart.Position) then
					for folder, v9 in pairs(v7) do
						total += v9.Spin.Value
						folder.CFrame = cFrame * CFrame.Angles(0, -math.rad((total + v9.Rot) * v9.RotScale), 0) * CFrame.new(
							0,
							v9.Height.Value,
							v9.Dist.Value
						) * v9.StartRot * CFrame.Angles(math.rad(total), 0, 0)

						if tick() - lastTime3 > 2.6 and not v9.Finished then
							v7[folder].Finished = true
							TweenService:Create(
								folder,
								TweenInfo.new(random:NextNumber(0.1, 0.2), Enum.EasingStyle.Sine),
								{
									Size = createVector(0, 0, 0)
								}
							):Play()

							for _, effect in pairs(folder:GetDescendants()) do
								if effect:IsA("ParticleEmitter") then
									effect.Enabled = false
								elseif effect:IsA("Trail") then
									playTween(effect, {
										Time = 0.3,
										EasingStyle = "Sine",
										Goal = {
											Transparency = NumberSequence.new({
												NumberSequenceKeypoint.new(0, 1),
												NumberSequenceKeypoint.new(1, 1)
											})
										}
									})
								end
							end
						elseif tick() - lastTime3 < 2.6 and tick() - lastTime3 > 2 then
							folder.Size = v9.Size * (v9.amplitude * math.sin(6.283185307179586 * v9.frequency * tick()))
							local v10 = math.max(folder.Size.X, folder.Size.Y, folder.Size.Z)

							if v10 < 2 and not v7[folder].Off then
								v7[folder].Off = true

								for _, effect in pairs(folder:GetDescendants()) do
									if effect:IsA("ParticleEmitter") then
										effect.Enabled = false
									elseif effect:IsA("Trail") then
										playTween(effect, {
											Time = 0.3,
											EasingStyle = "Sine",
											Goal = {
												Transparency = NumberSequence.new({
													NumberSequenceKeypoint.new(0, 1),
													NumberSequenceKeypoint.new(1, 1)
												})
											}
										})
									end
								end
							elseif v10 > 2 and v7[folder].Off then
								for _, effect in pairs(folder:GetDescendants()) do
									if effect:IsA("ParticleEmitter") then
										effect.Enabled = false
									elseif effect:IsA("Trail") then
										playTween(effect, {
											Time = 0.3,
											EasingStyle = "Sine",
											Goal = {
												Transparency = NumberSequence.new({
													NumberSequenceKeypoint.new(0, 1),
													NumberSequenceKeypoint.new(1, 1)
												})
											}
										})
									end
								end
							end
						end
					end
				end

				local RunService = game:GetService("RunService")
				RunService.Heartbeat:Wait()
			end
		end

		task.spawn(Rocks)
		local FX2 = nil
		task.delay(0.5, function()
			local v8

			if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v2 = true
				v8 = false
			else
				v8 = true
			end

			if not v8 then
				return
			end

			FX2 = quickFX({
				FX = vfx.Scribble,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
			})
			table.insert(cleanupTable, FX2)
			able({
				FX = FX2,
				On = true
			})
			lifeScale({
				FX = FX2,
				Scale = 0.7
			})
			dtwait(1.5)
			able({
				FX = FX2,
				On = false
			})
		end)
		task.spawn(function()
			while tick() - lastTime2 < 2.5 do
				count += 1
				local v8

				if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v2 = true
					v8 = false
				else
					v8 = true
				end

				if not v8 then
					return
				end

				if shared.OnScreen(humanoidRootPart.Position) then
					if tick() - lastTime2 < 1.7 then
						local clone = vfx.UpTime4:Clone()
						clone:ScaleTo(random:NextNumber(1, 1.3) * 0.1 + count * 0.02)
						local v9 = random:NextNumber(0.1, 0.3) + count * 0.015
						playMesh({
							Model = clone,
							Anchor = humanoidRootPart.CFrame * CFrame.new(0, 23 * clone:GetScale(), 0) * CFrame.Angles(
								0,
								math.rad((math.random(0, 360))),
								1.5707963267948966
							),
							Info = TweenInfo.new(v9, Enum.EasingStyle.Quad)
						})
						table.insert(starts, clone.Start)
						task.delay(v9 / 2, function()
							for i, child in pairs(clone.Start:GetChildren()) do
								TweenService:Create(child, TweenInfo.new(v9 / 2, Enum.EasingStyle.Sine), {
									Transparency = 1
								}):Play()
							end
						end)

						if FX2 then
							FX2:ScaleTo(random:NextNumber(2, 3.5))
						end
					end

					for _, v9 in pairs(starts) do
						for _, texture in pairs(v9:GetChildren()) do
							if not texture:IsA("Texture") then
								continue
							end

							texture.OffsetStudsU += 1
							texture.OffsetStudsV += 1
						end
					end
				end

				dtwait(0.05)
			end

			local v8

			if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v2 = true
				v8 = false
			else
				v8 = true
			end

			if not v8 then
				return
			end

			local v9 = object._maid:give(vfx.Bubble:Clone())
			table.insert(cleanupTable, v9)
			v9:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0))

			for _, child in pairs(v9:GetChildren()) do
				child.Size *= 0.1
			end

			v9.Parent = EFP

			for _, child in pairs(v9:GetChildren()) do
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

				TweenService:Create(child, TweenInfo.new(0.05, Enum.EasingStyle.Sine), {
					Size = child.Size * 13
				}):Play()
			end

			task.delay(0.06, function()
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

				for _, child in pairs(v9:GetChildren()) do
					local vector2 = Vector3.new(child.Size.X * 0.01, child.Size.Y * 2, child.Size.Z * 0.01)
					TweenService:Create(child, TweenInfo.new(0.08, Enum.EasingStyle.Sine), {
						Size = vector2
					}):Play()
					game.Debris:AddItem(child, 0.08)
				end
			end)
			local v10

			if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v2 = true
				v10 = false
			else
				v10 = true
			end

			if not (v10 and shared.OnScreen(humanoidRootPart.Position)) then
				return
			end

			local FX3 = quickFX({
				FX = vfx.EndSmoke,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
			})
			table.insert(cleanupTable, FX3)
			FX3:ScaleTo(2)
			lifeScale({
				FX = FX3,
				Scale = 2
			})
			playAttachment(FX3)
		end)
	end

	if v then
		task.spawn(Outside)
	end

	task.spawn(FirstEvent)
	wait(12)
	Clean() -- equivalent call inferred; original call site unknown
end

return Boundless
local createVector = vector.create
local Evolved = {}
local library = require(game.ReplicatedStorage.library)
local playAttachment = library.PlayAttachment
local maid = library.Maid
local _ = library.PlayTween
local _ = library.CamShake
local _ = library.PlayFlipBook
local dtwait = library.dtwait
local EFP = library.EFP
local playMesh = library.PlayMesh
local _ = library.Impact
local _ = library.GlassLight
local raiseZIndex = library.RaiseZIndex
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

function Evolved.FirstEvent(data)
	local char = data.Char
	local _ = char.Humanoid
	local primaryPart = char.PrimaryPart
	shared.NerfVfx({
		Script = script,
		Char = char
	})

	local function GetTorsoCF()
		local _, v, _ = char.HumanoidRootPart.CFrame:ToOrientation()
		return CFrame.new(char.Torso.Position) * CFrame.Angles(0, v, 0)
	end

	local object = setmetatable({}, class)
	object._maid = maid.new()
	local cleanupTable = data.CleanupTable
	local realAnim = data.RealAnim
	local bind = data.Bind
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	local parentChangedConnection = nil
	local v2 = false
	tick()
	parentChangedConnection = bind:GetPropertyChangedSignal("Parent"):Connect(function()
		if bind and bind.Parent then
			return
		end

		v2 = true
		workspace.Camera:SetAttribute("paused", false)
		Clean() -- equivalent call inferred; original call site unknown
		return parentChangedConnection:Disconnect()
	end)
	task.delay(15, function()
		if parentChangedConnection then
			return parentChangedConnection:Disconnect()
		end
	end)
	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	spawn(function()
		if not workspace:GetAttribute("ez") then
			workspace:SetAttribute("ez", true)
			local v3 = {}

			for _, moduleScript in pairs(vfx:GetDescendants()) do
				if not moduleScript:IsA("ModuleScript") then
					continue
				end

				local module = require(moduleScript)

				for _, v4 in pairs(module) do
					table.insert(v3, v4)
				end
			end

			local part = Instance.new("Part")
			part.Name = "DecalPart"
			part.Anchored = true
			part.Transparency = 0.5
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.CFrame = char.PrimaryPart.CFrame * CFrame.new(0, -8, 0)
			part.Parent = char
			game.Debris:AddItem(part, 15)

			for _, texture in pairs(v3) do
				local decal = Instance.new("Decal")
				decal.Parent = part
				decal.Texture = texture
				task.wait(0.0065)
			end
		end
	end)
	local clone = vfx.Cubes:Clone()
	table.insert(cleanupTable, clone)
	clone.Parent = workspace.Thrown
	game.Debris:AddItem(clone, 10)
	table.insert(cleanupTable, clone)
	clone.AnimationController:LoadAnimation(script.Cubes):Play()
	local weld = Instance.new("Weld")
	weld.Part0 = primaryPart
	weld.Part1 = clone.PrimaryPart
	weld.Parent = clone
	weld.C0 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)

	local function FirstEvent()
		local v3 = quickFX({
			FX = vfx.GroundSmoke,
			Maid = object._maid,
			Anchor = primaryPart.CFrame * CFrame.new(0, -primaryPart.Size.Y * 1.5, 0)
		})
		table.insert(cleanupTable, v3)
		playAttachment(v3)
		dtwait(0.5)
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

		task.delay(0.3, function()
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

			local v6 = quickFX({
				FX = vfx.DarkSphere,
				Maid = object._maid,
				Anchor = primaryPart.CFrame * CFrame.new(0, -primaryPart.Size.Y * 1.5, 0)
			})
			table.insert(cleanupTable, v6)
			TweenService:Create(v6, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
				Transparency = 1
			}):Play()
			local v7 = quickFX({
				FX = vfx.justSmoke2,
				Maid = object._maid,
				Anchor = primaryPart.CFrame * CFrame.new(0, -primaryPart.Size.Y * 1.5, 0)
			})
			table.insert(cleanupTable, v7)
			playAttachment(v7)
			local v8 = object._maid:give(Instance.new("Highlight"))
			table.insert(cleanupTable, v8)
			v8.OutlineTransparency = 1
			v8.DepthMode = Enum.HighlightDepthMode.Occluded
			v8.FillTransparency = 0
			v8.FillColor = Color3.new(1, 1, 1)
			v8.Parent = char
			TweenService:Create(v8, TweenInfo.new(0.7, Enum.EasingStyle.Sine), {
				FillTransparency = 1
			}):Play()
			game.Debris:AddItem(v8, 1)
			local v9 = quickFX({
				FX = vfx.Crack,
				Anchor = primaryPart.CFrame * CFrame.new(0, -primaryPart.Size.Y * 1.52, 0),
				Maid = object._maid
			})
			table.insert(cleanupTable, v9)
			v9:ScaleTo(0.25)

			for _, child in pairs(v9:GetChildren()) do
				local decal = child:FindFirstChild("Decal")
				table.insert(cleanupTable, decal)

				if not decal then
					continue
				end

				decal.Transparency = 0
				TweenService:Create(decal, TweenInfo.new(2, Enum.EasingStyle.Sine), {
					Color3 = Color3.fromRGB(0, 0, 0)
				}):Play()
			end

			dtwait(3)
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
				local decal = child:FindFirstChild("Decal")

				if decal then
					TweenService:Create(decal, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
						Transparency = 1
					}):Play()
				end
			end
		end)
	end

	task.spawn(FirstEvent)
	local parent = nil
	local v4 = {
		[1.9] = function()
			task.delay(0.1, function()
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
					FX = vfx.uhm,
					Maid = object._maid,
					Anchor = primaryPart.CFrame * CFrame.new(0, -primaryPart.Size.Y * 1.4, 0) * CFrame.Angles(0, 0, 0)
				})
				table.insert(cleanupTable, FX)
				lifeScale({
					FX = FX,
					Scale = 2
				})
				playAttachment(FX)
				local FX2 = quickFX({
					FX = vfx.SmokePlumeV2,
					Maid = object._maid,
					Anchor = primaryPart.CFrame * CFrame.new(0, -primaryPart.Size.Y * 1.4, 0) * CFrame.Angles(0, 0, 0)
				})
				table.insert(cleanupTable, FX2)
				FX2:ScaleTo(0.4)
				lifeScale({
					FX = FX2,
					Scale = 0.5
				})
				playAttachment(FX2)
			end)
			dtwait(0.2)
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

			playMesh({
				Model = vfx.Wind:Clone(),
				Anchor = primaryPart.CFrame * CFrame.new(0, -1.9, 0),
				Info = TweenInfo.new(1.8, Enum.EasingStyle.Quint)
			})
			local clone2 = vfx.Wind:Clone()
			table.insert(cleanupTable, clone2)
			clone2.Start.Transparency = 0
			clone2:ScaleTo(1.4)
			playMesh({
				Model = clone2,
				Anchor = primaryPart.CFrame * CFrame.new(0, -1.9, 0),
				Info = TweenInfo.new(0.5, Enum.EasingStyle.Quint)
			})
			local clone3 = vfx.Hmm2:Clone()
			table.insert(cleanupTable, clone3)
			clone3.Start.Transparency = 0
			clone3:ScaleTo(1.4)
			playMesh({
				Model = clone3,
				T = 0.9,
				Anchor = primaryPart.CFrame * CFrame.new(0, -primaryPart.Size.Y * 1.5, 0) * CFrame.Angles(
					0,
					1.5707963267948966,
					0
				),
				Info = TweenInfo.new(3.5, Enum.EasingStyle.Sine)
			})
		end,
		[3.1] = function()
			local primaryParts = {}

			for _, child in pairs(clone.Parts:GetChildren()) do
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

				child.Transparency = 1
				local FX = quickWeld({
					FX = vfx.MUIBall,
					Maid = object._maid,
					P = child
				})
				table.insert(cleanupTable, FX)
				TweenService:Create(FX.PrimaryPart, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {
					Size = createVector(1.5, 1.5, 1.5)
				}):Play()
				raiseZIndex({
					FX = FX,
					Count = 2
				})
				game.Debris:AddItem(FX, 3)
				table.insert(primaryParts, FX.PrimaryPart)
			end

			local FX2 = quickFX({
				FX = vfx.YesPls2,
				Maid = object._maid,
				Anchor = char.Torso.CFrame
			})
			table.insert(cleanupTable, FX2)
			FX2:ScaleTo(0.7)
			lifeScale({
				FX = FX2,
				Scale = 0.6
			})
			playAttachment(FX2)
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

			dtwait(0.95)
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

			local FX3 = quickFX({
				FX = vfx.YesPls,
				Maid = object._maid,
				Anchor = primaryParts[1].CFrame
			})
			table.insert(cleanupTable, FX3)
			FX3:ScaleTo(0.7)
			lifeScale({
				FX = FX3,
				Scale = 0.6
			})
			playAttachment(FX3)

			for _, v9 in pairs(primaryParts) do
				v9.Size = createVector(2.5, 2.5, 2.5)
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

			dtwait(0.5)
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

			for _, v11 in pairs(primaryParts) do
				v11:Destroy()
			end
		end,
		[4.38] = function()
			local FX = quickFX({
				FX = vfx.ExplosionNew,
				Maid = object._maid,
				Anchor = primaryPart.CFrame * CFrame.new(0, -primaryPart.Size.Y * 1.45, 0)
			})
			table.insert(cleanupTable, FX)
			FX:ScaleTo(1.5)
			lifeScale({
				FX = FX,
				Scale = 0.2
			})
			playAttachment(FX)
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

			task.delay(0.1, function()
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

				for _ = 1, 23 do
					local v8 = object._maid:give(vfx.Ball:Clone())
					table.insert(cleanupTable, v8)
					local cFrame = primaryPart.CFrame * CFrame.new(
						math.random(-25, 25),
						math.random(0, 15),
						math.random(-25, 25)
					)
					v8.CFrame = char.Torso.CFrame
					v8.Parent = EFP
					local v10 = random:NextNumber(0.4, 0.8) * 0.9
					TweenService:Create(v8, TweenInfo.new(v10 * 1.2, Enum.EasingStyle.Quad), {
						Size = v8.Size * random:NextNumber(1.1, 1.5),
						CFrame = cFrame
					}):Play()
					task.delay(v10 * 1.2, function()
						TweenService:Create(v8, TweenInfo.new(v10, Enum.EasingStyle.Back), {
							CFrame = char.Torso.CFrame
						}):Play()
						dtwait(v10 * 0.6)
						v8:Destroy()
					end)
					game.Debris:AddItem(v8, 2)
				end
			end)
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

			local clone2 = vfx.UpTime2:Clone()
			table.insert(cleanupTable, clone2)
			clone2.Start.Transparency = 0
			clone2:ScaleTo(1.4)
			playMesh({
				Model = clone2,
				T = 0,
				EndT = 0,
				Anchor = primaryPart.CFrame * CFrame.new(0, 72, 0) * CFrame.Angles(0, 0, 1.5707963267948966),
				Info = TweenInfo.new(0.5, Enum.EasingStyle.Sine)
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

			local clone3 = vfx.ForwardWave4:Clone()
			table.insert(cleanupTable, clone3)
			clone3.Start.Transparency = 0
			clone3:ScaleTo(1.4)
			playMesh({
				Model = clone3,
				T = 0,
				EndT = 0,
				Anchor = primaryPart.CFrame * CFrame.new(0, -primaryPart.Size.Y * 1.5, 0) * CFrame.Angles(
					0,
					0,
					1.5707963267948966
				),
				Info = TweenInfo.new(0.1, Enum.EasingStyle.Sine)
			})
			local v9 = quickFX({
				FX = vfx.BigAura,
				Maid = object._maid,
				Anchor = primaryPart.CFrame * CFrame.new(0, -primaryPart.Size.Y * 1.3, 0)
			})
			table.insert(cleanupTable, v9)
			v9:ScaleTo(0.9)
			playAttachment(v9)
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

			local v11 = object._maid:give(Instance.new("Highlight"))
			table.insert(cleanupTable, v11)
			v11.OutlineTransparency = 1
			v11.DepthMode = Enum.HighlightDepthMode.Occluded
			v11.FillTransparency = 0
			v11.FillColor = Color3.new(1, 1, 1)
			v11.Parent = char
			TweenService:Create(v11, TweenInfo.new(1.7, Enum.EasingStyle.Sine), {
				FillTransparency = 1
			}):Play()
			game.Debris:AddItem(v11, 4)
		end,
		[5.23] = function()
			task.spawn(function()
				if char ~= game.Players.LocalPlayer.Character then
					return
				end

				for _ = 1, 6 do
					local v5

					if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v2 = true
						v5 = false
					else
						v5 = true
					end

					if not v5 then
						break
					end

					local v6 = object._maid:give(vfx.Spoop:Clone())
					table.insert(cleanupTable, v6)
					v6:ScaleTo(1.6)
					v6.Start.Decal.Transparency = 1
					v6:PivotTo(game.Workspace.CurrentCamera.CFrame * CFrame.new(2.5, 0, -20) * CFrame.Angles(
						-0.7853981633974483,
						3.141592653589793,
						-1.5707963267948966
					))
					v6.Parent = EFP
					TweenService:Create(v6.Start.Decal, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
						Transparency = 0.2
					}):Play()
					task.delay(0.15, function()
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

						TweenService:Create(v6.Start.Decal, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
							Transparency = 1
						}):Play()
					end)
					TweenService:Create(v6.Start, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
						CFrame = v6.End.CFrame
					}):Play()
					TweenService:Create(v6.Start.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
						Scale = v6.End.Mesh.Scale
					}):Play()
					dtwait(0.3)
				end
			end)
			local v5 = object._maid:give(Instance.new("NumberValue"))
			table.insert(cleanupTable, v5)
			v5.Value = 2
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

			task.spawn(function()
				for _ = 1, 4 do
					local v7

					if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v2 = true
						v7 = false
					else
						v7 = true
					end

					if not v7 then
						break
					end

					local model = object._maid:give(vfx.Old.MainWave:Clone())
					table.insert(cleanupTable, model)
					model:ScaleTo(0.6 * v5.Value)
					playMesh({
						Model = model,
						T = 0,
						EndT = 0,
						Anchor = primaryPart.CFrame * CFrame.new(0, -primaryPart.Size.Y * 1.5, 0) * CFrame.Angles(
							3.141592653589793,
							0,
							0
						),
						Info = TweenInfo.new(random:NextNumber(0.2, 0.21), Enum.EasingStyle.Sine)
					})
					local model2 = object._maid:give(vfx.Old.MainWave2:Clone())
					table.insert(cleanupTable, model2)
					model2:ScaleTo(0.3 * v5.Value)
					playMesh({
						Model = model2,
						T = 0,
						EndT = 1,
						Anchor = primaryPart.CFrame * CFrame.new(0, -primaryPart.Size.Y * 1.5, 0) * CFrame.Angles(
							3.141592653589793,
							0,
							0
						),
						Info = TweenInfo.new(random:NextNumber(0.3, 0.31), Enum.EasingStyle.Sine)
					})
					local model3 = object._maid:give(vfx.Old.MainWave2:Clone())
					table.insert(cleanupTable, model3)
					model3:ScaleTo(0.45 * v5.Value)
					playMesh({
						Model = model3,
						T = 0,
						EndT = 1,
						Anchor = primaryPart.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(3.141592653589793, 0, 0),
						Info = TweenInfo.new(random:NextNumber(0.12, 0.13), Enum.EasingStyle.Sine)
					})
					local model4 = object._maid:give(vfx.Old.SideWave:Clone())
					table.insert(cleanupTable, model4)
					model4:ScaleTo(0.45 * v5.Value)
					playMesh({
						Model = model4,
						T = 0,
						EndT = 1,
						Anchor = primaryPart.CFrame * CFrame.new(0, -primaryPart.Size.Y * 1.5, 0) * CFrame.Angles(
							0,
							math.rad((math.random(0, 360))),
							0
						),
						Info = TweenInfo.new(0.25, Enum.EasingStyle.Sine)
					})
					dtwait(0.1)
				end
			end)
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

			local FX = quickFX({
				FX = vfx.Ground,
				Maid = object._maid,
				Anchor = primaryPart.CFrame * CFrame.new(0, -primaryPart.Size.Y * 1.45, 0)
			})
			table.insert(cleanupTable, FX)
			FX:ScaleTo(5)
			lifeScale({
				FX = FX,
				Scale = 1
			})
			playAttachment(FX)
			task.spawn(function()
				local v9 = quickFX({
					FX = vfx.Blasty,
					Maid = object._maid,
					Anchor = primaryPart.CFrame * CFrame.new(0, -primaryPart.Size.Y * 1.5, 0)
				})
				table.insert(cleanupTable, v9)
				v9:ScaleTo(3)
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

				for _ = 1, 11 do
					local v11

					if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v2 = true
						v11 = false
					else
						v11 = true
					end

					if not v11 then
						break
					end

					playAttachment(v9)
					dtwait(0.1)
				end
			end)
			local FX2 = quickFX({
				FX = vfx.ExplosionNew,
				Maid = object._maid,
				Anchor = primaryPart.CFrame * CFrame.new(0, -primaryPart.Size.Y * 1.45, 0)
			})
			table.insert(cleanupTable, FX2)
			FX2:ScaleTo(2.5)
			lifeScale({
				FX = FX2,
				Scale = 0.5
			})
			playAttachment(FX2)
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

			local v11 = object._maid:give(vfx.Cylinder:Clone())
			table.insert(cleanupTable, v11)
			v11.CFrame = primaryPart.CFrame * CFrame.new(0, -primaryPart.Size.Y * 1.5, 0) * CFrame.Angles(
				0,
				0,
				1.5707963267948966
			)
			v11.Parent = EFP
			game.Debris:AddItem(v11, 4)
			task.spawn(function()
				dtwait(0.2)
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

				local folder = quickFX({
					FX = vfx.Yooo,
					Maid = object._maid,
					Anchor = primaryPart.CFrame * CFrame.new(0, -primaryPart.Size.Y * 1.5, 0)
				})
				table.insert(cleanupTable, folder)
				folder:ScaleTo(1.5)
				task.delay(1, function()
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

					for _, emitter in pairs(folder:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							TweenService:Create(emitter, TweenInfo.new(1, Enum.EasingStyle.Sine), {
								TimeScale = 0.1
							}):Play()
						end
					end

					dtwait(2)
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

					for _, emitter in pairs(folder:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							TweenService:Create(emitter, TweenInfo.new(1, Enum.EasingStyle.Sine), {
								TimeScale = 1
							}):Play()
						end
					end
				end)

				for _, emitter in pairs(folder.PrimaryPart:GetChildren()) do
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

					if emitter:IsA("ParticleEmitter") then
						emitter.ZOffset += -3
					end
				end

				able({
					FX = folder,
					On = true
				})
				dtwait(1)
				able({
					FX = folder,
					On = false
				})
			end)
			TweenService:Create(v11, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
				Size = createVector(100, 10, 10)
			}):Play()
			dtwait(0.35)
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

			local size

			if game.Players.LocalPlayer.Character == char then
				size = createVector(100, 230, 230)
			else
				TweenService:Create(v11, TweenInfo.new(4), {
					Transparency = 1
				}):Play()
				size = createVector(100, 150, 50)
			end

			TweenService:Create(v11, TweenInfo.new(5.1, Enum.EasingStyle.Sine), {
				Size = size
			}):Play()
		end,
		[4.3] = function()
			parent = object._maid:give(vfx.Plane:Clone())
			table.insert(cleanupTable, parent)
			parent.CFrame = primaryPart.CFrame * CFrame.new(0, 1, -1.2) * CFrame.Angles(0, -1.5707963267948966, 0)
			parent.Parent = EFP
			game.Debris:AddItem(parent, 15)
			local GokuFlareFlip2d = require(vfx.Plane.GokuFlareFlip2d)

			for i = 20, #GokuFlareFlip2d, 2 do
				local v5

				if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v2 = true
					v5 = false
				else
					v5 = true
				end

				if not v5 then
					break
				end

				local texture = GokuFlareFlip2d[i]
				local decal = Instance.new("Decal")
				decal.Texture = texture
				decal.Name = i
				decal.Transparency = 0.999
				decal.Color3 = Color3.new(1, 1, 1)
				decal.Parent = parent
			end
		end,
		[7.3] = function()
			task.delay(0, function()
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

				parent.CFrame = primaryPart.CFrame * CFrame.new(0, 1, -1.2) * CFrame.Angles(0, -1.5707963267948966, 0)
				local GokuFlareFlip2d = require(vfx.Plane.GokuFlareFlip2d)
				parent.Decal.Transparency = 0
				local decal = nil
				task.spawn(function()
					for i = 20, #GokuFlareFlip2d, 2 do
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

						local texture = GokuFlareFlip2d[i]

						if texture then
							parent.Decal.Texture = texture
							decal = parent.Decal
							local child = parent:FindFirstChild(i - 2)

							if child then
								local TweenService2 = game:GetService("TweenService")
								TweenService2:Create(child, TweenInfo.new(0.35), {
									Transparency = 1
								}):Play()
								game.Debris:AddItem(child, 0.35)
							end
						end

						dtwait(0.05)
					end

					local TweenService2 = game:GetService("TweenService")
					TweenService2:Create(decal, TweenInfo.new(0.75), {
						Transparency = 1
					}):Play()
					local TweenService3 = game:GetService("TweenService")
					TweenService3:Create(parent, TweenInfo.new(0.75), {
						Transparency = 1
					}):Play()
					game.Debris:AddItem(parent, 10)
				end)
			end)
		end
	}

	for duration, v5 in pairs(v4) do
		local v6 = v5
		table.insert(cleanupTable, (task.delay(duration, function()
			local flag

			if v2 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v2 = true
				flag = false
			else
				flag = true
			end

			if flag then
				return v6()
			end
		end)))
	end
end

return Evolved
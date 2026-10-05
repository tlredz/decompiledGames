local createVector = vector.create
local LastWill = {}
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
local thrown = workspace.Thrown
local class = {}
class.__index = class
Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local camera = game.Workspace.Camera

function LastWill.FirstEvent(data)
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
	local _ = char == game.Players.LocalPlayer.Character

	local function GetTorsoCF()
		local _, v, _ = char.HumanoidRootPart.CFrame:ToOrientation()
		return CFrame.new(char.Torso.Position) * CFrame.Angles(0, v, 0)
	end

	local v = false
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local parentChangedConnection = nil
	local v2 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v2 then
			v2 = true

			if parentChangedConnection then
				parentChangedConnection:Disconnect()
			end

			object._maid:doCleaning()
		end
	end

	local v3 = nil
	local v4 = false
	local v5 = nil
	parentChangedConnection = bind:GetPropertyChangedSignal("Parent"):Connect(function()
		if bind and bind.Parent then
			return
		end

		v = true

		if v3 then
			v3:Destroy("")
		end

		if not (v4 or v2) then
			v2 = true

			if parentChangedConnection then
				parentChangedConnection:Disconnect()
			end

			object._maid:doCleaning()
		end

		if v5 then
			game.Debris:AddItem(v5, 0.5)
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(v5, TweenInfo.new(0.5), {
				Contrast = 0,
				Saturation = 0,
				Brightness = 0,
				TintColor = Color3.fromRGB(255, 255, 255)
			}):Play()
		end

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
	local v6

	if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
		v = true
		v6 = false
	else
		v6 = true
	end

	if not v6 then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function tween(instance, tweenInfo, data2, value)
		task.spawn(function()
			dtwait(value or 0)

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
		local v7

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v7 = false
		else
			v7 = true
		end

		if not v7 then
			return
		end

		local clone = data2.mesh:Clone()
		game.Debris:AddItem(clone, 15)
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

	local function changecc(p, data2)
		p.Brightness = data2.b
		p.Contrast = data2.c
		p.TintColor = data2.tc
		p.Saturation = data2.s
		dtwait(data2.w)
	end

	local function FirstEvent()
		local v7 = {}
		local v8 = {}

		local function parent(child, folder)
			local parent2 = folder[tostring(child)]

			if not parent2 then
				return
			end

			if not v7[folder] then
				v7[folder] = {}
			end

			for _, child2 in pairs(child:GetChildren()) do
				local v10

				if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v = true
					v10 = false
				else
					v10 = true
				end

				if not v10 then
					return
				end

				local clone = child2:Clone()
				game.Debris:AddItem(clone, 15)
				table.insert(cleanupTable, clone)
				clone.Parent = parent2
				table.insert(v7[folder], clone)

				for _, trail in pairs(clone:GetDescendants()) do
					if not trail:IsA("Trail") then
						continue
					end

					table.insert(v7[folder], trail)

					if trail.Attachment0 and trail.Attachment1 then
						v8[trail] = {
							Attachment0 = trail.Attachment0.CFrame,
							Attachment1 = trail.Attachment1.CFrame
						}
					end
				end
			end

			if next(v8) then
				for k, v10 in pairs(v8) do
					local v11

					if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v = true
						v11 = false
					else
						v11 = true
					end

					if not v11 then
						return
					end

					local attachment0 = v10.Attachment0
					local attachment1 = v10.Attachment1

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
		local effects2 = {}
		local targChar = data.targChar
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
		local descendantAddedConnection2 = targChar.DescendantAdded:Connect(function(effect)
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam") then
				if not effect:GetAttribute("Made") then
					return
				end

				table.insert(effects2, effect)
				game.Debris:AddItem(effect, 15)
				table.insert(cleanupTable, effect)
			end
		end)
		table.insert(cleanupTable, descendantAddedConnection2)
		task.delay(5, function()
			for _, connection in pairs({ descendantAddedConnection, descendantAddedConnection2 }) do
				if connection then
					connection:Disconnect()
				end
			end
		end)

		for _, child in pairs(char:GetChildren()) do
			local v9

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v9 = false
			else
				v9 = true
			end

			if not v9 then
				return
			end

			local child2 = script.Char:FindFirstChild((tostring(child)))

			if not child2 then
				continue
			end

			local v10

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v10 = false
			else
				v10 = true
			end

			if not v10 then
				return
			end

			parent(child2, char)
		end

		for _, child in pairs(targChar:GetChildren()) do
			local v9

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v9 = false
			else
				v9 = true
			end

			if not v9 then
				return
			end

			local child2 = script.Victim:FindFirstChild((tostring(child)))

			if child2 then
				parent(child2, targChar)
			end
		end

		local function thingable(folder, enabled, className)
			if folder.Parent == char or folder.Parent == targChar then
				for _, v9 in pairs(folder.Parent == targChar and effects2 or effects) do
					local v10

					if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v = true
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
				for _, descendant in pairs(folder:GetDescendants()) do
					if descendant:IsA(className) then
						descendant.Enabled = enabled
					end
				end
			end
		end

		local v9

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v9 = false
		else
			v9 = true
		end

		if not v9 then
			return
		end

		local clone = script.Ball:Clone()
		game.Debris:AddItem(clone, 15)
		table.insert(cleanupTable, clone)
		clone.Parent = char
		local ball = clone.Ball
		ball.Parent = char["Right Arm"]
		ball.Part0 = char["Right Arm"]
		ball.Part1 = clone
		local folder = char
		local v10 = nil
		local A1 = nil
		local A = nil
		task.delay(2, function()
			local v11

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v11 = false
			else
				v11 = true
			end

			if not v11 then
				return
			end

			local lastTime = tick()

			while true do
				task.wait()

				for _, child in pairs(folder:GetChildren()) do
					if tostring(child) ~= "CamRigWithLetterBox" then
						continue
					end

					v10 = child
					camera = child
					v3 = child
					break
				end

				if not (v10 ~= nil or tick() - lastTime >= 0.1) then
					continue
				end

				if not v10 then
					break
				end

				wait(0.2)

				if not v10 then
					break
				end

				for _, child in pairs(script.Folder.Part:GetChildren()) do
					local clone = child:Clone()
					clone.Parent = v10.camera
				end

				A1 = v10.camera.A1
				A = v10.camera.A
				break
			end
		end)
		local v11

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v11 = false
		else
			v11 = true
		end

		if not v11 then
			return
		end

		local clone2 = script.ScreenGui:Clone()
		game.Debris:AddItem(clone2, 15)
		table.insert(cleanupTable, clone2)
		clone2.Parent = game.StarterGui
		object._maid:give(clone2)
		dtwait(0.167)
		local v12

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v12 = false
		else
			v12 = true
		end

		if not v12 then
			return
		end

		local v13 = quickWeld({
			FX = vfx.StepFx,
			Maid = object._maid,
			P = folder.PrimaryPart,
			C0 = CFrame.new(-0.607, 3, 0.566)
		})
		game.Debris:AddItem(v13, 15)
		table.insert(cleanupTable, v13)
		playAttachment(v13)
		dtwait(0.74)
		local v14

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v14 = false
		else
			v14 = true
		end

		if not v14 then
			return
		end

		local v15 = quickWeld({
			FX = vfx.Step1Fx,
			Maid = object._maid,
			P = folder.PrimaryPart,
			C0 = CFrame.new(0.505, 3, 2.049)
		})
		game.Debris:AddItem(v15, 15)
		table.insert(cleanupTable, v15)
		playAttachment(v15)
		dtwait(0.167)
		local v16

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v16 = false
		else
			v16 = true
		end

		if not v16 then
			return
		end

		local v17 = quickWeld({
			FX = vfx.SlamFx,
			Maid = object._maid,
			P = folder.PrimaryPart,
			C0 = CFrame.new(0.653, 3, -3.881)
		})
		game.Debris:AddItem(v17, 15)
		table.insert(cleanupTable, v17)
		playAttachment(v17)
		dtwait(0.82)
		local v18

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v18 = false
		else
			v18 = true
		end

		if not v18 then
			return
		end

		local v19 = quickWeld({
			FX = vfx.Step2Fx,
			Maid = object._maid,
			P = folder.PrimaryPart,
			C0 = CFrame.new(-0.607, 3, 3.718)
		})
		playAttachment(v19)
		game.Debris:AddItem(v19, 15)
		table.insert(cleanupTable, v19)
		playAttachment(targChar.Head)
		thingable(targChar["Right Arm"], true, "Trail")
		task.delay(0.669, function()
			local v20

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v20 = false
			else
				v20 = true
			end

			if not v20 then
				return
			end

			thingable(targChar["Right Arm"], false, "Trail")
		end)
		dtwait(0.37)
		local v20

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v20 = false
		else
			v20 = true
		end

		if not v20 then
			return
		end

		local v21 = quickWeld({
			FX = vfx.DashFx,
			Maid = object._maid,
			P = folder.PrimaryPart,
			C0 = CFrame.new(0.17, 2.75, -3.233)
		})
		playAttachment(v21)
		game.Debris:AddItem(v21, 15)
		table.insert(cleanupTable, v21)
		local v22

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v22 = false
		else
			v22 = true
		end

		if not v22 then
			return
		end

		task.spawn(function()
			if camera ~= workspace.CurrentCamera then
				camera.camera.B1.ParticleEmitter.Enabled = true
				camera.camera.B.ParticleEmitter.Enabled = true
				TweenService:Create(camera.camera.B1.ParticleEmitter, TweenInfo.new(0.28), {
					TimeScale = 0.1
				}):Play()
				TweenService:Create(camera.camera.B.ParticleEmitter, TweenInfo.new(0.28), {
					TimeScale = 0.1
				}):Play()
				local v23

				if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v = true
					v23 = false
				else
					v23 = true
				end

				if not v23 then
					return
				end

				dtwait(0.58)
				local v24

				if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v = true
					v24 = false
				else
					v24 = true
				end

				if not v24 then
					return
				end

				TweenService:Create(camera.camera.B1.ParticleEmitter, TweenInfo.new(0.41), {
					TimeScale = 1
				}):Play()
				TweenService:Create(camera.camera.B.ParticleEmitter, TweenInfo.new(0.41), {
					TimeScale = 1
				}):Play()
				dtwait(0.366)
				local v25

				if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v = true
					v25 = false
				else
					v25 = true
				end

				if not v25 then
					return
				end

				camera.camera.B1.ParticleEmitter.Enabled = false
				camera.camera.B.ParticleEmitter.Enabled = false
			end
		end)
		dtwait(0.167)
		local v23

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v23 = false
		else
			v23 = true
		end

		if not v23 then
			return
		end

		thingable(folder["Left Leg"], true, "Trail")
		task.delay(0.08, function()
			local v24

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v24 = false
			else
				v24 = true
			end

			if not v24 then
				return
			end

			if camera ~= workspace.CurrentCamera then
				for _, emitter in pairs(camera.camera:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end

			dtwait(0.28)
			local v25

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v25 = false
			else
				v25 = true
			end

			if not v25 then
				return
			end

			for _, descendant in pairs(clone2:GetDescendants()) do
				TweenService:Create(descendant, TweenInfo.new(0.817, Enum.EasingStyle.Linear), {
					ImageTransparency = 0.5
				}):Play()
			end

			dtwait(0.633)
			local v26

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v26 = false
			else
				v26 = true
			end

			if not v26 then
				return
			end

			for _, descendant in pairs(clone2:GetDescendants()) do
				TweenService:Create(descendant, TweenInfo.new(1.149, Enum.EasingStyle.Linear), {
					ImageTransparency = 0
				}):Play()
			end

			dtwait(1.267)
			local v27

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v27 = false
			else
				v27 = true
			end

			if not v27 then
				return
			end

			for _, descendant in pairs(clone2:GetDescendants()) do
				TweenService:Create(descendant, TweenInfo.new(1.182, Enum.EasingStyle.Linear), {
					ImageTransparency = 1
				}):Play()
			end
		end)
		dtwait(1.41)
		local v24

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v24 = false
		else
			v24 = true
		end

		if not v24 then
			return
		end

		local v25 = quickWeld({
			FX = vfx.Hit1Fx,
			Maid = object._maid,
			P = folder.PrimaryPart,
			C0 = CFrame.new(-1.067, 0.6, 4.594)
		})
		playAttachment(v25)
		game.Debris:AddItem(v25, 15)
		table.insert(cleanupTable, v25)
		local FX = quickWeld({
			FX = vfx.LinesFx,
			Maid = object._maid,
			P = folder.PrimaryPart,
			C0 = CFrame.new(1.229, 0.2, 4.017)
		})
		able({
			FX = FX,
			On = true
		})
		game.Debris:AddItem(FX, 15)
		table.insert(cleanupTable, FX)
		local clone3 = vfx.Trail1Part:Clone()
		game.Debris:AddItem(clone3, 15)
		table.insert(cleanupTable, clone3)
		clone3.Parent = thrown
		clone3.CFrame = folder.PrimaryPart.CFrame * CFrame.new(0.068, -3, -4.274) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)
		object._maid:give(clone3)
		thingable(clone3, true, "Trail")
		local parent3 = makemesh({
			mesh = script.Folder1.glass1,
			transparency = 1,
			cframe = folder.PrimaryPart.CFrame * CFrame.new(0, -3, -3.389),
			size = createVector(0.001, 0.001, 0.001)
		})
		game.Debris:AddItem(parent3, 15)
		table.insert(cleanupTable, parent3)
		local highlight = Instance.new("Highlight")
		highlight.Enabled = false
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillTransparency = 0.5
		highlight.FillColor = Color3.fromRGB(255, 0, 0)
		highlight.OutlineTransparency = 0
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.Parent = parent3
		task.spawn(function()
			local v28

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v28 = false
			else
				v28 = true
			end

			if not v28 then
				return
			end

			tween(parent3, TweenInfo.new(0.734, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				size = createVector(45, 45, 45)
			}, nil) -- equivalent call inferred; original call site unknown
			tween(parent3, TweenInfo.new(0.334), {
				transparency1 = 3
			}, nil) -- equivalent call inferred; original call site unknown
			tween(parent3, TweenInfo.new(0.2), {
				transparency1 = 1
			}, 0.335) -- equivalent call inferred; original call site unknown
			dtwait(0.766)
			local v38

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v38 = false
			else
				v38 = true
			end

			if not v38 then
				return
			end

			parent3.Size = createVector(0.001, 0.001, 0.001)
			dtwait(0.09)
			local v39

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v39 = false
			else
				v39 = true
			end

			if not v39 then
				return
			end

			tween(parent3, TweenInfo.new(0.116), {
				transparency1 = 6
			}, nil) -- equivalent call inferred; original call site unknown
			tween(parent3, TweenInfo.new(0.734, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				size = createVector(75, 75, 75)
			}, nil) -- equivalent call inferred; original call site unknown
			tween(parent3, TweenInfo.new(0.416), {
				transparency1 = 1
			}, 0.117) -- equivalent call inferred; original call site unknown
			dtwait(0.74)
			local v49

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v49 = false
			else
				v49 = true
			end

			if not v49 then
				return
			end

			parent3.Size = createVector(0.001, 0.001, 0.001)
		end)
		task.delay(0.37, function()
			local v28

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v28 = false
			else
				v28 = true
			end

			if not v28 then
				return
			end

			if A1 and A then
				A1.ParticleEmitter.Enabled = true
				A.ParticleEmitter.Enabled = true
			end

			dtwait(0.06)
			local v29

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v29 = false
			else
				v29 = true
			end

			if not v29 then
				return
			end

			task.spawn(function()
				for _ = 1, 6 do
					local v30

					if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v = true
						v30 = false
					else
						v30 = true
					end

					if not v30 then
						break
					end

					tween(clone3, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
						cframe = clone3.CFrame * CFrame.Angles(0, 0, -1.5707963267948966) * CFrame.new(0, 0, 4.6)
					}, nil) -- equivalent call inferred; original call site unknown
					dtwait(0.11)
				end
			end)
			dtwait(0.32)
			local v30

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v30 = false
			else
				v30 = true
			end

			if not v30 then
				return
			end

			local v31 = makemesh({
				transparency = 1,
				mesh = vfx.WindSpinMesh,
				size = createVector(6.343, 8.023, 6.561),
				cframe = folder.PrimaryPart.CFrame * CFrame.new(-0, 2.104, -4.054) * CFrame.Angles(
					0,
					-1.5707963267948966,
					3.141592653589793
				)
			})
			game.Debris:AddItem(v31, 15)
			table.insert(cleanupTable, v31)
			tween(v31, TweenInfo.new(0.75), {
				cframe = v31.CFrame * CFrame.new(0, -17, 0) * CFrame.Angles(0, -3.141592653589793, 0),
				size = createVector(27.03, 52.943, 27.96)
			}, nil) -- equivalent call inferred; original call site unknown
			tween(v31, TweenInfo.new(0.05), {
				transparency1 = 0.9
			}, nil) -- equivalent call inferred; original call site unknown
			task.delay(0.08, function()
				local v36

				if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v = true
					v36 = false
				else
					v36 = true
				end

				if not v36 then
					return
				end

				tween(v31, TweenInfo.new(0.516), {
					transparency1 = 1
				}, nil) -- equivalent call inferred; original call site unknown
			end)
			local v36 = makemesh({
				transparency = 1,
				mesh = vfx.WindMesh1,
				size = createVector(5.165, 3.077, 5.38),
				cframe = folder.PrimaryPart.CFrame * CFrame.new(0, 1.527, -4.241) * CFrame.Angles(
					0,
					0,
					3.141592653589793
				)
			})
			tween(v36, TweenInfo.new(0.417), {
				cframe = v31.CFrame * CFrame.new(0, -19, 0) * CFrame.Angles(0, -3.141592653589793, 0),
				size = createVector(14.426, 42.37, 15.027)
			}, nil) -- equivalent call inferred; original call site unknown
			tween(v36, TweenInfo.new(0.05), {
				transparency1 = 0.3
			}, nil) -- equivalent call inferred; original call site unknown
			task.delay(0.08, function()
				local v41

				if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v = true
					v41 = false
				else
					v41 = true
				end

				if not v41 then
					return
				end

				tween(v36, TweenInfo.new(0.183), {
					transparency1 = 1
				}, nil) -- equivalent call inferred; original call site unknown
			end)
		end)
		local v28

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v28 = false
		else
			v28 = true
		end

		if not v28 then
			return
		end

		dtwait(0.787)
		local v29

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v29 = false
		else
			v29 = true
		end

		if not v29 then
			return
		end

		local v30 = quickWeld({
			FX = vfx.SmokeFx,
			Maid = object._maid,
			P = folder.PrimaryPart,
			C0 = CFrame.new(-1, 3, 4.858)
		})
		game.Debris:AddItem(v30, 15)
		table.insert(cleanupTable, v30)
		playAttachment(v30)

		if camera ~= workspace.CurrentCamera then
			for _, emitter in pairs(camera.camera:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end

		local v31

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v31 = false
		else
			v31 = true
		end

		if not v31 then
			return
		end

		dtwait(0.6)
		local v32

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v32 = false
		else
			v32 = true
		end

		if not v32 then
			return
		end

		thingable(clone3, false, "Trail")
		able({
			FX = FX,
			On = false
		})
		local clone4 = vfx.Lines2Fx:Clone()
		game.Debris:AddItem(clone4, 15)
		table.insert(cleanupTable, clone4)
		clone4.Parent = thrown
		clone4.CFrame = folder.PrimaryPart.CFrame * CFrame.new(1.055, 32.797, -4.126) * CFrame.Angles(
			0,
			3.141592653589793,
			3.141592653589793
		)
		object._maid:give(clone4)
		able({
			FX = clone4,
			On = true
		})
		tween(clone4, TweenInfo.new(0.6), {
			cframe = clone4.CFrame * CFrame.new(0, -37, 0)
		}, nil) -- equivalent call inferred; original call site unknown
		task.delay(0.667, function()
			local v35

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v35 = false
			else
				v35 = true
			end

			if not (v35 and camera ~= workspace.CurrentCamera) then
				return
			end

			for _, emitter in pairs(camera.camera:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end
		end)
		local v35

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v35 = false
		else
			v35 = true
		end

		if not v35 then
			return
		end

		dtwait(0.7)
		local v36

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v36 = false
		else
			v36 = true
		end

		if not v36 then
			return
		end

		able({
			FX = clone4,
			On = false
		})

		if A1 and A then
			A1.ParticleEmitter.Enabled = false
			A.ParticleEmitter.Enabled = false
		end

		local pointLight = nil
		task.delay(0.684, function()
			local v37

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v37 = false
			else
				v37 = true
			end

			if not v37 then
				return
			end

			if camera ~= workspace.CurrentCamera then
				pointLight = camera.camera.PointLight
				TweenService:Create(pointLight, TweenInfo.new(0.182), {
					Brightness = 15
				}):Play()
			end

			dtwait(0.02)
			local v38

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v38 = false
			else
				v38 = true
			end

			if not v38 then
				return
			end

			tween(parent3, TweenInfo.new(0.533, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				size = createVector(35, 35, 35)
			}, nil) -- equivalent call inferred; original call site unknown
			tween(parent3, TweenInfo.new(0.183), {
				transparency1 = 15
			}, nil) -- equivalent call inferred; original call site unknown
			tween(parent3, TweenInfo.new(0.216), {
				transparency1 = 1
			}, 0.184) -- equivalent call inferred; original call site unknown
			tween(parent3, TweenInfo.new(0.232), {
				transparency1 = 15
			}, 0.433) -- equivalent call inferred; original call site unknown
			tween(parent3, TweenInfo.new(0.8), {
				size = createVector(0, 0, 0)
			}, 0.633) -- equivalent call inferred; original call site unknown
			local v54

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v54 = false
			else
				v54 = true
			end

			if not v54 then
				return
			end

			dtwait(0.163)
			local v55

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v55 = false
			else
				v55 = true
			end

			if not v55 then
				return
			end

			if pointLight then
				TweenService:Create(pointLight, TweenInfo.new(0.682), {
					Brightness = 5
				}):Play()
			end
		end)
		dtwait(1)
		local v37

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v37 = false
		else
			v37 = true
		end

		if not v37 then
			return
		end

		for _, emitter in pairs(folder.Torso:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("Made") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local clone5 = script.ColorCorrection:Clone()
		game.Debris:AddItem(clone5, 15)
		table.insert(cleanupTable, clone5)
		v5 = clone5

		if folder == game.Players.LocalPlayer.Character or targChar == game.Players.LocalPlayer.Character then
			clone5.Parent = game.Lighting
		end

		local tween2 = TweenService:Create(clone5, TweenInfo.new(0.4), {
			Contrast = 0.1,
			Saturation = 0.4
		})
		tween2:Play()
		dtwait(0.38)
		local v38

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v38 = false
		else
			v38 = true
		end

		if not v38 then
			return
		end

		local FX2 = quickWeld({
			FX = vfx.ChargeFx,
			Maid = object._maid,
			P = folder.PrimaryPart,
			C0 = CFrame.new(-0.395, 3, 3.702)
		})
		able({
			FX = FX2,
			On = true
		})
		game.Debris:AddItem(FX2, 15)
		table.insert(cleanupTable, FX2)
		able({
			FX = folder.Ball,
			On = true
		})

		if A1 and A then
			A1.ParticleEmitter.Enabled = true
			A.ParticleEmitter.Enabled = true
		end

		dtwait(0.8)
		local v40

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v40 = false
		else
			v40 = true
		end

		if not v40 then
			return
		end

		local v41 = quickWeld({
			FX = vfx.BeamBg,
			Maid = object._maid,
			P = folder.PrimaryPart,
			C0 = CFrame.new(-0.192, 2.75, 6.738)
		})
		game.Debris:AddItem(v41, 15)
		table.insert(cleanupTable, v41)
		local v42 = quickWeld({
			FX = vfx.Bg,
			Maid = object._maid,
			P = folder.PrimaryPart,
			C0 = CFrame.new(0.687, 0.4, -8.554) * CFrame.Angles(0, 0.3193952531149623, 0)
		})
		game.Debris:AddItem(v42, 15)
		table.insert(cleanupTable, v42)

		if folder == game.Players.LocalPlayer.Character or targChar == game.Players.LocalPlayer.Character then
			thingable(v41, true, "Beam")
		end

		if A1 and A then
			A1.ParticleEmitter.Enabled = false
			A.ParticleEmitter.Enabled = false
		end

		task.delay(0.41, function()
			local v43

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v43 = false
			else
				v43 = true
			end

			if not v43 then
				return
			end

			for _, emitter in pairs(folder:GetDescendants()) do
				if not (emitter:IsA("ParticleEmitter") and emitter.Name == "Line" and emitter:GetAttribute("Made")) then
					continue
				end

				emitter.Enabled = true
			end
		end)
		task.delay(0.22, function()
			local v43

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v43 = false
			else
				v43 = true
			end

			if not v43 then
				return
			end

			tween2 = TweenService:Create(clone5, TweenInfo.new(0.583), {
				Contrast = 0,
				Saturation = 0
			})
			tween2:Play()
			dtwait(0.264)
			local v44

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v44 = false
			else
				v44 = true
			end

			if not v44 then
				return
			end

			thingable(folder["Right Arm"], true, "Beam")
		end)
		dtwait(0.62)
		local v43

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v43 = false
		else
			v43 = true
		end

		if not v43 then
			return
		end

		able({
			FX = FX2,
			On = false
		})
		able({
			FX = folder.Ball,
			On = false
		})

		if pointLight then
			TweenService:Create(pointLight, TweenInfo.new(0.5), {
				Brightness = 0
			}):Play()
		end

		local v44 = quickWeld({
			FX = vfx.Hit2Fx,
			Maid = object._maid,
			P = folder.PrimaryPart,
			C0 = CFrame.new(-0.509, 0.7, 7.646)
		})
		playAttachment(v44)
		game.Debris:AddItem(v44, 15)
		table.insert(cleanupTable, v44)
		task.delay(0.217, function()
			local v45

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v45 = false
			else
				v45 = true
			end

			if not v45 then
				return
			end

			if camera ~= workspace.CurrentCamera then
				for _, emitter in pairs(camera.camera:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end
		end)
		dtwait(0.6)
		local v45

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v45 = false
		else
			v45 = true
		end

		if not v45 then
			return warn("na")
		end

		if v42 and v41 then
			task.delay(0.135, function()
				if v42 and v42.Parent then
					thingable(v41, false, "Beam")
					v42.Transparency = 1
				end
			end)
		end

		local v46

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v46 = false
		else
			v46 = true
		end

		if not v46 then
			return
		end

		local clone6 = vfx.Trail2Part:Clone()
		game.Debris:AddItem(clone6, 9)
		clone6.Parent = thrown
		clone6.CFrame = folder.PrimaryPart.CFrame * CFrame.new(0.315, 3.477, -14.838)
		object._maid:give(clone6)
		local clone7 = vfx.Trail3Part:Clone()
		clone7.Parent = thrown
		game.Debris:AddItem(clone7, 9)
		clone7.CFrame = folder.PrimaryPart.CFrame * CFrame.new(-0.339, 3.865, -15.527)
		object._maid:give(clone7)
		task.delay(0.083, function()
			local v47

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v47 = false
			else
				v47 = true
			end

			if not v47 then
				return
			end

			task.spawn(function()
				for _ = 1, 6 do
					tween(clone6, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
						cframe = clone6.CFrame * CFrame.Angles(0, 0, -1.5707963267948966) * CFrame.new(0, 0, -8.5)
					}, nil) -- equivalent call inferred; original call site unknown
					dtwait(0.11)
				end
			end)
			local v48 = makemesh({
				transparency = 1,
				mesh = vfx.WindMesh3,
				size = createVector(5.165, 3.077, 5.38),
				cframe = folder.PrimaryPart.CFrame * CFrame.new(0.496, 2.206, -11.802) * CFrame.Angles(
					0,
					1.5707963267948966,
					1.5707963267948966
				)
			})
			game.Debris:AddItem(v48, 9)
			tween(v48, TweenInfo.new(1.699), {
				cframe = v48.CFrame * CFrame.new(0, 9, 0) * CFrame.Angles(0, -3.141592653589793, 0)
			}, nil) -- equivalent call inferred; original call site unknown
			tween(v48, TweenInfo.new(1.634), {
				size = createVector(38.617, 46.319, 40.225)
			}, nil) -- equivalent call inferred; original call site unknown
			tween(v48, TweenInfo.new(0.05), {
				transparency1 = 0
			}, nil) -- equivalent call inferred; original call site unknown
			dtwait(0.05)
			local v55

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v55 = false
			else
				v55 = true
			end

			if not v55 then
				return
			end

			tween(v48, TweenInfo.new(1.516), {
				transparency1 = 1
			}, nil) -- equivalent call inferred; original call site unknown
			local v58 = makemesh({
				transparency = 1,
				mesh = vfx.WindMesh2,
				size = createVector(5.165, 3.077, 5.38),
				cframe = folder.PrimaryPart.CFrame * CFrame.new(0.496, 1.54, -12.783) * CFrame.Angles(
					0,
					1.5707963267948966,
					1.5707963267948966
				)
			})
			game.Debris:AddItem(v58, 9)
			tween(v58, TweenInfo.new(0.417), {
				cframe = v58.CFrame * CFrame.new(0, -45, 0) * CFrame.Angles(0, -3.141592653589793, 0)
			}, nil) -- equivalent call inferred; original call site unknown
			tween(v58, TweenInfo.new(0.05), {
				transparency1 = 0
			}, nil) -- equivalent call inferred; original call site unknown
			tween(v58, TweenInfo.new(0.782), {
				size = createVector(43.322, 68.645, 43.906)
			}, nil) -- equivalent call inferred; original call site unknown
			dtwait(0.05)
			local v65

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v65 = false
			else
				v65 = true
			end

			if not v65 then
				return
			end

			tween(v58, TweenInfo.new(0.932), {
				transparency1 = 0.85
			}, nil) -- equivalent call inferred; original call site unknown
			task.delay(0.775, function()
				tween(v58, TweenInfo.new(1), {
					size = createVector(69.767, 143.601, 69.767)
				}, nil) -- equivalent call inferred; original call site unknown
				local v71

				if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v = true
					v71 = false
				else
					v71 = true
				end

				if not v71 then
					return
				end

				dtwait(0.25)
				local v72

				if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v = true
					v72 = false
				else
					v72 = true
				end

				if not v72 then
					return
				end

				tween(v58, TweenInfo.new(0.75), {
					transparency1 = 1
				}, nil) -- equivalent call inferred; original call site unknown
			end)
			dtwait(0.074)
			local v68

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v68 = false
			else
				v68 = true
			end

			if not v68 then
				return
			end

			task.spawn(function()
				for _ = 1, 5 do
					tween(clone6, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
						cframe = clone6.CFrame * CFrame.Angles(0, 0, -1.5707963267948966) * CFrame.new(0, 0, -10)
					}, nil) -- equivalent call inferred; original call site unknown
					dtwait(0.11)
				end
			end)
		end)
		dtwait(0.16)
		local v47

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v47 = false
		else
			v47 = true
		end

		if not v47 then
			return
		end

		local clone8 = vfx.Smoke1Fx:Clone()
		clone8.Anchored = true
		clone8.CFrame = folder.PrimaryPart.CFrame * CFrame.new(0, -2.7, -3)
		clone8.Transparency = 1
		clone8.Parent = workspace.Thrown
		game.Debris:AddItem(clone8, 9)

		for _, emitter in pairs(clone8:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local v48 = quickWeld({
			FX = vfx.Fx1,
			Maid = object._maid,
			P = folder.PrimaryPart,
			C0 = CFrame.new(-0.383, 0.6, 14.761)
		})
		game.Debris:AddItem(v48, 9)
		playAttachment(v48)
		thingable(clone6, true, "Trail")
		thingable(clone7, true, "Trail")

		for _, emitter in pairs(folder:GetDescendants()) do
			if not (emitter:IsA("ParticleEmitter") and emitter.Name == "Line" and emitter:GetAttribute("Made")) then
				continue
			end

			emitter.Enabled = false
		end

		thingable(folder["Right Arm"], false, "Beam")
		task.spawn(function()
			local v49 = makemesh({
				transparency = 0,
				mesh = vfx.ImpactBallMesh,
				size = createVector(0.001, 0.001, 0.001),
				cframe = folder.PrimaryPart.CFrame * CFrame.new(0.496, -0.4, -7.277)
			})
			game.Debris:AddItem(v49, 9)
			tween(v49, TweenInfo.new(0.1), {
				cframe = v49.CFrame * CFrame.new(0, 0, -14)
			}, nil) -- equivalent call inferred; original call site unknown
			tween(v49, TweenInfo.new(0.05), {
				cframe = v49.CFrame * CFrame.new(0, 0, -35)
			}, 0.11) -- equivalent call inferred; original call site unknown
			tween(v49, TweenInfo.new(0.06), {
				cframe = v49.CFrame * CFrame.new(0, 0, -55)
			}, 0.17) -- equivalent call inferred; original call site unknown
			tween(v49, TweenInfo.new(0.05), {
				cframe = v49.CFrame * CFrame.new(0, 0, -60)
			}, 0.24) -- equivalent call inferred; original call site unknown
			tween(v49, TweenInfo.new(0.066), {
				size = createVector(4.409, 4.409, 19.257)
			}, nil) -- equivalent call inferred; original call site unknown
			tween(v49, TweenInfo.new(0.083), {
				size = createVector(11.96, 11.96, 69.033)
			}, 0.067) -- equivalent call inferred; original call site unknown
			tween(v49, TweenInfo.new(0.063), {
				size = createVector(2.014, 2.014, 112.96)
			}, 0.15) -- equivalent call inferred; original call site unknown
			tween(v49, TweenInfo.new(0.05), {
				transparency1 = 1
			}, 0.2) -- equivalent call inferred; original call site unknown
		end)
		local flag

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			flag = false
		else
			flag = true
		end

		if flag then
			v4 = true
		end

		dtwait(0.42)
		thingable(clone6, false, "Trail")
		thingable(clone7, false, "Trail")
	end

	task.spawn(FirstEvent)
end

return LastWill
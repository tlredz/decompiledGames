local TrueRage = {}
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
require(game.ReplicatedStorage.MeshFlipbooks)
require(game.ReplicatedStorage.VfxUtils)
local vfx = script.vfx
local class = {}
class.__index = class
Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera

local function cloneBeamsAndTrails(child, parent, clones, _)
	local clonesByName = {}

	for _, child2 in ipairs(child:GetChildren()) do
		if child2:IsA("Attachment") then
			local clone = child2:Clone()
			table.insert(clones, clone)
			clone:SetAttribute("canme", true)
			clone.Parent = parent
			clonesByName[child2.Name] = clone
		end

		if not child2:IsA("ParticleEmitter") then
			continue
		end

		local clone = child2:Clone()
		table.insert(clones, clone)
		clone.Parent = parent
	end

	for _, trail in ipairs(child:GetChildren()) do
		if not trail:IsA("Trail") then
			continue
		end

		local clone = trail:Clone()
		table.insert(clones, clone)
		clone.Attachment0 = clonesByName[trail.Attachment0.Name]
		clone.Attachment1 = clonesByName[trail.Attachment1.Name]
		clone.Parent = parent
	end

	for _, attachment in ipairs(parent:GetChildren()) do
		if not (attachment:IsA("Attachment") and attachment:GetAttribute("canme")) then
			continue
		end

		for _, beam in ipairs(attachment:GetChildren()) do
			if not beam:IsA("Beam") then
				continue
			end

			local child2 = child:FindFirstChild(beam.Attachment0.Name)
			local child3 = child:FindFirstChild(beam.Attachment1.Name)

			if not (child2 and child3) then
				continue
			end

			beam.Attachment0 = clonesByName[child2.Name]
			beam.Attachment1 = clonesByName[child3.Name]
		end
	end
end

function TrueRage.FirstEvent(data)
	local FX = nil
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	shared.NerfVfx({
		Script = script,
		Char = char
	})
	warn("fired")
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local cleanupTable = data.CleanupTable
	local realAnim = data.RealAnim
	local bind = data.Bind
	local v2 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v2 then
			v2 = true
			object._maid:doCleaning()
		end
	end

	local function thingable(folder, enabled, className)
		if not (folder and folder.Parent) then
			return
		end

		for _, descendant in pairs(folder:GetDescendants()) do
			if not descendant:IsA(className) or descendant:GetAttribute("Cosmetic") then
				continue
			end

			descendant.Enabled = enabled
		end
	end

	local parentChangedConnection = nil
	local v3 = false
	tick()
	tick()
	local v4 = nil
	local v5 = nil
	local v6 = nil
	local descendants = {}
	local clones = {}
	local clones2 = {}
	local fn
	local v7 = false
	local parentChangedConnection2 = nil
	parentChangedConnection2 = char:GetPropertyChangedSignal("Parent"):Connect(function()
		Clean() -- equivalent call inferred; original call site unknown
		v7 = true

		for _, v8 in pairs(clones) do
			v8:Destroy()
		end

		return parentChangedConnection2:Disconnect()
	end)
	task.delay(12, function()
		local v8

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v8 = false
		else
			v8 = true
		end

		if not v8 then
			return
		end

		(function()
			local outside = script.outside

			for _, v9 in pairs({ outside.Beams, outside.FloorFx }) do
				local clone = v9:Clone()
				clone.Parent = workspace.Thrown
				clone.CFrame = CFrame.new(1000000, 1000000, 1000000)
				table.insert(clones2, clone)
				table.insert(clones, clone)

				if v9 == outside.Beams then
					v4 = clone
				else
					v5 = clone
				end
			end

			local clone = script.outside.FloorFx1:Clone()
			v6 = clone
			clone.Parent = workspace.Thrown
			clone.CFrame = CFrame.new(1000000, 1000000, 1000000)
			table.insert(clones2, clone)
			table.insert(clones, clone)
			able({
				FX = clone,
				On = true
			})
		end)()
		task.wait(1.5)

		for _, v9 in pairs(clones2) do
			v9.CFrame = humanoidRootPart.CFrame * v9:GetAttribute("Offset")
		end

		task.delay(0.1, function()
			if fn then
				fn()
			end
		end)
	end)
	tick()
	parentChangedConnection = bind:GetPropertyChangedSignal("Parent"):Connect(function()
		if bind and bind.Parent then
			return
		end

		thingable(char, false, "Beam")

		if FX and FX.Parent then
			thingable(FX, false, "Beam")
			able({
				FX = FX,
				On = false
			})
		end

		v3 = true
		workspace.Camera:SetAttribute("paused", false)
		Clean() -- equivalent call inferred; original call site unknown
		local lastTime = tick()
		spawn(function()
			while true do
				task.wait()

				if tick() - lastTime >= 0.125 then
					break
				end

				local v8 = nil

				for _, v10 in pairs(char.Humanoid:GetPlayingAnimationTracks()) do
					if v10.Animation.AnimationId ~= "rbxassetid://104862750267967" then
						continue
					end

					v8 = v10
					break
				end

				if v8 ~= nil then
					break
				end
			end

			local v9

			for _, v10 in pairs(char.Humanoid:GetPlayingAnimationTracks()) do
				if v10.Animation.AnimationId ~= "rbxassetid://104862750267967" then
					continue
				end

				v9 = v10
				break
			end

			if v9 then
				local sound = Instance.new("Sound")
				sound.Parent = humanoidRootPart
				sound.SoundId = "rbxassetid://134097780553904"
				sound.TimePosition = 0.1
				sound.Looped = true
				sound.Volume = 1.15
				sound:Play()
				v9.Stopped:Once(function()
					if sound and sound.Parent then
						local v10 = sound
						local TweenService2 = game:GetService("TweenService")
						TweenService2:Create(v10, TweenInfo.new(0.5), {
							Volume = 0
						}):Play()
						game.Debris:AddItem(v10, 0.5)
					end

					if parentChangedConnection2 then
						parentChangedConnection2:Disconnect()
					end

					local v10 = { v5, v4, v6 }

					local function fn2(folder)
						for _, descendant in pairs(folder:GetDescendants()) do
							if not (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("PointLight")) then
								continue
							end

							descendant.Enabled = false
						end
					end

					for _, v11 in pairs(v10) do
						game.Debris:AddItem(v11, 2)
						fn2(v11)
					end

					for _, descendant in pairs(char:GetDescendants()) do
						if not descendant:GetAttribute("TrueAura") then
							continue
						end

						descendant.Enabled = false
						game.Debris:AddItem(descendant, 2)
					end

					for _, v11 in pairs(clones) do
						game.Debris:AddItem(v11, 2)
					end
				end)

				local function fn2(enabled, p)
					for _, descendant in pairs(char:GetDescendants()) do
						if not ((descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("PointLight")) and descendant:GetAttribute("TrueAura")) then
							continue
						end

						descendant.Enabled = enabled

						if p then
							descendant:SetAttribute("TrueAura", false)
						end

						if not table.find(descendants, descendant) then
							table.insert(descendants, descendant)
						end
					end
				end

				fn2(false, true)

				for _, child in pairs(script.TemplateR6:GetChildren()) do
					cloneBeamsAndTrails(child, char[tostring(child)], clones, true)
				end

				for _, child in pairs(script.TemplateR62:GetChildren()) do
					cloneBeamsAndTrails(child, char[tostring(child)], clones, true)
				end

				fn2(true)

				for _, v10 in pairs(clones2) do
					v10.CFrame = humanoidRootPart.CFrame * v10:GetAttribute("Offset")
				end

				if tostring(char) == "YungCrepetics" and game.Players.LocalPlayer.Character ~= char then
					local _ = (game.Players.LocalPlayer.Character.PrimaryPart.Position - humanoidRootPart.Position).Magnitude
					spawn(function()
						while v9.IsPlaying and not v7 do
							if (game.Players.LocalPlayer.Character.PrimaryPart.Position - humanoidRootPart.Position).Magnitude <= 20 then
								shared.addshake(2)
								task.wait(Random.new():NextNumber(0.15, 0.2))
							end

							task.wait()
						end
					end)
				end

				if char == game.Players.LocalPlayer.Character then
					while v9.IsPlaying and not v7 do
						shared.addshake(1)
						task.wait(Random.new():NextNumber(0.15, 0.2))
					end
				end
			else
				for _, v10 in pairs(clones) do
					v10:Destroy()
				end
			end
		end)
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

	-- equivalent calls inferred from this helper; original call sites unknown
	local function spin(clone)
		task.spawn(function()
			for _ = 1, 6 do
				TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
					CFrame = clone.CFrame * CFrame.new(0, 1.1, 0) * CFrame.Angles(0, 2.0943951023931953, 0)
				}):Play()
				local v8

				if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v3 = true
					v8 = false
				else
					v8 = true
				end

				if not v8 then
					break
				end

				dtwait(0.15)
			end
		end)
	end

	local v8 = data.Char == game.Players.LocalPlayer.Character or data.targChar == game.Players.LocalPlayer.Character or nil

	local function FirstEvent()
		local v9

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v9 = false
		else
			v9 = true
		end

		if not v9 then
			return
		end

		if not v8 then
			task.delay(0.2, function()
				local v10

				if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v3 = true
					v10 = false
				else
					v10 = true
				end

				if not v10 then
					return
				end

				for _, child in pairs(script.TemplateR62:GetChildren()) do
					cloneBeamsAndTrails(child, char[tostring(child)], cleanupTable, true)
				end

				for _, descendant in pairs(char:GetDescendants()) do
					if not ((descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("PointLight")) and descendant:GetAttribute("TrueAura")) then
						continue
					end

					descendant.Enabled = true
				end

				local outside = script.outside
				local v11 = nil
				local v12 = nil

				for _, v13 in pairs({ outside.Beams, outside.FloorFx }) do
					local clone = v13:Clone()
					clone.Parent = workspace.Thrown
					clone.CFrame = char.PrimaryPart.CFrame * clone:GetAttribute("Offset")
					table.insert(cleanupTable, clone)
					object._maid:give(clone)

					if v13 == outside.Beams then
						v12 = clone
					else
						v11 = clone
					end
				end

				local v13 = nil
				task.delay(6, function()
					local v14

					if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v3 = true
						v14 = false
					else
						v14 = true
					end

					if not v14 then
						return
					end

					local clone = script.outside.FloorFx1:Clone()
					v13 = clone
					clone.Parent = workspace.Thrown
					clone.CFrame = char.PrimaryPart.CFrame * clone:GetAttribute("Offset")
					table.insert(cleanupTable, clone)
					able({
						FX = clone,
						On = true
					})

					for _, child in pairs(script.TemplateR6:GetChildren()) do
						cloneBeamsAndTrails(child, char[tostring(child)], cleanupTable, true)
					end

					for _, descendant in pairs(char:GetDescendants()) do
						if not ((descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("PointLight")) and descendant:GetAttribute("TrueAura")) then
							continue
						end

						descendant.Enabled = true
					end

					fn = function()
						local v15 = { v11, v12, v13 }

						for _, FX2 in pairs(v15) do
							able({
								FX = FX2,
								On = false
							})
						end
					end
				end)
				task.delay(13.9, function()
					local v14 = { v11, v12, v13 }

					for _, FX2 in pairs(v14) do
						able({
							FX = FX2,
							On = false
						})
					end
				end)
			end)
			return
		end

		for _, child in pairs(script.TemplateR6:GetChildren()) do
			cloneBeamsAndTrails(child, char[tostring(child)], cleanupTable)
		end

		local clone = script.ColorCorrection:Clone()
		table.insert(cleanupTable, clone)
		local clone2 = script.DepthOfField:Clone()
		table.insert(cleanupTable, clone2)
		local Lighting = game:GetService("Lighting")
		local Lighting2 = game:GetService("Lighting")
		clone.Parent = Lighting
		clone2.Parent = Lighting2
		object._maid:give(clone)
		object._maid:give(clone2)
		local FX3 = quickWeld({
			FX = vfx.FloorFx,
			Maid = object._maid,
			P = char.PrimaryPart,
			C0 = CFrame.new(0, 3.5, 0)
		})
		table.insert(cleanupTable, FX3)
		able({
			FX = FX3,
			On = true
		})
		local v11 = quickWeld({
			FX = vfx.Beams,
			Maid = object._maid,
			P = char.PrimaryPart,
			C0 = CFrame.new(0, 3.5, 0)
		})
		table.insert(cleanupTable, v11)
		thingable(v11, true, "Beam")

		for _, emitter in pairs(char:GetDescendants()) do
			if not (emitter:IsA("ParticleEmitter") and emitter.Name == "Line") then
				continue
			end

			local clone3 = emitter:Clone()
			table.insert(cleanupTable, clone3)
			clone3.Parent = emitter.Parent
			object._maid:give(clone3)
		end

		local v12

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v12 = false
		else
			v12 = true
		end

		if not v12 then
			return
		end

		local clones3 = {}

		if v8 then
			local v13

			if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v3 = true
				v13 = false
			else
				v13 = true
			end

			if not v13 then
				return
			end

			for _, v14 in pairs({ script.Impact }) do
				local clone3 = v14:Clone()
				game.Debris:AddItem(clone3, 10)
				clone3.Enabled = true
				clone3.Parent = game.Players.LocalPlayer.PlayerGui

				for _, image in pairs(clone3:GetDescendants()) do
					if not image:IsA("ImageLabel") then
						continue
					end

					image.Size = UDim2.new(0, 1, 0, 1)
					image.Visible = true
					image.Position = UDim2.new(0, 0, 0, 0)
					image.ImageTransparency = 0
				end

				table.insert(clones3, clone3)
			end
		end

		dtwait(6.3)
		local v13

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v13 = false
		else
			v13 = true
		end

		if not v13 then
			return
		end

		local function ImpactFrames(p, _)
			if not v8 then
				return
			end

			for _, impact in pairs(clones3) do
				local v15 = tostring(p)

				if tostring(impact) ~= v15 then
					continue
				end

				object.Impact = impact
				break
			end

			local frames = object.Impact.Frames

			if not frames then
				return
			end

			for _, descendant in pairs(char:GetDescendants()) do
				if not ((descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("PointLight")) and descendant:GetAttribute("TrueAura")) then
					continue
				end

				descendant.Enabled = true
			end

			local v14 = nil
			local v15 = 1
			tick()
			local v16 = nil
			v16 = shared.loop(function()
				local child = frames:FindFirstChild((tostring(v15)))

				if child and child ~= nil and child.Parent then
					local flag

					if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v3 = true
						flag = false
					else
						flag = true
					end

					if flag then
						v15 += 1
						child.Size = UDim2.new(1, 0, 1, 0)

						if v14 then
							v14:Destroy()
						end

						v14 = child
						return
					end
				end

				for _, child2 in pairs(frames:GetChildren()) do
					child2:Destroy()
				end

				return v16()
			end, 30)
		end

		if v8 then
			ImpactFrames("Impact")
		end

		local FX4 = quickWeld({
			FX = vfx.FloorFx1,
			Maid = object._maid,
			P = char.PrimaryPart,
			C0 = CFrame.new(0, 3.5, 0)
		})
		table.insert(cleanupTable, FX4)
		able({
			FX = FX4,
			On = true
		})
		thingable(char, true, "Beam")
		playAttachment(char)

		for _, child in pairs(char:GetChildren()) do
			if tostring(child) ~= "CamRigDook" then
				continue
			end

			FX = child
			break
		end

		able({
			FX = FX,
			On = true
		})
		local clone3 = vfx.TrailPart:Clone()
		local clone4 = vfx.TrailPart1:Clone()
		local clone5 = vfx.TrailPart2:Clone()
		table.insert(cleanupTable, clone3)
		table.insert(cleanupTable, clone4)
		table.insert(cleanupTable, clone5)
		clone3.Parent = game.Workspace.Thrown
		clone4.Parent = game.Workspace.Thrown
		clone5.Parent = game.Workspace.Thrown
		clone3.CFrame = char.PrimaryPart.CFrame * CFrame.new(0, -3.5, 0)
		clone4.CFrame = char.PrimaryPart.CFrame * CFrame.new(0, -3.5, 0)
		clone5.CFrame = char.PrimaryPart.CFrame * CFrame.new(0, -3.5, 0)
		thingable(clone3, true, "Trail")
		thingable(clone4, true, "Trail")
		thingable(clone5, true, "Trail")
		object._maid:give(clone3)
		object._maid:give(clone4)
		object._maid:give(clone5)
		spin(clone3) -- equivalent call inferred; original call site unknown
		spin(clone4) -- equivalent call inferred; original call site unknown
		spin(clone5) -- equivalent call inferred; original call site unknown
		local v15

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v15 = false
		else
			v15 = true
		end

		if not v15 then
			return
		end

		dtwait(0.15)
		local v16

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v16 = false
		else
			v16 = true
		end

		if not v16 then
			return
		end

		local clone6 = vfx.TextFx:Clone()
		table.insert(cleanupTable, clone6)
		clone6.Parent = game.Workspace.Thrown
		clone6.CFrame = char.PrimaryPart.CFrame * CFrame.new(-0.76, 1.8, -0.86) * CFrame.Angles(
			0,
			-1.5219271077390555,
			0
		)
		object._maid:give(clone6)
		playAttachment(clone6)
		dtwait(3)
		local v17

		if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v3 = true
			v17 = false
		else
			v17 = true
		end

		if not v17 then
			return
		end

		thingable(FX, true, "Beam")
	end

	task.spawn(FirstEvent)
	wait(15)
	Clean() -- equivalent call inferred; original call site unknown
	local v9

	if v3 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
		v3 = true
		v9 = false
	else
		v9 = true
	end

	if not v9 then
		return
	end

	thingable(FX, false, "Beam")
	thingable(char, false, "Beam")
	able({
		FX = FX,
		On = false
	})
end

return TrueRage
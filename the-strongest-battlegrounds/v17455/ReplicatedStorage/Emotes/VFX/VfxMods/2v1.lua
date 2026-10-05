local createVector = vector.create
local _2v1 = {}
local library = require(game.ReplicatedStorage.library)
local playAttachment = library.PlayAttachment
local maid = library.Maid
local _ = library.PlayTween
local _ = library.CamShake
local _ = library.PlayFlipBook
local _ = library.dtwait
local _ = library.EFP
local _ = library.PlayMesh
local impact = library.Impact
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
local _ = game.Workspace.Camera

function _2v1.FirstEvent(data)
	local char = data.Char
	local _ = char == game.Players.LocalPlayer.Character
	local character = game.Players.LocalPlayer.Character

	if char ~= character and data.targChar ~= character then
		return
	end

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
	local _ = char == game.Players.LocalPlayer.Character or char == data.targChar

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

	local v3 = {}
	local v4 = false
	local flag = false

	local function fn(p)
		if p == 0 and not v4 then
			v4 = true

			for k, _ in pairs(v3) do
				k.LocalTransparencyModifier = 0
			end
		else
			flag = true

			for _, descendant in pairs(workspace.Thrown:GetDescendants()) do
				if not (tostring(descendant) == "Debris" and (char.PrimaryPart.Position - descendant.Position).Magnitude <= 170) then
					continue
				end

				descendant.CFrame = CFrame.new(40000, 40000, 40000)
			end

			for _, part in pairs(workspace.Map:GetDescendants()) do
				if not part:IsA("BasePart") then
					continue
				end

				v3[part] = true
				part.LocalTransparencyModifier = 1
			end
		end
	end

	local DUALEMOTECLONE = char:WaitForChild("DUALEMOTECLONE", 1)

	if not DUALEMOTECLONE then
		return
	end

	local targChar = data.targChar
	local clone = nil
	local transparenciesByDescendant = {}
	local enabledsByDescendant = {}
	(function(p)
		if p == 0 then
			for k, transparency in pairs(transparenciesByDescendant) do
				k.Transparency = transparency
			end

			for k, enabled in pairs(enabledsByDescendant) do
				k.Enabled = enabled
			end
		else
			for _, descendant in pairs(targChar:GetDescendants()) do
				if descendant:IsA("PointLight") or descendant:IsA("Beam") or descendant:IsA("ParticleEmitter") or descendant:IsA("BillboardGui") then
					enabledsByDescendant[descendant] = descendant.Enabled
					descendant.Enabled = false
				end

				if not (descendant:IsA("BasePart") or descendant:IsA("Decal")) then
					continue
				end

				transparenciesByDescendant[descendant] = descendant.Transparency
				descendant.Transparency = 1
			end
		end
	end)(1)
	local star = char:FindFirstChild("Star")

	local function fn2(p)
		local enabled = p ~= 1

		for _, effect in pairs(star:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = enabled
			end

			if effect:IsA("Beam") then
				effect.Enabled = enabled
			end
		end
	end

	tick()
	table.insert(cleanupTable, (task.delay(17.1, function()
		for k, transparency in pairs(transparenciesByDescendant) do
			k.Transparency = transparency
		end

		for k, enabled in pairs(enabledsByDescendant) do
			k.Enabled = enabled
		end
	end)))
	local connection = nil
	connection = data.RealAnim:GetMarkerReachedSignal("kick"):Once(function()
		clone.Brightness = 1
		TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Sine), {
			Brightness = 0
		}):Play()

		for k, _ in pairs(v3) do
			k.LocalTransparencyModifier = 0
		end

		Clean() -- equivalent call inferred; original call site unknown

		for k, transparency in pairs(transparenciesByDescendant) do
			k.Transparency = transparency
		end

		for k, enabled in pairs(enabledsByDescendant) do
			k.Enabled = enabled
		end

		fn2(1)
		local folder = quickWeld({
			FX = vfx.KICK,
			Maid = object._maid,
			P = char.PrimaryPart,
			C0 = CFrame.new(1.2, 0.5, 2)
		})

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(40)
			end
		end

		if connection then
			connection:Disconnect()
		end
	end)
	local childAddedConnection = nil

	local function fn3()
		v = true
		Clean() -- equivalent call inferred; original call site unknown

		for k, transparency in pairs(transparenciesByDescendant) do
			k.Transparency = transparency
		end

		for k, enabled in pairs(enabledsByDescendant) do
			k.Enabled = enabled
		end

		spawn(function()
			fn(0)

			if flag then
				for k, _ in pairs(v3) do
					k.LocalTransparencyModifier = 0
				end
			end
		end)

		if childAddedConnection then
			childAddedConnection:Disconnect()
		end

		return parentChangedConnection:Disconnect()
	end

	childAddedConnection = char.ChildAdded:Connect(function(child)
		if tostring(child) == "Freeze" or tostring(child) == "Slowed" or tostring(child) == "Ragdoll" then
			fn3()
		end
	end)
	parentChangedConnection = bind:GetPropertyChangedSignal("Parent"):Connect(function()
		if not (bind and bind.Parent) then
			fn3()
		end
	end)
	task.delay(20, function()
		if childAddedConnection then
			childAddedConnection:Disconnect()
		end

		if parentChangedConnection then
			return parentChangedConnection:Disconnect()
		end
	end)
	task.delay(20, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local v5

	if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
		v = true
		v5 = false
	else
		v5 = true
	end

	if not v5 then
		return
	end

	local function FirstEvent()
		local WAIT_INTERVAL = 0.5

		local function thingable(folder, enabled, className)
			for _, descendant in pairs(folder:GetDescendants()) do
				if descendant:IsA(className) then
					descendant.Enabled = enabled
				end
			end
		end

		local extra = script.extra
		local clones = {}

		for _, child in pairs(extra.char:GetChildren()) do
			local clone2 = child:Clone()
			clone2.Parent = char.Head
			table.insert(clones, clone2)
			game.Debris:AddItem(clone2, 20)
			table.insert(cleanupTable, clone2)
		end

		fn2(1)
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

		local thrown = workspace.Thrown
		clone = script.ColorCorrection:Clone()
		clone.Parent = game.Lighting
		local v7 = clone
		game.Debris:AddItem(v7, 20)
		table.insert(cleanupTable, v7)
		local v8

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v8 = false
		else
			v8 = true
		end

		if not v8 then
			return
		end

		task.wait(0.45)
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

		local clone2 = vfx.BackG1:Clone()
		game.Debris:AddItem(clone2, 20)
		table.insert(cleanupTable, clone2)
		clone2.Parent = thrown
		clone2.CFrame = DUALEMOTECLONE.PrimaryPart.CFrame * CFrame.new(0, -1, 3)
		thingable(clone2, true, "Beam")
		local clone3 = vfx.RoomReal:Clone()
		game.Debris:AddItem(clone3, 20)
		table.insert(cleanupTable, clone3)
		clone3.Parent = thrown
		clone3.CFrame = DUALEMOTECLONE.PrimaryPart.CFrame * CFrame.new(0, 97.1, 0)
		object._maid:give(clone2)
		object._maid:give(clone3)
		local FX = quickWeld({
			FX = vfx.Line,
			Maid = object._maid,
			P = DUALEMOTECLONE.PrimaryPart,
			C0 = CFrame.new(0, 0, 0)
		})
		game.Debris:AddItem(FX, 20)
		table.insert(cleanupTable, FX)
		able({
			FX = FX,
			On = true
		})
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

		task.wait(0.28)
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
			FX = vfx.Startenegy,
			Maid = object._maid,
			P = DUALEMOTECLONE["Right Arm"],
			C0 = DUALEMOTECLONE["Right Arm"].RightGripAttachment.CFrame * CFrame.new(0, 2, 0)
		})
		game.Debris:AddItem(v13, 20)
		table.insert(cleanupTable, v13)
		playAttachment(v13)
		local FX2 = quickWeld({
			FX = vfx.Handau,
			Maid = object._maid,
			P = DUALEMOTECLONE["Right Arm"].Rock,
			C0 = CFrame.new(0, 0, 0)
		})
		able({
			FX = FX2,
			On = true
		})
		game.Debris:AddItem(FX2, 20)
		table.insert(cleanupTable, FX2)
		task.wait(1)
		local v15

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v15 = false
		else
			v15 = true
		end

		if not v15 then
			return
		end

		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		game.Debris:AddItem(colorCorrectionEffect, 20)
		table.insert(cleanupTable, colorCorrectionEffect)
		colorCorrectionEffect.Brightness = 50
		colorCorrectionEffect.Contrast = 200
		colorCorrectionEffect.Saturation = -1
		colorCorrectionEffect.TintColor = Color3.fromRGB(255, 255, 255)
		impact(colorCorrectionEffect, 0.05)
		local FX3 = quickWeld({
			FX = vfx.Line2,
			Maid = object._maid,
			P = DUALEMOTECLONE.PrimaryPart,
			C0 = CFrame.new(0, -30, 0)
		})
		able({
			FX = FX3,
			On = true
		})
		game.Debris:AddItem(FX3, 20)
		table.insert(cleanupTable, FX3)
		task.wait(0.3)
		local v17

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v17 = false
		else
			v17 = true
		end

		if not v17 then
			return
		end

		FX3:Destroy()
		clone2:Destroy()
		DUALEMOTECLONE:Destroy("")
		clone3.CFrame *= CFrame.new(0, -90, 0)
		clone3.Transparency = 1
		local clone4 = vfx.rockvfx.End:Clone()
		game.Debris:AddItem(clone4, 20)
		table.insert(cleanupTable, clone4)
		clone4.Parent = thrown
		clone4.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(1, 0, 0)
		clone4.CFrame *= CFrame.Angles(0, -1.5707963267948966, 0)
		object._maid:give(clone4)
		local size = clone4.Size
		local cFrame = clone4.CFrame
		local clone5 = vfx.BackG2:Clone()
		game.Debris:AddItem(clone5, 20)
		table.insert(cleanupTable, clone5)
		clone5.Parent = thrown
		clone5.CFrame = cFrame * CFrame.new(9, -4, -9) * CFrame.Angles(0, 3.141592653589793, 0)
		local clone6 = vfx.BackG3:Clone()
		game.Debris:AddItem(clone6, 20)
		table.insert(cleanupTable, clone6)
		clone6.Parent = thrown
		clone6.CFrame = cFrame * CFrame.new(-38, 0, 0) * CFrame.Angles(0, 3.141592653589793, 0)
		thingable(clone5, true, "Beam")
		thingable(clone6, true, "Beam")
		fn(1)
		task.spawn(function()
			for _ = 1, 30 do
				local v18

				if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v = true
					v18 = false
				else
					v18 = true
				end

				if not v18 then
					break
				end

				TweenService:Create(clone4, TweenInfo.new(0.05), {
					Size = createVector(7.008, 1.243, 1.267),
					CFrame = clone4.CFrame * CFrame.new(3, 0, 0)
				}):Play()
				task.wait(0.1)
				local v19

				if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v = true
					v19 = false
				else
					v19 = true
				end

				if not v19 then
					break
				end

				TweenService:Create(clone4, TweenInfo.new(0.05), {
					Size = size,
					CFrame = cFrame
				}):Play()
				task.wait(0.05)
			end
		end)
		local v18 = { vfx.rockvfx.Fire, vfx.rockvfx.Rock2 }

		for _, v19 in pairs(v18) do
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

			local clone7 = v19:Clone()
			game.Debris:AddItem(clone7, 20)
			table.insert(cleanupTable, clone7)

			if v19 == vfx.rockvfx.Fire then
				clone7.CFrame = clone4.CFrame * CFrame.new(-2.5, 0, 0) * CFrame.Angles(0, 1.5707963267948966, 0)
				local FX4 = clone7
				task.delay(0.6, function()
					able({
						FX = FX4,
						On = true
					})
				end)
			else
				clone7.CFrame = clone4.CFrame * CFrame.new(-1, 0, 0) * CFrame.Angles(0, 1.5707963267948966, 0)
				able({
					FX = clone7,
					On = true
				})
			end

			clone7.Parent = clone4
			object._maid:give(clone7)
		end

		task.wait(1.97)
		local v19

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v19 = false
		else
			v19 = true
		end

		if not v19 then
			return
		end

		local folder = quickWeld({
			FX = vfx.Line4,
			Maid = object._maid,
			P = char.PrimaryPart,
			C0 = CFrame.new(0, 0, 100)
		})
		game.Debris:AddItem(folder, 20)
		table.insert(cleanupTable, folder)

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter.Parent:IsA("Attachment") or not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
		end

		local folder2 = quickWeld({
			FX = vfx.Line4,
			Maid = object._maid,
			P = char.PrimaryPart,
			C0 = CFrame.new(0, 0, -40)
		})
		game.Debris:AddItem(folder2, 20)
		table.insert(cleanupTable, folder2)

		for _, emitter in pairs(folder2:GetDescendants()) do
			if emitter.Parent:IsA("Attachment") or not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
		end

		local v20 = quickWeld({
			FX = vfx.clap,
			Maid = object._maid,
			P = char.PrimaryPart,
			C0 = CFrame.new(0, 0, 0)
		})
		playAttachment(v20)
		game.Debris:AddItem(v20, 20)
		table.insert(cleanupTable, v20)
		clone.Brightness = 1
		TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
			Brightness = 0
		}):Play()
		task.wait(0.13)
		local v21

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v21 = false
		else
			v21 = true
		end

		if not v21 then
			return
		end

		clone4:Destroy()
		clone5:Destroy()
		clone6:Destroy()
		clone3.Transparency = 0
		local FX5 = quickWeld({
			FX = vfx.HELP,
			Maid = object._maid,
			P = char.PrimaryPart,
			C0 = CFrame.new(0, 3, 0.5)
		})
		able({
			FX = FX5,
			On = true
		})
		game.Debris:AddItem(FX5, 20)
		table.insert(cleanupTable, FX5)
		local FX6 = quickWeld({
			FX = vfx.speedlined,
			Maid = object._maid,
			P = char.PrimaryPart,
			C0 = CFrame.new(0, 0, -2)
		})
		able({
			FX = FX6,
			On = true
		})
		game.Debris:AddItem(FX6, 20)
		table.insert(cleanupTable, FX6)
		task.wait(0.55)
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
			FX = vfx.wow,
			Maid = object._maid,
			P = char.PrimaryPart,
			C0 = CFrame.new(0, 0, 4)
		})
		game.Debris:AddItem(v25, 20)
		table.insert(cleanupTable, v25)
		playAttachment(v25)
		task.wait(1.9)
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

		clone.Brightness = 1
		TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			Brightness = 0
		}):Play()
		FX6:Destroy()
		task.wait(1.5)
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

		fn2(0)
		local highlight = Instance.new("Highlight")
		game.Debris:AddItem(highlight, 20)
		table.insert(cleanupTable, highlight)
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillColor = Color3.fromRGB(255, 0, 0)
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 1
		highlight.Parent = char
		highlight.Name = "Red"
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		TweenService:Create(highlight, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			FillTransparency = 0
		}):Play()
		warn(highlight, highlight.Parent)
		task.wait(1.1)
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

		highlight.FillTransparency = 1
		local FX7 = quickWeld({
			FX = vfx.Blackhole,
			Maid = object._maid,
			P = char.PrimaryPart,
			C0 = CFrame.new(0, 0, 50)
		})
		able({
			FX = FX7,
			On = true
		})
		game.Debris:AddItem(FX7, 20)
		table.insert(cleanupTable, FX7)
		local v30 = {
			char.Star.Part1,
			char.Star.Part2,
			char.Star.Part3,
			char.Star.Part4,
			char.Star.Part5
		}

		for _, v31 in pairs(v30) do
			thingable(v31, true, "Beam")
		end

		able({
			FX = v30[1],
			On = true
		})
		task.wait(WAIT_INTERVAL)
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

		local v32 = quickWeld({
			FX = vfx.wing1,
			Maid = object._maid,
			P = v30[1],
			C0 = CFrame.new(0, 0, 0)
		})
		game.Debris:AddItem(v32, 20)
		table.insert(cleanupTable, v32)
		playAttachment(v32)
		task.wait(WAIT_INTERVAL)
		local v33

		if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v = true
			v33 = false
		else
			v33 = true
		end

		if not v33 then
			return
		end

		local FX8 = quickWeld({
			FX = vfx.wing2,
			Maid = object._maid,
			P = v30[1],
			C0 = CFrame.new(0, 0, 0)
		})
		game.Debris:AddItem(FX8, 20)
		table.insert(cleanupTable, FX8)
		able({
			FX = FX8,
			On = true
		})
		task.delay(0.2, function()
			able({
				FX = FX8,
				On = false
			})
		end)
		task.wait(WAIT_INTERVAL)
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

		local v36 = quickWeld({
			FX = vfx.wing3,
			Maid = object._maid,
			P = v30[1],
			C0 = CFrame.new(0, 0, 0)
		})
		playAttachment(v36)
		game.Debris:AddItem(v36, 20)
		table.insert(cleanupTable, v36)
		task.wait(WAIT_INTERVAL)
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

		able({
			FX = FX8,
			On = true
		})
		task.delay(0.2, function()
			able({
				FX = FX8,
				On = false
			})
		end)
		task.wait(1.2)
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

		local FX9 = quickWeld({
			FX = vfx.A,
			Maid = object._maid,
			P = v30[1],
			C0 = CFrame.new(0, 0, 0)
		})
		game.Debris:AddItem(FX9, 20)
		table.insert(cleanupTable, FX9)
		able({
			FX = FX9,
			On = true
		})
		local clone7 = vfx.star:Clone()
		game.Debris:AddItem(clone7, 20)
		table.insert(cleanupTable, clone7)
		clone7.Parent = thrown
		clone7.CFrame = v30[1].CFrame * CFrame.new(-2.9, 5.1, 0)
		task.wait(0.2)
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

		TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
			Brightness = 1
		}):Play()
		task.wait(0.3)
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

		clone.Brightness = 1
		TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			Brightness = 0
		}):Play()
		able({
			FX = clone7,
			On = true
		})
		folder:Destroy()
		folder2:Destroy()
		FX7:Destroy()
		local FX10 = quickWeld({
			FX = vfx.Line5,
			Maid = object._maid,
			P = char.PrimaryPart,
			C0 = CFrame.new(0, 0, 0)
		})
		game.Debris:AddItem(FX10, 20)
		table.insert(cleanupTable, FX10)
		able({
			FX = FX10,
			On = true
		})
		task.wait(1.85)
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

		clone7:Destroy()
		local v44 = quickWeld({
			FX = vfx.Handclap,
			Maid = object._maid,
			P = char["Right Arm"],
			C0 = char["Right Arm"].RightGripAttachment.CFrame * CFrame.new(0, 1.8, 0.2)
		})
		game.Debris:AddItem(v44, 20)
		table.insert(cleanupTable, v44)
		playAttachment(v44)

		for _, FX4 in pairs(clones) do
			able({
				FX = FX4,
				On = true
			})
		end

		task.wait(1)
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

		local FX11 = quickWeld({
			FX = vfx.Lighting,
			Maid = object._maid,
			P = char.PrimaryPart,
			C0 = CFrame.new(0, 0, 3)
		})
		game.Debris:AddItem(FX11, 20)
		table.insert(cleanupTable, FX11)
		able({
			FX = FX11,
			On = true
		})
		task.wait(1.3)
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

		task.delay(0.5, function()
			local v48

			if v or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v = true
				v48 = false
			else
				v48 = true
			end

			if not v48 then
				return
			end

			FX11:Destroy()
		end)
		TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
			Brightness = 1
		}):Play()
	end

	task.spawn(FirstEvent)
	wait(20)
	Clean() -- equivalent call inferred; original call site unknown
end

return _2v1
local createVector = vector.create
local FirstMove = {}
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
local Utility = require(game.ReplicatedStorage.Utility)
local firstMonsterVFX = game.ReplicatedStorage.Resources.FirstMonsterVFX
local class = {}
class.__index = class
local random = Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera

-- equivalent calls inferred from this helper; original call sites unknown
local function tween(instance, tweenInfo, data)
	task.spawn(function()
		if data.size then
			TweenService:Create(instance, tweenInfo, {
				CFrame = data.cframe,
				Size = data.size
			}):Play()
		else
			TweenService:Create(instance, tweenInfo, {
				CFrame = data.cframe
			}):Play()
		end

		for _, decal in pairs(instance:GetChildren()) do
			if decal:IsA("Decal") then
				TweenService:Create(decal, tweenInfo, {
					Transparency = data.transparency
				}):Play()
			end
		end

		TweenService:Create(instance:FindFirstChildWhichIsA("SpecialMesh"), tweenInfo, {
			Scale = data.scale
		}):Play()
	end)
end

local function fn(folder, _)
	local ray = shared.ray({
		orig = folder.Position,
		dir = createVector(0, -100, 0)
	})

	if ray then
		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") and tostring(emitter) == "smoke" then
				emitter.Color = ColorSequence.new(ray.Color)
			end
		end
	end
end

function FirstMove.Start(p)
	local char = p.Char
	local _ = char.PrimaryPart
	local _ = char.Humanoid
	local _ = char.Torso
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

	task.delay(4, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function makemesh(data)
		local clone = data.mesh:Clone()
		game.Debris:AddItem(clone, 15)
		clone.Parent = workspace.Thrown
		object._maid:give(clone)
		clone.CFrame = data.cframe
		local specialMesh = clone:FindFirstChildWhichIsA("SpecialMesh")
		specialMesh.Scale = data.scale

		for _, decal in pairs(clone:GetChildren()) do
			if decal:IsA("Decal") then
				decal.Transparency = data.transparency
			end
		end

		return clone
	end

	local function FirstEvent()
		dtwait(0.35)
		local parent = char
		local vfx = script.vfx
		local v3 = quickWeld({
			FX = vfx.jump,
			Maid = object._maid,
			P = parent.PrimaryPart,
			C0 = CFrame.new(0, 3.5, 0)
		})
		playAttachment(v3)
		fn(v3)
		local FX = quickWeld({
			FX = vfx.spin,
			Maid = object._maid,
			P = parent.Torso,
			C0 = CFrame.new(0, 0, 0)
		})
		able({
			FX = FX,
			On = true
		})
		FX.Parent = parent
		FX.Name = "DoomSpin"
		dtwait(0.5)
		able({
			FX = FX,
			On = false
		})
	end

	task.spawn(FirstEvent)
	wait(18)
	Clean() -- equivalent call inferred; original call site unknown
end

function FirstMove.FirstEvent(p)
	local char = p.Char
	local primaryPart = char.PrimaryPart
	local _ = char.Humanoid
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

	task.delay(4, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function FirstEvent()
		local cFrame = primaryPart.CFrame
		local FX = quickFX({
			FX = firstMonsterVFX.Jump,
			Maid = object._maid,
			Anchor = cFrame * CFrame.new(0, -primaryPart.Size.Y * 1.5, -1.5)
		})
		lifeScale({
			FX = FX,
			Scale = 1
		})
		FX:ScaleTo(1.8)
		playAttachment(FX)
		local FX2 = quickFX({
			FX = firstMonsterVFX.Smoke,
			Maid = object._maid,
			Anchor = cFrame * CFrame.new(0, -primaryPart.Size.Y * 1.5, -1.5)
		})
		lifeScale({
			FX = FX2,
			Scale = 1
		})
		playAttachment(FX2)
		local clone = firstMonsterVFX.Ring2:Clone()
		clone:ScaleTo(1.5)
		playMesh({
			Model = clone,
			T = 0,
			Anchor = cFrame * CFrame.new(0, -primaryPart.Size.Y * 1.5, 0) * CFrame.Angles(0, 0, 0),
			Info = TweenInfo.new(0.2, Enum.EasingStyle.Sine)
		})
		local clone2 = firstMonsterVFX.Wind:Clone()
		clone2:ScaleTo(1.3)
		playMesh({
			Model = clone2,
			T = 0.85,
			Anchor = primaryPart.CFrame * CFrame.new(0, 0, 2) * CFrame.Angles(0.7853981633974483, 0, 0) * CFrame.new(
				0,
				-20,
				0
			),
			Info = TweenInfo.new(0.5, Enum.EasingStyle.Quad)
		})
		local clone3 = firstMonsterVFX.Another:Clone()
		clone3:ScaleTo(1)
		playMesh({
			Model = clone3,
			EndT = 0,
			Anchor = primaryPart.CFrame * CFrame.new(0, 0, 2) * CFrame.Angles(-2.530727415391778, 0, 0) * CFrame.new(
				0,
				10,
				0
			),
			Info = TweenInfo.new(0.05, Enum.EasingStyle.Quad)
		})
		dtwait(0.05)
		local clone4 = firstMonsterVFX.Ring1:Clone()
		clone4:ScaleTo(1.5)
		playMesh({
			Model = clone4,
			T = 0.5,
			Anchor = primaryPart.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(-2.530727415391778, 0, 0),
			Info = TweenInfo.new(0.2, Enum.EasingStyle.Sine)
		})
		task.spawn(function()
			local effects = firstMonsterVFX.Effects
			local clone5 = effects.JumpDust1:Clone()
			clone5.CFrame = cFrame * CFrame.new(0, -primaryPart.Size.Y * 1.5, 0)
			clone5.Parent = EFP
			Utility.Debris(clone5, 2)
			local clone6 = effects.JumpVFX:Clone()
			local start = clone6.Distortion.Start
			local highlight = Instance.new("Highlight")
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.FillColor = Color3.fromRGB(255, 0, 0)
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = 1
			highlight.Enabled = true
			highlight.Parent = start
			clone6.Parent = EFP
			Utility.Debris(clone6, 0.5)
			Utility.vfxTween(clone6.Wind, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out))
			Utility.vfxTween(clone6.Main, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out))
			Utility.vfxTween(clone6.Distortion, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out))
		end)
	end

	task.spawn(FirstEvent)
	wait(4)
	Clean() -- equivalent call inferred; original call site unknown
end

function FirstMove.PreDive(p)
	local char = p.Char
	local primaryPart = char.PrimaryPart
	local _ = char.Humanoid
	local _ = char.Torso
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

	task.delay(4, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function makemesh(data)
		local clone = data.mesh:Clone()
		game.Debris:AddItem(clone, 15)
		clone.Parent = workspace.Thrown
		object._maid:give(clone)
		clone.CFrame = data.cframe
		local specialMesh = clone:FindFirstChildWhichIsA("SpecialMesh")
		specialMesh.Scale = data.scale

		for _, decal in pairs(clone:GetChildren()) do
			if decal:IsA("Decal") then
				decal.Transparency = data.transparency
			end
		end

		return clone
	end

	local function FirstEvent()
		local monsterPosConfrim = char:FindFirstChild("MonsterPosConfrim")
		local _ = primaryPart.CFrame

		if monsterPosConfrim then
			CFrame.new(primaryPart.Position, monsterPosConfrim.Value.Position)
		end

		local vfx = script.vfx
		local char2 = char
		local v3 = makemesh({
			mesh = vfx.Spiral2,
			cframe = char2.PrimaryPart.CFrame * CFrame.new(0, -1, 0) * CFrame.Angles(0.8377580409572782, 0, 0),
			scale = createVector(1.88, 4.769, 1.869),
			transparency = 0
		})
		tween(v3, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			cframe = v3.CFrame * CFrame.new(0, -8, 0) * CFrame.Angles(
				-3.158836506599497,
				1.4354634965952562,
				3.141592653589793
			),
			transparency = 1,
			scale = createVector(1.88, 14.029, 1.869)
		}) -- equivalent call inferred; original call site unknown
		local v5 = makemesh({
			mesh = vfx.windJ,
			scale = createVector(0.006, 0.003, 0.006),
			transparency = 0,
			cframe = char2.PrimaryPart.CFrame * CFrame.new(-0.52, -1, 0) * CFrame.Angles(0.8377580409572782, 0, 0)
		})
		tween(v5, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			cframe = v5.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(0, -1.4354634965952562, 0),
			transparency = 1,
			scale = createVector(0.013, 0.003, 0.013)
		}) -- equivalent call inferred; original call site unknown
		task.delay(0.25, function()
			local v7 = makemesh({
				mesh = vfx.windJ,
				scale = createVector(0.006, 0.003, 0.006),
				transparency = 0,
				cframe = char2.PrimaryPart.CFrame * CFrame.new(-0.52, -1, 0) * CFrame.Angles(0.8377580409572782, 0, 0)
			})
			tween(v7, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
				cframe = v7.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(0, -1.4354634965952562, 0),
				transparency = 1,
				scale = createVector(0.013, 0.003, 0.013)
			}) -- equivalent call inferred; original call site unknown
		end)
		task.spawn(function()
			for _ = 1, 3 do
				local v7 = makemesh({
					mesh = vfx.WINDM,
					scale = createVector(0.326, 0.272, 0.234),
					transparency = 0,
					cframe = char2.PrimaryPart.CFrame * CFrame.new(0, 1, 1) * CFrame.Angles(
						-2.251474735072685,
						1.5707963267948966,
						-1.5707963267948966
					)
				})
				tween(v7, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
					cframe = v7.CFrame * CFrame.new(-4, 0, 0) * CFrame.Angles(0, 0, 0),
					transparency = 1,
					scale = createVector(1.137, 0.272, 0.234)
				}) -- equivalent call inferred; original call site unknown
				dtwait(0.15)
			end
		end)
		task.spawn(function()
			for _ = 1, 4 do
				local v7 = makemesh({
					mesh = vfx.Reda,
					scale = createVector(0.326, 0.124, 0.124),
					transparency = 0,
					cframe = char2.PrimaryPart.CFrame * CFrame.new(0, 0.5, 2.45) * CFrame.Angles(
						2.3722515193106926,
						1.5707963267948966,
						0
					)
				})
				tween(v7, TweenInfo.new(0.08, Enum.EasingStyle.Sine), {
					cframe = v7.CFrame * CFrame.new(-2, -1, 0) * CFrame.Angles(0, 0, -0.13962634015954636),
					transparency = 1,
					scale = createVector(0.614, 0.1, 0.1),
					size = createVector(14.035, 0.001, 0.001)
				}) -- equivalent call inferred; original call site unknown
				dtwait(0.08)
			end
		end)
		local FX = quickWeld({
			FX = vfx.Legaura,
			Maid = object._maid,
			P = char2["Right Leg"],
			C0 = CFrame.new(0, 1, 0)
		})
		able({
			FX = FX,
			On = true
		})
		playAttachment((quickWeld({
			FX = vfx.pre,
			Maid = object._maid,
			P = char2.PrimaryPart,
			C0 = CFrame.new(0, 0, -1)
		})))
		dtwait(0.3)
		able({
			FX = FX,
			On = false
		})
	end

	task.spawn(FirstEvent)
	wait(4)
	Clean() -- equivalent call inferred; original call site unknown
end

function FirstMove.Dive(p)
	local char = p.Char
	local primaryPart = char.PrimaryPart
	local _ = char.Humanoid
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

	task.delay(4, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function FirstEvent()
		local _ = primaryPart.CFrame
		local count = 0
		local folders = {}
		task.spawn(function()
			local lastTime = tick()

			while tick() - lastTime < 1.1 do
				count += 1

				if count % 5 == 0 and tick() - lastTime < 0.2 then
					local folder = quickFX({
						FX = firstMonsterVFX.Spiralll,
						Maid = object._maid,
						Anchor = primaryPart.CFrame * CFrame.new(0, -4.5, -5) * CFrame.Angles(
							0,
							-1.5707963267948966,
							-2.356194490192345
						) * CFrame.new(-1.5, 0, 0) * CFrame.Angles(math.rad((math.random(0, 360))), 0, 0)
					})
					folder:ScaleTo(folder:GetScale() * random:NextNumber(0.9, 1.1) * 0.3)
					game.Debris:AddItem(folder, 1.5)
					table.insert(folders, folder)

					for _, descendant in pairs(folder:GetDescendants()) do
						if descendant:IsA("Decal") then
							local transparency = descendant.Transparency
							descendant.Transparency = 1
							TweenService:Create(
								descendant,
								TweenInfo.new(0.020000000000000004, Enum.EasingStyle.Sine),
								{
									Transparency = transparency
								}
							):Play()
							local v2 = descendant
							task.delay(0.021, function()
								TweenService:Create(v2, TweenInfo.new(0.03, Enum.EasingStyle.Sine), {
									Transparency = 1
								}):Play()
							end)
						elseif descendant:IsA("SpecialMesh") then
							TweenService:Create(descendant, TweenInfo.new(0.05, Enum.EasingStyle.Sine), {
								Scale = descendant.Scale * 2
							}):Play()
						end
					end

					local folder2 = quickFX({
						FX = firstMonsterVFX.Real,
						Maid = object._maid,
						Anchor = primaryPart.CFrame * CFrame.new(0, -4.5, -5) * CFrame.Angles(
							0,
							-1.5707963267948966,
							-2.356194490192345
						) * CFrame.new(-1.5, 0, 0) * CFrame.Angles(math.rad((math.random(0, 360))), 0, 0)
					})
					folder2:ScaleTo(folder2:GetScale() * random:NextNumber(1, 1.2) * 0.3)
					game.Debris:AddItem(folder2, 1.5)
					table.insert(folders, folder2)

					for _, descendant in pairs(folder2:GetDescendants()) do
						if descendant:IsA("Decal") then
							local transparency = descendant.Transparency
							descendant.Transparency = 1
							TweenService:Create(descendant, TweenInfo.new(0.03, Enum.EasingStyle.Sine), {
								Transparency = transparency
							}):Play()
							local v2 = descendant
							task.delay(0.031, function()
								TweenService:Create(v2, TweenInfo.new(0.04000000000000001, Enum.EasingStyle.Sine), {
									Transparency = 1
								}):Play()
							end)
						elseif descendant:IsA("SpecialMesh") then
							TweenService:Create(descendant, TweenInfo.new(0.06, Enum.EasingStyle.Sine), {
								Scale = descendant.Scale * 2
							}):Play()
						end
					end

					local clone = firstMonsterVFX.Dive4:Clone()
					clone:ScaleTo(0.44999999999999996)
					clone.Start.Material = Enum.Material.Neon
					clone.Start.Color = Color3.new(1, 0.254902, 0.00392157)
					TweenService:Create(clone.Start, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
						Color = Color3.fromRGB(0, 0, 0)
					}):Play()
					playMesh({
						Model = clone,
						T = 0,
						Anchor = primaryPart.CFrame * CFrame.new(0, -3.5, -4) * CFrame.Angles(-2.356194490192345, 0, 0),
						Info = TweenInfo.new(0.1, Enum.EasingStyle.Sine)
					})
				end

				for _, model in pairs(folders) do
					if not model:IsA("Model") then
						continue
					end

					if model.Name == "Spiralll" then
						model:PivotTo(model:GetPivot() * CFrame.Angles(0.20943951023931956, 0, 0))
					else
						model:PivotTo(model:GetPivot() * CFrame.Angles(0.06981317007977318, 0, 0))
					end
				end

				dtwait(0.01)
			end
		end)
	end

	task.spawn(FirstEvent)
	wait(4)
	Clean() -- equivalent call inferred; original call site unknown
end

function FirstMove.DiveImpact(p)
	local char = p.Char
	local _ = char.PrimaryPart
	local _ = char.Humanoid
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

	task.delay(4, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function thingable(folder, enabled, className)
		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant:IsA(className) then
				descendant.Enabled = enabled
			end
		end
	end

	local function makemesh(data)
		local clone = data.mesh:Clone()
		game.Debris:AddItem(clone, 15)
		clone.Parent = workspace.Thrown
		object._maid:give(clone)
		clone.CFrame = data.cframe
		local specialMesh = clone:FindFirstChildWhichIsA("SpecialMesh")

		if not specialMesh then
			return clone
		end

		specialMesh.Scale = data.scale

		for _, decal in pairs(clone:GetChildren()) do
			if decal:IsA("Decal") then
				decal.Transparency = data.transparency
			end
		end

		return clone
	end

	local function DiveImpact()
		local vfx = script.vfx
		local _ = p.Data.Anchor
		local v2 = quickWeld({
			FX = vfx.impact,
			Maid = object._maid,
			P = char.PrimaryPart,
			C0 = CFrame.new(0, 0.9, 1)
		})
		playAttachment(v2)
		fn(v2)
	end

	task.spawn(DiveImpact)
	wait(4)
	Clean() -- equivalent call inferred; original call site unknown
end

function FirstMove.SecondJump(p)
	local char = p.Char
	local _ = char.PrimaryPart
	local _ = char.Humanoid
	local _ = char.Torso
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

	task.delay(4, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function SecondJump()
		task.spawn(function()
			task.spawn(function()
				local DELAY_DURATION = 0.9
				local effects = firstMonsterVFX.Effects
				local _ = effects.RootFX
				local clones = {}
				local clone = effects.Trails.Attachment:Clone()
				clone.Parent = char["Right Arm"]
				task.delay(DELAY_DURATION, function()
					Utility.ToggleVFX(clone, false)
				end)
				table.insert(clones, clone)
				local clone2 = effects.Trails.Attachment:Clone()
				clone2.Parent = char["Left Arm"]
				task.delay(DELAY_DURATION, function()
					Utility.ToggleVFX(clone2, false)
				end)
				table.insert(clones, clone2)
				local clone3 = effects.Trails.Attachment:Clone()
				clone3.Parent = char["Right Leg"]
				task.delay(DELAY_DURATION, function()
					Utility.ToggleVFX(clone3, false)
				end)
				table.insert(clones, clone3)
				local clone4 = effects.Trails.Attachment:Clone()
				clone4.Parent = char["Left Leg"]
				task.delay(DELAY_DURATION, function()
					Utility.ToggleVFX(clone4, false)
				end)
				table.insert(clones, clone4)
				task.delay(DELAY_DURATION, function()
					for _, folder in pairs(clones) do
						for _, trail in pairs(folder:GetDescendants()) do
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
					end
				end)
			end)
		end)
	end

	task.spawn(SecondJump)
	wait(4)
	Clean() -- equivalent call inferred; original call site unknown
end

function FirstMove.SecondDive(p)
	local char = p.Char
	local primaryPart = char.PrimaryPart
	local _ = char.Humanoid
	local _ = char.Torso
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

	task.delay(4, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function SecondDive()
		task.spawn(function()
			local effects = firstMonsterVFX.Effects
			dtwait(0.15)
			local clone = effects.DiveVFX2:Clone()
			clone:PivotTo(primaryPart.CFrame)
			clone.Parent = EFP
			Utility.Debris(clone, 2)
			Utility.Emit(clone)
			local v2 = { clone.Distortion.Start, clone.ShockwaveGlass.Start }

			for _, parent in pairs(v2) do
				local highlight = Instance.new("Highlight")
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				highlight.FillColor = Color3.fromRGB(255, 0, 0)
				highlight.FillTransparency = 1
				highlight.OutlineTransparency = 1
				highlight.Enabled = true
				highlight.Parent = parent
			end

			Utility.vfxTween(clone.Distortion, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out))
			Utility.vfxTween(clone.Shockwave, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out))
			Utility.vfxTween(clone.Shockwave2, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out))
			Utility.vfxTween(clone.ShockwaveGlass, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out))
			Utility.vfxTween(clone.WindRing, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out))
			Utility.vfxTween(clone.Wind, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out))
			Utility.vfxTween(clone.Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
			Utility.vfxTween(clone.Wind3, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out))
			Utility.vfxTween(clone.WindDecal2, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
		end)
	end

	task.spawn(SecondDive)
	wait(4)
	Clean() -- equivalent call inferred; original call site unknown
end

function FirstMove.SecondImpact(p)
	local char = p.Char
	local primaryPart = char.PrimaryPart
	local _ = char.Humanoid
	local _ = char.Torso
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

	task.delay(4, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function SecondImpact()
		task.spawn(function()
			local anchor = p.Data.Anchor
			local effects = firstMonsterVFX.Effects
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { game.Workspace.Built, game.Workspace.Map }
			local raycastResult = game.Workspace:Raycast(anchor.Position, createVector(0, -100, 0), raycastParams)
			local clone = effects.Slam2:Clone()
			local _, v2, _ = primaryPart.CFrame:ToOrientation()

			if raycastResult then
				clone.CFrame = CFrame.new(raycastResult.Position) * CFrame.new(0, v2, 0) * CFrame.new(0, 0, -4)
			end

			clone.Parent = EFP
			Utility.Emit(clone)
			Utility.Debris(clone, 2.5)
			Utility.Tween(clone.Attachment2.PointLight, TweenInfo.new(0.3), {
				Brightness = 0
			})
			local cframe = CFrame.new(clone.Position + createVector(0, 15, 0))
			local position = cframe.Position
			local lookVector = cframe.LookVector
			local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)
			local clone2 = effects.Ring:Clone()
			clone2.Size = createVector(0, 14, 0)
			clone2.Color = Color3.fromRGB(248, 25, 25)
			clone2.CFrame = CFrame.new(position, position + vector2) * CFrame.Angles(0, 1.5707963267948966, 0)
			clone2.Parent = EFP
			clone2.Transparency = 0.75
			Utility.Tween(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				CFrame = clone2.CFrame + createVector(0, -15, 0),
				Size = createVector(35, 0.001, 35),
				Transparency = 1
			})
			Utility.Debris(clone2, 0.2)
			local clone3 = effects.Shockwave:Clone()
			clone3.Parent = EFP
			clone3:PivotTo(clone.CFrame)
			Utility.Debris(clone3, 0.45)
			Utility.vfxTween(clone3, TweenInfo.new(0.45, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out))
			local clone4 = effects.Shockwave2:Clone()
			clone4.Parent = EFP
			clone4:PivotTo(clone.CFrame)
			Utility.Debris(clone4, 0.45)
			Utility.vfxTween(clone4, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out))
			local clone5 = effects.Wind:Clone()
			clone5.Parent = EFP
			clone5:PivotTo(clone.CFrame)
			Utility.Debris(clone5, 0.25)
			Utility.vfxTween(clone5, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out))
		end)
	end

	task.spawn(SecondImpact)
	wait(4)
	Clean() -- equivalent call inferred; original call site unknown
end

return FirstMove
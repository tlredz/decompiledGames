local SkyRip = {}
local libraryNew = require(script.Parent.libraryNew)
local _ = libraryNew.PlayAttachment
local maid = libraryNew.Maid
local _ = libraryNew.PlayTween
local _ = libraryNew.CamShake
local _ = libraryNew.PlayFlipBook
local _ = libraryNew.dtwait
local EFP = libraryNew.EFP
local _ = libraryNew.PlayMesh
local _ = libraryNew.Impact
local _ = libraryNew.GlassLight
local _ = libraryNew.RaiseZIndex
local _ = libraryNew.Able
local _ = libraryNew.LifeScale
local _ = libraryNew.QuickFX
local quickWeld = libraryNew.QuickWeld
local _ = libraryNew.Yield
local _ = libraryNew.ProcessPart
local _ = libraryNew.WeldObject
local _ = libraryNew.Bezier
local vfx = script.vfx
local class = {}
class.__index = class
Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera
local Part_Icles = require(game.ReplicatedStorage.Resources.CosmicUtils.Part_Icles)

-- equivalent calls inferred from this helper; original call sites unknown
local function PlaceVFX(instance, p)
	instance:PivotTo(p * instance:GetAttribute("Offset"):Inverse())
end

local MoonEmitter = require(game.ReplicatedStorage.Resources.MoonEmitter)

function SkyRip.FirstEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local bind = data.bind
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

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local folder = nil
	local folder2 = nil
	bind.Destroying:Once(function()
		local v2 = { folder, folder2 }

		for _, folder3 in pairs(v2) do
			if not (folder3 and folder3.Parent) then
				continue
			end

			for _, effect in pairs(folder3:GetDescendants()) do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
					continue
				end

				effect.Enabled = false
			end
		end

		task.delay(1, Clean)
	end)

	local function FirstEvent()
		local function Dast()
			local v2 = object._maid:give(vfx.charge:Clone())
			task.spawn(function()
				local lastTime = tick()

				while tick() - lastTime < 0.6 do
					for _, child in pairs(v2:GetChildren()) do
						PlaceVFX(child, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
					end

					task.wait(0.1)
				end
			end)
			v2.Parent = EFP
			shared.vfx.emit(v2)
			task.wait(0.8)

			if not (bind and bind.Parent) then
				return
			end

			local part = object._maid:give(vfx.chargetrail:Clone())
			local chargetrail = part.chargetrail
			chargetrail.Part0 = char["Right Arm"]
			chargetrail.Part1 = part
			part.Parent = EFP
			shared.vfx.emit(part)
			local part2 = object._maid:give(vfx.PRE:Clone())
			local PRE = part2.PRE
			PRE.Part0 = char["Right Arm"]
			PRE.Part1 = part2
			part2.Parent = EFP
			shared.vfx.emit(part2)
			task.wait(0.3)

			if not (bind and bind.Parent) then
				return
			end

			local part3 = object._maid:give(vfx.Emit:Clone())
			local emit = part3.Emit
			emit.Part0 = char["Right Arm"]
			emit.Part1 = part3
			part3.Parent = EFP
			shared.vfx.emit(part3)
			local v6 = object._maid:give(vfx.emitone:Clone())
			v6.Parent = EFP
			PlaceVFX(v6, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
			shared.vfx.emit(v6)
		end

		local function Xamill()
			task.wait(0.2)

			if not (bind and bind.Parent) then
				return
			end

			folder2 = quickWeld({
				FX = vfx.UserRightArm,
				Maid = object._maid,
				P = char["Right Arm"]
			})
			folder = quickWeld({
				FX = vfx.UserLeftArm,
				Maid = object._maid,
				P = char["Left Arm"]
			})
			local trail = folder2.Trail

			for _, effect in pairs(trail:GetDescendants()) do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
					continue
				end

				effect.Enabled = true
			end

			for _, light in pairs(folder2:GetDescendants()) do
				if light:IsA("PointLight") then
					TweenService:Create(light, TweenInfo.new(2, Enum.EasingStyle.Sine), {
						Brightness = 0
					}):Play()
				end
			end

			local trail2 = folder.Trail

			for _, effect in pairs(trail2:GetDescendants()) do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
					continue
				end

				effect.Enabled = true
			end

			shared.vfx.emit(folder.Fx1, folder2.Fx1)
			local v2 = object._maid:give(vfx.StartUpFx:Clone())
			v2.Parent = EFP
			task.spawn(function()
				local lastTime = tick()

				while tick() - lastTime < 0.6 do
					PlaceVFX(v2, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
					task.wait(0.1)
				end
			end)
			shared.vfx.emit(v2.WindBeams)
			task.wait(0.9)

			if not (bind and bind.Parent) then
				return
			end

			for _, trail3 in pairs(folder:GetDescendants()) do
				if trail3:IsA("Trail") then
					trail3.Enabled = false
				end
			end

			for _, trail3 in pairs(folder2:GetDescendants()) do
				if trail3:IsA("Trail") then
					trail3.Enabled = false
				end
			end

			shared.vfx.emit(v2.Charge)
			shared.vfx.emit(folder2.Fx)
			local v3 = object._maid:give(vfx.ChargeN:Clone())

			for _, child in pairs(v3:GetChildren()) do
				PlaceVFX(child, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
			end

			v3.Parent = EFP

			for _, child in v3:GetChildren() do
				local Meshh = require(game.ReplicatedStorage.Resources.Meshh)
				Meshh(child)
			end

			local Part_Icles2 = require(game.ReplicatedStorage.Resources.CosmicUtils.Part_Icles)
			local v4 = object._maid:give(vfx.ChargeF:Clone())

			for _, child in pairs(v4:GetChildren()) do
				PlaceVFX(child, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
			end

			v4.Parent = EFP
			Part_Icles2:AbsoluteEmit(v4)
			local Part_Icles3 = require(game.ReplicatedStorage.Resources.CosmicUtils.Part_Icles)
			Part_Icles3:AbsoluteEmit(v2.Charge.WindBeams)
		end

		task.spawn(function()
			Xamill()
		end)
	end

	task.spawn(FirstEvent)
	wait(5)
	Clean() -- equivalent call inferred; original call site unknown
end

function SkyRip.DashEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
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

	task.delay(8, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local bind = data.bind
	bind.Destroying:Once(function()
		task.delay(0.35, Clean)
	end)

	local function DashEvent()
		local function Dash()
			if not (bind and bind.Parent) then
				return
			end

			local v2 = object._maid:give(vfx.Cfrane2:Clone())

			for _, child in pairs(v2:GetChildren()) do
				PlaceVFX(child, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
			end

			v2.Parent = EFP
			shared.vfx.emit(v2)
			local v3 = object._maid:give(vfx.Cframe1:Clone())
			v3.Parent = EFP
			shared.vfx.emit(v3)
			local folder = object._maid:give(vfx.TRAILBLUE:Clone())
			local TRAILBLUE = folder.TRAILBLUE
			TRAILBLUE.Part0 = char["Right Arm"]
			TRAILBLUE.Part1 = folder
			folder.Parent = EFP
			task.delay(0.3, function()
				for _, trail in pairs(folder:GetDescendants()) do
					if trail:IsA("Trail") then
						trail.Enabled = false
					end
				end
			end)

			if not (bind and bind.Parent) then
				return
			end

			local v4 = object._maid:give(vfx.Dash1:Clone())

			for _, child in pairs(v4:GetChildren()) do
				PlaceVFX(child, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
			end

			v4.Parent = EFP
			shared.vfx.emit(v4)
			task.spawn(function()
				local v5 = CFrame.new(0, 0, -3) * CFrame.Angles(-1.5707963267948966, 0, 0)
				local cframe = CFrame.new(0, 0, 1)
				local children = v2:GetChildren()
				local lastTime = tick()
				local v6 = nil

				while tick() - lastTime < 1 and bind and bind.Parent do
					local cFrame = humanoidRootPart.CFrame

					if cFrame ~= v6 then
						local v7 = cFrame * v5
						v6 = cFrame

						for i = 1, #children do
							children[i]:PivotTo(v7)
						end

						v3:PivotTo(cFrame * cframe)
					end

					local RunService = game:GetService("RunService")
					RunService.RenderStepped:Wait()
				end
			end)
		end

		local function Dash2()
			if not (bind and bind.Parent) then
				return
			end

			local v2 = object._maid:give(vfx.Rush:Clone())
			task.delay(5, function()
				if v2 and v2.Parent then
					v2:Destroy()
				end
			end)

			for _, child in pairs(v2:GetChildren()) do
				PlaceVFX(child, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
			end

			v2.Parent = EFP

			for _, child in v2:GetChildren() do
				if bind and bind.Parent then
					local Meshh = require(game.ReplicatedStorage.Resources.Meshh)
					Meshh(child)
				else
					return
				end
			end

			local v3 = object._maid:give(vfx.RushFx:Clone())
			PlaceVFX(v3, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
			v3.Parent = EFP
			shared.vfx.emit(v3)
			local v5 = object._maid:give(vfx.RushF:Clone())

			for _, child in pairs(v5:GetChildren()) do
				PlaceVFX(child, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
			end

			v5.Parent = EFP
			Part_Icles:AbsoluteEmit(v5)
			Part_Icles:AbsoluteEmit(v3.WindBeams)

			if bind and bind.Parent then
			end
		end

		Dash2()
		task.defer(Dash)
	end

	task.spawn(DashEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function SkyRip.HitEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local primaryPart = data.Victim.PrimaryPart
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

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function HitEvent()
		local function Dast()
			local WAIT_INTERVAL = 0.1
			local v2 = object._maid:give(vfx.hit1:Clone())
			v2.Parent = EFP

			for _, child in pairs(v2:GetChildren()) do
				PlaceVFX(child, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
			end

			shared.vfx.emit(v2)
			task.wait(0.2)
			local v3 = object._maid:give(vfx.auraBlue:Clone())
			local auraBlue = v3.auraBlue
			auraBlue.Part0 = char["Right Arm"]
			auraBlue.Part1 = v3
			auraBlue.Parent = v3
			v3.Parent = EFP
			shared.vfx.emit(v3)
			local folder = object._maid:give(vfx.TRAILBLUE:Clone())
			local TRAILBLUE = folder.TRAILBLUE
			TRAILBLUE.Part0 = char["Right Arm"]
			TRAILBLUE.Part1 = folder
			TRAILBLUE.Parent = folder
			folder.Parent = EFP
			task.wait(WAIT_INTERVAL)
			local folder2 = object._maid:give(vfx.BeamWindfirst:Clone())
			PlaceVFX(folder2, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
			folder2.Parent = EFP
			shared.vfx.emit(folder2)

			for _, beam in ipairs(folder2:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(beam, TweenInfo.new(0.3), {
					Brightness = 1
				}):Play()
			end

			task.wait(0.3)

			for _, beam in ipairs(folder2:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(beam, TweenInfo.new(1), {
					Brightness = 0
				}):Play()
			end

			for _, trail in pairs(folder:GetDescendants()) do
				if trail:IsA("Trail") then
					trail.Enabled = false
				end
			end

			task.wait(WAIT_INTERVAL)
			local folder3 = object._maid:give(vfx.Swirl:Clone())
			folder3.Parent = EFP

			for _, descendant in pairs(folder3:GetDescendants()) do
				if not (descendant:IsA("BasePart") or descendant:IsA("Model")) then
					continue
				end

				PlaceVFX(descendant, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
			end

			shared.vfx.emit(folder3)
			local v4 = object._maid:give(vfx.auraRed:Clone())
			local auraRed = v4.auraRed
			auraRed.Part0 = char["Right Arm"]
			auraRed.Part1 = v4
			auraRed.Parent = v4
			v4.Parent = EFP
			shared.vfx.emit(v4)
			shared.vfx.emit(v4)
			local folder4 = object._maid:give(vfx.TRAILRED:Clone())
			local TRAILRED = folder4.TRAILRED
			TRAILRED.Part0 = char["Left Arm"]
			TRAILRED.Part1 = folder4
			folder4.Parent = EFP

			for _, trail in pairs(folder4:GetDescendants()) do
				if trail:IsA("Trail") then
					trail.Enabled = true
				end
			end

			task.wait(0.4)
			local v5 = object._maid:give(vfx.SLIDE:Clone())
			v5.Parent = EFP

			for _, child in pairs(v5:GetChildren()) do
				PlaceVFX(child, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
			end

			task.spawn(function()
				local lastTime = tick()

				while tick() - lastTime < 1 do
					for _, child in pairs(v5:GetChildren()) do
						if child.Name ~= "wINDSLIDE" then
							continue
						end

						PlaceVFX(child, humanoidRootPart:GetPivot() * CFrame.new(0, 0, -10)) -- equivalent call inferred; original call site unknown
					end

					local RunService = game:GetService("RunService")
					RunService.RenderStepped:Wait()
				end
			end)
			shared.vfx.emit(v5)
			task.wait(0.03)
			local v6 = object._maid:give(vfx.hit2:Clone())
			v6.Parent = EFP

			for _, child in pairs(v6:GetChildren()) do
				PlaceVFX(child, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
			end

			shared.vfx.emit(v6)
			local folder5 = object._maid:give(vfx.BeamWind:Clone())
			PlaceVFX(folder5, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
			folder5.Parent = EFP
			shared.vfx.emit(folder5)

			for _, beam in ipairs(folder5:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(beam, TweenInfo.new(0.3), {
					Brightness = 0.5
				}):Play()
			end

			task.wait(WAIT_INTERVAL)

			for _, beam in ipairs(folder5:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(beam, TweenInfo.new(0.5), {
					Brightness = 0
				}):Play()
			end

			task.wait(0.5)

			for _, trail in pairs(folder4:GetDescendants()) do
				if trail:IsA("Trail") then
					trail.Enabled = false
				end
			end
		end

		local function Xamill()
			local v2 = object._maid:give(vfx.BluePunchF:Clone())
			v2.Parent = EFP

			for _, child in pairs(v2:GetChildren()) do
				PlaceVFX(child, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
			end

			quickWeld({
				FX = vfx.HitHrp,
				Maid = object._maid,
				P = primaryPart
			})
			local v3 = object._maid:give(vfx.HitFx:Clone())
			PlaceVFX(v3, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
			v3.Parent = EFP
			local v4 = object._maid:give(vfx.BluePunchN:Clone())
			v4.Parent = EFP

			for _, child in pairs(v4:GetChildren()) do
				PlaceVFX(child, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
			end

			local _ = v3.Spin
			task.wait(0.6)
			local folder = quickWeld({
				FX = vfx.UserLeftArm,
				Maid = object._maid,
				P = char["Left Arm"]
			})

			for _, trail in pairs(folder:GetDescendants()) do
				if trail:IsA("Trail") then
					trail.Enabled = false
				end
			end

			local v5 = object._maid:give(vfx.ChargeFx:Clone())
			PlaceVFX(v5, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
			v5.Parent = EFP
			local _ = v5.Charge.WindBeams
			local v6 = object._maid:give(vfx.ChargeN2:Clone())

			for _, child in pairs(v6:GetChildren()) do
				PlaceVFX(child, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
			end

			v6.Parent = EFP

			for _, child in v6:GetChildren() do
				local Meshh = require(game.ReplicatedStorage.Resources.Meshh)
				Meshh(child)
			end

			quickWeld({
				FX = vfx.UserHrp,
				Maid = object._maid,
				P = humanoidRootPart
			})
			task.wait(0.25)
			local v7 = object._maid:give(vfx.Hit1Fx:Clone())
			PlaceVFX(v7, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
			v7.Parent = EFP
			local v8 = object._maid:give(vfx.RedPunchN:Clone())

			for _, child in pairs(v8:GetChildren()) do
				PlaceVFX(child, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
			end

			v8.Parent = EFP
			quickWeld({
				FX = vfx.HitHrp,
				Maid = object._maid,
				P = primaryPart
			})
			local v10 = object._maid:give(vfx.RedPunchF:Clone())

			for _, child in pairs(v10:GetChildren()) do
				PlaceVFX(child, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
			end

			v10.Parent = EFP
			Part_Icles:AbsoluteEmit(v10)
			Part_Icles:AbsoluteEmit(v7.Spin)
			local v11 = object._maid:give(vfx.Rush1Fx:Clone())
			PlaceVFX(v11, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
			v11.Parent = EFP
			shared.vfx.emit(v11)
		end

		Dast()
	end

	task.spawn(HitEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function SkyRip.SecondEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local victim = data.Victim
	local _ = victim.PrimaryPart
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

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function SecondEvent()
		local function Blue()
			local parent = object._maid:give(vfx.Smallhitblue:Clone())
			local weld = Instance.new("Weld")
			weld.Part0 = parent.hitblue
			weld.Part1 = char["Right Arm"]
			weld.Parent = parent
			parent.Parent = EFP
			shared.vfx.emit(parent)
		end

		local function Red()
			local parent = object._maid:give(vfx.SmallhitRed:Clone())
			local weld = Instance.new("Weld")
			weld.Part0 = parent.hitred
			weld.Part1 = char["Left Arm"]
			weld.Parent = parent
			parent.Parent = EFP
			parent.Smoke.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
			shared.vfx.emit(parent)
		end

		Blue()
		task.wait(0.15)
		Red()
		task.wait(0.1)
		Blue()
		task.wait(0.1)
		Red()
		local lastTime = tick()
		local v2 = object._maid:give(Instance.new("NumberValue"))
		v2.Value = 0.13
		TweenService:Create(v2, TweenInfo.new(1, Enum.EasingStyle.Quad), {
			Value = 0.08
		}):Play()
		task.delay(0.8, function()
			print("FASTER")
			local v3 = object._maid:give(vfx.curve:Clone())

			for _, child in pairs(v3:GetChildren()) do
				PlaceVFX(child, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
			end

			v3.Parent = EFP
			shared.vfx.emit(v3)
		end)
		local flag = true

		while tick() - lastTime < 2.3 do
			if flag then
				Blue()
				flag = false
			else
				Red()
				flag = true
			end

			task.wait(v2.Value)
		end

		task.spawn(function()
			shared.repfire({
				Effect = "JustMod",
				Mod = "Sky Rip",
				Event = "FinalEvent",
				Char = char,
				Victim = victim
			})
		end)
		task.wait(0.3)
		task.spawn(function()
			shared.repfire({
				Effect = "JustMod",
				Mod = "Sky Rip",
				Event = "ChargeEvent",
				Char = char,
				Victim = victim
			})
		end)
	end

	task.spawn(SecondEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function SkyRip.FinalEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local _ = data.Victim.PrimaryPart
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

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function FinalEvent()
		local v2 = object._maid:give(vfx.hit3:Clone())

		for _, child in pairs(v2:GetChildren()) do
			PlaceVFX(child, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
		end

		v2.Parent = EFP
		shared.vfx.emit(v2)
		local part = object._maid:give(vfx.Emit:Clone())
		local emit = part.Emit
		emit.Part0 = char["Right Arm"]
		emit.Part1 = part
		part.Parent = EFP
		shared.vfx.emit(part)
		local part2 = object._maid:give(vfx.PRE:Clone())
		local PRE = part2.PRE
		PRE.Part0 = char["Right Arm"]
		PRE.Part1 = part2
		part2.Parent = EFP
		shared.vfx.emit(part2)
	end

	task.spawn(FinalEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function SkyRip.ChargeEvent(p)
	local data = p.Data
	local char = data.Char
	local _ = char.HumanoidRootPart
	local _ = char.Humanoid
	local _ = data.Victim.PrimaryPart
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

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function ChargeEvent()
		local v2 = object._maid:give(vfx.auraRed:Clone())
		local auraRed = v2.auraRed
		auraRed.Part0 = char["Right Arm"]
		auraRed.Part1 = v2
		auraRed.Parent = v2
		v2.Parent = EFP
		shared.vfx.emit(v2)
		local v3 = object._maid:give(vfx.RedCharge:Clone())
		local redCharge = v3.RedCharge
		redCharge.Part0 = char["Right Arm"]
		redCharge.Part1 = v3
		redCharge.Parent = v3
		v3.Parent = EFP
	end

	task.spawn(ChargeEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function SkyRip.UppercutEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local _ = data.Victim.PrimaryPart
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

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function UppercutEvent()
		local v2 = object._maid:give(vfx.hit4:Clone())

		for _, child in pairs(v2:GetChildren()) do
			PlaceVFX(child, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
		end

		v2.Parent = EFP
		shared.vfx.emit(v2)
	end

	task.spawn(UppercutEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function SkyRip.SecondChargeEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local victim = data.Victim
	local _ = victim.PrimaryPart
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

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function SecondChargeEvent()
		local v2 = object._maid:give(vfx.Jump:Clone())
		PlaceVFX(v2, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
		v2.Parent = EFP
		shared.vfx.emit(v2)
		task.wait(0.05)
		local v3 = object._maid:give(vfx.Pre:Clone())

		for _, child in pairs(v3:GetChildren()) do
			PlaceVFX(child, humanoidRootPart:GetPivot() * CFrame.new(0, 0, 7)) -- equivalent call inferred; original call site unknown
		end

		v3.Parent = EFP
		shared.vfx.emit(v3)
		task.spawn(function()
			task.wait(0.4)
			shared.repfire({
				Effect = "JustMod",
				Mod = "Sky Rip",
				Event = "BurstEvent",
				Char = char,
				Victim = victim
			})
		end)
	end

	task.spawn(SecondChargeEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function SkyRip.BurstEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local _ = data.Victim.PrimaryPart
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

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function BurstEvent()
		local folder = object._maid:give(vfx.orangeCharge:Clone())

		for _, descendant in pairs(folder:GetDescendants()) do
			if not (descendant:IsA("Model") or descendant:IsA("BasePart")) then
				continue
			end

			PlaceVFX(descendant, humanoidRootPart:GetPivot() * CFrame.new(0, 0, 0)) -- equivalent call inferred; original call site unknown
		end

		folder.Parent = EFP
		local weld = Instance.new("Weld")
		weld.Part0 = char["Left Arm"]
		weld.Part1 = folder.ChargeOrangeEmit1
		weld.Parent = folder.ChargeOrangeEmit1
		shared.vfx.emit(folder.ChargeOrangeEmit1)
		task.wait(0.01)
		local weld2 = Instance.new("Weld")
		weld2.Part0 = char["Left Arm"]
		weld2.Part1 = folder.ChargeOrange
		weld2.Parent = folder.ChargeOrange
		shared.vfx.emit(folder)
		task.wait(0.55)
		local v2 = object._maid:give(vfx.PreDash:Clone())
		PlaceVFX(v2, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown

		for _, model in pairs(v2:GetChildren()) do
			if not model:IsA("Model") then
				continue
			end

			PlaceVFX(model, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
		end

		v2.Parent = EFP
		shared.vfx.emit(v2)
		task.wait(0.2)
		local folder2 = object._maid:give(vfx.Dashflame:Clone())

		for _, descendant in pairs(folder2:GetDescendants()) do
			if not (descendant:IsA("Model") or descendant:IsA("BasePart")) then
				continue
			end

			PlaceVFX(descendant, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
		end

		folder2.Parent = EFP
		shared.vfx.emit(folder2)
		local cframe1 = folder2.Cframe1
		TweenService:Create(cframe1, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			CFrame = cframe1.CFrame * CFrame.new(0, 0, -120)
		}):Play()
		task.wait(0.1)
		local v3 = object._maid:give(vfx.Dash2:Clone())

		for _, child in pairs(v3:GetChildren()) do
			if not (child:IsA("Model") or child:IsA("BasePart")) then
				continue
			end

			PlaceVFX(child, humanoidRootPart:GetPivot() * CFrame.new(0, 0, 0)) -- equivalent call inferred; original call site unknown
		end

		v3.Parent = EFP
		shared.vfx.emit(v3)
	end

	task.spawn(BurstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function SkyRip.FinalLandEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local _ = data.Victim.PrimaryPart
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

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function FinalLandEvent()
		local v2 = object._maid:give(vfx.Last1:Clone())

		for _, child in pairs(v2:GetChildren()) do
			if not (child:IsA("Model") or child:IsA("BasePart")) then
				continue
			end

			PlaceVFX(child, humanoidRootPart:GetPivot() * CFrame.new(0, 0, 0)) -- equivalent call inferred; original call site unknown
		end

		v2.Parent = EFP
		local weld = Instance.new("Weld")
		weld.Part0 = char["Left Arm"]
		weld.Part1 = v2.ChargeOrangeEmit1
		weld.Parent = v2.ChargeOrangeEmit1
		shared.vfx.emit(v2)
		task.wait(0.13)
		local v3 = object._maid:give(vfx.PRe1:Clone())
		PlaceVFX(v3, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
		v3.Parent = EFP
		shared.vfx.emit(v3)
		local v4 = object._maid:give(vfx.PRe2:Clone())
		PlaceVFX(v4, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
		v4.Parent = EFP
		shared.vfx.emit(v4)
	end

	task.spawn(FinalLandEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function SkyRip.BlastEvent(p)
	local data = p.Data
	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local _ = data.Victim.PrimaryPart
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

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function BlastEvent()
		local v2 = object._maid:give(vfx:WaitForChild("SkyRippingFist_CframeTest MeshEmitter"):Clone())
		v2.Parent = EFP
		local v3 = MoonEmitter.new(v2)
		object._maid:giveTask(function()
			v3:Destroy()
		end)
		v3:SetAnchor(char.PrimaryPart.CFrame * CFrame.new(0, 0, -10))
		v3:Play()
		v3:SetTime(10.2)
		local folder = object._maid:give(vfx.Wind2:Clone())
		PlaceVFX(folder, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
		folder.Parent = EFP
		shared.vfx.emit(folder)
		task.delay(0.01, function()
			local folder2 = object._maid:give(vfx.LastImpact:Clone())

			for _, descendant in pairs(folder2:GetDescendants()) do
				if not (descendant:IsA("Model") or descendant:IsA("BasePart")) then
					continue
				end

				PlaceVFX(descendant, humanoidRootPart:GetPivot() * CFrame.new(0, 0, 0)) -- equivalent call inferred; original call site unknown
			end

			folder2.Parent = EFP
			local v4 = object._maid:give(Instance.new("Weld"))
			v4.Part0 = char["Left Arm"]
			v4.Part1 = folder2.FireHand
			v4.Parent = folder2.FireHand
			shared.vfx.emit(folder2)
			local folder3 = object._maid:give(vfx.WindDash2:Clone())
			PlaceVFX(folder3, humanoidRootPart:GetPivot()) -- equivalent call inferred; original call site unknown
			folder3.Parent = EFP
			shared.vfx.emit(folder3)
			local beams = {}

			for _, beam in folder3:GetDescendants() do
				if beam:IsA("Beam") then
					table.insert(beams, beam)
				end
			end

			for i = 1, #beams do
				TweenService:Create(beams[i], TweenInfo.new(0.5), {
					Brightness = 1
				}):Play()
			end

			task.wait(1.5)

			for i = 1, #beams do
				TweenService:Create(beams[i], TweenInfo.new(0.5), {
					Brightness = 0
				}):Play()
			end
		end)
		local beams = {}

		for _, beam in folder:GetDescendants() do
			if beam:IsA("Beam") then
				table.insert(beams, beam)
			end
		end

		for i = 1, #beams do
			TweenService:Create(beams[i], TweenInfo.new(0.5), {
				Brightness = 1
			}):Play()
		end

		task.wait(0.1)

		for i = 1, #beams do
			TweenService:Create(beams[i], TweenInfo.new(1), {
				Brightness = 0
			}):Play()
		end
	end

	task.spawn(BlastEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return SkyRip
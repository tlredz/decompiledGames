local createVector = vector.create
local AwakenRedo = {}
local libraryNew = require(script.Parent.libraryNew)
local playAttachment = libraryNew.PlayAttachment
local maid = libraryNew.Maid
local playTween = libraryNew.PlayTween
local _ = libraryNew.CamShake
local _ = libraryNew.PlayFlipBook
local dtwait = libraryNew.dtwait
local EFP = libraryNew.EFP
local playMesh = libraryNew.PlayMesh
local _ = libraryNew.Impact
local _ = libraryNew.GlassLight
local raiseZIndex = libraryNew.RaiseZIndex
local able = libraryNew.Able
local lifeScale = libraryNew.LifeScale
local quickFX = libraryNew.QuickFX
local _ = libraryNew.QuickWeld
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
local _ = game.Workspace.Camera
local BurstMod = require(script.Parent.BurstMod)

function AwakenRedo.FirstEvent(p)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { game.Workspace.Built, game.Workspace.Map }
	local char = p.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not flag then
			flag = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function FirstEvent()
		local cFrame = humanoidRootPart.CFrame
		local folder = quickFX({
			FX = vfx.FloorAura,
			Maid = object._maid,
			Anchor = cFrame
		})
		folder:ScaleTo(1.5)
		local FX = quickFX({
			FX = vfx.MoreFloor,
			Maid = object._maid,
			Anchor = cFrame
		})
		FX:ScaleTo(1.5)
		able({
			FX = folder,
			On = true
		})
		able({
			FX = FX,
			On = true
		})
		local numberSequence = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0.9),
			NumberSequenceKeypoint.new(1, 1)
		})
		local descendants = folder:GetDescendants()

		for i = 1, #descendants do
			local emitter = descendants[i]

			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.LockedToPart = false
			emitter.Transparency = numberSequence
		end

		task.delay(6.5, function()
			able({
				FX = folder,
				On = false
			})
			able({
				FX = FX,
				On = false
			})
		end)
		task.spawn(function()
			local lastTime = tick()
			local RunService = game:GetService("RunService")
			local renderStepped = RunService.RenderStepped
			local torso = char.Torso

			while tick() - lastTime < 4 do
				if char and char.Parent then
					local raycastResult = workspace:Raycast(torso.Position, createVector(0, -10, 0), raycastParams)

					if raycastResult then
						local position = raycastResult.Position
						folder:PivotTo(CFrame.new(position + createVector(0, 1, 0)))
						FX:PivotTo(CFrame.new(position))
					end

					renderStepped:Wait()
				else
					if flag then
						break
					end

					flag = true
					object._maid:doCleaning()
					break
				end
			end
		end)
		task.wait(0.4)
		local children = vfx.Aura:GetChildren()
		local count = 0
		local v2 = {}

		for i = 1, #children do
			local v3 = children[i]
			local v4 = object._maid:give(v3:Clone())
			local weld = Instance.new("Weld")
			weld.Part0 = v4
			weld.Part1 = char:FindFirstChild(v3.Name)
			weld.Parent = v4
			v4.Parent = EFP
			count += 1
			v2[count] = v4
		end

		dtwait(12)

		for i = 1, count do
			able({
				FX = v2[i],
				On = false
			})
		end
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function AwakenRedo.ScreamEvent(p)
	local char = p.Char
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

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function ScreamEvent()
		local folder = quickFX({
			FX = vfx.Scream,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
		})
		folder:ScaleTo(1.5)
		task.spawn(function()
			for _ = 1, 3 do
				local clone = vfx.dddd:Clone()
				clone:ScaleTo(0.2)
				clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(
					0,
					math.rad((math.random(0, 360))),
					0
				))
				playMesh({
					Model = clone,
					Info = TweenInfo.new(1.6, Enum.EasingStyle.Exponential)
				})
				task.wait(0.25)
			end
		end)
		local clone = vfx.Bubble2:Clone()
		clone:ScaleTo(0.5)
		clone:PivotTo(humanoidRootPart.CFrame)
		playMesh({
			Model = clone,
			Info = TweenInfo.new(0.6, Enum.EasingStyle.Exponential)
		})
		able({
			FX = folder.Part.Attachment2,
			On = false
		})
		playAttachment(folder.Part.Attachment2)
		local FX = quickFX({
			FX = vfx.stuff.Blast,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
		})
		lifeScale({
			FX = FX,
			Scale = 2.5
		})
		FX:ScaleTo(2)
		able({
			FX = FX,
			On = false
		})
		playAttachment(FX)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { game.Workspace.World }

		if game.Workspace:Raycast(humanoidRootPart.Position, createVector(0, -10, 0), raycastParams) then
			for _, descendant in pairs(folder:GetDescendants()) do
				local _ = descendant.Name == "smoke"
			end
		end

		able({
			FX = folder.Part.Attachment,
			On = true
		})
		task.spawn(function()
			local lastTime = tick()

			while tick() - lastTime < 0.8 do
				task.wait(0.1)
			end

			able({
				FX = folder,
				On = false
			})
		end)
	end

	task.spawn(ScreamEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function AwakenRedo.ScreamNextEvent(p)
	local char = p.Char
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

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function ScreamNextEvent()
		local folder = quickFX({
			FX = vfx.Scream,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
		})
		folder:ScaleTo(3.75)
		task.spawn(function()
			for _ = 1, 3 do
				local clone = vfx.dddd:Clone()
				clone:ScaleTo(0.5)
				clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(
					0,
					math.rad((math.random(0, 360))),
					0
				))
				playMesh({
					Model = clone,
					Info = TweenInfo.new(1.6, Enum.EasingStyle.Exponential)
				})
				task.wait(0.25)
			end
		end)
		local folder2 = quickFX({
			FX = vfx.stuff.Temp,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		})
		folder2:ScaleTo(4)
		playAttachment(folder2)
		able({
			FX = folder2,
			On = true
		})
		local clone = vfx.Bubble2:Clone()
		clone:ScaleTo(1.25)
		clone:PivotTo(humanoidRootPart.CFrame)
		playMesh({
			Model = clone,
			Info = TweenInfo.new(0.6, Enum.EasingStyle.Exponential)
		})
		able({
			FX = folder.Part.Attachment2,
			On = false
		})
		playAttachment(folder.Part.Attachment2)
		local FX = quickFX({
			FX = vfx.stuff.Blast,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
		})
		lifeScale({
			FX = FX,
			Scale = 2.5
		})
		FX:ScaleTo(5)
		able({
			FX = FX,
			On = false
		})
		playAttachment(FX)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { game.Workspace.World }

		if game.Workspace:Raycast(humanoidRootPart.Position, createVector(0, -10, 0), raycastParams) then
			for _, descendant in pairs(folder:GetDescendants()) do
				local _ = descendant.Name == "smoke"
			end
		end

		able({
			FX = folder.Part.Attachment,
			On = true
		})
		task.spawn(function()
			local lastTime = tick()

			while tick() - lastTime < 0.8 do
				local clone2 = vfx.WindDecal2:Clone()
				clone2:ScaleTo(10.5)
				clone2:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -3 * clone2:GetScale(), 0) * CFrame.Angles(
					3.141592653589793,
					math.rad((math.random(0, 360))),
					0
				))
				playMesh({
					Model = clone2,
					Info = TweenInfo.new(1, Enum.EasingStyle.Exponential)
				})
				task.wait(0.2)
			end

			able({
				FX = folder2,
				On = false
			})
			local folder3 = quickFX({
				FX = vfx.stuff.Blast,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
			})
			lifeScale({
				FX = folder3,
				Scale = 2.5
			})
			folder3:ScaleTo(5)
			able({
				FX = folder3,
				On = false
			})
			playAttachment(folder3)

			for _, emitter in pairs(folder:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					TweenService:Create(emitter, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
						TimeScale = 0.05
					}):Play()
				end
			end

			for _, emitter in pairs(folder2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					TweenService:Create(emitter, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
						TimeScale = 0.01
					}):Play()
				end
			end

			task.delay(0.05, function()
				for _, emitter in pairs(folder3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						TweenService:Create(emitter, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
							TimeScale = 0.05
						}):Play()
					end
				end
			end)
			able({
				FX = folder,
				On = false
			})
			dtwait(0.3)

			for _, emitter in pairs(folder2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					TweenService:Create(emitter, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
						TimeScale = 1
					}):Play()
				end
			end

			for _, emitter in pairs(folder3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					TweenService:Create(emitter, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
						TimeScale = 1
					}):Play()
				end
			end
		end)
	end

	task.spawn(ScreamNextEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function AwakenRedo.SlamEvent(p)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { game.Workspace.Built, game.Workspace.Map }
	local char = p.Char
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

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function SlamEvent()
		local anchor = p.Anchor
		local clone = vfx.Ring1:Clone()
		clone:ScaleTo(0.5599999999999999)
		clone:PivotTo(anchor * CFrame.new(0, 40, 0) * CFrame.Angles(0, 0, 0))
		playMesh({
			Model = clone,
			Info = TweenInfo.new(0.2, Enum.EasingStyle.Sine)
		})
		local clone2 = vfx.Spikey:Clone()
		clone2:ScaleTo(0.5599999999999999)
		clone2:PivotTo(anchor * CFrame.new(0, 45, 0) * CFrame.Angles(0, 0, 0))
		playMesh({
			Model = clone2,
			Info = TweenInfo.new(0.15, Enum.EasingStyle.Sine)
		})
		local clone3 = vfx.Ring2:Clone()
		clone3:ScaleTo(0.5599999999999999)
		clone3:PivotTo(anchor * CFrame.new(0, 30, 0) * CFrame.Angles(0, 0, 0))
		playMesh({
			Model = clone3,
			Info = TweenInfo.new(0.4, Enum.EasingStyle.Sine)
		})
		local FX = quickFX({
			FX = vfx.Impact,
			Maid = object._maid,
			Anchor = anchor * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
		})
		FX:ScaleTo(FX:GetScale() * 0.7)
		able({
			FX = FX,
			On = false
		})
		playAttachment(FX)
		BurstMod.Spawn({
			origin = anchor.Position,
			amount = 25,
			raycastParams = raycastParams,
			radiusMin = 65,
			radiusMax = 120,
			arcHeightMin = 84,
			arcHeightMax = 192,
			durationMin = 1.2,
			durationMax = 1.9,
			sizeMin = 7.7,
			sizeMax = 12.8,
			templatePart = vfx.CubeTemplate,
			canCollideInFlight = false,
			canCollideOnLand = true,
			anchorOnLand = true,
			copyFloorAppearance = true,
			randomSpawnOrientation = true,
			spinDuringFlight = true,
			spinSpeedMin = 1,
			spinSpeedMax = 2,
			ghostThroughOnLand = true,
			ghostSecondsMin = 0.35,
			ghostSecondsMax = 0.6,
			onLand = function(FX2, position, _, _)
				FX2.Transparency = 1

				if math.random(1, 2) == 1 then
					local v3 = {
						"rbxassetid://72482887095657",
						"rbxassetid://109014520859150",
						"rbxassetid://117658116341223",
						"rbxassetid://82791594163715"
					}
					shared.sfx({
						CFrame = CFrame.new(position),
						SoundId = v3[math.random(1, #v3)],
						Volume = math.random(1, 1.3),
						PlaybackSpeed = random:NextNumber(0.9, 1.1)
					}):Play("")
				end

				shared.repfire({
					Effect = "Ground Crater",
					Seed = math.random(1, 2000000000),
					start = position + createVector(0, 5, 0),
					["end"] = createVector(0, -34, 0),
					amount = 0,
					nosound = true,
					nodebris = true,
					sizemult = 1.3,
					size = 1.3
				})

				if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.PrimaryPart and (position - game.Players.LocalPlayer.Character.PrimaryPart.Position).Magnitude <= 350 and math.random(
					1,
					2
				) == 1 then
					shared.repfire({
						Effect = "Camshake",
						Intensity = 2,
						Last = 0.1
					})
				end

				able({
					FX = FX2,
					On = false
				})
				game.Debris:AddItem(FX2, 1)
			end
		})
		local v3 = quickFX({
			FX = vfx.Plume,
			Maid = object._maid,
			Anchor = anchor * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, -2)
		})
		v3:ScaleTo(0.7)
		playAttachment(v3)
		local folder = quickFX({
			FX = vfx.Plume,
			Maid = object._maid,
			Anchor = anchor * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, -2)
		})
		folder:ScaleTo(1.4)
		raiseZIndex({
			FX = folder,
			Count = 2
		})
		playAttachment(folder)
		task.delay(0.5, function()
			for _, emitter in pairs(folder:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					TweenService:Create(emitter, TweenInfo.new(1, Enum.EasingStyle.Sine), {
						TimeScale = 0.2
					}):Play()
				end
			end
		end)
		local FX3 = quickFX({
			FX = vfx.CoolWave,
			Maid = object._maid,
			Anchor = anchor * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
		})
		lifeScale({
			FX = FX3,
			Scale = 2.5
		})
		FX3:ScaleTo(14)
		able({
			FX = FX3,
			On = false
		})
		playAttachment(FX3)
		local clone4 = vfx.WindDecal1:Clone()
		clone4:ScaleTo(9.799999999999999)
		clone4:PivotTo(anchor * CFrame.new(0, -5 * clone4:GetScale(), 0) * CFrame.Angles(3.141592653589793, 0, 0))
		playMesh({
			Model = clone4,
			Info = TweenInfo.new(2, Enum.EasingStyle.Exponential)
		})
		local clone5 = vfx.Bubble:Clone()
		clone5:ScaleTo(0.9099999999999999)
		clone5:PivotTo(anchor)
		playMesh({
			Model = clone5,
			Info = TweenInfo.new(3, Enum.EasingStyle.Exponential)
		})
		local folder2 = quickFX({
			FX = vfx.OutBeams,
			Maid = object._maid,
			Anchor = anchor * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
		})
		local v5 = object._maid:give(Instance.new("NumberValue"))
		object._maid:giveTask(v5.Changed:Connect(function()
			folder2:PivotTo(folder2:GetPivot() * CFrame.Angles(0, 0.017453292519943295, 0))
			folder2:ScaleTo(v5.Value)
		end))

		for _, beam in pairs(folder2:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			beam.TextureSpeed *= -2
			TweenService:Create(beam, TweenInfo.new(3, Enum.EasingStyle.Sine), {
				TextureSpeed = 0.1
			}):Play()
		end

		v5.Value = 0.1
		TweenService:Create(v5, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			Value = 4.8999999999999995
		}):Play()

		for _, folder3 in pairs(folder2:GetDescendants()) do
			for _, beam in pairs(folder3:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				playTween(beam, {
					Time = 0.4,
					EasingStyle = "Sine",
					Goal = {
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(1, 1)
						})
					}
				})
				game.Debris:AddItem(beam, 0.4)
			end
		end

		local raycastParams2 = RaycastParams.new()
		raycastParams2.FilterType = Enum.RaycastFilterType.Include
		raycastParams2.FilterDescendantsInstances = { game.Workspace.Built, game.Workspace.Map }
		local raycastResult = game.Workspace:Raycast(anchor.Position, createVector(0, -10, 0), raycastParams2)
		local clone6 = vfx.WindDecal1:Clone()

		if raycastResult then
			clone6.Start.Impact252.Color3 = raycastResult.Instance.Color
		end

		clone6:ScaleTo(7)
		clone6:PivotTo(anchor * CFrame.new(0, -5 * clone6:GetScale(), 0) * CFrame.Angles(3.141592653589793, 0, 0))
		playMesh({
			Model = clone6,
			Info = TweenInfo.new(6, Enum.EasingStyle.Exponential)
		})
		local v6 = object._maid:give(Instance.new("BlurEffect"))
		v6.Size *= 0.3
		v6.Parent = game.Lighting
		TweenService:Create(v6, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			Size = 0
		}):Play()
		local clone7 = vfx.HitShockImpact:Clone()
		clone7:ScaleTo(4.199999999999999)
		clone7:PivotTo(anchor * CFrame.new(0, 5 * clone7:GetScale(), 0) * CFrame.Angles(
			1.5707963267948966,
			1.5707963267948966,
			0
		))
		playMesh({
			Model = clone7,
			Info = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
		})
		shared.repfire({
			Effect = "Ground Crater",
			Seed = math.random(1, 2000000000),
			start = anchor.Position,
			["end"] = createVector(0, -14, 0),
			amount = 4,
			nosound = true,
			sizemult = 3.3249999999999997,
			size = 10.5
		})
		shared.repfire({
			Effect = "Ground Crater",
			Seed = math.random(1, 2000000000),
			start = anchor.Position,
			["end"] = createVector(0, -14, 0),
			amount = 5,
			nosound = true,
			sizemult = 1.75,
			size = 0.9799999999999999
		})
		shared.repfire({
			Effect = "Ground Crater",
			Seed = math.random(1, 2000000000),
			start = anchor.Position,
			["end"] = createVector(0, -14, 0),
			amount = 6,
			nosound = true,
			sizemult = 4.725,
			size = 5.6
		})
	end

	task.spawn(SlamEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

local function fn(data)
	local orig = data.orig
	local dir = data.dir
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = data.Whitelist or data.Ignore or { workspace.Live, workspace.Thrown }

	if data.Whitelist then
		raycastParams.FilterType = Enum.RaycastFilterType.Include
	else
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	end

	if data.Blockcast then
		local blockcast = workspace:Blockcast(orig, data.Blockcast, dir, raycastParams)

		if blockcast then
			return blockcast.Instance, blockcast.Position, blockcast.Material, blockcast.Normal
		end
	else
		local raycastResult = workspace:Raycast(orig, dir, raycastParams)

		if raycastResult then
			return raycastResult.Instance, raycastResult.Position, raycastResult.Material, raycastResult.Normal
		end
	end
end

function AwakenRedo.DashEvent(p)
	local char = p.Char
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

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function DashEvent()
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { workspace.Built, workspace.Map }

		local function Dash(value)
			local v2 = value or 1.5
			local v3 = char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
			local raycastResult = workspace:Raycast(v3.Position, createVector(0, -10, 0), raycastParams)

			if not raycastResult then
				return
			end

			local position = raycastResult.Position
			local material = raycastResult.Material
			local color = raycastResult.Instance.Color
			local cframe = CFrame.new(position)
			local orientation, v4, v5 = humanoidRootPart.CFrame:ToOrientation()
			local v6 = 3 * v2

			for _ = 1, math.random(1, 2) do
				local v7 = object._maid:give(Instance.new("Part"))
				v7.CanCollide = false
				v7.Anchored = true
				local v8 = random:NextNumber(0.3, 0.8) * 3 * v6
				v7.Size = Vector3.new(v8, v8, v8)
				v7.Material = material
				v7.Color = color
				v7.CFrame = cframe * CFrame.Angles(
					random:NextNumber(-10, 10),
					random:NextNumber(-10, 10),
					random:NextNumber(-10, 10)
				)
				local v9 = cframe * CFrame.Angles(orientation, v4, v5) * CFrame.new(
					random:NextNumber(-5, 5) * v6,
					random:NextNumber(0, 3) * v6,
					random:NextNumber(5, 15) * v6
				)
				v7.Parent = EFP
				local number = random:NextNumber(0.3, 0.6)
				TweenService:Create(v7, TweenInfo.new(number, Enum.EasingStyle.Quad), {
					Size = createVector(0, 0, 0),
					CFrame = v9 * CFrame.Angles(
						random:NextNumber(-10, 10),
						random:NextNumber(-10, 10),
						random:NextNumber(-10, 10)
					)
				}):Play()
				game.Debris:AddItem(v7, number)
			end

			local v7, v8 = fn({
				orig = humanoidRootPart.Position,
				dir = createVector(0, -25, 0)
			})

			if v7 then
				shared.repfire({
					Effect = "Ground Crater",
					Seed = math.random(1, 2000000000),
					start = v8 + createVector(0, 0.3, 0),
					["end"] = createVector(0, -14, 0),
					amount = 3,
					size = 0.5,
					dontcollide = game.Players:GetPlayerFromCharacter(char),
					nosmoke = true,
					nosound = true
				})
			end

			local FX = quickFX({
				FX = vfx.stuff.Blast2,
				Maid = object._maid,
				Anchor = cframe
			})
			FX:ScaleTo(v2)
			able({
				FX = FX,
				On = false
			})
			playAttachment(FX)
			local v10 = quickFX({
				FX = vfx.stuff.Temp4,
				Maid = object._maid,
				Anchor = cframe
			})
			v10:ScaleTo(v2)
			playAttachment(v10)
		end

		dtwait(0.1)
		Dash(3)
		dtwait(0.65)
		Dash(2)
		dtwait(0.35)
		Dash()
		dtwait(0.3)
		Dash()
		dtwait(0.2)
		Dash()
		dtwait(0.175)
		Dash()
		dtwait(0.1)
		Dash()
	end

	task.spawn(DashEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function AwakenRedo.JumpEvent(p)
	local char = p.Char
	local _ = char.HumanoidRootPart
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

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function JumpEvent()
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { game.Workspace.World }
		local raycastResult = game.Workspace:Raycast(char.Torso.CFrame.Position, createVector(0, -10, 0), raycastParams)

		if raycastResult then
			local FX = quickFX({
				FX = vfx.Jump,
				Maid = object._maid,
				Anchor = CFrame.new(raycastResult.Position)
			})
			lifeScale({
				FX = FX,
				Scale = 2
			})
			playAttachment(FX)
			dtwait(0.15)
		end
	end

	task.spawn(JumpEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function AwakenRedo.FinalSlamEvent(p)
	local char = p.Char
	local _ = char.HumanoidRootPart
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

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function FinalSlamEvent() end

	task.spawn(FinalSlamEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return AwakenRedo
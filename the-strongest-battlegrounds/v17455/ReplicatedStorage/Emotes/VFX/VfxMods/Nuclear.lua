local createVector = vector.create
local Nuclear = {}
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
local quickWeld = libraryNew.QuickWeld
local _ = libraryNew.Yield
local _ = libraryNew.ProcessPart
local _ = libraryNew.WeldObject
local _ = libraryNew.Bezier
local _ = libraryNew.EditableMeshShader
local vfx = script.vfx
local class = {}
class.__index = class
local random = Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local camera = game.Workspace.Camera
local v = false

local function fn(p)
	if p == 0 then
		workspace:SetAttribute("MapInvis", nil)

		for _, part in pairs(workspace.Map:GetDescendants()) do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = 0
			end
		end
	else
		v = true

		for _, part in pairs(workspace.Thrown:GetDescendants()) do
			if not (tostring(part) == "Debris" and part:IsA("BasePart") and (game.Players.LocalPlayer.Character.PrimaryPart.Position - part.Position).Magnitude <= 170) then
				continue
			end

			part.CFrame = CFrame.new(40000, 40000, 40000)
		end

		for _, part in pairs(workspace.Map:GetDescendants()) do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = 1
			end
		end
	end
end

local function getCharEFP(char)
	if not char then
		return EFP
	end

	local name = "EFPNUCLEAR_" .. char.Name
	local v3 = EFP:FindFirstChild(name)

	if not v3 then
		v3 = Instance.new("Folder")
		v3.Name = name
		v3.Parent = EFP
	end

	local v4 = (v3:GetAttribute("_killToken") or 0) + 1
	v3:SetAttribute("_killToken", v4)
	task.delay(30, function()
		if v3 and v3.Parent and v3:GetAttribute("_killToken") == v4 then
			v3:Destroy()
		end
	end)
	return v3
end

local PortalSpawner = require(script.Parent.PortalSpawner)
local ZLib = require(game.ReplicatedStorage.Resources.CosmicUtils.ZLib)
local mesh_emit = require(game.ReplicatedStorage.Emotes.VFX.VfxMods.mesh_emit)

local function fn2(p, tweenInfo, p2: number)
	local model = Instance.new("Model", workspace.Thrown)
	p.Parent = model
	game.Debris:AddItem(model, 5)
	local numberValue = Instance.new("NumberValue", model)
	numberValue:GetPropertyChangedSignal("Value"):Connect(function()
		model:ScaleTo(numberValue.Value)
	end)
	local TweenService2 = game:GetService("TweenService")
	TweenService2:Create(numberValue, tweenInfo, {
		Value = p2
	}):Play()
end

local function fn3(root, data, p)
	local clone = root:Clone()
	clone.Parent = workspace.Thrown
	local v2 = p or clone.CFrame

	for _, beam in clone:GetDescendants() do
		if not beam:IsA("Beam") then
			continue
		end

		beam.Enabled = true
		local v3 = {
			Width0 = beam.Width0,
			Width1 = beam.Width1,
			TextureSpeed = beam.TextureSpeed,
			Brightness = beam.Brightness,
			LightEmission = beam.LightEmission
		}
		local TweenService2 = game:GetService("TweenService")
		local tween = TweenService2:Create(
			beam,
			TweenInfo.new(data.Duration, Enum.EasingStyle[data.Easing], Enum.EasingDirection[data.EasingDirection]),
			data.Properties
		)
		tween:Play()
		local v4 = beam
		tween.Completed:Once(function()
			v4.Enabled = false

			for k, v6 in v3 do
				v4[k] = v6
			end
		end)
	end

	local TweenService2 = game:GetService("TweenService")
	TweenService2:Create(
		clone,
		TweenInfo.new(data.Duration, Enum.EasingStyle[data.Easing], Enum.EasingDirection[data.EasingDirection]),
		{
			Position = (v2 * data.Offset).Position
		}
	):Play()
	local total = 0
	local heartbeatConnection = nil
	local RunService = game:GetService("RunService")
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		clone.CFrame *= CFrame.Angles(0, 0, (math.rad(data.RotationSpeed)))
		total += dt

		if total > 5 and heartbeatConnection then
			heartbeatConnection:Disconnect()
		end
	end)
	game.Debris:AddItem(clone, 5)
	return clone
end

local MoonEmitter = require(game.ReplicatedStorage.Resources.MoonEmitter)
local Crater = require(game.ReplicatedStorage.Resources.CosmicUtils.ZLib.Crater)
local filterDescendantsInstances = { game.Workspace.Map, game.Workspace.Built }
local v3 = {
	"https://assetgame.roblox.com/asset/?id=83828304622515&assetName=0134",
	"https://assetgame.roblox.com/asset/?id=103666199441235&assetName=0135",
	"https://assetgame.roblox.com/asset/?id=107039165912486&assetName=0136",
	"https://assetgame.roblox.com/asset/?id=85341884749537&assetName=0137",
	"https://assetgame.roblox.com/asset/?id=90666697688210&assetName=0138",
	"https://assetgame.roblox.com/asset/?id=102920664048244&assetName=0139",
	"https://assetgame.roblox.com/asset/?id=131996231376690&assetName=0140",
	"https://assetgame.roblox.com/asset/?id=90324575889361&assetName=0141",
	"https://assetgame.roblox.com/asset/?id=125981207131483&assetName=0142",
	"https://assetgame.roblox.com/asset/?id=116659607211929&assetName=0143",
	"https://assetgame.roblox.com/asset/?id=90933758948117&assetName=0144",
	"https://assetgame.roblox.com/asset/?id=127450234635554&assetName=0145",
	"https://assetgame.roblox.com/asset/?id=105602570820604&assetName=0146",
	"https://assetgame.roblox.com/asset/?id=98756122841714&assetName=0147",
	"https://assetgame.roblox.com/asset/?id=134978022502817&assetName=0148",
	"https://assetgame.roblox.com/asset/?id=102402509074991&assetName=0149",
	"https://assetgame.roblox.com/asset/?id=77926947495133&assetName=0150"
}
local RunService = game:GetService("RunService")

local function BuildScaleCache(folder)
	local pivot = folder:GetPivot()
	local parts = {}
	local meshes = {}
	local particles = {}

	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			local objectSpace = pivot:ToObjectSpace(descendant.CFrame)
			parts[#parts + 1] = {
				inst = descendant,
				size = descendant.Size,
				offsetPos = objectSpace.Position,
				offsetRot = objectSpace - objectSpace.Position
			}
		elseif descendant:IsA("SpecialMesh") then
			meshes[#meshes + 1] = {
				inst = descendant,
				scale = descendant.Scale
			}
		elseif descendant:IsA("ParticleEmitter") then
			local keypoints = descendant.Size.Keypoints
			local sizeKps = table.create(#keypoints)

			for i = 1, #keypoints do
				local keypoint = keypoints[i]
				sizeKps[i] = {
					t = keypoint.Time,
					v = keypoint.Value,
					e = keypoint.Envelope
				}
			end

			local speed = descendant.Speed
			particles[#particles + 1] = {
				inst = descendant,
				sizeKps = sizeKps,
				speedMin = speed.Min,
				speedMax = speed.Max
			}
		end
	end

	return {
		parts = parts,
		meshes = meshes,
		particles = particles
	}
end

local function ApplyCachedScale(data, p, pivot)
	for i = 1, #data.parts do
		local part = data.parts[i]
		local inst = part.inst
		inst.Size = part.size * p
		inst.CFrame = pivot * CFrame.new(part.offsetPos * p) * part.offsetRot
	end

	for i = 1, #data.meshes do
		local mesh = data.meshes[i]
		mesh.inst.Scale = mesh.scale * p
	end

	local particles = data.particles

	if particles then
		for i = 1, #particles do
			local particle = particles[i]
			local sizeKps = particle.sizeKps
			local numberSequenceKeypoints = table.create(#sizeKps)

			for i2 = 1, #sizeKps do
				local sizeKp = sizeKps[i2]
				numberSequenceKeypoints[i2] = NumberSequenceKeypoint.new(sizeKp.t, sizeKp.v * p, sizeKp.e * p)
			end

			particle.inst.Size = NumberSequence.new(numberSequenceKeypoints)
			particle.inst.Speed = NumberRange.new(particle.speedMin * p, particle.speedMax * p)
		end
	end
end

local function RunLerpLoop(value, callback, callback2, callback3, p)
	local v4

	if type(value) == "number" then
		v4 = value > 0
	else
		v4 = false
	end

	assert(v4, "duration must be > 0")
	assert(type(callback) == "function", "easingFn must be a function")
	assert(type(callback2) == "function", "onStep must be a function")
	local heartbeatConnection = nil
	local flag = false
	local total = 0

	if p then
		local v5 = 0
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			if flag then
				heartbeatConnection:Disconnect()
				return
			end

			v5 += dt

			while v5 >= 0.016666666666666666 do
				v5 -= 0.016666666666666666
				total += 0.016666666666666666
				local v6 = math.clamp(total / value, 0, 1)
				callback2(callback(v6), v6)

				if not (v6 >= 1) then
					continue
				end

				heartbeatConnection:Disconnect()

				if callback3 then
					callback3()
				end

				break
			end
		end)
	else
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			if flag then
				heartbeatConnection:Disconnect()
				return
			end

			total += dt
			local v5 = math.clamp(total / value, 0, 1)
			callback2(callback(v5), v5)

			if v5 >= 1 then
				heartbeatConnection:Disconnect()

				if callback3 then
					callback3()
				end
			end
		end)
	end

	return function()
		flag = true

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
		end
	end
end

function Nuclear.FirstEvent(p)
	local data = p.Data
	local char = data.Char
	local charEFP = getCharEFP(char)
	local bind = data.Bind
	local hitbox = data.hitbox
	local holdBind = data.HoldBind
	local portalHoldExtra = data.PortalHoldExtra or 1
	local portalCloseDelay = data.PortalCloseDelay or 0.7
	local portalMoveEndDelay = data.PortalMoveEndDelay or portalCloseDelay + 0.35
	local portalReleaseGlideDuration = data.PortalReleaseGlideDuration or 0.2
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local victim = data.Victim

	if victim then
		local _ = victim.HumanoidRootPart
	end

	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v4 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v4 then
			v4 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function FirstEvent()
		task.delay(0.1, function()
			local folder = object._maid:give(vfx["4"]:Clone())

			for _, emitter in pairs(folder:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Rate *= 5
				local lifetime = emitter.Lifetime
				emitter.Lifetime = NumberRange.new(lifetime.Min / 5, lifetime.Max / 5)
			end

			task.spawn(function()
				local Effectv2b2 = require(script.Effectv2b2)
				local folder2 = Effectv2b2:Attack(
					humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 2.5, 0),
					0.5,
					nil,
					holdBind
				)

				for _, light in pairs(folder2:GetDescendants()) do
					if light:IsA("PointLight") then
						TweenService:Create(light, TweenInfo.new(1, Enum.EasingStyle.Sine), {
							Brightness = 0
						}):Play()
					end
				end

				folder2:FindFirstChild("Spheres"):Destroy()
			end)
			task.spawn(function()
				task.wait(0.3)

				if not (bind and bind.Parent) then
					return
				end

				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = {
					game.Workspace.Live,
					game.Workspace.Thrown,
					game.Workspace.Map.Benchs,
					game.Workspace.Map.Trash
				}
				local raycastResult = game.Workspace:Raycast(
					char.Torso.Position,
					createVector(0, -50, 0),
					raycastParams
				)
				local position = char.PrimaryPart.Position - Vector3.new(0, char.PrimaryPart.Size.Y * 1.5, 0)

				if raycastResult then
					position = raycastResult.Position
				end

				local spawnportal = PortalSpawner.Spawnportal({
					Scale = 0.7,
					Lightning = true,
					TimeScale = 3,
					Bind = holdBind,
					Anchor = CFrame.new(position + createVector(0, 0.1, 0))
				})
				local lastTime = tick()
				local findVictim = nil
				local v5 = portalCloseDelay
				local v6 = portalMoveEndDelay + 0.1
				local v7 = nil
				local v8 = nil

				local function PortalMoveOpen()
					return holdBind and holdBind.Parent and (holdBind:GetAttribute("Pending") == true or holdBind:GetAttribute("Holding") == true)
				end

				local function PortalMoveHolding()
					return holdBind and holdBind.Parent and holdBind:GetAttribute("Holding") == true
				end

				local function FoundVictim()
					if not (bind and bind.Parent) then
						PortalSpawner.ClosePortal(spawnportal)
						return
					end

					if not findVictim or not findVictim.Value or not findVictim.Value.PrimaryPart or v8 then
						PortalSpawner.ClosePortal(spawnportal)
						return
					end

					local cframe = CFrame.new(findVictim.Value:GetPivot().Position) * CFrame.new(
						0,
						-findVictim.Value.PrimaryPart.Size.Y * 1.45,
						0
					)
					local raycastResult2 = game.Workspace:Raycast(
						cframe.Position + createVector(0, 1, 0),
						createVector(0, -11, 0),
						raycastParams
					)

					if raycastResult2 then
						cframe = CFrame.new(raycastResult2.Position + createVector(0, 0.1, 0))
					end

					v8 = true
					TweenService:Create(spawnportal.PrimaryPart, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
						CFrame = cframe
					}):Play()
					task.delay(0.5, function()
						PortalSpawner.ClosePortal(spawnportal)
					end)
				end

				while tick() - lastTime < v6 do
					if holdBind and holdBind.Parent and holdBind:GetAttribute("Holding") == true then
						v6 = math.max(v6, portalMoveEndDelay + portalHoldExtra + portalReleaseGlideDuration + 0.1)
					end

					findVictim = char:FindFirstChild("FindVictim")

					if findVictim and bind.Parent then
						FoundVictim()
						break
					end

					if hitbox and hitbox.Parent then
						local Y = humanoidRootPart.Position.Y
						local raycastResult2 = game.Workspace:Raycast(
							hitbox.Position,
							createVector(0, -10, 0),
							raycastParams
						)

						if raycastResult2 and spawnportal and spawnportal.Parent and spawnportal.PrimaryPart then
							if math.abs(Y - raycastResult2.Position.Y) > 0.1 then
								spawnportal:PivotTo(CFrame.new(raycastResult2.Position + createVector(0, 0.1, 0)))
							end

							local _ = raycastResult2.Position.Y
						end
					end

					if v5 <= tick() - lastTime and (not holdBind or not holdBind.Parent or holdBind:GetAttribute("Pending") ~= true and holdBind:GetAttribute("Holding") ~= true) and not v7 then
						PortalSpawner.ClosePortal(spawnportal)
						v7 = true
					end

					dtwait(0.01)
				end

				if not (v8 or v7) then
					findVictim = char:FindFirstChild("FindVictim")
					FoundVictim()
				end
			end)
			local v5 = object._maid:give(Instance.new("NumberValue"))
			folder:ScaleTo(0.001)
			v5.Value = folder:GetScale()
			TweenService:Create(v5, TweenInfo.new(1.5, Enum.EasingStyle.Bounce), {
				Value = 3
			}):Play()
			object._maid:giveTask(v5.Changed:Connect(function()
				folder:ScaleTo(v5.Value)
			end))
			folder.Parent = charEFP
			task.delay(0.15, function()
				if not (bind and bind.Parent) then
					return
				end

				local folder2 = quickFX({
					FX = vfx.umok2,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * CFrame.new(0, 1, 0)
				})
				local v6 = object._maid:give(Instance.new("NumberValue"))
				v6.Value = 0.1
				local v7 = nil

				local function updatescale()
					local descendants = v7

					if not descendants then
						descendants = {}

						for _, descendant in pairs(folder2:GetDescendants()) do
							if descendant:HasTag("MeshEmitter") then
								table.insert(descendants, descendant)
							end
						end

						v7 = descendants
					end

					for _, v8 in pairs(descendants) do
						local ogsize = v8:GetAttribute("ogsize")

						if not ogsize then
							ogsize = v8:GetAttribute("MaxSize")
							v8:SetAttribute("ogsize", ogsize)
						end

						v8:SetAttribute("MaxSize", NumberRange.new(ogsize.Min * v6.Value, ogsize.Max * v6.Value))
					end
				end

				updatescale()
				object._maid:giveTask(v6.Changed:Connect(updatescale))
				TweenService:Create(v6, TweenInfo.new(0.3, Enum.EasingStyle.Bounce), {
					Value = 1
				}):Play()
				able({
					FX = folder2,
					On = true
				})
				task.wait(0.6)

				while holdBind.Parent do
					wait()
				end

				able({
					FX = folder2,
					On = false
				})
			end)
			task.delay(0.8, function()
				if not (bind and bind.Parent) then
					return
				end

				while holdBind.Parent do
					wait()
				end

				quickFX({
					FX = vfx.Floor,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.4, 0)
				})
				able({
					FX = folder,
					On = false
				})
				game.Debris:AddItem(folder, 0.3)
			end)
			local v6 = object._maid:give(Instance.new("NumberValue"))
			v6.Value = 0.3
			TweenService:Create(v6, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				Value = 0.1
			}):Play()
			task.spawn(function()
				local lastTime = tick()

				while tick() - lastTime < 4 do
					if bind and bind.Parent then
						folder:PivotTo(char["Right Arm"].CFrame * CFrame.new(0, -1 * folder:GetScale(), 0) * CFrame.new(
							random:NextNumber(-v6.Value, v6.Value),
							random:NextNumber(-v6.Value, v6.Value),
							random:NextNumber(-v6.Value, v6.Value)
						))
						dtwait(0.01)
					else
						folder:Destroy()
						break
					end
				end
			end)
		end)
		task.wait(0.6)

		if not (bind and bind.Parent) then
			return Clean()
		end

		local findVictim = char:WaitForChild("FindVictim", 3)

		if not findVictim then
			return
		end

		if findVictim then
			victim = findVictim.Value
		end

		if not findVictim then
			return
		end

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances

		if game.Workspace:Raycast(victim.Torso.Position, createVector(0, -50, 0), raycastParams) then
			task.wait(0.3)

			if not (bind and bind.Parent) then
				return Clean()
			end

			local spawnportal = PortalSpawner.Spawnportal({
				TimeScale = 0.3,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.4, -5.5),
				Scale = 0.8
			})
			task.delay(0.35, function()
				PortalSpawner.ClosePortal(spawnportal, 0.5)
			end)
			local folder = quickFX({
				FX = vfx.Spin,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame
			})
			local lastTime = tick()
			local orientation, v5, v6 = humanoidRootPart.CFrame:ToOrientation()
			task.spawn(function()
				while tick() - lastTime < 4 do
					if bind and bind.Parent then
						folder:PivotTo(CFrame.new(victim.Torso.Position) * CFrame.Angles(orientation, v5, v6))
						dtwait(0.01)
					else
						return Clean()
					end
				end
			end)

			for _, emitter in pairs(folder:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local rotSpeed = emitter.RotSpeed
				emitter.RotSpeed = NumberRange.new(rotSpeed.Min * 1, rotSpeed.Max * 1)
			end

			task.wait(0.5)

			while holdBind.Parent do
				wait()
			end

			able({
				FX = folder,
				On = false
			})
		end
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function Nuclear.HitEvent(p)
	local data = p.Data
	local char = data.Char
	local charEFP = getCharEFP(char)
	local bind = data.Bind
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local victim = data.Victim

	if victim then
		local _ = victim.HumanoidRootPart
	end

	local v4 = game.Players.LocalPlayer.Character == data.Char or game.Players.LocalPlayer.Character == data.Victim
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v5 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v5 then
			v5 = true
			object._maid:doCleaning()
		end
	end

	task.delay(35, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function HitEvent()
		local v6 = object._maid:give(vfx["MakeitNew MeshEmitter"]:Clone())
		v6.Parent = charEFP

		if not v4 then
			v6.VignetteUI:Destroy()
		end

		game.Debris:AddItem(v6, 30)
		local v7 = MoonEmitter.new(v6)
		v7:SetAnchor(humanoidRootPart.CFrame * v6:GetAttribute("Offset"):Inverse())
		v7:Play()
		v7:SetTime(1.8333333333333333)

		if not v4 then
			task.delay(9.5, function()
				v7:Stop()
				v7:Destroy()
			end)
		end

		if v4 then
			local v8 = object._maid:give(Instance.new("SunRaysEffect"))
			v8.Parent = game.Lighting
			v7:AssignExternal("SunRays", v8)
			game.Debris:AddItem(v8, 25)
			local parent = object._maid:give(Instance.new("ScreenGui"))
			parent.Parent = game.Players.LocalPlayer.PlayerGui
			parent.IgnoreGuiInset = true
			local v10 = object._maid:give(Instance.new("Frame"))
			v10.Parent = parent
			v10.Size = UDim2.new(1, 0, 1, 0)
			v7:AssignExternal("Screen Cover", v10)
			game.Debris:AddItem(parent, 25)
			local v11 = object._maid:give(Instance.new("BloomEffect"))
			v11.Parent = game.Lighting
			game.Debris:AddItem(v11, 35)
			local v12 = object._maid:give(Instance.new("DepthOfFieldEffect"))
			v12.Parent = game.Lighting
			v7:AssignExternal("DepthOfField", v12)
			game.Debris:AddItem(v12, 25)
			object._maid:giveTask(v6:GetAttributeChangedSignal("Space"):Connect(function()
				v7:AssignExternal("Lighting", game.Lighting)
			end))
			local clockTime = game.Lighting.ClockTime
			object._maid:giveTask(v6:GetAttributeChangedSignal("Back"):Connect(function()
				v7:StopTime()
				game.Lighting.ClockTime = clockTime
			end))
			object._maid:giveTask(function()
				v7:Destroy()
			end)
			task.delay(13, function()
				if not (bind and bind.Parent) then
					return Clean()
				end

				v7:AssignExternal("Lighting", v12)
				task.wait(1.5)

				if bind and bind.Parent then
					return
				else
					return Clean()
				end
			end)
			object._maid:giveTask(bind.Destroying:Connect(function()
				v7:AssignExternal("Lighting", game.Workspace)
				Clean() -- equivalent call inferred; original call site unknown
			end))
		end

		local v8 = quickFX({
			FX = vfx.hitfloor,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 5, -3) * CFrame.Angles(1.5707963267948966, 0, 0)
		})
		v8:ScaleTo(1)
		playAttachment(v8)
		local folder = object._maid:give(vfx.Activated:Clone())
		folder:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 5, -5))
		TweenService:Create(folder.PrimaryPart, TweenInfo.new(2, Enum.EasingStyle.Sine), {
			CFrame = folder:GetPivot() * CFrame.new(0, 80, 0)
		}):Play()

		for _, emitter in pairs(folder:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Rate *= 5
			local lifetime = emitter.Lifetime
			emitter.Lifetime = NumberRange.new(lifetime.Min / 5, lifetime.Max / 5)
		end

		folder.Parent = charEFP
		task.delay(0.5, function()
			able({
				FX = folder,
				On = false
			})
		end)
	end

	task.spawn(HitEvent)
	wait(35)
	Clean() -- equivalent call inferred; original call site unknown
end

local function RaycastDown(p)
	local raycastResult = workspace:Raycast(p + createVector(0, 200, 0), createVector(0, -500, 0))

	if raycastResult then
		return raycastResult.Position.Y
	end

	return nil
end

local function GenerateCubicPoints(cframe, p)
	local v4 = cframe.Position + Vector3.new(math.random(-0.1, 0.1), 0, math.random(-0.1, 0.1))
	local orientation, v5, v6 = cframe:ToOrientation()
	local v7 = CFrame.new((Vector3.new(
		v4.X + math.random(-0.1, 0.1),
		v4.Y + random:NextNumber(-0.1, 0.1),
		v4.Z + math.random(-0.1, 0.1)
	))) * CFrame.Angles(orientation, v5, v6) * CFrame.new(0, 0, 7).Position
	return
		v4,
		v7,
		CFrame.new((Vector3.new(v7.X + math.random(-0.1, 0.1), v7.Y, v7.Z + math.random(-0.1, 0.1)))) * CFrame.Angles(
			orientation,
			v5,
			v6
		) * CFrame.new(0, 0, 0).Position,
		p
end

function cubicBezier(p, p2, p3, p4, p5)
	return (1 - p) ^ 3 * p2 + 3 * (1 - p) ^ 2 * p * p3 + 3 * (1 - p) * p ^ 2 * p4 + p ^ 3 * p5
end

function Nuclear.PreEvent(p)
	local data = p.Data
	local char = data.Char
	local charEFP = getCharEFP(char)
	local bind = data.Bind
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local victim = data.Victim

	if victim then
		local _ = victim.HumanoidRootPart
	end

	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v4 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v4 then
			v4 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function PreEvent()
		local v5 = {
			{
				"rbxassetid://126345619062862",
				"rbxassetid://99303886332474",
				"rbxassetid://121637092604416",
				"rbxassetid://113029456950748",
				"rbxassetid://138572874693768",
				"rbxassetid://92607920533530",
				"rbxassetid://138142224621278",
				"rbxassetid://120065192728444",
				"rbxassetid://70411827948913",
				"rbxassetid://71491448109970",
				"rbxassetid://85524876848679",
				"rbxassetid://84060367679631",
				"rbxassetid://98004646393019",
				"rbxassetid://139881862115187",
				"rbxassetid://75646293133592",
				"rbxassetid://82260360973815",
				"rbxassetid://80749449158947",
				"rbxassetid://75562819739007",
				"rbxassetid://78560402198235",
				"rbxassetid://134122785594190",
				"rbxassetid://122238912891286",
				"rbxassetid://83757815885857"
			},
			{
				"rbxassetid://79659437605905",
				"rbxassetid://118290359008121",
				"rbxassetid://93612183410156",
				"rbxassetid://79503345167950",
				"rbxassetid://75259404133000",
				"rbxassetid://123404852590285",
				"rbxassetid://89121436722950",
				"rbxassetid://122757847245395",
				"rbxassetid://110337433498526",
				"rbxassetid://82000074938026",
				"rbxassetid://96669627548575",
				"rbxassetid://113917452449518",
				"rbxassetid://133381373610534",
				"rbxassetid://138651759212140",
				"rbxassetid://120620024709807",
				"rbxassetid://95006064285568",
				"rbxassetid://135806306899349",
				"rbxassetid://134049946195990",
				"rbxassetid://77590421805120",
				"rbxassetid://71393365951006",
				"rbxassetid://94079431186519"
			}
		}
		local rightArm = char["Right Arm"]
		local v6 = rightArm.CFrame * CFrame.new(0, -1, 0)
		task.delay(0.1, function()
			local FX = quickWeld({
				FX = vfx.CoolSuckStar,
				Maid = object._maid,
				P = rightArm,
				C0 = CFrame.new(0, 1, 0)
			})
			able({
				FX = FX,
				On = false
			})
			raiseZIndex({
				FX = FX,
				Count = 1
			})
			lifeScale({
				FX = FX,
				Scale = 1.5
			})
			FX:ScaleTo(0.25)
			playAttachment(FX)
		end)
		task.spawn(function()
			local FX = object._maid:give(vfx.ArmThing.Attachment:Clone())
			FX.Parent = rightArm
			able({
				FX = FX,
				On = true
			})
			local folder = object._maid:give(vfx.Spinog.Spin:Clone())
			folder.Parent = rightArm
			local FX2 = quickFX({
				FX = vfx.GoundSMoke,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
			})
			local FX3 = quickWeld({
				FX = vfx.StuffGoinIn,
				Maid = object._maid,
				P = rightArm
			})
			task.spawn(function()
				task.spawn(function()
					local lastTime = tick()

					while tick() - lastTime < 0.5 do
						if bind and bind.Parent then
							task.spawn(function()
								for _ = 1, 3 do
									v6 = rightArm.CFrame * CFrame.new(0, -1, 0)
									local clone = vfx.Swirlnormalfaceorigin:Clone()
									clone:PivotTo(v6 * CFrame.new(0, 0, 0) * CFrame.Angles(
										math.rad((math.random(-180, 180))),
										math.rad((math.random(-180, 180))),
										(math.rad((math.random(-180, 180))))
									))
									clone.Mesh.Scale *= 1
									clone.Parent = charEFP
									game.Debris:AddItem(clone, 10)
									random:NextNumber(3, 6)
									random:NextNumber(0.0075, 0.015)
									local _ = random:NextInteger(1, 2) == 1
									local v11 = v5[math.random(1, 2)]
									task.spawn(function()
										for i = 1, #v11, 2 do
											local texture = v11[i]

											if texture then
												clone.Decal.Texture = texture
											end

											dtwait(0.03)
										end

										clone:Destroy()
									end)
									local v13 = clone
									task.delay(0.1, function()
										TweenService:Create(
											v13.Decal,
											TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
											{
												Color3 = Color3.fromRGB(129, 55, 213)
											}
										):Play()
									end)
								end
							end)
							task.wait(0.1)
						else
							return Clean()
						end
					end
				end)
				TimeSCale = 1
				start = tick()
				local count = 0
				local clone = vfx.Specs:Clone()
				clone.Parent = charEFP
				clone:PivotTo(v6 * CFrame.Angles(0, 1.5707963267948966, 0))
				able({
					FX = clone,
					On = false
				})
				local parts = {}
				local v10 = object._maid:give(Instance.new("NumberValue"))
				v10.Value = 1.5
				task.spawn(function()
					local v11 = {}

					for _, descendant in pairs(folder:GetDescendants()) do
						local maxSize = descendant:GetAttribute("MaxSize")

						if maxSize then
							v11[descendant] = {
								Size = maxSize,
								Rate = descendant:GetAttribute("Rate"),
								Lifetime = descendant:GetAttribute("Lifetime")
							}
						end
					end

					v10.Changed:Connect(function()
						for k, v12 in pairs(v11) do
							k:SetAttribute(
								"MaxSize",
								NumberRange.new(v12.Size.Min * v10.Value, v12.Size.Max * v10.Value)
							)
						end

						clone:ScaleTo(v10.Value)
					end)
					task.wait(1)

					if not (bind and bind.Parent) then
						return Clean()
					end

					task.delay(0.5, function()
						if not (bind and bind.Parent) then
							return Clean()
						end

						local FX4 = object._maid:give(vfx.Glow:Clone())
						FX4:PivotTo(humanoidRootPart.CFrame * vfx.Glow:GetAttribute("Offset"):Inverse())
						FX4.Parent = charEFP
						able({
							FX = FX4,
							On = false
						})
						task.spawn(function()
							local inverse = vfx.Glow:GetAttribute("Offset"):Inverse()
							local lastTime = tick()

							while tick() - lastTime < 1 do
								FX4:PivotTo(humanoidRootPart.CFrame * inverse * CFrame.new(
									random:NextNumber(-0.5, 0.5),
									random:NextNumber(-0.5, 0.5),
									random:NextNumber(-0.5, 0.5)
								))
								task.wait(0.01)
							end
						end)
						task.wait(0.5)
						able({
							FX = FX4,
							On = false
						})
					end)
					able({
						FX = FX3,
						On = false
					})

					for _, v12 in pairs(parts) do
						v12:Destroy()
					end

					lifeScale({
						FX = folder,
						Scale = 0.5
					})

					for _, objectValue in pairs(folder:GetDescendants()) do
						if objectValue:IsA("ObjectValue") then
							objectValue:SetAttribute("Rate", objectValue:GetAttribute("Rate") * 2)
						end
					end

					v10.Value = 0.1
					TweenService:Create(v10, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
						Value = 3
					}):Play()
					task.wait(0.3)
					TweenService:Create(v10, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {
						Value = 7
					}):Play()
				end)
				local flag = nil

				local function WindLines(p2)
					local clone2

					if flag then
						clone2 = vfx.WindSpinning:Clone()
						flag = false
					else
						clone2 = vfx.WindSpinning2:Clone()
						p2 *= 0.5
					end

					clone2:ScaleTo(Random.new():NextNumber(0.7, 0.9) * 0.5)
					local part = clone2.Part
					local weld = Instance.new("Weld")
					weld.Part0 = clone.PrimaryPart
					weld.Part1 = part
					weld.C0 = CFrame.new(
						0,
						-0.5,
						0,
						1,
						-9.30575428e-25,
						0,
						-9.30575428e-25,
						1,
						-8.27180613e-25,
						0,
						-8.27180613e-25,
						1
					) * CFrame.Angles(0, math.rad((random:NextNumber(0, 360))), 0)
					weld.Parent = part
					table.insert(parts, part)
					task.delay(5, function()
						clone2:Destroy()
						part:Destroy()
					end)
					task.wait()
					local v12 = math.clamp(0.7 - p2 / 20, 0.3, 3)
					Random.new():NextNumber(1, 2.5)
					part.Parent = charEFP

					for _, beam in pairs(part:GetDescendants()) do
						if not beam:IsA("Beam") then
							continue
						end

						if flag then
							beam.Width1 *= 2
						else
							beam.Width1 *= 3
						end

						local transparency = beam.Transparency
						beam.Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(1, 1)
						})
						local time = random:NextNumber(0.3, 0.4) * v12
						playTween(beam, {
							Time = time,
							EasingStyle = "Sine",
							Goal = {
								Transparency = transparency
							}
						})
						local v14 = beam
						task.delay(time, function()
							local time2 = v12 * Random.new():NextNumber(1, 0.88)
							TweenService:Create(
								v14,
								TweenInfo.new(time2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
								{
									TextureSpeed = 1,
									Width1 = v14.Width1 / 4
								}
							):Play()
							playTween(v14, {
								Time = time2,
								EasingStyle = "Sine",
								Goal = {
									Transparency = NumberSequence.new({
										NumberSequenceKeypoint.new(0, 1),
										NumberSequenceKeypoint.new(1, 1)
									})
								}
							})
							game.Debris:AddItem(v14, time2)
						end)
					end

					for _, attachment in pairs(part:GetDescendants()) do
						if not (attachment:IsA("Attachment") and attachment.Name == "Top") then
							continue
						end

						if not flag then
							attachment.Position += Vector3.new(0, Random.new():NextNumber(1, 3), 0)
						end

						TweenService:Create(
							attachment,
							TweenInfo.new(v12, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
							{
								Position = attachment.Position + Vector3.new(0, Random.new():NextNumber(-8.5, -11), 0)
							}
						):Play()
					end
				end

				local v11 = false

				while tick() - start < 2.5 do
					if not (bind and bind.Parent) then
						return Clean()
					end

					count += 1
					clone:PivotTo(v6 * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.Angles(
						0,
						math.rad(count * -6 * (v10.Value * 0.5)),
						0
					))

					if tick() - start < 2 then
						v6 = rightArm.CFrame * CFrame.new(0, -1, 0)

						if count % 30 == 0 or count == 10 then
							task.spawn(function()
								local v12 = tick() - start > 1 and 5 or 1
								local v13 = humanoidRootPart.CFrame * CFrame.Angles(
									0,
									math.rad((random:NextNumber(0, 360))),
									0
								)
								local clone2 = vfx.SpinOH.PartFx.f50.SpinFX:Clone()
								clone2.Parent = charEFP
								clone2.CFrame = v13 * CFrame.new(0, -2.5, 0)
								game.Debris:AddItem(clone2, 3)
								playAttachment(clone2)
								TweenService:Create(
									clone2,
									TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0),
									{
										CFrame = clone2.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
									}
								):Play()
								local clone3 = vfx.Meshes.Swing.Mesh.WindDecal1:Clone()
								clone3:ScaleTo(clone3:GetScale() * v12)
								mesh_emit.new(clone3):Emit(v13 * CFrame.new(clone3:GetAttribute("Offset")))
								local clone4 = vfx.Meshes.Swing.Mesh.WindThroweey:Clone()
								clone4:ScaleTo(clone4:GetScale() * v12)
								mesh_emit.new(clone4):Emit(v13 * CFrame.new(clone4:GetAttribute("Offset")))
								local clone5 = vfx.Meshes.Swing.Mesh.WindSwirl1:Clone()
								clone5:ScaleTo(clone5:GetScale() * v12)
								mesh_emit.new(clone5):Emit(v13 * CFrame.new(clone5:GetAttribute("Offset")))
								local root = vfx.Meshes.Swing.Mesh.GroundBeams.Root
								root.CFrame = v13 * CFrame.new(2, -1, 0) * CFrame.Angles(0, -2.0943951023931953, 0)
								fn2(fn3(root, {
									Properties = {
										Brightness = 0,
										LightEmission = 1,
										TextureSpeed = -0.45,
										Width0 = 2,
										Width1 = 13
									},
									RotationSpeed = 0,
									Rotation = true,
									Offset = CFrame.new(0, 0, 0),
									Duration = 1.5,
									Easing = "Sine",
									EasingDirection = "Out"
								}), TweenInfo.new(1.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), v12 * 1.5)
								local root2 = vfx.Meshes.Swing.Mesh.FullGBeams.Root
								root2.CFrame = v13 * CFrame.new(0, 0, -1) * CFrame.Angles(0, 0.7853981633974483, 0)
								fn2(fn3(root2, {
									Properties = {
										Brightness = 0,
										LightEmission = 1,
										TextureSpeed = -0.5,
										Width0 = 3,
										Width1 = 23
									},
									RotationSpeed = 0,
									Rotation = true,
									Offset = CFrame.new(0, 2, 0),
									Duration = 0.8,
									Easing = "Sine",
									EasingDirection = "Out"
								}), TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), v12 * 4)
							end)
						end

						if count % 5 == 0 then
							if count % 10 == 0 and tick() - start > 0.35 and tick() - start < 0.9 then
								WindLines(4)
							end

							task.spawn(function()
								for _ = 1, 1 do
									local clone2 = vfx.Swirlnormalfaceorigin:Clone()
									clone2:PivotTo(v6 * CFrame.new(0, 0, 0) * CFrame.Angles(
										math.rad((math.random(-180, 180))),
										math.rad((math.random(-180, 180))),
										(math.rad((math.random(-180, 180))))
									))
									clone2.Mesh.Scale *= 1 * v10.Value
									clone2.Parent = charEFP
									game.Debris:AddItem(clone2, 10)
									random:NextNumber(3, 6)
									random:NextNumber(0.0075, 0.015)
									local _ = random:NextInteger(1, 2) == 1
									local v13 = v5[math.random(1, 2)]
									task.spawn(function()
										for i = 1, #v13, 2 do
											local texture = v13[i]

											if texture then
												clone2.Decal.Texture = texture
											end

											dtwait(0.03 * TimeSCale)
										end

										clone2:Destroy()
									end)
									local v15 = clone2
									task.delay(0.1 * TimeSCale, function()
										TweenService:Create(
											v15.Decal,
											TweenInfo.new(
												0.1 * TimeSCale,
												Enum.EasingStyle.Linear,
												Enum.EasingDirection.In
											),
											{
												Color3 = Color3.fromRGB(255, 66, 138)
											}
										):Play()
									end)
								end
							end)
						end
					elseif not v11 then
						able({
							FX = folder,
							On = false
						})
						able({
							FX = clone,
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
						able({
							FX = FX2,
							On = false
						})
						v11 = true
					end

					task.wait(0.01)
				end

				clone:Destroy()
				task.wait(5)
				Clean() -- equivalent call inferred; original call site unknown
			end)
		end)
	end

	task.spawn(PreEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function Nuclear.PortalEvent(p)
	local data = p.Data
	local char = data.Char
	getCharEFP(char)
	local bind = data.Bind
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local victim = data.Victim

	if victim then
		local _ = victim.HumanoidRootPart
	end

	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v4 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v4 then
			v4 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function PortalEvent()
		local v5 = quickFX({
			FX = vfx.NextHit,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 5, -1.5)
		})
		v5:ScaleTo(3)
		playAttachment(v5)
		local folder = quickFX({
			FX = vfx.Spin2,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame
		})
		local lastTime = tick()
		local orientation, v6, v7 = humanoidRootPart.CFrame:ToOrientation()
		task.spawn(function()
			while tick() - lastTime < 2 do
				if bind and bind.Parent then
					folder:PivotTo(CFrame.new(char.Torso.Position) * CFrame.Angles(orientation, v6, v7))
					dtwait(0.01)
				else
					return Clean()
				end
			end
		end)
		task.delay(0.55, function()
			able({
				FX = folder,
				On = false
			})
		end)

		for _, emitter in pairs(folder:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local rotSpeed = emitter.RotSpeed
			emitter.RotSpeed = NumberRange.new(rotSpeed.Min * 3, rotSpeed.Max * 3)
		end

		local spawnportal = PortalSpawner.Spawnportal({
			Scale = 0.7,
			TimeScale = 0.3,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 5, -1.5)
		})
		task.delay(0.9, function()
			PortalSpawner.ClosePortal(spawnportal)
		end)
		task.delay(0.9, function()
			local spawnportal2 = PortalSpawner.Spawnportal({
				Scale = 0.7,
				TimeScale = 0.3,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, 62, -1.5)
			})
			task.wait(0.1)
			PortalSpawner.ClosePortal(spawnportal2)
			task.wait(0.15)

			if not (bind and bind.Parent) then
				return Clean()
			end

			local v8 = quickFX({
				FX = vfx.Connect,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, 67, -1.5)
			})
			v8:ScaleTo(0.5)
			playAttachment(v8)
		end)
		task.wait(1)

		if not (bind and bind.Parent) then
			return Clean()
		end

		local spawnportal2 = PortalSpawner.Spawnportal({
			Scale = 0.7,
			TimeScale = 0.3,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.4, -4.5)
		})
		task.delay(0.5, function()
			PortalSpawner.ClosePortal(spawnportal2)
		end)
		task.wait(0.3)

		if bind and bind.Parent then
			local spawnportal3 = PortalSpawner.Spawnportal({
				Scale = 0.7,
				TimeScale = 0.3,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, -120) * CFrame.Angles(1.5707963267948966, 0, 0)
			})
			task.delay(0.5, function()
				PortalSpawner.ClosePortal(spawnportal3)
			end)
		else
			return Clean()
		end
	end

	task.spawn(PortalEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

local class2 = {}
class2.__index = class2

local function scaleNumberSequence(sequence, currentScale)
	local keypoints = sequence.Keypoints
	local numberSequenceKeypoints = table.create(#keypoints)

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * currentScale,
			keypoint.Envelope * currentScale
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

function class2.new(folder)
	local object = setmetatable({}, class2)
	object._currentScale = 1
	local descendants = {}
	local sizes = {}
	local descendants2 = {}
	local positions = {}
	local descendants3 = {}
	local sizes2 = {}
	local speeds = {}
	local descendants4 = {}
	local widthScales = {}

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			local v4 = #descendants + 1
			descendants[v4] = descendant
			sizes[v4] = descendant.Size
		elseif descendant:IsA("Attachment") then
			local v4 = #descendants2 + 1
			descendants2[v4] = descendant
			positions[v4] = descendant.Position
		elseif descendant:IsA("ParticleEmitter") then
			local v4 = #descendants3 + 1
			descendants3[v4] = descendant
			sizes2[v4] = descendant.Size
			speeds[v4] = descendant.Speed
		elseif descendant:IsA("Trail") then
			local v4 = #descendants4 + 1
			descendants4[v4] = descendant
			widthScales[v4] = descendant.WidthScale
		end
	end

	object._parts = descendants
	object._partSizes = sizes
	object._atts = descendants2
	object._attPositions = positions
	object._emitters = descendants3
	object._emitterSizes = sizes2
	object._emitterSpeeds = speeds
	object._trails = descendants4
	object._trailWidths = widthScales
	return object
end

function class2:Set(currentScale)
	if currentScale == self._currentScale then
		return
	end

	self._currentScale = currentScale
	local _parts = self._parts
	local _partSizes = self._partSizes

	for i = 1, #_parts do
		_parts[i].Size = _partSizes[i] * currentScale
	end

	local _atts = self._atts
	local _attPositions = self._attPositions

	for i = 1, #_atts do
		local _att = _atts[i]
		local cFrame = _att.CFrame
		_att.CFrame = cFrame - cFrame.Position + _attPositions[i] * currentScale
	end

	local _emitters = self._emitters
	local _emitterSizes = self._emitterSizes
	local _emitterSpeeds = self._emitterSpeeds

	for i = 1, #_emitters do
		local _emitter = _emitters[i]
		_emitter.Size = scaleNumberSequence(_emitterSizes[i], currentScale)
		local _emitterSpeed = _emitterSpeeds[i]
		_emitter.Speed = NumberRange.new(_emitterSpeed.Min * currentScale, _emitterSpeed.Max * currentScale)
	end

	local _trails = self._trails
	local _trailWidths = self._trailWidths

	for i = 1, #_trails do
		_trails[i].WidthScale = scaleNumberSequence(_trailWidths[i], currentScale)
	end
end

function class2:SetGeometryOnly(currentScale)
	if currentScale == self._currentScale then
		return
	end

	self._currentScale = currentScale
	local _parts = self._parts
	local _partSizes = self._partSizes

	for i = 1, #_parts do
		_parts[i].Size = _partSizes[i] * currentScale
	end

	local _atts = self._atts
	local _attPositions = self._attPositions

	for i = 1, #_atts do
		local _att = _atts[i]
		local cFrame = _att.CFrame
		_att.CFrame = cFrame - cFrame.Position + _attPositions[i] * currentScale
	end

	local _trails = self._trails
	local _trailWidths = self._trailWidths

	for i = 1, #_trails do
		_trails[i].WidthScale = scaleNumberSequence(_trailWidths[i], currentScale)
	end
end

function class2:Destroy()
	table.clear(self._parts)
	table.clear(self._partSizes)
	table.clear(self._atts)
	table.clear(self._attPositions)
	table.clear(self._emitters)
	table.clear(self._emitterSizes)
	table.clear(self._emitterSpeeds)
	table.clear(self._trails)
	table.clear(self._trailWidths)
end

local v4 = {}
local v5 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function buildKey(data)
	return string.format(
		"%s|%s|%s",
		tostring(data.lifeScale or 1),
		tostring(data.rateMult or 1),
		(tostring(data.disableColorEmitters and "D" or "_"))
	)
end

local function bakeTemplate(instance, data)
	local clone = instance:Clone()

	for _, emitter in ipairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if data.lifeScale and data.lifeScale ~= 1 then
			local lifetime = emitter.Lifetime
			emitter.Lifetime = NumberRange.new(lifetime.Min * data.lifeScale, lifetime.Max * data.lifeScale)
		end

		if data.rateMult and data.rateMult ~= 1 then
			emitter.Rate *= data.rateMult
		end

		if data.disableColorEmitters and emitter.Name == "color" then
			emitter.Enabled = false
		end
	end

	return clone
end

function v4.GetTemplate(p, options)
	local v6 = options or {}
	local v7 = v5[p]

	if not v7 then
		v7 = {}
		v5[p] = v7
	end

	local key = buildKey(v6) -- equivalent call inferred; original call site unknown
	local v8 = v7[key]

	if not v8 then
		v8 = bakeTemplate(p, v6)
		v7[key] = v8
	end

	return v8
end

function v4:Clone(p2)
	return v4.GetTemplate(self, p2):Clone()
end

function Nuclear.BarrageEvent(p)
	local data = p.Data
	local char = data.Char
	getCharEFP(char)
	local bind = data.Bind
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local victim = data.Victim

	if victim then
		local _ = victim.HumanoidRootPart
	end

	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v6 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v6 then
			v6 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function BarrageEvent()
		-- equivalent calls inferred from this helper; original call sites unknown
		local function NewBarrage()
			task.spawn(function()
				task.wait(0.4)

				if not (bind and bind.Parent) then
					return Clean()
				end

				local lastTime = tick()
				local folder = quickFX({
					FX = vfx.Bem,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 1) * CFrame.Angles(
						0,
						0,
						0
					)
				})
				folder:ScaleTo(0.8)

				for _, effect in pairs(folder:GetDescendants()) do
					if effect:IsA("Beam") then
						effect.Brightness = 0
						local v7 = effect
						task.delay(0.1, function()
							TweenService:Create(v7, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
								Brightness = 1
							}):Play()
						end)
					elseif effect:IsA("ParticleEmitter") then
						effect.Enabled = true
					end
				end

				local FX = quickFX({
					FX = vfx.Back,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
				})
				raiseZIndex({
					FX = FX,
					Count = 2
				})
				FX:ScaleTo(2.3)
				local flag = true

				while tick() - lastTime < 1.1 do
					if not (bind and bind.Parent) then
						return Clean()
					end

					for _ = 1, 2 do
						local anchor = humanoidRootPart.CFrame * CFrame.new(
							random:NextNumber(-3.5, 3.5) * 1.5,
							random:NextNumber(-3.5, 3.5) * 1.5,
							random:NextNumber(-7, -3.5)
						) * CFrame.new(0, 0, 10)
						local folder2 = quickFX({
							FX = vfx["33"],
							Maid = object._maid,
							Anchor = anchor
						})
						local pointLight = Instance.new("PointLight")
						pointLight.Brightness = 3
						pointLight.Color = Color3.new(0.486275, 0.227451, 1)
						pointLight.Range = 4
						pointLight.Parent = folder2.PrimaryPart
						local v9 = object._maid:give(Instance.new("NumberValue"))
						object._maid:giveTask(v9.Changed:Connect(function() end))
						flag = nil

						for _, emitter in pairs(folder2:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							emitter.Rate *= 12
							local lifetime = emitter.Lifetime
							emitter.Lifetime = NumberRange.new(lifetime.Min / 12, lifetime.Max / 12)
							emitter:Emit(2)
						end

						local folder3

						if flag then
							folder3 = quickWeld({
								FX = vfx.Activated,
								Maid = object._maid,
								P = folder2.PrimaryPart,
								C0 = CFrame.Angles(1.5707963267948966, 0, 0)
							})
							folder3:ScaleTo(random:NextNumber(0.2, 0.4))

							for _, emitter in pairs(folder3:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								emitter.Rate *= 3
								local lifetime = emitter.Lifetime
								emitter.Lifetime = NumberRange.new(lifetime.Min / 3, lifetime.Max / 3)

								if emitter.Name == "color" then
									emitter.Enabled = false
								end
							end

							lifeScale({
								FX = folder3,
								Scale = 0.3
							})
						else
							folder3 = nil
						end

						v9.Value = folder2:GetScale()
						TweenService:Create(
							v9,
							TweenInfo.new(0.085, Enum.EasingStyle.Bounce, Enum.EasingDirection.In),
							{
								Value = random:NextNumber(1, 1.5) * 2
							}
						):Play()
						task.delay(0.085, function()
							TweenService:Create(
								v9,
								TweenInfo.new(0.085, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
								{
									Value = 0.01
								}
							):Play()

							if folder3 then
								able({
									FX = folder3,
									On = false
								})
							end

							task.wait(0.1)
							local FX2 = quickFX({
								FX = vfx.ArmEnd,
								Maid = object._maid,
								Anchor = folder2:GetPivot()
							})
							playAttachment(FX2)
							lifeScale({
								FX = FX2,
								Scale = 0.1
							})
							game.Debris:AddItem(FX2, 0.1)
						end)
						TweenService:Create(folder2.PrimaryPart, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
							CFrame = folder2:GetPivot() * CFrame.new(0, 0, -20)
						}):Play()
						local clone = vfx.Ring:Clone()
						clone:ScaleTo(random:NextNumber(0.2, 0.3) * 2)
						playMesh({
							Model = clone,
							T = 0.5,
							EndT = 1,
							Anchor = folder2:GetPivot() * CFrame.new(0, 0, -10) * CFrame.Angles(
								1.5707963267948966,
								0,
								0
							),
							Info = TweenInfo.new(0.085, Enum.EasingStyle.Sine)
						})
						game.Debris:AddItem(folder2, 0.17)
					end

					dtwait(0.034)
				end

				if folder then
					for _, effect in pairs(folder:GetDescendants()) do
						if effect:IsA("ParticleEmitter") then
							effect.Enabled = false
						elseif effect:IsA("Beam") then
							TweenService:Create(effect, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
								Brightness = 0
							}):Play()
						end
					end

					game.Debris:AddItem(folder, 0.5)
				end

				able({
					FX = FX,
					On = false
				})
			end)
		end

		task.spawn(function()
			NewBarrage() -- equivalent call inferred; original call site unknown
		end)
	end

	task.spawn(BarrageEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function Nuclear.FallEvent(p)
	local data = p.Data
	local char = data.Char
	local charEFP = getCharEFP(char)
	local bind = data.Bind
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local victim = data.Victim

	if victim then
		local _ = victim.HumanoidRootPart
	end

	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v6 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v6 then
			v6 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function FallEvent()
		local folder = object._maid:give(vfx.Activated:Clone())
		folder:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 40, -2))
		TweenService:Create(folder.PrimaryPart, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
			CFrame = folder:GetPivot() * CFrame.new(0, -80, 0)
		}):Play()

		for _, emitter in pairs(folder:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Rate *= 12
			local lifetime = emitter.Lifetime
			emitter.Lifetime = NumberRange.new(lifetime.Min / 12, lifetime.Max / 12)

			if emitter.Name == "color" then
				emitter.Enabled = false
			end
		end

		folder:ScaleTo(0.5)
		folder.Parent = charEFP
		task.delay(0.6, function()
			able({
				FX = folder,
				On = false
			})
		end)
		task.wait(0.05)

		if not (bind and bind.Parent) then
			return Clean()
		end

		local lastTime = tick()
		local count = 0
		task.spawn(function()
			while tick() - lastTime < 0.4 do
				if not (bind and bind.Parent) then
					return Clean()
				end

				count += 1
				local clone = vfx.FallWind:Clone()
				clone:ScaleTo(random:NextNumber(0.2, 0.3) * 2)
				playMesh({
					Model = clone,
					T = 0.5,
					EndT = 1,
					Anchor = CFrame.new(char.Torso.Position - createVector(0, 20, 0)) * CFrame.Angles(
						3.141592653589793,
						random:NextNumber(-4, 4),
						0
					),
					Info = TweenInfo.new(0.15, Enum.EasingStyle.Sine)
				})
				task.wait(0.1)
			end
		end)
		local v7 = object._maid:give(vfx.Impact:Clone())
		v7.Parent = charEFP
		game.Debris:AddItem(v7, 3)
		local lastTime2 = tick()

		while tick() - lastTime2 < 0.4 do
			if bind and bind.Parent then
				v7:ScaleTo(random:NextNumber(1.5, 2.5))
				v7:PivotTo(CFrame.new(char.Torso.Position - createVector(0, -5, 0)) * CFrame.Angles(
					0,
					random:NextNumber(-4, 4),
					0
				))
				task.wait(0.01)
			else
				return Clean()
			end
		end

		v7:Destroy()
	end

	task.spawn(FallEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function Nuclear.LandEvent(p)
	local data = p.Data
	local char = data.Char
	getCharEFP(char)
	local _ = data.Bind
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local victim = data.Victim

	if victim then
		local _ = victim.HumanoidRootPart
	end

	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v6 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v6 then
			v6 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function LandEvent()
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
		local raycastResult = game.Workspace:Raycast(
			humanoidRootPart.CFrame * CFrame.new(0, 0, -2).Position,
			createVector(0, -30, 0),
			raycastParams
		)

		if raycastResult then
			local v7 = quickFX({
				FX = vfx.Okkk,
				Maid = object._maid,
				Anchor = CFrame.new(raycastResult.Position + createVector(0, 0.2, 0))
			})
			v7:ScaleTo(3)
			playAttachment(v7)
		end
	end

	task.spawn(LandEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function Nuclear.RollEvent(p)
	local data = p.Data
	local char = data.Char
	getCharEFP(char)
	local bind = data.Bind
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local victim = data.Victim

	if victim then
		local _ = victim.HumanoidRootPart
	end

	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v6 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v6 then
			v6 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function RollEvent()
		task.wait(0.1)
		local folder = quickFX({
			FX = vfx.Spin,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame
		})
		local lastTime = tick()
		local orientation, v7, v8 = humanoidRootPart.CFrame:ToOrientation()
		task.spawn(function()
			while tick() - lastTime < 2 do
				if bind and bind.Parent then
					folder:PivotTo(CFrame.new(victim.Torso.Position) * CFrame.Angles(orientation, v7, v8))
					dtwait(0.01)
				else
					return Clean()
				end
			end
		end)

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				local rotSpeed = emitter.RotSpeed
				emitter.RotSpeed = NumberRange.new(rotSpeed.Min * 1.5, rotSpeed.Max * 1.5)
			elseif emitter:HasTag("MeshEmitter") then
				emitter:SetAttribute("LockedToPart", true)
				emitter:SetAttribute("Rate", emitter:GetAttribute("Rate") * 3)
			end
		end

		task.delay(0.1, function()
			local v9 = quickFX({
				FX = vfx.Bounce,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, -100)
			})
			v9:ScaleTo(1.2)
			playAttachment(v9)
			task.wait(0.5)

			if not (bind and bind.Parent) then
				return Clean()
			end

			local v10 = quickFX({
				FX = vfx.Bounce,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, -60)
			})
			v10:ScaleTo(1)
			playAttachment(v10)
			task.wait(0.4)

			if not (bind and bind.Parent) then
				return Clean()
			end

			local v11 = quickFX({
				FX = vfx.Bounce,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, -34)
			})
			v11:ScaleTo(0.85)
			playAttachment(v11)
		end)
		task.wait(0.8)
		able({
			FX = folder,
			On = false
		})
	end

	task.spawn(RollEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function Nuclear.GoneEvent(p)
	local data = p.Data
	local char = data.Char
	getCharEFP(char)
	local bind = data.Bind
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local victim = data.Victim

	if victim then
		local _ = victim.HumanoidRootPart
	end

	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v6 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v6 then
			v6 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function GoneEvent()
		local FX = quickFX({
			FX = vfx.Smoke,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame
		})
		able({
			FX = FX,
			On = false
		})
		Crater.FlyingRocks({
			Origin = humanoidRootPart.CFrame * CFrame.new(0, 0, -10),
			Direction = "Forward",
			Amount = 15,
			MinSize = createVector(1.05, 1.05, 1.05),
			MaxSize = createVector(2.4, 2.4, 2.4),
			SpeedMin = 132,
			SpeedMax = 267,
			SpreadAngle = 43,
			Lifetime = 0,
			Gravity = workspace.Gravity,
			Drag = 0.2,
			Bounciness = 0.5,
			Friction = 0.4,
			MaxBounces = 4,
			MinSpeed = 5,
			FadeTime = 0.5,
			LandSide = "up",
			Parent = workspace:FindFirstChild("Thrown"),
			done = function(anchor)
				playAttachment((quickFX({
					FX = vfx.SmokeBoom,
					Maid = object._maid,
					Anchor = anchor
				})))
			end
		})
		task.delay(0.3, function()
			if bind and bind.Parent then
				task.wait(0.1)
				Crater.FlyingRocks({
					Origin = humanoidRootPart.CFrame * CFrame.new(0, 0, -30),
					Direction = "Forward",
					Amount = 15,
					MinSize = createVector(1.05, 1.05, 1.05),
					MaxSize = createVector(2.4, 2.4, 2.4),
					SpeedMin = 132,
					SpeedMax = 267,
					SpreadAngle = 43,
					Lifetime = 0,
					Gravity = workspace.Gravity,
					Drag = 0.2,
					Bounciness = 0.5,
					Friction = 0.4,
					MaxBounces = 4,
					MinSpeed = 5,
					FadeTime = 0.5,
					LandSide = "up",
					Parent = workspace:FindFirstChild("Thrown"),
					done = function(anchor)
						playAttachment((quickFX({
							FX = vfx.SmokeBoom,
							Maid = object._maid,
							Anchor = anchor
						})))
					end
				})
			else
				return Clean()
			end
		end)
		local folder = quickFX({
			FX = vfx.Spin2,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame
		})
		local lastTime = tick()
		local orientation, v8, v9 = humanoidRootPart.CFrame:ToOrientation()
		task.spawn(function()
			while tick() - lastTime < 2 do
				if bind and bind.Parent then
					folder:PivotTo(CFrame.new(victim.Torso.Position) * CFrame.Angles(orientation, v8, v9))
					FX:PivotTo(folder:GetPivot() * CFrame.new(0, 0, -5) * CFrame.Angles(0, 0, 0))
					dtwait(0.01)
				else
					return Clean()
				end
			end
		end)
		task.delay(0.55, function()
			able({
				FX = folder,
				On = false
			})
			task.wait(0.2)
			able({
				FX = FX,
				On = false
			})
		end)

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				local rotSpeed = emitter.RotSpeed
				emitter.RotSpeed = NumberRange.new(rotSpeed.Min * 3, rotSpeed.Max * 3)
			elseif emitter:HasTag("MeshEmitter") then
				emitter:SetAttribute("Rate", emitter:GetAttribute("Rate") * 2)
				emitter:SetAttribute("LockedToPart", true)
			end
		end

		task.delay(0.1, function()
			local v10 = quickFX({
				FX = vfx.Bounce,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, -18)
			})
			v10:ScaleTo(0.85)
			playAttachment(v10)
			task.wait(0.6)

			if not (bind and bind.Parent) then
				return Clean()
			end

			local v11 = quickFX({
				FX = vfx.Bounce,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, -70)
			})
			v11:ScaleTo(1)
			playAttachment(v11)
			task.wait(0.4)
		end)
		task.spawn(function()
			local orientation2, v10, v11 = humanoidRootPart.CFrame:ToOrientation()
			local count = 0

			while tick() - lastTime < 0.6 do
				if not (bind and bind.Parent) then
					return Clean()
				end

				count += 1
				local clone = vfx.FallWind:Clone()
				clone:ScaleTo(random:NextNumber(0.2, 0.3) * 2)
				playMesh({
					Model = clone,
					T = 0.5,
					EndT = 1,
					Anchor = CFrame.new(victim.Torso.Position) * CFrame.Angles(orientation2, v10, v11) * CFrame.new(
						0,
						0,
						-10
					) * CFrame.Angles(-1.5707963267948966, random:NextNumber(-4, 4), 0),
					Info = TweenInfo.new(0.15, Enum.EasingStyle.Sine)
				})
				task.wait(0.1)
			end
		end)
		task.delay(0.5, function()
			if bind and bind.Parent then
				local spawnportal = PortalSpawner.Spawnportal({
					Scale = 0.7,
					TimeScale = 0.3,
					Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, -123) * CFrame.Angles(1.5707963267948966, 0, 0)
				})
				task.delay(0.9, function()
					PortalSpawner.ClosePortal(spawnportal)
				end)
			else
				return Clean()
			end
		end)
		local folders = {}

		for _, childName in pairs({
			"Right Arm",
			"Left Arm",
			"Right Leg",
			"Left Leg"
		}) do
			local child = victim:FindFirstChild(childName)

			if not child then
				continue
			end

			local folder2 = object._maid:give(vfx.Trails.TrailWind:Clone())

			for _, trail in pairs(folder2:GetDescendants()) do
				if trail:IsA("Trail") then
					trail.Enabled = true
				end
			end

			folder2.Parent = child
			table.insert(folders, folder2)
		end

		task.delay(6, function()
			for _, v10 in pairs(folders) do
				v10:Destroy()
			end
		end)
	end

	task.spawn(GoneEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function Nuclear.DashEvent(p)
	local data = p.Data
	local char = data.Char
	getCharEFP(char)
	local _ = data.Bind
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local victim = data.Victim

	if victim then
		local _ = victim.HumanoidRootPart
	end

	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v6 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v6 then
			v6 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function DashEvent()
		local FX = quickFX({
			FX = vfx.DashDust,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, -65)
		})
		lifeScale({
			FX = FX,
			Scale = 0.5
		})
		task.wait(0.1)
		playAttachment(FX)
	end

	task.spawn(DashEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function Nuclear.SpaceEvent(p)
	local data = p.Data
	local char = data.Char
	local charEFP = getCharEFP(char)
	local bind = data.Bind
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local camVal = char:FindFirstChild("CamVal")
	local value

	if camVal then
		value = camVal.Value
	else
		value = nil
	end

	local guide = data.guide
	guide.Parent = workspace.Thrown
	local victim = data.Victim

	if victim then
		local _ = victim.HumanoidRootPart
	end

	local v6 = game.Players.LocalPlayer.Character == data.Char or game.Players.LocalPlayer.Character == data.Victim
	local clouds = v6 and game.Workspace.Terrain:FindFirstChild("Clouds")

	if clouds then
		clouds.Enabled = false
	end

	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v7 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v7 then
			v7 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function SpaceEvent()
		local child = game.Workspace.Thrown:FindFirstChild("EFPNUCLEAR_" .. char.Name)
		local makeitNewMeshEmitter = child and child:FindFirstChild("MakeitNew MeshEmitter")

		if makeitNewMeshEmitter then
			makeitNewMeshEmitter:SetAttribute("Space", true)
		end

		local v8 = object._maid:give(script["Clear Blue Sky"]:Clone())
		v8.Name = "SpaceSky"
		v8.Parent = game.Lighting
		fn(1)
		local parentChangedConnection = nil
		parentChangedConnection = char:GetPropertyChangedSignal("Parent"):Connect(function()
			if not char.Parent and parentChangedConnection then
				parentChangedConnection:Disconnect()
				parentChangedConnection = nil
				workspace:SetAttribute("MapInvis", nil)

				for _, part in pairs(workspace.Map:GetDescendants()) do
					if part:IsA("BasePart") then
						part.LocalTransparencyModifier = 0
					end
				end
			end
		end)
		task.delay(15, function()
			if parentChangedConnection then
				parentChangedConnection:Disconnect()
				parentChangedConnection = nil
			end
		end)
		workspace:SetAttribute("MapInvis", true)
		bind.Destroying:Once(function()
			workspace:SetAttribute("MapInvis", nil)

			for _, part in pairs(workspace.Map:GetDescendants()) do
				if part:IsA("BasePart") then
					part.LocalTransparencyModifier = 0
				end
			end

			workspace:SetAttribute("MapInvis", nil)
		end)
		local folder = object._maid:give(vfx.TrailMoveEmitter:Clone())
		folder.Parent = charEFP
		game.Debris:AddItem(folder, 30)
		local v9 = MoonEmitter.new(folder)
		v9:SetAnchor(humanoidRootPart.CFrame)
		v9:Play()
		v9:SetTime(8.3)
		task.spawn(function()
			local lastTime = tick()

			while tick() - lastTime < 3 do
				if folder.Parent then
					v9:SetAnchor(humanoidRootPart.CFrame)
				end

				task.wait(0.1)
			end
		end)
		local v10 = object._maid:give(Instance.new("ColorCorrectionEffect"))
		v10.Parent = game.Lighting
		v9:AssignExternal("ColorCorrection", v10)
		object._maid:giveTask(bind.Destroying:Connect(function()
			local clouds2 = game.Workspace.Terrain:FindFirstChild("Clouds")

			if clouds2 then
				clouds2.Enabled = true
			end

			workspace:SetAttribute("MapInvis", nil)

			for _, part in pairs(workspace.Map:GetDescendants()) do
				if part:IsA("BasePart") then
					part.LocalTransparencyModifier = 0
				end
			end

			shared.originallighting()
			local L = require(game.ReplicatedStorage.Resources.CosmicUtils.L)
			L.A()
			Clean() -- equivalent call inferred; original call site unknown
		end))

		for _, effect in pairs(folder:GetDescendants()) do
			if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
				continue
			end

			effect.Enabled = true
		end

		local folder2 = object._maid:give(vfx.Trails.Trail:Clone())
		folder2.Parent = char.Torso
		game.Debris:AddItem(folder2, 6)

		for _, trail in pairs(folder2:GetDescendants()) do
			if trail:IsA("Trail") then
				trail.Enabled = true
			end
		end

		local v11 = object._maid:give(vfx.MeteroWave:Clone())
		v11:PivotTo(guide:GetPivot() * vfx.MeteroWave:GetAttribute("Offset"):Inverse())
		v11.Parent = charEFP
		game.Debris:AddItem(v11, 6)
		local M1 = value.CamPart.Beams.M1

		for _, beam in pairs(M1:GetDescendants()) do
			if beam:IsA("Beam") then
				beam.Enabled = true
			end
		end

		local M4 = value.CamPart.Beams.M4

		for _, beam in pairs(M4:GetDescendants()) do
			if beam:IsA("Beam") then
				beam.Enabled = true
			end
		end

		local enable = value.CamPart.Fx.Enable

		for _, effect in pairs(enable:GetDescendants()) do
			if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
				continue
			end

			effect.Enabled = false
		end

		local L = require(game.ReplicatedStorage.Resources.CosmicUtils.L)
		L.A(true)
		task.delay(6, function()
			local L2 = require(game.ReplicatedStorage.Resources.CosmicUtils.L)
			L2.A()
		end)
		local v12 = object._maid:give(vfx.ScreenEffect:Clone())
		v12.Parent = charEFP
		playAttachment(v12)
		task.spawn(function()
			local cframe = CFrame.new(0, 0, -2)
			local lastTime = tick()

			while tick() - lastTime < 4 do
				v12:PivotTo(camera.CFrame * cframe)
				RunService.RenderStepped:Wait()
			end
		end)
		local folder3 = quickFX({
			FX = vfx.BeamSpace,
			Maid = object._maid,
			Anchor = char:GetPivot() * vfx.BeamSpace:GetAttribute("Offset"):Inverse()
		})

		for _, beam in pairs(folder3:GetDescendants()) do
			if beam:IsA("Beam") then
				beam.Enabled = true
			end
		end

		game.Debris:AddItem(folder3, 6)
		task.wait(2)

		if not (bind and bind.Parent) then
			return Clean()
		end

		shared.vfx.emit(
			guide["Torus.007"].S,
			guide["Torus.008"].S,
			guide["Torus.009"].S,
			guide["Torus.010"].S,
			guide["Torus.011"].S,
			guide["Torus.012"].S,
			guide["Torus.013"].S,
			guide["Torus.014"].S,
			guide["Torus.015"].S,
			guide["Torus.016"].S,
			guide["Torus.017"].S,
			guide["Torus.019"].S,
			guide["Torus.020"].S,
			guide["Torus.021"].S
		)
		task.wait(2)

		if not (bind and bind.Parent) then
			return Clean()
		end

		local Part_Icles = require(game.ReplicatedStorage.Resources.CosmicUtils.Part_Icles)
		local v13 = object._maid:give(vfx.HoleF3:Clone())
		v13.Parent = charEFP

		for _, child2 in pairs(v13:GetChildren()) do
			child2:PivotTo(guide:GetPivot() * child2:GetAttribute("Offset"):Inverse())
		end

		Part_Icles:AbsoluteEmit(v13)
		shared.vfx.emit(guide["Torus.022"].H1)
		task.wait(0.77)
		task.wait(0.5)

		if bind and bind.Parent then
			shared.vfx.emit(value.CamPart.Fx.Emit2)
		else
			return Clean()
		end
	end

	if v6 then
		task.spawn(SpaceEvent)
	end

	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function Nuclear.BackEvent(p)
	local data = p.Data
	local char = data.Char
	getCharEFP(char)
	local bind = data.Bind
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local preAnchor = data.PreAnchor
	local camVal = char:FindFirstChild("CamVal")
	local value

	if camVal then
		value = camVal.Value
	else
		value = nil
	end

	local clouds = game.Workspace.Terrain:FindFirstChild("Clouds")

	if clouds then
		clouds.Enabled = true
	end

	local victim = data.Victim

	if victim then
		local _ = victim.HumanoidRootPart
	end

	local v6 = game.Players.LocalPlayer.Character == data.Char or game.Players.LocalPlayer.Character == data.Victim
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v7 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v7 then
			v7 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function BackEvent()
		local child = game.Workspace.Thrown:FindFirstChild("EFPNUCLEAR_" .. char.Name)
		local makeitNewMeshEmitter = child and child:FindFirstChild("MakeitNew MeshEmitter")

		if makeitNewMeshEmitter then
			makeitNewMeshEmitter:SetAttribute("Back", true)
		end

		if v6 then
			for _, child2 in pairs(game.Lighting:GetChildren()) do
				if child2.Name == "SpaceSky" then
					child2:Destroy()
				end
			end

			workspace:SetAttribute("MapInvis", nil)

			for _, part in pairs(workspace.Map:GetDescendants()) do
				if part:IsA("BasePart") then
					part.LocalTransparencyModifier = 0
				end
			end

			workspace:SetAttribute("MapInvis", nil)
		end

		task.delay(0.3, function()
			if bind and bind.Parent then
				local folder

				if v6 then
					folder = quickFX({
						FX = vfx.explosioo,
						Maid = object._maid,
						Anchor = humanoidRootPart.CFrame * vfx.explosioo:GetAttribute("Offset"):Inverse()
					})
				else
					folder = quickFX({
						FX = vfx.explosioooutside,
						Maid = object._maid,
						Anchor = humanoidRootPart.CFrame * vfx.explosioo:GetAttribute("Offset"):Inverse()
					})
				end

				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:SetAttribute("EmitDelay", emitter:GetAttribute("EmitDelay") * 0.45)
					end
				end

				playAttachment(folder)
				task.delay(0.3, function()
					if bind and bind.Parent then
						folder:PivotTo(folder:GetPivot() * CFrame.new(0, 0, -40))
						return
					end

					Clean() -- equivalent call inferred; original call site unknown
				end)
				dtwait(0.8)

				if bind and bind.Parent then
					Crater.FlyingRocks({
						Origin = humanoidRootPart.CFrame * CFrame.new(0, 0, 150),
						Direction = "Forward",
						Amount = 35,
						MinSize = createVector(3.5, 3.5, 3.5),
						MaxSize = createVector(8, 8, 8),
						SpeedMin = 220,
						SpeedMax = 445,
						SpreadAngle = 93,
						Lifetime = 0,
						Gravity = workspace.Gravity,
						Drag = 0.2,
						Bounciness = 0.5,
						Friction = 0.4,
						MaxBounces = 8,
						MinSpeed = 5,
						FadeTime = 0.5,
						LandSide = "up",
						Parent = workspace:FindFirstChild("Thrown"),
						done = function(anchor)
							playAttachment((quickFX({
								FX = vfx.SmokeBoom,
								Maid = object._maid,
								Anchor = anchor
							})))
						end
					})
					local v8 = quickFX({
						FX = vfx.NoiseCirclePart,
						Maid = object._maid,
						Anchor = humanoidRootPart.CFrame
					})
					v8:ScaleTo(1.2)
					local scale = v8.PrimaryPart.Mesh.Scale
					local v9 = object._maid:give(Instance.new("NumberValue"))
					v9.Value = 0
					TweenService:Create(v9, TweenInfo.new(0.5, Enum.EasingStyle.Elastic), {
						Value = 1
					}):Play()
					task.delay(3, function()
						TweenService:Create(v9, TweenInfo.new(4, Enum.EasingStyle.Elastic), {
							Value = 1
						}):Play()
					end)
					local lastTime = tick()
					local v10 = 0

					while tick() - lastTime < 1 do
						if bind and bind.Parent then
							local orientation, v11, v12 = humanoidRootPart.CFrame:ToOrientation()
							v8:PivotTo(CFrame.new(char.Torso.Position) * CFrame.Angles(orientation, v11, v12) * CFrame.new(
								0,
								-2,
								0
							) * CFrame.Angles(0, 0, -0))
							v10 += 1
							v8.PrimaryPart.Mesh.Scale = Vector3.new(scale.X, 0, scale.Z * v9.Value)
							v8.PrimaryPart.Mesh.VertexColor = createVector(0, 0, 0)

							if v3[v10] then
								v8.NoiseCirclePart.Mesh.TextureId = v3[v10]
							else
								v8.NoiseCirclePart.Mesh.TextureId = v3[1]
								v10 = 1
							end

							dtwait(0.01)
						else
							Clean() -- equivalent call inferred; original call site unknown
							return
						end
					end

					v8:Destroy()
					return
				end
			end

			Clean() -- equivalent call inferred; original call site unknown
		end)
		local spawnportal = PortalSpawner.Spawnportal({
			Scale = 0.7,
			TimeScale = 0.3,
			Anchor = preAnchor * CFrame.new(0, 1, 119) * CFrame.Angles(3.141592653589793, 0, 0)
		})
		task.delay(0.35, function()
			PortalSpawner.ClosePortal(spawnportal)
		end)

		if not v6 then
			local spawnportal2 = PortalSpawner.Spawnportal({
				Scale = 0.7,
				TimeScale = 0.3,
				Anchor = preAnchor * CFrame.new(0, 1, -139) * CFrame.Angles(1.5707963267948966, 0, 0)
			})
			task.delay(0.35, function()
				PortalSpawner.ClosePortal(spawnportal2)
			end)
		end

		if v6 then
			local M1 = value.CamPart.Beams.M1

			for _, beam in pairs(M1:GetDescendants()) do
				if beam:IsA("Beam") then
					beam.Enabled = false
				end
			end

			local M4 = value.CamPart.Beams.M4

			for _, beam in pairs(M4:GetDescendants()) do
				if beam:IsA("Beam") then
					beam.Enabled = false
				end
			end
		end

		local folders = {}

		for _, childName in pairs({
			"Right Arm",
			"Left Arm",
			"Right Leg",
			"Left Leg"
		}) do
			local child2 = victim:FindFirstChild(childName)

			if not child2 then
				continue
			end

			local folder = object._maid:give(vfx.Trails.TrailWind:Clone())

			for _, trail in pairs(folder:GetDescendants()) do
				if trail:IsA("Trail") then
					trail.Enabled = true
				end
			end

			folder.Parent = child2
			table.insert(folders, folder)
		end

		task.delay(2, function()
			for _, v8 in pairs(folders) do
				v8:Destroy()
			end
		end)
		task.wait(0.4)

		if bind and bind.Parent then
			local folder = quickFX({
				FX = vfx.Spin3,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame
			})
			local lastTime = tick()
			local orientation, v8, v9 = humanoidRootPart.CFrame:ToOrientation()
			local FX = quickFX({
				FX = vfx.Smoke,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame
			})
			able({
				FX = FX,
				On = true
			})
			task.delay(0.3, function()
				able({
					FX = FX,
					On = false
				})
			end)
			task.spawn(function()
				while tick() - lastTime < 2 do
					if bind and bind.Parent then
						folder:PivotTo(CFrame.new(victim.Torso.Position) * CFrame.Angles(orientation, v8, v9))
						FX:PivotTo(folder:GetPivot() * CFrame.new(0, -1, 0))
						dtwait(0.01)
					else
						Clean() -- equivalent call inferred; original call site unknown
						break
					end
				end
			end)

			for _, emitter in pairs(folder:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					local rotSpeed = emitter.RotSpeed
					emitter.RotSpeed = NumberRange.new(rotSpeed.Min * 1.5, rotSpeed.Max * 1.5)
				elseif emitter:HasTag("MeshEmitter") then
					emitter:SetAttribute("LockedToPart", true)
					emitter:SetAttribute("Rate", emitter:GetAttribute("Rate") * 3)
				end
			end

			task.delay(0.5, function()
				able({
					FX = folder,
					On = false
				})
			end)
			task.wait(0.1)

			if bind and bind.Parent then
				local v11 = quickFX({
					FX = vfx.Bounce,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, -103)
				})
				v11:ScaleTo(1.1)
				playAttachment(v11)
				Crater.FlyingRocks({
					Origin = humanoidRootPart.CFrame * CFrame.new(0, 0, -103),
					Direction = "Back",
					Amount = 15,
					MinSize = createVector(0.7, 0.7, 0.7),
					MaxSize = createVector(1.6, 1.6, 1.6),
					SpeedMin = 88,
					SpeedMax = 178,
					SpreadAngle = 43,
					Lifetime = 0,
					Gravity = workspace.Gravity,
					Drag = 0.2,
					Bounciness = 0.5,
					Friction = 0.4,
					MaxBounces = 8,
					MinSpeed = 5,
					FadeTime = 0.5,
					LandSide = "up",
					Parent = workspace:FindFirstChild("Thrown"),
					done = function(anchor)
						playAttachment((quickFX({
							FX = vfx.SmokeBoom,
							Maid = object._maid,
							Anchor = anchor
						})))
					end
				})
				task.wait(1.3)

				if bind and bind.Parent then
					Crater.FlyingRocks({
						Origin = humanoidRootPart.CFrame * CFrame.new(0, 0, -30),
						Direction = "Back",
						Amount = 15,
						MinSize = createVector(1.05, 1.05, 1.05),
						MaxSize = createVector(2.4, 2.4, 2.4),
						SpeedMin = 132,
						SpeedMax = 267,
						SpreadAngle = 43,
						Lifetime = 0,
						Gravity = workspace.Gravity,
						Drag = 0.2,
						Bounciness = 0.5,
						Friction = 0.4,
						MaxBounces = 8,
						MinSpeed = 5,
						FadeTime = 0.5,
						LandSide = "up",
						Parent = workspace:FindFirstChild("Thrown"),
						done = function(anchor)
							playAttachment((quickFX({
								FX = vfx.SmokeBoom,
								Maid = object._maid,
								Anchor = anchor
							})))
						end
					})
					return
				end

				Clean() -- equivalent call inferred; original call site unknown
				return
			end
		end

		Clean() -- equivalent call inferred; original call site unknown
	end

	task.spawn(BackEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function Nuclear.SlowEvent(p)
	local data = p.Data
	local char = data.Char
	local charEFP = getCharEFP(char)
	local bind = data.Bind
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local camVal = char:FindFirstChild("CamVal")

	if camVal then
		local _ = camVal.Value
	end

	local victim = data.Victim

	if victim then
		local _ = victim.HumanoidRootPart
	end

	local v6 = game.Players.LocalPlayer.Character == data.Char or game.Players.LocalPlayer.Character == data.Victim
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v7 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v7 then
			v7 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function SlowEvent()
		if v6 then
			local folder = quickFX({
				FX = vfx.Wall,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * vfx.Wall:GetAttribute("Offset"):Inverse()
			})
			task.delay(0.3, function()
				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						TweenService:Create(emitter, TweenInfo.new(1, Enum.EasingStyle.Sine), {
							TimeScale = 0.05
						}):Play()
					end
				end
			end)
			game.Debris:AddItem(folder, 5)
		end

		local clone = script.SlowEmitter:Clone()
		clone.Parent = charEFP
		game.Debris:AddItem(clone, 10)

		if not v6 then
			clone.VignetteUI:Destroy()
		end

		local v8 = MoonEmitter.new(clone)
		v8:SetAnchor(humanoidRootPart.CFrame * script.SlowEmitter:GetAttribute("Offset"):Inverse())
		v8:Play()
		v8:SetTime(16.283333333333335)
		local clockTime = game.Lighting.ClockTime
		object._maid:giveTask(clone:GetAttributeChangedSignal("explo"):Connect(function()
			v8:StopTime()
			game.Lighting.ClockTime = clockTime
		end))

		if v6 then
			local v9 = object._maid:give(Instance.new("BlurEffect"))
			v9.Parent = game.Lighting
			local v10 = object._maid:give(Instance.new("ColorCorrectionEffect"))
			v10.Parent = game.Lighting
			local atmosphere = game.Lighting:FindFirstChild("Atmosphere")

			if atmosphere then
				atmosphere.Parent = game.ReplicatedFirst
			end

			v8:AssignExternal("Lighting", game.Lighting)
			v8:AssignExternal("Blur", v9)
			v8:AssignExternal("ColorCorrection", v10)
			local v11 = object._maid:give(script.HandAttach:Clone())
			v11.Parent = char["Right Arm"]
			task.delay(3, function()
				v8:Destroy()
				v9:Destroy()
				v10:Destroy()
				v11:Destroy()

				if atmosphere then
					atmosphere.Parent = game.Lighting
				end
			end)
		end

		local folder = object._maid:give(vfx["3"]:Clone())
		game.Debris:AddItem(folder, 2)

		for _, emitter in pairs(folder:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Rate *= 12
			local lifetime = emitter.Lifetime
			emitter.Lifetime = NumberRange.new(lifetime.Min / 12, lifetime.Max / 12)
		end

		local v9 = object._maid:give(Instance.new("NumberValue"))
		folder:ScaleTo(0.001)
		v9.Value = folder:GetScale()
		TweenService:Create(v9, TweenInfo.new(1.5, Enum.EasingStyle.Bounce), {
			Value = 1
		}):Play()
		object._maid:giveTask(v9.Changed:Connect(function()
			folder:ScaleTo(v9.Value)
		end))
		folder.Parent = charEFP
		local v10 = object._maid:give(Instance.new("NumberValue"))
		v10.Value = 0.3
		TweenService:Create(v10, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			Value = 0.1
		}):Play()
		task.spawn(function()
			raiseZIndex({
				FX = folder,
				Count = -0.3
			})
			local lastTime = tick()

			while tick() - lastTime < 2 do
				if bind and bind.Parent then
					folder:PivotTo(char["Right Arm"].CFrame * CFrame.new(0, -1 * folder:GetScale(), 0) * CFrame.new(
						random:NextNumber(-v10.Value, v10.Value),
						random:NextNumber(-v10.Value, v10.Value),
						random:NextNumber(-v10.Value, v10.Value)
					))
					dtwait(0.01)
				else
					Clean() -- equivalent call inferred; original call site unknown
					break
				end
			end
		end)
		local clone2 = vfx.GlassEmitter:Clone()
		clone2.Parent = charEFP
		game.Debris:AddItem(clone2, 6)
		local folder2 = object._maid:give(vfx.TempHead:Clone())
		folder2.Parent = charEFP
		local weld = Instance.new("Weld")
		weld.Part0 = folder2
		weld.Part1 = victim.Head
		weld.Parent = folder2

		for _, emitter in pairs(folder2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:SetAttribute("EmitDuration", emitter:GetAttribute("EmitDuration") * 2)
			end
		end

		playAttachment(folder2)
		task.wait(0.4)

		if bind and bind.Parent then
			local v11 = object._maid:give(vfx.PrePunchN1:Clone())
			v11.Parent = charEFP

			for _, child in pairs(v11:GetChildren()) do
				child:PivotTo(humanoidRootPart.CFrame * child:GetAttribute("Offset"):Inverse())
			end

			shared.vfx.emit(v11)
		else
			Clean() -- equivalent call inferred; original call site unknown
		end
	end

	task.spawn(SlowEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function Nuclear.ExploEvent(p)
	local data = p.Data
	local char = data.Char
	local child = game.Workspace.Thrown:FindFirstChild("EFPNUCLEAR_" .. char.Name)

	if child then
		child:FindFirstChild("SlowEmitter"):SetAttribute("explo", true)
		child:Destroy()
	end

	local charEFP = getCharEFP(char)
	local bind = data.Bind
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local camVal = char:FindFirstChild("CamVal")

	if camVal then
		local _ = camVal.Value
	end

	local victim = data.Victim

	if victim then
		local _ = victim.HumanoidRootPart
	end

	local v6 = game.Players.LocalPlayer.Character == data.Char or game.Players.LocalPlayer.Character == data.Victim
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v7 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v7 then
			v7 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function ExploEvent()
		task.wait(0.1)
		local v8 = object._maid:give(Instance.new("NumberValue"))
		v8.Value = 1
		task.delay(0.5, function()
			TweenService:Create(v8, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
				Value = 4
			}):Play()
		end)
		task.delay(0.5, function()
			TweenService:Create(v8, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				Value = 7
			}):Play()
		end)
		local Effectv2b = require(script.Effectv2b)
		local spheres = Effectv2b:Attack(
			humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0),
			7,
			nil,
			v8
		):FindFirstChild("Spheres")

		if spheres then
			object._maid:giveTask(v8.Changed:Connect(function()
				for _, model in pairs(spheres:GetChildren()) do
					if not model:IsA("Model") then
						continue
					end

					local myScale = model:GetAttribute("MyScale")

					if not myScale then
						myScale = model:GetScale()
						model:SetAttribute("MyScale", myScale)
					end

					model:ScaleTo(myScale * v8.Value * 0.5)
				end
			end))

			for _, child2 in pairs(spheres:GetChildren()) do
				if child2.Name ~= "outer" then
					local _ = child2.Name == "lower"
				end
			end
		end

		local clone = vfx.GlassEmitter:Clone()
		clone.Parent = charEFP
		game.Debris:AddItem(clone, 6)
		local v9 = MoonEmitter.new(clone)
		v9:SetAnchor(humanoidRootPart.CFrame * CFrame.new(0.6, -0.9, -5))
		v9:Play()
		v9:SetTime(18.083333333333332)

		if v6 then
			local v10 = object._maid:give(Instance.new("ColorCorrectionEffect"))
			v10.Parent = game.Lighting
			v9:AssignExternal("ColorCorrection", v10)
		end

		task.wait(0.95)
		local v10 = object._maid:give(vfx.BigPunch:Clone())

		for _, child2 in pairs(v10:GetChildren()) do
			child2:PivotTo(humanoidRootPart.CFrame * child2:GetAttribute("Offset"):Inverse())
		end

		shared.vfx.emit(v10)
		require(game.ReplicatedStorage.Resources.CosmicUtils.Part_Icles)
		local v11 = object._maid:give(vfx.BigPunchF:Clone())

		for _, child2 in pairs(v11:GetChildren()) do
			child2:PivotTo(humanoidRootPart.CFrame * child2:GetAttribute("Offset"):Inverse())
		end

		playAttachment((quickFX({
			FX = vfx.RingEmit,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
		})))
		local localPlayer = game.Players.LocalPlayer
		local _ = localPlayer:GetAttribute("S_FastMode") == true
		local _ = localPlayer:GetAttribute("S_PotatoMode") == true

		local function NewSpheres()
			task.wait(0.1)

			if bind and bind.Parent then
				local child2 = game.Workspace.Thrown:FindFirstChild("EFPNUCLEAR_" .. char.Name)

				if child2 then
					child2:Destroy()
				end

				charEFP = getCharEFP(char)
				local folder = object._maid:give(vfx.Presets:Clone())
				folder:PivotTo(humanoidRootPart.CFrame * folder:GetAttribute("Offset"):Inverse() * CFrame.new(0, -30, 0))
				folder:ScaleTo(0.5)
				local children = {}
				local v13 = {}

				for _, emitter in pairs(folder:GetDescendants()) do
					if not (emitter:IsA("ParticleEmitter") and emitter.Name ~= "Balls") then
						continue
					end

					emitter.Rate *= 0.1

					if not (emitter.Name == "31" and emitter.Parent.Name == "Emit") then
						continue
					end

					emitter.Lifetime = NumberRange.new(0.3, 0.3)
					emitter.Rate = 10
				end

				folder.Parent = charEFP
				game.Debris:AddItem(folder, 4)
				local folder2 = object._maid:give(vfx.Presets2:Clone())
				folder2:ScaleTo(0.5)
				folder2:PivotTo(humanoidRootPart.CFrame * folder:GetAttribute("Offset"):Inverse() * CFrame.new(
					0,
					-30,
					0
				) * CFrame.Angles(0, 0, 0))

				for _, emitter in pairs(folder2:GetDescendants()) do
					if not (emitter:IsA("ParticleEmitter") and emitter.Name ~= "Balls") then
						continue
					end

					emitter.Rate *= 0.1

					if not (emitter.Name == "31" and emitter.Parent.Name == "Emit") then
						continue
					end

					emitter.Lifetime = NumberRange.new(0.3, 0.3)
					emitter.Rate = 10
				end

				folder2.Parent = charEFP
				game.Debris:AddItem(folder2, 4)
				BuildScaleCache(folder:GetChildren()[1])
				local v14 = {}
				object._maid:giveTask(RunService.Heartbeat:Connect(function()
					local now = tick()

					for k, v15 in pairs(v14) do
						if k.Parent then
							local v16 = math.clamp((now - v15.startTime) / v15.duration, 0, 1)
							local value = TweenService:GetValue(v16, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
							local v17 = v15.startScale + (v15.targetScale - v15.startScale) * value
							ApplyCachedScale(v15.cache, v17, k:GetPivot())

							if v16 >= 1 then
								v14[k] = nil
							end
						else
							v14[k] = nil
						end
					end
				end))

				local function Sort(folder3)
					local count = 0

					for _, child3 in pairs(folder3:GetChildren()) do
						child3:GetScale()
						local cache = BuildScaleCache(child3)
						ApplyCachedScale(cache, 0.01, child3:GetPivot())
						local name = tonumber(child3.Name)
						local v16 = child3
						task.delay(name * 0.12, function()
							if not v16.Parent then
								return
							end

							count += 1
							local number = random:NextNumber(0.5, 1)
							v14[v16] = {
								cache = cache,
								startScale = 0.01,
								targetScale = 1,
								startTime = tick(),
								duration = number
							}

							if char ~= game.Players.LocalPlayer.Character and victim ~= game.Players.LocalPlayer.Character and shared.OnScreen(char.PrimaryPart.Position) and (game.Players.LocalPlayer.Character.PrimaryPart.Position - char.PrimaryPart.Position).Magnitude <= 200 and name < 7 then
								shared.repfire({
									Effect = "Camshake",
									Intensity = 10,
									Last = name == 6 and 1 or false
								})
							end

							for i, child4 in pairs(v16.Main:GetChildren()) do
								if child4.Name ~= "Main" then
									continue
								end

								table.insert(children, child4)
								TweenService:Create(
									child4,
									TweenInfo.new(
										random:NextNumber(0.4, 1),
										Enum.EasingStyle.Linear,
										Enum.EasingDirection.Out,
										5
									),
									{
										CFrame = child4.CFrame * CFrame.Angles(
											0,
											3.141592653589793,
											(math.rad((random:NextNumber(30, 40))))
										)
									}
								):Play()
							end

							v13[v16] = {}
						end)
					end
				end

				Sort(folder)
				Sort(folder2)
				task.delay(1.5, function()
					for k, _ in pairs(v13) do
						v14[k] = nil
						k:Destroy()
					end
				end)
				local v15 = quickFX({
					FX = vfx.ExploFx,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, 0)
				})
				v15.ok:ScaleTo(1)
				v15.ok:PivotTo(v15.ok:GetPivot() * CFrame.new(0, 10, 0))
				raiseZIndex({
					FX = v15.ExploFx,
					Count = -150
				})

				for _, emitter in pairs(v15.ok:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter.Rate *= 4
					local lifetime = emitter.Lifetime
					emitter.Lifetime = NumberRange.new(lifetime.Min / 4, lifetime.Max / 4)
				end

				task.spawn(function()
					local total = 0
					local heartbeatConnection = nil
					heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
						total += dt

						if total >= 4 then
							heartbeatConnection:Disconnect()
							return
						end

						local cframe = CFrame.Angles(0, 10.471975511965978 * dt, 5.235987755982989 * dt)

						for i = 1, #children do
							local v16 = children[i]

							if v16.Parent then
								v16.CFrame *= cframe
							end
						end
					end)
					object._maid:giveTask(function()
						if heartbeatConnection.Connected then
							heartbeatConnection:Disconnect()
						end
					end)
				end)
			else
				Clean() -- equivalent call inferred; original call site unknown
			end
		end

		NewSpheres()
		task.wait(0.7)
		Nuclear.CamEvent({
			Data = data
		})
	end

	task.spawn(ExploEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function Nuclear.CamEvent(p)
	local data = p.Data
	local char = data.Char
	local charEFP = getCharEFP(char)
	local _ = data.Bind
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local camVal = char:FindFirstChild("CamVal")

	if camVal then
		local _ = camVal.Value
	end

	local victim = data.Victim

	if victim then
		local _ = victim.HumanoidRootPart
	end

	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v6 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v6 then
			v6 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function CamEvent()
		local function Beams()
			local folder = quickFX({
				FX = vfx.Nice,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * vfx.Nice:GetAttribute("Offset"):Inverse()
			})

			for _, beam in pairs(folder:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				local textureSpeed = beam.TextureSpeed
				beam.TextureSpeed *= 14
				TweenService:Create(beam, TweenInfo.new(2, Enum.EasingStyle.Sine), {
					TextureSpeed = textureSpeed
				}):Play()
			end

			if folder then
				task.delay(0.2, function()
					for _, beam in pairs(folder:GetDescendants()) do
						if not beam:IsA("Beam") then
							continue
						end

						playTween(beam, {
							Time = 2.5,
							Goal = {
								Transparency = NumberSequence.new(1)
							}
						})
						game.Debris:AddItem(beam, 2.5)
					end
				end)
			end
		end

		local function RockUp()
			local flyingRocks = Crater.FlyingRocks({
				Origin = humanoidRootPart.CFrame,
				Direction = "Up",
				Amount = 25,
				MinSize = createVector(6.2999997, 6.2999997, 6.2999997),
				MaxSize = createVector(14.400001, 14.400001, 14.400001),
				SpeedMin = 396,
				SpeedMax = 801,
				SpreadAngle = 43,
				Lifetime = 0,
				Gravity = workspace.Gravity,
				Drag = 0.2,
				Bounciness = 0.5,
				Friction = 0.4,
				MaxBounces = 4,
				MinSpeed = 5,
				FadeTime = 0.5,
				LandSide = "up",
				Parent = workspace:FindFirstChild("Thrown"),
				done = function(anchor)
					playAttachment((quickFX({
						FX = vfx.SmokeBoom,
						Maid = object._maid,
						Anchor = anchor
					})))
				end
			})

			for _, flyingRock in pairs(flyingRocks) do
				flyingRock.Material = Enum.Material.Neon
				flyingRock.Color = Color3.new(1, 0.701961, 0.0117647)
				local v7 = random:NextNumber(1, 2) * 8
				TweenService:Create(flyingRock, TweenInfo.new(v7, Enum.EasingStyle.Sine), {
					Color = Color3.new(0, 0, 0)
				}):Play()
				local v8 = flyingRock
				task.delay(v7, function()
					v8.Material = Enum.Material.Slate
				end)
			end
		end

		local function SmokeUp()
			local v7 = object._maid:give(Instance.new("Part"))
			v7.Transparency = 1
			v7.Anchored = true
			v7.CanCollide = false
			v7.CFrame = humanoidRootPart.CFrame * CFrame.Angles(3.141592653589793, 0, 0)
			TweenService:Create(v7, TweenInfo.new(3, Enum.EasingStyle.Back), {
				CFrame = v7.CFrame * CFrame.new(0, -333, 0) * CFrame.Angles(0, 0, 0)
			}):Play()
			v7.Parent = charEFP
			ZLib.MeshEmit:GroupEmit(vfx.FlyMeshes.FlyMeshes:GetChildren(), v7)
		end

		local v7 = quickFX({
			FX = vfx.FlareReal,
			Maid = object._maid,
			Anchor = camera.CFrame
		})
		local cframe = CFrame.new(0, 0, 0)
		task.spawn(function()
			local position = cframe.Position
			local lastTime = tick()

			while tick() - lastTime < 3 do
				local position2 = camera.CFrame.Position
				local magnitude = (position2 - position).Magnitude
				v7:PivotTo(CFrame.new(position, position2) * CFrame.new(0, 0, -magnitude + 10))
				RunService.RenderStepped:Wait()
			end
		end)
		playAttachment(v7)
		SmokeUp()
		Beams()
	end

	task.spawn(CamEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function Nuclear.FlyEvent(p)
	local data = p.Data
	local char = data.Char
	local charEFP = getCharEFP(char)
	local _ = data.Bind
	local _ = char.HumanoidRootPart
	local _ = char.Humanoid
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v6 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v6 then
			v6 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function FlyEvent()
		local v7 = quickWeld({
			FX = vfx.FlyTrail,
			Maid = object._maid,
			P = char.Torso
		})
		v7:ScaleTo(2)

		for _, child in pairs(v7.Part3["1"]:GetChildren()) do
			child.Rate *= 0.5
		end

		game.Debris:AddItem(v7, 1.5)
		local billboardGui = v7.Part3.MainProjectile.BillboardGui
		local size = billboardGui.Size
		billboardGui.Size = UDim2.new(0, 0, 0, 0)
		TweenService:Create(billboardGui, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {
			Size = size
		}):Play()
		task.delay(0.6, function()
			TweenService:Create(billboardGui, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
				Size = UDim2.new(0, 0, 0, 0)
			}):Play()
		end)
		task.spawn(function()
			local lastTime = tick()
			local v8 = object._maid:give(vfx.Track2:Clone())
			v8:PivotTo(char.Torso.CFrame)
			v8.Parent = charEFP
			local count = 0
			local position = nil
			local v9 = {}

			while tick() - lastTime < 1.2 do
				count += 1

				if position and position ~= char.Torso.Position then
					local cframe = CFrame.new(position, char.Torso.Position)

					if count % 10 == 0 then
						local clone = vfx.Last3:Clone()
						clone:ScaleTo(6)
						playMesh({
							Model = clone,
							T = 0.5,
							EndT = 1,
							Anchor = cframe * CFrame.new(0, 0, -10) * CFrame.Angles(1.5707963267948966, 0, 0),
							Info = TweenInfo.new(0.45, Enum.EasingStyle.Sine)
						})
						local v10 = quickFX({
							FX = vfx.RingEmit2,
							Maid = object._maid,
							Anchor = clone:GetPivot()
						})
						v10:ScaleTo(2)
						playAttachment(v10)
						table.insert(v9, v10)
					end

					local _ = (v8:GetPivot().Position - cframe.Position).Magnitude
					local _, _, _ = cframe:ToOrientation()
					v8:PivotTo(cframe * CFrame.Angles(0, -1.5707963267948966, 0) * CFrame.Angles(
						random:NextNumber(0, 4),
						0,
						0
					))
					v8:ScaleTo(random:NextNumber(0.9, 1.1))
				end

				if char:GetPivot().Position ~= position then
					position = char.Torso.Position
				end

				task.wait(0.01)
			end

			for _, v10 in pairs(v9) do
				v10:Destroy()
			end

			v8:Destroy()
		end)
	end

	task.spawn(FlyEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function Nuclear.DoneEvent(p)
	local data = p.Data
	local char = data.Char
	getCharEFP(char)
	local _ = data.Bind
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v6 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v6 then
			v6 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function DoneEvent()
		local _ = humanoidRootPart.CFrame
		local v7 = object._maid:give(Instance.new("Highlight"))
		v7.FillColor = Color3.new(0, 0, 0)
		v7.DepthMode = Enum.HighlightDepthMode.Occluded
		v7.FillTransparency = 0.3
		v7.OutlineTransparency = 1
		v7.Parent = char
		task.delay(0.3, function()
			TweenService:Create(v7, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				FillTransparency = 1
			}):Play()
			playAttachment((quickFX({
				FX = vfx.General,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
			})))
			playAttachment((quickFX({
				FX = vfx.justSmoke2,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0) * CFrame.Angles(
					0,
					1.5707963267948966,
					0
				),
				Maid = object._maid
			})))
		end)

		for i = 1, 3 do
			local FX = quickFX({
				FX = vfx.Up,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, (i - 1) * 30 - 2, 0),
				Maid = object._maid
			})
			FX:ScaleTo(i * 0.5 + 0.5)
			lifeScale({
				FX = FX,
				Scale = i * 0.5
			})
			playAttachment(FX)
		end

		local FX2 = quickFX({
			FX = vfx.YesPls,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0),
			Maid = object._maid
		})
		FX2:ScaleTo(4)
		lifeScale({
			FX = FX2,
			Scale = 1
		})
		local FX3 = quickFX({
			FX = vfx.BigAura,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0),
			Maid = object._maid
		})
		able({
			FX = FX3,
			On = true
		})
		task.delay(0.2, function()
			able({
				FX = FX3,
				On = false
			})
			quickFX({
				FX = vfx.justSmoke,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0),
				Maid = object._maid
			})
		end)
		task.spawn(function()
			local cframe = CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
			local FX = quickFX({
				FX = vfx.Lines,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * cframe
			})
			able({
				FX = FX,
				On = true
			})
			task.delay(0.4, function()
				able({
					FX = FX,
					On = false
				})
			end)
			local FX4 = quickFX({
				FX = vfx.GroundSmoke,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * cframe
			})
			able({
				FX = FX4,
				On = true
			})
			local v12 = object._maid:give(Instance.new("NumberValue"))
			object._maid:giveTask(v12.Changed:Connect(function()
				FX:ScaleTo(v12.Value)
				FX4:ScaleTo(v12.Value)
			end))
			v12.Value = 3.5
			TweenService:Create(v12, TweenInfo.new(2.3, Enum.EasingStyle.Sine), {
				Value = 1
			}):Play()
			local lastTime = tick()
			local count = 0

			while tick() - lastTime < 0.5 do
				count += 1
				FX:SetPrimaryPartCFrame(humanoidRootPart.CFrame * cframe)

				if count % 8 == 0 then
					local clone = vfx.SlowGrad:Clone()
					clone:ScaleTo(random:NextNumber(0.5, 0.6) * v12.Value)
					playMesh({
						Model = clone,
						Anchor = humanoidRootPart.CFrame * CFrame.new(0, -5, 0) * CFrame.Angles(
							0,
							math.rad((math.random(0, 360))),
							1.5707963267948966
						),
						Info = TweenInfo.new(0.15, Enum.EasingStyle.Sine)
					})

					if tick() - lastTime > 0.7 then
						local clone2 = vfx.Black:Clone()
						clone2:ScaleTo(random:NextNumber(0.2, 0.3) * v12.Value)
						playMesh({
							Model = clone2,
							Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0) * CFrame.Angles(
								0,
								math.rad((math.random(0, 360))),
								0
							),
							Info = TweenInfo.new(0.25, Enum.EasingStyle.Sine)
						})
					end

					local _ = tick() - lastTime > 0.5
					local clone2 = math.random(1, 2) == 1 and vfx.ERM:Clone() or vfx.ERM2:Clone()
					clone2:ScaleTo(random:NextNumber(0.8, 1) * v12.Value * 1.3)
					playMesh({
						Model = clone2,
						EndT = 1,
						Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0) * CFrame.Angles(
							0,
							0,
							1.5707963267948966
						),
						Info = TweenInfo.new(0.25, Enum.EasingStyle.Sine)
					})
				end

				if count % 16 == 0 then
					local clone = vfx.ReverseWind:Clone()
					clone:ScaleTo(random:NextNumber(0.5, 0.6) * v12.Value)
					playMesh({
						Model = clone,
						Anchor = humanoidRootPart.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(
							0,
							math.rad((math.random(0, 360))),
							0
						),
						Info = TweenInfo.new(0.15, Enum.EasingStyle.Sine)
					})
				end

				task.wait()
			end

			able({
				FX = FX4,
				On = false
			})
		end)
	end

	task.spawn(DoneEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return Nuclear
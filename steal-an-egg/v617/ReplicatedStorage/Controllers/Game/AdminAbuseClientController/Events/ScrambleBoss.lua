local createVector = vector.create
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ContentProvider = game:GetService("ContentProvider")
local Environment = require(ReplicatedStorage.Shared.Modules.Environment)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local ScrambleBossFlags = require(ReplicatedStorage.Shared.Flags.ScrambleBossFlags)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Cinematic = require(script.Cinematic)
local HazardView = require(script.HazardView)
local Kit = require(script.Kit)
local Music = require(script.Music)
local Presentation = require(script.Presentation)
local Rider = require(script.Rider)
local Rigs = require(script.Rigs)
local Transition = require(script.Transition)
local Vfx = require(script.Vfx)
local v = {
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.UserInputType.Touch] = true
}
local v2 = {
	[Enum.KeyCode.Space] = true,
	[Enum.KeyCode.ButtonA] = true,
	[Enum.KeyCode.ButtonX] = true,
	[Enum.KeyCode.ButtonR2] = true
}
local color = Color3.new(1, 1, 1)
local color2 = Color3.fromRGB(120, 235, 255)
local v3 = Trove.new()
local random = Random.new()
local v4 = false
local localPlayer = Players.LocalPlayer
local flag = false

local function coilBolts(vector2: Vector3, vector3: Vector3)
	local folder = Instance.new("Folder")
	folder.Name = "CoilBolts"
	folder.Parent = Kit.Debris()
	Debris:AddItem(folder, 0.6)

	for i = 1, 3 do
		local v5 = { vector2 }

		for i2 = 1, 5 do
			table.insert(v5, vector2:Lerp(vector3, i2 / 6) + random:NextUnitVector() * 3.5)
		end

		table.insert(v5, vector3)
		local v6 = i == 1 and 0.5 or 0.3

		for i2 = 1, #v5 - 1 do
			local v7 = v5[i2]
			local v8 = v5[i2 + 1]
			local part = Kit.Part
			local color3

			if i == 1 then
				color3 = color
			else
				color3 = color2
			end

			part({
				Name = "Bolt",
				Color = color3,
				Size = Vector3.new(v6, v6, (v8 - v7).Magnitude),
				CFrame = CFrame.lookAt((v7 + v8) / 2, v8),
				Parent = folder
			})
		end
	end
end

local function bindArena(instance)
	local maid = v3:Extend()
	maid:Connect(instance.AncestryChanged, function()
		if not instance:IsDescendantOf(Workspace) then
			maid:Destroy()
		end
	end)
	local v5 = Presentation.new(maid, instance)
	Music.new(maid, instance, v5)
	local v6 = HazardView.new(maid, instance)
	local v7 = nil

	local function bindActor(model)
		if not model:IsA("Model") then
			return
		end

		local extended = maid:Extend()
		extended:Connect(model.AncestryChanged, function()
			if not model:IsDescendantOf(instance) then
				extended:Destroy()
			end
		end)

		if model.Name == "Mech" then
			v7 = Rigs.Mech(extended, model)
		elseif model.Name == "Croc" then
			Rider.Mount(extended, model)
		elseif model.Name == "Ball" then
			model:WaitForChild("Root", 5)

			if model.PrimaryPart then
				Rigs.Ball(extended, model, instance)
			end
		end
	end

	local function bindDrone(model)
		if not model:IsA("Model") then
			return
		end

		local extended = maid:Extend()
		extended:Connect(model.AncestryChanged, function()
			if not model:IsDescendantOf(Workspace) then
				extended:Destroy()
			end
		end)
		Rigs.Drone(extended, model)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function watchDrones(instance2)
		maid:Connect(instance2.ChildAdded, bindDrone)

		for _, child in instance2:GetChildren() do
			bindDrone(child)
		end
	end

	local now = 0
	local v8 = nil
	local v9 = nil

	for _, child in instance:GetChildren() do
		bindActor(child)

		if child.Name ~= "Drones" then
			continue
		end

		watchDrones(child) -- equivalent call inferred; original call site unknown
	end

	maid:Connect(instance.ChildAdded, function(instance2)
		bindActor(instance2)

		if instance2.Name == "Drones" then
			watchDrones(instance2) -- equivalent call inferred; original call site unknown
		end
	end)

	local function syncHold()
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.PlatformStand = localPlayer:GetAttribute("ScrambleGrabbed") == true or localPlayer:GetAttribute("ScrambleThrown") ~= nil
		end
	end

	maid:Connect(localPlayer:GetAttributeChangedSignal("ScrambleGrabbed"), syncHold)
	maid:Connect(localPlayer:GetAttributeChangedSignal("ScrambleThrown"), syncHold)
	maid:Connect(UserInputService.InputBegan, function(p, flag2: boolean)
		if not localPlayer:GetAttribute("ScrambleGrabbed") then
			return
		end

		local v10

		if v[p.UserInputType] == true then
			v10 = true
		elseif v2[p.KeyCode] == true then
			v10 = not flag2
		else
			v10 = false
		end

		if not v10 or os.clock() - now < 0.07 then
			return
		end

		now = os.clock()
		Remotes.ScrambleBoss.HazardHit:FireServer(-2)
		Kit.Sound("Tick", nil, 0.8, 1.3 + math.random() * 0.4)
		Kit.Shake(1.5, 30, 0.15)
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clearRescue()
		if v8 then
			v8:Destroy()
		end

		v8 = nil
		v9 = nil
	end

	maid:Add(clearRescue)
	maid:Connect(RunService.RenderStepped, function()
		local grabVictim = instance:GetAttribute("GrabVictim") or 0
		local mech = instance:FindFirstChild("Mech")
		local grabRescue = mech and mech:FindFirstChild("GrabRescue")

		if grabVictim == 0 or grabVictim == localPlayer.UserId or grabRescue == nil then
			clearRescue() -- equivalent call inferred; original call site unknown
		else
			if v9 ~= grabRescue then
				clearRescue() -- equivalent call inferred; original call site unknown
				local folder = Instance.new("Folder")
				folder.Name = "ScrambleRescue"
				local ground = Vfx.Ground(grabRescue.Position, instance:GetAttribute("FloorY"))
				Kit.Part({
					Name = "Disc",
					Shape = Enum.PartType.Cylinder,
					Color = Kit.Green,
					Transparency = 0.5,
					Size = Vector3.new(0.3, grabRescue.Size.X, grabRescue.Size.Z),
					CFrame = CFrame.new(ground + createVector(0, 0.2, 0)) * CFrame.Angles(0, 0, 1.5707963267948966),
					Parent = folder
				})
				Kit.Part({
					Name = "Pillar",
					Shape = Enum.PartType.Cylinder,
					Color = Kit.Green,
					Transparency = 0.6,
					Size = Vector3.new(grabRescue.Size.Y, 2.5, 2.5),
					CFrame = CFrame.new(ground + Vector3.new(0, grabRescue.Size.Y / 2, 0)) * CFrame.Angles(
						0,
						0,
						1.5707963267948966
					),
					Parent = folder
				})
				folder.Parent = Kit.Debris()
				v8 = folder
				v9 = grabRescue
			end

			local midpoint = (math.sin(os.clock() * 8) + 1) / 2

			for _, part in v8:GetChildren() do
				if not part:IsA("BasePart") then
					continue
				end

				local transparency

				if part.Name == "Disc" then
					transparency = midpoint * 0.3 + 0.35
				else
					transparency = midpoint * 0.3 + 0.5
				end

				part.Transparency = transparency
			end
		end
	end)
	maid:Connect(Remotes.ScrambleBoss.Hazard.OnClientEvent, function(p)
		v6:Add(p)
	end)

	local function coilTop(coil: string)
		local coils = instance:FindFirstChild("Coils")
		local model = coils and coils:FindFirstChild(coil)

		if model == nil then
			return nil
		end

		local top = model:FindFirstChild("Top")

		if top and top:IsA("BasePart") then
			return top.Position
		end

		if not model:IsA("Model") then
			return nil
		end

		local boundingBox, v10 = model:GetBoundingBox()
		return boundingBox.Position + Vector3.new(0, v10.Y / 2, 0)
	end

	local function coilBurst(coil: string)
		local coils = instance:FindFirstChild("Coils")
		local folder = coils and coils:FindFirstChild(coil)

		if folder == nil then
			return
		end

		for _, emitter in folder:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter.Name == "AreaLightning" and 4 or 1)
			end
		end
	end

	local function floor(vector2: Vector3)
		return Vfx.Ground(vector2, instance:GetAttribute("FloorY"))
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function slam(vector2: Vector3, p: number)
		Vfx.Burst("Slam", CFrame.new(floor(vector2)), p)
	end

	local function hold(object, duration: number)
		if object == nil then
			return
		end

		maid:Add(task.delay(duration, function()
			object:Stop()
		end))
		maid:Add(function()
			object:Stop()
		end)
	end

	local function zap(worldPosition: Vector3, fn, p: number)
		local hold2 = Vfx.Hold("LaserBeam", CFrame.new(worldPosition))

		if hold2 == nil then
			return
		end

		local v10 = nil
		local v11 = nil
		local v12 = {}
		local v13 = {}

		for _, beam in hold2.Root:GetDescendants() do
			if not (beam:IsA("Beam") and beam.Attachment0 and beam.Attachment1) then
				continue
			end

			v10 = v10 or beam.Attachment0.WorldPosition
			v11 = v11 or beam.Attachment1.WorldPosition
		end

		for _, attachment in hold2.Root:GetDescendants() do
			if not attachment:IsA("Attachment") then
				continue
			end

			local worldPosition2 = attachment.WorldPosition
			local v14

			if (not v11 and 1e999 or (worldPosition2 - v11).Magnitude) < (not v10 and 0 or (worldPosition2 - v10).Magnitude) then
				v14 = v12
			else
				v14 = v13
			end

			table.insert(v14, attachment)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function place()
			local worldPosition2 = fn()

			for _, v15 in v13 do
				v15.WorldPosition = worldPosition
			end

			for _, v15 in v12 do
				v15.WorldPosition = worldPosition2
			end
		end

		place() -- equivalent call inferred; original call site unknown
		local lastTime = os.clock()
		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			place() -- equivalent call inferred; original call site unknown

			if p <= os.clock() - lastTime then
				if renderSteppedConnection then
					renderSteppedConnection:Disconnect()
				end

				hold2:Stop()
			end
		end)
		maid:Add(function()
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
			end

			hold2:Stop()
		end)
	end

	local function ballPosition(at: Vector3)
		local ball = instance:FindFirstChild("Ball")

		if ball == nil or not ball:IsA("Model") then
			return at
		end

		local drScrambleBall = ball:FindFirstChild("DrScrambleBall", true)

		if drScrambleBall and drScrambleBall:IsA("Model") then
			return drScrambleBall:GetBoundingBox().Position
		end

		if ball.PrimaryPart then
			return ball.PrimaryPart.Position
		end

		return at
	end

	local v10 = {
		MechIncoming = function(_)
			v5:Say("INCOMING!", nil, 1.5)
			Kit.Sound("Charge", nil, 1.2, 0.7)
		end,
		MechLand = function(p)
			Kit.Shake(8, 14, 1.4)
			Kit.Sound("ShockwaveRing", p.At, 1.2)
			slam(p.At, 1.1) -- equivalent call inferred; original call site unknown
		end,
		Stomp = function(p)
			local v11 = p.Kind == "Slam"
			Kit.ShakeFrom(p.At, v11 and 11 or 8, 520)
			Kit.Sound("ShockwaveRing", p.At, v11 and 1.2 or 1)
			local at = p.At
			Vfx.Burst("Slam", CFrame.new(floor(at)), v11 and 1 or 0.8)
		end,
		Swipe = function(data)
			local flat = Kit.Flat(data.Direction or createVector(0, 0, 0))
			local v11 = flat.Magnitude < 0.1 and createVector(0, 0, 1) or flat
			local origin = data.Origin or data.At
			local v12 = Vfx.Ground(origin, instance:GetAttribute("FloorY")) + createVector(0, 9, 0)
			local frame = Vfx.Frame("BossSwipe", v12, v11)

			if (data.Side or 1) < 0 then
				frame = CFrame.new(v12) * CFrame.fromAxisAngle(v11.Unit, 3.141592653589793) * frame.Rotation
			end

			local template = Vfx.Template("BossSwipe")
			local referenceRadius = template and template:GetAttribute("ReferenceRadius")
			local v13 = typeof(referenceRadius) ~= "number" and 21 or referenceRadius
			local v14 = (data.Radius or 46) * 0.85 / v13
			Vfx.Burst("BossSwipe", frame, v14, 0.3)
			Kit.Sound("WideArmSwipe", data.At, 1.2)
			Kit.ShakeFrom(data.At, 5, 180)
		end,
		LaserCharge = function(_)
			Kit.Sound("Charge", nil, 0.9, 1.1)
		end,
		RushDash = function(p)
			local mech = instance:FindFirstChild("Mech")
			local primaryPart = mech and mech:IsA("Model") and mech.PrimaryPart

			if primaryPart == nil then
				return
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function frame()
				local flat = Kit.Flat(primaryPart.CFrame.LookVector)
				local v11 = not (flat.Magnitude > 0.1) and createVector(0, 0, 1) or flat.Unit
				local position = primaryPart.Position
				local v12 = Vfx.Ground(position, instance:GetAttribute("FloorY")) + v11 * 34 + createVector(0, 30, 0)
				return Vfx.Frame("SpiderSlashes", v12, v11)
			end

			Vfx.Burst("SpiderSlashes", frame(), 1, 0.35)
			Kit.Sound("SpiderRush", primaryPart, 1)
			local hold2 = Vfx.Hold("SpiderSlashes", frame())

			if hold2 == nil then
				return
			end

			local v11 = os.clock() + (p.Seconds or 0.5)
			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if not (v11 <= os.clock()) and primaryPart.Parent ~= nil then
					hold2:Move(frame())
					return
				end

				if renderSteppedConnection then
					renderSteppedConnection:Disconnect()
				end

				hold2:Stop()
			end)
			maid:Add(function()
				if renderSteppedConnection then
					renderSteppedConnection:Disconnect()
				end

				hold2:Stop()
			end)
		end,
		RushStop = function(p)
			Kit.ShakeFrom(p.At, 6, 250)
			Kit.Sound("HeavyLand", p.At, 1.2)
			slam(p.At, 0.45) -- equivalent call inferred; original call site unknown
		end,
		GrabReach = function(p)
			Kit.Sound("Swoosh", p.At, 1.6, 0.55)
			Kit.Sound("Charge", p.At, 0.8, 1.3)
		end,
		GrabMiss = function(p)
			Kit.Sound("HeavyLand", p.At, 1, 1.2)
			Kit.ShakeFrom(p.At, 4, 160)
			slam(p.At, 0.4) -- equivalent call inferred; original call site unknown
		end,
		Grab = function(p)
			Kit.Sound("Chomp", nil, 1.5, 0.6)
			Kit.Sound("Boom", nil, 0.8, 1.2)
			local playerByUserId = Players:GetPlayerByUserId(p.UserId or 0)

			if p.UserId ~= localPlayer.UserId then
				v5:Say(`SAVE {string.upper(playerByUserId and playerByUserId.DisplayName or "THEM")}!`, nil, 2.5)
				return
			end

			Kit.Shake(6, 18, 0.6)
			v5:FlashScreen(Kit.Red, 0.6, 0.4)
			v5:Say("YOU'VE BEEN GRABBED!", nil, 2)
		end,
		GrabHit = function(_)
			local grabFree = instance:GetAttribute("GrabFree") or 0
			local v11 = math.max(instance:GetAttribute("GrabNeeded") or 1, 1)
			Kit.Sound("BatHit", nil, 1, 0.8 + grabFree / v11 * 0.6)
			Kit.Shake(2, 20, 0.25)
		end,
		GrabBreak = function(p)
			Kit.Sound("Boom", p.At, 1.2, 1.3)
			Kit.Sound("Pop", p.At, 1.5)
			Kit.Shake(5, 16, 0.6)

			if p.At then
				Vfx.Glitch(p.At, 1.4, 0.35)
			end

			local playerByUserId = Players:GetPlayerByUserId(p.UserId or 0)
			v5:Say(
				p.UserId == localPlayer.UserId and "BROKE FREE!" or `{string.upper(playerByUserId and playerByUserId.DisplayName or "THEY")} IS FREE!`,
				nil,
				1.6
			)
		end,
		Throw = function(p)
			Kit.Sound("Swoosh", nil, 2, 0.5)

			if p.UserId == localPlayer.UserId then
				Kit.Shake(7, 14, 1)
				v5:FlashScreen(Color3.new(1, 1, 1), 0.35, 0.3)
			end
		end,
		ThrowLand = function(p)
			Kit.ShakeFrom(p.At, 6, 180)
			Kit.Sound("HeavyLand", p.At, 1.1)
			slam(p.At, 0.35) -- equivalent call inferred; original call site unknown
		end,
		MechHit = function(p)
			if v7 then
				v7.Hit(p.Overheated == true)
			end
		end,
		Overheat = function(_)
			Kit.Sound("DrScrambleOverheating", nil, 1)
			v5:Say("HE'S OVERHEATING! HIT HIM NOW!", nil, 3)
		end,
		PhaseTwo = function(_)
			Kit.Shake(5, 10, 1.5)
			Kit.Sound("Roar", nil, 1.2, 0.7)
		end,
		Callout = function(data)
			v5:Say(data.Text or "", data.Speaker, data.Seconds)
		end,
		CrocWarn = function(_)
			v5:Say("GET THEM!", "Dr. Scramble", 2)
			Kit.Sound("DrScrambleLaughing", nil, 1)

			for i = 0, 5 do
				task.delay(i * 0.3, function()
					Kit.Sound("Tick", nil, 1, 1.8)
				end)
			end
		end,
		CrocLand = function(p)
			Kit.ShakeFrom(p.At, 8, 500)
			Kit.Sound("CrocShockwave", p.At, 1.2)
			Vfx.Burst("CrocLeap", CFrame.new(floor(p.At)), 1)
		end,
		CrocTarget = function(self)
			if self.UserId == localPlayer.UserId then
				Kit.Sound("TargetLock", nil, 1)
			end

			v5:CrocTarget(self.UserId or 0, ScrambleBossFlags.CrocChaseSeconds:Get() + 0.6)
		end,
		CrocBite = function(p)
			Kit.Sound("ChaseBite", p.At, 1.2)
			Kit.ShakeFrom(p.At, 3.5, 140)
		end,
		CrocSweep = function(p)
			Kit.Sound("TailSweep", p.At, 1.2)
			Kit.ShakeFrom(p.At, 4, 200)
			local croc = instance:FindFirstChild("Croc")
			local v11 = not (croc and croc:IsA("Model")) and createVector(0, 0, 1) or Kit.Flat(croc:GetPivot().LookVector)
			local crocScale = Vfx.CrocScale(instance)
			local at = p.At
			local v12 = Vfx.Ground(at, instance:GetAttribute("FloorY")) + Vector3.new(0, 2.34 * crocScale, 0)
			Vfx.Burst("CrocTail", Vfx.Frame("CrocTail", v12, v11), crocScale * 1.6)
		end,
		CrocCharge = function(p)
			Kit.Sound("Roar", p.At, 1.2, 1.1)
		end,
		CrocLeave = function(p)
			Vfx.Burst("CrocLeap", CFrame.new(floor(p.At)), 0.6)
			Kit.Sound("DrScrambleLaughing", nil, 1)
			v5:Say("HAHAHA! GOOD BOY!", "Dr. Scramble", 2)
		end,
		DroneSpawn = function(p)
			hold(Vfx.Hold("DroneSummon", CFrame.new(p.At)), 0.9)
		end,
		DroneBoom = function(p)
			slam(p.At, 0.35) -- equivalent call inferred; original call site unknown
			Kit.Sound("Boom", p.At, 1)
			Kit.ShakeFrom(p.At, 5, 80)
		end,
		DroneHit = function(p)
			Kit.Sound("BatHit", p.At, 0.7, 1.25)
		end,
		DronePop = function(p)
			Vfx.Glitch(p.At, 1.2, 0.3)
			Kit.Sound("BatHit", p.At, 1)
		end,
		EjectStart = function(p)
			v5:Say("SYSTEM FAILURE!", nil, 1.6)
			local open = p.Open or 1.3
			Kit.Sound("DrScrambleEjecting", nil, 1)
			hold(Vfx.Hold("DroneSummon", CFrame.new(p.At), 2.2), open)
			Kit.Shake(2, 25, open + 0.4)
		end,
		Eject = function(p)
			Vfx.Glitch(p.At, 2.2, 0.35)
			Kit.Shake(6, 16, 1.1)
		end,
		MechWreck = function(p)
			local mech = instance:FindFirstChild("Mech")
			local v11

			if mech and mech:IsA("Model") then
				local _, v12 = mech:GetBoundingBox()
				v11 = v12.Y * 0.45
			else
				v11 = 30
			end

			local hold2 = Vfx.Hold
			local at = p.At
			hold(
				hold2(
					"DroneSummon",
					CFrame.new(Vfx.Ground(at, instance:GetAttribute("FloorY")) + Vector3.new(0, v11, 0)),
					3
				),
				p.Seconds or 25
			)
		end,
		MechDespawn = function(p)
			Vfx.Glitch(p.At, 3, 0.35)
			Kit.Sound("Pop", p.At, 1.6)
		end,
		SuitImpact = function(p)
			Kit.Shake(12, 12, 2)
			Kit.Sound("HeavyLand", nil, 2)
			Kit.Sound("Boom", nil, 1.5)

			for k, v11 in p.Points or {} do
				local v12 = v11
				task.delay(k * 0.04, function()
					slam(v12, 0.6) -- equivalent call inferred; original call site unknown
				end)
			end
		end,
		BallLand = function(p)
			local v11 = p.Big and 1.5 or 1
			Kit.ShakeFrom(p.At, v11 * 10, 420)
			Kit.Sound("HeavyLand", p.At, 1.6)
			Kit.Sound("Boom", p.At, 1.1, 0.9)
			Vfx.Burst("CrocLeap", CFrame.new(floor(p.At)), p.Big and 0.9 or 0.5850000000000001)
		end,
		BallBounce = function(p)
			Kit.Sound("HeavyLand", p.At, 0.7, 1.25)
			Kit.ShakeFrom(p.At, 3, 200)
			slam(p.At, 0.3) -- equivalent call inferred; original call site unknown
		end,
		CoilsRise = function(_)
			Kit.Sound("Rumble", nil, 1, 1.2)
			Kit.Shake(2, 20, 2.2)
			local coils = instance:FindFirstChild("Coils")

			for _, v11 in not coils and {} or coils:GetChildren() do
				local home = v11:GetAttribute("Home")

				if typeof(home) == "Vector3" then
					Vfx.Burst("CrocLeap", CFrame.new(floor(home)), 0.45)
				end
			end
		end,
		BallTarget = function(p)
			if p.UserId == localPlayer.UserId then
				Kit.Sound("TargetLock", nil, 1)
				v5:FlashScreen(Kit.Red, 0.5, 0.35)
			end
		end,
		BallBump = function(p)
			Kit.ShakeFrom(p.At, 5, 60)
			Kit.Sound("Boom", p.At, 0.8, 1.3)
		end,
		CoilZap = function(p)
			local worldPosition = coilTop(p.Coil or "") or p.At
			Kit.Sound("Tesla", worldPosition, 1.5)
			Kit.ShakeFrom(worldPosition, 6, 300)
			zap(worldPosition, function()
				return (ballPosition(p.At))
			end, 0.6)
			Vfx.Glitch(ballPosition(p.At), 1.8, 0.6)
			coilBurst(p.Coil or "")
			Vfx.Burst("LightningSurge", CFrame.new((ballPosition(p.At))), 3)
			Vfx.Burst("LightningSurge", CFrame.new(worldPosition), 2)

			for i = 0, 5 do
				maid:Add(task.delay(i * 0.12, function()
					coilBolts(worldPosition, ballPosition(p.At) + random:NextUnitVector() * 3)
				end))
			end
		end,
		CoreHit = function(p)
			Kit.Sound("BatHit", p.At, 0.8, 0.8 + math.random() * 0.2)
			Kit.Sound("Zap", p.At, 0.35, 1.3 + math.random() * 0.3)
			Vfx.Glitch(p.At, 0.9, 0.2)
		end,
		CoreCrack = function(data)
			Kit.Sound("Zap", data.At, 1.4, 0.8)
			Kit.Sound("HeavyLand", data.At, 0.9, 1.3)
			Kit.Shake(4, 18, 0.8)
			Vfx.Glitch(data.At, 1.8, 0.6)
			local stage = data.Stage or 1
			local needed = data.Needed or 3
			v5:Say(
				stage == 1 and "CORE DAMAGED!" or stage < needed and "CORE CRITICAL!" or "CORE OVERLOADED!",
				nil,
				1.8
			)
		end,
		CoreBurst = function(p)
			Kit.Sound("Boom", p.At, 1.2)
			Kit.Sound("Zap", p.At, 2, 0.7)
			Kit.Shake(8, 16, 1.2)
			slam(p.At, 0.7) -- equivalent call inferred; original call site unknown
			Vfx.Glitch(p.At, 2.52, 0.7)
		end,
		HumanHit = function(p)
			Kit.Sound("BatHit", p.At, 1.5)
			Kit.ShakeFrom(p.At, 3, 80)
		end,
		FinalHit = function(p)
			task.spawn(Cinematic.FinalHit, maid, instance, v5, p)
		end,
		Defeated = function(_)
			v5:Say("DR. SCRAMBLE DEFEATED!", nil, 5)
		end
	}
	maid:Connect(RunService.RenderStepped, Vfx.Sample)
	maid:Connect(Remotes.ScrambleBoss.Fx.OnClientEvent, function(p: string, options)
		local v11 = v10[p]

		if v11 then
			local success, result = pcall(v11, options or {})

			if not success then
				warn((`[ScrambleBoss] fx {p} failed: {result}`))
			end
		end
	end)
end

local function warmAssets()
	local v5 = {
		MeshPart = true,
		Decal = true,
		Animation = true,
		ParticleEmitter = true,
		Beam = true,
		ImageLabel = true,
		Sound = true
	}
	local descendants = {}

	for _, folder in { ReplicatedStorage.CutsceneAssets.ScrambleBossCutsceneAssets } do
		for _, descendant in folder:GetDescendants() do
			local flag2 = false

			for className in v5 do
				if not descendant:IsA(className) then
					continue
				end

				flag2 = true
				break
			end

			if flag2 then
				table.insert(descendants, descendant)
			end
		end
	end

	print((`[{script.Name}] Preloading {#descendants} assets`))
	ContentProvider:PreloadAsync(descendants)
	print((`[{script.Name}] Preloading completed`))
end

task.spawn(function()
	local now = os.time()

	if RunService:IsStudio() and now < 1790434800 then
		warmAssets()
	elseif now < 1790431200 then
		task.wait(1790431200 - now)
		task.delay(math.random(180), warmAssets)
	elseif now < 1790434800 then
		task.delay(math.random(60), warmAssets)
	end
end)

local function joinAdminFight()
	Transition.Cover()
	local success, result = pcall(function()
		return Remotes.ScrambleBoss.EnterArena:InvokeServer()
	end)

	if not success or result ~= true then
		Transition.Reveal()
	end
end

local ScrambleBoss = {
	StartEvent = function(_, _: number, data)
		local isTestPlace = Environment.IsTestPlace()

		if isTestPlace then
			if data == nil then
				isTestPlace = false
			else
				isTestPlace = data.Testing == true
			end
		end

		if not (ScrambleBossFlags.ContentEnabled:Get() or isTestPlace) then
			return
		end

		v3:Clean()
		flag = false
		local v5

		if data == nil then
			v5 = false
		else
			v5 = type(data.StarterUserId) == "number"
		end

		if v5 and data and not data.SkipCutscenes then
			xpcall(function()
				local IntroCutscene1 = require(script.Cutscenes.IntroCutscene1)
				IntroCutscene1(v3).Run()
				local IntroCutscene2 = require(script.Cutscenes.IntroCutscene2)
				IntroCutscene2(v3).Run()
				v3:Clean()
				flag = true
			end, function(p)
				warn((`[{script.Name}] {p}`))
			end)
		end

		v4 = true
		local scrambleArena = Workspace:FindFirstChild("ScrambleArena")

		if scrambleArena and scrambleArena:IsA("Model") then
			task.defer(bindArena, scrambleArena)
		end

		v3:Connect(Workspace.ChildAdded, function(model)
			if model.Name == "ScrambleArena" and model:IsA("Model") and v4 then
				task.defer(bindArena, model)
			end
		end)

		if v5 then
			task.spawn(joinAdminFight)
		end
	end,
	StopEvent = function(_)
		v3:Clean()
		v4 = false

		if flag then
			flag = false
			xpcall(function()
				local OutroCutscene1 = require(script.Cutscenes.OutroCutscene1)
				OutroCutscene1(v3).Run()
				local OutroCutscene2 = require(script.Cutscenes.OutroCutscene2)
				OutroCutscene2(v3).Run()
				v3:Clean()
			end, function(p)
				warn((`[{script.Name}] {p}`))
			end)
		end
	end
}
Transition.Listen()
return ScrambleBoss
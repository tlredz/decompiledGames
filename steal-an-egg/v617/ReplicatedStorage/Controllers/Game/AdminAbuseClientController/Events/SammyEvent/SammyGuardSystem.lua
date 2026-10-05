local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CameraShaker = require(ReplicatedStorage.Packages.CameraShaker)
local Player = require(ReplicatedStorage.Shared.Player)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local SammyEventFlags = require(ReplicatedStorage.Shared.Flags.SammyEventFlags)
require(ReplicatedStorage.Packages.Trove)
local explosionVFX = ReplicatedStorage.Assets.Particles:WaitForChild("SammyEventVFX"):WaitForChild("ExplosionVFX")
local explosion = ReplicatedStorage.Assets.Sounds:WaitForChild("Explosion")
local color = Color3.fromRGB(255, 40, 40)
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local strawberryElephantAttacker = ReplicatedStorage.Assets:WaitForChild("SammyEventVisuals"):WaitForChild("Strawberry Elephant Attacker")
local cframe = CFrame.Angles(0, -1.5707963267948966, 0)
local v = CameraShaker.new(Enum.RenderPriority.Camera.Value + 2, function(cframe2: CFrame)
	local currentCamera = Workspace.CurrentCamera

	if currentCamera then
		currentCamera.CFrame *= cframe2
	end
end)
local sammy = nil
local v2 = 0
local v3 = 0
assert(explosion:IsA("Sound"), "Assets.Sounds.Explosion must be a Sound")
assert(strawberryElephantAttacker:IsA("Model"), "Strawberry Elephant Attacker must be a Model")
assert(strawberryElephantAttacker.Rig.RootPart.Anchored, "Strawberry Elephant Attacker.Rig.RootPart must be anchored")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.RespectCanCollide = true

local function sammyRoot()
	local v4 = sammy

	if v4 == nil or v4.Parent == nil or (v4:GetAttribute("Chasing") ~= true or v4:GetAttribute("Stunned") == true) then
		return nil
	end

	local humanoidRootPart = v4:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
		return nil
	end

	return humanoidRootPart
end

local function step()
	local v4 = sammyRoot()

	if v4 == nil then
		return
	end

	local now = os.clock()

	if now < v2 then
		return
	end

	local primaryPart = Player.FindPrimaryPart()

	if primaryPart == nil then
		return
	end

	local v5 = SammyEventFlags.SammyShakeRadiusStuds:Get()
	local magnitude = (primaryPart.Position - v4.Position).Magnitude

	if v5 <= magnitude then
		return
	end

	v2 = now + 0.35
	v:ShakeOnce(3.5 * (1 - magnitude / v5), 8, 0.1, 0.6)
end

local function spawnBombIndicator(vector2: Vector3, p: number)
	local part = Instance.new("Part")
	part.Name = "SammyBombIndicator"
	part.Shape = Enum.PartType.Cylinder
	part.Size = Vector3.new(0.4, p * 2, p * 2)
	part.CFrame = CFrame.new(vector2 + createVector(0, 0.15, 0)) * CFrame.Angles(0, 0, 1.5707963267948966)
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Transparency = 0.3
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Parent = Workspace
	TweenService:Create(part, tweenInfo, {
		Transparency = 0.8
	}):Play()
	return part
end

local function burstEmitters(folder)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")
		local emitDuration = emitter:GetAttribute("EmitDuration")
		local emitDelay = emitter:GetAttribute("EmitDelay")
		local v5 = emitter

		local function fire()
			if type(emitCount) == "number" and emitCount > 0 then
				v5:Emit((math.max(1, (math.floor(emitCount + 0.5)))))
			end

			if type(emitDuration) == "number" and emitDuration > 0 then
				v5.Enabled = true
				task.delay(emitDuration, function()
					v5.Enabled = false
				end)
			end
		end

		if type(emitDelay) == "number" and emitDelay > 0 then
			task.delay(emitDelay, fire)
		else
			fire()
		end
	end
end

local function playExplosion(position: Vector3)
	local part = Instance.new("Part")
	part.Name = "SammyBombExplosion"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.CFrame = CFrame.new(position)
	local clone = explosionVFX:Clone()
	clone.Parent = part
	part.Parent = Workspace
	burstEmitters(clone)
	Debris:AddItem(part, 3)
end

local function playExplosionSound(list)
	local now = os.clock()
	local primaryPart = Player.FindPrimaryPart()

	if now < v3 or primaryPart == nil then
		return
	end

	v3 = now + 0.3
	local v4 = list[1]

	for _, v5 in list do
		if (v5 - primaryPart.Position).Magnitude < (v4 - primaryPart.Position).Magnitude then
			v4 = v5
		end
	end

	local part = Instance.new("Part")
	part.Name = "SammyBombSound"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.CFrame = CFrame.new(v4)
	local clone = explosion:Clone()
	clone.Parent = part
	part.Parent = Workspace
	clone:Play()
	Debris:AddItem(part, 8)
end

local function shakeFromBlasts(items, p: number)
	local primaryPart = Player.FindPrimaryPart()

	if primaryPart == nil then
		return
	end

	local v4 = p * 3
	local v5 = 1e999

	for _, item in items do
		v5 = math.min(v5, (primaryPart.Position - item).Magnitude)
	end

	if v4 <= v5 then
		return
	end

	v:ShakeOnce(5 * (1 - v5 / v4), 10, 0, 1.5, createVector(0.25, 0.25, 0.25), createVector(4, 1, 1))
end

local function dropBombRow(maid, items, p: number, p2: number)
	local primaryPart = Player.FindPrimaryPart()

	if primaryPart == nil then
		return
	end

	local v4 = {}

	for _, item in items do
		if (item - primaryPart.Position).Magnitude <= 670 then
			table.insert(v4, item)
		end
	end

	if #v4 == 0 then
		return
	end

	local v5 = {}

	for _, v6 in v4 do
		table.insert(v5, maid:Add((spawnBombIndicator(v6, p))))
	end

	maid:Add(task.delay(math.max(p2 - Workspace:GetServerTimeNow(), 0), function()
		for _, v6 in v5 do
			maid:Remove(v6)
		end

		for _, v6 in v4 do
			playExplosion(v6)
		end

		shakeFromBlasts(v4, p)
		playExplosionSound(v4)
	end))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function elephantGround(vector2: Vector3)
	local raycastResult = Workspace:Raycast(vector2 + createVector(0, 60, 0), createVector(0, -200, 0), raycastParams)

	if raycastResult == nil then
		return nil
	end

	return raycastResult.Position.Y
end

local function spawnElephantWarning(Z: number)
	local part = Instance.new("Part")
	part.Name = "SammyElephantWarning"
	part.Size = Vector3.new(Z, 0.4, 50)
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Transparency = 0.3
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Parent = Workspace
	TweenService:Create(part, tweenInfo, {
		Transparency = 0.8
	}):Play()
	return part
end

local function runElephants(maid, p: number, vector2: Vector3, vector3: Vector3, p2: number, p3: number, items)
	local sABMaps = { Workspace.World.Build, Workspace.Terrain }
	local sABMap = Workspace:FindFirstChild("SABMap")

	if sABMap ~= nil then
		table.insert(sABMaps, sABMap)
	end

	raycastParams.FilterDescendantsInstances = sABMaps
	local hitbox = strawberryElephantAttacker.Hitbox
	local v4 = hitbox.Size.Y * 0.5
	local v5 = hitbox.Size.X * 0.5
	local Z = hitbox.Size.Z
	local vector4 = Vector3.new(-vector3.Z, 0, vector3.X)
	local v6 = {}

	for _, item in items do
		local model = maid:Add(strawberryElephantAttacker:Clone())
		model.Parent = Workspace
		local track = model.Rig.AnimationController.Animator:LoadAnimation(model.Animation)
		track.Looped = true
		track:Play()
		table.insert(v6, {
			Model = model,
			Warning = maid:Add((spawnElephantWarning(Z))),
			Offset = item,
			Y = vector2.Y
		})
	end

	local v7 = nil
	v7 = maid:Add(RunService.Heartbeat:Connect(function(dt: number)
		local v8 = (Workspace:GetServerTimeNow() - p) * p2

		if p3 <= v8 then
			for _, v9 in v6 do
				maid:Remove(v9.Model)
				maid:Remove(v9.Warning)
			end

			maid:Remove(v7)
		else
			local v9 = math.min(1, dt * 10)
			local v10 = math.min(50, p3 - v8)

			for _, v11 in v6 do
				local v12 = vector2 + vector3 * math.max(v8, 0) + vector4 * v11.Offset
				local Y = v11.Y
				local v13 = elephantGround(v12) -- equivalent call inferred; original call site unknown
				v11.Y = Y + ((v13 or v11.Y) - v11.Y) * v9
				local vector5 = Vector3.new(v12.X, v11.Y + v4, v12.Z)
				v11.Model:PivotTo(CFrame.lookAt(vector5, vector5 + vector3) * cframe)
				local v14 = Vector3.new(v12.X, v11.Y + 0.15, v12.Z) + vector3 * (v5 + v10 * 0.5)
				v11.Warning.Size = Vector3.new(Z, 0.4, v10)
				v11.Warning.CFrame = CFrame.lookAt(v14, v14 + vector3)
			end
		end
	end))
end

local function watchMap(maid, instance)
	sammy = instance:FindFirstChild("Sammy")
	maid:Connect(instance.ChildAdded, function(model)
		if model.Name == "Sammy" and model:IsA("Model") then
			sammy = model
		end
	end)
	maid:Connect(instance.ChildRemoved, function(p)
		if p == sammy then
			sammy = nil
		end
	end)
end

local function start(maid)
	sammy = nil
	v2 = 0
	v:Start()
	local sammyEventMap = Workspace:FindFirstChild("SammyEventMap")

	if sammyEventMap == nil then
		maid:Connect(Workspace.ChildAdded, function(p)
			if p.Name == "SammyEventMap" then
				watchMap(maid, p)
			end
		end)
	else
		watchMap(maid, sammyEventMap)
	end

	maid:Connect(
		Remotes.SammyEvent.ElephantCharge.OnClientEvent,
		function(p: number, vector2: Vector3, vector3: Vector3, p2: number, p3: number, p4)
			runElephants(maid, p, vector2, vector3, p2, p3, p4)
		end
	)
	maid:Connect(Remotes.SammyEvent.BomberRow.OnClientEvent, function(p, p2: number, p3: number)
		dropBombRow(maid, p, p2, p3)
	end)
	maid:Connect(RunService.Heartbeat, step)
	maid:Add(function()
		sammy = nil
		v:Stop()
	end)
end

return {
	Start = start
}
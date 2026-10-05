local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(-1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local vArenaDimension = FX:WaitForChild("PortalEffects").VArenaDimension
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor

local function areShiftedColorsEqual(player, childName: string, color: Color3, color2: Color3, color3: Color3)
	local child = player:FindFirstChild(childName)

	if child == nil then
		return false
	end

	local shifted = child:FindFirstChild("Shifted")

	if shifted == nil then
		return false
	end

	local shifted_Color1 = shifted:GetAttribute("Shifted_Color1")
	local shifted_Color2 = shifted:GetAttribute("Shifted_Color2")
	local shifted_Color3 = shifted:GetAttribute("Shifted_Color3")

	if shifted_Color1 == nil or shifted_Color2 == nil or shifted_Color3 == nil then
		return false
	end

	return color == shifted_Color1 and color2 == shifted_Color2 and color3 == shifted_Color3
end

function CreateLocation(p, name, position: Vector3, p2, value)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.CFrame = CFrame.new(position)
	part.Size = createVector(1, 1, 1)
	local specialMesh = Instance.new("SpecialMesh", part)
	specialMesh.Scale = createVector(1, 1, 1) * p2
	local sound = Instance.new("Sound")
	sound.Name = "Sound"
	sound.SoundId = value or "rbxassetid://9165261927"
	sound.Volume = 0.6
	sound.EmitterSize = 10
	sound.Looped = true
	Util.SetParentOverrideWithColor(sound, part, p, "PortalFruitVFXColor")
	Util.SetParentOverrideWithColor(part, Workspace._WorldOrigin.Locations, p, "PortalFruitVFXColor")
	return part
end

return function(data)
	local player = data.player
	local createForPlayer = data.createForPlayer
	local origin = data.origin
	local owner = data.owner
	local delayUntilTeleport = data.delayUntilTeleport

	if localPlayer ~= createForPlayer then
		return
	end

	local humanoidRootPart = localPlayer.Character.HumanoidRootPart
	local v = 1e999
	local v2 = nil

	for _, model in pairs(Workspace.Map:GetChildren()) do
		if not model:IsA("Model") then
			continue
		end

		local magnitude = (model:GetBoundingBox().Position - humanoidRootPart.Position).magnitude

		if not (magnitude < v) then
			continue
		end

		v2 = model
		v = magnitude
	end

	v2.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
	local v4 = {}
	task.spawn(function()
		local lastTime = tick()
		local v5 = false

		while wait() and owner and owner:IsDescendantOf(Workspace) do
			if owner:GetAttribute("DimensionCancel") then
				v5 = true
				break
			elseif humanoidRootPart == nil or humanoidRootPart.Parent == nil or humanoidRootPart.Parent.Parent == nil or tick() - lastTime > 4 and (humanoidRootPart.Position - origin).Magnitude > 10000 and not humanoidRootPart:GetAttribute("PortaledToAnotherDimension") then
				break
			end
		end

		if v5 and not localPlayer:GetAttribute("NormalExit") then
			task.wait(1.33)
		end

		v2.ModelStreamingMode = Enum.ModelStreamingMode.Default

		for _, callback in pairs(v4) do
			task.spawn(callback)
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onDestroy(restoreSky)
		table.insert(v4, restoreSky)
	end

	local v5

	if areShiftedColorsEqual(
		player,
		"PortalFruitVFXColor",
		Color3.fromRGB(255, 229, 97),
		Color3.fromRGB(255, 225, 30),
		Color3.fromRGB(255, 199, 16)
	) then
		v5 = CreateLocation(player, "Dimensional Rift", origin, 2000, "rbxassetid://134162873395453")
	else
		v5 = CreateLocation(player, "Dimensional Rift", origin, 2000, "rbxassetid://11848250566")
	end

	table.insert(v4, function()
		v5:Destroy()
	end)
	local clone = vArenaDimension:Clone()
	clone:PivotTo(clone:GetPivot().Rotation + origin)
	task.delay(delayUntilTeleport, function()
		local sky = Lighting:FindFirstChildOfClass("Sky")

		if sky.Name ~= "Space_Skybox" then
			Util.SetParentOverrideWithColor(sky, ReplicatedStorage, player, "PortalFruitVFXColor")
		end

		if areShiftedColorsEqual(
			player,
			"PortalFruitVFXColor",
			Color3.fromRGB(255, 229, 97),
			Color3.fromRGB(255, 225, 30),
			Color3.fromRGB(255, 199, 16)
		) then
			local clone2 = vArenaDimension.Parent.CrossroadsSky:Clone()
			clone2.Name = "Space_Skybox"
			Util.SetParentOverrideWithColor(clone2, Lighting, player, "PortalFruitVFXColor")
		else
			Util.SetParentOverrideWithColor(clone.Space_Skybox, Lighting, player, "PortalFruitVFXColor")
		end

		Util.SetParentOverrideWithColor(clone.SpaceAtmosphere, Lighting.LightingLayers, player, "PortalFruitVFXColor")
		local v6 = false

		local function restoreSky()
			if v6 == true then
				return
			end

			for _, child in ipairs(Lighting:GetChildren()) do
				if child.Name == "Space_Skybox" and child:IsA("Sky") then
					child:Destroy()
				elseif child.Name == "SpaceAtmosphere" and child:IsA("Atmosphere") then
					child:Destroy()
				end
			end

			for _, child in ipairs(Lighting.LightingLayers:GetChildren()) do
				if child.Name == "Space_Skybox" and child:IsA("Sky") then
					child:Destroy()
				elseif child.Name == "SpaceAtmosphere" and child:IsA("Atmosphere") then
					child:Destroy()
				end
			end

			Util.SetParentOverrideWithColor(sky, Lighting, player, "PortalFruitVFXColor")
			v6 = true
		end

		onDestroy(restoreSky) -- equivalent call inferred; original call site unknown
	end)
	Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "PortalFruitVFXColor")
	table.insert(v4, function()
		clone:Destroy()
	end)
	local stagePart = clone.StagePart
	Util.SetParentOverrideWithColor(stagePart, Workspace.Map, player, "PortalFruitVFXColor")
	table.insert(v4, function()
		stagePart:Destroy()
	end)

	if clone:HasTag("LocalSpaceAnimations") == false and clone:FindFirstChild("LocalSpaceAnimations") then
		local localSpaceAnimations = clone.LocalSpaceAnimations
		local playerScripts = localPlayer:FindFirstChildOfClass("PlayerScripts")

		if playerScripts then
			Util.SetParentOverrideWithColor(localSpaceAnimations, playerScripts, player, "PortalFruitVFXColor")
			localSpaceAnimations.Pointer.Value = clone.VWorldStorm
			localSpaceAnimations.Enabled = true
			table.insert(v4, function()
				localSpaceAnimations:Destroy()
			end)
		else
			localSpaceAnimations:Destroy()
		end
	end

	wait(5)

	if clone:IsDescendantOf(Workspace) then
		for _, child in pairs(clone.VWorldStorm.Exterior.Event_SkyPortal.Starfield:GetChildren()) do
			if child:FindFirstChild("ParticleEmitter") then
				child.ParticleEmitter.Enabled = true
			end
		end

		for _, emitter in pairs(clone.PortalEye:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end
	end
end
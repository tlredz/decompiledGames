local createVector = vector.create
script:WaitForChild("Sounds"):WaitForChild("Basalt")
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local v = nil
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local running = humanoidRootPart:WaitForChild("Running")
local humanoid = character:WaitForChild("Humanoid")
local jumping = humanoidRootPart:WaitForChild("Jumping")
jumping.SoundId = ""

function water_ef()
	if character == nil then
		return
	end

	local rightFoot = character:FindFirstChild("RightFoot")
	local leftFoot = character:FindFirstChild("LeftFoot")

	if rightFoot and leftFoot and v == Enum.Material.Water then
		local v2 = math.random(1, 2) == 1 and rightFoot or leftFoot
		local clone = script.Water_Step:Clone()
		clone.Position = v2.Position
		clone.Parent = workspace.Debree
		DebrisModule:AddItem(clone, 1.75)
		vfxUtility.EmitAll(clone.Attachment, vfxUtility.Owned(character))
	end
end

script.Sounds.Basalt.Played:Connect(water_ef)
running.DidLoop:Connect(water_ef)
local v2 = ""
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Terrain, workspace.Map }
raycastParams.IgnoreWater = false
raycastParams.FilterType = Enum.RaycastFilterType.Include
local Character_info_provider = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Character_info_provider"))
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)

function upd_running()
	local get_core_anim = Character_info_provider.get_core_anim(localPlayer, "walk", true)
	local get_core_anim2 = Character_info_provider.get_core_anim(localPlayer, "run", true)
	local soundId = ""
	local floorMaterial = humanoid.FloorMaterial

	if humanoidRootPart ~= nil and floorMaterial ~= nil and floorMaterial ~= Enum.Material.Air then
		local position = humanoidRootPart.Position
		local raycastResult = workspace:Raycast(position, createVector(0, -45, 0), raycastParams)

		if raycastResult ~= nil and raycastResult.Material == Enum.Material.Water then
			floorMaterial = Enum.Material.Water
		end
	end

	local swimState = character:GetAttribute("SwimState")

	if swimState == 2 and floorMaterial ~= nil and floorMaterial ~= Enum.Material.Air then
		floorMaterial = Enum.Material.Water
	end

	v = floorMaterial
	local v3

	if floorMaterial == nil then
		v3 = false
	else
		v3 = script.Sounds:FindFirstChild(floorMaterial.Name) or script.Sounds.Plastic
	end

	if v3 ~= nil then
		soundId = v3.SoundId
	end

	if humanoid ~= nil and humanoid.HipHeight > 2.2 then
		v3 = nil
		soundId = ""
	end

	if typeof(swimState) == "number" and swimState > 0 and swimState ~= 2 then
		v3 = nil
		soundId = ""
	end

	if getvaluesfolder ~= nil and getvaluesfolder:FindFirstChild("boulder_push") ~= nil then
		v3 = nil
		soundId = ""
	end

	if character:GetAttribute("OnHorse") then
		v3 = nil
		soundId = ""
	end

	if getvaluesfolder ~= nil and getvaluesfolder:FindFirstChild("NoFootStep") ~= nil then
		v3 = nil
		soundId = ""
	end

	local v4 = (v3 == nil or v3:FindFirstChild("SpeedInfluence") == nil) and 1 or v3.SpeedInfluence.Value or 1
	local volume = 0.05 * ((v3 == nil or v3:FindFirstChild("VolumeInfluence") == nil) and 1 or v3.VolumeInfluence.Value or 1)
	local v6 = v4 * (math.clamp(1 - 16 / humanoid.WalkSpeed, -0.3, 9999) * 1.8 + 1)
	running.SoundId = soundId
	local v7 = 1
	local SI = get_core_anim2:GetAttribute("SI")
	local SI2 = get_core_anim:GetAttribute("SI")
	local v8

	if v6 > 1 then
		v8 = SI or v7
	else
		v8 = SI2 or v7
	end

	running.PlaybackSpeed = v6 * v8
	running.Volume = volume

	if soundId ~= v2 then
		running.TimePosition = 0
	end

	v2 = soundId
end

humanoid:GetPropertyChangedSignal("HipHeight"):Connect(upd_running)
humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(upd_running)
humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(upd_running)
character:GetAttributeChangedSignal("SwimState"):Connect(upd_running)
character:GetAttributeChangedSignal("OnHorse"):Connect(upd_running)

if getvaluesfolder ~= nil then
	getvaluesfolder.ChildAdded:Connect(function(child)
		if child.Name == "boulder_push" or child.Name == "NoFootStep" then
			upd_running()
		end
	end)
	getvaluesfolder.ChildRemoved:Connect(function(child)
		if child.Name == "boulder_push" or child.Name == "NoFootStep" then
			upd_running()
		end
	end)
end

upd_running()
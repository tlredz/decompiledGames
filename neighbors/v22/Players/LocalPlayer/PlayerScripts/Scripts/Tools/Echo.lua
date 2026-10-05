local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local modules = ReplicatedStorage.Modules
require(modules.Network)
local Janitor = require(modules.Janitor)
local House = require(modules.Neighbors.House)
local maid = Janitor.new()
local _ = Players.LocalPlayer
local echoChangedConnection = nil
local v = false

-- equivalent calls inferred from this helper; original call sites unknown
local function addEchoVFX(head)
	local clone = ReplicatedStorage.Assets.Misc.Echo:Clone()
	clone.Parent = head
	maid:Add(clone)
	return clone
end

local function canApplyEcho(player, p: number)
	local character = player and player.Character

	if not (player and character) or character:GetAttribute("EchoUser") or p > 20 then
		return false
	end

	if character:GetAttribute("UsingVoiceTool") or character:GetAttribute("Muffled") or character:GetAttribute("Blinded") then
		return false
	end

	return true
end

local function wireAudio(p, targetInstance)
	local wire = Instance.new("Wire")
	wire.SourceInstance = p
	wire.TargetInstance = targetInstance
	wire.Name = `{p.Name} > {targetInstance.Name}`
	wire.Parent = p
	maid:Add(wire)
	return wire
end

local function setupEcho(player)
	local character = player.Character
	local head = character and character:WaitForChild("Head", 1)
	local audioDeviceInput = player:FindFirstChild("AudioDeviceInput")
	local audioEmitter = character:FindFirstChild("AudioEmitter")

	if not audioDeviceInput or not audioEmitter or not head or character:GetAttribute("EchoUser") then
		return
	end

	local clone = script.AudioEcho:Clone()
	local v2 = {}
	clone.Name = "ECHOFORK_AudioEcho"
	clone.Parent = audioEmitter
	maid:Add(clone)

	local function cleanupTemp()
		if v2 then
			for _, v3 in v2 do
				v3:Destroy()
			end

			v2 = {}
			v2 = nil
		end
	end

	maid:Add(clone.Destroying:Once(cleanupTemp))
	maid:Add(clone.AncestryChanged:Once(cleanupTemp))
	local wire = Instance.new("Wire")
	wire.SourceInstance = audioDeviceInput
	wire.TargetInstance = clone
	wire.Name = `{audioDeviceInput.Name} > {clone.Name}`
	wire.Parent = audioDeviceInput
	maid:Add(wire)
	table.insert(v2, wire)
	local wire2 = Instance.new("Wire")
	wire2.SourceInstance = clone
	wire2.TargetInstance = audioEmitter
	wire2.Name = `{clone.Name} > {audioEmitter.Name}`
	wire2.Parent = clone
	maid:Add(wire2)
	table.insert(v2, wire2)
	local clone2 = addEchoVFX(head) -- equivalent call inferred; original call site unknown
	table.insert(v2, clone2)
	return clone
end

local function startEchoLoop(object)
	local heartbeatConnection = nil
	local v2 = {}
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if v then
			local players = object:GetPlayers()
			local character = nil

			for _, player in players do
				if not (player.Character and player.Character:GetAttribute("EchoUser")) then
					continue
				end

				character = player.Character
				break
			end

			for _, player in players do
				local character2 = player and player.Character
				local v4 = not character and 0 or player:DistanceFromCharacter(character:GetBoundingBox().Position) or 0

				if character2 and canApplyEcho(player, v4) then
					local eCHOFORK_AudioEcho = character2:FindFirstChild("ECHOFORK_AudioEcho", true) or setupEcho(player)
					v2[player] = eCHOFORK_AudioEcho ~= nil
				else
					local eCHOFORK_AudioEcho = character2 and character2:FindFirstChild("ECHOFORK_AudioEcho", true)

					if eCHOFORK_AudioEcho then
						eCHOFORK_AudioEcho:Destroy()
					end

					if v2[player] then
						v2[player] = nil
					end
				end
			end

			for k in v2 do
				if table.find(players, k) then
					continue
				end

				local eCHOFORK_AudioEcho = k.Character and k.Character:FindFirstChild("ECHOFORK_AudioEcho", true)

				if eCHOFORK_AudioEcho then
					eCHOFORK_AudioEcho:Destroy()
				end

				v2[k] = nil
			end
		else
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
			v2 = {}
			v2 = nil
		end
	end)
	maid:Add(heartbeatConnection)
	return heartbeatConnection
end

-- equivalent calls inferred from this helper; original call sites unknown
local function toggleEcho(p, instance)
	local v2 = instance:GetAttribute("Echo") and instance:GetAttribute("Echo") > 0

	if v ~= v2 then
		if v2 then
			startEchoLoop(p)
		else
			maid:Cleanup()
		end
	end

	v = v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setupListeners(currentHouse)
	local model = currentHouse.Model
	toggleEcho(currentHouse, model) -- equivalent call inferred; original call site unknown
	echoChangedConnection = model:GetAttributeChangedSignal("Echo"):Connect(function()
		toggleEcho(currentHouse, model) -- equivalent call inferred; original call site unknown
	end)
end

House.ActiveHouseChanged:Connect(function()
	local currentHouse = House:GetCurrentHouse()

	if echoChangedConnection then
		echoChangedConnection:Disconnect()
		echoChangedConnection = nil
	end

	if not (currentHouse and currentHouse.Model) then
		maid:Cleanup()
		return
	end

	setupListeners(currentHouse) -- equivalent call inferred; original call site unknown
end)
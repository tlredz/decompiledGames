local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Warn = require(script.Parent.Parent.Shared.Warn)
local Config = require(script.Parent.Parent.Shared.Config)
local Entity = require(script.Parent.Parent.Shared.Entity)
local Holder = require(script.Parent.Parent.Shared.Holder)
require(script.Parent.Parent.Shared.Types)
local _playerChars = Holder._playerChars

local function RegisterPlayer(p, instance, p2)
	local _playerChar = _playerChars[p]

	if _playerChar then
		Entity.Destroy(_playerChar)
	end

	local config = p2.config or "PLAYER"
	local modelRepMode = p2.modelRepMode
	local v = Config._EntityConfigs[config] or {}
	local v2 = modelRepMode or v.MODEL_REPLICATION_MODE
	instance.Archivable = true
	local humanoid = instance:FindFirstChildWhichIsA("Humanoid")
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoid and humanoidRootPart and humanoid.RigType == Enum.HumanoidRigType.R6 and instance.PrimaryPart == instance:FindFirstChild("Head") then
		Config.SetModelPrimaryForChrono(instance, "HumanoidRootPart")
	end

	local v3 = Entity.new(config, instance, v2)
	Holder.SetAsCharacter(p, v3)
	Entity.SetNetworkOwner(v3, p)
	return v3
end

local function UnregisterPlayer(p)
	local _playerChar = _playerChars[p]

	if _playerChar then
		Entity.Destroy(_playerChar)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function OnCharacterAdded(character, p)
	task.wait(0.1)
	RegisterPlayer(p, character, {
		config = "PLAYER"
	})
end

local function OnPlayerAdded(player)
	local characterAddedConnection = player.CharacterAdded:Connect(function(character)
		OnCharacterAdded(character, player) -- equivalent call inferred; original call site unknown
	end)

	if player.Character then
		OnCharacterAdded(player.Character, player) -- equivalent call inferred; original call site unknown
	end

	local ancestryChangedConnection = nil
	ancestryChangedConnection = player.AncestryChanged:Connect(function()
		if not player:IsDescendantOf(game) then
			characterAddedConnection:Disconnect()
			ancestryChangedConnection:Disconnect()
		end
	end)
end

Config._WaitForLock(function()
	if not RunService:IsServer() then
		return
	end

	if Config._GetConfig("PLAYER_REPLICATION") ~= "AUTOMATIC" then
		Warn.low("automatic player replication is disabled")
		return
	end

	local death = script.Parent.Parent.Shared.Remotes.Death
	local _GetConfig = Config._GetConfig("REPLICATE_DEATHS")
	death.OnServerEvent:Connect(function(p, p2)
		if _GetConfig == "NONE" then
			return
		end

		local entity = Holder.GetEntityFromId(p2)

		if not entity or entity.networkOwner ~= p or _GetConfig == "PLAYER_CHARACTERS" and not entity._player then
			return
		end

		local model = entity.model

		if model then
			local humanoid = model:FindFirstChildWhichIsA("Humanoid")
			task.wait()

			if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
				humanoid.Health = 0
				task.delay(0, function()
					if humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
						humanoid.Health = 0
						humanoid.Health = 10
						humanoid.Health = 0
					end
				end)
			end
		end

		death:FireAllClients(p2)
	end)
	Players.PlayerAdded:Connect(OnPlayerAdded)
	Players.PlayerRemoving:Connect(UnregisterPlayer)

	for _, v in Players:GetPlayers() do
		OnPlayerAdded(v)
	end
end)
return {
	RegisterPlayer = RegisterPlayer,
	UnregisterPlayer = UnregisterPlayer
}
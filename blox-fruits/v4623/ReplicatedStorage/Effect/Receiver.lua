local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local Metadata = require(script.Parent.Metadata)
local Payload = require(script.Parent.Payload)
require(script.Parent.Types)
local bindable = script.Parent:WaitForChild("Bindable")
local v = { "Phoenix1.FullBodyTori", "Dragon2.TransformedEastern.Transform" }
local Receiver = {}
Receiver.__index = Receiver

local function ignoresTimeout(instance)
	return instance:FindFirstChild("IgnoreTimeout") ~= nil or (instance:GetAttribute("IgnoreTimeout") and true or false)
end

local function shouldHideEffect(state)
	local localPlayer = Players.LocalPlayer
	local sender = state.Sender

	if not localPlayer or not sender or sender == localPlayer or state.Name and table.find(v, state.Name) then
		return false
	end

	local pvpSessionDirectorComponent = localPlayer:FindFirstChild("PvpSessionDirectorComponent")
	local islandRaiding = sender:GetAttribute("IslandRaiding")
	return (localPlayer:GetAttribute("DisableAllyEffects") and CollectionService:HasTag(
		sender,
		"Ally" .. localPlayer.Name
	) or pvpSessionDirectorComponent and not sender:FindFirstChild("PvpSessionDirectorComponent") or sender:GetAttribute("InCooperativePvEZone") or CollectionService:HasTag(
		sender,
		"DogHouseIndra"
	) or islandRaiding and islandRaiding == localPlayer:GetAttribute("IslandRaiding")) and true or false
end

function Receiver.new(onEffectReceived, getEffectTime)
	return (setmetatable({
		_onEffectReceived = onEffectReceived,
		_getEffectTime = getEffectTime
	}, Receiver))
end

function Receiver:handleClientEvent(p2: number, state, p3)
	local Global = require(ReplicatedStorage.Global)

	if state.Sender and not state.Player then
		state.Player = state.Sender
	end

	if shouldHideEffect(state) then
		Global.TestGameWarn("Ignored effect for ally")
		return
	end

	local module = state.Module

	if not module then
		Global.TestGameWarn("effect not found", state.Name)

		if state.Name then
			module = Metadata.findModule(state.Name)
		end
	end

	assert(module, "Effect not found! " .. tostring(state.Name))
	local lastTime = tick()
	local decoded, v2, v3 = Payload.decode(p3)

	if tick() - lastTime > 2.5 and Global.TestGame then
		Global.TestGameWarn("Long Effect decoding time:", module:GetFullName())
	end

	if not v2 then
		Global.TestGameWarn(
			"Didn't run effect ",
			module:GetFullName(),
			"because parameter(s) failed to replicate: " .. table.concat(v3, ", ")
		)
		return
	end

	local v4 = self._getEffectTime() - p2

	if v4 > 10 and module:FindFirstChild("IgnoreTimeout") == nil and not module:GetAttribute("IgnoreTimeout") then
		Global.TestGameWarn("Didn't run effect", state.Name, "because it took", v4, "to reach the client.")
	else
		bindable:Fire("spawn", module, decoded, state)
	end
end

function Receiver:start()
	task.spawn(function()
		local Global = require(ReplicatedStorage.Global)
		local v2 = {}
		local _onEffectReceived = self._onEffectReceived
		local connection = _onEffectReceived:Connect(function(time, effect, p3)
			table.insert(v2, {
				time = time,
				effect = effect,
				data = p3
			})
		end)
		local localPlayer = Players.LocalPlayer

		if localPlayer then
			while not Global.PersistentLoaded and localPlayer.TeamColor == BrickColor.White() do
				task.wait()
			end

			Global.TestGamePrint("Persistent Loaded or Team Selected")
		end

		connection:Disconnect()
		_onEffectReceived:Connect(function(p, p2, p3)
			self:handleClientEvent(p, p2, p3)
		end)

		for k, v3 in v2 do
			v2[k] = nil
			local v4 = v3
			local success, result = pcall(function()
				local module = v4.effect and v4.effect.Module

				if module and (module:FindFirstChild("IgnoreTimeout") ~= nil or module:GetAttribute("IgnoreTimeout") or self._getEffectTime() - v4.time < 10) then
					self:handleClientEvent(v4.time, v4.effect, v4.data)
				end
			end)

			if not success then
				warn(result)
			end

			task.wait()
		end
	end)
end

return Receiver
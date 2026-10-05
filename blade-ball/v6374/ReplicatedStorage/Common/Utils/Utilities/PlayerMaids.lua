local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local v = {}
local Players = game:GetService("Players")
local v2 = require3(script.Parent.Maid)
require3(script.Parent.Thread)

local function CreatePlayerMaid(player)
	local count = 0
	local v3 = {}
	local maid = v2.new()
	maid.Character = v2.new()

	local function onCharAdded(character)
		maid.Character = v2.new()

		for _, callback in pairs(v3) do
			task.defer(callback, character, maid.Character)
		end
	end

	maid.CharacterAdded = {
		Connect = function(self, callback, p)
			count += 1
			local v4 = tostring(count)

			if player.Character and not p then
				callback(player.Character, maid.Character)
			end

			v3[v4] = callback
			return {
				Disconnect = function()
					v3[v4] = nil
				end
			}
		end
	}
	maid:GiveTask(player.CharacterAdded:Connect(onCharAdded))

	if player.Character then
		onCharAdded(player.Character)
	end

	return maid
end

v.PlayerAdded = {}
v.__PlayerAdded = {}
local RunService = game:GetService("RunService")

if RunService:IsServer() then
	local count = 0

	local function Connect(_, callback)
		assert(callback, "Connect Function is missing!")

		for _, v3 in pairs(Players:GetPlayers()) do
			task.spawn(callback, v3, v[v3])
		end

		count += 1
		local v3 = tostring(count)
		v.__PlayerAdded[v3] = callback
		return {
			Disconnect = function()
				v.__PlayerAdded[v3] = nil
			end
		}
	end

	v.PlayerAdded.Connect = Connect

	local function OnPlayerRemoved(p)
		local v3 = v[p]

		if v3 then
			v3:Destroy()
			v[p] = nil
		end
	end

	local function OnPlayerAdded(p)
		v[p] = CreatePlayerMaid(p)

		for _, callback in pairs(v.__PlayerAdded) do
			task.defer(callback, p, v[p])
		end
	end

	for _, v3 in pairs(Players:GetPlayers()) do
		OnPlayerAdded(v3)
	end

	Players.PlayerAdded:Connect(OnPlayerAdded)
	Players.PlayerRemoving:Connect(OnPlayerRemoved)

	function v.GetPlayerMaid(_, p, value)
		local v3 = typeof(value) == "number" and value or 60
		local total = 0

		repeat
			total += task.wait()
		until not p or not p.Parent or v[p] or v3 <= total

		return p and v[p]
	end

	return v
else
	local localPlayer = Players.LocalPlayer

	function v.PlayerAdded:Connect(callback)
		assert(callback, "Connect Function is missing!")
		callback(localPlayer)
	end

	v.Client = CreatePlayerMaid(Players.LocalPlayer)
	return v
end
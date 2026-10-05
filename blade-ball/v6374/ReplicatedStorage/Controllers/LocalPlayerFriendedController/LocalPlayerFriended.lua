local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local friendAdded = require3(ReplicatedStorage2.Packages.Signal).new()
local friendsCache = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function HandleFriendshipState(p, p2)
	if p == Players.LocalPlayer then
		return
	end

	if p2 and not friendsCache[p] then
		friendsCache[p] = true
		friendAdded:Fire(p)
	end
end

local function OnPlayerAdded(p)
	if p ~= Players.LocalPlayer then
		local success, result = pcall(function()
			return Players.LocalPlayer:IsFriendsWith(p.UserId)
		end)

		if success then
			friendsCache[p] = result
		end
	end
end

Players.PlayerAdded:Connect(OnPlayerAdded)

for _, v3 in Players:GetPlayers() do
	task.spawn(OnPlayerAdded, v3)
end

Players.PlayerRemoving:Connect(function(player)
	friendsCache[player] = nil
end)
pcall(function()
	StarterGui:GetCore("PlayerFriendedEvent").Event:Connect(function(p)
		task.wait(1)
		HandleFriendshipState(p, true) -- equivalent call inferred; original call site unknown
	end)
end)
return {
	_friendsCache = friendsCache,
	friendAdded = friendAdded
}
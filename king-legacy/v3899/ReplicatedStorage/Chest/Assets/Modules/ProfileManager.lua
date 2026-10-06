local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
game:GetService("ReplicatedStorage")
local ProfileManager = {}
local v = {}
local PlayerProfilelua = require(script:WaitForChild("PlayerProfile.lua"))
local Signallua = require(script:WaitForChild("Signal.lua"))
ProfileManager.OnCharacterAdded = Signallua.new("OnCharacterAdded")
ProfileManager.OnCharacterRemoving = Signallua.new("OnCharacterRemoving")

function ProfileManager.CreateProfile(player)
	local v2 = PlayerProfilelua.new(player)

	if player.Character then
		v2:SetCharacter(player.Character)
	end

	player.CharacterAdded:Connect(function(character)
		v2:SetCharacter(character)
	end)
	player.CharacterRemoving:Connect(function(character)
		Signallua:Fire("OnCharacterRemoving", character)
	end)
	v[player] = v2
end

function ProfileManager.AwaitProfile(instance, value: number)
	local v2 = value or 7
	local total = 0

	while not v[instance] do
		if not instance:IsDescendantOf(Players) then
			return
		end

		if v2 and v2 < total then
			return
		else
			total += RunService.Heartbeat:Wait()
		end
	end

	return ProfileManager.GetSyncedProfile(instance, v2)
end

function ProfileManager.GetSyncedProfile(player, value: number)
	local v2 = v[player]
	local total = 0
	local v3 = value or 7

	while v2:GetCharacter() ~= player.Character do
		total += RunService.Heartbeat:Wait()

		if v3 < total then
			return
		end
	end

	return v2
end

function ProfileManager.GetProfile(p)
	return v[p]
end

for _, v2 in pairs(Players:GetPlayers()) do
	if v[v2] then
		continue
	end

	local v3 = v2
	task.defer(function()
		ProfileManager.CreateProfile(v3)
	end)
end

Players.PlayerAdded:Connect(function(player)
	if v[player] then
		return
	end

	ProfileManager.CreateProfile(player)
end)
Players.PlayerRemoving:Connect(function(player)
	if v[player] then
		v[player]:Destroy()
	end

	v[player] = nil
end)
return ProfileManager
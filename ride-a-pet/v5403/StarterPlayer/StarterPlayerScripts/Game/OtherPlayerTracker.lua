local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local Player = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("Player"))
local otherPlayer = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Billboards"):WaitForChild("OtherPlayer")
local v = {}

local function Build(player)
	local clone = otherPlayer:Clone()
	clone.Name = "OtherPlayer_" .. player.Name
	clone.Enabled = false
	clone.Parent = localPlayer:WaitForChild("PlayerGui")
	local v2 = {
		Billboard = clone
	}
	v[player] = v2
	task.spawn(function()
		local PFP = clone:FindFirstChild("PFP", true)
		local success, result = pcall(Player.FetchPlayerPFP, Player, player.UserId)

		if success and typeof(result) == "string" and PFP and clone.Parent then
			PFP.Image = result
		end
	end)

	local function Adorn(character)
		v2.Character = character
		local head = character and (character:FindFirstChild("Head") or character:WaitForChild("HumanoidRootPart", 10))

		if clone.Parent then
			clone.Adornee = head
		end
	end

	if player.Character then
		task.spawn(Adorn, player.Character)
	end

	v2.CharacterConn = player.CharacterAdded:Connect(Adorn)
	v2.RemovingConn = player.CharacterRemoving:Connect(function()
		clone.Enabled = false
		clone.Adornee = nil
	end)
end

local function Remove(p)
	local v2 = v[p]

	if not v2 then
		return
	end

	v[p] = nil

	if v2.CharacterConn then
		v2.CharacterConn:Disconnect()
	end

	if v2.RemovingConn then
		v2.RemovingConn:Disconnect()
	end

	v2.Billboard:Destroy()
end

for _, v2 in Players:GetPlayers() do
	if v2 ~= localPlayer then
		Build(v2)
	end
end

Players.PlayerAdded:Connect(function(player)
	if player ~= localPlayer then
		Build(player)
	end
end)
Players.PlayerRemoving:Connect(Remove)
local total = 0
RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total < 0.25 then
		return
	end

	total = 0
	local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local position = humanoidRootPart.Position

	for _, v2 in v do
		local humanoidRootPart2 = v2.Character and v2.Character:FindFirstChild("HumanoidRootPart")
		local billboard = v2.Billboard

		if humanoidRootPart2 and billboard.Adornee then
			local magnitude = (humanoidRootPart2.Position - position).Magnitude

			if billboard.Enabled then
				if magnitude < 280 then
					billboard.Enabled = false
				end
			elseif magnitude >= 320 then
				billboard.Enabled = true
			end
		else
			billboard.Enabled = false
		end
	end
end)
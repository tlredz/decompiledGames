local Players = game:GetService("Players")
game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local remoteEvent = Net:RemoteEvent("UseItem")
local nightVision = script.NightVision
local nickname = script.Nickname
local flag = false

local function Disable()
	flag = false

	for _, v in Players:GetPlayers() do
		local character = v.Character

		if not character then
			continue
		end

		for _, v2 in character:QueryDescendants("#NightVisionGoogles") do
			v2:Destroy()
		end
	end
end

local function CreateVisionPartsOnPlayer(player)
	local character = player.Character or player.CharacterAdded:Wait()
	local head = character:WaitForChild("Head")

	if player.Name ~= localPlayer.Name then
		for _, part in character:GetChildren() do
			if not (part:IsA("BasePart") and part.Name ~= "__HITBOX" and part:FindFirstChild("NightVisionGoogles") == nil) then
				continue
			end

			for i = 1, 6 do
				local clone = nightVision:Clone()
				clone.Parent = part
				clone.Face = i - 1
				clone.Name = "NightVisionGoogles"
			end
		end

		local clone = nickname:Clone()
		clone.TextLabel.Text = player.Name
		clone.Parent = head
		clone.Name = "NightVisionGoogles"
	end
end

local function Enable()
	flag = true

	for _, v in Players:GetPlayers() do
		local v2 = v
		task.spawn(function()
			CreateVisionPartsOnPlayer(v2)
		end)
	end
end

remoteEvent.OnClientEvent:Connect(function(p, p2)
	if p ~= "EnableNightVisionCape" and p ~= "EnableNightVision" then
		return
	end

	if p2 then
		Enable()
	else
		Disable()
	end
end)
Players.PlayerAdded:Connect(function(player)
	if flag then
		CreateVisionPartsOnPlayer(player)
	end
end)
task.spawn(function()
	local Observers = require(ReplicatedStorage.Packages.Observers)
	Observers.observeCharacter(Players.LocalPlayer, function(_, p)
		return Observers.observeChildren(p, function(tool)
			if tool:IsA("Tool") and tool.Name == "Witch's Broom" then
				return Observers.observeAttribute(tool, "IsActive", function(p2)
					if not p2 then
						return
					end

					task.spawn(Enable)
					return Disable
				end)
			end

			return nil
		end)
	end)
end)
return {
	Enable = Enable,
	Disable = Disable
}
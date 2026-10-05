local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ToolGameplayGuard = require(ReplicatedStorage.Client.ToolGameplayGuard)
local localPlayer = Players.LocalPlayer
localPlayer:GetMouse()
local parent = script.Parent
local v = 0
local beeLauncherRemote = script.Parent:WaitForChild("BeeLauncherRemote")
local heartbeatConnection = nil
local v2 = {}

local function removePlayerHighlights(p)
	if v2[p] then
		for _, v3 in pairs(v2[p]) do
			if v3 and v3.Parent then
				v3:Destroy()
			end
		end

		v2[p] = nil
	end
end

local function addPlayerHighlights(player)
	local character = player.Character

	if not character then
		return
	end

	removePlayerHighlights(player)
	local v3 = {}
	local highlight = Instance.new("Highlight")
	highlight.OutlineColor = Color3.new(1, 0.933333, 0)
	highlight.Parent = character
	table.insert(v3, highlight)
	v2[player] = v3
end

local function onUnequipped()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	for _, v3 in pairs(v2) do
		for _, v4 in pairs(v3) do
			if v4 and v4.Parent then
				v4:Destroy()
			end
		end
	end

	v2 = {}
end

local function onEquipped()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
	end

	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if not (localPlayer.Character and localPlayer.Character.PrimaryPart) then
			onUnequipped()
			return
		end

		local position = localPlayer.Character.PrimaryPart.Position
		local v3 = {}

		for _, v4 in pairs(Players:GetPlayers()) do
			if not (v4 ~= localPlayer and v4.Character and v4.Character.PrimaryPart) then
				continue
			end

			if (v4.Character.PrimaryPart.Position - position).Magnitude <= 30 then
				table.insert(v3, v4)

				if not v2[v4] then
					addPlayerHighlights(v4)
				end
			else
				removePlayerHighlights(v4)
			end
		end

		for k, _ in pairs(v2) do
			if table.find(v3, k) or k == localPlayer then
				continue
			end

			removePlayerHighlights(k)
		end
	end)
end

local function onActivated()
	if not (ToolGameplayGuard.AllowsLocalUse(parent) and (localPlayer.Character and localPlayer.Character.PrimaryPart)) then
		return
	end

	local position = localPlayer.Character.PrimaryPart.Position
	local now = tick()

	if now - v < 60 then
		return
	end

	v = now

	for _, v3 in pairs(Players:GetPlayers()) do
		if v3 ~= localPlayer and v3.Character and v3.Character.PrimaryPart then
			local _ = (v3.Character.PrimaryPart.Position - position).Magnitude <= 30
		end
	end

	beeLauncherRemote:FireServer(position)
end

parent.Equipped:Connect(onEquipped)
parent.Unequipped:Connect(onUnequipped)
parent.Activated:Connect(onActivated)
localPlayer.CharacterRemoving:Connect(function()
	onUnequipped()
end)
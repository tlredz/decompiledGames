local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Net = require(ReplicatedStorage.Modules.Net)
local localPlayer = Players.LocalPlayer
local remoteEvent = Net:RemoteEvent("FishmenBubbleExit")
local connections = {}
local v = false
local count = 0

local function requestExit()
	if not v then
		return
	end

	v = false
	remoteEvent:FireServer()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopListening()
	v = false

	for _, connection in connections do
		connection:Disconnect()
	end

	table.clear(connections)
end

local function startListening()
	stopListening() -- equivalent call inferred; original call site unknown
	v = true
	table.insert(connections, UserInputService.JumpRequest:Connect(requestExit))
	local playerDodged = ReplicatedStorage:FindFirstChild("PlayerDodged")

	if playerDodged and playerDodged:IsA("BindableEvent") then
		table.insert(connections, playerDodged.Event:Connect(requestExit))
	end
end

local function refresh()
	stopListening() -- equivalent call inferred; original call site unknown

	if localPlayer:GetAttribute("FishmenBubbleRiding") then
		count += 1
		local v2 = count
		task.delay(0.45, function()
			if v2 == count and localPlayer:GetAttribute("FishmenBubbleRiding") then
				startListening()
			end
		end)
	end
end

localPlayer:GetAttributeChangedSignal("FishmenBubbleRiding"):Connect(refresh)
stopListening() -- equivalent call inferred; original call site unknown

if localPlayer:GetAttribute("FishmenBubbleRiding") then
	count += 1
	local v2 = count
	task.delay(0.45, function()
		if v2 == count and localPlayer:GetAttribute("FishmenBubbleRiding") then
			startListening()
		end
	end)
end
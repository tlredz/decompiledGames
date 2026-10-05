task.wait(2)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KM_PING_PLAYER_EVENT_CLIENT = ReplicatedStorage:FindFirstChild("KM_PING_PLAYER_EVENT_CLIENT")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local KM_PING_PLAYER_EVENT_SERVER = ReplicatedStorage2:FindFirstChild("KM_PING_PLAYER_EVENT_SERVER")
local v = 99

while v > 0 do
	if KM_PING_PLAYER_EVENT_CLIENT and KM_PING_PLAYER_EVENT_SERVER then
		KM_PING_PLAYER_EVENT_CLIENT.OnClientEvent:Connect(function()
			KM_PING_PLAYER_EVENT_SERVER:FireServer()
		end)
		break
	end

	local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
	KM_PING_PLAYER_EVENT_CLIENT = ReplicatedStorage3:FindFirstChild("KM_PING_PLAYER_EVENT_CLIENT")
	local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
	KM_PING_PLAYER_EVENT_SERVER = ReplicatedStorage4:FindFirstChild("KM_PING_PLAYER_EVENT_SERVER")
	v -= 1
	task.wait(1)
end

if not (workspace:GetAttribute("KM_DEBUG_SERVER_SCANNING_SPEED") or KM_PING_PLAYER_EVENT_CLIENT or KM_PING_PLAYER_EVENT_SERVER) then
	script.Parent:Destroy()
end
local RunService = game:GetService("RunService")
local ping = script.Parent:WaitForChild("Ping")
local v = 0
local count = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function SendPing()
	count += 1
	ping:FireServer(count, workspace:GetServerTimeNow())
end

RunService.Heartbeat:Connect(function(dt)
	v += dt

	if v >= 1 then
		v %= 1
		SendPing() -- equivalent call inferred; original call site unknown
	end
end)
task.spawn(SendPing)
local localPlayer = game.Players.LocalPlayer
local events = game.ReplicatedStorage:WaitForChild("Events", 100000000)
local fireServer = Instance.new("RemoteEvent").FireServer
local invokeServer = Instance.new("RemoteFunction").InvokeServer
game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Random = require(script.Random)
local v = Random.new(localPlayer.UserId + 59886)
local v2 = game.GameId == 4253037040
local v3 = {}
local Network = {}

for _, child in events:GetChildren() do
	v3[child.Name] = child
	child.Name = HttpService:GenerateGUID(false)
end

events.ChildAdded:connect(function(p)
	v3[p.Name] = p
	p.Name = HttpService:GenerateGUID(false)
end)

local function verify(p)
	local lastTime = os.clock()
	local v4 = false

	while not v3[p] do
		if v2 and os.clock() - lastTime > 20 and not v4 then
			warn(p .. " is taking too long to connect")
			v4 = true
		end

		wait()
	end
end

function Network:fire(p: string, ...)
	verify(p)
	fireServer(v3[p], v(0, 9999), ...)
end

function Network.invoke(_, p: string, ...)
	verify(p)
	return invokeServer(v3[p], v(0, 9999), ...)
end

function Network.listen(_, p: string, onClientInvoke, flag: boolean?)
	local function run()
		verify(p)

		if v3[p] then
			local v4 = v3[p]

			if v4.ClassName == "RemoteFunction" then
				v4.OnClientInvoke = onClientInvoke
			elseif v4.ClassName == "RemoteEvent" then
				return v4.OnClientEvent:connect(onClientInvoke)
			else
				Network:fire("Catch", "not event")
			end
		end
	end

	if flag then
		return run()
	end

	task.spawn(run)
end

task.spawn(function()
	local Admin = require(game.ReplicatedStorage.Modules.Admin)

	if Admin:IsLocalPlayerDeveloper() then
		print("User is a developer -- not spoofing network names")
		local RunService = game:GetService("RunService")
		RunService.Heartbeat:Connect(function()
			for k, v4 in next, v3, nil do
				v4.Name = k
			end
		end)
	end
end)
return Network
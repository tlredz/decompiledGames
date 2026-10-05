local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Universe = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("Universe"))
local SimulatedTime = {
	Speed = 1
}
local distributedGameTime = 0
local unixTimestamp

if RunService:IsServer() then
	unixTimestamp = DateTime.now().UnixTimestamp
	script:SetAttribute("Server_Now", unixTimestamp)
else
	while not script:GetAttribute("Server_Now") do
		task.wait(1)
	end

	unixTimestamp = script:GetAttribute("Server_Now")
	distributedGameTime = workspace.DistributedGameTime
end

local total = 0
local flag = false
local callbacks = {}
local isTestRealm = Universe:IsTestRealm()

function SimulatedTime.now()
	if isTestRealm then
		return DateTime.fromUnixTimestamp(unixTimestamp + total)
	end

	if RunService:IsServer() then
		return DateTime.now()
	end

	local v = workspace.DistributedGameTime - distributedGameTime
	return DateTime.fromUnixTimestamp(unixTimestamp + v)
end

function SimulatedTime.Subscribe(_, callback)
	if typeof(callback) ~= "function" then
		return
	end

	callbacks[#callbacks + 1] = callback
end

function SimulatedTime:SetTime(p, flag2: boolean?)
	if not (flag2 or isTestRealm) then
		return
	end

	unixTimestamp = p.UnixTimestamp
	flag = true
	ReplicatedStorage:SetAttribute("SimulatedStartTimestamp", unixTimestamp)
end

function SimulatedTime:SetSpeed(speed: number, flag2: boolean?)
	if not ((flag2 or isTestRealm) and typeof(speed) == "number") then
		return
	end

	ReplicatedStorage:SetAttribute("SimulatedTimeSpeed", speed)
	self.Speed = speed
end

function SimulatedTime:DHMS(p: number)
	local v = math.floor(p)
	local v2 = math.floor(v / 86400)
	local v3 = v % 86400
	local v4 = math.floor(v3 / 3600)
	local v5 = v3 % 3600
	return v2, v4, math.floor(v5 / 60), v5 % 60
end

function SimulatedTime:Format(p: number)
	local DHMS, v, v2, v3 = self:DHMS(p)
	local v4 = DHMS == 0 and "" or string.format("%dd ", DHMS)
	return string.format("%s%02dh %02dm %02ds", v4, v, v2, v3)
end

local function RefreshSimulatedTimeSpeed(p)
	local simulatedTimeSpeed = tonumber(ReplicatedStorage:GetAttribute("SimulatedTimeSpeed")) or 1
	SimulatedTime:SetSpeed(simulatedTimeSpeed, p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RefreshSimulatedTimestamp(p)
	local simulatedStartTimestamp = tonumber(ReplicatedStorage:GetAttribute("SimulatedStartTimestamp")) or DateTime.now().UnixTimestamp
	flag = true
	SimulatedTime:SetTime(DateTime.fromUnixTimestamp(simulatedStartTimestamp), p)
end

ReplicatedStorage:GetAttributeChangedSignal("SimulatedTimeSpeed"):Connect(RefreshSimulatedTimeSpeed)
ReplicatedStorage:GetAttributeChangedSignal("SimulatedStartTimestamp"):Connect(RefreshSimulatedTimestamp)

if RunService:IsClient() then
	SimulatedTime:SetSpeed(tonumber(ReplicatedStorage:GetAttribute("SimulatedTimeSpeed")) or 1, true)
	RefreshSimulatedTimestamp(true) -- equivalent call inferred; original call site unknown
else
	SimulatedTime:SetSpeed(1, true)
	SimulatedTime:SetTime(DateTime.now(), true)
end

task.spawn(function()
	local v = false

	if RunService:IsServer() then
		game:BindToClose(function()
			v = true
		end)
	end

	local function run_actions()
		local now = SimulatedTime.now()

		for _, callback in pairs(callbacks) do
			task.spawn(callback, now)
		end
	end

	if not isTestRealm then
		if RunService:IsServer() then
			task.spawn(function()
				local v2 = 0

				while task.wait(5) and not v do
					local unixTimestamp2 = DateTime.now().UnixTimestamp

					if not (unixTimestamp2 - v2 >= 60) then
						continue
					end

					script:SetAttribute("Server_Now", unixTimestamp2)
					v2 = unixTimestamp2
				end
			end)
		else
			script:GetAttributeChangedSignal("Server_Now"):Connect(function()
				local server_Now = script:GetAttribute("Server_Now")

				if not server_Now then
					return
				end

				unixTimestamp = server_Now
				distributedGameTime = workspace.DistributedGameTime
			end)
			local server_Now = script:GetAttribute("Server_Now")

			if server_Now then
				unixTimestamp = server_Now
			end

			distributedGameTime = workspace.DistributedGameTime
		end
	end

	local v2 = 0

	while not v do
		if flag then
			flag = false
			total = 0
		end

		total += task.wait(0.1) * SimulatedTime.Speed

		if total // 1 == v2 then
			continue
		end

		v2 = total // 1
		run_actions()
	end
end)
return SimulatedTime
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local packages = ReplicatedStorage:WaitForChild("Packages")
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local FFlags = require(packages.FFlags)
local Signal = require(packages.Signal)
local Timer = require(packages.Timer)
local Updates = {
	List = {},
	Methods = {},
	OnUpdateEnabled = Signal.new(),
	OnUpdateDisabled = Signal.new()
}

function Updates.Methods.IsEnabled(p: string)
	local v = Updates.List[p]

	if v then
		return workspace:GetServerTimeNow() >= FFlags:GetInstant(v.FFlag, v.UnixTimeStamp)
	end

	return false
end

function Updates.Methods.GetUpdateTime(p: string)
	local v = Updates.List[p]

	if v then
		return FFlags:GetInstant(v.FFlag, v.UnixTimeStamp)
	end
end

function Updates.Methods.GetTimeLeft(p: string)
	local v = Updates.List[p]

	if v then
		return FFlags:GetInstant(v.FFlag, v.UnixTimeStamp) - workspace:GetServerTimeNow()
	end
end

Updates.List["Update-10/03/2026"] = {
	UnixTimeStamp = ServerData.IsDevGame() and 0 or 1791054000,
	FFlag = "Update-10/03/2026"
}

local function Setup()
	local v = {}

	local function checkUpdate(p: string, p2)
		if v[p] then
			if v[p] ~= FFlags:GetInstant(p, p2.UnixTimeStamp) and not Updates.Methods.IsEnabled(p) then
				v[p] = nil
				Updates.OnUpdateDisabled:Fire(p)
			end
		elseif Updates.Methods.IsEnabled(p) then
			v[p] = FFlags:GetInstant(p, p2.UnixTimeStamp)
			Updates.OnUpdateEnabled:Fire(p)
		end
	end

	local v2 = Timer.new(1)
	v2.Tick:Connect(function()
		for k, v3 in Updates.List do
			checkUpdate(k, v3)
		end
	end)
	v2:Start()

	for k, v3 in Updates.List do
		local v4 = k
		local v5 = v3
		FFlags:OnChange(k, function()
			checkUpdate(v4, v5)
		end)
	end

	for k, v3 in Updates.List do
		if Updates.Methods.IsEnabled(k) then
			Updates.OnUpdateEnabled:Fire(k)
		else
			local v4 = k
			local v5 = v3
			task.spawn(function()
				while not Updates.Methods.IsEnabled(v4) do
					local v6 = FFlags:GetInstant(v5.FFlag, v5.UnixTimeStamp) - workspace:GetServerTimeNow()
					task.wait((math.clamp(v6, 0.01, 1e999)))
				end

				Updates.OnUpdateEnabled:Fire(v4)
			end)
		end
	end
end

Setup()
return Updates
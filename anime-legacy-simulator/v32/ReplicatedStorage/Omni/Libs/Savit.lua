local DataStoreService = game:GetService("DataStoreService")
local GoodSignal = require(script.GoodSignal)
local DataStore = require(script.DataStore)
local Leaderboard = require(script.Leaderboard)
local v = {}
local v2 = {}
task.spawn(function()
	while task.wait(1) do
		local serverTimeNow = workspace:GetServerTimeNow()

		for _, v3 in v2 do
			if not v3.UpdateInterval or (v3.IsUpdating or v3.IsClearing) or not next(v3.Queue) then
				continue
			end

			if serverTimeNow - (v3.LastUpdate or 0) < v3.UpdateInterval + (v3.UpdateOffset or 0) then
				continue
			end

			task.spawn(v3.Update, v3)
		end
	end
end)
local Savit = {}

function Savit.CreateLeaderboard(name: string)
	if typeof(name) ~= "string" then
		warn("[SAVIT] Leaderboard name must be a string!")
		return
	end

	if v2[name] then
		return v2[name]
	end

	local self = setmetatable({}, Leaderboard)
	self.Name = name
	self.OnUpdate = GoodSignal.new()
	self.List = {}
	self.Queue = {}
	self.Saving = {}
	self:SetSize(100)
	self:SetOrdering("Descending")
	self:SetCountrySaving(true)
	self:SetPlayerIconSaving(true)
	v2[name] = self
	return self
end

function Savit.GetLeaderboard(value: string)
	if typeof(value) == "string" then
		return v2[value]
	end

	warn("[SAVIT] Leaderboard name must be a string!")
end

function Savit.CreateDataStore(name: string)
	if typeof(name) ~= "string" then
		warn("[SAVIT] DataStore name must be a string!")
		return
	end

	if v[name] then
		return v[name]
	end

	local self = setmetatable({}, DataStore)
	self.Name = name
	self.Store = DataStoreService:GetDataStore(name)
	self.KeysCache = {}
	self.PendingRequests = {}
	v[name] = self
	return self
end

function Savit:GetDataStore()
	if typeof(self) == "string" then
		return v[self]
	end

	warn("[SAVIT] DataStore name must be a string!")
end

return Savit
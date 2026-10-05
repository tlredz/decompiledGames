local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Signal)
local v3 = require3(ReplicatedStorage2.Packages.Freeze)
local v4 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
require3(ReplicatedStorage2.Shared.t)
require3(ReplicatedStorage2.Shared.ClansData)
local old = newproxy(true)

getmetatable(old).__tostring = function()
	return "CLANS_OLD"
end

local new = newproxy(true)

getmetatable(new).__tostring = function()
	return "CLANS_OVERHAUL"
end

local v7 = newproxy(true)

getmetatable(v7).__tostring = function()
	return "CLANS_DISABLED"
end

local localPlayer = Players.LocalPlayer
local v8 = nil
local clanUpdated = v2.new()
local v10 = v2.new()
local ClanController = {}
ClanController._currentVersion = v7
ClanController.ClanUpdated = clanUpdated
ClanController.Versions = {
	new = new,
	old = old,
	disabled = v7
}

function ClanController:UpdateClan()
	local clanId = v8:Get("ClanId")

	if clanId then
		if self.CurrentClanId == clanId then
			return
		end

		self.CurrentClanId = clanId
		self.ClanReplion = v.Client:WaitReplion(clanId)
	else
		self.ClanReplion = nil
		self.CurrentClanId = nil
	end

	self.ClanUpdated:Fire(self.CurrentClanId, self.ClanReplion)
end

function ClanController.ObserveClan(p, callback)
	local currentClanId, v11

	if p.CurrentClanId and p.ClanReplion then
		currentClanId = p.CurrentClanId
		v11 = callback(p.ClanReplion, p.CurrentClanId, false)
	else
		currentClanId = nil
		v11 = nil
	end

	local connection = clanUpdated:Connect(function(p2, p3)
		if currentClanId == p2 then
			return
		end

		currentClanId = p2

		if v11 then
			v11()
			v11 = nil
		end

		if p2 and p3 then
			v11 = callback(p3, p2, true)
		end
	end)
	return function()
		connection:Disconnect()
		connection = nil
		currentClanId = nil

		if v11 then
			v11()
			v11 = nil
		end
	end
end

function ClanController.BindToVersion(p, p2, callback, ...)
	if p2 ~= old and p2 ~= new then
		error((`Invalid clan version: {p2}`))
	end

	local v11 = table.pack(...)
	task.defer(callback, table.unpack(v3.List.push(v11, p2 == p._currentVersion)))
	v10:Connect(function(p3)
		callback(table.unpack(v3.List.push(v11, p2 == p3)))
	end)
end

function ClanController.IsVersion(p, p2)
	return p._currentVersion == p2
end

function ClanController:Start()
	v8 = v.Client:WaitReplion("Data")

	local function updateClansUIVersion()
		local currentVersion

		if v4:GetKey("ClansEnabled") == true then
			if v4:GetKey("ClanOverhaulEnabled") == true or localPlayer.Name == "gabrielcidade" then
				currentVersion = new
			else
				currentVersion = old
			end
		else
			currentVersion = v7
		end

		if currentVersion == self._currentVersion then
			return
		end

		self._currentVersion = currentVersion
		v10:Fire(currentVersion)
	end

	v4.DataUpdatedEvent:Connect(updateClansUIVersion)
	task.spawn(updateClansUIVersion)
	v8:OnChange("ClanId", function()
		self:UpdateClan()
	end)
	v.Client:OnReplionRemoved(function(p)
		if p == self.ClanReplion then
			self.CurrentClanId = nil
			self.ClanReplion = nil
			self.ClanUpdated:Fire(nil, nil)
		end
	end)
	self:UpdateClan()
end

return ClanController
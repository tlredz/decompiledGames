local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local Replion = require(ReplicatedStorage.packages.Replion)
local remoteFunction = Net:RemoteFunction("RAPService/GetItemRAP", -1)
local v = {
	"RodSkins",
	"Boat",
	"Bobber",
	"Halo",
	"Lantern",
	"BoothSkin",
	"Glider",
	"CompanionSkin"
}
local v2 = nil

local function _getItemId(p: string, p2: string)
	return (`{p}/{p2}`)
end

local RAPController = {}

function RAPController.GetRAP(_, p: string, p2: string)
	if not v2 then
		return nil
	end

	if not table.find(v, p) then
		warn((`[RAPController] Invalid item type: {p}`))
		return nil
	end

	local v3 = { "RAPs", p, (`{p}/{p2}`) }
	local v4 = v2:Get(v3)

	if v4 == -1 then
		return nil
	end

	return v4
end

function RAPController.GetRAPAsync(_, p: string, p2: string)
	if not table.find(v, p) then
		warn((`[RAPController] Invalid item type: {p}`))
		return nil
	end

	local v3, v4 = remoteFunction:InvokeServer(p, p2)

	if not v3 and v4 then
		warn((`[RAPController] Failed to GetItemRAP for {p} {p2}: {v4}`))
	end

	return v3
end

function RAPController.OnRAPChanged(_, p: string, p2: string, callback)
	local maid = Trove.new()

	if not v2 then
		warn("[RAPController] RAPReplion not initialized")
		return maid
	end

	if not table.find(v, p) then
		warn((`[RAPController] Invalid item type: {p}`))
		return maid
	end

	local v3 = { "RAPs", p, (`{p}/{p2}`) }
	maid:Add(v2:OnChange(v3, function(p3: number?)
		if p3 == -1 then
			p3 = nil
		end

		callback(p3)
	end))
	return maid
end

function RAPController.OnAnyRAPChanged(_, callback)
	local maid = Trove.new()

	if v2 then
		maid:Add(v2:OnDescendantChange("RAPs", function(list, p)
			if typeof(list) ~= "table" or #list < 2 then
				return
			end

			local v3 = list[1]
			local v4 = list[2]

			if p == -1 then
				p = nil
			end

			callback(v3, v4, p)
		end))
		return maid
	end

	warn("[RAPController] RAPReplion not initialized")
	return maid
end

function RAPController.Start(_)
	v2 = Replion.Client:WaitReplion("RAP")
end

return RAPController
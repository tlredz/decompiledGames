local HttpService = game:GetService("HttpService")
local import = _G.import("global")
local import2 = _G.import("class")
local import3 = _G.import("timedProcessCollection")
_G.import("dictUtil")
local v = import2.new()

local function playerInfo(p)
	local playerByUserId = game.Players:GetPlayerByUserId(p)
	return playerByUserId, import.get("playerSave", playerByUserId), (import.get("playerSession", playerByUserId))
end

function v:hasTimedProcess(p)
	return self:getTimedProcess(p) and true
end

function v:getTimedProcess(p2)
	for _, v2 in self.TimedProcessInstances:pairs() do
		if v2.Id == p2 then
			return v2
		end
	end
end

function v:activateTimedProcess(p2, p3, p4)
	local v2 = import3:get(p2)

	if not v2 then
		warn("timedState: no collection for id", p2)
		return
	end

	local userId = self.UserId
	local playerByUserId = game.Players:GetPlayerByUserId(userId)
	local playerSave = import.get("playerSave", playerByUserId)
	local playerSession = import.get("playerSession", playerByUserId)
	v2[p3](playerByUserId, playerSave, playerSession, p4)
end

function v:timeProcess(id, p2, exclusive, p4)
	if p2 <= 0 then
		warn(string.format("attempted to initialize timed process %s with 0 duration", id))
		return
	end

	if not exclusive then
		for _, v2 in self.TimedProcessInstances:pairs() do
			if v2.Id ~= id or v2.Exclusive then
				continue
			end

			v2.ExpirationDate += p2
			return
		end
	end

	self:auto_repl(p4 or false)
	self.TimedProcessInstances[HttpService:GenerateGUID()] = {
		Id = id,
		ExpirationDate = os.time() + p2,
		Exclusive = exclusive
	}
	self:auto_repl(false)
	self:activateTimedProcess(id, "init")
end

function v:updateTimedProcesses(p)
	local now = os.time()

	for k, v2 in self.TimedProcessInstances:pairs() do
		if v2.ExpirationDate <= now then
			self.TimedProcessInstances[k] = nil
			self:activateTimedProcess(v2.Id, "deinit", p)
		elseif p then
			self:activateTimedProcess(v2.Id, "init")
		end
	end
end

function v:new()
	self.TimedProcessInstances = {
		_Insertable = true
	}
end

return v
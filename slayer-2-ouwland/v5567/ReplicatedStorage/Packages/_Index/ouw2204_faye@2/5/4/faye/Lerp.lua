local FayeUtility = require(script.Parent.Misc.FayeUtility)
require(script.Parent.FayeTypes)
local LerpPlayer = require(script.Parent.Compile.Compilers.CompileLerp.LerpPlayer)
local v = {
	__type = script.Name
}
v.__index = v

function v:Skip()
	local _, v2 = LerpPlayer.Find(self.__lerpid)

	if v2 then
		v2.Entity[v2.Property] = v2.To

		if v2.Workers then
			for i = 1, v2.Workers.Count do
				local worker = v2.Workers[i]

				if worker.Entity ~= nil and worker.Entity.Parent ~= nil then
					worker.Entity[worker.Property] = v2.To
				end
			end
		end

		LerpPlayer.Remove(self.__lerpid)
	end
end

function v:Stop()
	LerpPlayer.Remove(self.__lerpid)
end

function v:Destroy()
	self:Stop()

	if self.Thread ~= nil then
		FayeUtility.RemoveFromThread(self.Thread, self)
	end
end

local name = script.Name
local count = 0
return function(to, value: number?, from, thread)
	if to == nil then
		return
	end

	local self = setmetatable({
		To = to,
		Factor = value or 0.15,
		From = from,
		Thread = thread,
		__lerpid = name .. count
	}, v)
	count += 1

	if thread ~= nil then
		FayeUtility.AddToThread(thread, self)
	end

	return self
end
local LoopService = {}
LoopService.__index = LoopService

function LoopService.LoopWithFunctions(duration: number, list, p)
	local iterations = nil
	local count = 0

	for i = 1, #list do
		if iterations == nil then
			iterations = list[i].Iterations
		end

		if iterations < list[i].Iterations then
			iterations = list[i].Iterations
		end
	end

	local object = setmetatable({}, LoopService)
	object.LoopDone = false
	task.spawn(function()
		repeat
			count += 1

			for i = 1, #list do
				local v = i
				task.spawn(function()
					local iterations2 = list[v].Iterations
					local v2, v3 = math.modf(count / iterations2)

					if v3 == 0 then
						list[v].Function(p, object)
					end
				end)
			end

			if count == iterations then
				count = 0
			end

			task.wait(duration)
		until object.LoopDone
	end)
	return object
end

function LoopService:EndLoop()
	self.LoopDone = true
end

function LoopService:UpdateFunctions(p)
	self:EndLoop()
	local data = self.Data
	local loopWait = self.LoopWait
	LoopService.LoopWithFunctions(loopWait, p, data)
end

return LoopService
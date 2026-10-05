local RunService = game:GetService("RunService")

if RunService:IsClient() then
	RunService:IsServer()
end

local v = RunService:IsStudio() or RunService:IsClient()
local currentCamera

if v then
	currentCamera = workspace.CurrentCamera
else
	currentCamera = nil
end

local wait2 = wait
local tick2 = tick
local min = math.min
local random = math.random
local _ = print
local warn2 = warn
local v2 = {
	{},
	{}
}
local Queue = {}
Queue.__index = Queue

function Queue.new(name, func, value, value2, value3)
	for _, v3 in pairs(v2) do
		if not v3[name] then
			continue
		end

		warn2("[QUEUE]", name, "already exists, overwriting.")
		v3[name].func = func
		v3[name].renderDist = value or 100
		v3[name].renderMultiplier = value2 or 0.0033333333333333335
		v3[name].intervalOffset = value3 or 0
		return v3[name]
	end

	local thread = #v2[1] > #v2[2] and 2 or 1
	local self = setmetatable({
		thread = thread,
		intervalOffset = value3 or 0,
		renderDist = value or 100,
		renderMultiplier = value2 or 0.0033333333333333335,
		name = name,
		func = func,
		bin = {}
	}, {
		__index = Queue
	})
	v2[thread][name] = self
	return self
end

function Queue.add(data, p)
	p.time = 0
	p.lastRender = tick2()
	p.currentMul = 1

	if v and p.renderPoint then
		local magnitude = (currentCamera.CFrame.p - p.renderPoint).magnitude

		if magnitude < data.renderDist then
			p.rendering = true
			p.currentMul = 0
		else
			p.rendering = false
			p.currentMul = min(1, (magnitude - data.renderDist) * data.renderMultiplier)
		end
	else
		p.rendering = true
	end

	table.insert(data.bin, p)
end

function Queue:remove(p2)
	self.bin[p2] = nil
end

function Queue:update(p)
	local count = 0

	for _, v3 in pairs(self.bin) do
		if v3 then
			count += 1
		end
	end

	if count > 0 then
		local now = tick2()

		for k, v3 in pairs(self.bin) do
			if v3 then
				v3.time += p
				local v4 = random()
				local v5 = now - v3.lastRender

				if v3.rendering and self.intervalOffset < v5 or v4 * 0.9 * v3.currentMul + self.intervalOffset < v5 then
					v3.lastRender = now - v4 * 0.1 * v3.currentMul
					local v6 = k
					local v7 = v3
					local v8 = v5
					local success, result = pcall(function()
						self:func(v6, v7, v7.rendering and p or v8, v7.currentMul)
					end)

					if success then
						if result == "RemoveFromQueue" then
							self:remove(k)
						end
					else
						warn2("[QUEUE]", "Error:", result, debug.traceback())
						self:remove(k)
					end
				end
			else
				self:remove(k)
			end
		end
	end
end

local function UpdateMain(items)
	local now = tick2()

	while wait2() do
		local v3 = tick2() - now

		for _, item in pairs(items) do
			item:update(v3)
		end

		now = tick2()
	end
end

for _, v3 in pairs(v2) do
	local v4 = v3
	spawn(function()
		UpdateMain(v4)
	end)
end

if v then
	spawn(function()
		while wait2(0.5) do
			for _, v3 in pairs(v2) do
				for _, v4 in pairs(v3) do
					for _, v5 in pairs(v4.bin) do
						if not v5 then
							continue
						end

						if v5.renderPoint then
							local magnitude = (currentCamera.CFrame.p - v5.renderPoint).magnitude

							if magnitude < v4.renderDist then
								v5.rendering = true
								v4.currentMul = 0
							else
								v5.rendering = false
								v5.currentMul = min(1, (magnitude - v4.renderDist) * v4.renderMultiplier)
							end
						else
							v5.rendering = true
						end
					end
				end
			end
		end
	end)
end

return Queue
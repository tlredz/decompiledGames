local CollectionService = game:GetService("CollectionService")
game:GetService("RunService")
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._is_playing = false
	self._next_flicker = {}
	self:_Init()
	return self
end

function class:_Play()
	if self._is_playing then
		return
	end

	self._is_playing = true

	while true do
		local tagged = CollectionService:GetTagged("FlickeringLight")

		if #tagged == 0 then
			break
		end

		for _, v in pairs(tagged) do
			if tick() < (self._next_flicker[v] or 0) then
				continue
			end

			self._next_flicker[v] = tick() + 1 + 4 * math.random()
			local v2 = v
			task.spawn(function()
				for i = 1, math.random(1, 3) do
					local surfaceLight = v2:FindFirstChildOfClass("SurfaceLight")
					v2.Material = Enum.Material.Neon

					if surfaceLight then
						surfaceLight.Enabled = true
					end

					wait(0.1)
					v2.Material = Enum.Material.SmoothPlastic

					if surfaceLight then
						surfaceLight.Enabled = false
					end

					wait(0.1)
				end
			end)
		end

		wait(0.1)
	end

	self._is_playing = false
end

function class:_Init()
	CollectionService:GetInstanceAddedSignal("FlickeringLight"):Connect(function(p)
		self._next_flicker[p] = tick() + 1
		self:_Play()
	end)
	CollectionService:GetInstanceRemovedSignal("FlickeringLight"):Connect(function(p)
		self._next_flicker[p] = nil
	end)
	task.spawn(self._Play, self)
end

return class._new()
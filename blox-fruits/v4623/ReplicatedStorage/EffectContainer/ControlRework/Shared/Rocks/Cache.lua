local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {
	Templates = script.Templates
}
v.__index = v
local freeRocks = ReplicatedStorage:FindFirstChild("Free Rocks") or Instance.new("Folder", ReplicatedStorage)
freeRocks.Name = "Free Rocks"

function v:Add()
	local clone = self.Template:Clone()
	clone.CanCollide = false
	clone.CanTouch = false
	clone.CanQuery = false
	clone.Anchored = true
	clone.TopSurface = Enum.SurfaceType.Smooth
	clone.BottomSurface = Enum.SurfaceType.Smooth
	clone.CFrame = CFrame.new(0, 1000000, 0)
	clone.Parent = freeRocks
	table.insert(self.Free, clone)
end

function v:Get()
	if #self.Free == 0 then
		warn((`Apply Expansion [{self.Expansion}]`))

		for _ = 1, self.Expansion do
			self:Add()
		end
	end

	local count = #self.Free
	local v2 = self.Free[count]
	v2.Parent = self.Parent
	table.insert(self.Busy, v2)
	table.remove(self.Free, count)
	return v2
end

function v.Release(p, p2)
	local index = table.find(p.Busy, p2)

	if not index then
		return
	end

	p2.Parent = freeRocks
	table.remove(p.Busy, index)
	table.insert(p.Free, p2)
end

return function(value: string?, p, value2: number?, value3: number?)
	local self = setmetatable({
		Busy = {},
		Free = {},
		Template = v.Templates:FindFirstChild(value or "Default") or Instance.new("Part"),
		Parent = p or workspace._WorldOrigin,
		Expansion = value3 or 20
	}, v)

	for _ = 1, value2 or 250 do
		self:Add()
	end

	return self
end
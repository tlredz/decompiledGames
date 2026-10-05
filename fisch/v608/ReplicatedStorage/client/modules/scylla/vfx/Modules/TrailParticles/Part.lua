local Part = {}
Part.__index = Part

function Part.new(instance)
	local object = setmetatable({}, Part)
	object.CFrame = CFrame.new()
	object.Att0 = instance.Att0:Clone()
	object.Att1 = instance.Att1:Clone()
	object.Trails = {}
	object.Att0Pos = object.Att0.Position
	object.Att1Pos = object.Att1.Position
	object.TrailWidth = (instance.Position - object.Att0Pos).Magnitude + (instance.Position - object.Att1Pos).Magnitude
	object.Att0.Parent = workspace.Terrain
	object.Att1.Parent = workspace.Terrain

	for _, trail in ipairs(instance:GetChildren()) do
		if not trail:IsA("Trail") then
			continue
		end

		local clone = trail:Clone()
		clone.Attachment0 = object.Att0
		clone.Attachment1 = object.Att1
		clone.Parent = workspace.Terrain
		table.insert(object.Trails, clone)
	end

	return object
end

function Part:UpdateCFrame(cFrame: CFrame)
	self.CFrame = cFrame
	self:Update()
end

function Part:Update()
	self.Att0.WorldPosition = (self.CFrame * CFrame.new(self.Att0Pos)).Position
	self.Att1.WorldPosition = (self.CFrame * CFrame.new(self.Att1Pos)).Position
end

function Part:Destroy()
	self.Att0:Destroy()
	self.Att1:Destroy()

	for _, trail in ipairs(self.Trails) do
		trail:Destroy()
	end

	table.clear(self.Trails)
end

setmetatable(Part, {
	__index = function(_, p)
		error(string.format("%q is not a valid member of %q", tostring(p), script.Name), 2)
	end
})
return Part
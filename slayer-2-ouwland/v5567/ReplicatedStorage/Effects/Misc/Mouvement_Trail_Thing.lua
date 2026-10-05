local createVector = vector.create
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
game:GetService("RunService")
game:GetService("TweenService")
local v = {
	preset1 = {
		Duration = 10,
		size_mult = 1.6,
		Part = script.trail_
	}
}
local clock = os.clock
return function(instance, p, value, p2)
	local v2 = v[p]

	if instance == nil or v2 == nil or value == nil then
		return
	end

	if workspace.Debree:FindFirstChild("trail_" .. instance.Parent.Name) ~= nil then
		for _, child in pairs(workspace.Debree["trail_" .. instance.Parent.Name]:GetChildren()) do
			child.Enabled = false
		end

		DebrisModule:AddItem(workspace.Debree["trail_" .. instance.Parent.Name], 1)
		workspace.Debree["trail_" .. instance.Parent.Name].Name = "--"
	end

	if p2 == nil or p2 ~= true then
		return
	end

	local clone = v2.Part:Clone()
	clone.Size = instance.Size * (v2.size_mult or 1) + createVector(0, 0, 10)
	clone.Name = "trail_" .. instance.Parent.Name
	local max = clone.LinesWhite2.Lifetime.Max > clone.LinesWhite.Lifetime.Max and clone.LinesWhite2.Lifetime.Max or clone.LinesWhite.Lifetime.Max
	clone:SetAttribute("Added", tick() + max)
	clone.LinesWhite.EmissionDirection = value or "Top"
	clone.LinesWhite2.EmissionDirection = value or "Top"
	clone.CFrame = instance.CFrame
	clone.Parent = workspace.Debree
	local position = clone.CFrame.Position
	local v3 = nil
	local now = 0

	while clone ~= nil and instance ~= nil and instance:IsDescendantOf(workspace) == true and clone:IsDescendantOf(workspace.Debree) == true do
		task.wait()
		local position2 = instance.CFrame.Position
		local lookVector = position2 - position

		if lookVector.Magnitude == 0 then
			lookVector = instance.CFrame.lookVector
		end

		local cframe = CFrame.new(instance.CFrame.Position, instance.CFrame.Position + lookVector)
		local v4 = cframe * CFrame.new(0, 0, 4.1499999999999995).Position
		local rotation = cframe.Rotation

		if v3 == nil then
			v3 = rotation
		elseif instance and instance.Parent ~= nil and clone ~= nil and clone.Name == "trail_" .. instance.Parent.Name then
			v3 = v3:Lerp(rotation, 0.5)
		end

		clone.CFrame = CFrame.new(v4) * v3

		if not (clock() - now >= 0.075) then
			continue
		end

		now = clock()
		position = position2
	end
end
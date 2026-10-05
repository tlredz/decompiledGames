local createVector = vector.create
local Util = require(game.ReplicatedStorage.Util)
return function(data)
	local _ = data.CFrame
	local root = data.Root
	local grab = data.Grab
	local hitbox = data.Hitbox

	if typeof(root) ~= "Instance" then
		return
	end

	Util.DistributedLoop:add(function(p, _)
		if p > 10 or not (root and root:IsDescendantOf(workspace) and grab and grab:IsDescendantOf(workspace) and hitbox and hitbox:IsDescendantOf(workspace) and hitbox:FindFirstChild("Weld")) then
			return true
		end

		local count = 0

		for _, child in pairs(root.Parent:GetChildren()) do
			if child.Name == "Grab" then
				count += 1
			end
		end

		if count > 1 then
			return true
		end

		local cFrame = hitbox.CFrame
		root.CFrame = CFrame.new(createVector(0, 0, 0), cFrame.LookVector) * CFrame.new(0, 0, -hitbox.Size.Z) + cFrame.Position
	end)
end
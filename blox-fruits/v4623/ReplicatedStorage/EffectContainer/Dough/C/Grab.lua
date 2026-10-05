local Util = require(game.ReplicatedStorage.Util)
return function(data)
	local cFrame = data.CFrame
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

		local v = hitbox.Weld.Part0.CFrame * hitbox.Weld.C0
		local unit = grab.Value.Unit
		local cframe = CFrame.new(v * (unit * hitbox.Size.Magnitude / 3.141592653589793), v.p)
		local dot = (cframe.p - cFrame.p):Dot(cFrame.UpVector)

		if dot < 0 then
			cframe -= cFrame.UpVector * dot
		end

		root.CFrame = cframe
	end)
end
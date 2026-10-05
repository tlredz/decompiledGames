local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DetectBadPaths = {}
local v = {
	AgentRadius = 1.6,
	AgentHeight = 5,
	AgentCanJump = true,
	AgentCanClimb = false,
	WaypointSpacing = 4,
	Costs = {
		Obstacle = 1e999
	}
}

function DetectBadPaths.NodeTableExpander(part)
	local result = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isAlreadyInTable(p)
		for _, v2 in pairs(result) do
			if v2 == p then
				return true
			end
		end

		return false
	end

	local function searchInstance(folder)
		if not folder then
			return
		end

		for _, descendant in pairs(folder:GetDescendants()) do
			if not descendant:IsA("BasePart") or descendant:IsA("Model") then
				continue
			end

			-- equivalent call inferred; original call site unknown
			if not isAlreadyInTable(descendant) then
				table.insert(result, descendant)
			end
		end
	end

	if typeof(part) == "Instance" then
		if part:IsA("BasePart") then
			table.insert(result, part)
		end

		searchInstance(part)
	elseif typeof(part) == "table" then
		for _, part2 in pairs(part) do
			if typeof(part2) ~= "Instance" then
				continue
			end

			if part2:IsA("BasePart") then
				-- equivalent call inferred; original call site unknown
				if not isAlreadyInTable(part2) then
					table.insert(result, part2)
				end
			end

			searchInstance(part2)
		end
	end

	return result
end

function DetectBadPaths.CheckPath(p, p2, p3)
	local v2 = v

	if p then
		local success, result = pcall(function()
			return require(ReplicatedStorage.Forbidden.Config)
		end)

		if success and result then
			local config = result.GetConfig(p)
			v2 = config and {
				AgentRadius = config.AgentRadius or v.AgentRadius,
				AgentHeight = config.AgentHeight or v.AgentHeight,
				AgentCanJump = config.AgentCanJump ~= false,
				AgentCanClimb = config.AgentCanClimb or false,
				WaypointSpacing = config.WaypointSpacing or v.WaypointSpacing,
				Costs = config.Costs or v.Costs
			} or v2
		end
	end

	local path = PathfindingService:CreatePath(v2)
	local success, result = pcall(function()
		path:ComputeAsync(p2.Position, p3.Position)
	end)

	if success then
		return path.Status == Enum.PathStatus.Success
	end

	warn("[DetectBadPaths] ComputeAsync failed:", result)
	return false
end

function DetectBadPaths.DetectBadPaths(p, p2, p3)
	local v2 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function InsertBadPath(from, to, p6)
		table.insert(v2, {
			From = from,
			To = to,
			Omnidirectional = p6 or false
		})
	end

	local nodeTableExpander = DetectBadPaths.NodeTableExpander(p)

	if #nodeTableExpander < 2 then
		warn("[DetectBadPaths] Need at least 2 nodes to check paths")
		return v2
	end

	for i = 1, #nodeTableExpander - 1 do
		for i2 = i + 1, #nodeTableExpander do
			local from = nodeTableExpander[i]
			local to = nodeTableExpander[i2]

			if DetectBadPaths.CheckPath(p2, from, to) then
				if p3 and not DetectBadPaths.CheckPath(p2, to, from) then
					InsertBadPath(to, from) -- equivalent call inferred; original call site unknown
				end
			else
				if p3 and not DetectBadPaths.CheckPath(p2, to, from) then
					InsertBadPath(from, to, true) -- equivalent call inferred; original call site unknown
					continue
				end

				InsertBadPath(from, to) -- equivalent call inferred; original call site unknown
			end
		end
	end

	return v2
end

function DetectBadPaths.VisualizeBadPaths(list, p)
	local folder = Instance.new("Folder")
	folder.Name = "BadPathsVisualization"
	folder.Parent = p or workspace

	for i, v2 in ipairs(list) do
		local attachment = Instance.new("Attachment")
		attachment.Parent = v2.From
		attachment.Name = "BadPathAttachment_" .. i
		local attachment2 = Instance.new("Attachment")
		attachment2.Parent = v2.To
		attachment2.Name = "BadPathAttachment_" .. i
		local beam = Instance.new("Beam")
		beam.Name = "BadPath_" .. v2.From.Name .. "_to_" .. v2.To.Name
		beam.Attachment0 = attachment
		beam.Attachment1 = attachment2
		beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
		beam.FaceCamera = true
		beam.Width0 = 0.5
		beam.Width1 = 0.5
		beam.Parent = folder
		local folder2 = Instance.new("Folder")
		folder2.Name = "Cleanup_" .. i
		folder2.Parent = folder
		attachment.Parent = folder2
		attachment2.Parent = folder2
	end

	return folder
end

function DetectBadPaths.CleanupVisualization(instance)
	if instance then
		instance:Destroy()
	end
end

return DetectBadPaths
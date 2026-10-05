local TweenService = game:GetService("TweenService")
local frozen = table.freeze({
	BOUNCE_SCALE = 1.1,
	START_DELAY = 0.2,
	STEP_DELAY = 0.08,
	BOUNCE_TWEEN_INFO = TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true)
})
local PipeRipple = {
	MAX_SURFACE_GAP = 1
}
local v = {
	releaseNode = function(state)
		if state.completedConnection then
			state.completedConnection:Disconnect()
			state.completedConnection = nil
		end

		if state.tween then
			state.tween:Cancel()
			state.tween:Destroy()
			state.tween = nil
		end

		if state.part.Parent then
			state.part.Size = state.originalSize
		end
	end,
	getProjectionRadius = function(vector: Vector3, cframe: CFrame, vector2: Vector3)
		local vectorToObjectSpace = cframe:VectorToObjectSpace(vector2)
		local v2 = vector * 0.5
		return math.abs(vectorToObjectSpace.X) * v2.X + math.abs(vectorToObjectSpace.Y) * v2.Y + math.abs(vectorToObjectSpace.Z) * v2.Z
	end
}

function PipeRipple.getSurfaceGap(vector: Vector3, cframe: CFrame, vector2: Vector3, cframe2: CFrame)
	local v2 = cframe2.Position - cframe.Position

	if v2.Magnitude < 0.01 then
		return 0
	end

	local unit = v2.Unit
	local projectionRadius = v.getProjectionRadius(vector, cframe, unit)
	local projectionRadius2 = v.getProjectionRadius(vector2, cframe2, unit)
	return (math.max(0, v2.Magnitude - projectionRadius - projectionRadius2))
end

function PipeRipple.create()
	return {
		_nodes = {},
		_nodesParent = nil,
		_partCount = 0,
		_revision = 0
	}
end

function PipeRipple:cancel()
	self._revision += 1

	for _, _node in self._nodes do
		v.releaseNode(_node)
	end
end

function PipeRipple:clear()
	PipeRipple.cancel(self)
	table.clear(self._nodes)
	self._nodesParent = nil
	self._partCount = 0
end

function v:isGraphValid(instance, items)
	if self._nodesParent ~= instance then
		return false
	end

	local count = 0

	for _, part in instance:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		count += 1

		if not self._nodes[part] then
			return false
		end
	end

	if count ~= self._partCount then
		return false
	end

	for k in items do
		if k.Parent ~= instance or not self._nodes[k] then
			return false
		end
	end

	return next(self._nodes) ~= nil
end

function PipeRipple:resolve(nodesParent, p2)
	if v.isGraphValid(self, nodesParent, p2) then
		return
	end

	PipeRipple.clear(self)
	local parts = {}
	local v2 = {}

	for _, part in nodesParent:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		table.insert(parts, part)
		v2[part] = p2[part] or part.CFrame
		self._nodes[part] = {
			part = part,
			originalSize = part.Size,
			neighbors = {},
			tween = nil,
			completedConnection = nil
		}
	end

	for i = 1, #parts - 1 do
		local v3 = parts[i]
		local _node = self._nodes[v3]

		for i2 = i + 1, #parts do
			local v4 = parts[i2]

			if not (PipeRipple.getSurfaceGap(_node.originalSize, v2[v3], self._nodes[v4].originalSize, v2[v4]) <= PipeRipple.MAX_SURFACE_GAP) then
				continue
			end

			table.insert(_node.neighbors, self._nodes[v4])
			table.insert(self._nodes[v4].neighbors, _node)
		end
	end

	self._nodesParent = nodesParent
	self._partCount = #parts
end

function v:bounce(state, p2: number)
	if self._revision ~= p2 or state.part.Parent ~= self._nodesParent then
		return
	end

	v.releaseNode(state)

	if self._revision ~= p2 then
		return
	end

	local tween = TweenService:Create(state.part, frozen.BOUNCE_TWEEN_INFO, {
		Size = state.originalSize * frozen.BOUNCE_SCALE
	})
	local completedConnection = tween.Completed:Connect(function()
		if state.tween ~= tween then
			return
		end

		if state.completedConnection then
			state.completedConnection:Disconnect()
			state.completedConnection = nil
		end

		state.tween = nil
		tween:Destroy()

		if state.part.Parent then
			state.part.Size = state.originalSize
		end
	end)
	state.tween = tween
	state.completedConnection = completedConnection
	tween:Play()
end

function PipeRipple:play(p, p2)
	PipeRipple.cancel(self)
	local _revision = self._revision
	task.delay(frozen.START_DELAY, function()
		if self._revision ~= _revision or p2[p] then
			return
		end

		local _node = self._nodes[p]

		if not _node or p.Parent ~= self._nodesParent then
			return
		end

		local v2 = {
			[_node] = 0
		}
		local neighbors = { _node }
		local v3 = 1

		while v3 <= #neighbors do
			local v4 = neighbors[v3]
			local v5 = v2[v4] + 1
			v3 += 1

			for _, neighbor in v4.neighbors do
				if v2[neighbor] ~= nil or p2[neighbor.part] then
					continue
				end

				v2[neighbor] = v5
				table.insert(neighbors, neighbor)
			end
		end

		for k, v4 in v2 do
			local v5 = k
			task.delay(v4 * frozen.STEP_DELAY, function()
				if self._revision == _revision and not p2[v5.part] then
					v.bounce(self, v5, _revision)
				end
			end)
		end
	end)
end

return PipeRipple
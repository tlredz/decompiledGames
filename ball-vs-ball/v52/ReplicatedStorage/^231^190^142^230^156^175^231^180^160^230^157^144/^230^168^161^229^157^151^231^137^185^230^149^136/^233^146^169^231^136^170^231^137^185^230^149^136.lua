local createVector = vector.create
local RunService = game:GetService("RunService")

local function discoverHookChainSegmentCount(model)
	local v = {}
	local v2 = 0

	for _, part in ipairs(model:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		local match = part.Name:match("^连接(%d+)$")

		if not match then
			continue
		end

		local v3 = tonumber(match)
		v[v3] = true
		v2 = math.max(v2, v3)
	end

	assert(v2 > 0, string.format("钩爪素材模型 '%s' 找不到任何 连接N 部件", model:GetFullName()))

	for i = 1, v2 do
		assert(v[i], string.format("钩爪素材模型 '%s' 缺少连接%d（编号必须从 1 连续到 %d）", model:GetFullName(), i, v2))
	end

	return v2
end

local function worldFromArena(cframe: CFrame, p: number, point: Vector2, value: number?)
	return cframe:PointToWorldSpace((Vector3.new(point.X * p, point.Y * p, -(value or 0) * p)))
end

local function captureDecorations(instance)
	local result = {}

	for _, part in ipairs(instance:GetChildren()) do
		if part:IsA("BasePart") then
			table.insert(result, {
				part = part,
				offsetCFrame = instance.CFrame:ToObjectSpace(part.CFrame)
			})
		end
	end

	return result
end

local function applyHookSegmentPart(p, cframe: CFrame, items, position: Vector3, vector2: Vector3)
	local v

	if (vector2 - position).Magnitude > 0.02 then
		v = CFrame.lookAt(position, vector2)
	else
		v = CFrame.new(position) * cframe.Rotation
	end

	p.CFrame = v * cframe:Inverse()

	for _, item in items do
		item.part.CFrame = p.CFrame * item.offsetCFrame
	end
end

return function(data)
	local hookTemplateName = data.hookTemplateName
	local v

	if type(hookTemplateName) == "string" then
		v = hookTemplateName ~= ""
	else
		v = false
	end

	assert(v, "BattleConfig.visual.hookTemplateName is missing")
	local model = data.effectAssetRoot:FindFirstChild(hookTemplateName)
	assert(model and model:IsA("Model"), string.format("钩爪素材模型缺失：%s", hookTemplateName))
	local v2 = discoverHookChainSegmentCount(model)
	local cFrames = table.create(v2)

	for i = 1, v2 do
		local part = model:FindFirstChild(string.format("连接%d", i))
		local attachment = part and part:FindFirstChild("朝向标记")
		assert(
			part and part:IsA("BasePart") and attachment and attachment:IsA("Attachment"),
			string.format("钩爪素材模型缺少连接%d或其朝向标记", i)
		)
		cFrames[i] = attachment.CFrame
	end

	local part = model:FindFirstChild("碰撞箱")
	local attachment = part and part:FindFirstChild("朝向标记")
	assert(part and part:IsA("BasePart") and attachment and attachment:IsA("Attachment"), "钩爪素材模型缺少碰撞箱或其朝向标记")
	local cFrame = attachment.CFrame
	local clone = model:Clone()
	clone.Name = string.format("%s_HookGrapple", data.ballId)

	if data.ownerSlotId then
		clone:SetAttribute("BattleOwnerSlotId", data.ownerSlotId)
	end

	local firstChild = clone:FindFirstChild("碰撞箱")
	assert(firstChild, "钩爪克隆缺少碰撞箱")
	clone.PrimaryPart = firstChild
	local children = table.create(v2)
	local v3 = table.create(v2)

	for i = 1, v2 do
		local child = clone:FindFirstChild(string.format("连接%d", i))
		assert(child, string.format("钩爪克隆缺少连接%d", i))
		children[i] = child
		v3[i] = captureDecorations(child)
	end

	local v4 = captureDecorations(firstChild)

	for _, part2 in ipairs(clone:GetDescendants()) do
		if not part2:IsA("BasePart") then
			continue
		end

		part2.Anchored = true
		part2.CanCollide = false
		part2.CanQuery = false
		part2.CanTouch = false
	end

	local function applyFrame(ropePositions)
		if not ropePositions or #ropePositions < v2 + 1 then
			return false
		end

		local v5 = table.create(#ropePositions)

		for k, v6 in ropePositions do
			local arenaCFrame = data.arenaCFrame
			local arenaScale = data.arenaScale
			v5[k] = arenaCFrame:PointToWorldSpace((Vector3.new(v6.X * arenaScale, v6.Y * arenaScale, -0 * arenaScale)))
		end

		for i = 1, v2 do
			applyHookSegmentPart(children[i], cFrames[i], v3[i], v5[i], v5[i + 1])
		end

		local v6 = v5[v2]
		local v7 = v5[v2 + 1]
		local v8 = v7 - v6
		local v9

		if v8.Magnitude > 0.02 then
			v9 = v7 + v8.Unit
		else
			v9 = v7 + createVector(0, 0, 1)
		end

		firstChild.CFrame = CFrame.lookAt(v7, v9) * cFrame:Inverse()

		for _, v10 in v4 do
			v10.part.CFrame = firstChild.CFrame * v10.offsetCFrame
		end

		return true
	end

	local flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function finish()
		if flag then
			return
		end

		flag = true
		clone:Destroy()
	end

	task.spawn(function()
		while not flag do
			local ballState = data.getBallState(data.ballId)
			local hookGrapple = ballState and ballState.traits and ballState.traits.HookGrapple

			if not hookGrapple then
				break
			end

			if applyFrame(hookGrapple.ropePositions) and clone.Parent == nil then
				clone.Parent = data.rootFolder
			end

			RunService.Heartbeat:Wait()
		end

		finish() -- equivalent call inferred; original call site unknown
	end)
	return {
		destroy = finish
	}
end
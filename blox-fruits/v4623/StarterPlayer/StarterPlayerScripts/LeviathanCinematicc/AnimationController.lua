local AnimationController = {}
local TweenService = game:GetService("TweenService")

-- equivalent calls inferred from this helper; original call sites unknown
local function getBlendFactor(p, p2, p3, linear, out)
	local v = p2 - p
	return TweenService:GetValue((p3 - p) / v, linear, out)
end

local getRecursivePoses

getRecursivePoses = function(list, instance)
	local result = {}

	for _, v in ipairs(list[4] or {}) do
		local child = instance:FindFirstChild(v[1])

		if not child then
			continue
		end

		table.insert(result, { v, child })

		for _, v2 in pairs(getRecursivePoses(v, child) or {}) do
			table.insert(result, v2)
		end
	end

	return result
end

local function applyAnimationToMotor(instance, keyframes, _TimePosition)
	local children = keyframes.Children
	table.sort(children, function(a, b)
		return a[2] < b[2]
	end)
	local v = nil
	local v2 = nil

	for i = 1, #children - 1 do
		if not (children[i][2] <= _TimePosition and _TimePosition <= children[i + 1][2]) then
			continue
		end

		v = children[i]
		v2 = children[i + 1]
		break
	end

	if not (v and v2) then
		return
	end

	local recursivePoses = getRecursivePoses(v, instance)
	local recursivePoses2 = getRecursivePoses(v2, instance)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function findEndSubPose(recursivePos)
		for _, recursivePos2 in pairs(recursivePoses2) do
			if recursivePos2[2] == recursivePos[2] then
				return recursivePos2[1]
			end
		end
	end

	for _, recursivePos in ipairs(recursivePoses) do
		local recursivePo = recursivePos[1]
		local endSubPose = findEndSubPose(recursivePos) -- equivalent call inferred; original call site unknown

		if not endSubPose then
			continue
		end

		local bone = recursivePos[2]

		if not (bone and bone:IsA("Bone")) then
			continue
		end

		local components, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17 = recursivePo[2]:Lerp(
			endSubPose[2],
			getBlendFactor(v[2], v2[2], _TimePosition, Enum.EasingStyle.Linear, Enum.EasingDirection.Out) * recursivePo[3]
		):GetComponents()
		local v18 = components * 47.686
		local v19 = v7 * 47.686
		local v20 = v8 * 47.686
		bone.Transform = CFrame.new(v18, v19, v20, v9, v10, v11, v12, v13, v14, v15, v16, v17)
	end
end

function AnimationController.new(instance)
	local self = setmetatable({}, {
		__index = AnimationController
	})
	self.Instance = instance
	self.Tracks = {}
	self.CurrentlyEffected = {}
	return self
end

function AnimationController:_Update()
	for _, track in pairs(self.Tracks) do
		if not (track._TimePosition < 0) then
			applyAnimationToMotor(self.Instance, track.keyframes, track._TimePosition)
		end
	end
end

function AnimationController:LoadAnimation(keyframes)
	local object2 = setmetatable({
		controller = self,
		keyframes = keyframes,
		_TimePosition = -1
	}, {
		__index = function(p2, p3)
			if p3 == "TimePosition" then
				return p2._TimePosition
			end
		end,
		__newindex = function(p2, p3, timePosition)
			if p3 == "TimePosition" then
				p2._TimePosition = timePosition
				p2.controller:_Update()
			end
		end
	})
	table.insert(self.Tracks, object2)
	table.sort(self.Tracks, function(a, b)
		return b.keyframes.Priority.Value > a.keyframes.Priority.Value
	end)
	self:_Update()
	return object2
end

return AnimationController
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local genSlotSuffix = ReplicatedStorage.Modules.Gameplay:FindFirstChild("GenSlotSuffix")
local success, result = pcall(function()
	return genSlotSuffix and require(genSlotSuffix)
end)
local fn = not (success and result and result.forSlot) and function(p)
	if p == 1 then
		return ""
	elseif p == 2 then
		return "_Mirror"
	end

	return "_S" .. p
end or result.forSlot
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveValveForSlot(model, i)
	local child = model:FindFirstChild("ValveReference" .. fn(i))

	if child and child.Value and child.Value:IsA("BasePart") then
		return child.Value
	end

	return nil
end

local v2 = {
	IchorSpout = true,
	Top_Diamond_Plate = true,
	Top_Ichor_Tube = true
}

local function tryCapturePipeOrShakePart(model, data, descendant)
	if descendant:IsA("Model") and descendant.Name:match("^Pipe%d*") then
		local parent = descendant.Parent

		if parent and parent:IsA("Model") and (parent.Name == "BaseMachine" or parent.Name == "wipGenerator") and data.pipeBasePivots[descendant] == nil then
			data.pipeBasePivots[descendant] = descendant:GetPivot()
			table.insert(data.pipeModels, descendant)
		end
	else
		if not descendant:IsA("BasePart") then
			return
		end

		if descendant.Name == "IchorTubeCenter" then
			if data.pipeShakeBaseCFrames[descendant] == nil then
				data.pipeShakeBaseCFrames[descendant] = descendant.CFrame
				table.insert(data.pipeShakeParts, descendant)
			end
		elseif v2[descendant.Name] then
			local parent = descendant.Parent

			while parent and parent ~= model do
				if parent:IsA("Model") and parent.Name:match("^BaseMachine") then
					if data.pipeShakeBaseCFrames[descendant] == nil then
						data.pipeShakeBaseCFrames[descendant] = descendant.CFrame
						table.insert(data.pipeShakeParts, descendant)
					end

					return
				else
					parent = parent.Parent
				end
			end
		end
	end
end

local function registerGen(model)
	if v[model] or not model:IsA("Model") then
		return
	end

	local valveForSlots = {}
	local cFrames = {}
	local valveAngle = {}

	for i = 1, 8 do
		local valveForSlot = resolveValveForSlot(model, i) -- equivalent call inferred; original call site unknown

		if not valveForSlot then
			continue
		end

		valveForSlots[i] = valveForSlot
		cFrames[i] = valveForSlot.CFrame
		valveAngle[i] = 0
	end

	local v4 = {
		valveBySlot = valveForSlots,
		valveBaseCFrame = cFrames,
		valveAngle = valveAngle,
		pipeModels = {},
		pipeShakeParts = {},
		pipeBasePivots = {},
		pipeShakeBaseCFrames = {},
		shakeClock = 0
	}

	for _, descendant in ipairs(model:GetDescendants()) do
		tryCapturePipeOrShakePart(model, v4, descendant)
	end

	v4.descendantAddedConn = model.DescendantAdded:Connect(function(descendant)
		tryCapturePipeOrShakePart(model, v4, descendant)
	end)
	v[model] = v4
end

local function unregisterGen(p)
	local v3 = v[p]

	if v3 and v3.descendantAddedConn then
		v3.descendantAddedConn:Disconnect()
		v3.descendantAddedConn = nil
	end

	v[p] = nil
end

for _, v3 in ipairs(CollectionService:GetTagged("GenFXManaged")) do
	registerGen(v3)
end

CollectionService:GetInstanceAddedSignal("GenFXManaged"):Connect(registerGen)
CollectionService:GetInstanceRemovedSignal("GenFXManaged"):Connect(unregisterGen)
RunService.Heartbeat:Connect(function(dt)
	for k, v3 in pairs(v) do
		if k.Parent then
			if k:GetAttribute("AnyActiveSlot") == true then
				for i = 1, 8 do
					if k:GetAttribute("Slot" .. i .. "Spinning") ~= true then
						continue
					end

					local value = v3.valveBySlot[i]

					if not value then
						local child = k:FindFirstChild("ValveReference" .. fn(i))

						if child and child.Value and child.Value:IsA("BasePart") then
							value = child.Value
						else
							value = nil
						end

						if not value then
							continue
						end

						v3.valveBySlot[i] = value
						v3.valveBaseCFrame[i] = value.CFrame
						v3.valveAngle[i] = 0
					end

					if not value.Parent then
						continue
					end

					v3.valveAngle[i] = (v3.valveAngle[i] + 3.141592653589793 * dt) % 6.283185307179586
					value.CFrame = v3.valveBaseCFrame[i] * CFrame.Angles(0, 0, v3.valveAngle[i])
				end

				v3.shakeClock += dt
				local v4 = math.sin(v3.shakeClock * 3.141592653589793 * 12) * 0.04

				for _, pipeModel in ipairs(v3.pipeModels) do
					local pipeBasePivot = v3.pipeBasePivots[pipeModel]

					if pipeBasePivot and pipeModel.Parent then
						pipeModel:PivotTo(pipeBasePivot + Vector3.new(v4, 0, 0))
					end
				end

				for _, pipeShakePart in ipairs(v3.pipeShakeParts) do
					local pipeShakeBaseCFrame = v3.pipeShakeBaseCFrames[pipeShakePart]

					if pipeShakeBaseCFrame and pipeShakePart.Parent then
						pipeShakePart.CFrame = pipeShakeBaseCFrame + Vector3.new(v4, 0, 0)
					end
				end
			elseif v3.shakeClock ~= 0 then
				v3.shakeClock = 0

				for _, pipeModel in ipairs(v3.pipeModels) do
					if v3.pipeBasePivots[pipeModel] and pipeModel.Parent then
						pipeModel:PivotTo(v3.pipeBasePivots[pipeModel])
					end
				end

				for _, pipeShakePart in ipairs(v3.pipeShakeParts) do
					if v3.pipeShakeBaseCFrames[pipeShakePart] and pipeShakePart.Parent then
						pipeShakePart.CFrame = v3.pipeShakeBaseCFrames[pipeShakePart]
					end
				end
			end
		else
			if v3.descendantAddedConn then
				v3.descendantAddedConn:Disconnect()
				v3.descendantAddedConn = nil
			end

			v[k] = nil
		end
	end
end)
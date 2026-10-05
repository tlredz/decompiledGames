local Net = require(game.ReplicatedStorage.Modules.Net)
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local SkinVFX = require(game.ReplicatedStorage.Util.SkinVFX)
local CollectionService = game:GetService("CollectionService")
local TestRigUtil = {
	Constants = {
		MOVESET_ATTRIBUTE = "TestRigMoveset",
		MOVESET_TOOL_ATTRIBUTE = "TestRigMovesetTool",
		RIG_TAG = "TestRig",
		TRANSFORMATION_MODEL_NAMES = {
			["Yeti-Yeti"] = "YetiRig",
			["Tiger-Tiger"] = "TigerRig",
			["Werewolf (Tiger)-Werewolf (Tiger)"] = "TigerRig",
			["Fiend (Yeti)-Fiend (Yeti)"] = "YetiRig",
			["Magnet-Magnet"] = "MagnetRig"
		}
	}
}

function TestRigUtil.toolNameTagFor(p)
	return (`{TestRigUtil.Constants.MOVESET_TOOL_ATTRIBUTE}_{p.UserId}`)
end

function TestRigUtil.rigNameTagFor(p)
	return (`{TestRigUtil.Constants.RIG_TAG}_{p.UserId}`)
end

function TestRigUtil.rigNameFor(p)
	return (`{p.Name}'s Test Rig`)
end

function TestRigUtil.getExtents(instance, flag: boolean?)
	if flag or not instance:GetAttribute("_GotExtents") then
		local function getDeepModelBounds(instance2)
			local model = Instance.new("Model")
			local extractParts

			extractParts = function(instance3)
				for _, child in ipairs(instance3:GetChildren()) do
					if child:IsA("BasePart") then
						local clone = child:Clone()
						clone.Parent = model
					elseif child:IsA("Folder") or child:IsA("Model") then
						extractParts(child)
					end
				end
			end

			extractParts(instance2)
			local boundingBox, v = model:GetBoundingBox()
			model:Destroy()
			return boundingBox, v
		end

		local _, v = getDeepModelBounds(instance)
		instance:SetAttribute("_ExtentsSize", v)
		instance:SetAttribute("_GotExtents", true)
	end

	if not instance:GetAttribute("_HookedChildAdded") then
		instance:SetAttribute("_HookedChildAdded", true)
		instance.ChildAdded:Connect(function(child)
			for _, v in pairs(TestRigUtil.Constants.TRANSFORMATION_MODEL_NAMES) do
				if v == child.Name then
					instance:SetAttribute("_GotExtents", nil)
				end
			end
		end)
		instance.ChildRemoved:Connect(function(child)
			for _, v in pairs(TestRigUtil.Constants.TRANSFORMATION_MODEL_NAMES) do
				if v == child.Name then
					instance:SetAttribute("_GotExtents", nil)
				end
			end
		end)
	end

	return instance:GetPivot(), (instance:GetAttribute("_ExtentsSize"))
end

function TestRigUtil.isTransformed(p, childName: string?)
	local v = TestRigUtil.tryFindMovesetTool(p)

	if not v then
		return false
	end

	local isTransformed = v:FindFirstChild("IsTransformed")

	if isTransformed and isTransformed.Value then
		if not childName or v.Parent and v.Parent:FindFirstChild(childName) then
			return true
		end

		return false
	end

	return false
end

function TestRigUtil.tryFindMovesetTool(p)
	local v = TestRigUtil.tryFindRig(p)

	if not v then
		return nil
	end

	local tagged = CollectionService:GetTagged(TestRigUtil.toolNameTagFor(p))
	assert(#tagged <= 1, (`#tagged tools > 1 = {tagged}`))
	local v2 = tagged[1]

	if v2 and v2.Parent == v then
		return v2
	end

	return nil
end

function TestRigUtil.tryFindAllRigs(p)
	return (CollectionService:GetTagged(TestRigUtil.rigNameTagFor(p)))
end

function TestRigUtil.tryFindRig(p)
	local v = TestRigUtil.tryFindAllRigs(p)

	if #v > 1 then
		warn("#rigs > 1")
		return nil
	end

	if v[1] and v[1].Parent and v[1].Parent == workspace.Enemies then
		return v[1]
	end

	return nil
end

function TestRigUtil.tryFindCommandRig(p)
	local v = TestRigUtil.tryFindRig(p)

	if not v then
		return nil, nil, nil
	end

	local humanoid = v:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = v:FindFirstChild("HumanoidRootPart")

	if humanoid and humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return v, humanoid, humanoidRootPart
	end

	return nil, nil, nil
end

function TestRigUtil.waitForCommandRig(instance, callback)
	local thread = task.defer(function()
		local model, humanoid, primaryPart, _RigNetwork

		while true do
			model, humanoid, primaryPart = TestRigUtil.tryFindCommandRig(instance)
			_RigNetwork = instance:FindFirstChild("_RigNetwork")

			if model and humanoid and primaryPart and _RigNetwork then
				break
			end

			task.wait()
		end

		humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

		if not callback then
			return
		end

		callback({
			Model = model,
			Network = _RigNetwork,
			Humanoid = humanoid,
			PrimaryPart = primaryPart
		})
	end)
	return function()
		task.cancel(thread)
	end
end

function TestRigUtil.connectOnRigAdded(p, callback)
	local maid = Trove.new()
	assert(maid):Add(function()
		maid = nil
	end)
	local v = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function check()
		local v2 = TestRigUtil.tryFindRig(p)

		if v2 and v2 ~= v then
			task.spawn(callback, v2)
		end

		v = v2
	end

	maid:Add(task.defer(function()
		check() -- equivalent call inferred; original call site unknown
		maid:Add(CollectionService:GetInstanceAddedSignal(TestRigUtil.rigNameTagFor(p)):Connect(check))
		maid:Add(CollectionService:GetInstanceRemovedSignal(TestRigUtil.rigNameTagFor(p)):Connect(check))
	end))
	return function()
		if maid then
			maid:Destroy()
		end
	end
end

function TestRigUtil.spawnRig(_, moveset: string, skin: string?)
	local RunService = game:GetService("RunService")
	assert(RunService:IsClient())
	local maid = Trove.new()
	assert(maid):Add(function()
		maid = nil
	end)
	maid:Add(task.defer(function()
		Net:RemoteFunction("SceneNetwork"):InvokeServer({
			Context = "SpawnRig",
			Moveset = moveset,
			Skin = skin
		})
	end))
	return function()
		if maid then
			maid:Destroy()
		end
	end
end

function TestRigUtil.setSkin(p: number, instance, p2)
	if p2 then
		SkinVFX.applySkin(p, p2)
	end

	for _, child in pairs(instance:GetChildren()) do
		if not child:GetAttribute("_SkinVFXFolder") then
			continue
		end

		SkinVFX.updateVFXFolder(child, p)
		break
	end
end

function TestRigUtil.updateSkin(p, p2: number, p3)
	local v = TestRigUtil.tryFindRig(p)

	if v then
		TestRigUtil.setSkin(p2, v, p3)
	end
end

return TestRigUtil
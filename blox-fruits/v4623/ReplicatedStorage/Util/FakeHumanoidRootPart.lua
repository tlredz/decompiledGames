local RunService = game:GetService("RunService")
RunService:IsServer()
require(script.Dragon)
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local RunService2 = game:GetService("RunService")

if RunService2:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	local Global = require(game.ReplicatedStorage.Global)

	function Global.canDamageCustomRoot(p)
		return typeof(p) == "table" and rawget(p, "canDamageCustomRoot")
	end

	local Global2 = require(game.ReplicatedStorage.Global)

	function Global2.isCustomRoot(p)
		return typeof(p) == "table" and rawget(p, "__Reference")
	end

	local Global3 = require(game.ReplicatedStorage.Global)

	function Global3.ensureOriginalRoot(p)
		if typeof(p) == "table" then
			return (rawget(p, "__Reference"))
		end

		return p
	end

	local Global4 = require(game.ReplicatedStorage.Global)

	function Global4.getRootFromPart(p)
		local parent = p

		repeat
			parent = parent.Parent
		until not parent or parent:IsA("Model") and game.Players:GetPlayerFromCharacter(parent)

		if not parent then
			return parent or p
		end

		local Global5 = require(game.ReplicatedStorage.Global)
		local wrappedPlayer = Global5.getWrappedPlayer(game.Players:GetPlayerFromCharacter(parent))

		if wrappedPlayer then
			return (wrappedPlayer:getRoot())
		end

		parent = parent:FindFirstChild("HumanoidRootPart") or nil
		return parent or p
	end
end

local function makeFakeRoot(childName, parent)
	if typeof(childName) == "table" then
		local module = require(script[childName.__FakeType])
		setmetatable(childName, module.metatable)
		return childName
	else
		assert(script:FindFirstChild(childName), "FakeRoot type not found")
		local result = {
			Parent = parent.Parent,
			__Reference = parent,
			__FakeType = childName,
			canDamageCustomRoot = true
		}
		local module = require(script[childName])
		result.ReplicationValues = {}

		for k, className in pairs(module.ReplicationValues) do
			result.ReplicationValues[k] = Instance.new(className, parent)
		end

		result.DataValues = module.ReplicationValues

		if module.onApply then
			module.onApply(result)
		end

		for k, v in pairs(module.Attributes or {}) do
			result[k] = v
		end

		setmetatable(result, module.metatable)
		parent.AncestryChanged:Connect(function(_, parent2)
			if parent2 == nil then
				for _, replicationValue in pairs(result.ReplicationValues) do
					replicationValue:Destroy()
				end
			end
		end)
		return result
	end
end

return makeFakeRoot
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemModels = {}
local v = {}

function ItemModels.FindTool(childName: string)
	local itemAssets = ReplicatedStorage:FindFirstChild("ItemAssets")
	local tools

	if itemAssets ~= nil then
		tools = itemAssets:FindFirstChild("Tools") or nil
	end

	if tools == nil then
		return nil
	end

	local child = tools:FindFirstChild(childName)

	if child ~= nil then
		return child
	end

	for _, child2 in tools:GetChildren() do
		local child3 = child2:FindFirstChild(childName)

		if child3 ~= nil then
			return child3
		end
	end

	return nil
end

function ItemModels.FindFishingModel(childName: string)
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local fishingModels

	if assets ~= nil then
		fishingModels = assets:FindFirstChild("Fishing Models") or nil
	end

	if fishingModels == nil then
		return nil
	end

	local function take(instance)
		if instance == nil or not (instance:IsA("Model") or instance:IsA("BasePart")) then
			return nil
		end

		return instance
	end

	local instance = fishingModels:FindFirstChild(childName)

	if instance == nil or not (instance:IsA("Model") or instance:IsA("BasePart")) then
		instance = nil
	end

	if instance ~= nil then
		return instance
	end

	for _, child in fishingModels:GetChildren() do
		local instance2 = child:FindFirstChild(childName)

		if instance2 == nil or not (instance2:IsA("Model") or instance2:IsA("BasePart")) then
			instance2 = nil
		end

		if instance2 ~= nil then
			return instance2
		end
	end

	return nil
end

function ItemModels.Get(childName: string, value: string?)
	local v2 = value or "Equipped"
	local formatted = ("%*\0%*"):format(v2, childName)
	local v3 = v[formatted]

	if v3 ~= nil then
		return v3 or nil
	end

	local itemAssets = ReplicatedStorage:FindFirstChild("ItemAssets")
	local v4 = nil

	if itemAssets ~= nil then
		local instance = ItemModels.FindTool(childName)

		if instance ~= nil then
			for _, childName2 in ipairs({ v2, v2 == "Equipped" and "UnEquipped" or "Equipped" }) do
				local child = instance:FindFirstChild(childName2)
				local childModel

				if child ~= nil then
					childModel = child:FindFirstChildWhichIsA("Model", true) or child:FindFirstChildWhichIsA(
						"BasePart",
						true
					) or nil
				end

				if childModel == nil then
					continue
				end

				v4 = childModel
				break
			end

			if v4 == nil and (instance:IsA("Model") or instance:IsA("BasePart")) then
				v4 = instance
			end
		end

		if v4 == nil then
			local regular = itemAssets:FindFirstChild("Regular")

			if regular ~= nil then
				local instance2 = regular:FindFirstChild(childName, true)

				if instance2 ~= nil and (instance2:IsA("Model") or instance2:IsA("BasePart")) then
					v4 = instance2
				end
			end
		end
	end

	if v4 == nil then
		v4 = ItemModels.FindFishingModel(childName)
	end

	if v4 == nil then
		local assets = ReplicatedStorage:FindFirstChild("Assets")
		local instance

		if assets ~= nil then
			instance = assets:FindFirstChild((`{childName}Model`)) or nil
		end

		if instance ~= nil and (instance:IsA("Model") or instance:IsA("BasePart")) then
			v4 = instance
		end
	end

	if v4 == nil then
		local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
		local item = Items[childName]
		local v5

		if not (item == nil or item.PackContents == nil) then
			v5 = next(item.PackContents) or nil
		end

		if v5 ~= nil and v5 ~= childName then
			v4 = ItemModels.Get(v5, value)
		end
	end

	if itemAssets == nil and v4 == nil then
		return nil
	end

	v[formatted] = v4 or false
	return v4
end

return ItemModels
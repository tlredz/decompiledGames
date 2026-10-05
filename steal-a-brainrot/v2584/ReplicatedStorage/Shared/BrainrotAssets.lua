local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local models = ReplicatedStorage:WaitForChild("Models")
local animals = models:WaitForChild("Animals")
local traitsPerAnimal = models:WaitForChild("TraitsPerAnimal")
local spawnEffectsController = ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("SpawnEffectsController")
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getSharedModel(childName: string)
	return animals:FindFirstChild(childName)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSharedTrait(childName: string, childName2: string)
	local child = traitsPerAnimal:FindFirstChild(childName)
	return child and child:FindFirstChild(childName2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSharedEffect(childName: string)
	return spawnEffectsController:FindFirstChild(childName)
end

if RunService:IsServer() then
	local ServerStorage = game:GetService("ServerStorage")
	local __AssetLibrary = nil

	local function getLibraryFolder()
		if not __AssetLibrary then
			__AssetLibrary = ServerStorage:FindFirstChild("__AssetLibrary")
		end

		return __AssetLibrary
	end

	function v.getModel(childName: string, _: number?)
		if not __AssetLibrary then
			__AssetLibrary = ServerStorage:FindFirstChild("__AssetLibrary")
		end

		local m = __AssetLibrary and __AssetLibrary:FindFirstChild("m")
		return m and m:FindFirstChild(childName) or animals:FindFirstChild(childName)
	end

	function v.getModelBestEffort(p: string, _, _: number?)
		return v.getModel(p)
	end

	function v.getTrait(childName: string, childName2: string)
		if not __AssetLibrary then
			__AssetLibrary = ServerStorage:FindFirstChild("__AssetLibrary")
		end

		local t = __AssetLibrary and __AssetLibrary:FindFirstChild("t")
		local child = t and t:FindFirstChild(childName)
		local child2 = child and child:FindFirstChild(childName2)

		if not child2 then
			child2 = getSharedTrait(childName, childName2)
		end

		return child2
	end

	function v.getEffect(childName: string)
		if not __AssetLibrary then
			__AssetLibrary = ServerStorage:FindFirstChild("__AssetLibrary")
		end

		local e = __AssetLibrary and __AssetLibrary:FindFirstChild("e")
		return e and e:FindFirstChild(childName) or spawnEffectsController:FindFirstChild(childName)
	end

	function v.getEventAsset(childName: string, childName2: string)
		if not __AssetLibrary then
			__AssetLibrary = ServerStorage:FindFirstChild("__AssetLibrary")
		end

		local v3 = __AssetLibrary and __AssetLibrary:FindFirstChild("v")
		local child = v3 and v3:FindFirstChild(childName)
		return child and child:FindFirstChild(childName2)
	end

	function v.getSize(p: string)
		local model = v.getModel(p)
		return model and model:GetExtentsSize()
	end

	function v.preload(_) end

	return v
else
	local AssetStreamController = require(ReplicatedStorage.Controllers.AssetStreamController)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isSharedModelReady(folder)
		local __AssetDescendantCount = folder:GetAttribute("__AssetDescendantCount")
		return typeof(__AssetDescendantCount) ~= "number" or __AssetDescendantCount <= #folder:GetDescendants()
	end

	local function waitForSharedModel(sharedModel, p: number)
		local v2 = os.clock() + p

		while sharedModel.Parent and os.clock() < v2 do
			if isSharedModelReady(sharedModel) then
				return sharedModel
			else
				task.wait()
			end
		end

		return nil
	end

	local brainrotSizes = nil

	local function getSizesFolder()
		if not brainrotSizes then
			brainrotSizes = ReplicatedStorage:FindFirstChild("BrainrotSizes")
		end

		return brainrotSizes
	end

	function v.getModel(childName: string, value: number?)
		local sharedModel = getSharedModel(childName) -- equivalent call inferred; original call site unknown
		local v2 = sharedModel and waitForSharedModel(sharedModel, value or 30)

		if v2 then
			return v2
		end

		return AssetStreamController.waitForAsset("m", childName, value)
	end

	function v.getModelBestEffort(childName: string, callback, value: number?)
		local sharedModel = getSharedModel(childName) -- equivalent call inferred; original call site unknown

		if sharedModel then
			if isSharedModelReady(sharedModel) then
				return sharedModel
			end

			if callback then
				task.spawn(function()
					local v2 = waitForSharedModel(sharedModel, value or 10)

					if v2 then
						callback(v2)
					end
				end)
			end

			return nil
		else
			local v2 = value or 10
			AssetStreamController.requestAssets("m", { childName })

			if callback then
				task.spawn(function()
					local v3 = AssetStreamController.waitForAsset("m", childName, v2)

					if v3 then
						callback(v3)
					end
				end)
			end

			return nil
		end
	end

	function v.getTrait(childName: string, childName2: string)
		local sharedTrait = getSharedTrait(childName, childName2) -- equivalent call inferred; original call site unknown

		if sharedTrait then
			return sharedTrait
		end

		return AssetStreamController.waitForAsset("t", childName .. "\1" .. childName2)
	end

	function v.getEffect(childName: string)
		local sharedEffect = getSharedEffect(childName) -- equivalent call inferred; original call site unknown

		if sharedEffect then
			return sharedEffect
		end

		return AssetStreamController.waitForAsset("e", childName)
	end

	function v.getEventAsset(p: string, p2: string)
		return AssetStreamController.waitForAsset("v", p .. "\1" .. p2)
	end

	function v.getSize(childName: string)
		local sharedModel = getSharedModel(childName) -- equivalent call inferred; original call site unknown

		if sharedModel then
			return sharedModel:GetExtentsSize()
		end

		if not brainrotSizes then
			brainrotSizes = ReplicatedStorage:FindFirstChild("BrainrotSizes")
		end

		local vector3Value = brainrotSizes and brainrotSizes:FindFirstChild(childName)

		if vector3Value and vector3Value:IsA("Vector3Value") then
			return vector3Value.Value
		end

		return nil
	end

	function v.preload(items)
		local childNames = {}

		for _, childName in items do
			if not animals:FindFirstChild(childName) then
				table.insert(childNames, childName)
			end
		end

		if #childNames > 0 then
			AssetStreamController.requestAssets("m", childNames)
		end
	end

	return v
end
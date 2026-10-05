local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Util.Debris)
local WaitForExpectedDescendants = require(ReplicatedStorage.Util.WaitForExpectedDescendants)
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local v = {}
local isServer = RunService:IsServer()
local v2 = RunService:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false

function createModel()
	local model = Instance.new("Model")
	model.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
	model.Name = "PersistentParts"
	model.Parent = workspace._WorldOrigin
	model.AncestryChanged:Once(function()
		if not model.Parent then
			createModel()
		end
	end)
	local part = Instance.new("Part")
	part.Name = "__PersistentRoot"
	part.Size = createVector(0.1, 0.1, 0.1)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Transparency = 1
	part.Position = createVector(0, 10000, 0)
	part.Parent = model
end

if isServer and v2 then
	createModel()
end

if isServer and v2 then
	local folder_2 = Instance.new("Folder", ReplicatedStorage)
	folder_2.Name = "StreamedQueue"
	task.spawn(function()
		while task.wait(1) do
			for k, v3 in pairs(v) do
				local v4 = v3
				local v5 = k
				pcall(function()
					local v6 = v4[2]
					assert(typeof(v6) == "number", (`bad type: {typeof(v6)}`))

					if v6 < os.clock() then
						v[v5] = nil
						local v7 = v4[1]

						if typeof(v7) == "Instance" and v7.Parent then
							v7:Destroy()
						end

						local connection = v4[3]

						if typeof(connection) == "RBXScriptConnection" then
							connection:Disconnect()
						end
					end
				end)
			end
		end
	end)
elseif v2 then
	task.spawn(function()
		local streamedQueue = ReplicatedStorage:WaitForChild("StreamedQueue")

		local function FixObj(objectValue)
			objectValue:GetAttributeChangedSignal("Destroyed"):Connect(function()
				if objectValue:GetAttribute("Destroyed") then
					if objectValue:IsA("ObjectValue") and objectValue.Value then
						objectValue.Value:Destroy()
						objectValue.Value = nil
					end

					task.delay(10, function()
						objectValue:Destroy()
					end)
				end
			end)
			objectValue.AncestryChanged:Connect(function(_, parent)
				if not parent then
					task.delay(10, function()
						objectValue:Destroy()
					end)
				end
			end)
		end

		for _, child in pairs(streamedQueue:GetChildren()) do
			FixObj(child)
		end

		streamedQueue.ChildAdded:Connect(FixObj)
	end)
end

function DecodeObj(list, flag: boolean?)
	if list[5] then
		local Global = require(game.ReplicatedStorage.Global)
		local _ = Global.TestGame
		WaitForExpectedDescendants(list[5], 5, true)
		return list[5]
	else
		local v3 = os.clock() + (flag and 10 or 2)
		tick()
		local v4 = list[1]
		assert(typeof(v4) == "string")
		local child = ReplicatedStorage.StreamedQueue:WaitForChild(v4, v3 - os.clock())

		if not child or child:GetAttribute("Destroyed") then
			return list[5]
		end

		if child.Value then
			WaitForExpectedDescendants(child.Value, 5, true)
			return child.Value
		end

		local thread = coroutine.running()
		tick()
		local changedConnection = child.Changed:Connect(function(_)
			coroutine.resume(thread)
		end)
		local thread2 = task.delay(v3 - os.clock(), coroutine.resume, thread)
		coroutine.yield()
		changedConnection:Disconnect()
		pcall(task.cancel, thread2)

		if child.Value and not child:GetAttribute("Destroyed") then
			WaitForExpectedDescendants(child.Value, 5, true)
			return child.Value
		else
			return list[5]
		end
	end
end

local v3 = {
	Model = true,
	Folder = true,
	Part = true,
	MeshPart = true
}
local v4 = {
	[workspace.Characters] = true,
	[workspace.Enemies] = true,
	[workspace.Boats] = true,
	[workspace.SeaBeasts] = true
}
local v5 = {
	HumanoidRootPart = true,
	Head = true,
	LowerTorso = true,
	UpperTorso = true,
	LeftUpperArm = true,
	RightUpperArm = true,
	LeftLowerArm = true,
	RightLowerArm = true,
	LeftLowerLeg = true,
	RightLowerLeg = true,
	LeftUpperLeg = true,
	RightUpperLeg = true,
	LeftHand = true,
	RightHand = true,
	LeftFoot = true,
	RightFoot = true
}

function EncodeObj2(folder)
	if v[folder] then
		v[folder][2] = os.clock() + 15
		local v6 = v[folder][1]
		assert(typeof(v6) == "Instance")
		return {
			v6.Name,
			1,
			"__StreamedObject",
			false,
			folder
		}
	else
		if folder:IsDescendantOf(workspace.Map) then
			return folder
		end

		local v6 = folder:FindFirstChild("Humanoid") ~= nil

		if (v6 == false and folder.Parent and v5[folder.Name] and folder.Parent:FindFirstChild("Humanoid") and true or v6) == false and v3[folder.ClassName] and not v4[folder.Parent] then
			local ancestryChangedConnection = nil
			local descendants = folder:GetDescendants()
			local count = #descendants

			if count >= 1 then
				local v7 = {}
				local names = {}

				for _, touchTransmitter in pairs(descendants) do
					if touchTransmitter:IsA("TouchTransmitter") then
						count -= 1
					else
						if not v7[touchTransmitter.Name] then
							table.insert(names, touchTransmitter.Name)
						end

						v7[touchTransmitter.Name] = (v7[touchTransmitter.Name] or 0) + 1
					end
				end

				if not (count <= 0) then
					local HttpService = game:GetService("HttpService")
					local jSONEncode = HttpService:JSONEncode(names)
					folder:SetAttribute("ExpectedDescendantsNames", jSONEncode)
					folder:SetAttribute("ExpectedDescendants", count)
					local Global = require(game.ReplicatedStorage.Global)

					if Global.TestGame then
						local Global2 = require(game.ReplicatedStorage.Global)
						Global2.TestGameWarn("Now tracking ExpectedDescendants:", folder:GetFullName(), count)
					end

					local descendantRemovingConnection = folder.DescendantRemoving:Connect(function(descendant)
						local v8 = v7[descendant.Name]

						if v8 then
							if v8 <= 1 then
								v7[descendant.Name] = nil
								local index = table.find(names, descendant.Name)

								if index then
									table.remove(names, index)
								end

								local HttpService2 = game:GetService("HttpService")
								jSONEncode = HttpService2:JSONEncode(names)
								folder:SetAttribute("ExpectedDescendantsNames", jSONEncode)
							else
								local v9 = v7
								local name = descendant.Name
								v9[name] -= 1
							end
						end

						local Global2 = require(game.ReplicatedStorage.Global)
						Global2.TestGamePrint("Remove", descendant)
						count -= 1
						folder:SetAttribute("ExpectedDescendants", nil)
						folder:SetAttribute("ExpectedDescendants", count)
						folder:SetAttribute("ExpectedDescendantsNames", nil)
						folder:SetAttribute("ExpectedDescendantsNames", jSONEncode)
					end)
					ancestryChangedConnection = folder.AncestryChanged:Connect(function(_, instance)
						if instance == nil or not instance:IsDescendantOf(workspace) then
							folder:SetAttribute("ExpectedDescendants", nil)
							descendantRemovingConnection:Disconnect()
							ancestryChangedConnection:Disconnect()
						end
					end)
					task.delay(15, function()
						pcall(function()
							descendantRemovingConnection:Disconnect()
						end)
						pcall(function()
							ancestryChangedConnection:Disconnect()
						end)
					end)
				end
			end
		end

		local HttpService = game:GetService("HttpService")
		local GUID = HttpService:GenerateGUID(false)

		if folder:IsA("BasePart") and folder.Parent == workspace._WorldOrigin then
			folder.Parent = workspace._WorldOrigin.PersistentParts
		end

		local objectValue = Instance.new("ObjectValue")
		objectValue:SetAttribute("Destroyed", false)
		objectValue.Name = GUID
		objectValue.Value = folder
		objectValue.Parent = ReplicatedStorage.StreamedQueue

		if folder:IsA("Model") and folder.ModelStreamingMode == Enum.ModelStreamingMode.Default then
			folder.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
		end

		local destroyingConnection = folder.Destroying:Once(function()
			objectValue:SetAttribute("Destroyed", true)
			task.delay(10, function()
				folder:Destroy()
			end)
			v[folder][2] = os.clock() + 10
			v[folder][3] = nil
		end)
		v[folder] = { objectValue, os.clock() + 15, destroyingConnection }
		local v7 = v[folder][1]
		assert(typeof(v7) == "Instance")
		return {
			v7.Name,
			1,
			"__StreamedObject",
			false,
			folder
		}
	end
end

return function(value, flag: boolean?, _, _)
	if not v2 then
		return value
	end

	if isServer then
		if typeof(value) == "table" then
			local v6 = {}
			local recurse

			recurse = function(items)
				local result = v6[items] or {}

				for k, item in pairs(items) do
					if typeof(item) == "Instance" then
						result[k] = EncodeObj2(item)
					elseif typeof(item) == "table" then
						if v6[item] then
							result[k] = v6[item]
						else
							v6[item] = {}
							result[k] = recurse(item)
						end
					else
						result[k] = item
					end
				end

				return result
			end

			return (recurse(value))
		elseif typeof(value) == "Instance" then
			return EncodeObj2(value)
		else
			return value
		end
	else
		if typeof(value) ~= "table" then
			return value
		end

		if value[3] == "__StreamedObject" then
			return DecodeObj(value, flag)
		end

		local count = 0
		local count2 = 0
		local thread = coroutine.running()
		local recurse

		recurse = function(items)
			for k, item in pairs(items) do
				if typeof(item) ~= "table" then
					continue
				end

				if item[3] == "__StreamedObject" then
					count += 1
					math.random(1, 1000000)
					local v6 = item
					local v7 = k
					task.spawn(function()
						assert(typeof(v6) == "table")
						items[v7] = DecodeObj(v6, flag)
						count2 += 1
						coroutine.resume(thread)
					end)
				else
					recurse(item)
				end
			end
		end

		recurse(value)

		if count == count2 then
			return value
		end

		repeat
			coroutine.yield()
		until count == count2

		return value
	end
end
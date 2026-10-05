local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Tags = {}
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = require3(ReplicatedStorage2.Packages.Trove)

function Tags.Add(_, instance, tag: string)
	CollectionService:AddTag(instance, tag)
end

function Tags:Has(instance, tag: string)
	return CollectionService:HasTag(instance, tag)
end

function Tags:GetTags(p)
	return CollectionService:GetTags(p)
end

function Tags:GetTagged(tag: string)
	return CollectionService:GetTagged(tag)
end

function Tags.Remove(_, instance, tag: string)
	CollectionService:RemoveTag(instance, tag)
end

function Tags:GetInstanceAddedSignal(p: string)
	return CollectionService:GetInstanceAddedSignal(p)
end

function Tags:GetInstanceRemovedSignal(p: string)
	return CollectionService:GetInstanceRemovedSignal(p)
end

function Tags.FindFirstTagged(_, folder, p: string, flag: boolean?)
	for _, v2 in pairs(flag and folder:GetDescendants() or folder:GetChildren()) do
		if Tags:Has(v2, p) then
			return v2
		end
	end
end

function Tags.GetAllTagged(_, folder, p: string, flag: boolean?)
	local result = {}

	for _, v2 in pairs(flag and folder:GetDescendants() or folder:GetChildren()) do
		if Tags:Has(v2, p) then
			table.insert(result, v2)
		end
	end

	return result
end

function Tags:WaitForTagged(tag: string, callback)
	assert(typeof(tag) == "string", "Tag must be a string")
	local tagged = Tags:GetTagged(tag)

	for _, v2 in pairs(tagged) do
		if not callback or callback(v2) then
			return v2
		end
	end

	local instanceAddedSignal = Tags:GetInstanceAddedSignal(tag)
	local v2

	repeat
		v2 = instanceAddedSignal:Wait()
	until not callback or callback(v2)

	return v2
end

function Tags.AsyncWaitForTagged(_, p: string, callback, callback2)
	task.spawn(function()
		callback2((Tags:WaitForTagged(p, callback)))
	end)
end

function Tags:WaitForTaggedDescendant(tag: string, instance)
	assert(typeof(tag) == "string", "Tag must be a string")
	local tagged = Tags:GetTagged(tag)

	for _, descendant in pairs(tagged) do
		if not instance or instance:IsAncestorOf(descendant) then
			return descendant
		end
	end

	local instanceAddedSignal = Tags:GetInstanceAddedSignal(tag)
	local v2

	repeat
		v2 = instanceAddedSignal:Wait()
	until not instance or instance:IsAncestorOf(v2)

	return v2
end

function Tags:AsyncWaitForTaggedDescendant(p: string, p2, callback)
	task.spawn(function()
		callback((Tags:WaitForTaggedDescendant(p, p2)))
	end)
end

function Tags.WaitForTaggedGUI(_, value: string)
	assert(typeof(value) == "string", "Tag must be a string")
	assert(RunService:IsClient(), "Must be run on the client")
	return Tags:WaitForTaggedDescendant(value, Players.LocalPlayer)
end

function Tags.AsyncWaitForTaggedGUI(_, value: string, callback)
	assert(typeof(value) == "string", "Tag must be a string")
	assert(RunService:IsClient(), "Must be run on the client")
	Tags:AsyncWaitForTaggedDescendant(value, Players.LocalPlayer, callback)
end

function Tags:Bind(tag: string, object2, p: string?, p2: string?)
	local connection = nil
	local connection2

	if p then
		connection2 = object2:Connect(p, (CollectionService:GetInstanceAddedSignal(tag)))

		for _, v2 in pairs(self:GetTagged(tag)) do
			local v3 = v2
			task.spawn(function()
				object2[p](object2, v3)
			end)
		end
	end

	if p2 then
		connection = object2:Connect(p2, (CollectionService:GetInstanceRemovedSignal(tag)))
	end

	return connection2, connection
end

function Tags:Connect(tag: string, callback, callback2)
	local connection = CollectionService:GetInstanceAddedSignal(tag):Connect(callback)
	local connection2 = nil

	for _, v2 in self:GetTagged(tag) do
		task.spawn(callback, v2)
	end

	if callback2 then
		connection2 = CollectionService:GetInstanceRemovedSignal(tag):Connect(callback2)
	end

	return connection, connection2
end

local class = {}
class.__index = class

function class:Destroy()
	getmetatable(self).Trove:Destroy()
end

function Tags.NewArrayOfTagged(tag: string, callback)
	local clone = table.clone(class)
	clone.Trove = v.new()
	local v2 = {}

	for _, v3 in pairs(CollectionService:GetTagged(tag)) do
		if not callback or callback(v3) then
			table.insert(v2, v3)
		end
	end

	clone.Trove:Connect(CollectionService:GetInstanceAddedSignal(tag), function(p)
		if callback and not callback(p) then
			return
		end

		table.insert(v2, p)
	end)
	clone.Trove:Connect(CollectionService:GetInstanceRemovedSignal(tag), function(p)
		local index = table.find(v2, p)

		if index then
			table.remove(v2, index)
		end
	end)
	return (setmetatable(v2, clone))
end

function Tags.NewDictOfTagged(tag: string, callback)
	local clone = table.clone(class)
	clone.Trove = v.new()
	local object = setmetatable({}, clone)

	for _, v2 in pairs(CollectionService:GetTagged(tag)) do
		if not callback or callback(v2) then
			object[v2] = true
		end
	end

	clone.Trove:Connect(CollectionService:GetInstanceAddedSignal(tag), function(p)
		if callback and not callback(p) then
			return
		end

		object[p] = true
	end)
	clone.Trove:Connect(CollectionService:GetInstanceRemovedSignal(tag), function(p)
		object[p] = nil
	end)
	return object
end

function Tags.ForEach(_, tag: string, callback, callback2)
	local v2 = v.new()

	if callback then
		for _, v3 in CollectionService:GetTagged(tag) do
			task.spawn(callback, v3)
		end

		v2:Connect(CollectionService:GetInstanceAddedSignal(tag), callback)
	end

	if callback2 then
		v2:Connect(CollectionService:GetInstanceRemovedSignal(tag), callback2)
	end

	return v2
end

function Tags.ForTagged(_, tag: string, callback)
	for _, v2 in pairs(CollectionService:GetTagged(tag)) do
		task.spawn(callback, v2)
	end
end

return Tags
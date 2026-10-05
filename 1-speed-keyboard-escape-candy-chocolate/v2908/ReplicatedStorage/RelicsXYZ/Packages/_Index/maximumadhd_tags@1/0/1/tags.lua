local Tags = {}
local parent = script.Parent
local CollectionService = game:GetService("CollectionService")
local Trove = require(parent.Trove)
require(parent.Signal)
local RunContext = require(parent.RunContext)
local v = Trove.new()

if RunContext.IsEdit then
	local v2 = shared[script]

	if v2 then
		v2:Clean()
	end

	shared[script] = v
end

function Tags:GetTagged()
	return CollectionService:GetTagged(self)
end

function Tags.GetInstanceAddedSignal(p: string)
	return CollectionService:GetInstanceAddedSignal(p)
end

function Tags.GetInstanceRemovedSignal(p: string)
	return CollectionService:GetInstanceRemovedSignal(p)
end

function Tags.FindFirstTagged(tag: string)
	local tagged = CollectionService:GetTagged(tag)

	if #tagged > 0 then
		return tagged[1]
	end

	return nil
end

function Tags.Bind(tag: string, callback, callback2)
	local extended = v:Extend()

	if callback2 then
		extended:Connect(Tags.GetInstanceRemovedSignal(tag), callback2)
	end

	if callback then
		extended:Connect(Tags.GetInstanceAddedSignal(tag), callback)

		for _, v2 in CollectionService:GetTagged(tag) do
			task.spawn(callback, v2)
		end
	end

	return extended
end

function Tags.BindWithMaid(p: string, callback, callback2)
	local v2 = {}
	return (Tags.Bind(p, function(p2)
		local maid = Trove.new()
		v2[p2] = maid
		maid:Add(function()
			if callback2 then
				callback2(p2)
			end
		end)
		callback(p2, maid)
	end, function(p2)
		local v3 = v2[p2]

		if v3 then
			v3:Destroy()
			v2[p2] = nil
		end
	end))
end

return Tags
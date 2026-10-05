local RunService = game:GetService("RunService")
local isStudio = RunService:IsStudio()
local Maid = require(game.ReplicatedStorage.Util.Maid)

function WaitForChild(instance, ...)
	local v = { ... }
	local maid = Maid.new()
	local v2 = v[1]
	local thread = coroutine.running()
	local child = instance:FindFirstChild(v2)

	if not child then
		maid:GiveTask(instance.ChildAdded:Connect(function(child2)
			if child2.Name == v2 then
				coroutine.resume(thread, child2)
			end
		end))
		maid:GiveTask(instance.AncestryChanged:Connect(function(_, parent)
			if not parent then
				coroutine.resume(thread, false)
			end
		end))

		if isStudio then
			local v3 = false
			maid:GiveTask(function()
				v3 = true
			end)
			task.delay(5, function() end)
		end

		child = coroutine.yield()
	end

	maid:DoCleaning()

	if not child then
		return
	end

	if #v == 1 then
		return child
	end

	table.remove(v, 1)
	return WaitForChild(child, unpack(v))
end

return WaitForChild
local InstanceLoadingUtil = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Promise"))

function InstanceLoadingUtil.waitForDescendantsToLoad(instance, p: number)
	local lastTime = tick()
	local descendantAddedConnection = instance.DescendantAdded:Connect(function()
		lastTime = tick()
	end)
	return Promise.new(function(callback)
		while tick() - lastTime < p do
			task.wait()
		end

		descendantAddedConnection:Disconnect()
		callback()
	end)
end

function InstanceLoadingUtil.writeDescendantTotal(folder, p, flag: boolean?)
	local v = 0

	for _, descendant in pairs(folder:GetDescendants()) do
		if not p or p.Function(descendant) then
			v += 1
		end
	end

	folder:SetAttribute("_InstanceUtilTotalDescendants_" .. (not p and "" or p.Id or ""), v)

	if not flag then
		return
	end

	local descendantAddedConnection = folder.DescendantAdded:Connect(function(descendant)
		if not p or p.Function(descendant) then
			v += 1
			folder:SetAttribute("_InstanceUtilTotalDescendants_" .. (p and p.Id or ""), v)
		end
	end)
	local descendantRemovingConnection = folder.DescendantRemoving:Connect(function(descendant)
		if not p or p.Function(descendant) then
			v -= 1
			folder:SetAttribute("_InstanceUtilTotalDescendants_" .. (p and p.Id or ""), v)
		end
	end)
	return function()
		descendantAddedConnection:Disconnect()
		descendantRemovingConnection:Disconnect()
	end
end

function InstanceLoadingUtil.readDescendantTotal(instance, value: string?)
	local attribute = instance:GetAttribute("_InstanceUtilTotalDescendants_" .. (value or ""))

	if attribute then
		return attribute
	end

	error("InstanceLoadingUtil.readDescendantTotal: No total descendants attribute found. Did you forget to call InstanceLoadingUtil.writeDescendantTotal?")
end

function InstanceLoadingUtil.waitForDescendantTotalToMatch(folder, p, duration: number?)
	return Promise.new(function(callback)
		while true do
			local count = 0

			for _, descendant in pairs(folder:GetDescendants()) do
				if not p or p.Function(descendant) then
					count += 1
				end
			end

			if count == InstanceLoadingUtil.readDescendantTotal(folder, p and p.Id) then
				callback()
				break
			else
				task.wait(duration)
			end
		end
	end)
end

return InstanceLoadingUtil
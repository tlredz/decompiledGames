local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local class = {}
class.__index = class

function class.new()
	return (setmetatable({
		_Tasks = {}
	}, class))
end

function class:GiveTask(p2)
	table.insert(self._Tasks, p2)
end

function class:LinkToInstance(player)
	if player:IsA("Player") then
		self:GiveTask(Players.PlayerRemoving:Connect(function(player2)
			if player2 == player then
				self:DoCleaning()
			end
		end))
		return
	end

	player:AddTag("MaidLinkToInstance")
	self:GiveTask(CollectionService:GetInstanceRemovedSignal("MaidLinkToInstance"):Connect(function(p)
		if p == player then
			self:DoCleaning()
		end
	end))
	self:GiveTask(player.Destroying:Connect(function()
		self:DoCleaning()
		player:RemoveTag("MaidLinkToInstance")
	end))
end

function class:DoCleaning()
	local _Tasks = self._Tasks
	self._Tasks = {}

	for _, _Task in next, _Tasks, nil do
		local typeName = typeof(_Task)
		local v = typeName == "table"

		if typeName == "RBXScriptConnection" or v and _Task.Disconnect then
			_Task:Disconnect()
		elseif typeName == "thread" then
			xpcall(task.cancel, function(p2)
				local v2 = debug.info(4, "n")
				warn(debug.traceback((`Maid could not cancel thread for "{v2 or "Unknown Function"}": {p2}`)))
			end, _Task)
		elseif typeName == "Instance" or v and _Task.Destroy then
			_Task:Destroy()
		else
			_Task()
		end
	end

	table.clear(_Tasks)
end

class.Disconnect = class.DoCleaning
class.Destroy = class.DoCleaning
return table.freeze(class)
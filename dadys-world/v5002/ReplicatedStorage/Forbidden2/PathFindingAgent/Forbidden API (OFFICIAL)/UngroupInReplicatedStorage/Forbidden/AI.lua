require(script.Types)
local MessageQueue = require(script.MessageQueue)
local PathfindingProcessor = require(script.PathfindingProcessor)
local ConfigHandler = require(script.ConfigHandler)
local antilag = script.antilag
local AI = {}

function AI.SmartPathfind(p, p2, flag: boolean?, value)
	local v = flag or false
	PathfindingProcessor.InitializeStateMachine(p)
	local v2 = MessageQueue.SendStartMessage(p, p2, v, value or "DefaultStart")

	if v and v2 then
		v2.Event:Wait()
	end
end

function AI.Stop(p, flag: boolean?, value)
	local v = flag or false
	local v2 = MessageQueue.SendStopMessage(p, v, value or "DefaultStop")

	if v and v2 then
		v2.Event:Wait()
	end
end

function AI.GetConfig(p)
	return ConfigHandler.GetConfig(p)
end

function AI.InsertAntiLag(parent, flag: boolean?, flag2: boolean?)
	if parent == nil then
		error("NPC is nil! Cannot insert the anti-lag script.")
	end

	if parent:FindFirstChildOfClass("Humanoid") == nil and not flag2 then
		error("Cannot find the humanoid in this NPC. Cannot insert the anti-lag script.")
	end

	if not flag then
		local clone = antilag:Clone()
		clone.Parent = parent
		antilag.Enabled = true
	end

	if flag then
		local clone_2 = antilag:Clone()
		clone_2.Parent = parent
		antilag.Enabled = true
	end
end

return AI
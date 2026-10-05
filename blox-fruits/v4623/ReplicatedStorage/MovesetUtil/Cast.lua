local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Cast = {
	isLocalClient = function()
		return RunService:IsClient()
	end,
	isAlive = function(instance, ancestor)
		if instance then
			return (instance:IsDescendantOf(ancestor))
		end

		return ancestor.Parent ~= nil
	end
}

function Cast.isActive(p, flag: boolean?)
	if flag then
		return false
	end

	return Cast.isAlive(p.tool, p.character)
end

function Cast.isHeld(data, flag: boolean?)
	if flag then
		return false
	end

	local tool = data.tool

	if tool then
		return tool:IsDescendantOf(data.character)
	end

	return data.holdingInstance.Value
end

function Cast.isCastActive(p)
	local tool = p.tool

	if tool then
		return tool:IsDescendantOf(workspace)
	end

	return p.character:IsDescendantOf(workspace)
end

function Cast.toolOwner(p)
	if not p then
		return nil
	end

	local parent = p.Parent

	if not parent then
		return nil
	end

	if parent:IsA("Model") then
		return Players:GetPlayerFromCharacter(parent)
	end

	local parent2 = parent.Parent

	if parent2 and parent2:IsA("Player") then
		return parent2
	end

	return nil
end

function Cast.waitForRelease(p)
	if p.holdingInstance.Value then
		p.holdingInstance.Changed:Wait()
	end
end

function Cast.waitStep()
	if RunService:IsClient() then
		RunService.RenderStepped:Wait()
	else
		RunService.Heartbeat:Wait()
	end
end

function Cast.destroyBodyMover(instance)
	if instance then
		pcall(function()
			instance:Destroy()
		end)
	end
end

return Cast
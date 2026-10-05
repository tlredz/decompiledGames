local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local v = nil
local v2 = false

local function getIsolator()
	if v ~= nil or v2 then
		return v
	end

	local success, result = pcall(function()
		if RunService:IsServer() then
			return require(ServerScriptService:WaitForChild("Game"):WaitForChild("ServerLoader"):WaitForChild("ServiceIsolator"))
		end

		local playerScripts = Players.LocalPlayer:WaitForChild("PlayerScripts")
		return require(playerScripts:WaitForChild("ClientLoader"):WaitForChild("ControllerIsolator"))
	end)

	if success then
		v = result
	else
		v2 = true
		task.spawn(error, (`RequireProxy isolator failed to load, using the plain require: {result}`))
	end

	return v
end

return {
	CreateRequire = function(instance, callback)
		if not RunService:IsRunning() or RunService:IsServer() and not instance:IsDescendantOf(ServerScriptService) then
			return callback
		end

		local isolator = getIsolator()

		if isolator then
			return (isolator.CreateRequire(instance, callback))
		end

		return callback
	end
}
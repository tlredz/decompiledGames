local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)
local scopePool = require(parent.Memory.scopePool)
local poisonScope = require(parent.Memory.poisonScope)
local v = {}
local doCleanup

doCleanup = function(connection)
	if v[connection] then
		return External.logError("destroyedTwice")
	end

	v[connection] = true

	if typeof(connection) == "Instance" then
		connection:Destroy()
	elseif typeof(connection) == "RBXScriptConnection" then
		connection:Disconnect()
	elseif typeof(connection) == "function" then
		connection()
	elseif typeof(connection) == "table" then
		if typeof(connection.destroy) == "function" then
			connection:destroy()
		elseif typeof(connection.Destroy) == "function" then
			connection:Destroy()
		elseif connection[1] ~= nil then
			for i = #connection, 1, -1 do
				doCleanup(connection[i])
				connection[i] = nil
			end

			if External.isTimeCritical() then
				scopePool.giveIfEmpty(connection)
			else
				poisonScope(
					connection,
					"`doCleanup()` was previously called on this scope. Ensure you are not reusing scopes after cleanup."
				)
			end
		end
	end

	v[connection] = nil
end

return doCleanup
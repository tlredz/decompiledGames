game:GetService("RunService")
local Logger = {}
Logger._infoLogEnabled = false
Logger._infoLogAdvancedEnabled = false
Logger._debugEnabled = false

function Logger.setDebugLog(p, debugEnabled)
	p._debugEnabled = debugEnabled
end

function Logger.setInfoLog(p, infoLogEnabled)
	p._infoLogEnabled = infoLogEnabled
end

function Logger.setVerboseLog(p, infoLogAdvancedEnabled)
	p._infoLogAdvancedEnabled = infoLogAdvancedEnabled
end

function Logger.i(p, p2)
	if not p._infoLogEnabled then
		return
	end

	local v = "Info/GameAnalytics: " .. p2
	print(v)
end

function Logger.w(_, p)
	local v = "Warning/GameAnalytics: " .. p
	warn(v)
end

function Logger.e(_, p)
	task.spawn(function()
		local v = "Error/GameAnalytics: " .. p
		error(v, 0)
	end)
end

function Logger.d(p, p2)
	if not p._debugEnabled then
		return
	end

	local v = "Debug/GameAnalytics: " .. p2
	print(v)
end

function Logger.ii(p, p2)
	if not p._infoLogAdvancedEnabled then
		return
	end

	local v = "Verbose/GameAnalytics: " .. p2
	print(v)
end

return Logger
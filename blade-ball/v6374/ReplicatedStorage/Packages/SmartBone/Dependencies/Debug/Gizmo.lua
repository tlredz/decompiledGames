local parent = script.Parent.Parent
local Config = require(parent:WaitForChild("Config"))
local Gizmo = require(script:WaitForChild("Gizmo"))
local RunService = game:GetService("RunService")
local v = RunService:IsStudio() or Config.ALLOW_LIVE_GAME_DEBUG

if v then
	Gizmo.Init()
end

local object = setmetatable({}, {
	__index = function(_, p)
		if v then
			return Gizmo[p]
		end

		if ({
			SetStyle = true,
			AddDebrisInSeconds = true,
			PushProperty = true,
			PopProperty = true,
			AddDebrisInFrames = true,
			SetEnabled = true,
			DoCleaning = true,
			ScheduleCleaning = true,
			TweenProperties = true
		})[p] then
			return function() end
		end

		return {
			Draw = function() end,
			Create = function() end
		}
	end
})
return table.freeze(object)
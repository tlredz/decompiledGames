game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local gameComponents = Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("GameComponents")
local v = {
	"FlickeringLights",
	"SmokeClouds",
	"FireHitboxes",
	"CustomKnockbackParts",
	"UISparkleEffects",
	"UILoadingDots",
	"UIBackgrounds",
	"UIInputFrames",
	"UIKeybinds",
	"OpenPagePrompts",
	"SnowballPrompts",
	"OutOfBoundsParts",
	"UserIDsFilter",
	"JumpPads",
	"SubspaceTripmines",
	"UIShinyTexts",
	"UIGlitchEffects",
	"PortalModels",
	"Vortexes",
	"OneWayFloors",
	"SoundTriggers"
}
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.Components = {}
	self:_Init()
	return self
end

function class:_Setup()
	for _, v2 in pairs(v) do
		local v3 = v2
		task.spawn(function()
			local components = self.Components
			local module = require(gameComponents:WaitForChild(v3))
			components[v3] = module
		end)
	end
end

function class:_Init()
	RunService.Heartbeat:Connect(function(dt)
		for _, component in pairs(self.Components) do
			if component.Update then
				component:Update(dt)
			end
		end
	end)
	self:_Setup()
end

return class._new()
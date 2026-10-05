local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
require(ReplicatedStorage.Modules.Spring)
local Throwable = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Throwable)
local object = setmetatable({}, Throwable)
object.__index = object

function object.new(...)
	local self = setmetatable(Throwable.new(...), object)
	self:_Init()
	return self
end

function object:_Init()
	self.ProjectileThrown:Connect(function(instance, instance2)
		local highlight = Instance.new("Highlight")
		highlight.FillColor = Color3.fromRGB(255, 0, 0)
		highlight.OutlineTransparency = 1
		highlight.FillTransparency = 0
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.Adornee = instance2
		highlight.Parent = instance2
		BetterDebris:AddItem(highlight, 10)
		local random = Random.new()
		local lastTime = tick()

		while instance:IsDescendantOf(workspace) do
			local v = math.min(1, (tick() - lastTime) / self.Info.DetonateDelay)
			local v2 = random:NextUnitVector() * 0.25 * v ^ 4
			instance2.WorldPivot = instance2:GetPivot() + v2
			highlight.FillTransparency = 1 - v ^ 4 / 2
			RunService.RenderStepped:Wait()
		end

		highlight:Destroy()
	end)
end

return object
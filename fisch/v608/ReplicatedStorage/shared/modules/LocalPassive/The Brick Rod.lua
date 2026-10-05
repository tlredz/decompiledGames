local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("Players")
local _ = ReplicatedStorage.resources.replicated.fishing.customreels.thebrickrod
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
local module = require("./PassiveHandler")

local function Explode(p)
	script.SpinSpeed.Value = 1.1
	TweenService:Create(script.SpinSpeed, tweenInfo, {
		Value = 1
	}):Play()
	p.Rotation = Random.new():NextNumber(58, 66)
	TweenService:Create(p, tweenInfo2, {
		Rotation = 0
	}):Play()
end

local TheBrickRod = {
	Morph = function(p, p2)
		p.reelTrove:Add(RunService.Heartbeat:Connect(function()
			local v = workspace:GetServerTimeNow() * 360
			p2.SpawnLocation.Rotation = -v / 2 * script.SpinSpeed.Value % 360
			p2.Sigil.Rotation = v / 5 * script.SpinSpeed.Value % 360
		end))
		p.reelTrove:Add(ReplicatedStorage.events.debug_hammerhit.OnClientEvent:Once(function()
			Explode(p2)
		end))
	end
}
setmetatable(TheBrickRod, module)
return TheBrickRod
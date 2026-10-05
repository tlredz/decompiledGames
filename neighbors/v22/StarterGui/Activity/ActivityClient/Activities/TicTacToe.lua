local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Network = require(ReplicatedStorage.Modules.Network)
Network:listen("TicTacToeHighlight", function(instance, p)
	if instance:FindFirstChildOfClass("Highlight") then
		instance:FindFirstChildOfClass("Highlight"):Destroy()
	end

	local highlight = Instance.new("Highlight", instance)
	highlight.FillTransparency = 1
	highlight.OutlineColor = p == "O" and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 0, 255)
	TweenService:Create(highlight, TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		OutlineTransparency = 1
	}):Play()
	Debris:AddItem(highlight, 5)
end)
return {}
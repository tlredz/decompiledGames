local TweenService = game:GetService("TweenService")
local gameSettings = require(game.ReplicatedStorage.CAM.Global.gameSettings)
local StyleShared = {}

function StyleShared.replaySpawn(p)
	if p == nil then
		return
	end

	p.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(p, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
		Size = UDim2.new(0, gameSettings.MarkerSize, 0, gameSettings.MarkerSize)
	}):Play()
end

function StyleShared.applyOpacity(p, groupTransparency)
	if p == nil or groupTransparency == nil then
		return
	end

	p.GroupTransparency = groupTransparency
end

return StyleShared
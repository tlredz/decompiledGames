local TweenService = game:GetService("TweenService")
local v = {}

local function CreateTweenFromTable(p, p2, data)
	v[p] = v[p] or {}
	v[p][p2] = TweenService:Create(
		p,
		TweenInfo.new(
			data.Time,
			Enum.EasingStyle[data.EasingStyle],
			Enum.EasingDirection[data.EasingDirection],
			0,
			false,
			data.DelayTime
		),
		data.Properties
	)
end

game.ReplicatedStorage.ClientTweenEvents.CreateClientTween.OnClientEvent:Connect(function(p, p2, p3)
	CreateTweenFromTable(p, p2, p3)
end)
game.ReplicatedStorage.ClientTweenEvents.PlayClientTween.OnClientEvent:Connect(function(p, p2)
	if v[p] == nil then
		CreateTweenFromTable(p, p2, game.ReplicatedStorage.ClientTweenEvents.GetClientTween:InvokeServer(p, p2))
	elseif v[p][p2] == nil then
		CreateTweenFromTable(p, p2, game.ReplicatedStorage.ClientTweenEvents.GetClientTween:InvokeServer(p, p2))
	end

	v[p][p2]:Play()
end)
game.ReplicatedStorage.ClientTweenEvents.StopClientTween.OnClientEvent:Connect(function(p, p2)
	if v[p] ~= nil and v[p][p2] ~= nil then
		v[p][p2]:Cancel()
	end
end)
game.ReplicatedStorage.ClientTweenEvents.ClearTweens.OnClientEvent:Connect(function()
	v = {}
end)
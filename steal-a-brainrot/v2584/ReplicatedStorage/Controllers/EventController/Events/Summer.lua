local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerData = require(ReplicatedStorage.Datas.ServerData)
require(ReplicatedStorage.Shared.EventTypes)
local Trove = require(ReplicatedStorage.Packages.Trove)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local name = script.Name
local maid = Trove.new()
local Summer = {}

function Summer.OnStart(_)
	ReplicatedStorage:SetAttribute("SummerEvent", true)
	EffectController:Activate("Blink")
	EffectController:Run(name, "GrassRecolor")
	EffectController:Run(name, "WallRecolor")
	EffectController:Run(name, "WallBottomRecolor")

	if not (ServerData.IsTsunamiServer() or ServerData.IsBiggerServer()) then
		local clone = maid:Clone(script.SummerMap)
		clone.Parent = workspace
	end

	maid:Add(function()
		ReplicatedStorage:SetAttribute("SummerEvent", nil)
		EffectController:Stop(name, "GrassRecolor")
		EffectController:Stop(name, "WallRecolor")
		EffectController:Stop(name, "WallBottomRecolor")
		EffectController:Activate("Blink")
	end)
end

function Summer.OnStop(_)
	maid:Clean()
end

return Summer
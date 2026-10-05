game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.packages.Net)
require(ReplicatedStorage.shared.modules.fishing.BiteTypes)
Net:RemoteFunction("FishingRod/Cast", -1)
local module = require("@self/FishingRodClient")
local FishingRodController = {}

function FishingRodController:Tick(p: number)
	if module.Active then
		module.Active:Tick(p)
	end
end

function FishingRodController.GetRod(_)
	return module.Active
end

function FishingRodController.LoadRod(_, p)
	return module.new(p)
end

function FishingRodController.UnloadRod(_)
	if module.Active then
		module.Active:Destroy()
		module.Active = nil
	end
end

function FishingRodController.CanChange(_, _)
	return not module.Active or module.Active:CanReset()
end

function FishingRodController.Start(_) end

return FishingRodController
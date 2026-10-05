local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parent = script.Parent

if not parent:IsA("Model") then
	return
end

local GameplayBalance = require(ReplicatedStorage.Shared.Flags.GameplayBalance)
local beeLauncher = GameplayBalance.BeeLauncher
local BeeEffectController = require(ReplicatedStorage.Controllers.Game.BeeEffectController)
BeeEffectController.Apply(parent, beeLauncher.EFFECT_DURATION_SECONDS)
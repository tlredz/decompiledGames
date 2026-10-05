local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BaseIndexController = require(ReplicatedStorage.Controllers.BaseIndexController)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Shared.EventTypes)
local maid = Trove.new()
local HoneyBeeBase = {}

function HoneyBeeBase.OnStart(_) end

function HoneyBeeBase.OnStop(_)
	maid:Clean()
end

function HoneyBeeBase.OnLoad(_)
	maid:Add(BaseIndexController:Register({
		Id = "Honey Bee",
		IndexName = "Honey Bee",
		SkinName = "Honey Bee",
		ScreenGuiName = "HoneyBeeBase",
		FramePath = "HoneyBeeBase",
		PromptTag = "HoneyBeeBasePrompt",
		MotorTag = "HoneyBeeBaseMotor"
	}))
end

return HoneyBeeBase
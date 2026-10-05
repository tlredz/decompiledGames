local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BaseIndexController = require(ReplicatedStorage.Controllers.BaseIndexController)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Shared.EventTypes)
local maid = Trove.new()
local TacoBase = {}

function TacoBase.OnStart(_) end

function TacoBase.OnStop(_)
	maid:Clean()
end

function TacoBase.OnLoad(_)
	maid:Add(BaseIndexController:Register({
		Id = "Taco",
		IndexName = "Taco",
		SkinName = "Taco",
		ScreenGuiName = "TacoBase",
		FramePath = "TacoBase",
		PromptTag = "TacoBasePrompt",
		MotorTag = "TacoBaseMotor"
	}))
end

return TacoBase
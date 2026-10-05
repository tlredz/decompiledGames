local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BaseIndexController = require(ReplicatedStorage.Controllers.BaseIndexController)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Shared.EventTypes)
local maid = Trove.new()
local LuckyBase = {}

function LuckyBase.OnStart(_) end

function LuckyBase.OnStop(_)
	maid:Clean()
end

function LuckyBase.OnLoad(_)
	maid:Add(BaseIndexController:Register({
		Id = "Lucky",
		IndexName = "Lucky",
		SkinName = "Lucky",
		ScreenGuiName = "LuckyBase",
		FramePath = "LuckyBase",
		PromptTag = "LuckyBasePrompt",
		MotorTag = "LuckyBaseMotor"
	}))
end

return LuckyBase
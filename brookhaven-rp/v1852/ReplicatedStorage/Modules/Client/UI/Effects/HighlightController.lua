local HighlightController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)
HighlightController.OnHighlightEnabled = Signal.new()

function HighlightController.FrameworkInit() end

function HighlightController.FrameworkStart() end

function HighlightController.EnableHighlight(p: string)
	HighlightController.OnHighlightEnabled:Fire(p)
end

return HighlightController
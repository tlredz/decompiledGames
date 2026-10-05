local ButtonFactory = require(script:WaitForChild("Factory"):WaitForChild("ButtonFactory"))
local TextButtonFactory = require(script:WaitForChild("Factory"):WaitForChild("TextButtonFactory"))
require(script:WaitForChild("Packages"):WaitForChild("NexusInstance"))
local Button = require(script:WaitForChild("Button"))
local ControllerIcon = require(script:WaitForChild("ControllerIcon"))
local ThemedFrame = require(script:WaitForChild("ThemedFrame"))
return (setmetatable({
	ButtonFactory = ButtonFactory,
	TextButtonFactory = TextButtonFactory,
	ControllerIcon = ControllerIcon,
	ThemedFrame = ThemedFrame
}, Button))
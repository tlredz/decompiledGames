local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = {
	ButtonDown = Signal.new(),
	ButtonUp = Signal.new()
}
return table.freeze(v)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Client = require(ReplicatedStorage.Shared.Modules.BatController.Client)
local Gears = require(ReplicatedStorage.Data.Gears)
local parent = script.Parent
local gearName = parent:GetAttribute("GearName")
assert(typeof(gearName) == "string", "Bat Tool requires a GearName attribute")
local v = assert(Gears.Directory[gearName].BatControllerData, (`{gearName} requires BatControllerData`))
Client.new(parent, v)
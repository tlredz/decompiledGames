local ReplicatedStorage = game:GetService("ReplicatedStorage")
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local met = require(script.met)
require(script.UiDraggerSettings)
return {
	new = function(UI, dragSettings, p3)
		local self = setmetatable({
			DragSettings = dragSettings,
			tt = 2,
			UI = UI,
			Changed = simplesignal.new(),
			Ended = simplesignal.new(),
			Started = simplesignal.new()
		}, met)
		self:Recalibrate()

		if p3 ~= nil then
			self:AddThread(p3)
		end

		return self
	end
}
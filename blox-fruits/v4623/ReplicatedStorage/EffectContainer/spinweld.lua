workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(data)
	local w = data.w
	local cf = data.cf
	local total = 0

	while true do
		RunService.RenderStepped:wait()

		if w.Parent == nil or not w.Parent:IsDescendantOf(workspace) then
			break
		end

		local _ = data.obj
		total += 0.25
		w.C0 *= cf
	end
end
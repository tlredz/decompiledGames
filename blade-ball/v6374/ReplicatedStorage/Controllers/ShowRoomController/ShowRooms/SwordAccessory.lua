local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local GamepadService = game:GetService("GamepadService")
game:GetService("TweenService")
game:GetService("RunService")
game:GetService("Players")
require3(ReplicatedStorage2.Packages.Trove)
local v2 = require3(script.Parent.Templates.ShowRoom3D)
require3(ReplicatedStorage2.Controllers.UI.LimitedSwordPacksController)
require3(ReplicatedStorage2.Controllers.ShowRoomController)
return {
	Template = ReplicatedStorage2.Misc.ShowRooms.SwordAccessory,
	BeforeShow = function(p)
		local showRoom = v2(p)

		if not showRoom then
			return
		end

		p.Trove:Add(task.defer(function()
			pcall(function()
				if v.GamepadEnabled then
					GamepadService:EnableGamepadCursor(nil)
				end
			end)
			p.Trove:Add(function()
				if v.GamepadEnabled then
					GamepadService:DisableGamepadCursor()
				end
			end)
		end))
		p.Info.ShowRoom = showRoom
		return showRoom
	end
}
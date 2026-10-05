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
local v3 = require3(ReplicatedStorage2.Controllers.UI.LimitedSwordPacksController)
require3(ReplicatedStorage2.Controllers.ShowRoomController)
return {
	Template = ReplicatedStorage2.Misc.ShowRooms.SwordPacks,
	BeforeShow = function(p)
		local showRoom2 = v2(p)

		if not showRoom2 then
			return
		end

		p.Trove:Add(task.defer(function()
			pcall(function()
				if v.GamepadEnabled then
					GamepadService:EnableGamepadCursor(nil)
				end
			end)
			local topRankedBundle = v3:GetTopRankedBundle()

			if topRankedBundle then
				showRoom2.moveToShowRoom(topRankedBundle.ShowRoom)
			end

			p.Trove:Add(v3.BundleChanged:Connect(function(data, p2)
				local showRoom = data.ShowRoom

				if data.Type == "SelectColors" then
					for _, reward in data.Rewards do
						if reward.Color == v3.CurrentlySelectedColor then
							showRoom = reward.ShowRoom or showRoom
						end
					end

					showRoom = v3.CurrentlyColorTypeForcedShowRoom or showRoom
				end

				showRoom2.moveToShowRoom(showRoom, p2)
			end))
			p.Trove:Add(function()
				if v.GamepadEnabled then
					GamepadService:DisableGamepadCursor()
				end
			end)
		end))
		p.Info.ShowRoom = showRoom2
		return showRoom2
	end
}
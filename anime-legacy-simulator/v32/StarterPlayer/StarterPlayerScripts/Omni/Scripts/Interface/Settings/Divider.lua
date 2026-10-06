local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local scroll = module.Interface:WaitForChild("Frames"):WaitForChild("Settings"):WaitForChild("SettingsList"):WaitForChild("Scroll")
local settings = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Settings")
return fusion.scoped(fusion, {
	Build = function(scope, duration: number)
		scope.Position = scope:Value(UDim2.fromScale(1.5, 0.5))
		scope.PositionSpring = scope:Spring(scope.Position, 10, 1)
		scope.Instance = settings.Divider:Clone()
		scope.Instance.Name = scope.Name
		scope.Instance.Main.Title.Text = scope.Name
		scope.Instance.Parent = scroll
		scope.Instance.Visible = true
		scope:Hydrate(scope.Instance.Main)({
			Position = scope.PositionSpring
		})

		if duration and duration > 0 then
			task.delay(duration, function()
				if not next(scope) then
					return
				end

				scope.Position:set(UDim2.fromScale(0.5, 0.5))
			end)
		else
			scope.Position:set(UDim2.fromScale(0.5, 0.5))
		end

		return true
	end
})
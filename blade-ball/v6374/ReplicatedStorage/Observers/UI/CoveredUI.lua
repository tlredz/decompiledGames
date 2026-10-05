local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local UIStateController = require(ReplicatedStorage.Controllers.UI.UIStateController)
local Observers = require(ReplicatedStorage.Packages.Observers)
return Observers.observeTagNoAncestry("UI_CoveredUI", function(instance)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		UIStateController.IsUICovered:SetTag(`UI_{instance.Name}`, instance.Enabled and true or nil)
	end

	local enabledChangedConnection = instance:GetPropertyChangedSignal("Enabled"):Connect(update)
	update() -- equivalent call inferred; original call site unknown
	return function()
		if enabledChangedConnection then
			enabledChangedConnection:Disconnect()
		end
	end
end)
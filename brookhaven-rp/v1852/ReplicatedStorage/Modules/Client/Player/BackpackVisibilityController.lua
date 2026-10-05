local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = {}
local v2 = true
local BackpackVisibilityController = {
	VisibilityChanged = Signal.new(),
	GetIsVisible = function()
		return v2
	end
}

function BackpackVisibilityController.SetVisibility(flag: boolean, p: string)
	v[p] = not flag or nil
	local v3 = next(v) == nil

	if v2 ~= v3 then
		v2 = v3
		pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, v3)
		end)
		BackpackVisibilityController.VisibilityChanged:Fire(v3)
	end
end

function BackpackVisibilityController.FrameworkInit() end

function BackpackVisibilityController.FrameworkStart()
	Remotes.connect("BackpackVisibility:SetVisibility", function(flag: boolean, p: string)
		BackpackVisibilityController.SetVisibility(flag, p)
	end)
end

return BackpackVisibilityController
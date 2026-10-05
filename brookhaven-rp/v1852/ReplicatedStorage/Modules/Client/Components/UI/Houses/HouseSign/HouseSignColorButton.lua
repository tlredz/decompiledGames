local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HouseSignColorButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance
	local color = instance:FindFirstChild("Color")
	local _1RPHous1eEven1tColo1r = ReplicatedStorage.RE:WaitForChild("1RPHous1eEven1tColo1r")

	if _1RPHous1eEven1tColo1r then
		self._Janitor:Add(instance.MouseButton1Click:Connect(function()
			_1RPHous1eEven1tColo1r:FireServer("PickingBusinessNameColor", color)
		end))
	else
		warn("RPHouseEventColor not found")
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v
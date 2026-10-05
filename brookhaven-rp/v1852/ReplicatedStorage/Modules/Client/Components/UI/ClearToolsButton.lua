local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "ClearToolsButton"
})
local _1Clea1rTool1s = nil

function v:Construct()
	self._Janitor = Janitor.new()
	_1Clea1rTool1s = ReplicatedStorage.RE:WaitForChild("1Clea1rTool1s")
end

function v:IsValidInstance(button)
	if button:IsA("ImageButton") or button:IsA("TextButton") then
		return true
	end

	return false
end

function v:Start()
	if self:IsValidInstance(self.Instance) then
		self._Janitor:Add(self.Instance.Activated:Connect(function()
			_1Clea1rTool1s:FireServer("ClearAllTools")
		end))
	else
		warn("ClearToolsButton is not a valid instance")
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v
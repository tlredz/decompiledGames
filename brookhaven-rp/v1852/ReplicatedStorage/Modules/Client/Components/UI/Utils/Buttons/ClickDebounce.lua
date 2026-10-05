local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "ClickDebounce"
})
local v2 = {}

function v:IsValidInstance(button)
	if button:IsA("ImageButton") or button:IsA("TextButton") then
		return true
	end

	return false
end

function v:Debounce()
	if v2[self.Instance] then
		return
	end

	self.Instance.Active = false
	local v3 = not self.Instance:GetAttribute("DebounceTime") and 0.5 or self.Instance:GetAttribute("DebounceTime")
	v2[self.Instance] = true
	task.delay(v3, function()
		self.Instance.Active = true
		v2[self.Instance] = nil
	end)
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	if self:IsValidInstance(self.Instance) then
		self._Janitor:Add(self.Instance.Activated:Connect(function()
			self:Debounce()
		end))
	else
		warn("Invalid instance type, expected ImageButton or TextButton, got " .. self.Instance.ClassName)
	end
end

function v:Stop()
	v2[self.Instance] = nil
	self._Janitor:Destroy()
end

return v
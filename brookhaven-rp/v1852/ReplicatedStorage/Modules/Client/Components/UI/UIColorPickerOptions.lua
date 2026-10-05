local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "UIColorPickerOptions"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function isOption(label)
	return label:IsA("TextLabel") and label.Name ~= "Template"
end

function v:SetSelectedOption(p2)
	for _, label in self.colorPickMode:GetChildren() do
		if not isOption(label) then
			continue
		end

		local checkmark = label:WaitForChild("Checkmark")
		checkmark.Visible = label == p2
	end
end

function v:WireOption(instance)
	if self.wiredOptions[instance] ~= nil then
		return
	end

	local button = instance:WaitForChild("Button")

	if not (self._Janitor ~= nil and self.wiredOptions[instance] == nil) then
		return
	end

	self.wiredOptions[instance] = true
	self._Janitor:Add(button.Activated:Connect(function()
		Remotes.fireServerComponent(self.Instance, "SetColorOption", instance.Name)
		self:SetSelectedOption(instance)
	end))
end

function v:Construct()
	self._Janitor = Janitor.new()
	self.wiredOptions = {}
end

function v:Start()
	self.colorPickMode = self.Instance:WaitForChild("ColorPicks"):WaitForChild("ColorPicksFrame"):WaitForChild("ColorPickMode")

	if self._Janitor == nil then
		return
	end

	self._Janitor:Add(self.colorPickMode.ChildAdded:Connect(function(label)
		if not isOption(label) then
			return
		end

		self:WireOption(label)
	end))

	for _, label in self.colorPickMode:GetChildren() do
		if isOption(label) then
			self:WireOption(label)
		end
	end
end

function v:Stop()
	local _Janitor = self._Janitor
	self._Janitor = nil
	_Janitor:Destroy()
end

return v
local TweenService = game:GetService("TweenService")
local NumberSpinner = {}
local class = {}
class.__index = class
TweenInfo.new(1)

function NumberSpinner.new(label, num, p, p2)
	local self = setmetatable({}, class)
	self.Label = label
	self.Num = num
	self.Value = p
	self.Tween = TweenService:Create(self.Value, p2, {
		Value = self.Num
	})
	self.Prefix = nil
	return self
end

function class:SetPrefix(prefix: string)
	self.Prefix = prefix
end

function class.Start(data)
	data.Tween:Play()

	if data.Label then
		local changedConnection = data.Value.Changed:Connect(function()
			local value = data.Value.Value

			if data.Prefix then
				data.Label.Text = string.format("%s %d", data.Prefix, value)
			else
				data.Label.Text = math.round(value)
			end
		end)
		local completedConnection = nil
		completedConnection = data.Tween.Completed:Connect(function()
			changedConnection:Disconnect()
			completedConnection:Disconnect()
		end)
	end
end

return NumberSpinner
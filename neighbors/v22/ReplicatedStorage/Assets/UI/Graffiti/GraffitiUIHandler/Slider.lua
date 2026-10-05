game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local Slider = {}
Slider.__index = Slider

function Map(p, p2, p3, p4, p5)
	return p4 + (p - p2) * (p5 - p4) / (p3 - p2)
end

function Slider.new(instance)
	local v = {
		ProgressBar = instance,
		Slider = instance.Slider,
		Horizontal = false,
		Value = 0,
		Min = 0,
		Max = 1,
		IsDragging = false
	}
	instance.MouseButton1Down:Connect(function()
		v.IsDragging = true
	end)
	instance.MouseButton1Up:Connect(function()
		v.IsDragging = false
	end)

	if instance.Slider:IsA("ImageButton") then
		instance.Slider.MouseButton1Down:Connect(function()
			v.IsDragging = true
		end)
		instance.Slider.MouseButton1Up:Connect(function()
			v.IsDragging = false
		end)
	end

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			v.IsDragging = false
		end
	end)
	UserInputService.TouchEnded:Connect(function(_)
		v.IsDragging = false
	end)

	if instance:FindFirstChildOfClass("TextBox") then
		local textBox = instance:FindFirstChildOfClass("TextBox")
		textBox.FocusLost:Connect(function()
			local value = v.Value
			local text = tonumber(textBox.Text) or value

			if text then
				v:SetValue(text)
				textBox.Text = v.Value
			end
		end)
	end

	setmetatable(v, Slider)
	return v
end

function Round(p: number, p2: number)
	return (tonumber((`%.{p2}f`):format(p)))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RoundNumber(p)
	return math.round(p * 10) / 10
end

function Slider:Update(p: number)
	if not (self.IsDragging or p) then
		return
	end

	local v = UserInputService:GetMouseLocation() - Vector2.new(0, 56)
	local absolutePosition = self.ProgressBar.AbsolutePosition
	local absoluteSize = self.ProgressBar.AbsoluteSize
	local textBox = self.ProgressBar:FindFirstChildOfClass("TextBox")
	local X

	if self.Horizontal then
		X = v.X
	else
		X = v.Y
	end

	local X2

	if self.Horizontal then
		X2 = absolutePosition.X
	else
		X2 = absolutePosition.Y
	end

	local v2

	if self.Horizontal then
		v2 = absoluteSize.X
	else
		v2 = absoluteSize.Y
	end

	local mapped = math.clamp((X - X2) / v2, 0, 1)
	local roundNumber = RoundNumber(math.clamp(
		p or not self.Horizontal and Map(mapped, 0, 1, self.Max, self.Min) or Map(mapped, 0, 1, self.Min, self.Max),
		self.Min,
		self.Max
	)) -- equivalent call inferred; original call site unknown

	if p then
		mapped = not self.Horizontal and Map(roundNumber, self.Max, self.Min, 0, 1) or Map(
			roundNumber,
			self.Min,
			self.Max,
			0,
			1
		)
	end

	self.Value = math.clamp(Round(roundNumber, 2), self.Min, self.Max)

	if textBox then
		textBox.Text = tostring(self.Value)
	end

	if self.Horizontal then
		self.Slider.Position = UDim2.fromScale(mapped, 0.5)
	else
		self.Slider.Position = UDim2.fromScale(0.5, mapped)
	end
end

function Slider:SetValue(p: number)
	self:Update(p)
end

return Slider
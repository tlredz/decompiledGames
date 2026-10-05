local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local spring = require3(ReplicatedStorage2.Common.Utils).Spring
local UiPresets = {}

function UiPresets.animateButtonHover(parent, value: number?, value2: number?)
	local scale = value or 1
	local scale2 = value2 or 1.075
	local _SCALE = parent:FindFirstChild("_SCALE") or Instance.new("UIScale")
	_SCALE.Name = "_SCALE"
	_SCALE.Scale = scale
	_SCALE.Parent = parent
	local mouseEnterConnection = parent.MouseEnter:Connect(function()
		spring.stop(_SCALE)
		spring.target(_SCALE, 0.85, 6, {
			Scale = scale2
		})
		_SCALE:SetAttribute("HOVER_SCALE", scale2)
	end)
	local mouseLeaveConnection = parent.MouseLeave:Connect(function()
		spring.stop(_SCALE)
		spring.target(_SCALE, 0.85, 6, {
			Scale = scale
		})
		_SCALE:SetAttribute("IS_HOVER", scale)
	end)
	local selectionChangedConnection = parent.SelectionChanged:Connect(function(p)
		spring.stop(_SCALE)
		spring.target(_SCALE, 0.85, 6, {
			Scale = p and scale2 or scale
		})
		_SCALE:SetAttribute("HOVER_SCALE", p and scale2 or scale)
	end)
	return function()
		mouseEnterConnection:Disconnect()
		mouseLeaveConnection:Disconnect()
		selectionChangedConnection:Disconnect()
		_SCALE:Destroy()
	end
end

function UiPresets.animateButtonClick(parent, value: number?)
	local scale = value or 0.9
	local _SCALE = parent:FindFirstChild("_SCALE") or Instance.new("UIScale")
	_SCALE.Name = "_SCALE"
	_SCALE.Parent = parent
	local inputBeganConnection = parent.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		spring.stop(_SCALE)
		_SCALE.Scale = scale
	end)
	local inputEndedConnection = parent.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		spring.stop(_SCALE)
		spring.target(_SCALE, 0.35, 6, {
			Scale = parent:GetAttribute("HOVER_SCALE") or 1
		})
	end)
	return function()
		inputBeganConnection:Disconnect()
		inputEndedConnection:Disconnect()
	end
end

return UiPresets
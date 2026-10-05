local TweenService = game:GetService("TweenService")
local parent = script.Parent
local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear)
local v = {}

for i = 1, 4 do
	if i == 1 then
		parent["Layer" .. 1].Visible = false
	else
		local tweenInfo2 = TweenInfo.new(i / 4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1)
		local scale = parent["Layer" .. i].Position.X.Scale
		v[i] = {
			Frame = parent["Layer" .. i],
			X = scale,
			Offset = (5 - i) / 4 * 0.4,
			Ti = tweenInfo2
		}
	end
end

local function update()
	if parent.Visible then
		for i = 2, 4 do
			local v2 = v[i]
			TweenService:Create(v2.Frame, v2.Ti, {
				Position = UDim2.fromScale(v2.X - v2.Offset, 0.5)
			}):Play()
		end
	else
		for i = 2, 4 do
			local v2 = v[i]
			TweenService:Create(v2.Frame, tweenInfo, {
				Position = UDim2.fromScale(v2.X, 0.5)
			}):Play()
		end
	end
end

parent:GetPropertyChangedSignal("Visible"):Connect(function()
	update()
end)
update()
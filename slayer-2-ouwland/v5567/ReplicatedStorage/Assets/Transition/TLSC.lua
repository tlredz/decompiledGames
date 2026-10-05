local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
script.Parent.Frame:ClearAllChildren()
local round = math.round
local v = math.round(script.Parent.Frame.AbsoluteSize.X / script.Parent.ex.AbsoluteSize.X)
local v2 = math.round(script.Parent.Frame.AbsoluteSize.Y / script.Parent.ex.AbsoluteSize.Y)
local clamp = math.clamp
local v3 = math.clamp(math.round(v / v2), 1, 999)
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(
	script:GetAttribute("Anim") or 0.25,
	Enum.EasingStyle.Circular,
	Enum.EasingDirection.Out,
	0,
	false,
	0
)
local tweenInfo2 = TweenInfo.new(
	script:GetAttribute("Anim") or 0.25,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.In,
	0,
	false,
	0
)
local new = UDim2.new
local insert = table.insert
local v4 = {}
local new2 = Vector2.new
local currentCamera = workspace.CurrentCamera
local v5 = currentCamera.ViewportSize.X / currentCamera.ViewportSize.Y
local v6 = currentCamera.ViewportSize.Y / currentCamera.ViewportSize.X

if v5 < v6 then
	v5 = v6
end

local step = script:GetAttribute("Step")

for i = 1, v2 + 1 do
	local v7 = i - 1
	local v8 = script.Parent.ex.AbsoluteSize.Y * v7
	local v9 = v7 * v3 * script.Parent.ex.AbsoluteSize.X
	local v10 = clamp(round(v9 / script.Parent.ex.AbsoluteSize.X), 0, 999)
	local v11 = clamp(round(v8 / script.Parent.ex.AbsoluteSize.Y), 1, 999)
	v4[i] = {}

	if v10 > 0 then
		for i2 = 1, v10 do
			local clone = script.Parent.ex:Clone()
			clone.Visible = true
			clone.Name = "x"
			clone.ImageLabel.Size = new(clone.ImageLabel.Size.X.Scale * v5, 0, clone.ImageLabel.Size.Y.Scale * v5, 0)
			clone.AnchorPoint = new2(0.5, 0.5)
			insert(v4[i], clone)
			clone.Size = new()
			TweenService:Create(clone, tweenInfo, {
				Size = new(script.Parent.ex.Size.X.Scale * 2, 0, script.Parent.ex.Size.Y.Scale * 2, 0)
			}):Play()
			clone.Position = new(
				0,
				(i2 - 1) * script.Parent.ex.AbsoluteSize.X + clone.AbsoluteSize.X / 2,
				0,
				v8 + clone.AbsoluteSize.Y / 2
			)
			clone.Parent = script.Parent.Frame
		end
	end

	if v11 > 0 then
		for i2 = 1, v11 + 1 do
			for i3 = 1, v3 do
				local clone = script.Parent.ex:Clone()
				clone.Visible = true
				clone.Name = "y"
				clone.ImageLabel.Size = new(
					clone.ImageLabel.Size.X.Scale * v5,
					0,
					clone.ImageLabel.Size.Y.Scale * v5,
					0
				)
				clone.AnchorPoint = new2(0.5, 0.5)
				insert(v4[i], clone)
				clone.Size = new()
				TweenService:Create(clone, tweenInfo, {
					Size = new(script.Parent.ex.Size.X.Scale * 2, 0, script.Parent.ex.Size.Y.Scale * 2, 0)
				}):Play()
				clone.Position = new(
					0,
					v9 + (i3 - 1) * script.Parent.ex.AbsoluteSize.X + clone.AbsoluteSize.X / 2,
					0,
					(i2 - 1) * script.Parent.ex.AbsoluteSize.Y + clone.AbsoluteSize.Y / 2
				)
				clone.Parent = script.Parent.Frame
			end
		end
	end

	task.wait(step or nil)
end

local delay = script:GetAttribute("Delay")

if delay ~= 0 then
	task.wait(delay or 1)
end

for _, list in ipairs(v4) do
	for _, v7 in ipairs(list) do
		TweenService:Create(v7, tweenInfo2, {
			Size = new(0, 0, 0, 0)
		}):Play()
	end

	task.wait(step or nil)
end

DebrisModule:AddItem(script.Parent, script:GetAttribute("Anim") or 0.25)
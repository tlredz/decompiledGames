local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local parent = script.Parent
local imageShower = parent:WaitForChild("ImageShower")
local image = imageShower.Image
local size = imageShower.Size
local uDim = UDim2.new(size.X.Scale * 1.3, size.X.Offset * 1.3, size.Y.Scale * 1.3, size.Y.Offset * 1.3)
local flag = false
local count = 0
local v = nil
local flag2 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function StartTilting()
	flag2 = true
	task.spawn(function()
		while flag2 do
			local tween = TweenService:Create(imageShower, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
				Rotation = 8
			})
			tween:Play()
			tween.Completed:Wait()

			if not flag2 then
				break
			end

			local tween2 = TweenService:Create(imageShower, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
				Rotation = -8
			})
			tween2:Play()
			tween2.Completed:Wait()

			if not flag2 then
				break
			end

			local tween3 = TweenService:Create(imageShower, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
				Rotation = 0
			})
			tween3:Play()
			tween3.Completed:Wait()
		end
	end)
end

local function StartHover()
	if flag then
		return
	end

	flag = true
	count += 1
	local v2 = count
	TweenService:Create(imageShower, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = uDim
	}):Play()
	StartTilting() -- equivalent call inferred; original call site unknown
	task.delay(1, function()
		local resultId = flag and count == v2 and parent:GetAttribute("ResultId")

		if resultId then
			imageShower.Image = resultId
		end
	end)
end

local function EndHover()
	if not flag then
		return
	end

	flag = false
	count += 1
	v = nil
	flag2 = false
	imageShower.Image = image
	TweenService:Create(imageShower, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = size
	}):Play()
	TweenService:Create(imageShower, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		Rotation = 0
	}):Play()
end

parent.MouseEnter:Connect(function()
	if not v then
		StartHover()
	end
end)
parent.MouseLeave:Connect(function()
	if not v then
		EndHover()
	end
end)
parent.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		v = input
		StartHover()
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input == v then
		EndHover()
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == v then
		local position = input.Position
		local absolutePosition = parent.AbsolutePosition
		local absoluteSize = parent.AbsoluteSize

		if position.X < absolutePosition.X or position.X > absolutePosition.X + absoluteSize.X or position.Y < absolutePosition.Y or position.Y > absolutePosition.Y + absoluteSize.Y then
			EndHover()
		end
	end
end)
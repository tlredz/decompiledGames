local GlobalUIAnimations = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local v = {}

function GlobalUIAnimations:AspectGridLayout()
	local scale = self.CellPadding.Y.Scale

	local function update()
		local v2 = self.AbsoluteCellSize.X * self:GetAttribute("ContentAspectRatio")
		local v3 = self.Parent.AbsoluteWindowSize.Y * scale
		self.CellSize = UDim2.new(self.CellSize.X.Scale, 0, 0, v2)
		self.CellPadding = UDim2.new(self.CellPadding.X.Scale, 0, 0, v3)
	end

	self:GetPropertyChangedSignal("AbsoluteCellSize"):Connect(update)
	update()
end

function GlobalUIAnimations:UIStroke()
	local widthScale = self:GetAttribute("WidthScale")

	if widthScale == nil then
		widthScale = self.Thickness / 1080
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		local v2 = math.round(self.Parent.AbsoluteSize.X * widthScale)
		self.Thickness = math.max(v2, 1)
	end

	self.Parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		wait()
		update() -- equivalent call inferred; original call site unknown
	end)
	self.Thickness = math.max(math.round(self.Parent.AbsoluteSize.X * widthScale), 1)
end

function GlobalUIAnimations.BounceOnOutline(instance, p)
	local v2 = nil
	local v3 = nil
	local position = instance.ButtonBackground.Position + UDim2.new(0, 0, 0.05, 0)
	local position2 = instance.ButtonOutline.Position + UDim2.new(0, 0, 0.05, 0)

	local function bounceAnim()
		local uIAnimationSpeed = instance:GetAttribute("UIAnimationSpeed") or 0.05

		if v2 then
			v2:Pause()
		end

		if v3 then
			v3:Pause()
		end

		local tweenInfo = TweenInfo.new(uIAnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true)
		local tween = TweenService:Create(instance.ButtonBackground, tweenInfo, {
			Position = position
		})
		v2 = tween
		tween:Play()
		local tween2 = TweenService:Create(instance.ButtonOutline, tweenInfo, {
			Position = position2
		})
		v3 = tween2
		tween2:Play()
	end

	if p then
		bounceAnim()
	else
		instance.MouseButton1Click:Connect(function()
			bounceAnim()
		end)
	end
end

function GlobalUIAnimations.BounceOnClick(instance, p)
	local v2 = nil
	local v3 = {
		Position = instance.Position,
		Size = instance.Size
	}
	v[instance] = v3
	local uDim = UDim2.new(instance.Size.X.Scale * 0.9, 0, instance.Size.Y.Scale * 0.9, 0)

	local function bounceAnim()
		local uIAnimationSpeed = instance:GetAttribute("UIAnimationSpeed") or 0.05

		if v2 then
			v2:Pause()
		end

		local tween = TweenService:Create(instance, TweenInfo.new(uIAnimationSpeed, Enum.EasingStyle.Quad), {
			Size = uDim
		})
		v2 = tween
		tween:Play()
		wait(uIAnimationSpeed)

		if v2 == tween then
			local tween2 = TweenService:Create(
				instance,
				TweenInfo.new(uIAnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					Size = v3.Size
				}
			)
			v2 = tween2
			tween2:Play()
		end
	end

	if p then
		bounceAnim()
	else
		instance.MouseButton1Click:Connect(function()
			bounceAnim()
		end)
	end
end

Client.Events.RunUIAnimation:Connect(function(instance)
	local uIAnimation = instance:GetAttribute("UIAnimation") or instance.ClassName
	local v2 = string.split(uIAnimation, ",")

	for _, v3 in pairs(v2) do
		if GlobalUIAnimations[v3] then
			GlobalUIAnimations[v3](instance, true)
		end
	end
end)
Client.Utility.ForAllTagged("UIAnimation", function(instance)
	local uIAnimation = instance:GetAttribute("UIAnimation") or instance.ClassName
	local v2 = string.split(uIAnimation, ",")

	for _, v3 in pairs(v2) do
		if GlobalUIAnimations[v3] then
			GlobalUIAnimations[v3](instance)
		end
	end
end)
return GlobalUIAnimations
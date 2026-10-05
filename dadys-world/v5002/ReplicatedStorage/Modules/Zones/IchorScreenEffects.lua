local IchorScreenEffects = {}
IchorScreenEffects.__index = IchorScreenEffects
local tweenHelpers = require(game.ReplicatedStorage.Modules.Utils.tweenHelpers)
local Players = game:GetService("Players")
local screenGui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

function IchorScreenEffects.new(instance)
	local object = setmetatable({}, IchorScreenEffects)
	local ichorScreen = screenGui:FindFirstChild("IchorScreen")

	if ichorScreen then
		ichorScreen:Destroy()
	end

	object.gui = instance:Clone()
	object.gui.Visible = true
	object.gui.Parent = screenGui
	object.splats = {}

	for _, image in pairs(object.gui:GetChildren()) do
		if not image:IsA("ImageLabel") then
			continue
		end

		image.ImageTransparency = 1
		tweenHelpers.saveInitials(image)
		table.insert(object.splats, image)
	end

	return object
end

function IchorScreenEffects.Enter(p)
	local random = Random.new(tick())

	for k, splat in pairs(p.splats) do
		if k == random:NextInteger(1, #p.splats) then
			continue
		end

		splat.Position = splat:GetAttribute("start_Position")
		splat.Size = splat:GetAttribute("start_Size")
		splat.UIScale.Scale = 0.5
		splat.Rotation = random:NextInteger(
			splat:GetAttribute("start_Rotation") - 30,
			splat:GetAttribute("start_Rotation") + 30
		)
		tweenHelpers.playTween(splat, TweenInfo.new(0.25), {
			ImageTransparency = 0
		})
		tweenHelpers.playTween(splat.UIScale, TweenInfo.new(0.25, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
			Scale = 1.5
		})
		tweenHelpers.playTween(splat, TweenInfo.new(3, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut, -1, true), {
			Size = splat:GetAttribute("start_Size") + UDim2.fromScale(0, 0.05)
		})
	end
end

function IchorScreenEffects.Exit(p, duration)
	local random = Random.new(tick())

	for _, splat in pairs(p.splats) do
		local v = splat
		task.spawn(function()
			tweenHelpers.playTween(v, TweenInfo.new(duration), {
				Position = v:GetAttribute("start_Position") + UDim2.fromScale(0, random:NextNumber(0.01, 0.1))
			})
			wait(0.4)

			if p.gui and p.gui.Parent then
				tweenHelpers.playTween(v.UIScale, TweenInfo.new(duration, Enum.EasingStyle.Cubic), {
					Scale = 1
				})
				tweenHelpers.playTween(v, TweenInfo.new(duration - 1), {
					ImageTransparency = 1
				})
			end
		end)
	end
end

function IchorScreenEffects:Destroy()
	self.gui:Destroy()
	table.clear(self)
end

return IchorScreenEffects
local TweenService = game:GetService("TweenService")
game:GetService("TeleportService")
local localPlayer = game.Players.LocalPlayer
local parent = script.Parent
local transition = parent.Transition
local frame = parent.Frame
local v = false
local thread = nil

local function makeTransitionVisible(flag: boolean)
	if flag then
		transition.Visible = true
		local tween = TweenService:Create(transition, TweenInfo.new(0.5), {
			BackgroundTransparency = 0
		})
		tween:Play()
		tween.Completed:Wait()
	else
		local tween = TweenService:Create(transition, TweenInfo.new(0.3), {
			BackgroundTransparency = 1
		})
		tween:Play()
		tween.Completed:Wait()
		transition.Visible = false
	end
end

local function makeTeleportVisible(serverTeleport: boolean)
	if thread then
		task.cancel(thread)
		thread = nil
	end

	thread = task.spawn(function()
		transition.Visible = true
		local tween = TweenService:Create(transition, TweenInfo.new(0.5), {
			BackgroundTransparency = 0
		})
		tween:Play()
		tween.Completed:Wait()
		frame.Visible = serverTeleport
		local tween2 = TweenService:Create(transition, TweenInfo.new(0.3), {
			BackgroundTransparency = 1
		})
		tween2:Play()
		tween2.Completed:Wait()
		transition.Visible = false
		v = false
	end)
end

localPlayer:GetAttributeChangedSignal("ServerTeleport"):Connect(function()
	print("teleporting!!", localPlayer:GetAttribute("ServerTeleport"))
	return makeTeleportVisible(localPlayer:GetAttribute("ServerTeleport"))
end)
parent.Parent = localPlayer:WaitForChild("PlayerGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local v = nil
local v2 = nil
local count = 0

local function getFrame()
	local v3 = v

	if v3 and v3.Parent then
		return v3
	end

	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return nil
	end

	local magmaCaveElevatorTransition = playerGui:FindFirstChild("MagmaCaveElevatorTransition")

	if magmaCaveElevatorTransition then
		magmaCaveElevatorTransition:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MagmaCaveElevatorTransition"
	screenGui.DisplayOrder = 1000
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	screenGui.Parent = playerGui
	local frame = Instance.new("Frame")
	frame.Name = "Black"
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Size = UDim2.fromScale(1, 1)
	frame.ZIndex = 1000
	frame.Parent = screenGui
	v = frame
	return frame
end

local function fade(backgroundTransparency: number, duration: number)
	local frame = getFrame()

	if not frame then
		return
	end

	if v2 then
		v2:Cancel()
		v2 = nil
	end

	if duration <= 0 then
		frame.BackgroundTransparency = backgroundTransparency
		return
	end

	local tween = TweenService:Create(
		frame,
		TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			BackgroundTransparency = backgroundTransparency
		}
	)
	v2 = tween
	tween.Completed:Connect(function()
		if v2 == tween then
			v2 = nil
		end
	end)
	tween:Play()
end

return {
	OnStart = function()
		local Net = require(game.ReplicatedStorage.Modules.Net)
		Net:RemoteEvent("MagmaCaveElevatorFade").OnClientEvent:Connect(function(p, value)
			local v3 = (typeof(value) ~= "number" or value ~= value) and 0.35 or math.clamp(value, 0, 5)
			count += 1

			if p == "In" then
				local v4 = count
				fade(0, v3)
				task.delay(8, function()
					if count == v4 then
						fade(1, v3)
					end
				end)
			elseif p == "Out" then
				fade(1, v3)
			end
		end)
		Net:RemoteEvent("MagmaCaveElevatorLocked").OnClientEvent:Connect(function(value)
			if typeof(value) ~= "string" or value == "" then
				return
			end

			local DialogueController = require(game.ReplicatedStorage.DialogueController)

			if DialogueController.Active then
				return
			end

			local v3 = DialogueController.new()
			v3:setTitle(Players.LocalPlayer.DisplayName)
			v3:addPage("Main", function(object)
				object:addText(value)
			end)
			v3:build()
			DialogueController.start(v3)
		end)
	end
}
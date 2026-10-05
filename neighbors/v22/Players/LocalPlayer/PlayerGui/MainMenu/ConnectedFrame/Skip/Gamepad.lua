local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Network = require(ReplicatedStorage.Modules.Network)
local pV2Piano = script.Parent.Parent.Parent.PV2Piano
local buttons = script.Parent.Buttons
local skip = buttons.Skip
local pause = buttons.Pause
local v = {
	Skip = Enum.KeyCode.ButtonY,
	Pause = Enum.KeyCode.ButtonB
}
local v2 = {}

local function buildProgressCallback(p, p2, p3: number, fn)
	local lastTime = os.clock()
	p.Progress.Size = UDim2.new(0, 0, 1, 0)
	p.Progress.Visible = true

	if v2[p] then
		v2[p]:Pause()
		v2[p] = nil
	end

	TweenService:Create(p.UIScale, TweenInfo.new(0.2), {
		Scale = 1.1
	}):Play()

	while os.clock() - lastTime < p3 and UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, p2) do
		local v3 = math.clamp((os.clock() - lastTime) / p3, 0, 1)
		p.Progress.Size = UDim2.new(v3, 0, 1, 0)
		task.wait()
	end

	TweenService:Create(p.UIScale, TweenInfo.new(0.2), {
		Scale = 1
	}):Play()
	v2[p] = TweenService:Create(p.Progress, TweenInfo.new(0.15), {
		Size = UDim2.new(0, 0, 1, 0)
	})
	v2[p].Completed:Once(function(p4)
		if p4 == Enum.PlaybackState.Completed then
			p.Progress.Visible = false
		end
	end)
	v2[p]:Play()

	if p3 <= os.clock() - lastTime then
		fn()
	end
end

pV2Piano:GetAttributeChangedSignal("Visible"):Connect(function()
	local visible = pV2Piano:GetAttribute("Visible")

	for _, v3 in { pause, skip } do
		v3.Interactable = not visible
		v3.Active = not visible
	end
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
	if not gameProcessed and buttons.Visible then
		if input.KeyCode == v.Skip then
			if skip.Blocked.Visible or not skip.Visible then
				return
			end

			buildProgressCallback(skip, v.Skip, 0.5, function()
				Network:fire("Skip")
			end)
		elseif input.KeyCode == v.Pause then
			if Players.LocalPlayer:GetAttribute("IsCustomizingLocalHouse") then
				Network:invoke("UpdateLocalCustomizationStatus", false)
				return
			end

			if pause.Blocked.Visible or not pause.Visible then
				return
			end

			if Players.LocalPlayer:GetAttribute("ForceQueueTargetADMIN") then
				return
			else
				buildProgressCallback(pause, v.Pause, 1, function()
					Network:fire("Pause")
				end)
			end
		end
	end
end)
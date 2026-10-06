local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local SoundService = game:GetService("SoundService")
local sound = Instance.new("Sound")
sound.Name = "UIHoverSound"
sound.SoundId = "rbxasset://sounds/switch.wav"
sound.Volume = 0.18
sound.Parent = SoundService
local sound2 = Instance.new("Sound")
sound2.Name = "UIClickSound"
sound2.SoundId = "rbxasset://sounds/switch.wav"
sound2.Volume = 0.3
sound2.PlaybackSpeed = 0.8
sound2.Parent = SoundService
local object = setmetatable({}, {
	__mode = "k"
})
local now = 0

local function bind(button)
	if not button:IsA("GuiButton") or object[button] then
		return
	end

	object[button] = true
	button.Activated:Connect(function()
		sound2:Stop()
		sound2:Play()
	end)
	button.MouseEnter:Connect(function()
		if not (button.Interactable and button.Active) then
			return
		end

		local parent = button

		while parent and parent ~= playerGui do
			if parent:IsA("GuiObject") and not parent.Visible then
				return
			end

			if parent:IsA("ScreenGui") and not parent.Enabled then
				return
			else
				parent = parent.Parent
			end
		end

		if parent ~= playerGui or os.clock() - now < 0.065 then
			return
		end

		now = os.clock()
		sound:Stop()
		sound:Play()
	end)
end

for _, descendant in playerGui:GetDescendants() do
	bind(descendant)
end

playerGui.DescendantAdded:Connect(bind)
script.Destroying:Connect(function()
	sound:Destroy()
	sound2:Destroy()
end)
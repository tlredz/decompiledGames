local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local localPlayer = game.Players.LocalPlayer
local parent = script.Parent
local TweenService = game:GetService("TweenService")
local v = nil
local v2 = "PC"
local v3 = {
	PC = parent:WaitForChild("Desktop"),
	Tablet = parent:WaitForChild("Mobile"),
	Phone = parent:WaitForChild("Mobile"),
	Gamepad = parent:WaitForChild("Console")
}
script:WaitForChild("Click")
local ding = script:WaitForChild("Ding")
local clickSounds = script:WaitForChild("ClickSounds")

local function showRoleSelect(data)
	task.wait(0.3)
	local v4 = v
	local roles = data.Roles
	local selectedRole = data.SelectedRole
	local chanceRole = data.ChanceRole or "Murderer"
	local chance = data.Chance
	local v5 = {}

	for k, _ in roles do
		table.insert(v5, k)
	end

	v4.Chance.Visible = chance ~= nil
	v4.Title.Text = "You Are"
	v4.BackgroundTransparency = 0.3
	v4.Visible = true

	if chance ~= nil then
		v4.Chance.Text = "Your chance to be " .. string.lower(chanceRole) .. ": " .. chance .. "%"
	end

	if #v5 > 1 then
		local children = clickSounds:GetChildren()
		local v6 = 1
		local v7 = 1

		for i = 1, 24 do
			local v8 = v6 + 1
			v6 = #v5 < v8 and 1 or v8
			local text = v5[v6]
			local role = roles[text]
			local v10

			if text == selectedRole then
				v10 = i > 14
			else
				v10 = false
			end

			if v10 then
				ding:Play()
			else
				local v11 = v7 > 6 and 1 or v7
				children[v11]:Play()
				v7 = v11 + 1
			end

			v4.Role.Text = text
			v4.Role.TextColor3 = role
			task.wait(0.1)

			if v10 then
				break
			end
		end

		task.wait(2.5)
	else
		local selectedRole2 = data.SelectedRole
		local role = roles[selectedRole2]
		v4.Role.Text = selectedRole2
		v4.Role.TextColor3 = role
		task.wait(1.5)
	end

	local gameplayText = data.GameplayText or "Game starts in..."
	v4.Title.Text = gameplayText
	v4.Role.TextColor3 = Color3.fromRGB(255, 255, 255)
	v4.Chance.Visible = false
	local countdownLength = data.CountdownLength or 10

	for i = 1, countdownLength do
		v4.Role.Text = countdownLength + 1 - i

		if i == 3 then
			TweenService:Create(v4, tweenInfo, {
				Position = UDim2.new(0.5, 0, 0, v4.AbsoluteSize.Y / 2),
				BackgroundTransparency = 1
			}):Play()
		end

		task.wait(1)
	end

	v4.Visible = false
	v4.Position = UDim2.new(0.5, 0, 0.5, 0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateDevice()
	local device = localPlayer.PlayerGui:GetAttribute("Device") or "PC"
	v = v3[device]
	v2 = device
end

UpdateDevice() -- equivalent call inferred; original call site unknown
localPlayer.PlayerGui:GetAttributeChangedSignal("Device"):Connect(UpdateDevice)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Gameplay"):WaitForChild("ShowRoleSelectNew").OnClientEvent:Connect(showRoleSelect)
local parent = script.Parent.Parent
local roleSelector = parent:WaitForChild("RoleSelector")
local localPlayer = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage:WaitForChild("Remotes")

for _, child in pairs(script:GetChildren()) do
	local ContentProvider = game:GetService("ContentProvider")
	ContentProvider:Preload(child.SoundId)
end

local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false)

-- equivalent calls inferred from this helper; original call sites unknown
local function onGameplayFade()
	TweenService:Create(parent:WaitForChild("Fade"), tweenInfo, {
		BackgroundTransparency = 0
	}):Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unfadeGameplay()
	TweenService:Create(parent:WaitForChild("Fade"), tweenInfo, {
		BackgroundTransparency = 1
	}):Play()
end

game.ReplicatedStorage.Remotes.Gameplay.LoadingMap.OnClientEvent:connect(function(_) end)
local v = {
	Innocent = Color3.new(0, 1, 0),
	Sheriff = Color3.new(0, 0, 1),
	Murderer = Color3.new(1, 0, 0),
	Zombie = Color3.new(0.09803921568627451, 0.6745098039215687, 0),
	Survivor = Color3.new(0.16862745098039217, 0.6039215686274509, 0.9333333333333333),
	Red = Color3.new(0.8509803921568627, 0.13725490196078433, 0.13725490196078433),
	Blue = Color3.new(0.24705882352941178, 0.6901960784313725, 0.8784313725490196),
	Juggernaut = Color3.new(0.8509803921568627, 0.13725490196078433, 0.13725490196078433),
	Gladiator = Color3.new(0.24705882352941178, 0.6901960784313725, 0.8784313725490196)
}
local v2 = {
	Innocent = 13,
	Sheriff = 14,
	Murderer = 15
}
local v3 = {
	Classic = { "Innocent", "Sheriff", "Murderer" },
	Infection = { "Survivor", "Zombie" }
}
remotes.Gameplay.Fade.OnClientEvent:Connect(function()
	onGameplayFade() -- equivalent call inferred; original call site unknown
end)
remotes.Gameplay.ShowRoleSelect.OnClientEvent:Connect(function()
	unfadeGameplay() -- equivalent call inferred; original call site unknown
end)
remotes.Gameplay.ShowRoleSelectNew.OnClientEvent:Connect(function()
	unfadeGameplay() -- equivalent call inferred; original call site unknown
end)
remotes.Gameplay.RoleSelect.OnClientEvent:Connect(function(text, _, _, p, p2)
	unfadeGameplay() -- equivalent call inferred; original call site unknown

	if p2 == "Classic" then
		roleSelector.Chance.Text = "Your chance to be murderer: "
		spawn(function()
			roleSelector.Chance.Text = "Your chance to be murderer: " .. game.ReplicatedStorage.Remotes.Extras.GetChance:InvokeServer() .. "%"
		end)
	end

	roleSelector.Visible = true

	if p2 == "Classic" then
		local classic = v3.Classic

		for i = 1, v2[text] do
			local text2 = classic[(i - 1) % #classic + 1]

			if i == v2[text] then
				script.Ding:Play()
			else
				script["Click" .. (i - 1) % #classic + 1]:Play()
			end

			wait(0.04)
			roleSelector.Role.Text = text2
			roleSelector.Role.TextColor3 = v[text2]
			wait(0.06)
		end

		wait(2.5)

		if text == "Murderer" or text == "Sheriff" or text == "Zombie" or text == "Survivor" then
			roleSelector.Title.Text = "You will receive your weapon in..."
			roleSelector.Role.TextColor3 = Color3.new(1, 1, 1)

			for i = 1, 10 do
				roleSelector.Role.Text = 11 - i

				if i == 3 then
					roleSelector:TweenPosition(UDim2.new(0, 0, 0, 25), "Out", "Quad", 1, false)
				end

				wait(1)
			end

			roleSelector.Visible = false
		else
			roleSelector.Title.Text = "Game starts in..."
			roleSelector.Role.TextColor3 = Color3.new(1, 1, 1)

			for i = 1, 10 do
				roleSelector.Role.Text = 11 - i

				if i == 3 then
					roleSelector:TweenPosition(UDim2.new(0, 0, 0, 25), "Out", "Quad", 1, false)
				end

				wait(1)
			end
		end
	end

	if p2 == "Dodgeball" then
		roleSelector.Title.Text = "You are on the"
		roleSelector.Role.Text = text .. " Team"
		roleSelector.Role.TextColor3 = v[text] or Color3.new()
		wait(3)
		roleSelector.Title.Text = "Game starts in..."
		roleSelector:TweenPosition(UDim2.new(0, 0, 0, 25), "Out", "Quad", 1, false)
		roleSelector.Role.TextColor3 = Color3.new(1, 1, 1)

		for i = 1, 5 do
			roleSelector.Role.Text = 6 - i
			wait(1)
		end
	elseif p2 == "Infection" then
		roleSelector.Title.Text = "Everyone is a"
		roleSelector.Role.Text = "Survivor"
		roleSelector.Role.TextColor3 = v.Survivor
		wait(3)
		roleSelector.Title.Text = "Someone will be infected in..."
		roleSelector:TweenPosition(UDim2.new(0, 0, 0, 25), "Out", "Quad", 1, false)
		roleSelector.Role.TextColor3 = Color3.new(1, 1, 1)

		for i = 1, 5 do
			roleSelector.Role.Text = 6 - i
			wait(1)
		end
	elseif p2 == "Massacre" then
		roleSelector.Title.Text = "Everyone is a"
		roleSelector.Role.Text = "Murderer"
		roleSelector.Role.TextColor3 = Color3.new(1, 0, 0)
		wait(3)
		roleSelector.Title.Text = "Massacre starts in..."
		roleSelector:TweenPosition(UDim2.new(0, 0, 0, 25), "Out", "Quad", 1, false)
		roleSelector.Role.TextColor3 = Color3.new(1, 1, 1)

		for i = 1, 5 do
			roleSelector.Role.Text = 6 - i
			wait(1)
		end
	elseif p2 == "Juggernaut" then
		roleSelector.Title.Text = "You are a"
		roleSelector.Role.Text = text
		roleSelector.Role.TextColor3 = v[text]
		wait(3)
		roleSelector.Title.Text = "Battle begins in..."
		roleSelector:TweenPosition(UDim2.new(0, 0, 0, 25), "Out", "Quad", 1, false)
		roleSelector.Role.TextColor3 = Color3.new(1, 1, 1)

		for i = 1, 5 do
			roleSelector.Role.Text = 6 - i
			wait(1)
		end
	end

	roleSelector.Visible = false

	if p then
		game.Players.LocalPlayer.CameraMode = "LockFirstPerson"
	end
end)
remotes:WaitForChild("Gameplay"):WaitForChild("GiveWeapon").OnClientEvent:Connect(function(p: string)
	parent.Weapon.Visible = true
	parent.Weapon.Knife.Visible = p == "Knife"
	parent.Weapon.Gun.Visible = p == "Gun"
	parent.Weapon.WeaponIcon.Image = p == "Knife" and "http://www.roblox.com/asset/?id=148256623" or p == "Gun" and "http://www.roblox.com/asset/?id=197518111" or ""
end)
game.ReplicatedStorage.Remotes.Gameplay.RoundStart.OnClientEvent:Connect(function(text)
	unfadeGameplay() -- equivalent call inferred; original call site unknown
	parent.Timer.Text = text

	while wait(1) do
		text -= 1
		parent.Timer.Text = text
	end
end)

repeat
	wait()
until localPlayer.Character ~= nil

wait()
localPlayer.CameraMode = "Classic"
localPlayer.CameraMinZoomDistance = 7
wait(0.5)
localPlayer.CameraMinZoomDistance = 0.5
game.StarterGui:SetCoreGuiEnabled("Health", false)
game.StarterGui:SetCoreGuiEnabled("PlayerList", false)
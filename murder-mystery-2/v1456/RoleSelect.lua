local localPlayer = game.Players.LocalPlayer
local parent = script.Parent.Parent
local _ = parent.Parent
local lobby = parent:WaitForChild("Lobby")
lobby:WaitForChild("Dock")
lobby:WaitForChild("Screens")
game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local game2 = parent:WaitForChild("Game")
local roleSelector = game2:WaitForChild("RoleSelector")
local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false)

for _, child in pairs(script:GetChildren()) do
	local ContentProvider = game:GetService("ContentProvider")
	ContentProvider:Preload(child.SoundId)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetImage(image)
	if _G.Cache[image] ~= nil then
		return _G.Cache[image]
	end

	local v

	if tonumber(image) then
		v = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. image or image
	else
		v = image
	end

	local v2 = v .. "&bust=" .. math.random(1, 10000)
	_G.Cache[image] = v2
	return v2
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local weapons = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync")).Weapons
game.ReplicatedStorage.Remotes.Gameplay.LoadingMap.OnClientEvent:connect(function(p)
	if p ~= "Classic" and p ~= "ScaryMode" then
	end
end)
local v = {
	Innocent = Color3.new(0, 1, 0),
	Sheriff = Color3.new(0, 0, 1),
	Murderer = Color3.new(1, 0, 0),
	Zombie = Color3.new(0.09803921568627451, 0.6745098039215687, 0),
	Survivor = Color3.new(0.16862745098039217, 0.6039215686274509, 0.9333333333333333),
	Red = Color3.new(0.8509803921568627, 0.13725490196078433, 0.13725490196078433),
	Blue = Color3.new(0.24705882352941178, 0.6901960784313725, 0.8784313725490196),
	Juggernaut = Color3.new(0.8509803921568627, 0.13725490196078433, 0.13725490196078433),
	Gladiator = Color3.new(0.24705882352941178, 0.6901960784313725, 0.8784313725490196),
	Freezer = Color3.fromRGB(150, 220, 250),
	Runner = Color3.fromRGB(0, 200, 100)
}

local function updateTarget(text, p, p2, p3)
	local assassinTarget = game2.AssassinTarget

	if text == nil or p == nil or p2 == nil then
		assassinTarget.Visible = false
		return
	end

	local userThumbnailAsync = game.Players:GetUserThumbnailAsync(
		math.abs(p),
		Enum.ThumbnailType.AvatarBust,
		Enum.ThumbnailSize.Size180x180
	)
	assassinTarget.Target.PlayerIcon.Image = userThumbnailAsync
	assassinTarget.TargetName.Text = text
	local icon = assassinTarget.Knife.Icon
	local image = GetImage(weapons[p2].Image) -- equivalent call inferred; original call site unknown
	icon.Image = image
	local icon2 = assassinTarget.Gun.Icon
	local image2 = GetImage(weapons[p3].Image) -- equivalent call inferred; original call site unknown
	icon2.Image = image2
	assassinTarget.Visible = true
end

local v2 = {
	Classic = { "Innocent", "Sheriff", "Murderer" },
	Infection = { "Survivor", "Zombie" },
	FreezeTag = { "Freezer", "Runner" }
}
local v3 = {
	Innocent = 13,
	Sheriff = 14,
	Murderer = 15,
	Freezer = 13,
	Runner = 14
}
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage2:WaitForChild("Remotes")

-- equivalent calls inferred from this helper; original call sites unknown
local function unfadeGameplay()
	lobby.LeaderBar.Visible = false
	lobby.GameBar.Visible = true
	TweenService:Create(lobby.Fade, tweenInfo, {
		BackgroundTransparency = 1
	}):Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fadeGameplay()
	TweenService:Create(lobby.Fade, tweenInfo, {
		BackgroundTransparency = 0
	}):Play()
end

local v4 = nil
remotes.Gameplay.RoleSelect.OnClientEvent:connect(function(p, _, _, p2, p3, text, p5, p6, p7)
	local v5 = v2[p3]
	unfadeGameplay() -- equivalent call inferred; original call site unknown
	task.wait(tweenInfo.Time)
	game.Players.LocalPlayer.PlayerGui:SetTopbarTransparency(0.5)

	if p3 == "ScaryMode" then
		if p == "Innocent" then
			game2.Crouch.Visible = true
		end
	else
		roleSelector.Visible = true

		if p3 == "Classic" or p3 == "FreezeTag" then
			for i = 1, v3[p] do
				local text2 = v5[(i - 1) % #v5 + 1]

				if i == v3[p] then
					script.Ding:Play()
				else
					script[text2]:Play()
				end

				wait(0.04)
				roleSelector.Role.Text = text2
				roleSelector.Role.TextColor3 = v[text2]
				wait(0.06)
			end

			wait(2.5)

			if p == "Innocent" or p == "Runner" then
				roleSelector.Title.Text = "Game starts in..."
			else
				roleSelector.Title.Text = "You will receive your weapon in..."
			end

			roleSelector.Role.TextColor3 = Color3.new(1, 1, 1)

			for i = 1, 10 do
				roleSelector.Role.Text = 11 - i

				if i == 3 then
					roleSelector:TweenPosition(UDim2.new(0.5, 0, 0, 0), "Out", "Quad", 1, false)
				end

				wait(1)
			end

			roleSelector.Visible = false
		elseif p3 == "Infection" then
			roleSelector.Title.Text = "Everyone is a"
			roleSelector.Role.Text = "Survivor"
			roleSelector.Role.TextColor3 = v.Survivor
			wait(3)
			roleSelector.Title.Text = "Someone will be infected in..."
			roleSelector:TweenPosition(UDim2.new(0.5, 0, 0, 0), "Out", "Quad", 1, false)
			roleSelector.Role.TextColor3 = Color3.new(1, 1, 1)

			for i = 1, 5 do
				roleSelector.Role.Text = 6 - i
				wait(1)
			end

			roleSelector.Visible = false
		elseif p3 == "Assassin" then
			roleSelector.Visible = false
			local assassinTarget = game2.AssassinTarget
			updateTarget(text, p7, p5, p6)
			v4 = text

			for i = 1, 10 do
				assassinTarget.Timer.Text = 11 - i
				wait(1)
			end

			assassinTarget.TimerTitle.Visible = false
			assassinTarget.Timer.Visible = false
		end

		if p2 then
			localPlayer.CameraMode = "LockFirstPerson"
		end
	end
end)
remotes.Gameplay.ShowRoleSelect.OnClientEvent:Connect(unfadeGameplay)
remotes.Gameplay.ShowRoleSelectNew.OnClientEvent:Connect(unfadeGameplay)

local function onFadeEvent(_)
	lobby.Screens.Waiting.Scoreboard.Visible = false
	game.Players.LocalPlayer.PlayerGui:SetTopbarTransparency(0)

	if localPlayer:GetAttribute("Alive") ~= true then
		fadeGameplay() -- equivalent call inferred; original call site unknown
		task.wait(tweenInfo.Time)
	end

	game2.Visible = true
	GuiService.TouchControlsEnabled = true
end

game.ReplicatedStorage.Remotes.Gameplay.Fade.OnClientEvent:connect(function(p)
	onFadeEvent(p)
end)
game.ReplicatedStorage.Remotes.Gameplay.ChangeTarget.OnClientEvent:connect(function(text, p2, p3, p4)
	local assassinTarget = game2.AssassinTarget

	if v4 ~= text then
		v4 = text
		assassinTarget.NewTarget.Visible = true
		task.spawn(function()
			wait(1)
			assassinTarget.NewTarget.Visible = false
		end)
	end

	updateTarget(text, p4, p2, p3)
end)
game.ReplicatedStorage.Remotes.Gameplay.VictoryScreen.OnClientEvent:connect(function()
	game2.AssassinTarget.Visible = false
end)
_G.LockTarget = nil
localPlayer.CameraMode = Enum.CameraMode.Classic
localPlayer.CameraMinZoomDistance = 7
wait(0.5)
localPlayer.CameraMinZoomDistance = 0.5
game.Players.LocalPlayer.Character.Humanoid.Died:connect(function()
	game.Players.LocalPlayer.CameraMode = Enum.CameraMode.Classic
end)
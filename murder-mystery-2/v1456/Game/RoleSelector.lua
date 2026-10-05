local game2 = script.Parent:WaitForChild("Game")
local roleSelector = game2:WaitForChild("RoleSelector")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage:WaitForChild("Remotes")

for _, child in script:GetChildren() do
	local ContentProvider = game:GetService("ContentProvider")
	ContentProvider:Preload(child.SoundId)
end

local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local item = require(ReplicatedStorage2:WaitForChild("Database"):WaitForChild("Sync")).Item
local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false)
TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
local TweenService = game:GetService("TweenService")
local v = nil
local target3 = game2:WaitForChild("Target3")
local v2 = {
	Innocent = Color3.new(0, 1, 0),
	Sheriff = Color3.new(0, 0, 1),
	Murderer = Color3.new(1, 0, 0),
	Zombie = Color3.new(0.09803921568627451, 0.6745098039215687, 0),
	Survivor = Color3.new(0.16862745098039217, 0.6039215686274509, 0.9333333333333333),
	Freezer = Color3.fromRGB(150, 220, 250),
	Runner = Color3.fromRGB(0, 200, 100),
	Red = Color3.new(0.8509803921568627, 0.13725490196078433, 0.13725490196078433),
	Blue = Color3.new(0.24705882352941178, 0.6901960784313725, 0.8784313725490196),
	Juggernaut = Color3.new(0.8509803921568627, 0.13725490196078433, 0.13725490196078433),
	Gladiator = Color3.new(0.24705882352941178, 0.6901960784313725, 0.8784313725490196)
}
local v3 = {
	Innocent = 13,
	Sheriff = 14,
	Murderer = 15,
	Freezer = 13,
	Runner = 14
}
local v4 = {
	Classic = { "Innocent", "Sheriff", "Murderer" },
	Infection = { "Survivor", "Zombie" },
	FreezeTag = { "Freezer", "Runner" }
}

-- equivalent calls inferred from this helper; original call sites unknown
local function GetImage(image)
	if _G.Cache[image] ~= nil then
		return _G.Cache[image]
	end

	local v5

	if tonumber(image) then
		v5 = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. image or image
	else
		v5 = image
	end

	local v6 = v5 .. "&bust=" .. math.random(1, 10000)
	_G.Cache[image] = v6
	return v6
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PlayTweens(items)
	for _, item2 in pairs(items) do
		item2:Play()
	end
end

local function onMapLoading()
	game2.Waiting.Image = "http://www.roblox.com/asset/?id=304416585"
end

local function updateAssassinTarget(text, p, p2, p3)
	if text == nil or p == nil or p2 == nil then
		target3.Visible = false
		return
	end

	local userThumbnailAsync = game.Players:GetUserThumbnailAsync(
		math.abs(p),
		Enum.ThumbnailType.AvatarBust,
		Enum.ThumbnailSize.Size180x180
	)
	target3.Target.PlayerIcon.Image = userThumbnailAsync
	target3.TargetName.Text = text
	local icon = target3.Knife.Icon
	local image = GetImage(item[p2].Image) -- equivalent call inferred; original call site unknown
	icon.Image = image
	local icon2 = target3.Gun.Icon
	local image2 = GetImage(item[p3].Image) -- equivalent call inferred; original call site unknown
	icon2.Image = image2
	target3.Visible = true
end

local function onAssassinTargetChanged(text, p2, p3, p4)
	local target32 = game2.Target3

	if text ~= v then
		v = text
		target32.NewTarget.Visible = true
		task.spawn(function()
			wait(1)
			target32.NewTarget.Visible = false
		end)
	end

	updateAssassinTarget(text, p4, p2, p3)
end

local function onGameplayFade()
	PlayTweens({ TweenService:Create(game2.Fade, tweenInfo, {
			BackgroundTransparency = 0
		}) }) -- equivalent call inferred; original call site unknown
end

local function unfadeGameplay()
	local waiting = game2:WaitForChild("Waiting")
	waiting.Visible = false
	PlayTweens({ TweenService:Create(game2:WaitForChild("Fade"), tweenInfo, {
			BackgroundTransparency = 1
		}) }) -- equivalent call inferred; original call site unknown
end

local function onVictoryScreenShown()
	game2.Target3.Visible = false
end

local function onRoleSelect(p, p2, p3, p4, p5, text, p7, p8, p9)
	unfadeGameplay()
	wait(0.3)

	if p5 == "Classic" then
		roleSelector.Chance.Text = "Your chance to be murderer: "
		task.spawn(function()
			roleSelector.Chance.Text = "Your chance to be murderer: " .. game.ReplicatedStorage.Remotes.Extras.GetChance:InvokeServer() .. "%"
		end)
	end

	roleSelector.Visible = true

	if p5 == "Classic" or p5 == "FreezeTag" then
		local v5 = v4[p5]

		for i = 1, v3[p] do
			local text2 = v5[(i - 1) % #v5 + 1]

			if i == v3[p] then
				script.Ding:Play()
			else
				script["Click" .. (i - 1) % #v5 + 1]:Play()
			end

			wait(0.04)
			roleSelector.Role.Text = text2
			roleSelector.Role.TextColor3 = v2[text2]
			wait(0.06)
		end

		wait(2.5)

		if p == "Murderer" or p == "Sheriff" or p == "Zombie" or p == "Survivor" or p == "Freezer" then
			roleSelector.Title.Text = "You will receive your weapon in..."
			roleSelector.Role.TextColor3 = Color3.new(1, 1, 1)

			for i = 1, 10 do
				roleSelector.Role.Text = 11 - i

				if i == 3 then
					roleSelector:TweenPosition(UDim2.new(0.5, -150, 0, 25), "Out", "Quad", 1, false)
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
					roleSelector:TweenPosition(UDim2.new(0.5, -150, 0, 25), "Out", "Quad", 1, false)
				end

				wait(1)
			end
		end
	elseif p5 == "Assassin" then
		roleSelector.Visible = false
		updateAssassinTarget(text, p9, p7, p8)
		v = text

		for i = 1, 10 do
			target3.Timer.Text = "Game starts in... " .. 11 - i
			wait(1)
		end

		target3.Timer.Visible = false
	end

	roleSelector.Visible = false

	if p4 then
		game.Players.LocalPlayer.CameraMode = "LockFirstPerson"
		local yourCodeName = game2.YourCodeName
		local CodeImages = require(game.ReplicatedStorage.CodeImages)
		yourCodeName.Image = CodeImages[p3]
		game2.YourCodeName.ImageColor3 = p2.Color
		game2.YourCodeName.Visible = true
	end

	if p5 == "ScaryMode" and p == "Innocent" then
		local UserInputService = game:GetService("UserInputService")
		local touchEnabled = UserInputService.TouchEnabled

		if touchEnabled then
			local UserInputService2 = game:GetService("UserInputService")
			touchEnabled = not UserInputService2.KeyboardEnabled
		end

		if touchEnabled then
			game2.Crouch.Visible = true
		end
	end
end

remotes:WaitForChild("Gameplay"):WaitForChild("Fade").OnClientEvent:Connect(onGameplayFade)
remotes.Gameplay:WaitForChild("LoadingMap").OnClientEvent:Connect(onMapLoading)
remotes.Gameplay:WaitForChild("ShowRoleSelect").OnClientEvent:Connect(unfadeGameplay)
remotes.Gameplay:WaitForChild("ShowRoleSelectNew").OnClientEvent:Connect(unfadeGameplay)
remotes.Gameplay:WaitForChild("RoleSelect").OnClientEvent:Connect(onRoleSelect)
remotes.Gameplay:WaitForChild("ChangeTarget").OnClientEvent:Connect(onAssassinTargetChanged)
remotes.Gameplay:WaitForChild("VictoryScreen").OnClientEvent:Connect(onVictoryScreenShown)
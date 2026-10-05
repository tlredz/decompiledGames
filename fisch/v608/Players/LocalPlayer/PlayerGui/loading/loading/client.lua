local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
local StarterGui = game:GetService("StarterGui")
local CollectionService = game:GetService("CollectionService")
local GuiService = game:GetService("GuiService")
local StarterPlayer = game:GetService("StarterPlayer")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local loading = script.Parent:WaitForChild("loading")
local iris = script.Parent:WaitForChild("iris")
local v = nil
local flag = false
local titleMusic = script.Parent:WaitForChild("TitleMusic")
titleMusic.Parent = script.Parent

local function oriRad(p, p2, p3)
	return CFrame.fromOrientation(math.rad(p), math.rad(p2), (math.rad(p3)))
end

local v2 = {
	Starter = CFrame.new(317.298, 134.766, 277.479) * CFrame.fromOrientation(
		0,
		-0.9948376736367679,
		0.22689280275926285
	),
	TradePlaza = CFrame.new(523, 99, 1822) * CFrame.fromOrientation(
		-0.17453292519943295,
		-2.199114857512855,
		0.22689280275926285
	),
	["Abyssal Zenith"] = CFrame.new(-13589, -11004, 18) * CFrame.fromOrientation(
		-0.5235987755982988,
		2.199114857512855,
		-0.22689280275926285
	),
	AncientIsle = CFrame.new(6076, 206, 256) * CFrame.fromOrientation(
		-0.22689280275926285,
		2.8099800957108707,
		0.22689280275926285
	),
	Atlantis = CFrame.new(-4150, -555, 1747) * CFrame.fromOrientation(
		-0.24434609527920614,
		2.0420352248333655,
		0.22689280275926285
	),
	["Calm Zone"] = CFrame.new(-4293, -11194, 1748) * CFrame.fromOrientation(
		-0.17453292519943295,
		-0.13962634015954636,
		0.22689280275926285
	),
	["Castaway Cliffs"] = CFrame.new(673, 159, -1757) * CFrame.fromOrientation(
		0.4363323129985824,
		0.4363323129985824,
		-0.24434609527920614
	),
	["Challengers Deep"] = CFrame.new(-738, -3236, -673) * CFrame.fromOrientation(
		-0.3141592653589793,
		1.9722220547535925,
		-0.22689280275926285
	),
	CryogenicCanal = CFrame.new(20310, 724, 5657) * CFrame.fromOrientation(
		0.15707963267948966,
		2.199114857512855,
		-0.22689280275926285
	),
	CrystalCove = CFrame.new(1382, -615, 2456) * CFrame.fromOrientation(
		0.06981317007977318,
		0.20943951023931956,
		-0.22689280275926285
	),
	DesolateDeep = CFrame.new(-1656, -207, -2935) * CFrame.fromOrientation(
		-0.20943951023931956,
		-2.6179938779914944,
		0.22689280275926285
	),
	["Forsaken Shores"] = CFrame.new(-2449, 147, 1493) * CFrame.fromOrientation(
		-0.017453292519943295,
		2.129301687433082,
		0.22689280275926285
	),
	FrigidCavern = CFrame.new(19723, 422, 5411) * CFrame.fromOrientation(
		-0.08726646259971647,
		-1.2566370614359172,
		-0.22689280275926285
	),
	GlacialGrotto = CFrame.new(19997, 1144, 5568) * CFrame.fromOrientation(
		0.20943951023931956,
		0.6806784082777885,
		0.22689280275926285
	),
	["Living Garden"] = CFrame.new(-2493, -300, -3106) * CFrame.fromOrientation(
		-0.12217304763960307,
		-2.4958208303518914,
		0.22689280275926285
	),
	["Lost Jungle"] = CFrame.new(-2670, 170, -2080) * CFrame.fromOrientation(
		-0.2792526803190927,
		1.710422666954443,
		0.22689280275926285
	),
	LuminescentCavern = CFrame.new(-1023, -330, -4078) * CFrame.fromOrientation(
		-0,
		-0.10471975511965978,
		0.22689280275926285
	),
	Moosewood = CFrame.new(454, 154, 249) * CFrame.fromOrientation(
		-0.06981317007977318,
		-1.8500490071139892,
		-0.22689280275926285
	),
	OvergrowthCaves = CFrame.new(19541, 176, 5358) * CFrame.fromOrientation(
		-0.5585053606381855,
		-0.4014257279586958,
		0.2617993877991494
	),
	Roslit = CFrame.new(-1419, 137, 754) * CFrame.fromOrientation(
		0.05235987755982989,
		0.8726646259971648,
		-0.22689280275926285
	),
	["Scoria Reach"] = CFrame.new(-5098, 140, -1461) * CFrame.fromOrientation(
		0.2792526803190927,
		1.5882496193148399,
		0.24434609527920614
	),
	Snowcap = CFrame.new(2669, 155, 2362) * CFrame.fromOrientation(
		0.08726646259971647,
		-2.670353755551324,
		-0.22689280275926285
	),
	Sunstone = CFrame.new(-904, 141, -1146) * CFrame.fromOrientation(
		0.2617993877991494,
		2.426007660272118,
		0.22689280275926285
	),
	Terrapin = CFrame.new(-124, 161, 1928) * CFrame.fromOrientation(
		-0.20943951023931956,
		1.710422666954443,
		0.22689280275926285
	),
	["The Depths"] = CFrame.new(943, -696, 1173) * CFrame.fromOrientation(
		0.06981317007977318,
		3.1066860685499065,
		-0.22689280275926285
	),
	Tidefall = CFrame.new(3091, -1098, 805) * CFrame.fromOrientation(
		0.15707963267948966,
		-1.0122909661567112,
		0.22689280275926285
	),
	["Volcanic Vents"] = CFrame.new(-3352, -2242, 3811) * CFrame.fromOrientation(
		-0.08726646259971647,
		2.478367537831948,
		-0.22689280275926285
	)
}

local function PlaySound(instance, parent, flag2: boolean, tag: string?, p)
	local clone = instance:Clone()
	clone.Parent = parent

	if flag2 == true then
		clone.PlaybackSpeed += math.random(-15, 15) / 100
	end

	if tag then
		CollectionService:AddTag(clone, tag)

		if p then
			clone:SetAttribute("Owner", p.Name)
		end
	end

	clone:Play()
	task.delay(clone.TimeLength, function()
		clone:Destroy()
	end)
end

local inputBeganConnection = nil

local function play()
	if not flag then
		return
	end

	flag = false

	if inputBeganConnection ~= nil then
		inputBeganConnection:Disconnect()
	end

	local menuplay = ReplicatedStorage.resources.sounds.sfx.ui.menuplay
	local parent = script.Parent
	local clone = menuplay:Clone()
	clone.Parent = parent
	clone:Play()
	task.delay(clone.TimeLength, function()
		clone:Destroy()
	end)
	v = TweenService:Create(loading, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0
	})
	v:Play()
	TweenService:Create(loading.fish, TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		ImageTransparency = 1
	}):Play()
	TweenService:Create(loading.Tiles, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		ImageTransparency = 1
	}):Play()
	TweenService:Create(loading.tips, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 1
	}):Play()
	TweenService:Create(loading.name, TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		ImageTransparency = 1
	}):Play()
	TweenService:Create(loading.title, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 1,
		Rotation = 0
	}):Play()
	ReplicatedStorage.events.finishedloading:FireServer()

	if not localPlayer:GetAttribute("SpawnFinished") then
		localPlayer:GetAttributeChangedSignal("SpawnFinished"):Wait()
	end

	if v then
		v:Cancel()
	end

	loading.BackgroundTransparency = 0
	iris.Visible = true
	iris.Size = UDim2.new(0, 0, 0, 0)
	workspace.CurrentCamera.FieldOfView = 100
	loading.title.Rotation = math.random(-9, 9)
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	TweenService:Create(loading, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1
	}):Play()
	TweenService:Create(
		workspace.CurrentCamera,
		TweenInfo.new(3.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.3),
		{
			FieldOfView = 70
		}
	):Play()
	TweenService:Create(iris, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0.3), {
		Size = UDim2.new(3, 0, 3, 0)
	}):Play()
	TweenService:Create(titleMusic, TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Volume = 0
	}):Play()
	task.delay(5, function()
		titleMusic:Destroy()
	end)
	script.Parent.Enabled = true
	task.spawn(function()
		local hud = localPlayer.PlayerGui:WaitForChild("hud")
		local backpack = localPlayer.PlayerGui:WaitForChild("backpack")
		hud.Enabled = true
		backpack.Enabled = true
		local safezone = hud:WaitForChild("safezone")
		safezone.Visible = true
		local deviceinset = hud:WaitForChild("deviceinset")
		deviceinset.Enabled = true
	end)
	task.wait(2.5)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
	task.wait(2.5)
	script.Parent.Enabled = false
	ReplicatedStorage:SetAttribute("LoadingScreenFinished", true)

	if not localPlayer.PlayerScripts:FindFirstChild("PlayerModule") and StarterPlayer.StarterPlayerScripts:FindFirstChild("PlayerModule") then
		warn("PlayerModule didnt load normally! Why? I wish I knew!")
		StarterPlayer.StarterPlayerScripts.PlayerModule.Archivable = true

		for _, descendant in StarterPlayer.StarterPlayerScripts.PlayerModule:GetDescendants() do
			descendant.Archivable = true
		end

		local clone_2 = StarterPlayer.StarterPlayerScripts.PlayerModule:Clone()
		clone_2.Parent = localPlayer.PlayerScripts
	end

	if not localPlayer.PlayerScripts:FindFirstChild("PlayerScriptsLoader") and StarterPlayer.StarterPlayerScripts:FindFirstChild("PlayerScriptsLoader") then
		warn("PlayerScriptsLoader didnt load normally! Why? I wish I knew!")
		StarterPlayer.StarterPlayerScripts.PlayerScriptsLoader.Archivable = true
		local clone_3 = StarterPlayer.StarterPlayerScripts.PlayerScriptsLoader:Clone()
		clone_3.Parent = localPlayer.PlayerScripts
	end
end

local UserInputService = game:GetService("UserInputService")
inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
	if flag ~= true then
		return
	end

	if input.UserInputType == Enum.UserInputType.Keyboard or input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Gamepad1 then
		play()
	end
end)

local function startLoading()
	task.spawn(function()
		local deviceinset = localPlayer.PlayerGui:WaitForChild("hud", 1e999):WaitForChild("deviceinset")
		deviceinset.Enabled = false
	end)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)

	if not GuiService:IsTenFootInterface() then
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	end

	script.Parent.Enabled = true
	TweenService:Create(
		loading:WaitForChild("fish"),
		TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0),
		{
			Rotation = 60
		}
	):Play()
	task.spawn(function()
		titleMusic:Play()

		while not localPlayer:GetAttribute("DataLoaded") do
			task.wait()
		end

		local SettingsController = require(ReplicatedStorage:WaitForChild("client"):WaitForChild("legacyControllers"):WaitForChild("SettingsController"))
		local v3 = math.clamp(SettingsController:GetSettingValue("musicVolume") or 100, 0, 100)
		titleMusic.EqualizerSoundEffect.Enabled = false
		titleMusic.Volume = titleMusic.Volume * v3 / 100
	end)
	loading.fish.Image = "rbxassetid://16833240221"
	loading.loadinginfo.Text = "[Loading] ... "
end

local function waitForLoadedAsync()
	while not (game:IsLoaded() and localPlayer:GetAttribute("DataLoaded")) do
		task.wait()
	end
end

local function completeLoading()
	loading.loadinginfo.Text = "[Loading] ... Finalization"
	TweenService:Create(loading.loadinginfo, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 1
	}):Play()
	loading.skip.Visible = false
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	workspace.CurrentCamera.CFrame = v2.Starter
	task.wait(0.45)
	loading.title.Size = UDim2.new(loading.title.Size.X.Scale, 2, loading.title.Size.Y.Scale, 2)
	loading.title.TextColor3 = Color3.fromRGB(135, 135, 135)
	loading.fish.Image = "rbxassetid://17000889044"
	TweenService:Create(loading.title, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.new(loading.title.Size.X.Scale, 0, loading.title.Size.Y.Scale, 0)
	}):Play()
	TweenService:Create(loading.title, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		TextColor3 = Color3.fromRGB(255, 255, 255)
	}):Play()
	local popup = ReplicatedStorage.resources.sounds.sfx.ui.popup
	local parent = script.Parent
	local clone = popup:Clone()
	clone.Parent = parent
	clone:Play()
	task.delay(clone.TimeLength, function()
		clone:Destroy()
	end)
	loading.title.Text = "[Assets Loaded]"
	loading.title.Text = "Loading player data..."

	while not localPlayer:GetAttribute("DataLoaded") do
		task.wait()
	end

	local legacyLocalPlayerData = require(ReplicatedStorage:WaitForChild("client"):WaitForChild("modules"):WaitForChild("legacyLocalPlayerData"))
	local value = legacyLocalPlayerData.fetch():WaitForChild("Stats"):WaitForChild("spawnlocation").Value
	local FischUtils = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("utils"):WaitForChild("FischUtils"))
	local v3 = FischUtils.IsTradePlaza() and "TradePlaza" or value

	if v3 and v2[v3] then
		workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
		workspace.CurrentCamera.CFrame = v2[v3]
		workspace.CurrentCamera.Focus = v2[v3]
		task.spawn(function()
			local hud = playerGui:WaitForChild("hud")
			hud.Enabled = false
			hud:GetPropertyChangedSignal("Enabled"):Connect(function()
				if flag then
					hud.Enabled = false
				end
			end)
			local deviceinset = hud:WaitForChild("deviceinset")
			deviceinset.Enabled = false
			deviceinset:GetPropertyChangedSignal("Enabled"):Connect(function()
				if flag then
					deviceinset.Enabled = false
				end
			end)
			local backpack = playerGui:WaitForChild("backpack")
			backpack.Enabled = false
			backpack:GetPropertyChangedSignal("Enabled"):Connect(function()
				if flag then
					backpack.Enabled = false
				end
			end)

			while flag do
				workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
				workspace.CurrentCamera.CFrame = v2[v3]
				workspace.CurrentCamera.Focus = v2[v3]
				task.wait(0.1)
			end
		end)
		v = TweenService:Create(loading, TweenInfo.new(4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.15
		})
		v:Play()
	end

	loading.title.Text = "[press any key to continue]"
	flag = true

	if localPlayer:GetAttribute("NextSpawn") then
		play()
	end
end

startLoading()
waitForLoadedAsync()
completeLoading()
localPlayer:GetAttributeChangedSignal("NextSpawn"):Once(play)
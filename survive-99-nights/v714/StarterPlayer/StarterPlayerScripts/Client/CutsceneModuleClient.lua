local createVector = vector.create
local CutsceneModuleClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local UtilityAlec = require(ReplicatedStorage.Modules.UtilityAlec)
local _ = Client.Interface.SkipCutsceneFrame
local v = nil
local v2 = nil
local v3 = {}
local v4 = {}

function CutsceneModuleClient.GetCurrentCutscene()
	return v
end

function v4.LoadSet(p, p2)
	local clone = game.ReplicatedStorage.Assets.CutsceneSets[p.SetName]:Clone()
	clone.Parent = p2.Set
end

function v4.MakeNote(p, _)
	Client.PopUpUI.AddPopUp(p.Message, "note", p.Timer)
end

function v4.SetCamera(p, p2)
	local cFrame = p.CFrame

	if p2.StarterCamOffset == nil then
		p2.StarterCamOffset = nil
	end

	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	workspace.CurrentCamera.CFrame = cFrame
	workspace.CurrentCamera.Focus = cFrame * CFrame.Angles(0, 0, -1)
end

function v4.ReturnCamera(_, _)
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
end

function v4.SetNight(_, p)
	Client.ColorCorrectionLightingClient.SetBiome("HedgeMaze", true)
	table.insert(p.Debris, function()
		Client.ColorCorrectionLightingClient.SetBiome(Client.BiomesClient.GetCurrentBiome(), true)
	end)
end

function v4.FadeOut(p, p2)
	local blackScreen = localPlayer.PlayerGui.CutsceneGui.BlackScreen
	blackScreen.BackgroundTransparency = 1
	blackScreen.Visible = true
	local tween = TweenService:Create(blackScreen, TweenInfo.new(p.Duration, Enum.EasingStyle.Linear), {
		BackgroundTransparency = 0
	})
	table.insert(p2.Debris, tween)
	tween:Play()
	wait(p.Duration)
end

function v4.FadeIn(p, p2, _)
	local blackScreen = localPlayer.PlayerGui.CutsceneGui.BlackScreen
	blackScreen.BackgroundTransparency = 0
	blackScreen.Visible = true
	local tween = TweenService:Create(blackScreen, TweenInfo.new(p.Duration, Enum.EasingStyle.Linear), {
		BackgroundTransparency = 1
	})
	table.insert(p2.Debris, tween)
	tween:Play()
	wait(p.Duration)
	blackScreen.Visible = false
end

function CutsceneModuleClient.RunAction(p, p2)
	v4[p.Action](p, p2 or {
		Debris = {}
	})
end

task.spawn(function()
	local skipCutsceneFrame = localPlayer.PlayerGui.CutsceneGui.SkipCutsceneFrame
	skipCutsceneFrame.SkipButton.MouseButton1Click:Connect(function()
		CutsceneModuleClient.EndCutscene()
	end)
	ContextActionService:BindActionAtPriority("SkipCutscene", function(_, p, _)
		if not skipCutsceneFrame.Visible or p ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end

		CutsceneModuleClient.EndCutscene()
		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value + 1, Enum.KeyCode.ButtonA, Enum.KeyCode.ButtonB)
end)

function CutsceneModuleClient.IsCutsceneRunning()
	return v ~= nil
end

function CutsceneModuleClient.RunCutscene(value, p)
	if not p.ForceCutscene and localPlayer.Character then
		local mainFire = workspace.Map.Campground.MainFire

		if mainFire:GetAttribute("FuelRemaining") <= 0 then
			print("don't play cutscene unless safe in fire range")
			return
		end

		if ((mainFire:GetPivot().Position - (localPlayer.Character and localPlayer.Character:GetPivot().Position)) * createVector(
			1,
			0,
			1
		)).Magnitude > Client.GlobalSettings.FireOuterZoneSize / 2 then
			print("don't play cutscene unless safe in fire range")
			return
		end
	end

	if v then
		CutsceneModuleClient.EndCutscene()
	end

	local v5

	if type(value) == "string" then
		v5 = v3[value]
	else
		v5 = value
	end

	if type(value) ~= "string" then
		value = false
	end

	v2 = value

	if v5 == nil then
		return
	end

	local v6 = {}

	if p then
		for k, v7 in pairs(p) do
			v6[k] = v7
		end
	end

	v6.Debris = {}
	local model = Instance.new("Model")
	v6.Set = model
	model.Parent = workspace
	v = v6

	if not p.NoSkip then
		localPlayer.PlayerGui.CutsceneGui.SkipCutsceneFrame.Visible = true
	end

	for _, v7 in pairs(v5) do
		if v ~= v6 then
			break
		end

		if v7.Action == "Pause" then
			wait(v7.Duration)
		elseif v4[v7.Action] then
			v4[v7.Action](v7, v6)
		end

		if v7.Callback then
			v7.Callback(v6)
		end
	end

	if v == v6 then
		CutsceneModuleClient.EndCutscene()
	end
end

Client.Events.RunCutscene:Connect(function(...)
	CutsceneModuleClient.RunCutscene(...)
end)

function CutsceneModuleClient.EndCutscene()
	local v5 = v
	v = nil

	for _, tween in pairs(v5.Debris) do
		if type(tween) == "userdata" then
			if tween:IsA("Tween") then
				tween:Pause()
				tween:Destroy()
			end
		elseif type(tween) == "function" then
			tween()
		end
	end

	v5.Set:Destroy()
	localPlayer.PlayerGui.CutsceneGui.BlackScreen.Visible = false
	localPlayer.PlayerGui.CutsceneGui.SkipCutsceneFrame.Visible = false
	Client.Events.CutsceneFinished:FireServer()
	workspace.CurrentCamera.FieldOfView = 70
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom

	if v2 then
		Client.Events.CutsceneComplete:Fire(v2)
	end
end

Client.Events.PreloadCutscene:Connect(function(childName)
	if not childName then
		return
	end

	local child = game.ReplicatedStorage.Assets.CutsceneSets:FindFirstChild(childName)

	if not child then
		return
	end

	if child:FindFirstChild("Animations") then
		print("PRELOAD SUCCESSFUL")
		UtilityAlec.preload(child.Animations:GetChildren())
	end

	if child:FindFirstChild("Sounds") then
		UtilityAlec.preload(child.Sounds:GetChildren())
	end
end)

function CutsceneModuleClient.Init()
	for _, moduleScript in pairs(script.CutsceneSequences:GetChildren()) do
		local v5 = v3
		local name = moduleScript.Name
		local module = require(moduleScript)
		v5[name] = module
	end

	task.spawn(function()
		UtilityAlec.preload(game.ReplicatedStorage.Assets.CutsceneSets.Preload:GetChildren())
		UtilityAlec.preload({ workspace.MusicNORMAL })

		for _, v5 in pairs({ "UpdateCutscene52", "HappyFinalRam" }) do
			local cutsceneSet = ReplicatedStorage.Assets.CutsceneSets[v5]
			UtilityAlec.preload(cutsceneSet.Animations:GetChildren())
			UtilityAlec.preload(cutsceneSet.Sounds:GetChildren())
		end
	end)
end

return CutsceneModuleClient
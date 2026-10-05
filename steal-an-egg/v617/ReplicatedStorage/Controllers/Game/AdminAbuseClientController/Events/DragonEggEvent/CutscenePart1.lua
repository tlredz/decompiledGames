local ContentProvider = game:GetService("ContentProvider")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CutsceneHelperFunctions = require(script.Parent.Parent.Parent.CutsceneHelperFunctions)
require(ReplicatedStorage.Packages.Trove)
local currentCamera = Workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

local function restoreCamera()
	TweenService:Create(currentCamera, TweenInfo.new(0), {
		FieldOfView = 70
	}):Play()
	currentCamera.FieldOfView = 70
	currentCamera.CameraType = Enum.CameraType.Custom
	currentCamera.CameraSubject = localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") or nil
	localPlayer.ReplicationFocus = nil
end

local function cloneCharacterRig(instance)
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if character == nil or humanoid == nil or character.PrimaryPart == nil then
		return nil
	end

	local archivable = character.Archivable
	character.Archivable = true
	local clone = character:Clone()
	character.Archivable = archivable
	clone.Name = instance.Name

	for _, child in ipairs(clone:GetChildren()) do
		if not (child:IsA("LocalScript") or child:IsA("Script") or child:IsA("Tool")) then
			continue
		end

		child:Destroy()
	end

	local humanoid2 = clone:FindFirstChildOfClass("Humanoid")
	assert(humanoid2, "Cloned character lost its Humanoid")
	humanoid2.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

	if humanoid2:FindFirstChildOfClass("Animator") == nil then
		local animator = Instance.new("Animator")
		animator.Parent = humanoid2
	end

	for _, part in ipairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = part == clone.PrimaryPart
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.LocalTransparencyModifier = 0
	end

	local animation = instance:FindFirstChildOfClass("Animation")
	assert(animation, (`{instance.Name} needs an Animation child`))
	local clone_2 = animation:Clone()
	clone_2.Parent = clone
	clone:PivotTo(instance:GetPivot())
	return clone
end

local function hideCharacter(maid)
	local character = localPlayer.Character

	if character == nil then
		return function() end
	end

	local v = {}

	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") then
			v[descendant] = descendant.LocalTransparencyModifier
			descendant.LocalTransparencyModifier = 1
		elseif descendant:IsA("Decal") then
			v[descendant] = descendant.Transparency
			descendant.Transparency = 1
		end
	end

	local function restore()
		for instance, v2 in v do
			if not instance.Parent then
				continue
			end

			if instance:IsA("BasePart") then
				instance.LocalTransparencyModifier = v2
			elseif instance:IsA("Decal") then
				instance.Transparency = v2
			end
		end
	end

	maid:Add(restore)
	return restore
end

return function(maid)
	local helperFunctions = CutsceneHelperFunctions.GetHelperFunctions(maid)
	local setProperty = helperFunctions.SetProperty
	local tweenProperty = helperFunctions.TweenProperty
	local _ = helperFunctions.PlaySequenceAsync
	local loadAnimationIntoRig = helperFunctions.LoadAnimationIntoRig
	local dragonEggEventCutscene1 = ReplicatedStorage.CutsceneAssets.DragonEggEventCutscene1
	local cutsceneUI = localPlayer.PlayerGui.CutsceneUI
	local cutsceneMusic = script.CutsceneMusic
	local black = cutsceneUI.Black
	local v = nil
	local v2 = {
		[0] = {
			setProperty("Workspace.CurrentCamera.FieldOfView", 35),
			tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(1.2666666666666666, Enum.EasingStyle.Linear),
				80.84581
			),
			setProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.LeftDoor.Meshes/untitled2_Walls102.CFrame",
				CFrame.new(3526.5938, 86.4341, -373.0499, 0, 0, 1, 0, 1, -0, -1, 0, 0)
			),
			tweenProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.LeftDoor.Meshes/untitled2_Walls102.CFrame",
				TweenInfo.new(5.35, Enum.EasingStyle.Linear),
				CFrame.new(3514.3865, 86.4341, -383.3008, 0.9781, 0, 0.2079, 0, 1, 0, -0.2079, 0, 0.9781)
			),
			setProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.LeftDoor.Meshes/untitled_Walls100 (2).CFrame",
				CFrame.new(3527.27, 90.0758, -374.963, -0, 0, 1, 0, 1, 0, -1, 0, -0)
			),
			tweenProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.LeftDoor.Meshes/untitled_Walls100 (2).CFrame",
				TweenInfo.new(5.35, Enum.EasingStyle.Linear),
				CFrame.new(3516.3984, 90.0758, -383.037, 0.9781, 0, 0.2079, 0, 1, 0, -0.2079, 0, 0.9781)
			),
			setProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.LeftDoor.Meshes/untitled_Walls103.CFrame",
				CFrame.new(3526.6228, 84.8732, -373.5785, -0, 0, 1, 0, 1, 0, -1, 0, -0)
			),
			tweenProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.LeftDoor.Meshes/untitled_Walls103.CFrame",
				TweenInfo.new(5.35, Enum.EasingStyle.Linear),
				CFrame.new(3514.9097, 84.8732, -383.3822, 0.9781, 0, 0.2079, 0, 1, 0, -0.2079, 0, 0.9781)
			),
			setProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.LeftDoor.Meshes/untitled_Walls104.CFrame",
				CFrame.new(3526.4937, 86.4515, -369.8316, -0, 0, 1, 0, 1, 0, -1, 0, -0)
			),
			tweenProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.LeftDoor.Meshes/untitled_Walls104.CFrame",
				TweenInfo.new(5.35, Enum.EasingStyle.Linear),
				CFrame.new(3511.2178, 86.4515, -382.7296, 0.9781, 0, 0.2079, 0, 1, 0, -0.2079, 0, 0.9781)
			),
			setProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.LeftDoor.Meshes/untitled_Walls105.CFrame",
				CFrame.new(3526.3276, 86.4762, -364.6917, -0, 0, 1, 0, 1, 0, -1, 0, -0)
			),
			tweenProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.LeftDoor.Meshes/untitled_Walls105.CFrame",
				TweenInfo.new(5.35, Enum.EasingStyle.Linear),
				CFrame.new(3506.1558, 86.4762, -381.8233, 0.9781, 0, 0.2079, 0, 1, 0, -0.2079, 0, 0.9781)
			),
			setProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.LeftDoor.Meshes/untitled_Walls106.CFrame",
				CFrame.new(3526.365, 88.1662, -374.3624, -0, 0, 1, 0, 1, 0, -1, 0, -0)
			),
			tweenProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.LeftDoor.Meshes/untitled_Walls106.CFrame",
				TweenInfo.new(5.35, Enum.EasingStyle.Linear),
				CFrame.new(3515.6228, 88.1662, -383.7974, 0.9781, 0, 0.2079, 0, 1, 0, -0.2079, 0, 0.9781)
			),
			setProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.LeftDoor.Meshes/untitled_Walls107.CFrame",
				CFrame.new(3526.3193, 89.4656, -369.1417, -0, 0, 1, 0, 1, 0, -1, 0, -0)
			),
			tweenProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.LeftDoor.Meshes/untitled_Walls107.CFrame",
				TweenInfo.new(5.35, Enum.EasingStyle.Linear),
				CFrame.new(3510.5066, 89.4656, -382.7566, 0.9781, 0, 0.2079, 0, 1, 0, -0.2079, 0, 0.9781)
			),
			setProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.RightDoor.right1.CFrame",
				CFrame.new(3526.5938, 86.4341, -355.3767, 0, 0, 1, 0, 1, -0, -1, 0, 0)
			),
			tweenProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.RightDoor.right1.CFrame",
				TweenInfo.new(5.35, Enum.EasingStyle.Linear),
				CFrame.new(3514.4778, 86.4341, -345.5578, -0.9703, 0, 0.2419, 0, 1, 0, -0.2419, 0, -0.9703)
			),
			setProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.RightDoor.right2.CFrame",
				CFrame.new(3527.27, 90.0758, -353.463, -0, 0, 1, 0, 1, 0, -1, 0, -0)
			),
			tweenProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.RightDoor.right2.CFrame",
				TweenInfo.new(5.35, Enum.EasingStyle.Linear),
				CFrame.new(3516.4983, 90.0758, -345.751, -0.9703, 0, 0.2419, 0, 1, 0, -0.2419, 0, -0.9703)
			),
			setProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.RightDoor.right3.CFrame",
				CFrame.new(3526.6228, 84.8732, -354.8475, -0, 0, 1, 0, 1, 0, -1, 0, -0)
			),
			tweenProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.RightDoor.right3.CFrame",
				TweenInfo.new(5.35, Enum.EasingStyle.Linear),
				CFrame.new(3514.9985, 84.8732, -345.458, -0.9703, 0, 0.2419, 0, 1, 0, -0.2419, 0, -0.9703)
			),
			setProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.RightDoor.right4.CFrame",
				CFrame.new(3526.4937, 86.4515, -358.5941, -0, 0, 1, 0, 1, 0, -1, 0, -0)
			),
			tweenProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.RightDoor.right4.CFrame",
				TweenInfo.new(5.35, Enum.EasingStyle.Linear),
				CFrame.new(3511.3318, 86.4515, -346.2393, -0.9703, 0, 0.2419, 0, 1, 0, -0.2419, 0, -0.9703)
			),
			setProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.RightDoor.right5.CFrame",
				CFrame.new(3526.3276, 86.4762, -363.7342, -0, 0, 1, 0, 1, 0, -1, 0, -0)
			),
			tweenProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.RightDoor.right5.CFrame",
				TweenInfo.new(5.35, Enum.EasingStyle.Linear),
				CFrame.new(3506.3042, 86.4762, -347.3215, -0.9703, 0, 0.2419, 0, 1, 0, -0.2419, 0, -0.9703)
			),
			setProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.RightDoor.right6.CFrame",
				CFrame.new(3526.365, 88.1662, -354.0636, -0, 0, 1, 0, 1, 0, -1, 0, -0)
			),
			tweenProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.RightDoor.right6.CFrame",
				TweenInfo.new(5.35, Enum.EasingStyle.Linear),
				CFrame.new(3515.6965, 88.1662, -345.0182, -0.9703, 0, 0.2419, 0, 1, 0, -0.2419, 0, -0.9703)
			),
			setProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.RightDoor.right7.CFrame",
				CFrame.new(3526.3193, 89.4657, -359.2843, -0, 0, 1, 0, 1, 0, -1, 0, -0)
			),
			tweenProperty(
				"Workspace.World.Build.AAEventProps.DragonCave.Door.RightDoor.right7.CFrame",
				TweenInfo.new(5.35, Enum.EasingStyle.Linear),
				CFrame.new(3510.6201, 89.4657, -346.237, -0.9703, 0, 0.2419, 0, 1, 0, -0.2419, 0, -0.9703)
			),
			function()
				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function check(p: number?)
					return p ~= nil and p ~= 0
				end

				for _, emitter in v.DoorOpenSmoke:GetDescendants() do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local emitCount = emitter:GetAttribute("EmitCount")
					local emitDuration = emitter:GetAttribute("EmitDuration")

					if check(emitCount) then
						emitter:Emit(emitCount)
					end

					if not check(emitDuration) then
						continue
					end

					emitter.Enabled = true
					local v5 = emitter
					task.delay(emitDuration, function()
						v5.Enabled = false
					end)
				end
			end,
			setProperty("Lighting.dragondepth.Enabled", false),
			setProperty("Lighting.dragondepth.InFocusRadius", 20),
			setProperty("Workspace.DragonEggEventCutscene1.cutscene1egg.Highlight.Enabled", false),
			setProperty("Workspace.DragonEggEventCutscene1.cutscene1egg.Highlight.FillTransparency", 0.5),
			tweenProperty(
				"Workspace.DragonEggEventCutscene1.cutscene1egg.Highlight.FillTransparency",
				TweenInfo.new(7.583333333333333, Enum.EasingStyle.Linear),
				1
			),
			setProperty("Workspace.DragonEggEventCutscene1.cutscene1egg.Highlight.OutlineTransparency", 0),
			tweenProperty(
				"Workspace.DragonEggEventCutscene1.cutscene1egg.Highlight.OutlineTransparency",
				TweenInfo.new(7.583333333333333, Enum.EasingStyle.Linear),
				1
			),
			setProperty("Lighting.ThirdPoV.Enabled", false),
			setProperty("Lighting.ThirdPoV.InFocusRadius", 50),
			setProperty("Lighting.ThirdPoV.FocusDistance", 200),
			setProperty("Lighting.1.Enabled", true),
			setProperty("Lighting.1.InFocusRadius", 50),
			setProperty("Lighting.1.FocusDistance", 25),
			setProperty(
				"Workspace.CutsceneVFX.Fly.CFrame",
				CFrame.new(3632.9419, 20.3041, -371.646, -0.1736, 0, 0.9848, 0, 1, 0, -0.9848, 0, -0.1736)
			),
			setProperty(
				"Workspace.CutsceneVFX.Charge.CFrame",
				CFrame.new(3407.4592, 101.738, -375.0436, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			),
			setProperty(
				"Workspace.CutsceneVFX.Wave.CFrame",
				CFrame.new(3395.644, -3.5316, -364.8042, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			),
			setProperty("Lighting.CutsceneBlur.Enabled", true),
			setProperty("Lighting.CutsceneBlur.Size", 2),
			setProperty("Lighting.BLACK.Enabled", false),
			setProperty("Lighting.WHITE.Enabled", false),
			setProperty("Lighting.Black+White.Enabled", false),
			setProperty("Lighting.White+Black.Enabled", false),
			setProperty("Lighting.red.Enabled", false),
			setProperty("Lighting.Whitered.Enabled", false),
			setProperty("Lighting.Whitered.Saturation", -1.1),
			tweenProperty("Lighting.Whitered.Saturation", TweenInfo.new(49.38333333333333, Enum.EasingStyle.Linear), 0),
			setProperty("Lighting.Whitered.Contrast", -1000000),
			tweenProperty("Lighting.Whitered.Contrast", TweenInfo.new(49.38333333333333, Enum.EasingStyle.Linear), 0),
			setProperty("Lighting.Whitered.TintColor", Color3.new(1, 1, 1)),
			setProperty("Lighting.Whitered.Brightness", 0)
		},
		[76] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Linear),
				80.64736
			) },
		[82] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Linear),
				80.46038
			) },
		[88] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Linear),
				80.22632
			) },
		[94] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Linear),
				79.80621
			) },
		[100] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Linear),
				78.99367
			) },
		[106] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Linear),
				77.62277
			) },
		[112] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Linear),
				75.68993
			) },
		[118] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Linear),
				73.3545
			) },
		[124] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Linear),
				70.81742
			) },
		[130] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Linear),
				68.21306
			) },
		[136] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Linear),
				65.59524
			) },
		[142] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(1.2, Enum.EasingStyle.Linear),
				34.16667
			) },
		[214] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Linear),
				31.56664
			) },
		[220] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Linear),
				29.09974
			) },
		[226] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Linear),
				27.03225
			) },
		[232] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Linear),
				25.63041
			) },
		[238] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.05, Enum.EasingStyle.Linear),
				25.26233
			) },
		[241] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Linear),
				24.72586
			) },
		[247] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Linear),
				24.47468
			) },
		[253] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.05, Enum.EasingStyle.Linear),
				24.3586
			) },
		[256] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.05, Enum.EasingStyle.Linear),
				24.26451
			) },
		[259] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Linear),
				24.07752
			) },
		[265] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Linear),
				23.94988
			) },
		[271] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Linear),
				23.84164
			) },
		[277] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Linear),
				23.7417
			) },
		[283] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.13333333333333333, Enum.EasingStyle.Linear),
				23.61215
			) },
		[291] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Linear),
				23.50904
			) },
		[297] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.05, Enum.EasingStyle.Linear),
				23.45451
			) },
		[300] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.05, Enum.EasingStyle.Linear),
				23.39405
			) },
		[303] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Linear),
				23.16991
			) },
		[309] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Linear),
				22.78801
			) },
		[315] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				22.7113
			) },
		[316] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.05, Enum.EasingStyle.Linear),
				22.47363
			) },
		[319] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Linear),
				21.96249
			) },
		[325] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.06666666666666667, Enum.EasingStyle.Linear),
				21.60656
			) },
		[329] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.3, Enum.EasingStyle.Linear),
				20
			) },
		[365] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(1.4166666666666667, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				15.9003
			) },
		[450] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				13.47454
			) },
		[455] = {
			setProperty("Workspace.DragonEggEventCutscene1.cutscene1egg.Highlight.Enabled", true),
			tweenProperty(
				"Workspace.DragonEggEventCutscene1.cutscene1egg.Highlight.FillTransparency",
				TweenInfo.new(0.15, Enum.EasingStyle.Linear),
				0.4
			),
			tweenProperty(
				"Workspace.DragonEggEventCutscene1.cutscene1egg.Highlight.OutlineTransparency",
				TweenInfo.new(0.15, Enum.EasingStyle.Linear),
				0
			)
		},
		[456] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.05, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				12.3416
			) },
		[459] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.05, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				11.20867
			) },
		[462] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.05, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				10.54439
			) },
		[464] = { function()
				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function check(p: number?)
					return p ~= nil and p ~= 0
				end

				for _, emitter in v.Shimmer:GetDescendants() do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local emitCount = emitter:GetAttribute("EmitCount")
					local emitDuration = emitter:GetAttribute("EmitDuration")

					if check(emitCount) then
						emitter:Emit(emitCount)
					end

					if not check(emitDuration) then
						continue
					end

					emitter.Enabled = true
					local v5 = emitter
					task.delay(emitDuration, function()
						v5.Enabled = false
					end)
				end
			end, tweenProperty(
				"Workspace.DragonEggEventCutscene1.cutscene1egg.Highlight.FillTransparency",
				TweenInfo.new(0.21666666666666667, Enum.EasingStyle.Linear),
				1
			), tweenProperty(
				"Workspace.DragonEggEventCutscene1.cutscene1egg.Highlight.OutlineTransparency",
				TweenInfo.new(0.21666666666666667, Enum.EasingStyle.Linear),
				1
			) },
		[465] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				9.65424
			) },
		[471] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.05, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				9.47588
			) },
		[474] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				9.19042
			) },
		[477] = { setProperty("Workspace.DragonEggEventCutscene1.cutscene1egg.Highlight.Enabled", false) },
		[480] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				9
			) },
		[486] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				8
			) },
		[522] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				40
			) },
		[523] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(2.216666666666667, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				45
			) },
		[670] = { function()
				local ZZZ = v:WaitForChild("ZZZ")

				for _, emitter in ipairs(ZZZ:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end },
		[721] = { setProperty("Lighting.ThirdPoV.Enabled", true) },
		[780] = { tweenProperty(
				"Lighting.ThirdPoV.FocusDistance",
				TweenInfo.new(0.38333333333333336, Enum.EasingStyle.Linear),
				0
			) },
		[858] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				25
			) },
		[859] = { setProperty("Lighting.ThirdPoV.Enabled", false) },
		[1264] = { setProperty("Lighting.dragondepth.Enabled", true), setProperty("Lighting.1.Enabled", false) },
		[1376] = { tweenProperty(
				"Lighting.dragondepth.InFocusRadius",
				TweenInfo.new(2.033333333333333, Enum.EasingStyle.Linear),
				13
			) },
		[1571] = { function()
				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function check(p: number?)
					return p ~= nil and p ~= 0
				end

				for _, emitter in v.Mud:GetDescendants() do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local emitCount = emitter:GetAttribute("EmitCount")
					local emitDuration = emitter:GetAttribute("EmitDuration")

					if check(emitCount) then
						emitter:Emit(emitCount)
					end

					if not check(emitDuration) then
						continue
					end

					emitter.Enabled = true
					local v5 = emitter
					task.delay(emitDuration, function()
						v5.Enabled = false
					end)
				end
			end },
		[1573] = { tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(0.9666666666666667, Enum.EasingStyle.Linear),
				0.5
			) },
		[1576] = { function()
				local ZZZ = v:WaitForChild("ZZZ")

				for _, emitter in ipairs(ZZZ:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end },
		[1590] = { tweenProperty(
				"Lighting.dragondepth.InFocusRadius",
				TweenInfo.new(0.7166666666666667, Enum.EasingStyle.Linear),
				50
			) },
		[1686] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(3.533333333333333, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				40
			) },
		[1807] = { tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(1.5333333333333334, Enum.EasingStyle.Linear),
				0
			) },
		[1898] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				15
			) },
		[1899] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(4.05, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				25
			) },
		[1929] = { function()
				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function check(p: number?)
					return p ~= nil and p ~= 0
				end

				for _, emitter in v.Takeoff:GetDescendants() do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local emitCount = emitter:GetAttribute("EmitCount")
					local emitDuration = emitter:GetAttribute("EmitDuration")

					if check(emitCount) then
						emitter:Emit(emitCount)
					end

					if not check(emitDuration) then
						continue
					end

					emitter.Enabled = true
					local v5 = emitter
					task.delay(emitDuration, function()
						v5.Enabled = false
					end)
				end
			end },
		[2120] = { function()
				local fly = v:WaitForChild("Fly")

				for _, emitter in ipairs(fly:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end },
		[2130] = { tweenProperty(
				"Workspace.CutsceneVFX.Fly.CFrame",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				CFrame.new(3632.9526, 76.9216, -371.6479, -0.1736, 0, 0.9848, 0, 1, 0, -0.9848, 0, -0.1736)
			) },
		[2131] = { tweenProperty(
				"Workspace.CutsceneVFX.Fly.CFrame",
				TweenInfo.new(0.06666666666666667, Enum.EasingStyle.Linear),
				CFrame.new(3610.0322, 76.9216, -367.6064, -0.1736, 0, 0.9848, 0, 1, 0, -0.9848, 0, -0.1736)
			) },
		[2135] = {
			tweenProperty(
				"Workspace.CutsceneVFX.Fly.CFrame",
				TweenInfo.new(0.05, Enum.EasingStyle.Linear),
				CFrame.new(3582.1382, 76.9216, -364.7979, -0.1736, 0, 0.9848, 0, 1, 0, -0.9848, 0, -0.1736)
			),
			setProperty("Lighting.White+Black.Enabled", true)
		},
		[2137] = {
			setProperty("Lighting.Black+White.Enabled", true),
			setProperty("Lighting.White+Black.Enabled", false)
		},
		[2138] = { tweenProperty(
				"Workspace.CutsceneVFX.Fly.CFrame",
				TweenInfo.new(0.05, Enum.EasingStyle.Linear),
				CFrame.new(3554.259, 76.9216, -363.7752, -0.0367, 0, 0.9993, 0, 1, 0, -0.9993, 0, -0.0367)
			) },
		[2139] = { setProperty("Lighting.Black+White.Enabled", false), setProperty("Lighting.red.Enabled", true) },
		[2141] = {
			tweenProperty(
				"Workspace.CutsceneVFX.Fly.CFrame",
				TweenInfo.new(0.15, Enum.EasingStyle.Linear),
				CFrame.new(3535.5564, 76.9216, -363.0892, -0.0367, 0, 0.9993, 0, 1, 0, -0.9993, 0, -0.0367)
			),
			setProperty("Lighting.red.Enabled", false)
		},
		[2142] = {
			tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(2.466666666666667, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				22
			),
			function()
				local fly = v:WaitForChild("Fly")

				for _, emitter in ipairs(fly:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end
		},
		[2181] = { function()
				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function check(p: number?)
					return p ~= nil and p ~= 0
				end

				for _, emitter in v.EggDrop:GetDescendants() do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local emitCount = emitter:GetAttribute("EmitCount")
					local emitDuration = emitter:GetAttribute("EmitDuration")

					if check(emitCount) then
						emitter:Emit(emitCount)
					end

					if not check(emitDuration) then
						continue
					end

					emitter.Enabled = true
					local v5 = emitter
					task.delay(emitDuration, function()
						v5.Enabled = false
					end)
				end
			end },
		[2290] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(9.933333333333334, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				28
			) },
		[2344] = { tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(0.75, Enum.EasingStyle.Linear),
				0.4
			) },
		[2357] = { tweenProperty(
				"Lighting.dragondepth.InFocusRadius",
				TweenInfo.new(1, Enum.EasingStyle.Linear),
				250
			) },
		[2389] = { tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(5.933333333333334, Enum.EasingStyle.Linear),
				0.4
			) },
		[2417] = { tweenProperty(
				"Lighting.dragondepth.InFocusRadius",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				20
			) },
		[2568] = { tweenProperty(
				"Lighting.dragondepth.InFocusRadius",
				TweenInfo.new(1.2333333333333334, Enum.EasingStyle.Linear),
				300
			) },
		[2635] = { setProperty("Lighting.White+Black.Enabled", true) },
		[2637] = { function()
				local charge = v:WaitForChild("Charge")

				for _, emitter in ipairs(charge:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end, setProperty("Lighting.Black+White.Enabled", true), setProperty("Lighting.White+Black.Enabled", false) },
		[2639] = {
			setProperty("Lighting.Black+White.Enabled", false),
			setProperty("Lighting.White+Black.Enabled", true)
		},
		[2641] = { setProperty("Lighting.White+Black.Enabled", false), setProperty("Lighting.red.Enabled", true) },
		[2643] = { setProperty("Lighting.red.Enabled", false) },
		[2647] = { tweenProperty(
				"Workspace.CutsceneVFX.Charge.CFrame",
				TweenInfo.new(1.9666666666666666, Enum.EasingStyle.Linear),
				CFrame.new(3403.1526, 101.738, -375.0436, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			) },
		[2745] = { tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(1.4333333333333333, Enum.EasingStyle.Linear),
				1
			) },
		[2766] = { tweenProperty(
				"Workspace.CutsceneVFX.Wave.CFrame",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				CFrame.new(3395.645, 87.3247, -364.8042, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			) },
		[2767] = { tweenProperty(
				"Workspace.CutsceneVFX.Wave.CFrame",
				TweenInfo.new(1.9833333333333334, Enum.EasingStyle.Linear),
				CFrame.new(3305.9136, 87.3247, -364.8042, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			) },
		[2886] = {
			function()
				local charge = v:WaitForChild("Charge")

				for _, emitter in ipairs(charge:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end,
			tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				0.5
			),
			tweenProperty(
				"Workspace.CutsceneVFX.Wave.CFrame",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				CFrame.new(3459.4167, 87.3247, -358.4828, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			),
			tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(5.983333333333333, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				15
			)
		},
		[2887] = { tweenProperty(
				"Workspace.CutsceneVFX.Wave.CFrame",
				TweenInfo.new(1.5, Enum.EasingStyle.Linear),
				CFrame.new(3375.6699, 87.3247, -358.4828, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			) },
		[2948] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.48333333333333334, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				10
			) },
		[2963] = {
			setProperty("Lighting.Whitered.Enabled", true),
			tweenProperty(
				"Lighting.Whitered.Saturation",
				TweenInfo.new(0.23333333333333334, Enum.EasingStyle.Linear),
				-1.1
			),
			tweenProperty("Lighting.Whitered.Contrast", TweenInfo.new(0.23333333333333334, Enum.EasingStyle.Linear), 25),
			tweenProperty(
				"Lighting.Whitered.TintColor",
				TweenInfo.new(0.23333333333333334, Enum.EasingStyle.Linear),
				Color3.new(1, 0.173412, 0.0980392)
			),
			tweenProperty("Lighting.Whitered.Brightness", TweenInfo.new(0.1, Enum.EasingStyle.Linear), 2)
		},
		[2969] = { tweenProperty(
				"Lighting.Whitered.Brightness",
				TweenInfo.new(0.13333333333333333, Enum.EasingStyle.Linear),
				15
			) },
		[2977] = {
			tweenProperty(
				"Workspace.CutsceneVFX.Wave.CFrame",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				CFrame.new(2920.835, 87.3247, -358.4828, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			),
			tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				2
			),
			tweenProperty("Lighting.Whitered.Saturation", TweenInfo.new(1.8, Enum.EasingStyle.Linear), 0),
			tweenProperty("Lighting.Whitered.Contrast", TweenInfo.new(1.8, Enum.EasingStyle.Linear), 0),
			tweenProperty(
				"Lighting.Whitered.TintColor",
				TweenInfo.new(1.8, Enum.EasingStyle.Linear),
				Color3.new(1, 1, 1)
			),
			tweenProperty("Lighting.Whitered.Brightness", TweenInfo.new(1.8, Enum.EasingStyle.Linear), 0)
		},
		[2978] = {
			tweenProperty(
				"Workspace.CutsceneVFX.Wave.CFrame",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				CFrame.new(2920.835, 87.3247, -369.4669, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			),
			setProperty("Lighting.Whitered.Enabled", false)
		},
		[2979] = { tweenProperty(
				"Workspace.CutsceneVFX.Wave.CFrame",
				TweenInfo.new(2, Enum.EasingStyle.Linear),
				CFrame.new(2570.1248, 87.3247, -369.4669, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			) },
		[3071] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.4666666666666667, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				10
			) },
		[3085] = {
			setProperty("Lighting.Whitered.Enabled", true),
			tweenProperty(
				"Lighting.Whitered.Saturation",
				TweenInfo.new(0.23333333333333334, Enum.EasingStyle.Linear),
				-1.1
			),
			tweenProperty("Lighting.Whitered.Contrast", TweenInfo.new(0.23333333333333334, Enum.EasingStyle.Linear), 25),
			tweenProperty(
				"Lighting.Whitered.TintColor",
				TweenInfo.new(0.23333333333333334, Enum.EasingStyle.Linear),
				Color3.new(1, 0.173412, 0.0980392)
			),
			tweenProperty("Lighting.Whitered.Brightness", TweenInfo.new(0.1, Enum.EasingStyle.Linear), 2)
		},
		[3091] = { tweenProperty(
				"Lighting.Whitered.Brightness",
				TweenInfo.new(0.13333333333333333, Enum.EasingStyle.Linear),
				15
			) },
		[3099] = {
			tweenProperty(
				"Workspace.CutsceneVFX.Wave.CFrame",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				CFrame.new(2512.0125, 87.3247, -369.4669, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			),
			tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				2
			),
			tweenProperty("Lighting.Whitered.Saturation", TweenInfo.new(2.1666666666666665, Enum.EasingStyle.Linear), 0),
			tweenProperty("Lighting.Whitered.Contrast", TweenInfo.new(2.1666666666666665, Enum.EasingStyle.Linear), 0),
			tweenProperty(
				"Lighting.Whitered.TintColor",
				TweenInfo.new(2.1666666666666665, Enum.EasingStyle.Linear),
				Color3.new(1, 1, 1)
			),
			tweenProperty("Lighting.Whitered.Brightness", TweenInfo.new(2.1666666666666665, Enum.EasingStyle.Linear), 0)
		},
		[3100] = {
			tweenProperty(
				"Workspace.CutsceneVFX.Wave.CFrame",
				TweenInfo.new(2.4, Enum.EasingStyle.Linear),
				CFrame.new(2172.207, 87.3247, -364.1021, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			),
			setProperty("Lighting.Whitered.Enabled", false)
		},
		[3106] = { tweenProperty(
				"Lighting.dragondepth.InFocusRadius",
				TweenInfo.new(1.9333333333333333, Enum.EasingStyle.Linear),
				13
			) },
		[3200] = { function()
				black.Visible = true
				black.BackgroundTransparency = 1
				TweenService:Create(black, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
					BackgroundTransparency = 0
				}):Play()
				task.delay(2, function()
					TweenService:Create(black, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
						BackgroundTransparency = 1
					}):Play()
					task.wait(0.5)
					black.Visible = false
				end)
			end },
		[3229] = {
			setProperty("Lighting.Whitered.Enabled", true),
			tweenProperty(
				"Lighting.Whitered.Saturation",
				TweenInfo.new(0.23333333333333334, Enum.EasingStyle.Linear),
				-1.1
			),
			tweenProperty("Lighting.Whitered.Contrast", TweenInfo.new(0.23333333333333334, Enum.EasingStyle.Linear), 25),
			tweenProperty(
				"Lighting.Whitered.TintColor",
				TweenInfo.new(0.23333333333333334, Enum.EasingStyle.Linear),
				Color3.new(1, 0.173412, 0.0980392)
			),
			tweenProperty("Lighting.Whitered.Brightness", TweenInfo.new(0.1, Enum.EasingStyle.Linear), 2)
		},
		[3234] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.13333333333333333, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				30
			) },
		[3235] = { tweenProperty(
				"Lighting.Whitered.Brightness",
				TweenInfo.new(0.13333333333333333, Enum.EasingStyle.Linear),
				15
			) }
	}
	return {
		Run = function()
			Workspace.World.Build:WaitForChild("AAEventProps")
			local clones = {}

			for _, child in script.LightingAssets:GetChildren() do
				if Lighting:FindFirstChild(child.Name) then
					continue
				end

				local clone = child:Clone()
				clone.Parent = Lighting
				maid:Add(clone)
				table.insert(clones, clone)
			end

			cutsceneUI.Enabled = true
			black.BackgroundTransparency = 1
			black.Visible = true
			local clone = script.CutsceneVFX:Clone()
			clone.Parent = Workspace
			v = clone
			maid:Add(clone)
			TweenService:Create(black, TweenInfo.new(0.1), {
				BackgroundTransparency = 0
			}):Play()
			maid:Add(function()
				black.BackgroundTransparency = 1
				black.Visible = false
			end)
			local clone2 = dragonEggEventCutscene1:Clone()

			for _, model in clone2:GetChildren() do
				if model:IsA("Model") and model.PrimaryPart then
					model.PrimaryPart.Anchored = true
				end
			end

			local v3 = hideCharacter(maid)
			clone2.Parent = workspace
			maid:Add(clone2)
			local animations = {}

			for _, child in clone2:GetChildren() do
				local animation = child:FindFirstChildOfClass("Animation")

				if animation then
					table.insert(animations, animation)
				end
			end

			ContentProvider:PreloadAsync(animations)
			local v4 = {}

			for _, child in clone2:GetChildren() do
				local animation = child:FindFirstChildOfClass("Animation")

				if animation then
					v4[child] = loadAnimationIntoRig(child, animation.AnimationId)
				end
			end

			local v5 = true
			maid:Add(function()
				v5 = false
			end)
			maid:Add(function()
				if not v5 then
					return
				end

				restoreCamera()
			end)

			for _, v6 in v4 do
				v6:Play(0)
			end

			local v6 = v4[clone2["Camera Rig"]]
			assert(v6, "Camera Rig needs an Animation")
			local v7 = os.clock() + 2

			while v5 and v6.TimePosition <= 0 and os.clock() < v7 do
				RunService.RenderStepped:Wait()
			end

			local vignette = cutsceneUI.Vignette
			vignette.Visible = true
			vignette.ImageTransparency = 0.1
			TweenService:Create(vignette, TweenInfo.new(10, Enum.EasingStyle.Linear), {
				ImageTransparency = 1
			}):Play()
			task.delay(10, function() end)
			maid:Add(function()
				vignette.Visible = false
				vignette.ImageTransparency = 1
			end)
			TweenService:Create(black, TweenInfo.new(0.3), {
				BackgroundTransparency = 1
			}):Play()
			task.delay(0.3, function()
				black.Visible = false
			end)
			cutsceneMusic:Play()
			local cam = clone2["Camera Rig"].Cam
			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if not v5 then
					renderSteppedConnection:Disconnect()
					return
				end

				currentCamera.CameraType = Enum.CameraType.Scriptable
				localPlayer.ReplicationFocus = cam
				currentCamera.Focus = cam.CFrame
				currentCamera.CFrame = cam.CFrame
			end)
			local v8 = {}
			local total = 0
			local v9 = 0.1
			local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				total += dt
				v9 -= 0.1

				if v9 <= 0 then
					v9 = 0.1

					for _, v10 in v4 do
						if not (v10.IsPlaying and math.abs(total - v10.TimePosition) >= 0.1) then
							continue
						end

						local v11 = v10
						xpcall(function()
							v11.TimePosition = total
						end, warn)
					end
				end

				if cutsceneMusic.TimePosition < total - 0.001 then
					cutsceneMusic.PlaybackSpeed = 1.01
				else
					local timePosition = cutsceneMusic.TimePosition

					if total + 0.001 < timePosition then
						cutsceneMusic.PlaybackSpeed = 0.99
					else
						cutsceneMusic.PlaybackSpeed = 1
					end
				end

				for i = 0, 9 do
					local v10 = math.floor(total * 60 - i)

					if not v2[v10] or v8[v10] then
						continue
					end

					v8[v10] = true

					for _, callback in v2[v10] do
						task.spawn(callback)
					end
				end
			end)
			maid:Add(heartbeatConnection)
			task.wait(55.083333333333336)
			heartbeatConnection:Disconnect()
			xpcall(function()
				clone:Destroy()
			end, warn)
			v5 = false
			vignette.Visible = false
			xpcall(function()
				for _, v10 in clones do
					v10:Destroy()
				end
			end, warn)
			xpcall(function()
				clone2:Destroy()
			end, warn)
			xpcall(restoreCamera, warn)
			v3()
			pcall(function()
				task.spawn(function()
					TweenService:Create(Workspace:WaitForChild("DragonEggEventMusic", 15), TweenInfo.new(1), {
						Volume = 0.5
					}):Play()
				end)
			end)
		end
	}
end
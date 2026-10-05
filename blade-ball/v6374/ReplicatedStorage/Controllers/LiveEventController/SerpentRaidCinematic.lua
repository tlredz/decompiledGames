local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local v = require3(ReplicatedStorage2.Controllers.CinematicController)
local v2 = require3(ReplicatedStorage2.Controllers.UI.DialogueController)
local v3 = require3(ReplicatedStorage2.Common.Utils)
local localPlayer = Players.LocalPlayer
local v4 = {
	Intro1 = {
		Title = "World Serpent",
		Text = "A mere speck in existence dares to challenge me? You trespass in my domain.",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEventPart2_Phase1_VA1",
		Duration = 14.5
	},
	Intro2 = {
		Title = "World Serpent",
		Text = "I hope you brought worthy warriors.",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEventPart2_Phase1_VA2",
		Duration = 4
	},
	Intro3 = {
		Title = "World Serpent",
		Text = "Pay with your lives!",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEventPart2_Phase1_VA3",
		Duration = 2.25
	},
	Phase2A = {
		Title = "World Serpent",
		Text = "You think your tiny collection of warriors will do anything to me!?",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEventPart2_Phase2_VA1",
		Duration = 7
	},
	Phase2B = {
		Title = "World Serpent",
		Text = "You fools! You do not know what you are doing!",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEventPart2_Phase2_VA2",
		Duration = 4.75
	},
	Phase3 = {
		Title = "World Serpent",
		Text = "Your arrogance will be your downfall. This ends now!",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEventPart2_Phase3_VA1",
		Duration = 7.25
	},
	Phase4A = {
		Title = "World Serpent",
		Text = "Your struggle amuses me, but now it ends.",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEventPart2_Phase4_VA1",
		Duration = 6
	},
	Phase4B = {
		Title = "World Serpent",
		Text = "The worthy have proven themselves. I acknowledge your strength.",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEventPart2_Phase4_VA2",
		Duration = 6.25
	},
	Death = {
		Title = "World Serpent",
		Text = "You are not as insignificant as I thought. I grant you my respect.",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEventPart2_Death_VA1",
		Duration = 9.25
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function sendDialogue(p: string)
	local v5 = v4[p]

	if v5 then
		v2:SendText(v5)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playSound(p: string, folder)
	local ATTACK_ATTACHMENT = folder and (folder:FindFirstChild("ATTACK_ATTACHMENT", true) or folder.PrimaryPart)
	v3.Sounds:Play(p, ATTACK_ATTACHMENT)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playSection(child)
	if not child then
		return
	end

	local cinematicFromConfiguration = v:CreateCinematicFromConfiguration(child)

	if cinematicFromConfiguration and cinematicFromConfiguration.Removed then
		cinematicFromConfiguration.Removed:Wait()
	end
end

local function playSequence(instance, items)
	if not instance then
		return
	end

	for _, childName in items do
		playSection(instance:FindFirstChild(childName)) -- equivalent call inferred; original call site unknown
	end
end

local function getBlackout()
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local serpentRaidBlackout = playerGui:FindFirstChild("SerpentRaidBlackout")

	if serpentRaidBlackout and serpentRaidBlackout:IsA("ScreenGui") then
		local frame = serpentRaidBlackout:FindFirstChild("Frame")

		if frame and frame:IsA("Frame") then
			return serpentRaidBlackout, frame
		else
			serpentRaidBlackout:Destroy()
		end
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SerpentRaidBlackout"
	screenGui.DisplayOrder = 1000
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
	local frame = Instance.new("Frame")
	frame.Name = "Frame"
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	return screenGui, frame
end

local function fadeBlackout(backgroundTransparency: number, duration: number, flag: boolean?)
	local blackout, v5 = getBlackout()
	local tween = TweenService:Create(v5, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = backgroundTransparency
	})
	tween:Play()
	tween.Completed:Wait()

	if flag then
		blackout:Destroy()
	end
end

local function emitMouthEffects(folder)
	if not folder then
		return
	end

	local ATTACK_ATTACHMENT = folder:FindFirstChild("ATTACK_ATTACHMENT", true)

	if not ATTACK_ATTACHMENT then
		return
	end

	for _, emitter in ATTACK_ATTACHMENT.Parent:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 12)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resetCamera()
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		currentCamera.FieldOfView = 70
	end

	v:Reset()
end

local function runStage(p: string, folder, instance)
	local currentCamera = workspace.CurrentCamera

	if p == "Intro" then
		local _, v5 = getBlackout()
		v5.BackgroundTransparency = 0
		playSound("LiveEvent_SerpentRumble", folder) -- equivalent call inferred; original call site unknown
		task.wait(0.75)
		fadeBlackout(1, 0.75, true)

		if currentCamera then
			currentCamera.FieldOfView = 35
		end

		playSequence(instance and instance:FindFirstChild("Awaken"), { "Section1", "Section2" })
		sendDialogue("Intro1") -- equivalent call inferred; original call site unknown
		sendDialogue("Intro2") -- equivalent call inferred; original call site unknown
		playSequence(instance and instance:FindFirstChild("Awaken"), { "Section3", "Section4" })
		sendDialogue("Intro3") -- equivalent call inferred; original call site unknown
		playSound("LiveEvent_SerpentRoar3", folder) -- equivalent call inferred; original call site unknown
		v:Shake(4, 12, 2)
		emitMouthEffects(folder)
		playSequence(instance and instance:FindFirstChild("FlyUpScene"), {
			"Section1",
			"Section2",
			"Section3",
			"Section4",
			"Section5"
		})
	elseif p == "Phase2" then
		if currentCamera then
			currentCamera.FieldOfView = 30
		end

		playSound("LiveEvent_SerpentRoar4", folder) -- equivalent call inferred; original call site unknown
		v:Shake(4, 10, 1.5)
		emitMouthEffects(folder)
		playSequence(instance and instance:FindFirstChild("Phase2"), {
			"Section1",
			"Section2",
			"Section3",
			"Section4",
			"Section5",
			"Section6",
			"Section7"
		})
		sendDialogue("Phase2A") -- equivalent call inferred; original call site unknown
		sendDialogue("Phase2B") -- equivalent call inferred; original call site unknown
	elseif p == "Phase3Exit" then
		playSound("LiveEventPart2_SerpentHeavyWingFlap", folder) -- equivalent call inferred; original call site unknown
		v:Shake(4, 10, 2)
		playSequence(instance and instance:FindFirstChild("GoingUp"), {
			"Section1",
			"Section2",
			"Section3",
			"Section4"
		})
		sendDialogue("Phase3") -- equivalent call inferred; original call site unknown
		fadeBlackout(0, 0.75)
	elseif p == "Phase3Enter" then
		fadeBlackout(1, 0.75, true)
		playSound("LiveEvent_SerpentRoar3", folder) -- equivalent call inferred; original call site unknown
		v:Shake(4, 8, 1.5)
		playSequence(instance and instance:FindFirstChild("GoingDown"), { "Section1", "Section2" })
	elseif p == "Phase4" then
		playSequence(instance and instance:FindFirstChild("Phase4"), { "Section1" })
		sendDialogue("Phase4A") -- equivalent call inferred; original call site unknown
		sendDialogue("Phase4B") -- equivalent call inferred; original call site unknown
		playSound("LiveEvent_SerpentRoar5", folder) -- equivalent call inferred; original call site unknown
		v:Shake(5, 14, 2)
	elseif p == "Death" then
		sendDialogue("Death") -- equivalent call inferred; original call site unknown
		playSound("LiveEvent_SerpentRoarEnding", folder) -- equivalent call inferred; original call site unknown
		playSequence(instance and instance:FindFirstChild("Death"), {
			"Section1",
			"Section2",
			"Section3",
			"Section4"
		})

		if folder then
			local highlight = Instance.new("Highlight")
			highlight.Name = "SerpentDeathHighlight"
			highlight.FillColor = Color3.new(1, 1, 1)
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = 1
			highlight.Parent = folder
			TweenService:Create(highlight, TweenInfo.new(0.4), {
				FillTransparency = 0,
				OutlineTransparency = 0
			}):Play()
			task.wait(0.4)

			for _, part in folder:GetDescendants() do
				if part:IsA("BasePart") then
					TweenService:Create(part, TweenInfo.new(1), {
						LocalTransparencyModifier = 1
					}):Play()
				end
			end

			TweenService:Create(highlight, TweenInfo.new(1), {
				FillTransparency = 1,
				OutlineTransparency = 1
			}):Play()
			task.wait(1)
			highlight:Destroy()
		end
	else
		error((`Unknown serpent raid cinematic stage: {p}`))
	end
end

return {
	Start = function(_, p: string, _, parent, p3)
		local v5, v6 = xpcall(function()
			runStage(p, parent, p3)
		end, debug.traceback)
		resetCamera() -- equivalent call inferred; original call site unknown

		if not v5 then
			error(v6)
		end

		return true
	end
}
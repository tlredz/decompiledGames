local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local session = chickenOrHero.Game.Session
local ParticipantDirectory = require(chickenOrHero.Presentation.ParticipantDirectory)
local VerifiedName = require(chickenOrHero.Presentation.VerifiedName)
local ChoiceSpotlightConfig = require(chickenOrHero.Presentation.ChoiceSpotlightConfig)
local parent = script.Parent
local notificationsF = localPlayer.PlayerGui:WaitForChild("Notifications").MainFrame.NotificationsF
local choiceAnnouncement = notificationsF:WaitForChild("ChoiceAnnouncement")
local v = {}
local v2 = nil
local highlight = nil
local clone = nil
local version = nil
local version2 = nil
local connections = {}
local v3 = nil
local v4 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function actorById(userId)
	for _, v5 in ParticipantDirectory.list() do
		if v5.UserId == userId then
			return v5
		end
	end
end

local function canFocus()
	local phase = session:GetAttribute("Phase")
	return localPlayer:GetAttribute("InMatch") == true and localPlayer:GetAttribute("ScreenPresentationActive") ~= true and localPlayer:GetAttribute("TutorialModalActive") ~= true and (phase == "SelectHero" or phase == "HeroChoice" or phase == "ChoiceReveal")
end

local function stopCamera()
	local v5 = v2
	v2 = nil

	if v5 and workspace.CurrentCamera == v5.camera and v5.camera.CameraType == Enum.CameraType.Scriptable then
		v5.camera.CFrame = v5.from
		v5.camera.Focus = v5.focus
		v5.camera.FieldOfView = v5.fov
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		v5.camera.CameraSubject = humanoid or v5.subject
		v5.camera.CameraType = v5.kind
	end

	localPlayer:SetAttribute("ChoiceSpotlightActive", nil)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearMarker()
	if highlight then
		highlight:Destroy()
		highlight = nil
	end

	if clone then
		clone:Destroy()
		clone = nil
	end
end

local function setBanner(p)
	if p == v4 then
		return
	end

	v4 = p

	if v3 then
		v3:Cancel()
	end

	if p then
		choiceAnnouncement.Visible = true
	end

	v3 = TweenService:Create(choiceAnnouncement, TweenInfo.new(p and 0.22 or 0.18), {
		GroupTransparency = p and 0 or 1
	})
	v3:Play()

	if not p then
		local v5 = v3
		task.delay(0.19, function()
			if v3 == v5 and not v4 then
				choiceAnnouncement.Visible = false
			end
		end)
	end
end

local function startCamera(player)
	stopCamera()

	if not player or player.UserId == localPlayer.UserId then
		return
	end

	local currentCamera = workspace.CurrentCamera
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not ChoiceSpotlightConfig.CameraEnabled or not canFocus() or not humanoidRootPart or not currentCamera or currentCamera.CameraType == Enum.CameraType.Scriptable then
		return
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.RespectCanCollide = true
	local characters = {}

	for _, v5 in ParticipantDirectory.list() do
		if v5.Character then
			table.insert(characters, v5.Character)
		end
	end

	raycastParams.FilterDescendantsInstances = characters
	v2 = {
		camera = currentCamera,
		root = humanoidRootPart,
		actorId = player.UserId,
		started = os.clock(),
		from = currentCamera.CFrame,
		focus = currentCamera.Focus,
		fov = currentCamera.FieldOfView,
		subject = currentCamera.CameraSubject,
		kind = currentCamera.CameraType,
		params = raycastParams,
		deadline = (v.endsAt or workspace:GetServerTimeNow()) + ChoiceSpotlightConfig.DeadlineGrace
	}
	localPlayer:SetAttribute("ChoiceSpotlightActive", true)
	currentCamera.CameraType = Enum.CameraType.Scriptable
	chickenOrHero.Audio.PresentationCues:Fire("ChoiceFocus", ChoiceSpotlightConfig.ApproachTime)
end

local function update()
	local choiceMoment = session:GetAttribute("ChoiceMoment")

	if choiceMoment then
		local success, result = pcall(function()
			return HttpService:JSONDecode(choiceMoment)
		end)

		if success and type(result) == "table" then
			v = result
		end
	end

	local v5 = v.kind == "Chosen"
	local v6 = v.kind == "Selected"
	local v7 = (v.endsAt or 0) + (v6 and ChoiceSpotlightConfig.DeadlineGrace or 0)
	local v8

	if localPlayer:GetAttribute("InMatch") == true then
		if v5 or v6 then
			if workspace:GetServerTimeNow() < v7 and localPlayer:GetAttribute("ScreenPresentationActive") ~= true and localPlayer:GetAttribute("TutorialModalActive") ~= true then
				v8 = v5 or canFocus()
			else
				v8 = false
			end
		else
			v8 = v6
		end
	else
		v8 = false
	end

	setBanner(v8)

	if v8 then
		local escapeStreak = notificationsF:FindFirstChild("EscapeStreak")
		choiceAnnouncement.Position = UDim2.new(
			0.5,
			0,
			1,
			escapeStreak and escapeStreak.Visible and 14 + escapeStreak.AbsoluteSize.Y or 10
		)
		local v9 = v.choice == "Hero"
		local color = v5 and v9 and Color3.fromRGB(255, 202, 86) or Color3.fromRGB(158, 217, 238)
		choiceAnnouncement.Title.RichText = true
		local formatted = VerifiedName.format(v.name or "Runner", v.verified)
		choiceAnnouncement.Title.Text = v5 and formatted .. " chose " .. string.upper(v.choice or "Chicken") or formatted .. " is choosing…"
		choiceAnnouncement.Description.Text = v5 and (v9 and "They cross alone first. Watch their escape." or "Everyone crosses together. Get ready.") or "Chicken or Hero?"
		choiceAnnouncement.Accent.BackgroundColor3 = color

		if version ~= v.version then
			version = v.version
			clearMarker() -- equivalent call inferred; original call site unknown
			local v10 = actorById(v.userId) -- equivalent call inferred; original call site unknown
			local character = v10 and v10.Character

			if character then
				highlight = Instance.new("Highlight")
				highlight.Name = "ChoiceFocus"
				highlight.Adornee = character
				highlight.FillTransparency = 0.94
				highlight.OutlineTransparency = 0.15
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				highlight.FillColor = color
				highlight.OutlineColor = color
				highlight.Parent = character

				if v5 then
					clone = parent.DecisionTemplate:Clone()
					clone.Name = "ChoiceDecision"
					clone.Enabled = true
					clone.Adornee = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
					clone.Label.Text = string.upper(v.choice or "Chicken")
					clone.Label.TextColor3 = color
					clone.Parent = parent
				end
			end
		end

		if v5 and v2 and v2.actorId == v.userId and not v2.resolvedAt then
			v2.resolvedAt = os.clock()
		end

		if v6 and version2 ~= v.version and canFocus() then
			version2 = v.version
			startCamera(actorById(v.userId))
		end

		if not canFocus() then
			stopCamera()
		end
	else
		clearMarker() -- equivalent call inferred; original call site unknown
		stopCamera()
	end
end

table.insert(connections, session:GetAttributeChangedSignal("ChoiceMoment"):Connect(update))
table.insert(connections, session:GetAttributeChangedSignal("Phase"):Connect(update))
local total = 0

for _, v5 in { "InMatch", "ScreenPresentationActive", "TutorialModalActive" } do
	table.insert(connections, localPlayer:GetAttributeChangedSignal(v5):Connect(update))
end

table.insert(connections, localPlayer.CharacterAdded:Connect(function()
	stopCamera()
	clearMarker() -- equivalent call inferred; original call site unknown
end))
table.insert(connections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(stopCamera))
RunService:BindToRenderStep("CoHChoiceSpotlight", Enum.RenderPriority.Camera.Value + 3, function(p)
	if v2 and (not canFocus() or not v2.root.Parent or workspace:GetServerTimeNow() > v2.deadline) then
		stopCamera()
	end

	total += p

	if total >= 0.1 then
		total = 0
		update()
	end

	local v5 = v2

	if not v5 then
		return
	end

	if not canFocus() or not v5.root.Parent or workspace.CurrentCamera ~= v5.camera or v5.camera.CameraType ~= Enum.CameraType.Scriptable or not v5.resolvedAt and workspace:GetServerTimeNow() > v5.deadline then
		stopCamera()
		return
	end

	local v6 = os.clock() - v5.started
	local v7 = v5.root.Position + createVector(0, 1, 0)
	local v8 = v7 + v5.root.CFrame.LookVector * ChoiceSpotlightConfig.Distance + createVector(0, 1, 0) * ChoiceSpotlightConfig.Height
	local raycastResult = workspace:Raycast(v7, v8 - v7, v5.params)

	if raycastResult then
		v8 = raycastResult.Position + raycastResult.Normal * 0.5
	end

	if (v8 - v7).Magnitude < 0.1 then
		v8 = v7 + createVector(0, 0, 1)
	end

	local cframe = CFrame.lookAt(v8, v7)
	local v9 = math.clamp(v6 / ChoiceSpotlightConfig.ApproachTime, 0, 1)

	if v5.resolvedAt then
		local v10 = os.clock() - v5.resolvedAt - ChoiceSpotlightConfig.AnswerHoldTime

		if ChoiceSpotlightConfig.ReturnTime <= v10 then
			stopCamera()
			return
		elseif v10 > 0 then
			v9 *= 1 - math.clamp(v10 / ChoiceSpotlightConfig.ReturnTime, 0, 1)
		end
	end

	local v10 = v9 * v9 * (3 - v9 * 2)
	v5.camera.CFrame = v5.from:Lerp(cframe, v10)
	v5.camera.Focus = v5.focus:Lerp(CFrame.new(v7), v10)
end)
script.Destroying:Connect(function()
	stopCamera()
	clearMarker() -- equivalent call inferred; original call site unknown
	setBanner(false)
	RunService:UnbindFromRenderStep("CoHChoiceSpotlight")

	for _, connection in connections do
		connection:Disconnect()
	end
end)
update()
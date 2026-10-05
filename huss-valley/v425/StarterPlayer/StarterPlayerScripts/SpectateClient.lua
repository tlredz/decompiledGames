local createVector = vector.create
local HudNavigation = require(game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Presentation"):WaitForChild("HudNavigation"))
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local presentation = game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Presentation")
local session = presentation.Parent:WaitForChild("Game"):WaitForChild("Session")
local SpectateConfig = require(presentation:WaitForChild("SpectateConfig"))
local VerifiedName = require(presentation:WaitForChild("VerifiedName"))
local CreatorPolicy = require(presentation:WaitForChild("CreatorPolicy"))
local v = false
local SpectateGeometry = require(presentation:WaitForChild("SpectateGeometry"))
local SpectateCamera = require(presentation:WaitForChild("SpectateCamera"))
local SpectateView = require(presentation:WaitForChild("SpectateView"))
local SpectateInput = require(presentation:WaitForChild("SpectateInput"))
local ParticipantDirectory = require(presentation:WaitForChild("ParticipantDirectory"))
local spectateEvent = presentation:WaitForChild("SpectateEvent")
local v2 = SpectateView.new(localPlayer)
local flag = false
local v3 = "Follow"
local character = nil
local id = nil
local v4 = nil
local v5 = nil
local token = nil
local v6 = nil
local connections = {}
local v7 = {}
local now = 0
local now2 = 0
local v8 = false
local count = 0
local v9 = nil
local v10 = {
	"MapVoteOpen",
	"JourneyOpen",
	"ArmoryOpen",
	"BalloonOfferOpen",
	"ServerBrowserOpen",
	"FairPlayNoticeOpen",
	"ChoiceSpotlightActive",
	"AdminConsoleActive",
	"SettingsOpen",
	"UpdateLogOpen"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function connect(object, p)
	table.insert(connections, object:Connect(p))
end

local function eligible(p)
	if p then
		return SpectateConfig.Enabled and CreatorPolicy.lobby(localPlayer, session)
	end

	local enabled = SpectateConfig.Enabled

	if not enabled then
		return enabled
	end

	if session:GetAttribute("SpectateAvailable") == true then
		enabled = not session:GetAttribute("MapChanging")

		if enabled then
			if localPlayer:GetAttribute("ClientReady") == true and localPlayer:GetAttribute("InMatch") ~= true and (localPlayer:GetAttribute("GameRole") or "Lobby") == "Lobby" then
				enabled = not (localPlayer:GetAttribute("TutorialSession") or localPlayer:GetAttribute("TutorialRouting") or localPlayer:GetAttribute("ScreenPresentationActive") or localPlayer:GetAttribute("AdminTransferring") or localPlayer:GetAttribute("ServerBrowserTransferring"))
			else
				enabled = false
			end
		end
	else
		enabled = false
	end

	return enabled
end

-- equivalent calls inferred from this helper; original call sites unknown
local function menuOpen()
	for _, attributeName in v10 do
		if localPlayer:GetAttribute(attributeName) then
			return true
		end
	end

	return false
end

local function render()
	local v11 = UserInputService:GetLastInputType().Name:find("Gamepad") ~= nil
	v2:render(flag, v3, UserInputService.TouchEnabled and not v11, v11)

	if flag and v then
		v2.bar.Visible = false
		v2.hint.Visible = false
		v2.hintButton.Visible = false
	end

	v2.open.Visible = false
	local setAvailable = HudNavigation.setAvailable
	local v13 = eligible()

	if v13 then
		v13 = not flag

		if v13 then
			local v14 = menuOpen() -- equivalent call inferred; original call site unknown
			v13 = not v14
		end
	end

	setAvailable("Spectate", v13)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function touchControls()
	local touchGui = localPlayer.PlayerGui:FindFirstChild("TouchGui")

	if touchGui and touchGui ~= v9 then
		if v9 and v9.Parent and v4 then
			v9.Enabled = v4.touchEnabled
		end

		v9 = touchGui
		v4.touchEnabled = touchGui.Enabled
		touchGui.Enabled = false
	end
end

local function fn(p)
	v8 = false
	count += 1

	if p then
		spectateEvent:FireServer("Stop")
	end

	local v11 = flag
	flag = false
	v = false
	localPlayer:SetAttribute("CreatorCameraActive", nil)
	v6:set(false, v3)
	localPlayer:SetAttribute("Spectating", nil)
	localPlayer:SetAttribute("SpectateMode", nil)
	local currentCamera = workspace.CurrentCamera

	if v11 and currentCamera then
		currentCamera.CameraSubject = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") or v4 and v4.subject
		currentCamera.CameraType = v4 and v4.cameraType or Enum.CameraType.Custom

		if v4 then
			currentCamera.FieldOfView = v4.fov
			currentCamera.CFrame = v4.cf
			currentCamera.Focus = v4.focus
		end
	end

	if v9 and v9.Parent and v4 then
		v9.Enabled = v4.touchEnabled
	end

	v9 = nil

	if v11 and v4 then
		UserInputService.MouseBehavior = v4.mouse
		UserInputService.MouseIconEnabled = v4.icon
	end

	character = nil
	id = nil
	token = nil
	v5 = nil
	v4 = nil
	table.clear(v7)
	render()
end

local function action(p)
	if p == "Stop" then
		fn(true)
	elseif flag then
		if v then
			return
		end

		if p == "Previous" then
			spectateEvent:FireServer("Next", -1)
		elseif p == "Next" then
			spectateEvent:FireServer("Next", 1)
		elseif p == "Toggle" then
			spectateEvent:FireServer(v3 == "Free" and "Follow" or "Free")
		elseif p == "Follow" or p == "Free" then
			spectateEvent:FireServer(p)
		end
	end
end

v6 = SpectateInput.new(v2, action)

local function startWatching()
	HudNavigation.opening("Spectate")

	if eligible() then
		local v11 = menuOpen() -- equivalent call inferred; original call site unknown

		if not (v11 or v8) then
			v8 = true
			count += 1
			local v12 = count
			spectateEvent:FireServer("Start")
			task.delay(8, function()
				if count == v12 then
					v8 = false
				end
			end)
		end
	end
end

HudNavigation.register("CreatorCamera", function()
	if v and (flag or v8) then
		fn(true)
		return
	end

	if not (SpectateConfig.Enabled and CreatorPolicy.lobby(localPlayer, session)) then
		HudNavigation.Notice:Fire("Creator freecam is available while you are in the lobby.")
		return
	end

	HudNavigation.opening("CreatorCamera")

	-- equivalent call inferred; original call site unknown
	if menuOpen() then
		HudNavigation.Notice:Fire("Close the other menu before starting the camera.")
		return
	end

	if flag then
		fn(false)
	end

	v = true
	v8 = true
	count += 1
	local v11 = count
	spectateEvent:FireServer("CreatorStart")
	task.delay(8, function()
		if count == v11 and v8 then
			fn(true)
			HudNavigation.Notice:Fire("Camera request timed out. Try again.")
		end
	end)
end)
HudNavigation.setAvailable("CreatorCamera", true)
HudNavigation.register("Spectate", startWatching)
connect(v2.open.Activated, startWatching) -- equivalent call inferred; original call site unknown

for _, v11 in {
	{ v2.prev, "Previous" },
	{ v2.next, "Next" },
	{ v2.follow, "Follow" },
	{ v2.free, "Free" },
	{ v2.exit, "Stop" }
} do
	local v12 = v11
	table.insert(connections, v11[1].Activated:Connect(function()
		action(v12[2])
	end))
end

table.insert(connections, v2.zoomIn.Activated:Connect(function()
	if v5 then
		v5:zoom(-3)
	end
end))
table.insert(connections, v2.zoomOut.Activated:Connect(function()
	if v5 then
		v5:zoom(3)
	end
end))

local function refreshIgnore()
	table.clear(v7)

	if localPlayer.Character then
		table.insert(v7, localPlayer.Character)
	end

	for _, v11 in ParticipantDirectory.list() do
		if v11.Character then
			table.insert(v7, v11.Character)
		end
	end

	local spectatorStreamingFoci = workspace:FindFirstChild("SpectatorStreamingFoci")

	if spectatorStreamingFoci then
		table.insert(v7, spectatorStreamingFoci)
	end

	now = os.clock()
end

table.insert(connections, spectateEvent.OnClientEvent:Connect(function(p, value)
	if p == "Stop" then
		fn(false)

		if type(value) == "string" then
			v2.note.Text = value
			task.delay(4, function()
				if v2.note.Parent and v2.note.Text == value then
					v2.note.Text = ""
				end
			end)
		end
	else
		if p == "Bounds" and flag and SpectateGeometry.valid(value) then
			v5.area = value
			return
		end

		if p ~= "Target" and p ~= "Free" or (type(value) ~= "table" or not SpectateGeometry.valid(value.area)) then
			return
		end

		local creator = value.creator == true

		if eligible(creator) then
			local v11 = menuOpen() -- equivalent call inferred; original call site unknown

			if not v11 and (flag or v8) then
				v = creator
				local currentCamera = workspace.CurrentCamera

				if not currentCamera then
					fn(true)
					return
				end

				local v12 = not flag

				if v12 then
					v4 = {
						subject = currentCamera.CameraSubject,
						cameraType = currentCamera.CameraType,
						fov = currentCamera.FieldOfView,
						cf = currentCamera.CFrame,
						focus = currentCamera.Focus,
						mouse = UserInputService.MouseBehavior,
						icon = UserInputService.MouseIconEnabled
					}
					local position = value.position or value.area.cf.Position
					local cframe = CFrame.lookAt(
						SpectateGeometry.clamp(position + createVector(0, 9, 18), value.area),
						position + createVector(0, 1.5, 0)
					)

					if v then
						cframe = CFrame.new(SpectateGeometry.clamp(position, value.area)) * currentCamera.CFrame.Rotation
					end

					v5 = SpectateCamera.new(cframe, value.area)
					currentCamera.FieldOfView = not v and 70 or localPlayer:GetAttribute("CreatorFOV") or 60

					if v then
						currentCamera.CFrame = cframe
					end
				end

				v5.area = value.area
				token = value.token
				v8 = false
				local v13 = p == "Free" and "Free" or "Follow"
				local v14 = v3 ~= v13
				local v15 = id ~= value.id
				v3 = v13
				flag = true
				currentCamera.CameraType = Enum.CameraType.Scriptable
				localPlayer:SetAttribute("Spectating", true)
				localPlayer:SetAttribute("SpectateMode", v3)
				localPlayer:SetAttribute("CreatorCameraActive", v or nil)
				touchControls() -- equivalent call inferred; original call site unknown

				if v3 == "Free" then
					v5:resetPosition(currentCamera.CFrame)
					v5.focus = nil
					character = nil
					v2.label.Text = "SPECTATING  /  FREE CAMERA"
					v2.name.Text = "Explore the field"
					v2.role.Text = "STAYING IN THE LOBBY"
					now2 = 0
				else
					character = value.character
					id = value.id

					if v15 or v14 then
						v5.focus = nil
					end

					v2.label.Text = "WATCHING  /  " .. value.index .. " OF " .. value.total
					v2.name.RichText = true
					v2.name.Text = VerifiedName.format(value.name, value.verified)
					v2.role.Text = value.role .. "  ·  " .. value.state

					if (v12 or v15) and workspace.StreamingEnabled and value.position then
						task.spawn(function()
							pcall(function()
								localPlayer:RequestStreamAroundAsync(value.position, 5)
							end)
						end)
					end
				end

				if v12 or v14 then
					v6:set(true, v3)
				end

				refreshIgnore()
				v2.note.Text = ""
				render()
				return
			end
		end

		fn(true)
	end
end))

local function fn2()
	if not (flag or v8) then
		render()
		return
	end

	if eligible(v) then
		-- equivalent call inferred; original call site unknown
		if not menuOpen() then
			render()
			return
		end
	end

	fn(true)
end

for _, v11 in {
	"CreatorAuthorized",
	"ClientReady",
	"InMatch",
	"GameRole",
	"TutorialSession",
	"TutorialRouting",
	"ScreenPresentationActive",
	"AdminTransferring",
	"ServerBrowserTransferring"
} do
	connect(localPlayer:GetAttributeChangedSignal(v11), fn2) -- equivalent call inferred; original call site unknown
end

for _, v11 in v10 do
	connect(localPlayer:GetAttributeChangedSignal(v11), fn2) -- equivalent call inferred; original call site unknown
end

for _, v11 in { "SpectateAvailable", "MapChanging", "GlobalPaused" } do
	connect(session:GetAttributeChangedSignal(v11), fn2) -- equivalent call inferred; original call site unknown
end

table.insert(connections, localPlayer:GetAttributeChangedSignal("SpectateRequestedExit"):Connect(function()
	if flag or v8 then
		fn(true)
	end
end))
table.insert(connections, localPlayer.CharacterRemoving:Connect(function()
	if flag or v8 then
		fn(true)
	end
end))
table.insert(connections, localPlayer.CharacterAdded:Connect(function()
	if flag or v8 then
		fn(true)
	end
end))
connect(UserInputService.LastInputTypeChanged, render) -- equivalent call inferred; original call site unknown
connect(localPlayer:GetAttributeChangedSignal("SpectatorHints"), render) -- equivalent call inferred; original call site unknown
table.insert(connections, localPlayer.PlayerGui.ChildAdded:Connect(function(child)
	if flag and child.Name == "TouchGui" then
		touchControls() -- equivalent call inferred; original call site unknown
	end
end))
RunService:BindToRenderStep("ValleySpectate", Enum.RenderPriority.Camera.Value + 3, function(p)
	if not flag then
		return
	end

	if eligible(v) then
		-- equivalent call inferred; original call site unknown
		if not menuOpen() then
			local currentCamera = workspace.CurrentCamera

			if not currentCamera then
				return
			end

			if v3 == "Follow" and not (character and character.Parent) then
				for _, v12 in ParticipantDirectory.list() do
					if v12.UserId ~= id then
						continue
					end

					character = v12.Character
					break
				end
			end

			if os.clock() - now > 0.5 then
				refreshIgnore()
			end

			local sample, v11, v12, v13, v14 = v6:sample(p)
			v5:look(v11)

			if v3 == "Follow" then
				v5:zoom(v12)
			end

			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			local creatorCameraSpeed = localPlayer:GetAttribute("CreatorCameraSpeed")
			v5.speedScale = (not v or type(creatorCameraSpeed) ~= "number" or creatorCameraSpeed ~= creatorCameraSpeed) and 1 or math.clamp(
				creatorCameraSpeed,
				0.25,
				2
			) or 1

			if v then
				local creatorFOV = localPlayer:GetAttribute("CreatorFOV")
				local v15 = (type(creatorFOV) ~= "number" or creatorFOV ~= creatorFOV) and 60 or math.clamp(
					creatorFOV,
					35,
					90
				) or 60
				currentCamera.FieldOfView += (v15 - currentCamera.FieldOfView) * SpectateGeometry.alpha(12, p)
			end

			local cFrame, focus = v5:step(v3, humanoidRootPart, sample, v13, p, v7)
			currentCamera.CameraType = Enum.CameraType.Scriptable
			currentCamera.CFrame = cFrame
			currentCamera.Focus = focus
			UserInputService.MouseBehavior = v14 and Enum.MouseBehavior.LockCurrentPosition or Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = not v14

			if v3 == "Free" and os.clock() - now2 >= SpectateConfig.FocusInterval then
				now2 = os.clock()
				spectateEvent:FireServer("Focus", {
					token = token,
					position = cFrame.Position
				})
			end

			return
		end
	end

	fn(true)
end)
fn2()
script.Destroying:Connect(function()
	fn(true)
	RunService:UnbindFromRenderStep("ValleySpectate")
	v6:destroy()

	for _, connection in connections do
		connection:Disconnect()
	end

	v2:destroy()
end)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local giveawayEvent = chickenOrHero:WaitForChild("Admin"):WaitForChild("GiveawayEvent")
local GiveawayView = require(chickenOrHero.Presentation.GiveawayView)
local v = GiveawayView.new(localPlayer:WaitForChild("PlayerGui"))
local GiveawayPicker = require(chickenOrHero.Presentation.GiveawayPicker)
local v2 = GiveawayPicker.new(localPlayer, giveawayEvent)
local v3 = nil
local v4 = {}
local now = 0
local v5 = false
local clone = nil

local function cue(childName, value)
	local gameAudio = game.SoundService:FindFirstChild("GameAudio")
	local _04_UI = gameAudio and gameAudio:FindFirstChild("04_UI")
	local sound = _04_UI and _04_UI:FindFirstChild("MatchSummary") and _04_UI.MatchSummary:FindFirstChild(childName)

	if not sound or not sound:IsA("Sound") or sound.SoundId == "" then
		return
	end

	if clone then
		clone:Destroy()
	end

	clone = sound:Clone()
	clone.Volume *= value or 1
	clone.Looped = false
	clone.Parent = game.SoundService
	clone:Play()
	Debris:AddItem(clone, 5)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function close(data)
	if data and v3 and v3.id ~= data then
		return
	end

	if v3 then
		v4[v3.id] = true
	end

	v3 = nil
	v:hide()
	localPlayer:SetAttribute("GlobalWheelOpen", nil)
end

giveawayEvent.OnClientEvent:Connect(function(p, data)
	if p == "Open" then
		v2.open()
	elseif p == "Reply" then
		v2.reply(data)
	elseif p == "Show" then
		if type(data) ~= "table" or v4[data.id] or workspace:GetServerTimeNow() >= data.endsAt or v3 and v3.id == data.id then
			return
		end

		v2.hide()
		v3 = data
		v5 = false
		localPlayer:SetAttribute("GlobalWheelOpen", true)
		local focusedTextBox = UserInputService:GetFocusedTextBox()

		if focusedTextBox then
			focusedTextBox:ReleaseFocus()
		end

		v:show(data, localPlayer.UserId)
	elseif p == "Close" then
		close(data) -- equivalent call inferred; original call site unknown
	elseif p == "Skipped" then
		local ValleyPanels = require(chickenOrHero.Presentation.ValleyPanels)
		local screen = ValleyPanels.screen(localPlayer, "GiveawayStatus", 9901)
		local v6 = ValleyPanels.make("TextLabel", screen, "Message", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.15),
			Size = UDim2.fromScale(0.75, 0.15),
			BackgroundTransparency = 1,
			Text = data.message,
			TextWrapped = true,
			TextScaled = true,
			TextColor3 = ValleyPanels.Gold,
			TextStrokeTransparency = 0.2,
			TextStrokeColor3 = ValleyPanels.Ink,
			Font = Enum.Font.GothamBold
		})
		ValleyPanels.make("UITextSizeConstraint", v6, "Limit", {
			MaxTextSize = 23,
			MinTextSize = 12
		})
		Debris:AddItem(screen, 7)
	end
end)
RunService:BindToRenderStep("GlobalGiveawayOverlay", Enum.RenderPriority.Camera.Value + 20, function()
	if not v3 then
		return
	end

	local serverTimeNow = workspace:GetServerTimeNow()

	if v3.endsAt + 1 <= serverTimeNow then
		if v3 then
			v4[v3.id] = true
		end

		v3 = nil
		v:hide()
		localPlayer:SetAttribute("GlobalWheelOpen", nil)
	else
		local v6, v7 = v:step(serverTimeNow)

		if v6 and os.clock() - now > 0.075 then
			now = os.clock()
			cue("CountTick", 0.5)
		end

		if v7 and not v5 then
			v5 = true
			cue("LevelUp", 0.85)
		end
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function sync()
	giveawayEvent:FireServer("Sync")
end

localPlayer:GetAttributeChangedSignal("ClientReady"):Connect(sync)
sync() -- equivalent call inferred; original call site unknown
script.Destroying:Connect(function()
	if v3 then
		v4[v3.id] = true
	end

	v3 = nil
	v:hide()
	localPlayer:SetAttribute("GlobalWheelOpen", nil)
	RunService:UnbindFromRenderStep("GlobalGiveawayOverlay")
	v2.destroy()
	v.gui:Destroy()

	if clone then
		clone:Destroy()
	end
end)
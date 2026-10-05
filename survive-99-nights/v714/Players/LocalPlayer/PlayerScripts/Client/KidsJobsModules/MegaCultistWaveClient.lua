local MegaCultistWaveClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local color = Color3.fromRGB(255, 64, 64)
local color2 = Color3.fromRGB(0, 217, 0)
local v = { "rbxassetid://113412118160746", "rbxassetid://130339875527682", "rbxassetid://93564647560872" }
local megaWave = nil
local textColor3 = nil
local count = 0
local v2 = false
local v3 = false
local flag = false

function FormatTime(p)
	return string.format("%d:%02d", math.floor(p / 60), p % 60)
end

function UpdateRemaining()
	local megaWaveUnitsTotal = workspace:GetAttribute("MegaWaveUnitsTotal")
	local megaWaveUnitsAlive = workspace:GetAttribute("MegaWaveUnitsAlive")

	if megaWave == nil or megaWaveUnitsTotal == nil or megaWaveUnitsAlive == nil then
		return
	end

	megaWave.CultistRemaining.Text = megaWaveUnitsAlive .. "/" .. megaWaveUnitsTotal .. " Cultists Remain"
end

function StartFlashing()
	if flag then
		return
	end

	flag = true
	local v4 = count
	task.spawn(function()
		while flag and count == v4 do
			megaWave.Time.Visible = not megaWave.Time.Visible
			task.wait(0.4)
		end

		if count == v4 then
			megaWave.Time.Visible = true
		end
	end)
end

function UpdateTimer(p)
	megaWave.Time.Text = FormatTime(p)

	if p <= 20 then
		megaWave.Time.TextColor3 = color
	end

	if p <= 10 then
		StartFlashing()
	end
end

function FinishWave(text, textColor)
	if megaWave == nil or v3 then
		return
	end

	v3 = true
	flag = false
	megaWave.Time.Visible = true
	megaWave.Time.Text = text
	megaWave.Time.TextColor3 = textColor
	local v4 = count
	task.delay(10, function()
		if count == v4 then
			megaWave.Visible = false
		end
	end)
end

function WaveIncoming(p, p2, p3, p4)
	if megaWave == nil then
		return
	end

	count += 1
	v3 = false
	flag = false
	v2 = true
	megaWave.Time.Visible = true
	megaWave.Time.TextColor3 = textColor3
	megaWave.Time.Text = FormatTime(p3)
	megaWave.CultistRemaining.Text = p2 .. "/" .. p2 .. " Cultists Remain"

	for i = 1, 3 do
		local child = megaWave.Frame:FindFirstChild("Cultist" .. i)

		if not child then
			continue
		end

		child.Visible = i <= p
		child.Tick.Visible = false
		child.Image = v[p4]
	end

	megaWave.Visible = true
end

function MegaCultistWaveClient.Init()
	task.spawn(function()
		megaWave = Client.Interface.MegaWave
		textColor3 = megaWave.Time.TextColor3
	end)
	Client.Events.MegaCultistWaveIncoming:Connect(WaveIncoming)
	Client.Events.MegaCultistWaveAnnounce:Connect(function(p, p2)
		Client.PopUpUI.AddPopUp(
			`<font color="#9B1E1E">Kill all the Cultists before time expires.</font> Difficulty: <font color="{p2}">{p}</font>`,
			"note"
		)
	end)
	Client.Events.MegaCultistWaveStarted:Connect(function()
		v2 = false
	end)
	Client.Events.MegaCultistWaveCleared:Connect(function(p)
		if megaWave == nil then
			return
		end

		local child = megaWave.Frame:FindFirstChild("Cultist" .. p)

		if child then
			child.Tick.Visible = true
		end
	end)
	Client.Events.MegaCultistWaveCompleted:Connect(function()
		FinishWave("VICTORY", color2)
	end)
	Client.Events.MegaCultistWaveFailed:Connect(function()
		FinishWave("DEFEAT", color)
		Client.PopUpUI.AddPopUp("you failed the Mega Cultist Wave", "warning")
	end)
	workspace:GetAttributeChangedSignal("MegaWaveUnitsAlive"):Connect(UpdateRemaining)
	workspace:GetAttributeChangedSignal("SecondsLeft"):Connect(function()
		if megaWave == nil or not megaWave.Visible or v3 or v2 then
			return
		end

		if workspace:GetAttribute("State") ~= "Night" then
			return
		end

		local secondsLeft = workspace:GetAttribute("SecondsLeft")

		if secondsLeft and secondsLeft > 0 then
			UpdateTimer(secondsLeft)
		end
	end)
end

return MegaCultistWaveClient
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local GuiService = game:GetService("GuiService")
require(ReplicatedStorage.ServerInfo)
local currentCamera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not (UserInputService.GamepadEnabled or GuiService:IsTenFootInterface())
local v2 = {
	{
		TeamName = "Red",
		Color = Color3.fromRGB(255, 103, 103)
	},
	{
		TeamName = "Blue",
		Color = Color3.fromRGB(64, 153, 255)
	}
}
local announcer = playerGui:WaitForChild("announcer")
local parent = script.Parent
local frame = parent.Frame.Frame
local instructionFrame = parent.InstructionFrame
local clone = parent.Frame.Team1.Template:Clone()
local clone2 = parent.Frame.Team2.Template:Clone()
local v3 = { parent.Frame.Team1, parent.Frame.Team2 }

for _, v4 in v3 do
	for _, guiObject in v4:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end
end

local v4 = {
	teams = {}
}
local v5 = nil

local function shiftNotifications()
	local uDim = UDim2.fromScale(0, 0.15)
	local v6 = {
		announcer.Standoff,
		announcer.StandoffShadow,
		announcer.Killed,
		announcer.Winner,
		announcer.Standoff
	}
	local enabled = parent.Enabled

	if not enabled then
		task.wait(1)
	end

	for _, v7 in ipairs(v6) do
		local originalPosition = v7:GetAttribute("OriginalPosition")

		if not originalPosition then
			originalPosition = v7.Position
			v7:SetAttribute("OriginalPosition", originalPosition)
		end

		if enabled then
			originalPosition += uDim
		end

		v7.Position = originalPosition
	end
end

local function updateState(data)
	frame.Score.Text = data.score or "<score>"
	instructionFrame.Reward.Text = data.instruction or ""

	if data.currencyImage then
		instructionFrame.RewardIcon.Visible = true
		instructionFrame.RewardIcon.Image = data.currencyImage
	else
		instructionFrame.RewardIcon.Visible = false
	end

	local v6 = {}

	for k, v7 in table.clone(v4.teams) do
		for i = #v7.players, 1, -1 do
			local player = v7.players[i]

			if not player then
				continue
			end

			local flag = false

			if data.teams[k] then
				for _, player2 in data.teams[k].players do
					if player2.uuid ~= player.uuid then
						continue
					end

					flag = true
					break
				end
			end

			if flag then
				v6[player.uuid] = player.gui
			else
				local v8 = player
				pcall(function()
					v8.gui:Destroy()
				end)
				table.remove(v4.teams[k].players, i)
			end
		end

		if #v7.players == 0 then
			v4.teams[k] = nil
		end
	end

	for k, team in data.teams do
		if not v4.teams[k] then
			v4.teams[k] = {
				players = {}
			}
		end

		local v7 = v2[k] or {
			TeamName = ("Team %d"):format(k),
			Color = Color3.fromRGB(255, 255, 255)
		}

		for k2, player in team.players do
			if not v6[player.uuid] then
				local uuid = player.uuid
				local v8

				if k == 1 then
					v8 = clone
				else
					v8 = clone2
				end

				v6[uuid] = v8:Clone()
			end

			local gui = v6[player.uuid]
			local parent2

			if k == 1 then
				parent2 = parent.Frame.Team1
			else
				parent2 = parent.Frame.Team2
			end

			gui.Parent = parent2
			gui.LayoutOrder = k2 * (k == 1 and 1 or -1)
			gui.ImageLabel.Image = `rbxthumb://type=AvatarHeadShot&id={player.id}&w=100&h=100`
			gui.TextLabel.Text = player.score
			gui.ImageTransparency = player.alive and 0 or 0.8
			gui.ImageLabel.ImageTransparency = player.alive and 0 or 0.8
			gui.ImageColor3 = v7.Color
			local team2 = v4.teams[k]

			if team2 and team2.players then
				table.insert(team2.players, {
					uuid = player.uuid,
					gui = gui
				})
			end
		end

		if v then
			parent.TeamNames.Holder[`Team{k}Name`].Text = k == 1 and `({#team.players}) {team.name}` or `{team.name} ({#team.players})`
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateBoardVisibility()
	local character = localPlayer.Character
	parent.Enabled = v5 and character and character.Parent == workspace.Alive
end

parent:GetPropertyChangedSignal("Enabled"):Connect(shiftNotifications)
shiftNotifications()
game.ReplicatedStorage.Remotes.InformScoreUIState.OnClientEvent:Connect(updateState)
task.spawn(function()
	local v6 = game.ReplicatedStorage.Remotes.GetScoreUIState:InvokeServer()

	if v6 then
		task.spawn(updateState, v6)
	end
end)
game.ReplicatedStorage.Remotes.ShowHideTwoTeamScoreBoard.OnClientEvent:Connect(function(flag: boolean)
	v5 = flag
	updateBoardVisibility() -- equivalent call inferred; original call site unknown
end)
task.spawn(function()
	local v6 = game.ReplicatedStorage.Remotes.GetTwoTeamScoreBoardVisibility:InvokeServer()

	if v6 then
		v5 = v6
		updateBoardVisibility() -- equivalent call inferred; original call site unknown
	end
end)
workspace.Alive.ChildAdded:Connect(updateBoardVisibility)
workspace.Dead.ChildAdded:Connect(updateBoardVisibility)
task.spawn(updateBoardVisibility)
local RunService = game:GetService("RunService")
RunService.PreRender:Connect(function()
	debug.profilebegin("TwoTeamsScoreBoard")

	if not parent.Enabled then
		return
	end

	if localPlayer.Character and localPlayer.Character.Parent == workspace.Alive then
		parent.Frame.Visible = true
	else
		parent.Frame.Visible = false
	end

	debug.profileend()
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function darkenColor(color: Color3, value: number)
	local v6 = math.clamp(value, 0, 1)
	return Color3.fromRGB(color.R * v6 * 255, color.G * v6 * 255, color.B * v6 * 255)
end

for i, v6 in ipairs(v2) do
	local child = parent.TeamNames.Holder:FindFirstChild(("Team%dName"):format(i))

	if not child then
		continue
	end

	child.Text = v6.TeamName
	child.TextColor3 = v6.Color
	local uIStroke = child.UIStroke
	uIStroke.Color = darkenColor(v6.Color, 0.3)
end

parent.Enabled = false
local thread = nil

local function updateSizes()
	local viewportSize = currentCamera.ViewportSize
	local v6 = (viewportSize.X + viewportSize.Y) / 3000 <= 0.55
	local v7 = viewportSize.X / 1920
	local v8

	if v6 then
		v8 = v7 * 128
	else
		v8 = v7 * 108
	end

	local uDim = UDim.new(0, -v8 / 5)
	local uDim2 = UDim2.new(0, v8, 1, 0)
	parent.Frame.Team1.UIListLayout.Padding = uDim
	parent.Frame.Team2.UIListLayout.Padding = uDim

	for _, v9 in v3 do
		for _, guiObject in v9:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject.Size = uDim2
			end
		end
	end

	instructionFrame.Size = UDim2.fromScale(1, v6 and 0.03 or 0.02)
	thread = nil
end

task.spawn(updateSizes)
currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	if thread then
		task.cancel(thread)
	end

	thread = task.delay(1, updateSizes)
end)
instructionFrame.Reward:GetPropertyChangedSignal("Text"):Connect(updateSizes)

for _, v6 in v3 do
	if v then
		v6.Visible = false
	else
		v6.ChildAdded:Connect(updateSizes)
		v6.ChildRemoved:Connect(updateSizes)
	end
end

frame.Visible = not v
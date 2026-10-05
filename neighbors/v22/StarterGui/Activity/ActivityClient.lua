local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local Network = require(ReplicatedStorage.Modules.Network)
local UI = require(ReplicatedStorage.Modules.UI)
require(ReplicatedStorage.Modules.Server)
require(ReplicatedStorage.Modules.Gamepad)
local leave = script.Parent:WaitForChild("Leave")
local modulesByName = {}
local framesByName = {}
local inActivity = nil
local v = {}

for _, moduleScript in script.Activities:GetChildren() do
	local name = moduleScript.Name
	local module = require(moduleScript)
	modulesByName[name] = module
end

for _, frame in script.Parent.Activities:GetChildren() do
	if frame:IsA("Frame") then
		framesByName[frame.Name] = frame
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function initializePrompt(joinActivity)
	if not joinActivity:GetAttribute("Distance") then
		joinActivity:SetAttribute("Distance", joinActivity.MaxActivationDistance)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setPromptEnabled(joinActivity, p)
	joinActivity.MaxActivationDistance = not p and 0 or joinActivity:GetAttribute("Distance") or 0
end

local function stopCurrentActivity()
	if inActivity then
		if framesByName[inActivity] then
			framesByName[inActivity].Visible = false
		end

		if modulesByName[inActivity] then
			local v2 = modulesByName[inActivity]

			if v2.Signals then
				for _, signal in v2.Signals do
					signal:disconnect()
				end
			end

			if v2.Stop then
				v2:Stop()
			end
		end
	end

	inActivity = nil
end

local function updateActivity(instance)
	if instance.PrimaryPart then
		local character = game.Players.LocalPlayer.Character
		local v2 = character and not character:GetAttribute("InActivity")
		local joinActivity = instance.PrimaryPart:FindFirstChild("JoinActivity")

		if joinActivity then
			initializePrompt(joinActivity) -- equivalent call inferred; original call site unknown
			setPromptEnabled(joinActivity, v2) -- equivalent call inferred; original call site unknown
		end
	end
end

local function update()
	local character = game.Players.LocalPlayer.Character

	if character then
		local _ = not character:GetAttribute("InActivity")
	end

	leave.Visible = character and character:GetAttribute("InActivity") == true
	stopCurrentActivity()
	inActivity = character:GetAttribute("InActivity")

	if character:GetAttribute("InActivity") == "MemoryTiles" then
		leave.Visible = true
	end

	if framesByName[inActivity] then
		framesByName[inActivity].Visible = true
	end

	if inActivity and modulesByName[inActivity] and modulesByName[inActivity].Start then
		modulesByName[inActivity]:Start()
	end

	for _, v2 in CollectionService:GetTagged("Activity") do
		updateActivity(v2)
	end
end

local function getCharacterInfo(p)
	return v[p]
end

local function registerCharacter(character)
	if character == game.Players.LocalPlayer.Character then
		character:GetAttributeChangedSignal("InActivity"):connect(update)
		update()
	end

	local v2 = {
		Character = character,
		Humanoid = character:WaitForChild("Humanoid"),
		Player = game.Players:GetPlayerFromCharacter(character),
		Offset = os.clock(),
		Activity = nil
	}
	v[character] = v2

	local function update_activity()
		if v2.Activity and modulesByName[v2.Activity] and modulesByName[v2.Activity].DestroyPlayer then
			modulesByName[v2.Activity]:DestroyPlayer(v2)
		end

		v2.Activity = character:GetAttribute("InActivity")

		if modulesByName[v2.Activity] and modulesByName[v2.Activity].RegisterPlayer then
			modulesByName[v2.Activity]:RegisterPlayer(v2)
		end
	end

	character:GetAttributeChangedSignal("InActivity"):connect(update_activity)
	character.AncestryChanged:connect(function(_, p)
		if not p then
			v[character] = nil
			table.clear(v2)
		end
	end)
	return update_activity()
end

local function register_player(player)
	player.CharacterAdded:connect(registerCharacter)

	if player.Character then
		return registerCharacter(player.Character)
	end
end

for _, v2 in modulesByName do
	function v2.GetCharacterData(_, p)
		return v[p]
	end
end

CollectionService:GetInstanceAddedSignal("Activity"):connect(updateActivity)
local RunService = game:GetService("RunService")
RunService.Heartbeat:connect(function(p)
	for _, v2 in v do
		local v3 = modulesByName[v2.Activity]

		if v2.Activity and v3 and v3.Loop then
			v3.Loop(v3, v2, p)
		end
	end
end)
leave.Button.MouseButton1Click:connect(function()
	Network:fire("LeaveActivity")
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.ButtonB and leave.Visible then
		Network:fire("LeaveActivity")
	end
end)
UI:Bind(leave.Button)
UI:RegisterUIScale(script.Parent.Activities:WaitForChild("UIScale"))
game.Players.PlayerAdded:connect(register_player)

for _, v2 in game.Players:GetPlayers() do
	task.spawn(register_player, v2)
end
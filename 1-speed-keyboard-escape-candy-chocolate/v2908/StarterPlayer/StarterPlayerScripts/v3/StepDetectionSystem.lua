local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local UpgradeMultipliers = require(ReplicatedStorage._FRAMEWORK.Libraries.UpgradeMultipliers)
local NotificationSystem = require(ReplicatedStorage:WaitForChild("NotificationSystem"))
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local localPlayer = Players.LocalPlayer
local updateSpeed = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UpdateSpeed")
local v = 0
local v2 = localPlayer.UserId ~= 3845375404

if localPlayer.UserId == 3845375404 then
	local textChatCommand = Instance.new("TextChatCommand")
	textChatCommand.Name = "ProgressionToggle"
	textChatCommand.PrimaryAlias = "/progression"
	textChatCommand.Parent = TextChatService
	textChatCommand.Triggered:Connect(function()
		v2 = not v2
		local v3 = v2 and "ACTIVÉE" or "DÉSACTIVÉE"
		print("[Admin] Progression " .. v3)
	end)
end

RunService.Heartbeat:Connect(function()
	if not v2 then
		return
	end

	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local v3 = ClientState:Get()

	if not humanoid or humanoid.Health <= 0 or v3.onTreadmill then
		return
	end

	if humanoid.MoveDirection.Magnitude > 0 then
		local now = os.clock()
		local XP_TIME_BASED = Config.XP_TIME_BASED
		local v4 = math.clamp(
			(humanoid.WalkSpeed - XP_TIME_BASED.MIN_SPEED) / (XP_TIME_BASED.MAX_SPEED - XP_TIME_BASED.MIN_SPEED),
			0,
			1
		)

		if XP_TIME_BASED.MAX_COOLDOWN - v4 * (XP_TIME_BASED.MAX_COOLDOWN - XP_TIME_BASED.MIN_COOLDOWN) <= now - v then
			updateSpeed:FireServer("Walking")
			local v5 = ClientState:Get()
			local equippedTrail = v5.EquippedTrail or "None"
			local trail = UpgradeMultipliers.trail(equippedTrail)
			NotificationSystem:ShowPlusOne(v5.StepBonus, v5.SpeedBoostMultiplier, trail, 1, v5.BonusXPMultiplier or 1)
			v = now
		end
	else
		v = 0
	end
end)
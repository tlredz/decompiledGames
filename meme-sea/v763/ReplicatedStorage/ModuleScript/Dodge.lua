local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local Setting = require(moduleScript:WaitForChild("Setting"))
local FXModule = require(moduleScript:WaitForChild("FXModule"))
local SetText = require(moduleScript:WaitForChild("SetText"))
local animation_Folder = ReplicatedStorage.Animation_Folder
local ability = otherEvent.MainEvents:WaitForChild("Ability")
local v = { animation_Folder.Dodge:FindFirstChild("Dodge"), animation_Folder.Dodge:FindFirstChild("Dodge2") }
return {
	Dodge = function(instance, p)
		local v2 = math.floor(p)
		local v3 = (v2 == nil or v2 > 1) and 1 or v2
		local playerFromCharacter = instance and Players:GetPlayerFromCharacter(instance)

		if playerFromCharacter then
			local dodge = instance:FindFirstChild("Dodge")
			local humanoid = instance:FindFirstChild("Humanoid")
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
			local playerData = playerFromCharacter:WaitForChild("PlayerData")
			local dodgeLevel = playerData:WaitForChild("DodgeLevel")
			local dodgeExp = playerData:WaitForChild("DodgeExp")

			if dodge and dodge.Value > 0 and playerFromCharacter:GetAttribute("UsedDodge") == true then
				dodge.Value -= v3
				FXModule.Dodge(humanoidRootPart, dodge.Value, dodgeLevel.Value * Setting.Setting.DodgeMultiplier)
				humanoid:LoadAnimation(v[math.random(1, #v)]):Play()
				dodgeExp.Value += 1
			elseif dodge.Value <= 0 and playerFromCharacter and playerFromCharacter:GetAttribute("UsedDodge") == true then
				ability:InvokeClient(playerFromCharacter, "DodgeBroke")
				SetText.SetText(playerFromCharacter, "CustomMessage", "< No Dodge Left! >", Color3.fromRGB(196, 40, 28))
			end

			if dodge and dodge.Value and dodgeLevel and dodgeLevel.Value then
				return dodge.Value, dodgeLevel.Value * 10 or 0, 10
			end
		end
	end
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
game:GetService("GuiService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
ReplicatedStorage:WaitForChild("Modules")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local animation_Folder = ReplicatedStorage:WaitForChild("Animation_Folder")
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
animation_Folder:WaitForChild("Skill_Animation")
local skillEvents = otherEvent:WaitForChild("SkillEvents")
local secretEvents = otherEvent:WaitForChild("SecretEvents")
workspace:WaitForChild("Character")
localPlayer:WaitForChild("PlayerGui", 60):WaitForChild("CooldownGui", 15):WaitForChild("Container", 15)
local server_Skills = skillEvents:WaitForChild("Server_Skills")
local freeMoney = secretEvents:WaitForChild("FreeMoney")
local Generate = require(moduleScript:WaitForChild("Generate"))
require(moduleScript:WaitForChild("ItemSettings"))
require(moduleScript:WaitForChild("Cooldown_Module"))
local _ = workspace.CurrentCamera

function Z_Release(player, _, _, p, p2, p3, p4, _)
	local character = player.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChild("Humanoid")
	end

	if character then
		character:FindFirstChild("HumanoidRootPart")
	end

	if humanoid then
		humanoid:FindFirstChild("Animator")
	end

	local cooldown = player:FindFirstChild("Cooldown")
	player:FindFirstChild("PlayerGui")

	if Generate.CheckIfAlive(character) and Generate.CheckExist(cooldown) and Generate.CheckTool(p) and Generate.IsReady(character) and character:GetAttribute("Holding") == "None" and cooldown:FindFirstChild((`{p2}_{p3}`)) == nil then
		local hotkey_Frame = Generate.Hotkey_Frame(player, p2, p3, "Cooldown")

		if hotkey_Frame then
			hotkey_Frame.Visible = true
		end

		server_Skills:FireServer(character, p.Name, p3, "Release")

		if p4 then
			p4.BackgroundTransparency = 1
			freeMoney:FireServer("Mobile_Button", nil)
		end

		local hotkey_Frame2 = Generate.Hotkey_Frame(player, p2, p3, "Hotkey")

		if hotkey_Frame2 then
			hotkey_Frame2:SetAttribute("Cooldown", true)
		end
	end
end

return {
	Z = {
		Hold = function(p, p2, p3, p4, p5, p6, p7, p8)
			Z_Release(p, p2, p3, p4, p5, p6, p7, p8)
		end
	}
}
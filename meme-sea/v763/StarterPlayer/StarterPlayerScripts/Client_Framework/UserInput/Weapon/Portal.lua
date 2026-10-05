local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage:WaitForChild("Modules")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local animation_Folder = ReplicatedStorage:WaitForChild("Animation_Folder")
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
animation_Folder:WaitForChild("Skill_Animation")
local skillEvents = otherEvent:WaitForChild("SkillEvents")
local secretEvents = otherEvent:WaitForChild("SecretEvents")
local server_Skills = skillEvents:WaitForChild("Server_Skills")
local freeMoney = secretEvents:WaitForChild("FreeMoney")
local Generate = require(moduleScript:WaitForChild("Generate"))
require(moduleScript:WaitForChild("ItemSettings"))
require(moduleScript:WaitForChild("PlaySound"))

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
	local playerGui = player:FindFirstChild("PlayerGui")
	local portalGui

	if playerGui then
		portalGui = playerGui:FindFirstChild("PortalGui")
	end

	if Generate.CheckIfAlive(character) and portalGui and Generate.CheckExist(cooldown) and Generate.CheckTool(p) and cooldown:FindFirstChild((`{p2}_{p3}`)) == nil and Generate.IsReady(character) and character:GetAttribute("Holding") == "None" then
		server_Skills:FireServer(character, p.Name, p3, "Hold")
		character:SetAttribute("Portal_Teleporting", "None")
		portalGui.Enabled = true
		local hotkey_Frame = Generate.Hotkey_Frame(player, p2, p3, "Cooldown")

		if hotkey_Frame then
			hotkey_Frame.Visible = true
		end

		local _ = humanoid.Health
		local _ = p.Name
		local lastTime = tick()

		while task.wait(0.1) and Generate.CheckIfAlive(character) and character:GetAttribute("Portal_Teleporting") == "None" and not (tick() - lastTime >= 60) do

		end

		if portalGui.Enabled then
			portalGui.Enabled = false
		end

		server_Skills:FireServer(character, p.Name, p3, "Release", {
			Location = character:GetAttribute("Portal_Teleporting")
		})

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
local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
game:GetService("RunService")
local GuiService = game:GetService("GuiService")
ReplicatedStorage:WaitForChild("Modules")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local animation_Folder = ReplicatedStorage:WaitForChild("Animation_Folder")
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local skill_Animation = animation_Folder:WaitForChild("Skill_Animation")
local skillEvents = otherEvent:WaitForChild("SkillEvents")
local secretEvents = otherEvent:WaitForChild("SecretEvents")
local server_Skills = skillEvents:WaitForChild("Server_Skills")
local freeMoney = secretEvents:WaitForChild("FreeMoney")
local Generate = require(moduleScript:WaitForChild("Generate"))
require(moduleScript:WaitForChild("ItemSettings"))
local currentCamera = workspace.CurrentCamera

function V_Release(player, _, _, p, p2, p3, p4, _)
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

	if Generate.CheckIfAlive(character) and Generate.CheckExist(cooldown) and Generate.CheckTool(p) and cooldown:FindFirstChild((`{p2}_{p3}`)) == nil and Generate.IsReady(character) and character:GetAttribute("Holding") == "None" then
		server_Skills:FireServer(character, p.Name, p3, "Release")
		local hotkey_Frame = Generate.Hotkey_Frame(player, p2, p3, "Cooldown")

		if hotkey_Frame then
			hotkey_Frame.Visible = true
		end

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

function C_Hold(player, p, mouse_Position, instance, p3, p4, p5, p6)
	local character = player.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChild("Humanoid")
	end

	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	local animator

	if humanoid then
		animator = humanoid:FindFirstChild("Animator")
	end

	local cooldown = player:FindFirstChild("Cooldown")

	if Generate.CheckIfAlive(character) and humanoid and Generate.CheckExist(cooldown) and Generate.CheckTool(instance) and instance:GetAttribute("Step") == 1 and cooldown:FindFirstChild((`{p3}_{p4}`)) == nil and cooldown:FindFirstChild((`{p3}_{p4}_Holding`)) == nil and Generate.IsReady(character) and character:GetAttribute("Holding") == "None" then
		character:SetAttribute("Holding", (`{p3}_{p4}`))
		instance:SetAttribute("Step", 2)

		if p6 then
			server_Skills:FireServer(character, instance.Name, p4, "Hold", {
				Mouse_Position = p6.Position
			})
		else
			server_Skills:FireServer(character, instance.Name, p4, "Hold", {
				Mouse_Position = mouse_Position
			})
		end

		Generate.Skill_Holding(humanoidRootPart)
		Generate.Stunning(humanoid, "Unspeed")
		humanoid.AutoRotate = false
		humanoid.PlatformStand = true

		if animator then
			animator:LoadAnimation(skill_Animation[p3][instance.Name][p4].Release):Play()
		end

		local hotkey_Frame = Generate.Hotkey_Frame(player, p3, p4, "Cooldown")

		if hotkey_Frame then
			hotkey_Frame.Visible = true
		end

		local health = humanoid.Health
		local lastTime = tick()

		while task.wait() and Generate.CheckIfAlive(character) and Generate.CheckTool(instance) and instance:GetAttribute("Step") ~= 1 do
			if health < humanoid.Health then
				health = humanoid.Health
			end

			if instance.Parent ~= character or humanoid.Health < health or tick() - lastTime >= 2 then
				break
			end

			if _G.MobileShiftlock and currentCamera then
				local vector2 = Vector2.new(
					currentCamera.ViewportSize.X / 2,
					currentCamera.ViewportSize.Y / 2 - GuiService:GetGuiInset().Y / 2.1
				)
				local viewportPointToRay = currentCamera:ViewportPointToRay(vector2.X, vector2.Y)

				if viewportPointToRay then
					local hit_Position = Generate.Hit_Position(viewportPointToRay, character, 500)

					if hit_Position then
						humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
						humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
						humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, hit_Position)
					end
				end
			else
				local mouseLocation = UserInputService:GetMouseLocation()
				local viewportPointToRay = currentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)

				if viewportPointToRay then
					local hit_Position = Generate.Hit_Position(viewportPointToRay, character, 500)

					if hit_Position then
						humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
						humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
						humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, hit_Position)
					end
				end
			end
		end

		if instance:GetAttribute("Step") == 2 then
			C_Release(player, p, mouse_Position, instance, p3, p4, p5, p6)
		end

		if humanoid and humanoid.Parent then
			humanoid.AutoRotate = true
			humanoid.PlatformStand = false
		end
	end
end

function C_Release(player, _, _, instance, p, p2, p3, _)
	local character = player.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChild("Humanoid")
	end

	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	local animator

	if humanoid then
		animator = humanoid:FindFirstChild("Animator")
	end

	local cooldown = player:FindFirstChild("Cooldown")

	if Generate.CheckExist(cooldown) and Generate.CheckExist(instance) and instance:GetAttribute("Step") == 2 and character:GetAttribute("Holding") == `{p}_{p2}` then
		character:SetAttribute("Holding", "None")
		instance:SetAttribute("Step", 1)

		if animator then
			for _, v in ipairs(animator:GetPlayingAnimationTracks()) do
				if v.Name == "Release" then
					v:Stop()
				end
			end
		end

		if p3 then
			p3.BackgroundTransparency = 1
			freeMoney:FireServer("Mobile_Button", nil)
		end

		Generate.ClearBV(humanoidRootPart)
		Generate.Stunning(humanoid, "Speed")

		if humanoid and humanoid.Parent then
			humanoid.AutoRotate = true
			humanoid.PlatformStand = false
		end

		server_Skills:FireServer(character, instance.Name, p2, "Release")
		local hotkey_Frame = Generate.Hotkey_Frame(player, p, p2, "Hotkey")

		if hotkey_Frame then
			hotkey_Frame:SetAttribute("Cooldown", true)
		end
	end
end

function X_Hold(player, p, p2, instance, p3, p4, p5, p6)
	local character = player.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChild("Humanoid")
	end

	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	local animator

	if humanoid then
		animator = humanoid:FindFirstChild("Animator")
	end

	local cooldown = player:FindFirstChild("Cooldown")

	if Generate.CheckIfAlive(character) and humanoid and Generate.CheckExist(cooldown) and Generate.CheckTool(instance) and instance:GetAttribute("Step") == 1 and cooldown:FindFirstChild((`{p3}_{p4}`)) == nil and cooldown:FindFirstChild((`{p3}_{p4}_Holding`)) == nil and Generate.IsReady(character) and character:GetAttribute("Holding") == "None" then
		character:SetAttribute("Holding", (`{p3}_{p4}`))
		instance:SetAttribute("Step", 2)
		server_Skills:FireServer(character, instance.Name, p4, "Hold")
		Generate.Stunning(humanoidRootPart, "Anchored")
		humanoid.AutoRotate = false
		humanoid.PlatformStand = true

		if animator then
			animator:LoadAnimation(skill_Animation[p3][instance.Name][p4].Hold):Play()
		end

		local hotkey_Frame = Generate.Hotkey_Frame(player, p3, p4, "Cooldown")

		if hotkey_Frame then
			hotkey_Frame.Visible = true
		end

		local health = humanoid.Health
		local name = instance.Name
		local lastTime = tick()

		while task.wait() and Generate.CheckIfAlive(character) and Generate.Tool_Equipped(character, name) and instance:GetAttribute("Step") ~= 1 do
			if health < humanoid.Health then
				health = humanoid.Health
			end

			if instance.Parent ~= character or humanoid.Health < health or tick() - lastTime >= 60 then
				break
			end

			if _G.MobileShiftlock and currentCamera then
				humanoidRootPart.CFrame = CFrame.new(
					humanoidRootPart.Position,
					currentCamera.CFrame.Position + currentCamera.CFrame.LookVector * 500
				)
			else
				humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, p.Hit.Position)
			end
		end

		if instance:GetAttribute("Step") == 2 then
			if Generate.CheckExist(instance) then
				X_Release(player, p, p2, instance, p3, p4, p5, p6)
			else
				local child = player.Backpack:FindFirstChild(name)

				if child then
					X_Release(player, p, p2, child, p3, p4, p5, p6)
				end
			end
		end

		if humanoid and humanoid.Parent then
			humanoid.AutoRotate = true
			humanoid.PlatformStand = false
		end
	end
end

function X_Release(player, _, mouse_Position, instance, p2, p3, p4, p5)
	local character = player.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChild("Humanoid")
	end

	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	local animator

	if humanoid then
		animator = humanoid:FindFirstChild("Animator")
	end

	local cooldown = player:FindFirstChild("Cooldown")

	if Generate.CheckExist(cooldown) and Generate.CheckExist(instance) and instance:GetAttribute("Step") == 2 and character:GetAttribute("Holding") == `{p2}_{p3}` then
		character:SetAttribute("Holding", "None")
		instance:SetAttribute("Step", 1)
		Generate.Stunning(humanoidRootPart, "Unanchored")

		if animator then
			for _, v in ipairs(animator:GetPlayingAnimationTracks()) do
				if v.Name == "Hold" then
					v:Stop()
				end
			end
		end

		if p4 then
			p4.BackgroundTransparency = 1
			freeMoney:FireServer("Mobile_Button", nil)
		end

		if p5 then
			server_Skills:FireServer(character, instance.Name, p3, "Release", {
				Mouse_Position = p5.Position
			})
		else
			server_Skills:FireServer(character, instance.Name, p3, "Release", {
				Mouse_Position = mouse_Position
			})
		end

		local hotkey_Frame = Generate.Hotkey_Frame(player, p2, p3, "Hotkey")

		if hotkey_Frame then
			hotkey_Frame:SetAttribute("Cooldown", true)
		end
	end
end

function Z_Hold(player, p, p2, instance, p3, p4, p5, p6)
	local character = player.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChild("Humanoid")
	end

	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	local animator

	if humanoid then
		animator = humanoid:FindFirstChild("Animator")
	end

	local cooldown = player:FindFirstChild("Cooldown")

	if Generate.CheckIfAlive(character) and humanoid and Generate.CheckExist(cooldown) and Generate.CheckTool(instance) and instance:GetAttribute("Step") == 1 and cooldown:FindFirstChild((`{p3}_{p4}`)) == nil and cooldown:FindFirstChild((`{p3}_{p4}_Holding`)) == nil and Generate.IsReady(character) and character:GetAttribute("Holding") == "None" then
		character:SetAttribute("Holding", (`{p3}_{p4}`))
		instance:SetAttribute("Step", 2)
		server_Skills:FireServer(character, instance.Name, p4, "Hold")
		Generate.Stunning(humanoidRootPart, "Anchored")
		humanoid.AutoRotate = false
		humanoid.PlatformStand = true

		if animator then
			animator:LoadAnimation(skill_Animation[p3][instance.Name][p4].Hold):Play()
		end

		local hotkey_Frame = Generate.Hotkey_Frame(player, p3, p4, "Cooldown")

		if hotkey_Frame then
			hotkey_Frame.Visible = true
		end

		local health = humanoid.Health
		local name = instance.Name
		local lastTime = tick()

		while task.wait() and Generate.CheckIfAlive(character) and Generate.Tool_Equipped(character, name) and instance:GetAttribute("Step") ~= 1 do
			if health < humanoid.Health then
				health = humanoid.Health
			end

			if instance.Parent ~= character or humanoid.Health < health or tick() - lastTime >= 60 then
				break
			end

			if _G.MobileShiftlock and currentCamera then
				humanoidRootPart.CFrame = CFrame.new(
					humanoidRootPart.Position,
					currentCamera.CFrame.Position + currentCamera.CFrame.LookVector * 500
				)
			else
				humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, p.Hit.Position)
			end
		end

		if instance:GetAttribute("Step") == 2 then
			if Generate.CheckExist(instance) then
				Z_Release(player, p, p2, instance, p3, p4, p5, p6)
			else
				local child = player.Backpack:FindFirstChild(name)

				if child then
					Z_Release(player, p, p2, child, p3, p4, p5, p6)
				end
			end
		end

		if humanoid and humanoid.Parent then
			humanoid.AutoRotate = true
			humanoid.PlatformStand = false
		end
	end
end

function Z_Release(player, _, mouse_Position, instance, p2, p3, p4, p5)
	local character = player.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChild("Humanoid")
	end

	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	local animator

	if humanoid then
		animator = humanoid:FindFirstChild("Animator")
	end

	local cooldown = player:FindFirstChild("Cooldown")

	if Generate.CheckExist(cooldown) and Generate.CheckExist(instance) and instance:GetAttribute("Step") == 2 and character:GetAttribute("Holding") == `{p2}_{p3}` then
		character:SetAttribute("Holding", "None")
		instance:SetAttribute("Step", 1)
		Generate.Stunning(humanoidRootPart, "Unanchored")

		if animator then
			for _, v in ipairs(animator:GetPlayingAnimationTracks()) do
				if v.Name == "Hold" then
					v:Stop()
				end
			end
		end

		if p4 then
			p4.BackgroundTransparency = 1
			freeMoney:FireServer("Mobile_Button", nil)
		end

		if p5 then
			server_Skills:FireServer(character, instance.Name, p3, "Release", {
				Mouse_Position = p5.Position
			})
		else
			server_Skills:FireServer(character, instance.Name, p3, "Release", {
				Mouse_Position = mouse_Position
			})
		end

		local hotkey_Frame = Generate.Hotkey_Frame(player, p2, p3, "Hotkey")

		if hotkey_Frame then
			hotkey_Frame:SetAttribute("Cooldown", true)
		end
	end
end

return {
	Z = {
		Hold = function(p, p2, p3, p4, p5, p6, p7, p8)
			Z_Hold(p, p2, p3, p4, p5, p6, p7, p8)
		end,
		Release = function(p, p2, p3, p4, p5, p6, p7, p8)
			Z_Release(p, p2, p3, p4, p5, p6, p7, p8)
		end
	},
	X = {
		Hold = function(p, p2, p3, p4, p5, p6, p7, p8)
			X_Hold(p, p2, p3, p4, p5, p6, p7, p8)
		end,
		Release = function(p, p2, p3, p4, p5, p6, p7, p8)
			X_Release(p, p2, p3, p4, p5, p6, p7, p8)
		end
	},
	C = {
		Hold = function(p, p2, p3, p4, p5, p6, p7, p8)
			C_Hold(p, p2, p3, p4, p5, p6, p7, p8)
		end,
		Release = function(p, p2, p3, p4, p5, p6, p7, p8)
			C_Release(p, p2, p3, p4, p5, p6, p7, p8)
		end
	},
	V = {
		Hold = function(p, p2, p3, p4, p5, p6, p7, p8)
			V_Release(p, p2, p3, p4, p5, p6, p7, p8)
		end
	}
}
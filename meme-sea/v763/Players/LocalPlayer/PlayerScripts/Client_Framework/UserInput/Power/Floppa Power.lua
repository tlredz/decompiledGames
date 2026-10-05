local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
ReplicatedStorage:WaitForChild("Modules")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local animation_Folder = ReplicatedStorage:WaitForChild("Animation_Folder")
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local skill_Animation = animation_Folder:WaitForChild("Skill_Animation")
local skillEvents = otherEvent:WaitForChild("SkillEvents")
local secretEvents = otherEvent:WaitForChild("SecretEvents")
local container = localPlayer:WaitForChild("PlayerGui", 60):WaitForChild("CooldownGui", 15):WaitForChild(
	"Container",
	15
)
local server_Skills = skillEvents:WaitForChild("Server_Skills")
local freeMoney = secretEvents:WaitForChild("FreeMoney")
local Generate = require(moduleScript:WaitForChild("Generate"))
local ItemSettings = require(moduleScript:WaitForChild("ItemSettings"))
local Cooldown_Module = require(moduleScript:WaitForChild("Cooldown_Module"))
local currentCamera = workspace.CurrentCamera

function F_Hold(player, p, p2, instance, p3, p4, p5, p6)
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
		Generate.ClearBV(humanoidRootPart)
		character:SetAttribute("Holding", (`{p3}_{p4}`))
		instance:SetAttribute("Step", 2)
		server_Skills:FireServer(character, instance.Name, p4, "Hold")
		humanoid.AutoRotate = false
		humanoid.PlatformStand = true
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

		if animator then
			animator:LoadAnimation(skill_Animation[p3][instance.Name][p4].Hold):Play()
		end

		local hotkey_Frame = Generate.Hotkey_Frame(player, p3, p4, "Cooldown")

		if hotkey_Frame then
			hotkey_Frame.Visible = true
		end

		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(50000, 50000, 50000)
		bodyVelocity.Parent = humanoidRootPart
		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = createVector(50000, 50000, 50000)
		bodyGyro.P = 100000
		bodyGyro.Parent = humanoidRootPart
		local health = humanoid.Health
		local name = instance.Name
		local v = ItemSettings[instance.Name][p4]
		local lastTime = os.time()
		local v2 = humanoid.Health / humanoid.MaxHealth

		if container then
			if player:GetAttribute("TH") then
				Cooldown_Module.SetCooldown_Bar("Flight", 60, "Floppa Flight", container, true, true)
			else
				Cooldown_Module.SetCooldown_Bar("Flight", 60, "Floppa Flight", container, false, true)
			end
		end

		while task.wait() and Generate.CheckIfAlive(character) and Generate.Tool_Equipped(character, name) and instance:GetAttribute("Step") ~= 1 do
			if health < humanoid.Health then
				health = humanoid.Health
			end

			if instance.Parent ~= character or humanoid.Health < health or os.time() - lastTime >= 60 then
				break
			end

			if _G.MobileShiftlock and currentCamera then
				local vector2 = Vector2.new(
					currentCamera.ViewportSize.X / 2,
					currentCamera.ViewportSize.Y / 2 - GuiService:GetGuiInset().Y / 2.1
				)
				local viewportPointToRay = currentCamera:ViewportPointToRay(vector2.X, vector2.Y)
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {
					character,
					workspace.Skills,
					workspace.Region,
					workspace.Visuals,
					workspace.Location,
					workspace.Sea,
					workspace.Leaderboard,
					workspace.CameraFolder,
					workspace.SpawningPower,
					workspace.Character,
					workspace.Monster,
					workspace.Island,
					workspace.Raids
				}
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude

				if viewportPointToRay then
					local hit_Position = Generate.Hit_Position(viewportPointToRay, raycastParams, 500)

					if hit_Position then
						bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, hit_Position)
						bodyVelocity.Velocity = CFrame.new(humanoidRootPart.Position, hit_Position).LookVector * (v.Flying_Speed * math.clamp(
							v2,
							0.25,
							1
						))
					end
				end
			else
				local mouseLocation = UserInputService:GetMouseLocation()
				local viewportPointToRay = currentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {
					character,
					workspace.Skills,
					workspace.Region,
					workspace.Visuals,
					workspace.Location,
					workspace.Sea,
					workspace.Leaderboard,
					workspace.CameraFolder,
					workspace.SpawningPower,
					workspace.Character,
					workspace.Monster,
					workspace.Island,
					workspace.Raids
				}
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude

				if viewportPointToRay then
					local hit_Position = Generate.Hit_Position(viewportPointToRay, raycastParams, 500)

					if hit_Position then
						bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, hit_Position)
						bodyVelocity.Velocity = CFrame.new(humanoidRootPart.Position, hit_Position).LookVector * (v.Flying_Speed * math.clamp(
							v2,
							0.25,
							1
						))
					end
				end
			end
		end

		if instance:GetAttribute("Step") == 2 then
			if Generate.CheckExist(instance) then
				F_Release(player, p, p2, instance, p3, p4, p5, p6)
			else
				local child = player.Backpack:FindFirstChild(name)

				if child then
					F_Release(player, p, p2, child, p3, p4, p5, p6)
				end
			end
		end

		if humanoid and humanoid.Parent then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
			humanoid.AutoRotate = true
			humanoid.PlatformStand = false
		end
	end
end

function F_Release(player, _, mouse_Position, instance, p2, p3, p4, p5)
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

	if humanoid and Generate.CheckExist(cooldown) and Generate.CheckExist(instance) and instance:GetAttribute("Step") == 2 and character:GetAttribute("Holding") == `{p2}_{p3}` then
		character:SetAttribute("Holding", "None")
		instance:SetAttribute("Step", 1)
		Generate.ClearBV(humanoidRootPart)

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

		local flight_Template = container and container:FindFirstChild("Flight_Template")

		if flight_Template then
			flight_Template:Destroy()
		end
	end
end

function V_Hold(player, p, p2, instance, p3, p4, p5, p6)
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
				V_Release(player, p, p2, instance, p3, p4, p5, p6)
			else
				local child = player.Backpack:FindFirstChild(name)

				if child then
					V_Release(player, p, p2, child, p3, p4, p5, p6)
				end
			end
		end

		if humanoid and humanoid.Parent then
			humanoid.AutoRotate = true
			humanoid.PlatformStand = false
		end
	end
end

function V_Release(player, _, mouse_Position, instance, p2, p3, p4, p5)
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
			if _G.MobileShiftlock then
				local vector2 = Vector2.new(
					currentCamera.ViewportSize.X / 2,
					currentCamera.ViewportSize.Y / 2 - GuiService:GetGuiInset().Y / 2.1
				)
				local viewportPointToRay = currentCamera:ViewportPointToRay(vector2.X, vector2.Y)
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {
					character,
					workspace.Skills,
					workspace.Region,
					workspace.Visuals,
					workspace.Location,
					workspace.Sea,
					workspace.Leaderboard,
					workspace.CameraFolder,
					workspace.SpawningPower
				}
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				local hit_Position = viewportPointToRay and Generate.Hit_Position(
					viewportPointToRay,
					raycastParams,
					ItemSettings[instance.Name][p3].Max_Distance
				)

				if hit_Position then
					server_Skills:FireServer(character, instance.Name, p3, "Release", {
						Mouse_Position = p5.Position,
						Hit_Position = hit_Position
					})
				end
			else
				local mouseLocation = UserInputService:GetMouseLocation()
				local viewportPointToRay = currentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {
					character,
					workspace.Skills,
					workspace.Region,
					workspace.Visuals,
					workspace.Location,
					workspace.Sea,
					workspace.Leaderboard,
					workspace.CameraFolder,
					workspace.SpawningPower
				}
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				local hit_Position = viewportPointToRay and Generate.Hit_Position(
					viewportPointToRay,
					raycastParams,
					ItemSettings[instance.Name][p3].Max_Distance
				)

				if hit_Position then
					server_Skills:FireServer(character, instance.Name, p3, "Release", {
						Mouse_Position = p5.Position,
						Hit_Position = hit_Position
					})
				end
			end
		else
			local mouseLocation = UserInputService:GetMouseLocation()
			local viewportPointToRay = currentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = {
				character,
				workspace.Skills,
				workspace.Region,
				workspace.Visuals,
				workspace.Location,
				workspace.Sea,
				workspace.Leaderboard,
				workspace.CameraFolder,
				workspace.SpawningPower
			}
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			local hit_Position = viewportPointToRay and Generate.Hit_Position(
				viewportPointToRay,
				raycastParams,
				ItemSettings[instance.Name][p3].Max_Distance
			)

			if hit_Position then
				server_Skills:FireServer(character, instance.Name, p3, "Release", {
					Mouse_Position = mouse_Position,
					Hit_Position = hit_Position
				})
			end
		end

		local hotkey_Frame = Generate.Hotkey_Frame(player, p2, p3, "Hotkey")

		if hotkey_Frame then
			hotkey_Frame:SetAttribute("Cooldown", true)
		end
	end
end

function C_Hold(player, p, p2, instance, p3, p4, p5, p6)
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
					(Vector3.new(
						(currentCamera.CFrame.Position + currentCamera.CFrame.LookVector * 500).X,
						humanoidRootPart.Position.Y,
						(currentCamera.CFrame.Position + currentCamera.CFrame.LookVector * 500).Z
					))
				)
			else
				humanoidRootPart.CFrame = CFrame.new(
					humanoidRootPart.Position,
					(Vector3.new(p.Hit.Position.X, humanoidRootPart.Position.Y, p.Hit.Position.Z))
				)
			end
		end

		if instance:GetAttribute("Step") == 2 then
			if Generate.CheckExist(instance) then
				C_Release(player, p, p2, instance, p3, p4, p5, p6)
				return
			end

			local child = player.Backpack:FindFirstChild(name)

			if child then
				C_Release(player, p, p2, child, p3, p4, p5, p6)
			end
		end
	end
end

function C_Release(player, _, mouse_Position, instance, p2, p3, p4, p5)
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

		if humanoid and humanoid.Parent then
			humanoid.AutoRotate = false
			humanoid.PlatformStand = true
		end

		Generate.Skill_Holding(humanoidRootPart)

		if _G.MobileShiftlock and currentCamera then
			local vector2 = Vector2.new(
				currentCamera.ViewportSize.X / 2,
				currentCamera.ViewportSize.Y / 2 - GuiService:GetGuiInset().Y / 2.1
			)
			local viewportPointToRay = currentCamera:ViewportPointToRay(vector2.X, vector2.Y)
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = {
				character,
				workspace.Skills,
				workspace.Region,
				workspace.Visuals,
				workspace.Location,
				workspace.Sea,
				workspace.Leaderboard,
				workspace.CameraFolder,
				workspace.SpawningPower,
				workspace.Character,
				workspace.Monster
			}
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			local v = viewportPointToRay and Generate.Hit_Position(viewportPointToRay, raycastParams, 500)

			if v then
				humanoidRootPart.CFrame = CFrame.new(
					humanoidRootPart.Position,
					(Vector3.new(v.X, humanoidRootPart.Position.Y, v.Z))
				)
				server_Skills:FireServer(character, instance.Name, p3, "Release", {
					Mouse_Position = p5.Position
				})
			end
		else
			local mouseLocation = UserInputService:GetMouseLocation()
			local viewportPointToRay = currentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = {
				character,
				workspace.Skills,
				workspace.Region,
				workspace.Visuals,
				workspace.Location,
				workspace.Sea,
				workspace.Leaderboard,
				workspace.CameraFolder,
				workspace.SpawningPower,
				workspace.Character,
				workspace.Monster
			}
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			local v = viewportPointToRay and Generate.Hit_Position(viewportPointToRay, raycastParams, 500)

			if v then
				humanoidRootPart.CFrame = CFrame.new(
					humanoidRootPart.Position,
					(Vector3.new(v.X, humanoidRootPart.Position.Y, v.Z))
				)
				server_Skills:FireServer(character, instance.Name, p3, "Release", {
					Mouse_Position = mouse_Position
				})
			end
		end

		local _ = humanoid.Health
		local _ = instance.Name
		local lastTime = tick()

		while task.wait(0.1) and not (tick() - lastTime >= 0.5) do

		end

		Generate.ClearBV(humanoidRootPart)

		if humanoid and humanoid.Parent then
			humanoid.AutoRotate = true
			humanoid.PlatformStand = false
		end

		local hotkey_Frame = Generate.Hotkey_Frame(player, p2, p3, "Hotkey")

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
				local vector2 = Vector2.new(
					currentCamera.ViewportSize.X / 2,
					currentCamera.ViewportSize.Y / 2 - GuiService:GetGuiInset().Y / 2.1
				)
				local viewportPointToRay = currentCamera:ViewportPointToRay(vector2.X, vector2.Y)
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {
					character,
					workspace.Skills,
					workspace.Region,
					workspace.Visuals,
					workspace.Location,
					workspace.Sea,
					workspace.Leaderboard,
					workspace.CameraFolder,
					workspace.SpawningPower,
					workspace.Character,
					workspace.Monster
				}
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude

				if viewportPointToRay then
					local hit_Position = Generate.Hit_Position(viewportPointToRay, raycastParams, 500)

					if hit_Position then
						humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, hit_Position)
					end
				end
			else
				local mouseLocation = UserInputService:GetMouseLocation()
				local viewportPointToRay = currentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {
					character,
					workspace.Skills,
					workspace.Region,
					workspace.Visuals,
					workspace.Location,
					workspace.Sea,
					workspace.Leaderboard,
					workspace.CameraFolder,
					workspace.SpawningPower,
					workspace.Character,
					workspace.Monster
				}
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude

				if viewportPointToRay then
					local hit_Position = Generate.Hit_Position(viewportPointToRay, raycastParams, 500)

					if hit_Position then
						humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, hit_Position)
					end
				end
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
				local vector2 = Vector2.new(
					currentCamera.ViewportSize.X / 2,
					currentCamera.ViewportSize.Y / 2 - GuiService:GetGuiInset().Y / 2.1
				)
				local viewportPointToRay = currentCamera:ViewportPointToRay(vector2.X, vector2.Y)
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {
					character,
					workspace.Skills,
					workspace.Region,
					workspace.Visuals,
					workspace.Location,
					workspace.Sea,
					workspace.Leaderboard,
					workspace.CameraFolder,
					workspace.SpawningPower,
					workspace.Character,
					workspace.Monster
				}
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude

				if viewportPointToRay then
					local hit_Position = Generate.Hit_Position(viewportPointToRay, raycastParams, 500)

					if hit_Position then
						humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, hit_Position)
					end
				end
			else
				local mouseLocation = UserInputService:GetMouseLocation()
				local viewportPointToRay = currentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {
					character,
					workspace.Skills,
					workspace.Region,
					workspace.Visuals,
					workspace.Location,
					workspace.Sea,
					workspace.Leaderboard,
					workspace.CameraFolder,
					workspace.SpawningPower,
					workspace.Character,
					workspace.Monster
				}
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude

				if viewportPointToRay then
					local hit_Position = Generate.Hit_Position(viewportPointToRay, raycastParams, 500)

					if hit_Position then
						humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, hit_Position)
					end
				end
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
			V_Hold(p, p2, p3, p4, p5, p6, p7, p8)
		end,
		Release = function(p, p2, p3, p4, p5, p6, p7, p8)
			V_Release(p, p2, p3, p4, p5, p6, p7, p8)
		end
	},
	F = {
		Hold = function(p, p2, p3, p4, p5, p6, p7, p8)
			F_Hold(p, p2, p3, p4, p5, p6, p7, p8)
		end,
		Release = function(p, p2, p3, p4, p5, p6, p7, p8)
			F_Release(p, p2, p3, p4, p5, p6, p7, p8)
		end
	}
}
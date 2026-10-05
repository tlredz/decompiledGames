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
workspace:WaitForChild("Skills")
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

		if animator then
			animator:LoadAnimation(skill_Animation[p3][instance.Name][p4].Hold):Play()
		end

		local hotkey_Frame = Generate.Hotkey_Frame(player, p3, p4, "Cooldown")

		if hotkey_Frame then
			hotkey_Frame.Visible = true
		end

		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.P = 100000
		bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
		bodyVelocity.Parent = humanoidRootPart
		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = createVector(1000000, 1000000, 1000000)
		bodyGyro.D = 5
		bodyGyro.P = 500
		bodyGyro.Parent = humanoidRootPart
		local bodyPosition = Instance.new("BodyPosition")
		bodyPosition.MaxForce = createVector(0, 0, 0)
		bodyPosition.D = 750
		bodyPosition.P = 50000
		bodyPosition.Position = createVector(0, -103, 0)
		bodyPosition.Parent = humanoidRootPart
		Generate.Stunning(humanoid, "Unjump")
		humanoid:SetAttribute("Old_HipHeight", humanoid.HipHeight)
		character:SetAttribute("Dough_Rolling", true)
		humanoid.AutoRotate = false
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
		humanoid.HipHeight = 5
		local health = humanoid.Health
		local name = instance.Name
		local v = ItemSettings[instance.Name][p4]
		local lastTime = os.time()
		local flag = false
		local v2 = humanoid.Health / humanoid.MaxHealth
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { workspace.Island, workspace.Raids }
		raycastParams.FilterType = Enum.RaycastFilterType.Include

		if container then
			if player:GetAttribute("TH") then
				Cooldown_Module.SetCooldown_Bar("Flight", 60, "Dough Roll", container, true, true)
			else
				Cooldown_Module.SetCooldown_Bar("Flight", 60, "Dough Roll", container, false, true)
			end
		end

		while task.wait() and Generate.CheckIfAlive(character) and Generate.Tool_Equipped(character, name) and instance:GetAttribute("Step") ~= 1 do
			if health < humanoid.Health then
				health = humanoid.Health
			end

			if instance.Parent ~= character or humanoid.Health < health or os.time() - lastTime >= 60 then
				break
			end

			if humanoidRootPart.Position.Y <= -103 and character:GetAttribute("Dough_Rolling") and bodyPosition.MaxForce ~= createVector(
				0,
				1000000,
				0
			) then
				bodyPosition.MaxForce = createVector(0, 1000000, 0)
			elseif bodyPosition.MaxForce ~= createVector(0, 0, 0) then
				bodyPosition.MaxForce = createVector(0, 0, 0)
			end

			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position - createVector(0, 2, 0),
				(humanoidRootPart.CFrame * CFrame.new(0, -2, 0)).LookVector * 5,
				raycastParams
			)

			if raycastResult and raycastResult.Instance then
				if not flag then
					humanoid.PlatformStand = true
					flag = true
				end

				local mouseLocation = UserInputService:GetMouseLocation()
				local viewportPointToRay = currentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
				local raycastParams2 = RaycastParams.new()
				raycastParams2.FilterDescendantsInstances = {
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
				raycastParams2.FilterType = Enum.RaycastFilterType.Exclude

				if viewportPointToRay then
					local hit_Position = Generate.Hit_Position(viewportPointToRay, raycastParams2, 500)

					if hit_Position then
						if bodyPosition.MaxForce ~= createVector(0, 0, 0) then
							bodyPosition.MaxForce = createVector(0, 0, 0)
						end

						bodyGyro.CFrame = CFrame.new(
							humanoidRootPart.Position,
							(Vector3.new(hit_Position.X, raycastResult.Position.Y, hit_Position.Z))
						)
						bodyVelocity.MaxForce = createVector(100000, 1000000, 100000)
						bodyVelocity.Velocity = CFrame.new(
							humanoidRootPart.Position,
							(Vector3.new(
								humanoidRootPart.AssemblyLinearVelocity.X,
								raycastResult.Position + raycastResult.Normal,
								humanoidRootPart.AssemblyLinearVelocity.Z
							))
						).LookVector + Vector3.new(0, v.Flying_Speed * math.clamp(v2, 0.25, 1) / 2, 0)
					else
						if bodyPosition.MaxForce ~= createVector(0, 0, 0) then
							bodyPosition.MaxForce = createVector(0, 0, 0)
						end

						bodyGyro.CFrame = CFrame.new(
							humanoidRootPart.Position,
							(Vector3.new(
								humanoidRootPart.CFrame.X,
								humanoidRootPart.Position.Y,
								humanoidRootPart.CFrame.Z
							))
						)
						bodyVelocity.MaxForce = createVector(100000, 1000000, 100000)
						bodyVelocity.Velocity = humanoidRootPart.CFrame.LookVector + Vector3.new(
							0,
							v.Flying_Speed * math.clamp(v2, 0.25, 1) / 2,
							0
						)
					end
				end
			else
				if flag then
					humanoid.PlatformStand = false
					humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
					humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
					flag = false
				end

				if _G.MobileShiftlock and currentCamera then
					local vector2 = Vector2.new(
						currentCamera.ViewportSize.X / 2,
						currentCamera.ViewportSize.Y / 2 - GuiService:GetGuiInset().Y / 2.1
					)
					local viewportPointToRay = currentCamera:ViewportPointToRay(vector2.X, vector2.Y)
					local raycastParams2 = RaycastParams.new()
					raycastParams2.FilterDescendantsInstances = {
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
					raycastParams2.FilterType = Enum.RaycastFilterType.Exclude

					if viewportPointToRay then
						local hit_Position = Generate.Hit_Position(viewportPointToRay, raycastParams2, 500)

						if hit_Position then
							bodyGyro.CFrame = CFrame.new(
								humanoidRootPart.Position,
								(Vector3.new(hit_Position.X, humanoidRootPart.CFrame.Y, hit_Position.Z))
							)
							bodyVelocity.MaxForce = createVector(100000, 0, 100000)
							bodyVelocity.Velocity = humanoidRootPart.CFrame.LookVector * Vector3.new(
								v.Flying_Speed * math.clamp(v2, 0.25, 1),
								0,
								v.Flying_Speed * math.clamp(v2, 0.25, 1)
							)
						end
					end
				else
					local mouseLocation = UserInputService:GetMouseLocation()
					local viewportPointToRay = currentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
					local raycastParams2 = RaycastParams.new()
					raycastParams2.FilterDescendantsInstances = {
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
					raycastParams2.FilterType = Enum.RaycastFilterType.Exclude

					if viewportPointToRay then
						local hit_Position = Generate.Hit_Position(viewportPointToRay, raycastParams2, 500)

						if hit_Position then
							bodyGyro.CFrame = CFrame.new(
								humanoidRootPart.Position,
								(Vector3.new(hit_Position.X, humanoidRootPart.CFrame.Y, hit_Position.Z))
							)
							bodyVelocity.MaxForce = createVector(100000, 0, 100000)
							bodyVelocity.Velocity = humanoidRootPart.CFrame.LookVector * Vector3.new(
								v.Flying_Speed * math.clamp(v2, 0.25, 1),
								0,
								v.Flying_Speed * math.clamp(v2, 0.25, 1)
							)
						end
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
			character:SetAttribute("Dough_Rolling", nil)
			humanoid.AutoRotate = true
			humanoid.PlatformStand = false
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
			Generate.Stunning(humanoid, "Jump")

			if humanoid:GetAttribute("Old_HipHeight") then
				humanoid.HipHeight = humanoid:GetAttribute("Old_HipHeight")
				humanoid:SetAttribute("Old_HipHeight", nil)
			end

			local flight_Template = container and container:FindFirstChild("Flight_Template")

			if flight_Template then
				flight_Template:Destroy()
			end
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

		if humanoid and humanoid.Parent then
			character:SetAttribute("Dough_Rolling", nil)
			humanoid.AutoRotate = true
			humanoid.PlatformStand = false
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
			Generate.Stunning(humanoid, "Jump")

			if humanoid:GetAttribute("Old_HipHeight") then
				humanoid.HipHeight = humanoid:GetAttribute("Old_HipHeight")
				humanoid:SetAttribute("Old_HipHeight", nil)
			end
		end

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
			else
				local child = player.Backpack:FindFirstChild(name)

				if child then
					C_Release(player, p, p2, child, p3, p4, p5, p6)
				end
			end
		end

		if humanoid and humanoid.Parent then
			humanoid.AutoRotate = true
			humanoid.PlatformStand = false
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
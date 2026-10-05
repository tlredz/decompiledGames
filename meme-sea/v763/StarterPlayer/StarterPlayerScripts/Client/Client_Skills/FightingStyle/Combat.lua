local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local currentCamera = workspace.CurrentCamera
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local modules = ReplicatedStorage:WaitForChild("Modules")
ReplicatedStorage:WaitForChild("OtherEvent")
local skillFolder = ReplicatedStorage:WaitForChild("SkillFolder")
local skills = workspace:WaitForChild("Skills")
workspace:WaitForChild("Character")
workspace:WaitForChild("Monster")
local PlaySound = require(moduleScript:WaitForChild("PlaySound"))
local Generate = require(moduleScript:WaitForChild("Generate"))
local Bezier = require(modules:WaitForChild("Bezier"))
local Setting = require(moduleScript:WaitForChild("Setting"))
local _ = Setting.Setting
return {
	Z = {
		Hold = function(enemy: string, sound: string, _: string, data)
			local player_Releaser = data.Player_Releaser
			local skill_Releaser = data.Skill_Releaser
			local releaser_RootPart = data.Releaser_RootPart
			local _ = data.Mouse_Position
			local skill_Info = data.Skill_Info
			local releaser_Id = data.Releaser_Id
			local _ = skill_Info.Moving_Speed
			local duration = skill_Info.Duration
			local cooldown = player_Releaser:FindFirstChild("Cooldown")
			local position = releaser_RootPart.Position
			local _ = releaser_RootPart.CFrame

			if (position - currentCamera.CFrame.Position).Magnitude <= 1000 then
				local leftLowerArm = skill_Releaser:FindFirstChild("LeftLowerArm")
				local clone = skillFolder[enemy][`{sound}_Part`]:Clone()
				clone.Name = `{releaser_Id}_{enemy}_{sound}_Part`
				clone.Parent = skills
				Debris:AddItem(clone, duration + 1)

				for i = 1, 16 do
					if not (cooldown:FindFirstChild((`FightingStyle_{sound}_Holding`)) and Generate.CheckExist(releaser_RootPart)) then
						break
					end

					local clone2 = skillFolder[enemy][sound]:Clone()
					clone2.CanCollide = false
					clone2.Anchored = false
					clone2.Color = leftLowerArm.Color or Color3.fromRGB(163, 162, 165)
					local cframe, cframe2, cframe3, C1

					if i % 2 == 0 then
						cframe = CFrame.new(
							Random.new():NextNumber(-2.5, -3),
							Random.new():NextNumber(-1.5, 1),
							Random.new():NextNumber(0.5, 1.5)
						)
						cframe2 = CFrame.new(
							Random.new():NextNumber(-7.5, 2),
							Random.new():NextNumber(-5.25, 10),
							Random.new():NextNumber(-5.1, -9)
						)
						cframe3 = CFrame.new(
							Random.new():NextNumber(-6, 1),
							Random.new():NextNumber(-5, 3),
							Random.new():NextNumber(-20, -20)
						)
						C1 = CFrame.new(0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0):Inverse()
					else
						cframe = CFrame.new(
							Random.new():NextNumber(2.5, 3),
							Random.new():NextNumber(1, -1.5),
							Random.new():NextNumber(0.5, 1.5)
						)
						cframe2 = CFrame.new(
							Random.new():NextNumber(-2, 7.5),
							Random.new():NextNumber(-5.25, 10),
							Random.new():NextNumber(-5.1, -9)
						)
						cframe3 = CFrame.new(
							Random.new():NextNumber(6, -1),
							Random.new():NextNumber(-5, 3),
							Random.new():NextNumber(-20, -20)
						)
						C1 = CFrame.new(0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0):Inverse() * CFrame.Angles(
							0,
							0,
							3.141592653589793
						)
					end

					local motor6D = Instance.new("Motor6D")
					motor6D.Name = "ArmWeld"
					motor6D.Part0 = releaser_RootPart
					motor6D.Part1 = clone2
					motor6D.C0 = cframe
					motor6D.C1 = C1
					motor6D.Parent = clone2
					clone2.Parent = skills
					Debris:AddItem(clone2, 1)
					PlaySound.PlaySound_Character(skill_Releaser, {
						Folder = "FightingStyle_Sound",
						Enemy = enemy,
						Sound = sound
					})
					Bezier.new(cframe.Position, cframe2.Position, cframe3.Position):CreateCFrameTween(
						motor6D,
						{ "C0" },
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						false
					):Play()
					TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
					task.wait(0.1)
				end
			end
		end,
		Hitted = function(enemy: string, p2: string, _: string, data)
			local _ = data.Releaser_Character
			local releaser_Id = data.Releaser_Id
			local hit_Character = data.Hit_Character
			local child = skills:FindFirstChild((`{releaser_Id}_{enemy}_{p2}_Part`))

			if hit_Character and hit_Character.Parent and child then
				local humanoidRootPart = hit_Character:FindFirstChild("HumanoidRootPart")

				if not child:GetAttribute("Last_Time") then
					child:SetAttribute("Last_Time", tick() - 1)
				end

				if humanoidRootPart and tick() - child:GetAttribute("Last_Time") >= 0.1 then
					child:SetAttribute("Last_Time", tick())
					PlaySound.PlaySound_Character(humanoidRootPart, {
						Folder = "FightingStyle_Sound",
						Enemy = enemy,
						Sound = `{p2}_Hit`
					})
				end
			end
		end
	}
}
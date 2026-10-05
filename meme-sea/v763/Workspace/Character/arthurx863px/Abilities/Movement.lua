local createVector = vector.create
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Teams = game:GetService("Teams")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()
mouse.TargetFilter = workspace.Region
local playerData = localPlayer:WaitForChild("PlayerData", 15)
local playerSettings = localPlayer:WaitForChild("PlayerSettings", 15)
local cooldown = localPlayer:WaitForChild("Cooldown", 15)
local party = localPlayer:WaitForChild("Party", 15)
local ability = localPlayer:WaitForChild("Ability", 15)
local race = playerData:WaitForChild("Race")
local airJumpText = playerSettings:WaitForChild("AirJumpText")
local instinctText = playerSettings:FindFirstChild("InstinctText")
playerSettings:WaitForChild("ThaiLanguage")
playerData:WaitForChild("PowerEquip")
playerData:WaitForChild("FlashStepExp")
playerData:WaitForChild("FlashStepMaxExp")
local flashStepLevel = playerData:WaitForChild("FlashStepLevel")
local dodgeLevel = playerData:WaitForChild("DodgeLevel")
local dodge = playerData:WaitForChild("Dodge")
local maxDodge = playerData:WaitForChild("MaxDodge")
local flashStep = ability:WaitForChild("FlashStep")
local fishAwaken = ability:WaitForChild("FishAwaken")
local rabbitAwaken = ability:WaitForChild("RabbitAwaken")
local birdAwaken = ability:WaitForChild("BirdAwaken")
local aura = ability:WaitForChild("Aura")
local instinct = ability:WaitForChild("Instinct")
local playerGui = localPlayer:WaitForChild("PlayerGui", 30)
localPlayer:WaitForChild("PlayerScripts", 30)
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local stun = character:WaitForChild("Stun", 30)
local humanoid = character:WaitForChild("Humanoid", 30)
local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 30)
local animator = humanoid:WaitForChild("Animator")
local animation_Folder = ReplicatedStorage:WaitForChild("Animation_Folder")
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local visualFX = ReplicatedStorage:WaitForChild("VisualFX")
local guiTemplate = ReplicatedStorage:WaitForChild("GuiTemplate")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local monsterSpawn = ReplicatedStorage:WaitForChild("MonsterSpawn")
visualFX:WaitForChild("RaceEffect")
animation_Folder:WaitForChild("Weapon_Animation")
local visuals = workspace:WaitForChild("Visuals")
local character2 = workspace:WaitForChild("Character")
local monster = workspace:WaitForChild("Monster")
local location = workspace:WaitForChild("Location")
workspace:WaitForChild("BoatFolder")
local currentCamera = workspace.CurrentCamera
location:WaitForChild("Enemy_Location")
local cooldownGui = playerGui:WaitForChild("CooldownGui")
local instinctGui = playerGui:WaitForChild("InstinctGui")
local container = cooldownGui:WaitForChild("Container")
local instinct2 = Lighting:WaitForChild("Instinct")
local circle = instinctGui:WaitForChild("Circle")
local Setting = require(moduleScript:WaitForChild("Setting"))
local SetText = require(moduleScript:WaitForChild("SetText"))
require(moduleScript:WaitForChild("Abbreviate"))
local Cooldown_Module = require(moduleScript:WaitForChild("Cooldown_Module"))
local Generate = require(moduleScript:WaitForChild("Generate"))
local ItemSettings = require(moduleScript:WaitForChild("ItemSettings"))
local movement = otherEvent.SkillEvents:WaitForChild("Movement")
local water_Passive = otherEvent.SkillEvents:WaitForChild("Water_Passive")
local instinct3 = otherEvent.SkillEvents:WaitForChild("Instinct")
local ability2 = otherEvent.MainEvents:WaitForChild("Ability")
local modules = otherEvent.MainEvents:WaitForChild("Modules")
local waterDamage = otherEvent.MiscEvents:WaitForChild("WaterDamage")
local clientUI = otherEvent.GuiEvents:WaitForChild("ClientUI")
local lastTime = tick()
local lastTime2 = tick()
local lastTime3 = tick()
local lastTime4 = tick()
tick()
local position = humanoidRootPart.Position
local value = maxDodge.Value
local v = true
local v2 = nil
local v3 = "Left"
local v4 = "Left"
local maxJump

if birdAwaken.Value == true and race.Value == "Bird" then
	maxJump = Setting.Setting.MaxJump + 3
else
	maxJump = Setting.Setting.MaxJump
end

local flashStepCooldown = Setting.Setting.FlashStepCooldown
local raceSkill_Cooldown = Setting.Setting.RaceSkill_Cooldown
local max_Distance = Setting.Setting.Instinct_Info.Max_Distance
local space = Enum.KeyCode.Space
local Q = Enum.KeyCode.Q
local leftControl = Enum.KeyCode.LeftControl
local R = Enum.KeyCode.R
local T = Enum.KeyCode.T
local B = Enum.KeyCode.B
local E = Enum.KeyCode.E
local backspace = Enum.KeyCode.Backspace
local Folders = {
	workspace.Skills,
	workspace.Region,
	workspace.Visuals,
	workspace.Location,
	workspace.Sea,
	workspace.Leaderboard,
	workspace.CameraFolder,
	workspace.SpawningPower,
	workspace.Character
}
localPlayer:SetAttribute("Jumpscaring", nil)
local v5 = {
	Enemy = {
		FillColor = Color3.fromRGB(196, 40, 28),
		OutlineColor = Color3.fromRGB(196, 40, 28),
		FillTransparency = 0.5,
		OutlineTransparency = 0.25,
		MarkColor = Color3.fromRGB(196, 40, 28),
		MarkTransparency = 0.25
	},
	Player = {
		FillColor = Color3.fromRGB(175, 175, 175),
		OutlineColor = Color3.fromRGB(225, 225, 225),
		FillTransparency = 0.75,
		OutlineTransparency = 0.5,
		MarkColor = Color3.fromRGB(200, 200, 200),
		MarkTransparency = 0.25
	},
	Party_Player = {
		FillColor = Color3.fromRGB(85, 255, 0),
		OutlineColor = Color3.fromRGB(85, 255, 0),
		FillTransparency = 0.75,
		OutlineTransparency = 0.25,
		MarkColor = Color3.fromRGB(85, 255, 0),
		MarkTransparency = 0.25
	}
}
local instinct_Name = guiTemplate:WaitForChild("Instinct_Name")
local instinct_Health = guiTemplate:WaitForChild("Instinct_Health")
local instinct_Mark = guiTemplate:WaitForChild("Instinct_Mark")
local instinct_Bar = guiTemplate:WaitForChild("Instinct_Bar")
local v6 = {
	["Big Floppa"] = {
		StudsOffsetWorldSpace = createVector(0, -2, 0),
		Size = UDim2.new(25, 0, 25, 0)
	},
	["Walter Dog"] = {
		StudsOffsetWorldSpace = createVector(0, -1, 0)
	},
	["Snow Tree"] = {
		Size = UDim2.new(25, 0, 25, 0)
	},
	["Sus Face"] = {
		StudsOffsetWorldSpace = createVector(0, -1, 0),
		Size = UDim2.new(25, 0, 25, 0)
	},
	["Gorilla King"] = {
		StudsOffsetWorldSpace = createVector(0, -1.5, 0)
	},
	Obamid = {
		StudsOffsetWorldSpace = createVector(0, 2, 0),
		Size = UDim2.new(25, 0, 25, 0)
	},
	["Giant Pumpkin"] = {
		StudsOffsetWorldSpace = createVector(0, 2.5, 0),
		Size = UDim2.new(25, 0, 25, 0)
	},
	["Pink Absorber"] = {
		StudsOffsetWorldSpace = createVector(0, 1, 0)
	},
	Moai = {
		StudsOffsetWorldSpace = createVector(0, 1, 0),
		Size = UDim2.new(25, 0, 25, 0)
	},
	["Evil Noob"] = {
		StudsOffsetWorldSpace = createVector(0, -1, 0)
	},
	["Lord Sus"] = {
		StudsOffsetWorldSpace = createVector(0, 2, 0),
		Size = UDim2.new(25, 0, 25, 0)
	},
	["Rick Roller"] = {
		StudsOffsetWorldSpace = createVector(0, 1, 0)
	},
	MrBeast = {
		StudsOffsetWorldSpace = createVector(0, -1, 0)
	},
	["Quandale Dingle"] = {
		StudsOffsetWorldSpace = createVector(0, -1, 0)
	}
}
local v7 = maxJump
local tracksByName = {}
local v8 = {}
local flag = false
local cFrameChangedConnection = nil
local v9 = 0
local v10 = {
	"SeaBlock",
	"Sand",
	"Invisible_Part",
	"Raid_Grass",
	"Raid_Rock"
}
local v11 = 1
local v12 = nil
local v13 = false
local v14 = true
local flag2 = false
local v15 = false
local connections = {}
local flag3 = false
local diedConnection = nil
local onClientEventConnection = nil

while not (localPlayer.Team and localPlayer:GetAttribute("LoadedData")) do
	task.wait(1)
end

local track = animator:LoadAnimation(animation_Folder.Dash:WaitForChild("LeftDash"))
local track2 = animator:LoadAnimation(animation_Folder.Dash:WaitForChild("RightDash"))
local track3 = animator:LoadAnimation(animation_Folder.Jump:WaitForChild("Animation"))
local track4 = animator:LoadAnimation(animation_Folder.Jump:WaitForChild("Right"))
local track5 = animator:LoadAnimation(animation_Folder.Jump:WaitForChild("Left"))
local track6 = animator:LoadAnimation(animation_Folder.Run:WaitForChild("Run_Animation"))
local track7 = animator:LoadAnimation(animation_Folder.Run:WaitForChild("ToolIdle_Animation"))
local track8 = animator:LoadAnimation(animation_Folder.FightingStyle_Animation.Baller:WaitForChild("Walk"))
local track9 = animator:LoadAnimation(animation_Folder.FightingStyle_Animation.Baller:WaitForChild("Idle"))
local track10 = animator:LoadAnimation(animation_Folder.Dodge:WaitForChild("Left"))
local track11 = animator:LoadAnimation(animation_Folder.Dodge:WaitForChild("Right"))

for _, animation in ipairs(animation_Folder.Swim:GetChildren()) do
	tracksByName[animation.Name] = animator:LoadAnimation(animation)
end

if track7 then
	track7.Priority = Enum.AnimationPriority.Action
end

local v16 = race.Value == "Rabbit" and rabbitAwaken.Value == false and 450 or race.Value == "Rabbit" and rabbitAwaken.Value == true and 475 or 425
local v17 = race.Value == "Bird" and birdAwaken.Value == false and 55 or race.Value == "Bird" and birdAwaken.Value == true and 60 or 50

if UserInputService.GamepadEnabled then
	flag3 = true
elseif UserInputService.TouchEnabled then
	flag = true
end

local button = playerGui.Mobile.Dash:WaitForChild("Button", 15)
local button2 = playerGui.Mobile.Run:WaitForChild("Button", 15)
local button3 = playerGui.Mobile.FlashStep:WaitForChild("Button", 15)
local button4 = playerGui.Mobile.RaceSkill:WaitForChild("Button", 15)
local button5 = playerGui.Mobile.Aura:WaitForChild("Button", 15)
local button6 = playerGui.Mobile.Instinct:WaitForChild("Button", 15)
character:SetAttribute("Holding", "None")
humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

local function TextColor(p, p2)
	if p and p2 then
		return (`<font color="rgb({p2})">{p}</font>`)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Instinct_Disconnect(p)
	for _, connection in ipairs(v8[p]) do
		if connection then
			connection:Disconnect()
		end
	end

	v8[p] = nil
end

local function Instinct_Visuals(p: string, flag4: boolean)
	if p == "On" then
		if flag then
			TweenService:Create(button6, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
				ImageColor3 = Color3.fromRGB(114, 255, 75)
			}):Play()
		end

		circle.ImageTransparency = 0.5
		TweenService:Create(instinct2, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TintColor = Color3.fromRGB(216, 236, 255)
		}):Play()
		TweenService:Create(circle, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(1.5, 0, 5, 0),
			ImageTransparency = 1
		}):Play()
	elseif flag4 then
		if flag then
			TweenService:Create(button6, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
				ImageColor3 = Color3.fromRGB(255, 255, 255)
			}):Play()
		end

		TweenService:Create(instinct2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TintColor = Color3.fromRGB(255, 255, 255)
		}):Play()
		circle.ImageTransparency = 0.5
		TweenService:Create(circle, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 0, 5, 0),
			ImageTransparency = 1
		}):Play()
	else
		if flag then
			TweenService:Create(button6, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
				ImageColor3 = Color3.fromRGB(255, 255, 255)
			}):Play()
		end

		TweenService:Create(instinct2, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TintColor = Color3.fromRGB(255, 255, 255)
		}):Play()
		circle.ImageTransparency = 0.5
		TweenService:Create(circle, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 0, 5, 0),
			ImageTransparency = 1
		}):Play()
	end
end

local function Checked_Humanoid()
	if humanoidRootPart and humanoid and humanoidRootPart.Anchored == false and humanoid.WalkSpeed ~= 0 and humanoid.Health > 0 and humanoid.Sit == false and character:FindFirstChild("Stun") and character:FindFirstChild("Stun").Value <= 0 and not _G.CheckBV(character) and character:GetAttribute("Holding") == "None" then
		return true
	end

	return false
end

local function CheckIfAlive(instance)
	if instance and instance.Parent and instance:FindFirstChild("Humanoid") and instance:FindFirstChild("Humanoid").Parent and instance:FindFirstChild("Humanoid").Health > 0 and instance:FindFirstChild("Humanoid"):GetState() ~= Enum.HumanoidStateType.Dead then
		return true
	end

	return false
end

local function Check_Swimming()
	if playerData and playerData.PowerEquip.Value == "None" or playerData.Race.Value == "Fish" or playerData.PowerEquip.Value == "Water Power" or playerData.PowerEquip.Value == "Ice Power" or character:GetAttribute("Dough_Rolling") then
		return true
	end

	return false
end

local function onPlayerJumpRequest()
	if humanoid and humanoid.SeatPart then
		humanoid.Sit = false
	end
end

local function Dash_Function(_)
	local moveDirection = humanoid.MoveDirection
	local v18 = false
	local dashDirection = "Move_Direction"
	local v20 = character:GetAttribute("Transform") == "Diamond" and character:GetAttribute("FastSpeed_Active") and 50 or character:GetAttribute("Transform") == "Diamond" and 100 or 0
	local v21

	if character:GetAttribute("FastSpeed_Active") then
		v21 = (v16 + v20) * 1.5
	else
		v21 = v20 + v16
	end

	if moveDirection.Magnitude == 0 then
		moveDirection = currentCamera.CFrame.LookVector
		dashDirection = "Camera_Direction"
	end

	if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter or _G.MobileShiftlock then
		local dot = humanoid.MoveDirection:Dot(humanoidRootPart.CFrame.RightVector)

		if dot >= 0.707 then
			movement:FireServer("Dash", {
				Direction = "Right",
				MoveDirection = moveDirection,
				DashDirection = dashDirection
			})
			v18 = true
		elseif dot <= -0.707 then
			movement:FireServer("Dash", {
				Direction = "Left",
				MoveDirection = moveDirection,
				DashDirection = dashDirection
			})
			v18 = true
		end

		if humanoid.MoveDirection:Dot(humanoidRootPart.CFrame.LookVector) <= -0.707 then
			movement:FireServer("Dash", {
				Direction = "Back",
				MoveDirection = moveDirection,
				DashDirection = dashDirection
			})
			v18 = true
		end
	end

	PlayAnimation("Dash")
	local cframe = CFrame.new(
		humanoidRootPart.Position,
		humanoidRootPart.Position + moveDirection * createVector(1, 0, 1)
	)
	local lastTime5 = tick()
	local rotation = currentCamera.CFrame.Rotation
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.Name = "Dash_Gyro"
	bodyGyro.MaxTorque = createVector(100000, 100000, 100000)
	bodyGyro.P = 100000
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.P = 100000
	bodyVelocity.MaxForce = createVector(100000, 0, 100000)
	bodyVelocity.Velocity = cframe.LookVector * v21
	bodyGyro.CFrame = cframe

	if humanoid.FloorMaterial == Enum.Material.Air then
		bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
	else
		bodyVelocity.MaxForce = createVector(100000, 0, 100000)
	end

	bodyVelocity.Parent = humanoidRootPart

	if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter and not _G.MobileShiftlock then
		bodyGyro.Parent = humanoidRootPart
	end

	Debris:AddItem(bodyGyro, 0.25)
	Debris:AddItem(bodyVelocity, 0.25)

	if v18 == false then
		movement:FireServer("Dash", {
			Direction = "Front",
			MoveDirection = moveDirection,
			DashDirection = dashDirection
		})
	end

	cFrameChangedConnection = currentCamera:GetPropertyChangedSignal("CFrame"):Connect(function()
		if currentCamera.CFrame.Rotation ~= rotation then
			local moveDirection2 = humanoid.MoveDirection

			if moveDirection2.Magnitude == 0 then
				moveDirection2 = currentCamera.CFrame.LookVector
			end

			cframe = CFrame.new(
				humanoidRootPart.Position,
				humanoidRootPart.Position + moveDirection2 * createVector(1, 0, 1)
			)
		end

		bodyGyro.CFrame = cframe
	end)

	while tick() - lastTime5 <= 0.25 and character and character.Parent do
		bodyVelocity.Velocity = cframe.LookVector * (v21 * (0.5 - (tick() - lastTime5)))
		RunService.RenderStepped:Wait()
	end

	if cFrameChangedConnection then
		cFrameChangedConnection:Disconnect()
		cFrameChangedConnection = nil
	end
end

function DashActive()
	if (character:GetAttribute("FastSpeed_Active") and 0.1 or 0.35) <= tick() - lastTime and Checked_Humanoid() then
		lastTime = tick()

		if character:GetAttribute("Running") == nil and v then
			v = false
			RunActive()
		end

		Dash_Function()
	end
end

function JumpActive()
	if tick() - lastTime2 >= 0.35 and Checked_Humanoid() and v9 >= 1 then
		if character:GetAttribute("FastRegen_Active") then
			v7 = maxJump
		end

		if v7 > 0 then
			lastTime2 = tick()

			if not character:GetAttribute("FastRegen_Active") then
				v7 -= 1
			end

			if airJumpText.Value == true then
				if localPlayer:GetAttribute("TH") then
					if character:GetAttribute("FastRegen_Active") then
						SetText.SetText(localPlayer, "CustomMessage", {
							Message = `กระโดดเหลือ {"<font color=\"rgb(235,75,45)\">(∞/∞)</font>"}`,
							MessageColor = Color3.fromRGB(255, 255, 255),
							Type = "AirJump"
						})
					else
						local setText = SetText.SetText
						local formatted = `({v7}/{maxJump})`
						local v22

						if formatted then
							v22 = `<font color="rgb(235,75,45)">{formatted}</font>`
						end

						setText(localPlayer, "CustomMessage", {
							Message = `กระโดดเหลือ {v22}`,
							MessageColor = Color3.fromRGB(255, 255, 255),
							Type = "AirJump"
						})
					end
				elseif character:GetAttribute("FastRegen_Active") then
					SetText.SetText(localPlayer, "CustomMessage", {
						Message = `Sky Jumped {"<font color=\"rgb(235,75,45)\">(∞/∞)</font>"}`,
						MessageColor = Color3.fromRGB(255, 255, 255),
						Type = "AirJump"
					})
				else
					local setText = SetText.SetText
					local formatted = `({v7}/{maxJump})`
					local v22

					if formatted then
						v22 = `<font color="rgb(235,75,45)">{formatted}</font>`
					end

					setText(localPlayer, "CustomMessage", {
						Message = `Sky Jumped {v22}`,
						MessageColor = Color3.fromRGB(255, 255, 255),
						Type = "AirJump"
					})
				end
			end

			local velocity = nil
			local moveDirection = humanoid.MoveDirection
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = Folders
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			local raycastResult, _ = workspace:Raycast(
				humanoidRootPart.Position,
				humanoidRootPart.CFrame.LookVector * 10,
				raycastParams
			)
			local v19 = raycastResult and true or false
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = createVector(500000, 100000, 500000)

			if v19 == false then
				if moveDirection.Magnitude == 0 then
					PlayAnimation("Jump")
					bodyVelocity.Velocity = Vector3.new(0, v17, 0)
					movement:FireServer("Jump", {
						Move = "NotMoving"
					})
				else
					if velocity == nil then
						if race.Value == "Bird" then
							velocity = Vector3.new(moveDirection.X, 0, moveDirection.Z) * (v16 + humanoid.WalkSpeed * 5) / 8 + Vector3.new(
								0,
								v17,
								0
							) + moveDirection
						else
							velocity = Vector3.new(moveDirection.X, 0, moveDirection.Z) * (v16 + humanoid.WalkSpeed * 4) / 8 + Vector3.new(
								0,
								v17,
								0
							) + moveDirection
						end
					end

					PlayAnimation("Jump")
					bodyVelocity.Velocity = velocity
					movement:FireServer("Jump", {
						Move = "Moving"
					})
				end
			elseif v19 == true then
				PlayAnimation("Jump")
				bodyVelocity.Velocity = Vector3.new(0, v17, 0)
				movement:FireServer("Jump", {
					Move = "NotMoving"
				})
			end

			bodyVelocity.Parent = humanoidRootPart
			Debris:AddItem(bodyVelocity, 0.25)
		end
	end
end

function FlashStepActive(p)
	if tick() - lastTime3 >= 0.1 and cooldown:FindFirstChild("FlashStepCD") == nil and Checked_Humanoid() then
		local mouse2 = mouse.Hit.p

		if mouse2 and (character:GetPrimaryPartCFrame().Position - mouse2).Magnitude <= 500 * flashStepLevel.Value and mouse.Target and not table.find(
			v10,
			mouse.Target.Name
		) then
			ability2:InvokeServer("FlashStep", {
				Mouse = mouse2
			})
			lastTime3 = tick()

			if localPlayer:GetAttribute("TH") then
				Cooldown_Module.SetCooldown_Bar(
					"FlashStep",
					flashStepCooldown / flashStepLevel.Value,
					"ก้าวพริบตา",
					container,
					true,
					false
				)
			else
				Cooldown_Module.SetCooldown_Bar(
					"FlashStep",
					flashStepCooldown / flashStepLevel.Value,
					"Flash Step",
					container,
					false,
					false
				)
			end

			if p then
				v11 = 3
				v12 = 1
				v13 = false
				TweenService:Create(button3, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
					ImageColor3 = Color3.fromRGB(255, 35, 35)
				}):Play()
				task.wait(flashStepCooldown / flashStepLevel.Value)
				v11 = 1
				v14 = true
				TweenService:Create(button3, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
					ImageColor3 = Color3.fromRGB(255, 255, 255)
				}):Play()
			end
		end
	end
end

local function Clear_Instinct(instance, p: string)
	if instance and instance.Parent then
		local instinct_Highlight = instance:FindFirstChild("Instinct_Highlight")
		local instinct_Name2 = instance:FindFirstChild("Instinct_Name")
		local instinct_Health2 = instance:FindFirstChild("Instinct_Health")
		local instinct_Mark2 = instance:FindFirstChild("Instinct_Mark")
		local party_Mark = instance:FindFirstChild("Party_Mark")

		if instinct_Highlight then
			instinct_Highlight:Destroy()
		end

		if instinct_Name2 then
			instinct_Name2:Destroy()
		end

		if instinct_Health2 then
			instinct_Health2:Destroy()
		end

		if instinct_Mark2 then
			instinct_Mark2:Destroy()
		end

		if party_Mark and party_Mark.Mark.TextTransparency == 1 then
			party_Mark.Mark.TextTransparency = 0
		end

		if p == "Player" then
			local instinct_Bar2 = instance:FindFirstChild("Instinct_Bar")

			if instinct_Bar2 then
				instinct_Bar2:Destroy()
			end

			local humanoid2 = instance:FindFirstChild("Humanoid")

			if instance:GetAttribute("Summoner") then
				local child = Players:FindFirstChild(instance:GetAttribute("Summoner"))

				if humanoid2 and child then
					humanoid2.DisplayName = `{child.Name}'s Dog`
				end
			else
				local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

				if humanoid2 and playerFromCharacter then
					humanoid2.DisplayName = playerFromCharacter.DisplayName
				end
			end
		end
	end
end

local function Add_Highlight(character3, p)
	if p == "Enemy" then
		local highlight = Instance.new("Highlight")
		highlight.Name = "Instinct_Highlight"
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillTransparency = v5.Enemy.FillTransparency
		highlight.OutlineTransparency = v5.Enemy.OutlineTransparency
		highlight.OutlineColor = v5.Enemy.OutlineColor
		highlight.FillColor = v5.Enemy.FillColor
		highlight.Adornee = character3
		highlight.Parent = character3
	else
		local playerFromCharacter = p == "Player" and Players:GetPlayerFromCharacter(character3)

		if playerFromCharacter then
			if party:FindFirstChild(character3.Name) or localPlayer.Team == Teams.Cheems and playerFromCharacter.Team == Teams.Cheems then
				local highlight = Instance.new("Highlight")
				highlight.Name = "Instinct_Highlight"
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.FillTransparency = v5.Party_Player.FillTransparency
				highlight.OutlineTransparency = v5.Party_Player.OutlineTransparency
				highlight.OutlineColor = v5.Party_Player.OutlineColor
				highlight.FillColor = v5.Party_Player.FillColor
				highlight.Adornee = character3
				highlight.Parent = character3
			else
				local highlight = Instance.new("Highlight")
				highlight.Name = "Instinct_Highlight"
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.FillTransparency = v5.Player.FillTransparency
				highlight.OutlineTransparency = v5.Player.OutlineTransparency
				highlight.OutlineColor = v5.Player.OutlineColor
				highlight.FillColor = v5.Player.FillColor
				highlight.Adornee = character3
				highlight.Parent = character3
			end
		end
	end
end

local function Add_Instinct(model, p, p2: string)
	local humanoid2 = model:FindFirstChild("Humanoid")
	local humanoidRootPart2 = model:FindFirstChild("HumanoidRootPart")

	if humanoid2 and humanoidRootPart2 then
		if (humanoidRootPart2.Position - currentCamera.CFrame.Position).Magnitude <= p then
			if not model:HasTag("Has_Instinct") then
				model:AddTag("Has_Instinct")
			end

			if not model:FindFirstChild("Instinct_Highlight") then
				Add_Highlight(model, p2)
			end

			if not model:FindFirstChild("Instinct_Name") then
				local clone = instinct_Name:Clone()

				if p2 == "Player" then
					local playerFromCharacter = Players:GetPlayerFromCharacter(model)

					if playerFromCharacter then
						local playerData2 = playerFromCharacter:FindFirstChild("PlayerData")
						local level

						if playerData2 then
							level = playerData2:FindFirstChild("Level")
						end

						if level then
							clone.TextLabel.Text = `{model.Name} [Lv. {level.Value}]`
							humanoid2.DisplayName = `{humanoid2.DisplayName} [Lv. {level.Value}]`
						end
					else
						local child = model:GetAttribute("Summoner") and Players:FindFirstChild(model:GetAttribute("Summoner"))

						if child then
							local playerData2 = child:FindFirstChild("PlayerData")
							local v18

							if playerData2 then
								v18 = playerData2:FindFirstChild("Level")
							end

							if v18 then
								clone.TextLabel.Text = `{model.Name}`
								humanoid2.DisplayName = `{child.Name}'s Dog`
							end
						end
					end
				else
					clone.TextLabel.Text = humanoid2.DisplayName
				end

				clone.Adornee = humanoidRootPart2
				clone.Enabled = true
				clone.TextLabel.TextTransparency = 1
				clone.Parent = model
			end

			if not model:FindFirstChild("Instinct_Mark") then
				local clone = instinct_Mark:Clone()
				clone.Adornee = humanoidRootPart2
				clone.Enabled = true
				clone.Mark.BackgroundTransparency = 1
				local playerFromCharacter = Players:GetPlayerFromCharacter(model)

				if p2 == "Player" and playerFromCharacter then
					if party:FindFirstChild(model.Name) or localPlayer.Team == Teams.Cheems and playerFromCharacter.Team == Teams.Cheems then
						clone.Mark.BackgroundColor3 = v5.Party_Player.MarkColor
					else
						clone.Mark.BackgroundColor3 = v5[p2].MarkColor
					end
				else
					clone.Mark.BackgroundColor3 = v5[p2].MarkColor
				end

				clone.Parent = model
			end

			if v8[model] == nil then
				v8[model] = {}
			end

			if p2 == "Player" then
				local playerFromCharacter = Players:GetPlayerFromCharacter(model)

				if playerFromCharacter then
					if not model:FindFirstChild("Instinct_Bar") then
						local playerData2 = playerFromCharacter:FindFirstChild("PlayerData")
						local dodge2

						if playerData2 then
							dodge2 = playerData2:FindFirstChild("Dodge")
						else
							dodge2 = nil
						end

						local maxDodge2

						if playerData2 then
							maxDodge2 = playerData2:FindFirstChild("MaxDodge")
						else
							maxDodge2 = nil
						end

						if dodge2 and maxDodge2 then
							local clone = instinct_Bar:Clone()
							clone.HealthFrame.Health.Size = UDim2.new(
								math.clamp(humanoid2.Health / humanoid2.MaxHealth, 0, 1),
								0,
								1,
								0
							)
							clone.DodgeFrame.Dodge.Size = UDim2.new(
								math.clamp(dodge2.Value / maxDodge2.Value, 0, 1),
								0,
								1,
								0
							)
							clone.Adornee = humanoidRootPart2
							clone.Enabled = true
							clone.Parent = model

							if v8[model] then
								v8[model][#v8[model] + 1] = humanoid2.HealthChanged:Connect(function()
									if humanoid2.Health <= 0 or humanoid2:GetState() == Enum.HumanoidStateType.Dead then
										if v8[model] then
											Instinct_Disconnect(model) -- equivalent call inferred; original call site unknown
										end

										if model and model.Parent and model:HasTag("Has_Instinct") then
											model:RemoveTag("Has_Instinct")
										end

										if clone and clone.Parent then
											clone:Destroy()
										end
									elseif clone and clone.Parent then
										clone.HealthFrame.Health.Size = UDim2.new(
											math.clamp(humanoid2.Health / humanoid2.MaxHealth, 0, 1),
											0,
											1,
											0
										)
									end
								end)
								v8[model][#v8[model] + 1] = dodge2.Changed:Connect(function()
									if clone and clone.Parent then
										clone.DodgeFrame.Dodge.Size = UDim2.new(
											math.clamp(dodge2.Value / maxDodge2.Value, 0, 1),
											0,
											1,
											0
										)
									end
								end)
								v8[model][#v8[model] + 1] = model:GetPropertyChangedSignal("Parent"):Connect(function()
									if not Generate.CheckExist(model) then
										if v8[model] then
											Instinct_Disconnect(model) -- equivalent call inferred; original call site unknown
										end

										if model and model.Parent and model:HasTag("Has_Instinct") then
											model:RemoveTag("Has_Instinct")
										end

										if CheckIfAlive(model) then
											Clear_Instinct(model, p2)
										end
									end
								end)
							end
						end
					end
				elseif model:GetAttribute("Summoner") and not model:FindFirstChild("Instinct_Health") then
					local clone = instinct_Health:Clone()
					clone.HealthFrame.Health.Size = UDim2.new(
						math.clamp(humanoid2.Health / humanoid2.MaxHealth, 0, 1),
						0,
						1,
						0
					)
					clone.Adornee = humanoidRootPart2
					clone.Enabled = true
					clone.Size = UDim2.new(15, 0, 15, 0)
					clone.StudsOffsetWorldSpace = createVector(0, -1, 0)
					clone.Parent = model

					if v8[model] then
						v8[model][#v8[model] + 1] = humanoid2.HealthChanged:Connect(function()
							if humanoid2.Health <= 0 or humanoid2:GetState() == Enum.HumanoidStateType.Dead then
								if v8[model] then
									Instinct_Disconnect(model) -- equivalent call inferred; original call site unknown
								end

								if model and model.Parent and model:HasTag("Has_Instinct") then
									model:RemoveTag("Has_Instinct")
								end

								if clone and clone.Parent then
									clone:Destroy()
								end
							elseif clone and clone.Parent then
								clone.HealthFrame.Health.Size = UDim2.new(
									math.clamp(humanoid2.Health / humanoid2.MaxHealth, 0, 1),
									0,
									1,
									0
								)
							end
						end)
						v8[model][#v8[model] + 1] = model:GetPropertyChangedSignal("Parent"):Connect(function()
							if not Generate.CheckExist(model) or model and model.Parent and model.Parent == monsterSpawn then
								if v8[model] then
									Instinct_Disconnect(model) -- equivalent call inferred; original call site unknown
								end

								if model and model.Parent and model:HasTag("Has_Instinct") then
									model:RemoveTag("Has_Instinct")
								end

								if CheckIfAlive(model) then
									Clear_Instinct(model, p2)
								end
							end
						end)
					end
				end
			elseif not model:FindFirstChild("Instinct_Health") then
				local clone = instinct_Health:Clone()
				clone.HealthFrame.Health.Size = UDim2.new(
					math.clamp(humanoid2.Health / humanoid2.MaxHealth, 0, 1),
					0,
					1,
					0
				)
				clone.Adornee = humanoidRootPart2
				clone.Enabled = true
				clone.Parent = model

				if v6[model.Name] then
					clone.Size = v6[model.Name].Size or UDim2.new(15, 0, 15, 0)
					clone.StudsOffsetWorldSpace = v6[model.Name].StudsOffsetWorldSpace or createVector(0, 0, 0)
				end

				if v8[model] then
					v8[model][#v8[model] + 1] = humanoid2.HealthChanged:Connect(function()
						if humanoid2.Health <= 0 or humanoid2:GetState() == Enum.HumanoidStateType.Dead then
							if v8[model] then
								Instinct_Disconnect(model) -- equivalent call inferred; original call site unknown
							end

							if model and model.Parent and model:HasTag("Has_Instinct") then
								model:RemoveTag("Has_Instinct")
							end

							if clone and clone.Parent then
								clone:Destroy()
							end
						elseif clone and clone.Parent then
							clone.HealthFrame.Health.Size = UDim2.new(
								math.clamp(humanoid2.Health / humanoid2.MaxHealth, 0, 1),
								0,
								1,
								0
							)
						end
					end)
					v8[model][#v8[model] + 1] = model:GetPropertyChangedSignal("Parent"):Connect(function()
						if not Generate.CheckExist(model) or model and model.Parent and model.Parent == monsterSpawn then
							if v8[model] then
								Instinct_Disconnect(model) -- equivalent call inferred; original call site unknown
							end

							if model and model.Parent and model:HasTag("Has_Instinct") then
								model:RemoveTag("Has_Instinct")
							end

							if CheckIfAlive(model) then
								Clear_Instinct(model, p2)
							end
						end
					end)
				end
			end

			if (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude <= humanoid2.NameDisplayDistance + 300 then
				local instinct_Mark2 = model:FindFirstChild("Instinct_Mark")
				local instinct_Highlight = model:FindFirstChild("Instinct_Highlight")
				local instinct_Name2 = model:FindFirstChild("Instinct_Name")
				local party_Mark = model:FindFirstChild("Party_Mark")

				if p2 == "Player" then
					if (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude <= humanoid2.NameDisplayDistance then
						if instinct_Name2 and instinct_Name2.TextLabel.TextTransparency == 0 then
							TweenService:Create(
								instinct_Name2.TextLabel,
								TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									TextTransparency = 1
								}
							):Play()
						end
					elseif instinct_Name2 and instinct_Name2.TextLabel.TextTransparency == 1 then
						TweenService:Create(
							instinct_Name2.TextLabel,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								TextTransparency = 0
							}
						):Play()
					end
				elseif (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude <= humanoid2.NameDisplayDistance + 150 then
					if instinct_Name2 and instinct_Name2.TextLabel.TextTransparency == 0 then
						TweenService:Create(
							instinct_Name2.TextLabel,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								TextTransparency = 1
							}
						):Play()
					end
				elseif instinct_Name2 and instinct_Name2.TextLabel.TextTransparency == 1 then
					TweenService:Create(
						instinct_Name2.TextLabel,
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TextTransparency = 0
						}
					):Play()
				end

				if not instinct_Highlight then
					local highlight = Instance.new("Highlight")
					highlight.Name = "Instinct_Highlight"
					highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					highlight.FillTransparency = v5.Enemy.FillTransparency
					highlight.OutlineTransparency = v5.Enemy.OutlineTransparency
					highlight.OutlineColor = v5.Enemy.OutlineColor
					highlight.FillColor = v5.Enemy.FillColor
					highlight.Adornee = model
					highlight.Parent = model
				end

				if instinct_Mark2 and instinct_Mark2.Mark.BackgroundTransparency == v5.Enemy.MarkTransparency then
					TweenService:Create(
						instinct_Mark2.Mark,
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							BackgroundTransparency = 1
						}
					):Play()
				end

				if party_Mark and party_Mark.Mark.TextTransparency == 1 then
					TweenService:Create(
						party_Mark.Mark,
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TextTransparency = 0
						}
					):Play()
				end
			else
				local instinct_Name2 = model:FindFirstChild("Instinct_Name")
				local instinct_Highlight = model:FindFirstChild("Instinct_Highlight")
				local instinct_Mark2 = model:FindFirstChild("Instinct_Mark")
				local party_Mark = model:FindFirstChild("Party_Mark")

				if instinct_Name2 and instinct_Name2.TextLabel.TextTransparency == 1 then
					TweenService:Create(
						instinct_Name2.TextLabel,
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TextTransparency = 0
						}
					):Play()
				end

				if instinct_Highlight then
					instinct_Highlight:Destroy()
				end

				if instinct_Mark2 and instinct_Mark2.Mark.BackgroundTransparency == 1 and model:GetAttribute("Raid_Enemy") == nil then
					TweenService:Create(
						instinct_Mark2.Mark,
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							BackgroundTransparency = v5.Enemy.MarkTransparency
						}
					):Play()
				end

				if party_Mark and party_Mark.Mark.TextTransparency == 0 then
					TweenService:Create(
						party_Mark.Mark,
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TextTransparency = 1
						}
					):Play()
				end
			end
		else
			if CheckIfAlive(model) then
				Clear_Instinct(model, p2)
			end

			if v8[model] then
				Instinct_Disconnect(model) -- equivalent call inferred; original call site unknown
			end

			if model:HasTag("Has_Instinct") then
				model:RemoveTag("Has_Instinct")
			end
		end
	end
end

function Instince_Frame(p: string)
	if p == "Enable" then
		local v18 = dodgeLevel.Value * max_Distance

		if not character:FindFirstChild("Highlight_Player") then
			local highlight = Instance.new("Highlight")
			highlight.Name = "Highlight_Player"
			highlight.FillTransparency = 0.75
			highlight.FillColor = Color3.fromRGB(175, 175, 175)
			highlight.OutlineTransparency = 0.5
			highlight.OutlineColor = Color3.fromRGB(225, 225, 225)
			highlight.Adornee = character
			highlight.Parent = character
		end

		while character:GetAttribute("Using_Instinct") and CheckIfAlive(character) do
			for _, model in ipairs(monster:GetChildren()) do
				if not (model:IsA("Model") and CheckIfAlive(model) and model.Name ~= "Training Log" and model.Name ~= "Meme Beast") then
					continue
				end

				Add_Instinct(model, v18, "Enemy")
			end

			for _, model in ipairs(character2:GetChildren()) do
				if not (model:IsA("Model") and CheckIfAlive(model) and model.Name ~= localPlayer.Name) then
					continue
				end

				Add_Instinct(model, v18, "Player")
			end

			task.wait(2)
		end

		if instinct2.TintColor == Color3.fromRGB(216, 236, 255) then
			Instince_Frame("Disable")
			Instinct_Visuals("Off")
		end
	else
		local highlight_Player = character:FindFirstChild("Highlight_Player")

		if highlight_Player then
			highlight_Player:Destroy()
		end

		for k, list in pairs(v8) do
			for _, connection in ipairs(list) do
				if connection then
					connection:Disconnect()
				end
			end

			v8[k] = nil
		end

		for _, model in ipairs(CollectionService:GetTagged("Has_Instinct")) do
			model:RemoveTag("Has_Instinct")

			if not (model:IsA("Model") and model ~= character) then
				continue
			end

			if Players:GetPlayerFromCharacter(model) then
				Clear_Instinct(model, "Player")
			else
				Clear_Instinct(model, "Enemy")
			end
		end
	end
end

function DropItem()
	local tool

	if character and character.Parent then
		tool = character:FindFirstChildOfClass("Tool")
	end

	if tool and (ItemSettings[tool.Name].Droppable == true or tool:HasTag("MoneyBag")) then
		modules:FireServer(
			tool.Name == "Awakening Orb" and "Awakening_Orb" or tool.Name == "Quest Scroll" and "Quest_Scroll" or tool.Name == "Money Bag" and "Money_Bag" or "Eatable_Power",
			{
				Action = "Drop",
				Tool = tool
			}
		)
	end
end

function RaceSkill_Active(p)
	if cooldown:FindFirstChild("RaceSkillCD") == nil then
		movement:FireServer("RaceSkill")

		if localPlayer:GetAttribute("TH") then
			Cooldown_Module.SetCooldown_Bar("RaceAbility", raceSkill_Cooldown, "ความสามารถเผ่า", container, true, false)
		else
			Cooldown_Module.SetCooldown_Bar("RaceAbility", raceSkill_Cooldown, "Race Ability", container, false, false)
		end

		if p then
			TweenService:Create(button4, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
				ImageColor3 = Color3.fromRGB(255, 35, 35)
			}):Play()
			task.wait(raceSkill_Cooldown)
			TweenService:Create(button4, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
				ImageColor3 = Color3.fromRGB(255, 255, 255)
			}):Play()
		end
	end
end

function Aura_Active(p)
	if cooldown:FindFirstChild("AuraCD") == nil then
		if character:GetAttribute("Using_Aura") == true then
			ability2:InvokeServer("Aura")

			if p then
				TweenService:Create(button5, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
					ImageColor3 = Color3.fromRGB(255, 255, 255)
				}):Play()
			end
		elseif character:GetAttribute("Using_Aura") == nil then
			ability2:InvokeServer("Aura")

			if p then
				TweenService:Create(button5, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
					ImageColor3 = Color3.fromRGB(114, 255, 75)
				}):Play()
			end
		end
	end
end

function Instinct_Active(_)
	if cooldown:FindFirstChild("InstinctCD") == nil and CheckIfAlive(character) then
		if character:GetAttribute("Using_Instinct") == true then
			ability2:InvokeServer("Instinct")
			Instinct_Visuals("Off")
			Instince_Frame("Disable")
		elseif character:GetAttribute("Using_Instinct") == nil then
			if ability2:InvokeServer("Instinct") == true then
				Instinct_Visuals("On")
				Instince_Frame("Enable")
			else
				Instinct_Visuals("Off")
				Instince_Frame("Disable")
			end
		end
	end
end

function RunActive()
	if character:GetAttribute("Running") == nil then
		movement:FireServer("Run")

		if flag then
			TweenService:Create(button2, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
				ImageColor3 = Color3.fromRGB(114, 255, 75)
			}):Play()
		end
	else
		movement:FireServer("Walk")

		if flag then
			TweenService:Create(button2, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
				ImageColor3 = Color3.fromRGB(255, 255, 255)
			}):Play()
		end
	end
end

function Start_Swimming()
	if humanoidRootPart and humanoidRootPart:FindFirstChild("Swim_BP") == nil then
		local bodyPosition = Instance.new("BodyPosition")
		bodyPosition.Name = "Swim_BP"
		bodyPosition.MaxForce = createVector(0, 100000, 0)
		bodyPosition.D = 750
		bodyPosition.P = 100000
		bodyPosition.Position = createVector(0, -108, 0)
		bodyPosition:SetAttribute("Invincible", true)
		bodyPosition.Parent = humanoidRootPart
	end
end

function Ice_WaterWalk()
	local part = Instance.new("Part")
	part.Anchored = true
	part.Transparency = 1
	part.CanCollide = true
	part.Color = Color3.fromRGB(128, 187, 219)
	part.Material = Enum.Material.Plastic
	part.Size = createVector(20, 1, 20)
	part.Position = Vector3.new(humanoidRootPart.Position.X, -108, humanoidRootPart.Position.Z)
	part.Parent = visuals
	Debris:AddItem(part, 1)
end

function Jump_OnWater()
	if humanoidRootPart then
		local swim_BP = humanoidRootPart:FindFirstChild("Swim_BP")

		if swim_BP then
			swim_BP:Destroy()
			flag2 = true
			v15 = false
		end

		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Name = "Swim_BV"
		bodyVelocity.MaxForce = createVector(0, 100000, 0)
		bodyVelocity.Velocity = createVector(0, 50, 0)
		bodyVelocity.Parent = humanoidRootPart
		Debris:AddItem(bodyVelocity, 0.25)

		if v9 ~= 1 then
			v9 = 1
		end
	end
end

function PlayAnimation(p)
	if p == "Dash" then
		if v3 == "Right" then
			track:Play()
			track:AdjustSpeed(2.5)
			v3 = "Left"
		elseif v3 == "Left" then
			track2:Play()
			track2:AdjustSpeed(2.5)
			v3 = "Right"
		else
			track:Play()
			track:AdjustSpeed(2.5)
			v3 = "Left"
		end
	elseif p == "Jump" then
		track3:Play(nil, nil, 1.5)
	elseif p == "JumpBackward" then
		track3:Play(nil, nil, -1.5)
	elseif p == "JumpRight" then
		track4:Play(nil, nil, 1.5)
	elseif p == "JumpLeft" then
		track5:Play(nil, nil, 1.5)
	end
end

function RunAnimation(p)
	if not Checked_Humanoid() and track6.IsPlaying then
		track6:Stop()
	end

	local tool = character:FindFirstChildOfClass("Tool")

	if tool and tool:FindFirstChild("Handle") and tool.Name == "Baller" then
		if p >= 10 and p < 60 and character:GetAttribute("Running") == true and not track8.IsPlaying then
			local tool2 = character:FindFirstChildOfClass("Tool")

			if tool2 and tool2:FindFirstChild("Handle") and not (tool2:HasTag("Weapon") or tool2:HasTag("FightingStyle")) then
				track7:Play()
			elseif track7.IsPlaying then
				track7:Stop()
			end

			if track6.IsPlaying then
				track6:Stop()
			end

			track8:Play(nil, nil, 2)
		elseif p >= 60 and p < 100 and character:GetAttribute("Running") == true and not track8.IsPlaying then
			local tool2 = character:FindFirstChildOfClass("Tool")

			if tool2 and tool2:FindFirstChild("Handle") and not (tool2:HasTag("Weapon") or tool2:HasTag("FightingStyle")) then
				track7:Play()
			elseif track7.IsPlaying then
				track7:Stop()
			end

			if track6.IsPlaying then
				track6:Stop()
			end

			track8:Play(nil, nil, 3)
		elseif p >= 100 and character:GetAttribute("Running") == true and not track8.IsPlaying then
			local tool2 = character:FindFirstChildOfClass("Tool")

			if tool2 and tool2:FindFirstChild("Handle") and not (tool2:HasTag("Weapon") or tool2:HasTag("FightingStyle")) then
				track7:Play()
			elseif track7.IsPlaying then
				track7:Stop()
			end

			if track6.IsPlaying then
				track6:Stop()
			end

			track8:Play(nil, nil, 4)
		elseif p >= 10 and character:GetAttribute("Running") == nil and not track8.IsPlaying then
			if track6.IsPlaying then
				track6:Stop()
			end

			track8:Play()
		elseif p < 10 and track8.IsPlaying then
			track8:Stop()
		end
	elseif p >= 10 and p < 60 and character:GetAttribute("Running") == true and not track6.IsPlaying then
		local tool2 = character:FindFirstChildOfClass("Tool")

		if tool2 and tool2:FindFirstChild("Handle") and not (tool2:HasTag("Weapon") or tool2:HasTag("FightingStyle")) then
			track7:Play()
		elseif track7.IsPlaying then
			track7:Stop()
		end

		if track8.IsPlaying then
			track8:Stop()
		end

		track6:Play(nil, nil, 2)
	elseif p >= 60 and p < 100 and character:GetAttribute("Running") == true and not track6.IsPlaying then
		local tool2 = character:FindFirstChildOfClass("Tool")

		if tool2 and tool2:FindFirstChild("Handle") and not (tool2:HasTag("Weapon") or tool2:HasTag("FightingStyle")) then
			track7:Play()
		elseif track7.IsPlaying then
			track7:Stop()
		end

		if track8.IsPlaying then
			track8:Stop()
		end

		track6:Play(nil, nil, 3)
	elseif p >= 100 and character:GetAttribute("Running") == true and not track6.IsPlaying then
		local tool2 = character:FindFirstChildOfClass("Tool")

		if tool2 and tool2:FindFirstChild("Handle") and not (tool2:HasTag("Weapon") or tool2:HasTag("FightingStyle")) then
			track7:Play()
		elseif track7.IsPlaying then
			track7:Stop()
		end

		if track8.IsPlaying then
			track8:Stop()
		end

		track6:Play(nil, nil, 4)
	elseif p >= 10 and character:GetAttribute("Running") == nil and track6.IsPlaying then
		track6:Stop()
	elseif p < 10 and track6.IsPlaying then
		track6:Stop()
	end
end

function Play_SwimAnimation()
	while v15 and humanoid and humanoid.Parent and humanoid.Health > 0 and v15 ~= false do
		if humanoid.MoveDirection == createVector(0, 0, 0) then
			if tracksByName.Swimming.IsPlaying then
				tracksByName.Swimming:Stop()
			end

			if not tracksByName.SwimIdle.IsPlaying then
				tracksByName.SwimIdle:Play()
			end
		else
			if tracksByName.SwimIdle.IsPlaying then
				tracksByName.SwimIdle:Stop()
			end

			if not tracksByName.Swimming.IsPlaying then
				tracksByName.Swimming:Play()
			end
		end

		task.wait(0.05)
	end
end

if instinct2.TintColor == Color3.fromRGB(216, 236, 255) then
	Instinct_Visuals("Off")
	Instince_Frame("Disable")
end

connections[#connections + 1] = UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if flag3 then
		if input.UserInputType == Enum.UserInputType.Gamepad1 and not localPlayer:GetAttribute("IsConsole") then
			localPlayer:SetAttribute("IsConsole", true)
		elseif input.UserInputType == Enum.UserInputType.Keyboard and localPlayer:GetAttribute("IsConsole") then
			localPlayer:SetAttribute("IsConsole", nil)
		end
	end

	if not gameProcessed or localPlayer:GetAttribute("IsConsole") then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Q then
				DashActive()
			elseif input.KeyCode == space or input.KeyCode == Enum.KeyCode.ButtonA then
				JumpActive()
			elseif input.KeyCode == leftControl or input.KeyCode == Enum.KeyCode.ButtonL3 then
				RunActive()
			elseif input.KeyCode == R or input.KeyCode == Enum.KeyCode.ButtonR3 then
				if flashStep.Value == true then
					FlashStepActive()
				end
			elseif input.KeyCode == T or input.KeyCode == Enum.KeyCode.DPadUp then
				if race.Value == "Fish" and fishAwaken.Value == true then
					RaceSkill_Active()
				elseif race.Value == "Rabbit" and rabbitAwaken.Value == true then
					RaceSkill_Active()
				elseif race.Value == "Bird" and birdAwaken.Value == true then
					RaceSkill_Active()
				end
			elseif input.KeyCode == B or input.KeyCode == Enum.KeyCode.DPadDown then
				if aura.Value == true then
					Aura_Active()
				end
			elseif input.KeyCode == E or input.KeyCode == Enum.KeyCode.DPadLeft then
				if instinct.Value == true then
					Instinct_Active()
				end
			elseif input.KeyCode == backspace then
				DropItem()
			end
		elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
			if input.KeyCode == space or input.KeyCode == Enum.KeyCode.ButtonA then
				JumpActive()
			elseif input.KeyCode == Q or input.KeyCode == Enum.KeyCode.ButtonL3 then
				DashActive()
			elseif input.KeyCode == leftControl then
				RunActive()
			elseif input.KeyCode == R or input.KeyCode == Enum.KeyCode.ButtonR3 then
				if flashStep.Value == true then
					FlashStepActive()
				end
			elseif input.KeyCode == T or input.KeyCode == Enum.KeyCode.DPadUp then
				if race.Value == "Fish" and fishAwaken.Value == true then
					RaceSkill_Active()
				elseif race.Value == "Rabbit" and rabbitAwaken.Value == true then
					RaceSkill_Active()
				elseif race.Value == "Bird" and birdAwaken.Value == true then
					RaceSkill_Active()
				end
			elseif input.KeyCode == B or input.KeyCode == Enum.KeyCode.DPadDown then
				if aura.Value == true then
					Aura_Active()
				end
			elseif input.KeyCode == E or input.KeyCode == Enum.KeyCode.DPadLeft then
				if instinct.Value == true then
					Instinct_Active()
				end
			elseif input.KeyCode == backspace then
				DropItem()
			end
		end
	end
end)
connections[#connections + 1] = RunService.Stepped:Connect(function()
	if humanoidRootPart.Position.Y <= -95 and humanoidRootPart.Position.Y > -108 and localPlayer:GetAttribute("Ice_WaterPassive") then
		while localPlayer:GetAttribute("Ice_WaterPassive") and humanoid and humanoid.Parent and humanoid.Health > 0 and not character:GetAttribute("Ice_PassiveCD") and humanoidRootPart.Position.Y <= -95 and humanoidRootPart.Position.Y > -108 and humanoid.FloorMaterial and humanoid.Sit == false do
			if humanoid.FloorMaterial ~= Enum.Material.Plastic or (position - humanoidRootPart.Position).Magnitude >= 10 then
				position = humanoidRootPart.Position
				Ice_WaterWalk()
				water_Passive:FireServer(
					character,
					(Vector3.new(humanoidRootPart.Position.X, -108, humanoidRootPart.Position.Z))
				)
			end

			task.wait(0.05)
		end
	elseif humanoidRootPart.Position.Y <= -108 and not localPlayer:GetAttribute("Dough_Rolling") then
		if humanoidRootPart.Position.Y <= -117 and flag2 then
			Generate.ClearBV(humanoidRootPart)

			if humanoidRootPart and humanoidRootPart:FindFirstChild("Swim_BP") then
				humanoidRootPart:FindFirstChild("Swim_BP"):Destroy()
			end

			humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.CFrame.X, -108, humanoidRootPart.CFrame.Z)
			waterDamage:FireServer("End_WaterDamage")

			if tracksByName.SwimIdle.IsPlaying then
				tracksByName.SwimIdle:Stop()
			end

			if tracksByName.Swimming.IsPlaying then
				tracksByName.Swimming:Stop()
			end

			v15 = false
			flag2 = false
		elseif flag2 == false and v15 == false and not character:GetAttribute("OnWaterDamage") then
			flag2 = true
			v15 = true
			Start_Swimming()

			if character and humanoid and humanoid.Health > 0 and (not playerData or playerData.PowerEquip.Value ~= "None") and playerData.Race.Value ~= "Fish" and playerData.PowerEquip.Value ~= "Water Power" and playerData.PowerEquip.Value ~= "Ice Power" and not character:GetAttribute("Dough_Rolling") then
				waterDamage:FireServer("Start_WaterDamage")
			end

			task.spawn(Play_SwimAnimation)
		end
	elseif humanoidRootPart.Position.Y > -107 and flag2 then
		if humanoidRootPart and humanoidRootPart:FindFirstChild("Swim_BP") then
			humanoidRootPart:FindFirstChild("Swim_BP"):Destroy()
		end

		waterDamage:FireServer("End_WaterDamage")

		if tracksByName.SwimIdle.IsPlaying then
			tracksByName.SwimIdle:Stop()
		end

		if tracksByName.Swimming.IsPlaying then
			tracksByName.Swimming:Stop()
		end

		v15 = false
		flag2 = false
	end

	humanoid.Running:Wait()
end)
connections[#connections + 1] = dodge.Changed:Connect(function()
	if dodge.Value < value then
		value = dodge.Value

		if v4 == "Right" then
			track10:Play()
			v4 = "Left"
		elseif v4 == "Left" then
			track11:Play()
			v4 = "Right"
		else
			track10:Play()
			v4 = "Left"
		end
	else
		local value2 = dodge.Value

		if value <= value2 then
			value = dodge.Value

			if instinctText.Value == true then
				if localPlayer:GetAttribute("TH") then
					local setText = SetText.SetText
					local formatted = `({dodge.Value}/{maxDodge.Value})`
					local v22

					if formatted then
						v22 = `<font color="rgb(184,133,255)">{formatted}</font>`
					end

					setText(localPlayer, "CustomMessage", {
						Message = `ชาร์จการหลบแล้ว! {v22}`,
						Type = "Instinct"
					})
				else
					local setText = SetText.SetText
					local formatted = `({dodge.Value}/{maxDodge.Value})`
					local v22

					if formatted then
						v22 = `<font color="rgb(184,133,255)">{formatted}</font>`
					end

					setText(localPlayer, "CustomMessage", {
						Message = `Dodge Charged! {v22}`,
						Type = "Instinct"
					})
				end
			end
		end
	end
end)
connections[#connections + 1] = monster.ChildAdded:Connect(function(model)
	if character:GetAttribute("Using_Instinct") and model:IsA("Model") and model.Name ~= "Training Log" and model.Name ~= "Meme Beast" then
		Add_Instinct(model, dodgeLevel.Value * max_Distance, "Enemy")
	end
end)
connections[#connections + 1] = instinct3.OnClientEvent:Connect(function(p: string)
	if p == "Instinct_Broke" then
		Instinct_Visuals("Off", true)
		Instince_Frame("Disable")
	end
end)

if flag then
	connections[#connections + 1] = button.Activated:Connect(DashActive)
	connections[#connections + 1] = button2.Activated:Connect(RunActive)
	connections[#connections + 1] = button5.Activated:Connect(function()
		if aura.Value == true then
			Aura_Active(true)
		elseif localPlayer:GetAttribute("TH") then
			SetText.SetText(localPlayer, "CustomMessage", {
				Message = "[คุณยังไม่ได้ปลดล็อคทักษะนี้!]",
				MessageColor = "Red"
			})
		else
			SetText.SetText(localPlayer, "CustomMessage", {
				Message = "[You haven't unlocked this ability yet!]",
				MessageColor = "Red"
			})
		end
	end)
	connections[#connections + 1] = button6.Activated:Connect(function()
		if instinct.Value == true then
			Instinct_Active(true)
		elseif localPlayer:GetAttribute("TH") then
			SetText.SetText(localPlayer, "CustomMessage", {
				Message = "[คุณยังไม่ได้ปลดล็อคทักษะนี้!]",
				MessageColor = "Red"
			})
		else
			SetText.SetText(localPlayer, "CustomMessage", {
				Message = "[You haven't unlocked this ability yet!]",
				MessageColor = "Red"
			})
		end
	end)
	connections[#connections + 1] = button4.Activated:Connect(function()
		if cooldown:FindFirstChild("RaceSkillCD") == nil then
			if race.Value == "Fish" and fishAwaken.Value == true then
				RaceSkill_Active(true)
			elseif race.Value == "Rabbit" and rabbitAwaken.Value == true then
				RaceSkill_Active(true)
			elseif race.Value == "Bird" and birdAwaken.Value == true then
				RaceSkill_Active(true)
			elseif localPlayer:GetAttribute("TH") then
				SetText.SetText(localPlayer, "CustomMessage", {
					Message = "[คุณยังไม่ได้ปลดล็อคทักษะนี้!]",
					MessageColor = "Red"
				})
			else
				SetText.SetText(localPlayer, "CustomMessage", {
					Message = "[You haven't unlocked this ability yet!]",
					MessageColor = "Red"
				})
			end
		end
	end)
	connections[#connections + 1] = button3.Activated:Connect(function()
		if flashStep.Value == true then
			if v11 == 1 then
				v12 = 0

				if v13 == false and v12 == 0 then
					v12 = 1
					v13 = true
					TweenService:Create(button3, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
						ImageColor3 = Color3.fromRGB(114, 255, 75)
					}):Play()
				end

				if v13 == true and v12 == 0 then
					v12 = 1
					v13 = false
					TweenService:Create(button3, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
						ImageColor3 = Color3.fromRGB(255, 255, 255)
					}):Play()
				end
			end
		elseif localPlayer:GetAttribute("TH") then
			SetText.SetText(localPlayer, "CustomMessage", {
				Message = "[คุณยังไม่ได้ปลดล็อคทักษะนี้!]",
				MessageColor = "Red"
			})
		else
			SetText.SetText(localPlayer, "CustomMessage", {
				Message = "[You haven't unlocked this ability yet!]",
				MessageColor = "Red"
			})
		end
	end)
end

connections[#connections + 1] = humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
	if humanoid.SeatPart then
		if humanoid.SeatPart.Name == "BoatSeat" then
			local parent = humanoid.SeatPart.Parent
			local boatOwner = parent and parent:FindFirstChild("MainPart") and parent:FindFirstChild("Boat Owner")
			local flag4 = boatOwner and localPlayer.Name ~= boatOwner.Value and parent:FindFirstChild("Flag")

			if flag4 then
				local boatNameGui = flag4:FindFirstChild("BoatNameGui")

				if boatNameGui and boatNameGui.Enabled then
					boatNameGui.Enabled = false
					v2 = boatNameGui
				end
			end
		elseif humanoid.SeatPart.Name == "VehicleSeat" then
			local parent = humanoid.SeatPart.Parent.Parent.Parent
			local boatOwner = parent and parent:FindFirstChild("MainPart") and parent:FindFirstChild("Boat Owner")
			local flag4 = boatOwner and localPlayer.Name ~= boatOwner.Value and parent:FindFirstChild("Flag")

			if flag4 then
				local boatNameGui = flag4:FindFirstChild("BoatNameGui")

				if boatNameGui and boatNameGui.Enabled then
					boatNameGui.Enabled = false
					v2 = boatNameGui
				end
			end
		end
	elseif v2 and v2.Parent then
		v2.Enabled = true
		v2 = nil
	end
end)
connections[#connections + 1] = UserInputService.JumpRequest:Connect(function()
	if flag2 then
		Jump_OnWater()
	end
end)

if stun then
	connections[#connections + 1] = stun:GetPropertyChangedSignal("Value"):Connect(function()
		if stun.Value > 0 then
			if humanoid.WalkSpeed ~= 0 and humanoid.JumpPower ~= 0 then
				if not humanoid:GetAttribute("Old_Speed") then
					if character:GetAttribute("FastSpeed_Active") then
						humanoid:SetAttribute("Rabbit_Speed", 50)
						humanoid:SetAttribute("Old_Speed", humanoid.WalkSpeed - 50)
					else
						humanoid:SetAttribute("Old_Speed", humanoid.WalkSpeed)
					end

					humanoid.WalkSpeed = 0
				end

				if not humanoid:GetAttribute("Old_Jump") then
					humanoid:SetAttribute("Old_Jump", humanoid.JumpPower)
					humanoid.JumpPower = 0
				end
			end
		else
			if humanoid:GetAttribute("Old_Speed") then
				if humanoid:GetAttribute("Rabbit_Speed") then
					humanoid.WalkSpeed = humanoid:GetAttribute("Old_Speed") + humanoid:GetAttribute("Rabbit_Speed")
					humanoid:SetAttribute("Rabbit_Speed", nil)
				else
					humanoid.WalkSpeed = humanoid:GetAttribute("Old_Speed")
				end

				humanoid:SetAttribute("Old_Speed", nil)
			end

			if humanoid:GetAttribute("Old_Jump") then
				humanoid.JumpPower = humanoid:GetAttribute("Old_Jump")
				humanoid:SetAttribute("Old_Jump", nil)
			end
		end
	end)
end

connections[#connections + 1] = humanoid.StateChanged:Connect(function(_, p)
	if p == Enum.HumanoidStateType.Freefall then
		if track6.IsPlaying then
			track6:Stop()
		end

		if track8.IsPlaying then
			track8:Stop()
		end

		for _, v18 in ipairs(animator:GetPlayingAnimationTracks()) do
			if v18.Name == "Idle" then
				v18:Stop()
			end
		end

		if v9 == 0 then
			v9 = 1
		end
	elseif p == Enum.HumanoidStateType.Landed then
		local baller = character:FindFirstChild("Baller")

		if baller and baller:GetAttribute("Idle_Animation") then
			track9:Play()
		end

		if v9 ~= 0 then
			v7 = maxJump
			v9 = 0
		end
	elseif p == Enum.HumanoidStateType.Climbing then
		if track6.IsPlaying then
			track6:Stop()
		end
	elseif p == Enum.HumanoidStateType.Seated and track6.IsPlaying then
		track6:Stop()
	end
end)
connections[#connections + 1] = character.ChildAdded:Connect(function(child)
	if child.Name == "Baller" and humanoid.MoveDirection.Magnitude ~= 0 then
		RunAnimation(humanoid.WalkSpeed)
	end
end)
connections[#connections + 1] = character.ChildRemoved:Connect(function(child)
	if track7.IsPlaying then
		track7:Stop()
	end

	if child.Name == "Baller" then
		if track8.IsPlaying then
			track8:Stop()
		end

		if humanoid.MoveDirection.Magnitude ~= 0 then
			RunAnimation(humanoid.WalkSpeed)
		end
	end
end)
connections[#connections + 1] = humanoid.Running:Connect(function(p)
	RunAnimation(p)
	humanoid.Running:Wait()
end)
connections[#connections + 1] = mouse.Button1Down:Connect(function()
	if v13 == true then
		lastTime4 = tick()
		v11 = 2
	end
end)
connections[#connections + 1] = mouse.Button1Up:Connect(function()
	if v11 == 2 and tick() - lastTime4 <= 0.25 then
		FlashStepActive(true)
	end
end)
onClientEventConnection = clientUI.OnClientEvent:Connect(function(p: string)
	if p == "Load_Character" then
		if diedConnection then
			diedConnection:Disconnect()
			diedConnection = nil
		end

		if onClientEventConnection then
			onClientEventConnection:Disconnect()
			onClientEventConnection = nil
		end

		for _, connection in ipairs(connections) do
			if connection then
				connection:Disconnect()
			end
		end

		table.clear(connections)
		Instinct_Visuals("Off")
		Instince_Frame("Disable")
	end
end)
diedConnection = humanoid.Died:Connect(function()
	if diedConnection then
		diedConnection:Disconnect()
		diedConnection = nil
	end

	if onClientEventConnection then
		onClientEventConnection:Disconnect()
		onClientEventConnection = nil
	end

	for _, connection in ipairs(connections) do
		if connection then
			connection:Disconnect()
		end
	end

	table.clear(connections)
	Instinct_Visuals("Off")
	Instince_Frame("Disable")
end)

if flag then
	local touchGui = playerGui:WaitForChild("TouchGui", 10)
	local touchControlFrame = touchGui and touchGui:WaitForChild("TouchControlFrame", 10)

	if touchControlFrame then
		local jumpButton = touchControlFrame:WaitForChild("JumpButton", 10)

		if jumpButton and jumpButton then
			connections[#connections + 1] = jumpButton.MouseButton1Up:Connect(function()
				if v9 ~= 2 then
					v9 = 2
				elseif v9 >= 2 then
					JumpActive()
				else
					v9 = 2
				end
			end)
		end
	end
end
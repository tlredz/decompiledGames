local createVector = vector.create
local v = 200
local v2 = 15
game:GetService("RunService")
game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local sharedSoru

if game.ReplicatedStorage.EffectContainer:FindFirstChild("Shared") and game.ReplicatedStorage.EffectContainer.Shared:FindFirstChild("Soru") then
	sharedSoru = Effect.new("Shared.Soru")
else
	sharedSoru = nil
end

local Util = require(game.ReplicatedStorage.Util)
local MobileUIController = require(game.ReplicatedStorage.Controllers.UI.MobileUIController)
local currentCamera = workspace.CurrentCamera
local v3 = {
	LastAfter = 0,
	LastUse = 0
}
local Global = require(game.ReplicatedStorage.Global)
Global.Dodging = false
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character
local mouse = localPlayer:GetMouse()
local touchEnabled = UserInputService.TouchEnabled
local flag = false

local function handleAction(p, p2, data)
	local SeatUtil = require(game.ReplicatedStorage.Util.SeatUtil)
	local v4 = false

	if localPlayer.Data.Race.Value == "Human" and localPlayer.Data.Race:FindFirstChild("Evolved") then
		v2 = 10
		v = 350
	else
		v4 = localPlayer.Data.Race.Value == "Skypiea" and localPlayer.Character and localPlayer.Character:FindFirstChild("RaceTransformed") and localPlayer.Character.RaceTransformed.Value and true or false
		v2 = 15
		v = 200
	end

	local flashstepCooldown = character:GetAttribute("FlashstepCooldown")

	if flashstepCooldown and flashstepCooldown > 0 then
		v2 *= 1 - flashstepCooldown
	end

	local v5 = touchEnabled and data.KeyCode == Enum.KeyCode.Unknown
	local v6

	if p2 == Enum.UserInputState.Begin then
		v6 = data.UserInputState == Enum.UserInputState.Begin
	else
		v6 = false
	end

	local v7

	if p2 == Enum.UserInputState.End then
		v7 = data.UserInputState == Enum.UserInputState.End
	else
		v7 = false
	end

	if not (v5 and v7) and (v5 or not v6) or not character:HasTag("Soru") then
		return
	end

	local contextButton = MobileUIController:GetContextButton(p)
	local v8 = data.UserInputType == Enum.UserInputType.MouseButton1

	if v5 or v8 then
		if flag then
			task.wait()
			flag = false
			local Global2 = require(game.ReplicatedStorage.Global)
			Global2.mobileSoru = false

			if contextButton then
				contextButton:SetAttribute("Selected", false)
			end

			return
		else
			if contextButton then
				contextButton:SetAttribute("Selected", true)
			end

			flag = true
			local Global2 = require(game.ReplicatedStorage.Global)
			Global2.mobileSoru = true
			local lastTime = tick()

			repeat
				task.wait()
			until tick() - lastTime > 0.03333333333333333

			if v8 then
				local flag2 = true
				local inputBeganConnection = nil
				inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
					if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessed then
						inputBeganConnection:Disconnect()
						inputBeganConnection = nil
						flag2 = false
					end
				end)

				while flag2 do
					task.wait()
				end
			else
				repeat
					local v9, v10 = UserInputService.TouchTapInWorld:Wait()
					_ = v9
				until v10 == false
			end

			if flag == false then
				if contextButton then
					contextButton:SetAttribute("Selected", false)
				end

				return
			end
		end
	end

	flag = false

	if contextButton then
		contextButton:SetAttribute("Selected", false)
	end

	local Global2 = require(game.ReplicatedStorage.Global)
	Global2.mobileSoru = false
	local humanoid = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart
	local p3 = mouse.Hit.p
	local now = tick()
	local tool = character:FindFirstChildOfClass("Tool")

	if tool and tool:GetAttribute("State") == "StartCasting" or (localPlayer.Character.Humanoid.Health <= 0 or SeatUtil.isSeated(character)) then
		return
	end

	local magnitude = (p3 - humanoidRootPart.Position).magnitude

	if v < magnitude then
		if not v4 then
			return
		end

		p3 = (CFrame.new(humanoidRootPart.Position, p3) * CFrame.new(0, 0, -v)).Position
	end

	if not character.Busy.Value then
		local Global3 = require(game.ReplicatedStorage.Global)

		if not (Global3.Swimming or humanoidRootPart.Anchored or character.Stun.Value > 0) then
			if not character:FindFirstChild("DoorMode") then
				if character:FindFirstChild("Phoenix") or character:FindFirstChild("Dragon") or character:FindFirstChild("DisableMovement") then
					return
				end
			end

			if character.Energy.Value < 10 then
				return
			end

			if now - v3.LastUse < v2 then
				local v9

				if character:FindFirstChild("Humanoid") and character.Humanoid:GetAttribute("SoruCharges") and character.Humanoid:GetAttribute("SoruCharges") > 0 then
					character.Humanoid:SetAttribute("SoruCharges", character.Humanoid:GetAttribute("SoruCharges") - 1)
					v9 = true
				else
					v9 = false
				end

				if not v9 then
					return
				end
			end

			local cFrame = humanoidRootPart.CFrame
			local v9 = humanoidRootPart.CFrame - humanoidRootPart.CFrame.p + p3 + Vector3.new(
				0,
				humanoidRootPart.Size.Y * 1.5,
				0
			)
			local ID = math.random(1, 999999999)
			game.ReplicatedStorage.Remotes.CommE:FireServer("Soru", cFrame, v9, workspace:GetServerTimeNow(), ID)
			local level = false
			local flag2 = false
			local v13 = false
			local v14 = character:FindFirstChild("YetiRig") and true or false

			if localPlayer.Data.Race.Value == "Human" and localPlayer.Character and localPlayer.Character:FindFirstChild("RaceTransformed") and localPlayer.Character.RaceTransformed.Value then
				if localPlayer.Data.Race:FindFirstChild("A") and localPlayer.Data.Race.A.Value >= 1 then
					level = localPlayer.Data.Race.A.Value
				end
			elseif localPlayer.Data.Race.Value == "Draco" and localPlayer.Data.Race:FindFirstChild("Evolved") then
				flag2 = true
			end

			if character:FindFirstChild("__Room") then
				local __Room = character:FindFirstChild("__Room")

				if __Room then
					local cFrame2 = __Room:GetAttribute("CFrame")
					local radius = __Room:GetAttribute("Radius")
					v13 = cFrame2 and radius and (v9.Position - cFrame2.Position).Magnitude <= radius and true or false
				end
			end

			local v15 = localPlayer.Data.DevilFruit.Value == "Gravity-Gravity" or false

			if v14 and not localPlayer:GetAttribute("RedYeti") then
				Effect.new("Yeti.Transformed.FlashStep"):play({
					Stage = 1,
					Origin = humanoidRootPart.Position,
					Root = humanoidRootPart,
					StartCFrame = cFrame,
					ID = ID
				})
			elseif v13 then
				local ray = Util.Ray
				local v16 = v9.Position + createVector(0, 1, 0)
				local v17 = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
				local instance, position, normal = ray(v16, createVector(-0, -10, -0), v17)
				Effect.new("ControlRework.Dodge"):play({
					Root = humanoidRootPart,
					Stage = 3,
					Character = character,
					Humanoid = humanoid,
					EndCF = v9,
					RaycastResult = instance and {
						Instance = instance,
						Position = position,
						Normal = normal
					} or nil
				})
			elseif v15 then
				Effect.new("Gravity.Teleport"):play({
					Stage = 1,
					Origin = humanoidRootPart.Position,
					Root = humanoidRootPart,
					StartCFrame = cFrame
				})
			elseif flag2 then
				Effect.new("DracoRace.Step"):play({
					ID = 1,
					CFrame = cFrame,
					Character = character,
					player = localPlayer
				})
			elseif not level and sharedSoru then
				sharedSoru:play({
					CFrame = cFrame,
					Character = character,
					Mode = 1,
					player = localPlayer
				})
			end

			if SeatUtil.isSeated(character) then
				return
			end

			v3.LastUse = now
			humanoidRootPart.CFrame = v9
			task.delay(1, function()
				if v2 - 1 <= 0 then
					return
				end

				game.ReplicatedStorage.Events.PlaySkillCooldownAnimation:Fire(
					"BoundActionSoru",
					"none",
					level and 0 or v2 - 1
				)
			end)

			if not v13 then
				if v14 and not localPlayer:GetAttribute("RedYeti") then
					Effect.new("Yeti.Transformed.FlashStep"):play({
						Stage = 2,
						Origin = humanoidRootPart.Position,
						Root = humanoidRootPart,
						EndCFrame = v9
					})
				elseif v15 then
					humanoidRootPart.Velocity = v9.LookVector * 100
					Effect.new("Gravity.Teleport"):play({
						Stage = 2,
						Origin = humanoidRootPart.Position,
						Root = humanoidRootPart,
						EndCFrame = v9
					})
					Util.Anims:Get(character, "GravityFlashstep"):Play()
				elseif flag2 then
					local v16 = 0.5 + humanoidRootPart.Size.Y * 0.5 + humanoid.HipHeight

					if Util.Ray(v9.p, createVector(0, 1, 0) * -v16, { workspace.Characters, workspace.Enemies }) then
						Util.Anims:Get(character, "FlashStepDraco"):Play(
							0,
							nil,
							(math.clamp((humanoidRootPart.Velocity * createVector(1, 0, 1)).Magnitude / 16, 1.1, 3.3))
						)
					end

					Effect.new("DracoRace.Step"):play({
						ID = 2,
						CFrame = humanoidRootPart.CFrame,
						Character = character,
						player = localPlayer
					})
				elseif level then
					Util.Anims:Get(character, "FlashStepRegular"):Play(
						0,
						nil,
						(math.clamp((humanoidRootPart.Velocity * createVector(1, 0, 1)).Magnitude / 16, 1.1, 3.3))
					)
					Effect.new("RaceAwakenings.Human"):play({
						Root = humanoidRootPart,
						originPos = cFrame,
						goalPos = v9,
						level = level
					})
				else
					Util.Anims:Get(character, "FlashStepRegular"):Play(
						0,
						nil,
						(math.clamp((humanoidRootPart.Velocity * createVector(1, 0, 1)).Magnitude / 16, 1.1, 3.3))
					)

					if sharedSoru then
						sharedSoru:play({
							CFrame = humanoidRootPart.CFrame,
							Character = character,
							Mode = 2
						})
					end
				end
			end
		end
	end
end

MobileUIController:UnbindContextButton("BoundActionSoru")
ContextActionService:UnbindAction("BoundActionSoru")
local connection = nil

local function instanceAdded(character2)
	if character2 == character then
		if connection then
			connection:Disconnect()
			connection = nil
		end

		local contextButton = MobileUIController:CreateContextButton(
			"BoundActionSoru",
			handleAction,
			Enum.KeyCode.R,
			Enum.KeyCode.ButtonR3
		)

		if contextButton then
			contextButton:SetAttribute("NonToolButton", true)
		else
			ContextActionService:BindAction(
				"BoundActionSoru",
				handleAction,
				false,
				Enum.KeyCode.R,
				Enum.KeyCode.ButtonR3
			)
		end
	end
end

if character:HasTag("Soru") then
	instanceAdded(character)
else
	connection = CollectionService:GetInstanceAddedSignal("Soru"):Connect(instanceAdded)
end

local function hook(p)
	if p and p.Name == "RaceTransformed" then
		p.Changed:Connect(function(p2)
			if p2 and localPlayer.Data.Race.Value == "Skypiea" then
				v3.LastUse = 0
			end
		end)
	end
end

game.Players.LocalPlayer.Character.ChildAdded:Connect(hook)
local raceTransformed = game.Players.LocalPlayer.Character:FindFirstChild("RaceTransformed")

if raceTransformed and raceTransformed.Name == "RaceTransformed" then
	raceTransformed.Changed:Connect(function(p)
		if p and localPlayer.Data.Race.Value == "Skypiea" then
			v3.LastUse = 0
		end
	end)
end
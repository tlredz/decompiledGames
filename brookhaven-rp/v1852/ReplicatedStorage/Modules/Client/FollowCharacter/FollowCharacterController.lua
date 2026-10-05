local createVector = vector.create
local FollowCharacterController = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local FollowCharacter = require(ReplicatedStorage.Modules.Client.Components.FollowCharacter.FollowCharacter)
local localPlayer = Players.LocalPlayer
local _1Bab1yFollo1w = nil
local jumpingConnection = nil
local cFrames = {}
local v = {}

function onSeated(p, p2)
	if p then
		local character = localPlayer.Character

		if not character then
			return
		end

		local humanoid = character:WaitForChild("Humanoid")

		if not humanoid then
			return
		end

		if character ~= nil and character:FindFirstChild("FollowCharacter") ~= nil and p2 ~= nil and p2.Name == "VehicleSeat" or character ~= nil and character:FindFirstChild("FollowCharacter") ~= nil and p2 ~= nil and p2.Name == "Passenger" or character ~= nil and character:FindFirstChild("FollowCharacter") ~= nil and p2 ~= nil and p2.Name == "PassengerBaby" or character ~= nil and character:FindFirstChild("FollowCharacter") ~= nil and p2 ~= nil and p2.Name == "PilotSeat" then
			local modelName = character.FollowCharacter:GetAttribute("ModelName")
			_1Bab1yFollo1w:FireServer("DeleteFollowCharacter")
			jumpingConnection = humanoid.Jumping:Connect(function(_: boolean)
				_1Bab1yFollo1w:FireServer("CharacterFollowSpawnPlayer", modelName)
				jumpingConnection:disconnect()
			end)
		end
	end
end

function FollowCharacterController.FrameworkInit() end

function FollowCharacterController.InsertDebugPositions(cFrame: CFrame)
	local v2

	if #v > 20 then
		v2 = v[1]
		table.remove(v, 1)
	else
		v2 = Instance.new("Part")
	end

	v2.Anchored = true
	v2.CanCollide = false
	v2.Name = "DebugPart"
	v2.Transparency = 0.5
	v2.Size = createVector(1, 1, 1)
	v2.Shape = Enum.PartType.Ball
	v2.Parent = game.Workspace
	v2.CFrame = cFrame
	table.insert(v, v2)
end

function FollowCharacterController.FrameworkStart()
	_1Bab1yFollo1w = ReplicatedStorage.RE:WaitForChild("1Bab1yFollo1w")
	_1Bab1yFollo1w.OnClientEvent:Connect(function(p, value, childName)
		local character = localPlayer.Character

		if p == "ClientHasFollowCharacter" and localPlayer ~= nil and character ~= nil then
			local formatted = `FollowCharacter{value or ""}`
			local child

			if childName then
				child = character:FindFirstChild(childName)

				if not child then
					warn((`FollowCharacterController.FrameworkStart() - Folder {childName} not found for player {localPlayer.Name}`))
					return
				end
			else
				child = character
			end

			if child:FindFirstChild(formatted) ~= nil then
				local child2 = child:FindFirstChild(formatted)
				local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
					child2,
					"FollowCharacter",
					FollowCharacter
				)

				if character then
					if not child2:GetAttribute("SkipOffset") then
						child2:SetPrimaryPartCFrame(character.HumanoidRootPart.CFrame * CFrame.new(2, -1.5, 2))
					end

					waitForAncestorComponent:StartFollowCharacter(
						character,
						child2.Torso,
						child2,
						FollowCharacterController
					)
				end
			end
		end
	end)
	local character = localPlayer.Character
	local humanoid = character and character:WaitForChild("Humanoid")

	if humanoid then
		humanoid.Seated:Connect(onSeated)
	end

	local now = 0
	RunService.RenderStepped:Connect(function()
		task.wait(0.15)

		if now + 0.1 < os.clock() then
			local character2 = localPlayer.Character

			if not character2 then
				return
			end

			local humanoidRootPart = character2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart or #cFrames ~= 0 and (humanoidRootPart.Position - cFrames[#cFrames].Position).Magnitude < 0.75 then
				return
			end

			table.insert(cFrames, humanoidRootPart.CFrame)

			if #cFrames > 20 then
				table.remove(cFrames, 1)
			end

			now = os.clock()
		end
	end)
end

function FollowCharacterController.GetPositionsForSlot(p: number)
	local v2 = (p - 2) * 3 + 2

	if #cFrames == 0 then
		return nil
	end

	if #cFrames < v2 then
		return cFrames[#cFrames]
	end

	return cFrames[#cFrames - v2]
end

return FollowCharacterController
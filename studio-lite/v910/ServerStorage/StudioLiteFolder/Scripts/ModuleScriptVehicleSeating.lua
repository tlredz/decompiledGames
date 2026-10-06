local createVector = vector.create
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
game:GetService("HttpService")
local parent = script.Parent.Parent
local v = nil
local v2 = {}
local ModuleScriptVehicleSeating = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getVehicleObject()
	return script.Parent.Parent
end

local function carjackingEnabled(instance)
	return instance:GetAttribute("AllowCarjacking")
end

local getEffectsFolderFromSeat

getEffectsFolderFromSeat = function(parent2)
	local parent3 = parent2.Parent

	if not parent3:IsA("Model") then
		return nil
	end

	if parent3:FindFirstChild("Effects") then
		return parent3.Effects
	end

	return getEffectsFolderFromSeat(parent3)
end

local function playDoorSound(instance, p)
	local child = instance:FindFirstChild(p .. "Door")

	if child then
		child:Play()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isFlipped(p)
	return math.deg((math.acos((p.CFrame.upVector:Dot(createVector(0, 1, 0)))))) >= 70
end

local Raycast

Raycast = function(p, p2, p3, p4, p5)
	local v3 = (p5 == nil and 0 or p5) + 1
	local part, v4 = Workspace:FindPartOnRayWithIgnoreList(Ray.new(p, p2 * p3), p4)

	if part and part.CanCollide == false and v3 <= 5 then
		part, v4 = Raycast(v4, p2, p3 - (p - v4).magnitude, p4, v3)
	end

	return part, v4
end

local function ExitSeat(playerFromCharacter, instance, part0, instance2)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		instance2:Destroy()

		if part0:FindFirstChild("DoorHinge") then
			part0.DoorLatchWeld.Enabled = false
			part0.DoorHinge.TargetAngle = 55
			local openCloseDoor = part0:FindFirstChild("OpenCloseDoor")

			if openCloseDoor then
				openCloseDoor:Play()
			end
		end

		v2[part0] = not v2[part0] and 1 or v2[part0] + 1 or 1
		task.wait()

		if part0:FindFirstChild("ExitPosition") then
			local v3 = part0

			while true do
				local parent2 = v3.Parent

				if parent2.ClassName ~= "Model" then
					break
				end

				v3 = parent2
			end

			local worldPosition = part0.ExitPosition.WorldPosition
			local v4 = worldPosition - part0.Position
			local magnitude = v4.magnitude
			local unit = v4.unit
			local v5, _ = Raycast(part0.Position, unit, magnitude, { instance, v3 })

			if v5 then
				humanoidRootPart.CFrame = CFrame.new(part0.Position)
				instance:MoveTo(part0.Position + createVector(0, 8, 0))
			else
				humanoidRootPart.CFrame = CFrame.new(worldPosition)
			end
		else
			humanoidRootPart.CFrame = CFrame.new(part0.Position)
			instance:MoveTo(part0.Position + createVector(0, 8, 0))
		end

		if playerFromCharacter then
			v.ExitSeat:FireClient(playerFromCharacter, true)
		end

		task.wait(0.5)
		local v3 = v2
		local v4

		if v2[part0] > 1 then
			v4 = v2[part0] - 1 or nil
		end

		v3[part0] = v4

		if part0:FindFirstChild("DoorHinge") and v2[part0] == nil then
			part0.DoorHinge.TargetAngle = 0

			while math.abs(part0.DoorHinge.CurrentAngle) > 0.01 do
				task.wait()
			end

			part0.DoorLatchWeld.Enabled = true
		end
	end
end

local function FlipSeat(_, parent2)
	if parent2 and parent2.Parent then
		if not parent2.Parent.Parent:FindFirstChild("Scripts") then
			warn("Flip Error: Scripts file not found. Please parent seats to the chassis model")
		elseif parent2.Parent.Parent.Scripts:FindFirstChild("Chassis") then
			local Chassis = require(parent2.Parent.Parent.Scripts.Chassis)
			Chassis.Redress()
		else
			warn("Flip Error: Chassis module not found.")
		end
	end
end

function ModuleScriptVehicleSeating.EjectCharacter(character)
	if character and character.HumanoidRootPart then
		for _, v3 in pairs(character.HumanoidRootPart:GetJoints()) do
			if v3.Name ~= "SeatWeld" then
				continue
			end

			ExitSeat(Players:GetPlayerFromCharacter(character), character, v3.Part0, v3)
			return
		end
	end
end

function ModuleScriptVehicleSeating.SetRemotesFolder(p)
	v = p
	v:FindFirstChild("ExitSeat").OnServerEvent:Connect(function(player)
		if player.Character then
			local character = player.Character
			ModuleScriptVehicleSeating.EjectCharacter(character)
		end
	end)
	v:FindFirstChild("ForceExitSeat").OnServerEvent:Connect(function(childName)
		local chassis = parent:FindFirstChild("Chassis")

		if chassis then
			local child = chassis:FindFirstChild(childName)

			if child and child.Occupant then
				local parent2 = child.Occupant.Parent
				ModuleScriptVehicleSeating.EjectCharacter(parent2)
			end
		end
	end)
end

function ModuleScriptVehicleSeating.SetBindableEventsFolder(instance)
	instance:FindFirstChild("ForceExitSeat").Event:Connect(function(childName)
		local chassis = parent:FindFirstChild("Chassis")

		if chassis then
			local child = chassis:FindFirstChild(childName)

			if child and child.Occupant then
				local parent2 = child.Occupant.Parent
				ModuleScriptVehicleSeating.EjectCharacter(parent2)
			end
		end
	end)
end

function ModuleScriptVehicleSeating.AddSeat(parent2, callback, callback2)
	local promptLocation = parent2:FindFirstChild("PromptLocation")
	local proximityPrompt = promptLocation and promptLocation:FindFirstChildWhichIsA("ProximityPrompt")

	if proximityPrompt then
		local vehicleObject = getVehicleObject() -- equivalent call inferred; original call site unknown

		local function setCarjackPrompt()
			if parent2.Occupant and not vehicleObject:GetAttribute("AllowCarjacking") then
				proximityPrompt.Enabled = false
			else
				proximityPrompt.Enabled = true
			end
		end

		parent2:GetPropertyChangedSignal("Occupant"):connect(setCarjackPrompt)
		vehicleObject:GetAttributeChangedSignal("AllowCarjacking"):Connect(setCarjackPrompt)
		proximityPrompt.Triggered:connect(function(player)
			if parent2 then
				if isFlipped(parent2) then
					FlipSeat(player, parent2)
				elseif (not parent2:FindFirstChild("SeatWeld") or vehicleObject:GetAttribute("AllowCarjacking")) and player.Character ~= nil then
					local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
					local humanoid = player.Character:FindFirstChild("Humanoid")

					if humanoidRootPart and (humanoidRootPart.Position - parent2.Position).magnitude <= 15 then
						if parent2.Occupant then
							local parent3 = parent2.Occupant.Parent

							for _, v4 in pairs(parent3.HumanoidRootPart:GetJoints()) do
								if v4.Name ~= "SeatWeld" then
									continue
								end

								ExitSeat(Players:GetPlayerFromCharacter(parent3), parent3, v4.Part0, v4)
								break
							end
						end

						parent2:Sit(humanoid)

						if parent2:FindFirstChild("DoorHinge") then
							if parent2.DoorHinge.ClassName ~= "HingeConstraint" then
								warn("Warning, door hinge is not actually a hinge!")
							end

							v2[parent2] = v2[parent2] and v2[parent2] + 1 or 1
							parent2.DoorLatchWeld.Enabled = false
							parent2.DoorHinge.TargetAngle = 55
							parent2.DoorHinge.AngularSpeed = 2.15
							local openCloseDoor = parent2:FindFirstChild("OpenCloseDoor")

							if openCloseDoor then
								openCloseDoor:Play()
							end

							task.wait(0.5)
							v2[parent2] = v2[parent2] > 1 and v2[parent2] - 1 or nil

							if v2[parent2] == nil then
								parent2.DoorHinge.TargetAngle = 0

								while math.abs(parent2.DoorHinge.CurrentAngle) > 0.01 do
									task.wait()
								end

								parent2.DoorLatchWeld.Enabled = true
							end
						end
					end
				end
			end
		end)
	end

	local parent3 = parent2.Parent
	local effects

	if parent3:IsA("Model") then
		if parent3:FindFirstChild("Effects") then
			effects = parent3.Effects
		else
			effects = getEffectsFolderFromSeat(parent3)
		end
	end

	local openCloseDoor = effects and effects:FindFirstChild("OpenCloseDoor")

	if openCloseDoor then
		local clone = openCloseDoor:Clone()
		clone.Parent = parent2
	end

	local occupant = nil
	local occupantChangedConnection = parent2:GetPropertyChangedSignal("Occupant"):Connect(function()
		if parent2.Occupant then
			if callback then
				occupant = parent2.Occupant
				occupant = Players:GetPlayerFromCharacter(occupant.Parent) or occupant
				callback(occupant, parent2)
			end
		elseif callback2 then
			callback2(occupant, parent2)
			occupant = nil
		end
	end)
	parent2.AncestryChanged:connect(function()
		if not parent2:IsDescendantOf(game) then
			occupantChangedConnection:Disconnect()
		end
	end)
end

return ModuleScriptVehicleSeating
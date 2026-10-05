local createVector = vector.create
local Players = game:GetService("Players")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)
local ToolActionInput = require(ReplicatedStorage.Shared.ToolActionInput)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local isTradePlaza = ServerData.IsTradePlaza()
local parent = script.Parent
local playerFromCharacter

if parent.Parent:IsA("Model") then
	playerFromCharacter = Players:GetPlayerFromCharacter(parent.Parent)
else
	playerFromCharacter = parent.Parent.Parent
end

assert(playerFromCharacter and playerFromCharacter:IsA("Player"))

if playerFromCharacter ~= Players.LocalPlayer then
	return
end

local character = playerFromCharacter.Character and playerFromCharacter.Character.Parent == workspace and playerFromCharacter.Character or playerFromCharacter.CharacterAdded:Wait()
local v = assert(character:WaitForChild("HumanoidRootPart", 5))
local v2 = assert(character:WaitForChild("Humanoid", 5))
parent:WaitForChild("Handle")
local santasSleighPresent = playerFromCharacter.PlayerGui:WaitForChild("ToolsFrames"):WaitForChild("SantasSleighPresent")
local _ = {
	X = 66,
	Z = 99
}
local v3 = {
	Forward = {
		Mode = false,
		Keys = {
			Key = "w",
			ByteKey = 17
		}
	},
	Backward = {
		Mode = false,
		Keys = {
			Key = "s",
			ByteKey = 18
		}
	},
	Left = {
		Mode = false,
		Keys = {
			Key = "a",
			ByteKey = 20
		}
	},
	Right = {
		Mode = false,
		Keys = {
			Key = "d",
			ByteKey = 19
		}
	}
}
local flag = false
local v4 = false
local changedConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function CheckIfAlive()
	if character and character.Parent and v2 and v2.Parent and v2.Health > 0 and v and v.Parent and playerFromCharacter and playerFromCharacter.Parent then
		return true
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DisableJump(flag2: boolean)
	if changedConnection then
		changedConnection:Disconnect()
	end

	if flag2 then
		changedConnection = v2.Changed:Connect(function(p)
			if p == "Jump" then
				v2.Jump = false
			end
		end)
	end
end

local childAddedConnection = nil

local function HandleFlightControl()
	if not CheckIfAlive() then
		return
	end

	if childAddedConnection then
		childAddedConnection:Disconnect()
	end

	childAddedConnection = v.ChildAdded:Connect(function(child)
		if flag then
			return
		end

		if child.Name == "FlightHold" then
			local flightSpin = v:FindFirstChild("FlightSpin")
			local flightPower = v:FindFirstChild("FlightPower")
			local flightHold = v:FindFirstChild("FlightHold")

			if not (flightSpin and flightPower and flightHold) then
				return
			end

			flag = true
			santasSleighPresent.Visible = not isTradePlaza
			v2.WalkSpeed = 0
			v2.PlatformStand = true
			v2.AutoRotate = false

			if changedConnection then
				changedConnection:Disconnect()
			end

			changedConnection = v2.Changed:Connect(function(p)
				if p == "Jump" then
					v2.Jump = false
				end
			end)
			v.Velocity = createVector(0, 0, 0)
			v.RotVelocity = createVector(0, 0, 0)
			local v5 = assert(workspace.CurrentCamera)

			while flag and flightSpin.Parent and flightPower.Parent and flightHold.Parent and character and character.Parent and v2 and v2.Parent and v2.Health > 0 and v and v.Parent and playerFromCharacter and playerFromCharacter.Parent do
				local v6 = createVector(0, 0, 0)
				local cFrame = v5.CFrame
				local vectorToWorldSpace = cFrame:VectorToWorldSpace(createVector(0, 0, -1))
				local vectorToWorldSpace2 = cFrame:VectorToWorldSpace(createVector(-1, 0, 0))
				local vectorToObjectSpace = CFrame.new(createVector(0, 0, 0), cFrame.LookVector * createVector(1, 0, 1)):VectorToObjectSpace(v2.MoveDirection)
				local v7 = v6 + (vectorToWorldSpace * 99 * -vectorToObjectSpace.Z or v6)
				local velocity = v7 + (vectorToWorldSpace2 * 66 * -vectorToObjectSpace.X or v7)
				flightSpin.CFrame = CFrame.new(createVector(0, 0, 0), vectorToWorldSpace)

				if velocity.Magnitude < 1 then
					flightHold.MaxForce = Vector3.new(flightHold.P, flightHold.P, flightHold.P)
					flightPower.MaxForce = createVector(0, 0, 0)
					flightHold.Position = v.Position
				else
					flightHold.MaxForce = createVector(0, 0, 0)
					flightPower.MaxForce = Vector3.new(flightPower.P * 100, flightPower.P * 100, flightPower.P * 100)
				end

				flightPower.Velocity = velocity
				task.wait(0.016666666666666666)
			end

			flag = false
			santasSleighPresent.Visible = false

			if CheckIfAlive() then
				v.Velocity = createVector(0, 0, 0)
				v.RotVelocity = createVector(0, 0, 0)
				v2.WalkSpeed = 16
				v2.PlatformStand = false
				v2.AutoRotate = true
				DisableJump(false) -- equivalent call inferred; original call site unknown
				v2:ChangeState(Enum.HumanoidStateType.Freefall)
			end
		end
	end)
end

local function KeyPress(value: string, mode: boolean)
	local v5 = string.lower(value)
	local v6 = string.byte(v5)

	for k, v7 in pairs(v3) do
		if v5 == v7.Keys.Key or v6 == v7.Keys.ByteKey then
			v3[k].Mode = mode
		end
	end
end

local function Equipped(p)
	if not CheckIfAlive() then
		return
	end

	v4 = true
	p.KeyDown:Connect(function(p2)
		KeyPress(p2, true)
	end)
	p.KeyUp:Connect(function(p2)
		KeyPress(p2, false)
	end)
	task.spawn(HandleFlightControl)
end

local function Unequipped()
	if not v4 then
		return
	end

	flag = false
	santasSleighPresent.Visible = false
	local v5 = { changedConnection, childAddedConnection }

	for _, connection in pairs(v5) do
		if connection then
			connection:Disconnect()
		end
	end

	for k, _ in pairs(v3) do
		v3[k].Mode = false
	end

	v4 = false
end

parent.Equipped:Connect(Equipped)
parent.Unequipped:Connect(Unequipped)

if not isTradePlaza then
	local v5 = ToolActionInput.bind(santasSleighPresent, santasSleighPresent.Activate, function()
		Net:RemoteEvent("Tools/SantasSleigh/DropPresent"):FireServer()
	end)
	parent.Destroying:Connect(v5)
end

local function UpdateCooldown()
	local cooldownTime = tonumber(parent:GetAttribute("CooldownTime") or 0) or 0

	if cooldownTime > 0 then
		santasSleighPresent.Activate.ImageColor3 = Color3.fromRGB(128, 128, 128)
		santasSleighPresent.Activate.Icon.ImageColor3 = Color3.fromRGB(128, 128, 128)
		santasSleighPresent.Activate.Txt.TextColor3 = Color3.fromRGB(128, 128, 128)
		santasSleighPresent.Activate.Cooldown.Text = string.format("%0.1f", cooldownTime)
		santasSleighPresent.Activate.Cooldown.Visible = true
	else
		santasSleighPresent.Activate.ImageColor3 = Color3.fromRGB(255, 255, 255)
		santasSleighPresent.Activate.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
		santasSleighPresent.Activate.Txt.TextColor3 = Color3.fromRGB(255, 255, 255)
		santasSleighPresent.Activate.Cooldown.Visible = false
	end
end

parent:GetAttributeChangedSignal("CooldownTime"):Connect(UpdateCooldown)
UpdateCooldown()
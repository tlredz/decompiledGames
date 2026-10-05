local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local currentCamera = workspace.CurrentCamera
local Players = game:GetService("Players")
Players = Players.LocalPlayer
game:GetService("UserInputService")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local controllers = script:WaitForChild("Controllers")
local modules = {
	Movement = require(controllers:WaitForChild("Movement")),
	Effect = require(controllers:WaitForChild("Effect")),
	Audio = require(controllers:WaitForChild("Audio")),
	Animation = require(controllers:WaitForChild("Animation")),
	SteeringWheel = require(controllers:WaitForChild("SteeringWheel"))
}
require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Effect"))
local v2 = string.format("Core/%s", controllers.Parent.Name)
local flag = false
local v3 = {}

local function getShipFromPlayer(p)
	for k, v4 in pairs(v3) do
		if v4.Movement and v4.Movement.Owner == p then
			return v4, k
		end
	end
end

local Global = require(game.ReplicatedStorage.Global)
Global.getLocalShipFromPlayer = getShipFromPlayer
local Global2 = require(game.ReplicatedStorage.Global)

function Global2.getShipFromBoat(p)
	for k, v4 in pairs(v3) do
		if v4.Boat == p then
			return v4, k
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createLoop()
	if flag then
		return
	end

	flag = true
	RunService:BindToRenderStep(v2, 0, function(p)
		local count = 0

		for k, v4 in pairs(v3) do
			if v4.Boat:IsDescendantOf(workspace) and v4.Boat:FindFirstChild("VehicleSeat") then
				local v5 = (currentCamera.CFrame.p - v4.Boat:GetModelCFrame().p).Magnitude < 1000 + 2 * v4.Boat:GetModelSize().Magnitude
				v4.Movement:update(p)
				local v6 = not v5 and 0 or v4.Movement.SpeedAlpha or 0
				local position = v4.Movement.SmoothSteer:GetPosition()
				local v7 = not v5 and 0 or v4.Movement.Throttle or 0
				local steer = v4.Movement.Steer
				v4.Effect:update(v6, position, v7)
				v4.Audio:update(v6, position, v7)
				v4.Animation:update(v6, position, v7)

				if v4.SteeringWheel then
					v4.SteeringWheel:update(
						v6,
						v5 and position or 0,
						not v5 and 0 or v4.Movement.SteerSpring:GetPosition() or 0,
						v5 and steer or 0
					)
				end

				if v4.Movement.Active or v4.Movement.SpeedAlpha ~= 0 then
					count += 1
				end
			else
				v3[k] = nil
			end
		end

		if count ~= 0 then
			return
		end

		flag = false
		RunService:UnbindFromRenderStep(v2)
	end)
end

remotes.Ship.OnClientEvent:Connect(function(p, p2, options)
	local Global3 = require(game.ReplicatedStorage.Global)
	local encoded = Global3.Encode(p)

	if p2 then
		if encoded and typeof(encoded) == "Instance" and encoded:IsA("Model") then
			local v4 = nil

			for _, v6 in pairs(v3) do
				if v6.Boat ~= encoded then
					continue
				end

				v4 = v6
				break
			end

			if v4 then
				v4.Movement:refresh(options)

				if v4.SteeringWheel then
					v4.SteeringWheel:unregister()
					v4.SteeringWheel = nil
				end

				v4.SteeringWheel = modules.SteeringWheel.register(v4.Boat, options)
			else
				local v6 = options or {}
				v6.Boat = encoded
				v6.Movement = modules.Movement.register(v6.Boat, options)
				v6.Effect = modules.Effect.register(v6.Boat)
				v6.Audio = modules.Audio.register(v6.Boat)
				v6.Animation = modules.Animation.register(v6.Boat)
				v6.SteeringWheel = modules.SteeringWheel.register(v6.Boat, options)
				table.insert(v3, v6)
			end

			createLoop() -- equivalent call inferred; original call site unknown
		else
			local fullName

			if encoded then
				if typeof(encoded) == "Instance" then
					fullName = encoded:GetFullName()
				else
					fullName = false
				end
			else
				fullName = encoded
			end

			print("Tried to set an illegal type of boat:", encoded, fullName)
		end
	else
		local v5

		for _, v6 in pairs(v3) do
			if v6.Boat ~= encoded then
				continue
			end

			v5 = v6
			break
		end

		local v6

		if v5 then
			v6 = v5
		else
			local owner = options.Owner

			for _, v8 in pairs(v3) do
				if not (v8.Movement and v8.Movement.Owner == owner) then
					continue
				end

				v6 = v8
				break
			end
		end

		if v6 then
			v6.Movement:unregister()

			if v6.SteeringWheel then
				v6.SteeringWheel:unregister()
				v6.SteeringWheel = nil
			else
				print("how???", v6)
			end
		end

		createLoop() -- equivalent call inferred; original call site unknown
	end
end)
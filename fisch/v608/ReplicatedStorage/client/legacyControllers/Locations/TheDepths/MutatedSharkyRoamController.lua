local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Net = require(ReplicatedStorage.packages.Net)
local module = require("../../ZoneController")
local unreliableRemoteEvent = Net:UnreliableRemoteEvent("MutatedSharky/UpdateUnreliable")
local remoteEvent = Net:RemoteEvent("MutatedSharky/UpdateReliable")
local remoteEvent2 = Net:RemoteEvent("MutatedSharky/Catch")
local MutatedSharkyRoamController = {}
local v = {
	Active = false,
	State = "Wander",
	CurrentSpeed = 0,
	CurrentPath = 0,
	CurrentPathId = 0,
	CurrentPathIndex = 1,
	CurrentPathAlpha = 0
}
v.CurrentPath = { createVector(0, 0, 0) }
local identity = CFrame.identity
local currentPathId = 0
local v2 = 0
local v3 = nil
local v4 = nil

function MutatedSharkyRoamController.GetCurrentPosition()
	local vector2 = v.CurrentPath[v.CurrentPathIndex]
	local vector3 = v.CurrentPath[v.CurrentPathIndex + 1]

	if vector3 and not (v.CurrentPathAlpha >= 1) then
		return CFrame.lookAt(vector2:Lerp(vector3, v.CurrentPathAlpha), vector3, createVector(0, 1, 0))
	end

	if v3 then
		return v3:GetPivot().Rotation + (vector3 or vector2)
	end

	return CFrame.new(vector3 or vector2)
end

function MutatedSharkyRoamController.TickMovement(p: number)
	debug.profilebegin("MutatedSharkyRoamController::TickMovement")
	local v5 = v.CurrentSpeed * p

	while v5 > 0 do
		local vector2 = v.CurrentPath[v.CurrentPathIndex]
		local vector3 = v.CurrentPath[v.CurrentPathIndex + 1]

		if vector3 then
			local magnitude = (vector3 - vector2).Magnitude
			local v6 = magnitude * (1 - v.CurrentPathAlpha)
			v.CurrentPathAlpha += v5 / magnitude
			v5 -= v6

			if v.CurrentPathAlpha >= 1 then
				v.CurrentPathIndex += 1
				v.CurrentPathAlpha = 0
			end
		else
			v.CurrentPathIndex -= 1
			v.CurrentPathAlpha = 1
			break
		end
	end

	debug.profileend()
end

function MutatedSharkyRoamController.Tick(p: number)
	if v.Active then
		if not (v3 and v3.PrimaryPart) then
			return
		end

		if v.CurrentPathId ~= currentPathId then
			print("path desync:", v.CurrentPathId, currentPathId)
			return
		end

		debug.profilebegin("MutatedSharkyRoamController::Tick")
		MutatedSharkyRoamController.TickMovement(p)
		local smoothDamp, v5 = TweenService:SmoothDamp(
			v3:GetPivot(),
			MutatedSharkyRoamController.GetCurrentPosition(),
			identity,
			0.1,
			nil,
			p
		)
		v3:PivotTo(smoothDamp)
		identity = v5
		local stateLabel = v3.RootPart.stateIndicator.stateLabel

		if v.State == "Curious" then
			stateLabel.Text = "?"
		elseif v.State == "Flee" then
			if v.CurrentSpeed >= 48 then
				stateLabel.Text = "!!!"
			else
				stateLabel.Text = "!"
			end
		else
			stateLabel.Text = ""
		end

		if v4 then
			v4:AdjustSpeed(identity.Position.Magnitude / 16)
		end

		debug.profileend()
	else
		identity = CFrame.identity

		if v3 then
			v3:Destroy()
			v3 = nil
		end

		if v4 then
			v4:Destroy()
			v4 = nil
		end
	end
end

function MutatedSharkyRoamController.Activate()
	if not v3 then
		local clone = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("instances"):WaitForChild("general"):WaitForChild("RoamingMutatedSharky"):Clone()
		clone:PivotTo(MutatedSharkyRoamController.GetCurrentPosition())
		clone.ProximityPrompt.Triggered:Connect(function()
			remoteEvent2:FireServer()
		end)
		clone.Parent = workspace.active
		v3 = clone
		local track = clone.AnimationController.Animator:LoadAnimation(clone.Swim)
		track:Play()
		v4 = track
	end
end

function MutatedSharkyRoamController.Deactivate()
	v.Active = false

	if v3 then
		v3:Destroy()
		v3 = nil
	end

	if v4 then
		v4:Destroy()
		v4 = nil
	end
end

function MutatedSharkyRoamController.Start(_)
	unreliableRemoteEvent.OnClientEvent:Connect(function(list, p: number)
		if p < v2 then
			return
		end

		v2 = p
		v.CurrentSpeed = list[1]
		v.CurrentPathIndex = list[2]
		v.CurrentPathAlpha = list[3]
		v.CurrentPathId = list[4]
		local v5 = workspace:GetServerTimeNow() - p
		MutatedSharkyRoamController.TickMovement(v5)
	end)
	remoteEvent.OnClientEvent:Connect(function(p, p2: number)
		local v5 = v
		v = p

		if p2 < v2 then
			warn("got outdated reliable, overwriting certain stuff")

			if p.CurrentPathId == v5.CurrentPathId then
				v.CurrentSpeed = v5.CurrentSpeed
				v.CurrentPathIndex = v5.CurrentPathIndex
				v.CurrentPathAlpha = v5.CurrentPathAlpha
			else
				warn("nvm what?", p.CurrentPathId, v5.CurrentPathId)
			end
		else
			v2 = p2
		end

		currentPathId = p.CurrentPathId

		if v5.Active ~= p.Active then
			if p.Active then
				MutatedSharkyRoamController.Activate()
			else
				MutatedSharkyRoamController.Deactivate()
			end
		end

		local v6 = workspace:GetServerTimeNow() - p2
		MutatedSharkyRoamController.TickMovement(v6)
	end)
	module.ZoneChanged:Connect(function(p)
		if p ~= "The Depths" then
			MutatedSharkyRoamController.Deactivate()
		end
	end)
	RunService:BindToRenderStep(
		"MutatedSharkyUpdate",
		Enum.RenderPriority.Character.Value + 10,
		MutatedSharkyRoamController.Tick
	)
end

return MutatedSharkyRoamController
local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local v = Component.new({
	Tag = "HotAirBalloon"
})
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Players = game:GetService("Players")
local Signal = require(ReplicatedStorage.Packages.Signal)
v.OnTakeControl = Signal.new()
v.OnReleaseControl = Signal.new()

function v.GetPilotSeat(p)
	return p.Instance:FindFirstChild("PilotSeat")
end

function v:GetDistanceToGround()
	local characters = { self.Instance }

	for _, v2 in Players:GetPlayers() do
		if v2.Character then
			table.insert(characters, v2.Character)
		end
	end

	self._raycastParams.FilterDescendantsInstances = characters
	local raycastResult = workspace:Raycast(self._mainPart.Position, createVector(0, -100, 0), self._raycastParams)

	if not raycastResult or (raycastResult.Instance:HasTag("MilitaryVehicleCollider") or raycastResult.Instance:HasTag("AntiAircraftZone")) then
		return 1e999
	end

	return raycastResult.Distance
end

function v.ChangeMovementAngle(p, p2: number)
	return Remotes.invokeServerComponent(p.Instance, "ChangeMovementAngle", (tonumber(p2)))
end

function v.ChangeSpeed(p, p2: number)
	return Remotes.invokeServerComponent(p.Instance, "ChangeSpeed", (tonumber(p2)))
end

function v.StartHoldMovement(p, p2: string)
	return Remotes.invokeServerComponent(p.Instance, "StartHoldMovement", p2)
end

function v.StopHoldMovement(p)
	return Remotes.invokeServerComponent(p.Instance, "StopHoldMovement")
end

function v.SetSpeed(p, p2: number)
	return Remotes.invokeServerComponent(p.Instance, "SetSpeed", p2)
end

function v.GetSpeed(p)
	return Remotes.invokeServerComponent(p.Instance, "GetSpeed")
end

function v.ChangeSkin(p, p2: number)
	return Remotes.invokeServerComponent(p.Instance, "ChangeSkin", p2)
end

function v.ExitVehicle(p)
	return Remotes.invokeServerComponent(p.Instance, "ExitVehicle")
end

function v:TakeControl()
	PanelController.ToggleGroup("TopArea", false)
	PanelController.Open("HotAirBalloonControl", "HotAirBalloonControl")
	self.OnTakeControl:Fire(self)
end

function v:ReleaseControl()
	PanelController.Close("HotAirBalloonControl", "HotAirBalloonControl")
	self.OnReleaseControl:Fire(self)
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "TakeControl", function()
		self:TakeControl()
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "ReleaseControl", function()
		self:ReleaseControl()
	end))
end

function v:Stop()
	PanelController.Close("HotAirBalloonControl", "HotAirBalloonControl")
	self.OnReleaseControl:Fire(self)
	self._Janitor:Destroy()
end

return v
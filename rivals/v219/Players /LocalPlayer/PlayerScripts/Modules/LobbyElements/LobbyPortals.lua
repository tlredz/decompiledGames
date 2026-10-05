local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local PreloadController = require(Players.LocalPlayer.PlayerScripts.Controllers.PreloadController)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local LobbyElement = require(Players.LocalPlayer.PlayerScripts.Modules.LobbyElement)
local object = setmetatable({}, LobbyElement)
object.__index = object

function object._new(...)
	local self = setmetatable(LobbyElement.new(...), object)
	self._teleport_cooldown = 0
	self:_Init()
	return self
end

function object:_ObjectAdded(instance)
	if CONSTANTS.IS_ARCADE_SERVER then
		return
	end

	local camera = instance:WaitForChild("Camera")
	local entrance = instance:WaitForChild("Entrance")
	local exit = instance:WaitForChild("Exit")
	entrance.Touched:Connect(function(otherPart)
		if tick() < self._teleport_cooldown or otherPart.Parent ~= Players.LocalPlayer.Character or not (FighterController.LocalFighter and FighterController.LocalFighter:IsAlive()) then
			return
		end

		if SpectateController.CurrentDuelSubject or SpectateController.CurrentSubject ~= FighterController.LocalFighter then
			return
		end

		self._teleport_cooldown = tick() + 5.3 + 1
		Utility:CreateSound("rbxassetid://86785771664692", 0.5, 1 + 0.1 * math.random(), entrance, true, 10)
		Utility:CreateSound("rbxassetid://81610952487049", 1, 1 + 0.1 * math.random(), exit, true, 10)
		local humanoid = FighterController.LocalFighter.Entity.Humanoid
		local upperTorso = FighterController.LocalFighter.Entity.Model:FindFirstChild("UpperTorso")
		local rootPart = FighterController.LocalFighter.Entity.RootPart
		local rootRigAttachment = rootPart:FindFirstChild("RootRigAttachment")
		local alignPosition = Instance.new("AlignPosition")
		alignPosition.Position = exit.Position
		alignPosition.Attachment0 = rootRigAttachment
		alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
		alignPosition.MaxAxesForce = createVector(1, 0, 1) * 1e999
		alignPosition.Responsiveness = 20
		alignPosition.ForceRelativeTo = Enum.ActuatorRelativeTo.World
		alignPosition.ForceLimitMode = Enum.ForceLimitMode.PerAxis
		alignPosition.Parent = rootPart
		BetterDebris:AddItem(alignPosition, 5.3)
		local alignOrientation = Instance.new("AlignOrientation")
		alignOrientation.Attachment0 = rootRigAttachment
		alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
		alignOrientation.CFrame = exit.CFrame.Rotation
		alignOrientation.RigidityEnabled = true
		alignOrientation.Parent = rootPart
		BetterDebris:AddItem(alignOrientation, 5.3)
		rootPart.CFrame = exit.CFrame + Vector3.new(math.random() - 0.5, 0, math.random() - 0.5) * exit.Size
		humanoid:LoadAnimation(PreloadController:GetPreloadedAnimation("LobbyPortalFalling")):Play(0)
		RunService:BindToRenderStep("LobbyPortalFalling", CameraController:GetRenderstepPriority() + 1, function(_)
			workspace.CurrentCamera.FieldOfView = 30
			workspace.CurrentCamera.CFrame = CFrame.new(camera.Position, (upperTorso or rootPart).Position)
		end)
		wait(5.3)
		RunService:UnbindFromRenderStep("LobbyPortalFalling")
	end)
end

function object:_Init()
	CollectionService:GetInstanceAddedSignal("LobbyPortal"):Connect(function(p)
		self:_ObjectAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("LobbyPortal")) do
		task.defer(self._ObjectAdded, self, v)
	end
end

return object._new()
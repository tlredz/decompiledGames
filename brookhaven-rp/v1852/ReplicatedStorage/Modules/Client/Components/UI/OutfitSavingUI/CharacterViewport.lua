local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Observers = require(ReplicatedStorage.Packages.Observers)
local v = Component.new({
	Tag = "CharacterViewport"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._characterVisualJanitor = self._Janitor:Add(Janitor.new())
	self._worldModel = self._Janitor:Add(Instance.new("WorldModel"))
	self._camera = self._Janitor:Add(Instance.new("Camera"))
	self._worldModel.Parent = self.Instance
	self._camera.Parent = self._worldModel
	self.Instance.CurrentCamera = self._camera
	self._cameraYaw = 0
end

function v:Start()
	self._Janitor:Add(Observers.observeLocalCharacter(function(instance)
		local maid = Janitor.new()
		maid:Add(instance.ChildAdded:Connect(function(instance2)
			if instance2:IsA("Tool") or instance2:IsA("Model") or instance2:IsA("Script") or instance2:IsA("BasePart") then
				return
			end

			task.wait(0.1)
			self:UpdateCharacter()
		end))
		maid:Add(instance.ChildRemoved:Connect(function(instance2)
			if instance2:IsA("Tool") or instance2:IsA("Model") or instance2:IsA("Script") or instance2:IsA("BasePart") then
				return
			end

			task.wait(0.1)
			self:UpdateCharacter()
		end))
		self:UpdateCharacter()
		return function()
			maid:Destroy()
		end
	end))
	local touch = nil
	local vector = Vector2.new(0, 0)

	if self.Instance:GetAttribute("Rotatable") then
		self._Janitor:Add(self.Instance.InputBegan:Connect(function(input, _: boolean)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			touch = input.UserInputType == Enum.UserInputType.Touch and Enum.UserInputType.Touch or Enum.UserInputType.MouseMovement
			vector = input.Position
		end))
		self._Janitor:Add(UserInputService.InputChanged:Connect(function(input, _: boolean)
			if input.UserInputType == touch then
				local v2 = input.Position - vector
				vector = input.Position
				self._cameraYaw -= v2.X * 0.01
				self:UpdateCamera()
			end
		end))
		self._Janitor:Add(UserInputService.TouchMoved:Connect(function(data, _: boolean)
			if data.UserInputType == touch and data.UserInputState == Enum.UserInputState.Begin then
				local v2 = data.Position - vector
				vector = data.Position
				self._cameraYaw -= v2.X * 0.01
				self:UpdateCamera()
			end
		end))
		self._Janitor:Add(UserInputService.InputEnded:Connect(function(input, _: boolean)
			if (input.UserInputType == Enum.UserInputType.Touch and Enum.UserInputType.Touch or Enum.UserInputType.MouseButton1) == input.UserInputType then
				touch = nil
			end
		end))
	end
end

function v:UpdateCharacter()
	local character = Players.LocalPlayer.Character

	if not character then
		self._characterVisualJanitor:Cleanup()
		return
	end

	self._characterVisualJanitor:Cleanup()
	local archivablesByPart = {}

	for _, part in character:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		archivablesByPart[part] = part.Archivable
		part.Archivable = true
	end

	character.Archivable = true
	local folder = self._characterVisualJanitor:Add(character:Clone())
	character.Archivable = false

	for _, descendant in folder:GetDescendants() do
		if not (descendant:IsA("Tool") or descendant:IsA("Model") or descendant:IsA("Script") or descendant:IsA("Sound")) then
			continue
		end

		descendant:Destroy()
	end

	for k, archivable in archivablesByPart do
		k.Archivable = archivable
	end

	folder.Parent = self._worldModel
	self._clonedCharacter = folder
	self:UpdateCamera()
end

function v:UpdateCamera()
	if not self._clonedCharacter then
		return
	end

	self._camera.CFrame = self._clonedCharacter:GetPivot() * CFrame.Angles(0, 3.141592653589793 + self._cameraYaw, 0) * CFrame.new(
		0,
		-0.5,
		5.5
	)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v
local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local QuaternionSpring = require(ReplicatedStorage.Modules.QuaternionSpring)
local GameplayUtility = require(ReplicatedStorage.Modules.GameplayUtility)
local Quaternion = require(ReplicatedStorage.Modules.Quaternion)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Spring = require(ReplicatedStorage.Modules.Spring)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local WrapController = require(Players.LocalPlayer.PlayerScripts.Controllers.WrapController)
local spearTightropes = Players.LocalPlayer.PlayerScripts.Assets.SpearTightropes
local Tightrope = {}
Tightrope.__index = Tightrope

function Tightrope.new(tightropeController, part)
	local self = setmetatable({}, Tightrope)
	self.TightropeController = tightropeController
	self.Part = part
	self.Active = false
	self.Character = nil
	self._destroyed = false
	self._id = HttpService:GenerateGUID(false)
	self._connections = {}
	self._active_connections = {}
	self._align_position = Instance.new("AlignPosition")
	self._spring = Spring.new(0, 0.25, 8)
	self._cooldown = 0
	self._platform = Instance.new("Part")
	self._visuals = {}
	self._beam0 = nil
	self._beam1 = nil
	self._start_time = 0
	self._touched_cooldowns = {}
	self._object_id = self.Part:GetAttribute("ObjectID")
	self._minimum_momentum_percentage = self.Part:GetAttribute("MinimumMomentumPercentage") or 0
	self._is_spear = self.Part:GetAttribute("IsSpear")
	self._viewmodel_name = self.Part:GetAttribute("ViewModelName")
	self._spear_model = nil
	self._spear_spin = nil
	self._spear_spring = nil
	self:_Init()
	return self
end

function Tightrope:IsTooVertical()
	return Utility:AngleBetweenVectors(self.Part.CFrame.UpVector, createVector(0, 1, 0)) < 0.1308996938995747 or Utility:AngleBetweenVectors(
		self.Part.CFrame.UpVector,
		createVector(-0, -1, -0)
	) < 0.1308996938995747
end

function Tightrope:JumpOff()
	if not self.Active then
		return
	end

	local v = math.max(0, self._spring.Velocity) ^ 2 * 0.25 / 25
	local v2 = math.clamp(math.max(self._minimum_momentum_percentage, v), 0, 1) * 25
	self.Character.HumanoidRootPart.Velocity = createVector(0, 1, 0) * (v2 + 25)
	self._cooldown = tick() + 0.5
	self:Disable()
end

function Tightrope:Enable()
	if self.Active or self:IsTooVertical() or not FighterController.LocalFighter or not FighterController.LocalFighter:IsAlive() or FighterController.LocalFighter.Entity:Get("IsFrozen") then
		return
	end

	FighterController.LocalFighter.Entity:AirborneCancel()
	self.Active = true
	self.Character = Players.LocalPlayer.Character
	self._spring.Value = self.Character.HumanoidRootPart.Velocity.Y / 20
	self.Character.HumanoidRootPart.Velocity = createVector(0, 0, 0)
	self._platform.CanCollide = true
	self._platform.CFrame = self.Character.HumanoidRootPart.CFrame - createVector(0, 3, 0)
	self._beam0.Width1 = self._beam0.Width0 * 0.25
	self._beam1.Width1 = self._beam1.Width0 * 0.25
	self._start_time = tick()
	table.insert(self._active_connections, UserInputService.JumpRequest:Connect(function()
		self:JumpOff()
	end))
	table.insert(self._active_connections, self.Character.Humanoid.StateChanged:Connect(function(_, p)
		if p == Enum.HumanoidStateType.Climbing then
			self:Disable()
		end
	end))
	table.insert(self._active_connections, self.Character.Humanoid.Died:Connect(function()
		self:Disable()
	end))
	table.insert(self._active_connections, self.Character.AncestryChanged:Connect(function()
		if not self.Character:IsDescendantOf(workspace) then
			self:Disable()
		end
	end))
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = { self._platform }
	raycastParams.CollisionGroup = "Players"
	raycastParams.RespectCanCollide = true
	raycastParams.IgnoreWater = true
	RunService:BindToRenderStep("Tightrope - " .. self._id, Enum.RenderPriority.Camera.Value - 1, function(_)
		local _GetC0 = self:_GetC0()
		local _GetC1 = self:_GetC1()
		local magnitude = ((_GetC0.Position - _GetC1.Position) * createVector(1, 0, 1)).Magnitude
		local v = self._spring.Value - 2
		local cFrame = self.Character.HumanoidRootPart.CFrame
		local v2 = ((cFrame.Position - _GetC0.Position) * createVector(1, 0, 1)).Magnitude / magnitude
		local lerped = _GetC0.Position:Lerp(_GetC1.Position, v2)
		local v3 = 0.25 / magnitude
		local v4 = CFrame.new(lerped) * self.Part.CFrame.Rotation + Vector3.new(0, v, 0)
		local lerped2 = self._platform.CFrame:Lerp(v4, 0.1)

		if v2 < v3 or 1 - v3 < v2 then
			self:Disable()
			return
		end

		local cFrame2 = CFrame.new(cFrame.Position:Lerp(lerped, (math.min(1, 2 * (tick() - self._start_time)))) * createVector(
			1,
			0,
			1
		)) * CFrame.new(0, lerped2.Y + 3, 0) * cFrame.Rotation

		if not cFrame2.Position:FuzzyEq(cFrame.Position) then
			local raycastResult = workspace:Raycast(cFrame.Position, cFrame2.Position - cFrame.Position, raycastParams)

			if raycastResult then
				if math.abs(cFrame2.Y - raycastResult.Position.Y) > 0.01 then
					self:Disable()
					return
				else
					cFrame2 = CFrame.new(raycastResult.Position) * cFrame2.Rotation
				end
			end

			local raycastResult2 = workspace:Raycast(
				cFrame.Position,
				(cFrame2.Position - cFrame.Position).Unit * ((cFrame2.Position - cFrame.Position).Magnitude + 1),
				raycastParams
			)
			local vector2 = not raycastResult2 and createVector(0, 0, 0) or self.Character.HumanoidRootPart.Position - raycastResult2.Position
			cFrame2 += vector2:FuzzyEq(createVector(0, 0, 0)) and createVector(0, 0, 0) or vector2.Unit * math.min(
				vector2.Magnitude,
				1
			)
		end

		if (cFrame2.Position - cFrame.Position).Magnitude > 32 then
			self:Disable()
			return
		end

		self.Character.HumanoidRootPart.CFrame = cFrame2
		self._platform.CFrame = CFrame.new(lerped.X, lerped2.Y, lerped.Z) * self.Part.CFrame.Rotation
		self:_UpdateSpearCFrame()
	end)
	self:_UpdateSpearCFrame()
end

function Tightrope:Disable()
	if not self.Active then
		return
	end

	self.Active = false
	self.Character = nil
	self._platform.CFrame = self.Part.CFrame
	self._platform.CanCollide = false
	self._beam0.Width1 = self._beam0.Width0
	self._beam1.Width1 = self._beam1.Width0

	for _, _active_connection in pairs(self._active_connections) do
		_active_connection:Disconnect()
	end

	self._active_connections = {}
	RunService:UnbindFromRenderStep("Tightrope - " .. self._id)
	self:_UpdateSpearCFrame()
end

function Tightrope:Destroy()
	self._destroyed = true

	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self:Disable()
	self._platform:Destroy()

	for _, _visual in pairs(self._visuals) do
		_visual:Destroy()
	end

	self._visuals = {}
end

function Tightrope:_GetC0()
	return self.Part.CFrame * CFrame.new(0, -self.Part.Size.Y / 2, 0)
end

function Tightrope:_GetC1()
	return self.Part.CFrame * CFrame.new(0, self.Part.Size.Y / 2, 0)
end

function Tightrope:_GetPositionAlongTightrope(p)
	local _GetC0 = self:_GetC0()
	local position = _GetC0.Position
	local v = self:_GetC1().Position - position
	local closestPoint = Ray.new(_GetC0.Position, v.Unit):ClosestPoint(p)
	return position + v.Unit * math.min(v.Magnitude, (closestPoint - position).Magnitude)
end

function Tightrope:_Touched(p)
	local assemblyRootPart = p.AssemblyRootPart or p

	if self.Active or self._touched_cooldowns[assemblyRootPart] or tick() < self._cooldown then
		return
	end

	self._touched_cooldowns[assemblyRootPart] = true
	task.delay(0.25, function()
		self._touched_cooldowns[assemblyRootPart] = nil
	end)

	if Players:GetPlayerFromCharacter(assemblyRootPart.Parent) ~= Players.LocalPlayer or not assemblyRootPart.Parent:FindFirstChild("Humanoid") or assemblyRootPart.Parent.Humanoid.Health <= 0 or assemblyRootPart.Parent.Humanoid:GetState() == Enum.HumanoidStateType.Climbing or self.TightropeController:GetActiveTightrope() then
		return
	end

	local _GetPositionAlongTightrope = self:_GetPositionAlongTightrope(assemblyRootPart.Position)
	local raycastWhitelist = GameplayUtility:GetRaycastWhitelist(assemblyRootPart.Parent:GetAttribute("EnvironmentID"))
	local raycastResult = Utility:Raycast(
		assemblyRootPart.Position,
		_GetPositionAlongTightrope,
		(_GetPositionAlongTightrope - assemblyRootPart.Position).Magnitude,
		raycastWhitelist,
		Enum.RaycastFilterType.Include
	)

	if not raycastResult.Instance or raycastResult.Instance == self.Part or raycastResult.Instance == self._platform then
		self:Enable()
	end
end

function Tightrope:_UpdateSpearCFrame()
	if not self._spear_model then
		return
	end

	local position = (self.Part.CFrame * CFrame.new(0, self.Part.Size.Y / 2, 0)).Position
	local position2

	if position:FuzzyEq(self._platform.Position) then
		position2 = self.Part.Position
	else
		position2 = self._platform.Position
	end

	local v

	if self._spear_spring then
		v = self._spear_spring.Position:ToCFrame()
	else
		v = CFrame.identity
	end

	self._spear_model:PivotTo(CFrame.new(position, position2) * CFrame.Angles(1.5707963267948966, 0, 0) * self._spear_spin * v)
end

function Tightrope:_SetupSpear()
	if not self._is_spear then
		return
	end

	self._spear_model = (spearTightropes:FindFirstChild(self._viewmodel_name) or spearTightropes.Spear):Clone()

	for _, part in pairs(self._spear_model:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Anchored = true
	end

	self._spear_model.Parent = self.Part
	local wrap = FighterController:GetWrap(self._object_id)

	if wrap then
		WrapController:ApplyWrap(WrapController:RecordOriginalWrapProperties(self._spear_model), wrap, true)
	end

	if self._viewmodel_name == "Plunger" then
		Utility:CreateSound("rbxassetid://78976757664560", 1, 0.9 + 0.2 * math.random(), self.Part, true, 5)
		Utility:CreateSound("rbxassetid://104596277305324", 1, 0.9 + 0.2 * math.random(), self.Part, true, 5)
		Utility:CreateSound("rbxassetid://71181338073339", 1, 0.9 + 0.2 * math.random(), self.Part, true, 5)
	elseif self._viewmodel_name == "Thunderpike" then
		Utility:CreateSound("rbxassetid://78976757664560", 1, 0.9 + 0.2 * math.random(), self.Part, true, 5)
		Utility:CreateSound("rbxassetid://86096630213185", 1, 0.9 + 0.2 * math.random(), self.Part, true, 5)
		Utility:CreateSound("rbxassetid://71162611852857", 1, 0.9 + 0.2 * math.random(), self.Part, true, 5)
	elseif self._viewmodel_name == "Fork" then
		Utility:CreateSound("rbxassetid://78976757664560", 1, 0.9 + 0.2 * math.random(), self.Part, true, 5)
		Utility:CreateSound("rbxassetid://140166764131349", 1, 0.9 + 0.2 * math.random(), self.Part, true, 5)
		Utility:CreateSound("rbxassetid://136877803636502", 1, 0.9 + 0.2 * math.random(), self.Part, true, 5)
	else
		Utility:CreateSound("rbxassetid://78976757664560", 1, 0.9 + 0.2 * math.random(), self.Part, true, 5)
		Utility:CreateSound("rbxassetid://86096630213185", 1, 0.9 + 0.2 * math.random(), self.Part, true, 5)
	end

	if not (self.Part.AssemblyRootPart or self.Part).Anchored then
		table.insert(self._connections, RunService.RenderStepped:Connect(function()
			if not self.Active then
				self._platform.CFrame = self.Part.CFrame
			end

			self:_UpdateSpearCFrame()
		end))
	end

	self._spear_spin = CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0)
	self._spear_spring = QuaternionSpring.new(Quaternion.identity, 0.5, 20)
	self._spear_spring.Position = Quaternion.fromCFrame(CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0) * CFrame.Angles(
		(0.25 + 0.75 * math.random()) * 0.4363323129985824,
		0,
		0
	))
	task.spawn(function()
		local now = tick()

		while tick() < now + 5 do
			self:_UpdateSpearCFrame()
			RunService.RenderStepped:Wait()

			if self._destroyed then
				return
			end
		end

		self._spear_spring = nil
		self:_UpdateSpearCFrame()
	end)
end

function Tightrope:_Setup()
	self.Part.Transparency = 1
	self.Part.CanCollide = false
	self._platform.Color = Color3.fromRGB(200, 200, 200)
	self._platform.Transparency = 1
	self._platform.Anchored = true
	self._platform.CanCollide = false
	self._platform.Size = createVector(0.1, 1, 1)
	self._platform.CFrame = self.Part.CFrame
	self._platform.CollisionGroup = "CollideWithPlayersOnly"
	self._platform:AddTag("Barrier")
	self._platform.Parent = self.Part
	local attachment = Instance.new("Attachment")
	attachment.Parent = self.Part
	attachment.WorldPosition = self:_GetC0().Position
	table.insert(self._visuals, attachment)
	local attachment2 = Instance.new("Attachment")
	attachment2.Parent = self.Part
	attachment2.WorldPosition = self:_GetC1().Position
	table.insert(self._visuals, attachment2)
	local attachment3 = Instance.new("Attachment")
	attachment3.Parent = self._platform
	table.insert(self._visuals, attachment3)
	local beam = Instance.new("Beam")
	beam.Width0 = self.Part.Size.X
	beam.Width1 = self.Part.Size.X
	beam.FaceCamera = true
	beam.Transparency = NumberSequence.new(0)
	beam.Color = ColorSequence.new(self.Part.Color)
	beam.LightInfluence = 1
	beam.Attachment0 = attachment
	beam.Attachment1 = attachment3
	beam.Enabled = not self._is_spear
	beam.Parent = self._platform
	table.insert(self._visuals, beam)
	local clone = beam:Clone()
	clone.Attachment0 = attachment2
	clone.Parent = self._platform
	table.insert(self._visuals, clone)
	self._beam0 = beam
	self._beam1 = clone
end

function Tightrope:_Init()
	table.insert(self._connections, self.Part.Destroying:Connect(function()
		self:Destroy()
	end))
	table.insert(self._connections, self.Part.Touched:Connect(function(otherPart)
		self:_Touched(otherPart)
	end))
	self:_Setup()
	self:_SetupSpear()
end

return Tightrope
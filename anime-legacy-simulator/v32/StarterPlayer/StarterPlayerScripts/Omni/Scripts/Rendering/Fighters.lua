local createVector = vector.create
local module = require("@game/ReplicatedStorage/Omni")
local v = { 2, 4, 8 }
local v2 = {
	MapName = true,
	Gamemode = true,
	SessionID = true
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Omni.Libs.Fusion)
local UltimateRunner = require(script:WaitForChild("UltimateRunner"))
local Mutations = require(script.Parent:WaitForChild("Mutations"))
local Traits = require(script.Parent:WaitForChild("Traits"))
local maps = workspace:WaitForChild("Client"):WaitForChild("Maps")
local fighters = workspace:WaitForChild("Client"):WaitForChild("Fighters")
local fighters2 = workspace:WaitForChild("Server"):WaitForChild("Fighters")
local fighter = module.Assets:WaitForChild("Interface"):WaitForChild("HUD"):WaitForChild("Fighter")
local teleport = module.Assets:WaitForChild("Effects"):WaitForChild("Movement"):WaitForChild("Teleport")
local v3 = 0
local v4 = 1
local lODPhase2 = 0
local v6 = {}
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { maps }
raycastParams.RespectCanCollide = true
local v7 = {}
local v8 = {}
local v9 = {}
local v10 = {}
local v11 = {}
local v12 = {}
local v13 = {}
local object = setmetatable({}, {
	__mode = "k"
})
local Fighters = {}

local function WaitForObject(instance, childName: string, p: number)
	local child = instance:FindFirstChild(childName)

	if child ~= nil then
		return child
	end

	local lastTime = tick()

	while not (p <= tick() - lastTime) do
		local child2 = instance:FindFirstChild(childName)

		if child2 ~= nil then
			return child2
		end

		task.wait()
	end

	return nil
end

local function WaitForAttribute(instance, attributeName: string, p: number)
	local attribute = instance:GetAttribute(attributeName)

	if attribute ~= nil then
		return attribute
	end

	local lastTime = tick()

	while not (p <= tick() - lastTime) do
		local attribute2 = instance:GetAttribute(attributeName)

		if attribute2 ~= nil then
			return attribute2
		end

		task.wait()
	end

	return nil
end

local function ShouldRender(instance)
	if instance:GetAttribute("OwnerID") == module.Instance.UserId then
		return true
	end

	local data = module.Data

	if not (data and data.Maps) or data.Settings and data.Settings["Hide Other Fighters"] == true then
		return false
	end

	local gamemode = instance:GetAttribute("Gamemode")
	local sessionID = instance:GetAttribute("SessionID")
	local v14

	if typeof(data.Gamemode) == "string" and data.Gamemode ~= "" and typeof(data.GamemodeSession) == "string" then
		v14 = data.GamemodeSession ~= ""
	else
		v14 = false
	end

	if v14 then
		return sessionID == data.GamemodeSession and gamemode == data.Gamemode
	else
		local v15 = sessionID == nil or sessionID == "Global"
		local v16 = gamemode == nil or gamemode == ""
		return v15 and v16 and instance:GetAttribute("MapName") == data.Maps.Current
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsLODExempt(state)
	return state.Owner == module.Instance or state.UltimateContext ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetFloorInterval()
	local distantEntitiesQuality = module.Data.Settings["Distant Entities Quality"]
	return (math.clamp(
		math.round(15 ^ (1 - math.clamp(
			(typeof(distantEntitiesQuality) ~= "number" or distantEntitiesQuality ~= distantEntitiesQuality) and 50 or distantEntitiesQuality,
			0,
			100
		) / 100)),
		1,
		15
	))
end

local function GetUpdateInterval(p: number, flag: boolean)
	local v14 = math.clamp((p - 60) / 90, 0, 1)
	local v15 = math.round((v4 - 1) * v14 + 1)

	if flag then
		return (math.max(v15, (math.min(3, v4))))
	end

	return v15
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetNextCountdown(state)
	local lODPhase = state.LODPhase

	if not lODPhase then
		return state.UpdateInterval
	end

	state.LODPhase = nil
	return lODPhase % state.UpdateInterval + 1
end

local function GetGrounded(state, position: Vector3, mediumSize: number, now: number)
	if state.Position ~= position or now - state.CheckedAt >= 1 then
		local raycastResult = workspace:Raycast(position, createVector(0, -100, 0), raycastParams)

		if not raycastResult then
			state.Position = nil
			return position
		end

		state.Position = position
		state.GroundY = raycastResult.Position.Y
		state.CheckedAt = now
	end

	return (Vector3.new(position.X, state.GroundY + mediumSize, position.Z))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Watch(folder)
	if v13[folder] then
		return
	end

	v13[folder] = folder.AttributeChanged:Connect(function(p: string)
		if not v2[p] then
			return
		end

		task.defer(Fighters.Check, folder)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Unwatch(folder)
	local connection = v13[folder]

	if not connection then
		return
	end

	connection:Disconnect()
	v13[folder] = nil
end

function Fighters.Init()
	for _, moduleScript in script:WaitForChild("Ultimates"):GetChildren() do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local success, result = pcall(require, moduleScript)

		if success then
			v6[moduleScript.Name] = result
		else
			module:Debug((`[Fighters] Failed to load Ultimate Module '{moduleScript.Name}': {result}`))
		end
	end
end

function Fighters.Build(instance)
	local name = instance.Name
	local name2 = WaitForAttribute(instance, "Name", 5)

	if not name2 then
		return nil, "missing Name attribute"
	end

	local info = module.Shared.Fighters.List[name2]

	if not info then
		return nil, (`unknown fighter '{name2}'`)
	end

	local waitForAttribute = WaitForAttribute(instance, "OwnerID", 5)

	if not waitForAttribute then
		return nil, "missing OwnerID attribute"
	end

	local shiny = WaitForAttribute(instance, "Shiny", 5)

	if shiny == nil then
		return nil, "missing Shiny attribute"
	end

	local hit = WaitForObject(instance, "Hit", 5)

	if not hit then
		return nil, "missing Hit value"
	end

	local target = WaitForObject(instance, "Target", 5)

	if not target then
		return nil, "missing Target value"
	end

	local endPosition = WaitForObject(instance, "EndPosition", 5)

	if not endPosition then
		return nil, "missing EndPosition value"
	end

	local currentPosition = WaitForObject(instance, "CurrentPosition", 5)

	if not currentPosition then
		return nil, "missing CurrentPosition value"
	end

	local playerByUserId = module.Services.Players:GetPlayerByUserId(waitForAttribute)

	if not playerByUserId then
		return nil, (`owner {waitForAttribute} not in game`)
	end

	local character = playerByUserId.Character

	if not character then
		return nil, "owner has no character"
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return nil, "owner character has no HumanoidRootPart"
	end

	local allCharacterAnimations = module.Utils.Characters.GetAllCharacterAnimations(name2)

	if not allCharacterAnimations then
		return nil, "missing animations"
	end

	local idle = allCharacterAnimations.Idle

	if not idle then
		return nil, "missing Idle animation"
	end

	local combatIdle = allCharacterAnimations.CombatIdle

	if not combatIdle then
		return nil, "missing CombatIdle animation"
	end

	local walk = allCharacterAnimations.Walk

	if not walk then
		return nil, "missing Walk animation"
	end

	local run = allCharacterAnimations.Run

	if not run then
		return nil, "missing Run animation"
	end

	local hits = allCharacterAnimations.Hits

	if not hits then
		return nil, "missing Hits animations"
	end

	local folder, humanoid, v23, head, animator, v25 = module.Utils.Characters.Get({
		Name = name2,
		Owner = playerByUserId,
		Shiny = shiny,
		RemoveHumanoidStates = true
	})

	if folder and humanoid and v23 and head and animator and v25 then
		if not instance.Parent then
			folder:Destroy()
			return nil, "server fighter removed"
		end

		folder:PivotTo(humanoidRootPart.CFrame)
		local attachment = Instance.new("Attachment")
		attachment.Name = "RootAttachment"
		attachment.Parent = v23
		local alignPosition = Instance.new("AlignPosition")
		alignPosition.Name = "PosAligner"
		alignPosition.Attachment0 = attachment
		alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
		alignPosition.MaxForce = 1e999
		alignPosition.MaxVelocity = 1e999
		alignPosition.Responsiveness = 30
		alignPosition.Position = humanoidRootPart.CFrame.Position
		alignPosition.Parent = v23
		local alignOrientation = Instance.new("AlignOrientation")
		alignOrientation.Name = "RotAligner"
		alignOrientation.Attachment0 = attachment
		alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
		alignOrientation.MaxTorque = 1e999
		alignOrientation.MaxAngularVelocity = 1e999
		alignOrientation.Responsiveness = 30
		alignOrientation.CFrame = humanoidRootPart.CFrame
		alignOrientation.Parent = v23
		local vector3Value = Instance.new("Vector3Value")
		vector3Value.Name = "OffsetValue"
		vector3Value.Parent = instance
		folder.Parent = fighters

		for _, part in folder:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.Anchored = false
			part.CanCollide = false
			part.CollisionGroup = "Fighters"
			part.Massless = part.Name ~= "HumanoidRootPart"
		end

		local object2 = setmetatable({}, {
			__index = v7
		})
		object2.ID = name
		object2.Name = name2
		object2.Shiny = shiny
		object2.Scope = Fusion.scoped(Fusion)
		object2.Info = info
		object2.Instance = instance
		object2.Model = folder
		object2.HRP = v23
		object2.Head = head
		object2.Offset = vector3Value
		object2.Humanoid = humanoid
		object2.Animator = animator
		object2.Owner = playerByUserId
		object2.OwnerHRP = humanoidRootPart
		object2.BaseScale = folder:GetScale()
		object2.BaseMediumSize = v25
		object2.MediumSize = v25
		object2.PosAligner = alignPosition
		object2.RotAligner = alignOrientation
		object2.Far = false
		object2.UpdateInterval = 1
		object2.UpdateCountdown = 0
		object2.LODPhase = lODPhase2
		object2.EndGround = {}
		object2.CurrentGround = {}
		lODPhase2 = (lODPhase2 + 1) % 15
		object2.Animations = {}
		object2.Animations.Idle = animator:LoadAnimation(idle)
		object2.Animations.Idle.Looped = true
		object2.Animations.Idle.Priority = Enum.AnimationPriority.Action
		object2.Animations.CombatIdle = animator:LoadAnimation(combatIdle)
		object2.Animations.CombatIdle.Looped = true
		object2.Animations.CombatIdle.Priority = Enum.AnimationPriority.Action
		object2.Animations.Walk = animator:LoadAnimation(walk)
		object2.Animations.Walk.Looped = true
		object2.Animations.Walk.Priority = Enum.AnimationPriority.Action
		object2.Animations.Run = animator:LoadAnimation(run)
		object2.Animations.Run.Looped = true
		object2.Animations.Run.Priority = Enum.AnimationPriority.Action
		object2.HitAnimations = {}

		for _, animation in hits:GetChildren() do
			local track = animator:LoadAnimation(animation)
			track.Looped = false
			track.Priority = Enum.AnimationPriority.Action2
			table.insert(object2.HitAnimations, track)
		end

		object2.Connections = {}
		object2.Connections.TargetChanged = target.Changed:Connect(function()
			object2:TargetChanged()
			object2:LoadHUD()
		end)
		object2.Connections.AttributeChanged = instance.AttributeChanged:Connect(function(p: string)
			if p == "Level" then
				object2:LoadHUD()
			elseif p == "FighterSize" then
				object2:RefreshSize()
			end
		end)
		object2.Connections.HitChanged = hit.Changed:Connect(function()
			object2:Hitted()
			object2:LoadHUD()
		end)
		object2.Connections.OnUltimateChanged = hit.AttributeChanged:Connect(function(p: string)
			if p == "OnUltimate" then
				object2.OnUltimate = hit:GetAttribute("OnUltimate") == true
				object2:LoadHUD()

				if object2.OnUltimate == true then
					object2:Ultimate()
				end
			end
		end)
		object2.Connections.OwnerCharacter = playerByUserId.CharacterAdded:Connect(function(character2)
			local humanoidRootPart2 = character2:WaitForChild("HumanoidRootPart", 5)

			if not humanoidRootPart2 or object2.Destroyed or character2 ~= playerByUserId.Character then
				return
			end

			object2.OwnerHRP = humanoidRootPart2
		end)

		if info.PlayerAvatar then
			object2.Connections.AppearanceLoaded = playerByUserId:GetAttributeChangedSignal("FighterAvatarRevision"):Connect(function()
				if object2.Destroyed or not instance.Parent then
					return
				end

				local character2 = playerByUserId.Character

				if not (character2 and character2:WaitForChild("HumanoidRootPart", 5)) then
					Fighters.ScheduleRetry(instance)
					return
				end

				if object2.Destroyed or character2 ~= playerByUserId.Character then
					return
				end

				Fighters.Rebuild(name)
			end)
		end

		object2.Data = {
			Hit = hit,
			Target = target,
			EndPosition = endPosition,
			CurrentPosition = currentPosition
		}
		object2:RefreshSize()
		object2:TargetChanged()
		object2:Render()
		object2:InitializeLOD()
		object2:LoadHUD()
		return object2
	else
		if folder then
			folder:Destroy()
		end

		return nil, "character model could not be built"
	end
end

function Fighters.Register(p)
	v8[p.ID] = p
	Fighters.ClearRetry(p.ID)
	Mutations.Attach("Fighter", p)
	Traits.Attach(p)
end

local function CreateFighter(instance)
	local name = instance.Name

	if v8[name] or not ShouldRender(instance) then
		return
	end

	local v14, _ = Fighters.Build(instance)

	if not v14 then
		Fighters.ScheduleRetry(instance)
	elseif v8[name] or not (instance.Parent and ShouldRender(instance)) then
		v14:Destroy()
	else
		Fighters.Register(v14)
		return v14
	end
end

function Fighters.Create(p)
	if v12[p] then
		return
	end

	v12[p] = true
	local success, result = pcall(CreateFighter, p)
	v12[p] = nil

	if success then
		return result
	end

	module:Debug((`[Fighters] Create failed for '{p.Name}': {result}`))
end

function Fighters.Rebuild(p: string)
	local v14 = v8[p]

	if not v14 or v14.Destroyed then
		return
	end

	local instance = v14.Instance

	if not instance.Parent then
		return
	end

	local v15 = (v11[p] or 0) + 1
	v11[p] = v15
	local v16, v17 = Fighters.Build(instance)

	if v11[p] ~= v15 or v8[p] ~= v14 or not instance.Parent then
		if v16 then
			v16:Destroy()
		end
	else
		v11[p] = nil

		if v16 then
			Fighters.Destroy(p)
			Fighters.Register(v16)
		else
			module:Debug((`[Fighters] Failed to rebuild '{p}', keeping current model: {v17}`))
			Fighters.ScheduleRetry(instance)
		end
	end
end

function Fighters.ScheduleRetry(instance)
	local name = instance.Name

	if v9[name] then
		return
	end

	local v14 = (v10[name] or 0) + 1
	v10[name] = v14
	local v15 = v[v14] or 15
	v9[name] = task.delay(v15, function()
		v9[name] = nil

		if not instance.Parent then
			Fighters.ClearRetry(name)
		elseif v8[name] then
			Fighters.Rebuild(name)
		else
			Fighters.Create(instance)
		end
	end)
end

function Fighters.ClearRetry(p: string)
	local v14 = v9[p]

	if v14 then
		task.cancel(v14)
	end

	v9[p] = nil
	v10[p] = nil
end

function Fighters.Destroy(p: string)
	v11[p] = nil
	local v14 = v8[p]

	if not v14 then
		return
	end

	v14:Destroy()
	v8[p] = nil
end

function Fighters.Check(instance)
	if not instance.Parent then
		return
	end

	local name = instance.Name

	if ShouldRender(instance) then
		if not v8[name] then
			task.spawn(Fighters.Create, instance)
		end
	else
		Fighters.ClearRetry(name)
		Fighters.Destroy(name)
	end
end

function Fighters.Recheck()
	for _, folder in fighters2:GetChildren() do
		if folder:IsA("Folder") then
			Fighters.Check(folder)
		end
	end
end

local function StepFighter(object2, cframe: CFrame?, flag: boolean, flag2: boolean)
	if flag then
		object2:SetFar(false)
		object2:SetUpdateInterval(1)
	elseif cframe then
		object2:UpdateLOD(cframe)
	end

	if not flag2 then
		return
	end

	object2:Render()
end

local function RenderFighter(state, cFrame: CFrame?)
	if state.Destroyed then
		return
	end

	local lODExempt = IsLODExempt(state) -- equivalent call inferred; original call site unknown
	state.UpdateCountdown -= 1
	local v15 = lODExempt or state.UpdateCountdown <= 0

	if not v15 and state.UpdateCountdown % 3 ~= 0 then
		return
	end

	local success, result = pcall(StepFighter, state, cFrame, lODExempt, v15)

	if v15 then
		local updateCountdown = GetNextCountdown(state) -- equivalent call inferred; original call site unknown
		state.UpdateCountdown = updateCountdown
	else
		state.UpdateCountdown = math.min(state.UpdateCountdown, state.UpdateInterval)
	end

	if success then
		object[state] = nil
		return
	end

	if object[state] == result then
		return
	end

	object[state] = result
	module:Debug((`[Fighters] Render failed for '{state.ID}': {result}`))
end

function Fighters.RenderAll()
	v4 = GetFloorInterval()
	local currentCamera = workspace.CurrentCamera
	local cFrame = currentCamera and currentCamera.CFrame

	for _, v14 in v8 do
		RenderFighter(v14, cFrame)
	end
end

function v7:RefreshSize()
	local fighterSize = self.Instance:GetAttribute("FighterSize") or 1

	if self.Size == fighterSize then
		return
	end

	self.Size = fighterSize
	self.MediumSize = self.BaseMediumSize * fighterSize
	self.Model:ScaleTo(self.BaseScale * fighterSize)
end

function v7:LoadHUD()
	if self.Far then
		return
	end

	local level = self.Instance:GetAttribute("Level") or 1

	if not self.HUD then
		self.HUDScope = self.Scope:innerScope()
		self.HUD = fighter:Clone()
		self.HUD.Main.Title.Text = module.Shared.Fighters.GetDisplayName(self.Name, self.Owner)
		self.HUD.Main.Shiny.Visible = self.Shiny == true
		self.HUD.Main.Rarity.Text = self.Info.Rarity
		self.HUD.Main.Rarity.UIGradient:SetAttribute("Rarity", self.Info.Rarity)
		self.HUD.Parent = self.Head
		self.HUD:AddTag("AnimatedHUD")
		self.SkillBarProgress = self.HUDScope:Value(UDim2.fromScale(0, 1))
		self.SkillBarProgressSpring = self.HUDScope:Spring(self.SkillBarProgress, 12.5, 1)
		self.SkillBarColor = self.HUDScope:Value(Color3.new(1, 0, 0))
		self.SkillBarColorSpring = self.HUDScope:Spring(self.SkillBarColor, 12.5, 1)
		self.HUDScope:Hydrate(self.HUD.SkillBar.Slider)({
			Size = self.SkillBarProgressSpring,
			BackgroundColor3 = self.SkillBarColorSpring
		})
	end

	self.HUD.Main.Level.Text = `Lvl. {level}`
	self.HUD.SkillBar.Visible = self.Data.Target.Value ~= ""

	if self.Data.Target.Value ~= "" then
		local value = self.Data.Hit.Value
		local v14 = math.clamp(value / (self.Data.Hit:GetAttribute("UltHits") or value), 0, 1)
		local v15 = self.OnUltimate and 1 or v14
		self.SkillBarProgress:set(UDim2.fromScale(v15, 1))
		self.SkillBarColor:set(self.OnUltimate and Color3.new(1, 0, 0) or Color3.new(1, 1, 1))
	end
end

function v7:ReleaseHUD()
	if not self.HUD then
		return
	end

	self.HUDScope:doCleanup()
	self.HUD:Destroy()
	self.HUD = nil
	self.HUDScope = nil
	self.SkillBarProgress = nil
	self.SkillBarProgressSpring = nil
	self.SkillBarColor = nil
	self.SkillBarColorSpring = nil
end

function v7:TargetChanged()
	local value = self.Data.Target.Value

	if value == "" then
		self.Target = nil
	else
		local v14 = module.Cache:Get({ "Enemies" })

		if v14 then
			local target = v14[value]

			if target then
				self.Target = target
			else
				self.Target = nil
			end
		end
	end
end

function v7:Hitted()
	if self.Data.Hit.Value > 0 then
		local currentHit = self.CurrentHit or 1
		local v14 = #self.HitAnimations < currentHit and 1 or currentHit
		local hitAnimation = self.HitAnimations[v14]

		if hitAnimation and not self.Far then
			hitAnimation:Play()
		end

		module.Scripts.Rendering.Combat.Hit(self.Owner, self.Info.CombatSound, v14, self.HRP)
		self.CurrentHit = v14 + 1
	end
end

function v7:Ultimate()
	self:TargetChanged()
	local ultimateSource = self.Data.Hit:GetAttribute("UltimateSource") or self.Name
	local ultimateInfo = module.Shared.Fighters.List[ultimateSource]

	if not ultimateInfo or ultimateInfo.CopyStrongest then
		return
	end

	self.UltimateInfo = ultimateInfo
	local v15 = v6[ultimateInfo.MapName]
	local v16 = v15 and v15[ultimateSource]

	if not v16 then
		module:Debug((`[Fighters] {self.Name}: Ultimate aborted, no UltimateEntry for MapName '{self.Info.MapName}'`))
		return
	end

	local v17

	if self.Owner.UserId == module.Instance.UserId then
		v17 = module.Data.Settings["Show My Skills"] == true
	else
		local currentCamera = workspace.CurrentCamera

		if not currentCamera or self:GetLODDistance(currentCamera.CFrame) > 80 then
			return
		end

		v17 = module.Data.Settings["Show Other Skills"] == true
	end

	if not v17 then
		return
	end

	if type(v16) == "function" then
		v16(self, v17)
	else
		UltimateRunner(self, v16, v17)
	end
end

function v7:GetLODDistance(cframe: CFrame)
	local vector2 = self.Data.CurrentPosition.Value.Position - cframe.Position
	local v14 = vector2:Dot(cframe.LookVector) < -10
	return vector2.Magnitude, v14
end

function v7:SetFar(far: boolean)
	if self.Far == far then
		return
	end

	self.Far = far

	if far then
		self:ReleaseHUD()
	else
		self:LoadHUD()
	end
end

function v7:InitializeLOD()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera or self.Owner == module.Instance or self.UltimateContext ~= nil then
		return
	end

	self:UpdateLOD(currentCamera.CFrame)
end

function v7:SetUpdateInterval(updateInterval: number)
	if self.UpdateInterval == updateInterval then
		return
	end

	local v14 = self.UpdateInterval == 1
	self.UpdateInterval = updateInterval

	if updateInterval == 1 == v14 then
		return
	end

	local responsiveness = updateInterval == 1 and 30 or 10
	self.PosAligner.Responsiveness = responsiveness
	self.RotAligner.Responsiveness = responsiveness
end

function v7:UpdateLOD(cframe: CFrame)
	local lODDistance, v14 = self:GetLODDistance(cframe)

	if self.Far then
		self:SetFar(lODDistance >= 140)
	else
		self:SetFar(lODDistance > 150)
	end

	local v15 = math.clamp((lODDistance - 60) / 90, 0, 1)
	local v16 = math.round((v4 - 1) * v15 + 1)

	if v14 then
		v16 = math.max(v16, (math.min(3, v4)))
	end

	self:SetUpdateInterval(v16)
end

function v7:PlayAnimation(currentAnimation: string)
	local animation = self.Animations[currentAnimation]

	if currentAnimation == self.CurrentAnimation and animation and animation.IsPlaying then
		return
	end

	self.CurrentAnimation = currentAnimation

	for k, animation2 in self.Animations do
		if k == currentAnimation then
			if not animation2.IsPlaying then
				animation2:Play()
			end
		elseif animation2.IsPlaying then
			animation2:Stop()
		end
	end
end

function v7:Render()
	if self.UltimateContext and self.UltimateContext.MovementLocked then
		self.LastAlign = nil
		return
	end

	local now = os.clock()
	local value = self.Data.EndPosition.Value
	local value2 = self.Data.CurrentPosition.Value
	local grounded = GetGrounded(self.EndGround, value.Position, self.MediumSize, now)
	local grounded2 = GetGrounded(self.CurrentGround, value2.Position, self.MediumSize, now)
	local v16 = grounded - grounded2
	local magnitude = v16.Magnitude
	local vector2

	if magnitude > 1 then
		local unit = v16.Unit
		vector2 = Vector3.new(unit.X, 0, unit.Z)
	elseif self.Target then
		local unit = (self.Target.HRP.Position - grounded).Unit
		vector2 = Vector3.new(unit.X, 0, unit.Z)
	else
		vector2 = self.OwnerHRP.CFrame.LookVector
	end

	local assemblyLinearVelocity = self.OwnerHRP.AssemblyLinearVelocity
	local vector3 = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z)
	local cframe = CFrame.new(grounded2, grounded2 + vector2)
	local v17 = vector3.Magnitude > 1 and not self.Target

	if not v17 then
		if (self.HRP.Position - cframe.Position).Magnitude > 1 then
			v17 = value2 ~= value
		else
			v17 = false
		end
	end

	local v18 = cframe * CFrame.new(self.Offset.Value)

	if v18 ~= self.LastAlign then
		if not module.Utils.Validator:ValidateCFrame(cframe) then
			return
		end

		self.LastAlign = v18
		self.RotAligner.CFrame = v18
		self.PosAligner.Position = v18.Position

		if (self.HRP.Position - cframe.Position).Magnitude >= 100 then
			local clone = teleport:Clone()
			clone.Position = self.HRP.Position
			clone.Parent = workspace.Cache
			module.Utils.Particles:Emit(clone)
			module.Services.Debris:AddItem(clone, 3)
			local clone2 = teleport:Clone()
			clone2.Position = cframe.Position
			clone2.Parent = workspace.Cache
			module.Utils.Particles:Emit(clone2)
			module.Services.Debris:AddItem(clone2, 3)
			self.Model:PivotTo(cframe)
		end
	end

	local v19

	if magnitude >= 1 then
		v19 = (magnitude >= 3 or not self.Animations.Walk.IsPlaying) and "Run" or "Walk"
	else
		v19 = self.Target and "CombatIdle" or v17 and "Walk" or "Idle"
	end

	self:PlayAnimation(v19)
end

function v7:Destroy()
	if self.Destroyed then
		return
	end

	self.Destroyed = true
	object[self] = nil
	Mutations.Detach("Fighter", self)
	Traits.Detach(self)

	if self.UltimateContext then
		pcall(function()
			self.UltimateContext:CleanupAll()
		end)
		self.UltimateContext = nil
	end

	for _, connection in self.Connections do
		connection:Disconnect()
	end

	table.clear(self.Connections)

	if self.UltimateAnimation then
		self.UltimateAnimation:Stop(0)
		self.UltimateAnimation:Destroy()
	end

	self.Offset:Destroy()
	self.Scope:doCleanup()
	self.Model:Destroy()
end

fighters2.ChildRemoved:Connect(function(folder)
	if not folder:IsA("Folder") then
		return
	end

	Unwatch(folder) -- equivalent call inferred; original call site unknown
	Fighters.ClearRetry(folder.Name)
	Fighters.Destroy(folder.Name)
end)
module:OnDataChanged({ "Maps" }, Fighters.Recheck)
module:OnDataChanged({ "Gamemode" }, Fighters.Recheck)
module:OnDataChanged({ "GamemodeSession" }, Fighters.Recheck)
module:OnDataChanged({ "Settings", "Hide Other Fighters" }, Fighters.Recheck)
module.Utils.Instance:ObserveChilds(fighters2, function(folder)
	if not folder:IsA("Folder") then
		return
	end

	Watch(folder) -- equivalent call inferred; original call site unknown
	Fighters.Create(folder)
end)
module.Services.RunService.Heartbeat:Connect(function()
	local now = os.clock()

	if now - v3 < 0.03333333333333333 then
		return
	end

	v3 = now
	Fighters.RenderAll()
end)
return Fighters
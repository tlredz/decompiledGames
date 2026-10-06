local createVector = vector.create
local module = require("@game/ReplicatedStorage/Omni")
local color = Color3.new(1, 0, 0)
local v = {
	Fighter = Color3.fromRGB(255, 50, 50),
	Weapon = Color3.fromRGB(50, 150, 255),
	Critical = Color3.fromRGB(255, 220, 0)
}
local color2 = Color3.new(1, 1, 1)
local numberSequence = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0) })
local numberSequence2 = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 1) })
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Omni.Libs.Fusion)
local Mutations = require(script.Parent:WaitForChild("Mutations"))
local Damage = require(script.Parent:WaitForChild("Damage"))
local Combat = require(script.Parent:WaitForChild("Combat"))
local maps = workspace:WaitForChild("Client"):WaitForChild("Maps")
local enemies = workspace:WaitForChild("Client"):WaitForChild("Enemies")
local enemies2 = module.Assets:WaitForChild("Effects"):WaitForChild("Enemies")
local interactHighlight = enemies2:WaitForChild("InteractHighlight")
local hit = enemies2:WaitForChild("Hit")
local die = enemies2:WaitForChild("Die")
local respawn = enemies2:WaitForChild("Respawn")
local HUD = module.Assets:WaitForChild("Interface"):WaitForChild("HUD")
local enemy = HUD:WaitForChild("Enemy")
local enemyInteract = HUD:WaitForChild("EnemyInteract")
local HUD2 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Enemies"):WaitForChild("HUD")
local shield = module.Assets:WaitForChild("Models"):WaitForChild("Shield")
local enemies3 = module.Assets:WaitForChild("Animations"):WaitForChild("Enemies")
local hits = enemies3:WaitForChild("Hits")
local die2 = enemies3:WaitForChild("Die")
local respawn2 = enemies3:WaitForChild("Respawn")
local v2 = 0
local v3 = 1
local lODPhase2 = 0
local v5 = {}
local formatted = `{module.Instance.UserId}:`
local v6 = {}
local v7 = Combat.IsMobile() and 8 or 12
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { maps }
raycastParams.RespectCanCollide = true
local v8 = {}
local v9 = {}
local v10 = {}
local v11 = {}
local object = setmetatable({}, {
	__mode = "k"
})
local Enemies = {}

local function ShouldRender(instance)
	local gamemode = module.Data.Gamemode
	local gamemodeSession = module.Data.GamemodeSession
	local v12

	if typeof(gamemode) == "string" and gamemode ~= "" and typeof(gamemodeSession) == "string" then
		v12 = gamemodeSession ~= ""
	else
		v12 = false
	end

	local sessionID = instance:GetAttribute("SessionID")

	if v12 then
		return sessionID == gamemodeSession and instance:GetAttribute("Gamemode") == gamemode
	else
		if sessionID ~= nil then
			return false
		end

		local current = module.Data.Maps and module.Data.Maps.Current
		return instance:GetAttribute("MapName") == current
	end
end

local function FindEnemy(p: string)
	local v12 = v9[p]

	if v12 then
		return v12
	end

	for k in v11 do
		if k.ID == p then
			return k
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsOwnFighter(value: string)
	return string.sub(value, 1, #formatted) == formatted
end

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
	local v12 = math.clamp((p - 60) / 90, 0, 1)
	local v13 = math.round((v3 - 1) * v12 + 1)

	if flag then
		return (math.max(v13, (math.min(3, v3))))
	end

	return v13
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

local function CreateHitEffect()
	local clone = hit:Clone()
	local lifetime = 0
	local emitters = {}

	for _, emitter in clone:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		lifetime = math.max(lifetime, emitter.Lifetime.Max)
		table.insert(emitters, emitter)
	end

	clone.Parent = workspace.Cache
	local v13 = {
		Effect = clone,
		Emitters = emitters,
		Lifetime = lifetime,
		IsOwn = false,
		EmittedAt = -1e999
	}
	table.insert(v6, v13)
	return v13
end

local function GetHitEffectSlot(isOwn: boolean, now: number)
	local v12 = nil
	local v13 = nil

	for _, v14 in v6 do
		if now - v14.EmittedAt >= v14.Lifetime then
			return v14
		end

		if v14.IsOwn then
			if not v12 or v14.EmittedAt < v12.EmittedAt then
				v12 = v14
			end
		elseif not v13 or v14.EmittedAt < v13.EmittedAt then
			v13 = v14
		end
	end

	if #v6 < v7 then
		return (CreateHitEffect())
	end

	if v13 then
		return v13
	end

	if isOwn then
		return v12
	end

	return nil
end

local function EmitHitEffect(position: Vector3, isOwn: boolean)
	local now = os.clock()
	local hitEffectSlot = GetHitEffectSlot(isOwn, now)

	if not hitEffectSlot then
		return
	end

	if now - hitEffectSlot.EmittedAt < hitEffectSlot.Lifetime then
		for _, emitter in hitEffectSlot.Emitters do
			emitter:Clear()
		end
	end

	hitEffectSlot.IsOwn = isOwn
	hitEffectSlot.EmittedAt = now
	hitEffectSlot.Effect.Position = position

	for _, emitter in hitEffectSlot.Emitters do
		emitter:Emit(emitter:GetAttribute("EmitCount") or emitter.Rate)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearHitEffects()
	for _, v12 in v6 do
		v12.Effect:Destroy()
	end

	table.clear(v6)
end

local function GetSortedDrops(dropsFolder)
	local result = {}

	for _, child in dropsFolder:GetChildren() do
		local type = child:GetAttribute("Type")
		local name = child:GetAttribute("Name")
		local minimum = child:GetAttribute("Minimum")
		local maximum = child:GetAttribute("Maximum")
		local chance = child:GetAttribute("Chance")

		if not (type and name and minimum and maximum) then
			continue
		end

		if not chance then
			continue
		end

		if not module.Utils.PlayerStats.CanObtainDrop({
			Type = type,
			Name = name,
			MapName = child:GetAttribute("MapName"),
			CancelMapLimitation = child:GetAttribute("CancelMapLimitation") == true
		}, module.Data) then
			continue
		end

		local info = module.Utils.Info:Get(type, name)

		if info then
			table.insert(result, {
				ID = child.Name,
				Info = info,
				Type = type,
				Name = name,
				Minimum = minimum,
				Maximum = maximum,
				Chance = chance,
				Shiny = child:GetAttribute("Shiny") == true
			})
		end
	end

	table.sort(result, function(a, b)
		return a.Chance < b.Chance
	end)
	return result
end

local function GetDropTrack(viewport, p)
	local worldModel = viewport:FindFirstChildOfClass("WorldModel")
	local model = worldModel and worldModel:FindFirstChildOfClass("Model")
	local humanoid = model and model:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		return nil
	end

	if p and p.Animator == animator then
		return p
	end

	local track = animator:GetPlayingAnimationTracks()[1]

	if track then
		return {
			Animator = animator,
			Track = track
		}
	end

	return nil
end

local function CreateEnemy(instance)
	local ID = WaitForAttribute(instance, "EnemyID", 5)

	if not ID or v9[ID] or not ShouldRender(instance) then
		return
	end

	local name = WaitForAttribute(instance, "EnemyName", 5)

	if not name then
		return
	end

	local difficulty = WaitForAttribute(instance, "Difficulty", 5)

	if not difficulty then
		return
	end

	local waitForObject = WaitForObject(instance, "Data", 5)

	if not waitForObject then
		return
	end

	local endPosition = WaitForObject(waitForObject, "EndPosition", 5)

	if not endPosition then
		return
	end

	local currentPosition = WaitForObject(waitForObject, "CurrentPosition", 5)

	if not currentPosition then
		return
	end

	local health = WaitForObject(waitForObject, "Health", 5)

	if not health then
		return
	end

	local maxHealth = WaitForObject(waitForObject, "MaxHealth", 5)

	if not maxHealth then
		return
	end

	local dropsFolder = WaitForObject(instance, "Drops", 5)

	if not dropsFolder then
		return
	end

	local staticModel = module.Shared.Enemies.StaticModels[name]
	local v21 = not staticModel and module.Utils.Characters.GetAllCharacterAnimations(name)

	if not (staticModel or v21 and v21.Idle and v21.CombatIdle and v21.Walk and v21.Run) then
		return
	end

	local folder, humanoid, v23, head, animator, v25 = module.Utils.Enemies.GetModel(name)

	if not (folder and v23 and head and v25) then
		return
	end

	if not (staticModel or humanoid and animator) then
		folder:Destroy()
		return
	end

	if not instance.Parent or v9[ID] or not ShouldRender(instance) then
		folder:Destroy()
		return
	end

	local modelScale = staticModel and 1 or module.Shared.Enemies.DifficultySizes[difficulty] or 1

	if not staticModel then
		folder:ScaleTo(modelScale)
	end

	folder:PivotTo(instance.CFrame)
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
	alignPosition.Position = instance.CFrame.Position
	alignPosition.Parent = v23
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Name = "RotAligner"
	alignOrientation.Attachment0 = attachment
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.MaxTorque = 1e999
	alignOrientation.MaxAngularVelocity = 1e999
	alignOrientation.Responsiveness = 30
	alignOrientation.CFrame = instance.CFrame
	alignOrientation.Parent = v23
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.Name = "ClickDetector"
	clickDetector.MaxActivationDistance = 50
	clickDetector.CursorIcon = "rbxassetid://"
	clickDetector.Parent = folder
	local vector3Value = Instance.new("Vector3Value")
	vector3Value.Name = "OffsetValue"
	vector3Value.Parent = folder
	folder.Parent = enemies

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = staticModel ~= nil
		part.CanCollide = false
		part.CollisionGroup = "Enemies"
		part.Massless = part.Name ~= "HumanoidRootPart"
	end

	local object2 = setmetatable({}, {
		__index = v8
	})
	object2.ID = ID
	object2.Instance = instance
	object2.DropsFolder = dropsFolder
	object2.Name = name
	object2.ModelScale = modelScale
	object2.StaticInfo = staticModel
	object2.Immortal = instance:GetAttribute("Immortal") == true
	object2.Difficulty = difficulty
	object2.MovementSpeed = instance:GetAttribute("MovementSpeed") or 16
	object2.MovementStart = instance:GetAttribute("MovementStart")
	object2.Model = folder
	object2.HRP = v23
	object2.Head = head
	object2.Offset = vector3Value
	object2.Humanoid = humanoid
	object2.Animator = animator
	object2.Scope = Fusion.scoped(Fusion)
	object2.ClickDetector = clickDetector
	object2.MediumSize = v25 * modelScale
	object2.PosAligner = alignPosition
	object2.RotAligner = alignOrientation
	object2.Far = false
	object2.UpdateInterval = 1
	object2.UpdateCountdown = 0
	object2.LODPhase = lODPhase2
	object2.EndGround = {}
	object2.CurrentGround = {}
	object2.LastFlinch = -1e999
	object2.LastHitEffect = -1e999
	object2.LastOwnHit = -1e999
	object2.FadeTweens = {}
	lODPhase2 = (lODPhase2 + 1) % 15
	object2.Animations = {}
	object2.HitAnimations = {}

	if not staticModel then
		for _, v27 in {
			"Idle",
			"CombatIdle",
			"Walk",
			"Run"
		} do
			local track = animator:LoadAnimation(v21[v27])
			track.Looped = true
			track.Priority = Enum.AnimationPriority.Action
			object2.Animations[v27] = track
		end

		object2.DieAnimation = animator:LoadAnimation(die2)
		object2.DieAnimation.Looped = false
		object2.DieAnimation.Priority = Enum.AnimationPriority.Action3
		object2.RespawnAnimation = animator:LoadAnimation(respawn2)
		object2.RespawnAnimation.Looped = false
		object2.RespawnAnimation.Priority = Enum.AnimationPriority.Action4

		for _, animation in hits:GetChildren() do
			local track = animator:LoadAnimation(animation)
			track.Looped = false
			track.Priority = Enum.AnimationPriority.Action2
			table.insert(object2.HitAnimations, track)
		end
	end

	object2.Connections = {}
	object2.Connections.HealthChanged = health.Changed:Connect(function()
		object2:LoadHUD()
		object2:ResetHitHighlight()
	end)
	object2.Connections.MaxHealthChanged = maxHealth.Changed:Connect(function()
		object2:LoadHUD()
	end)
	object2.Connections.MouseEnter = clickDetector.MouseHoverEnter:Connect(function()
		object2.ReallyHovered = true
		object2:Hovered(true)
	end)
	object2.Connections.MouseLeave = clickDetector.MouseHoverLeave:Connect(function()
		object2.ReallyHovered = false
		object2:Hovered(false)
	end)
	object2.Connections.DropsChanged1 = dropsFolder.ChildAdded:Connect(function()
		object2:LoadHUD(true)
	end)
	object2.Connections.DropsChanged2 = dropsFolder.ChildRemoved:Connect(function()
		object2:LoadHUD(true)
	end)
	object2.Connections.AttributeChanged = instance.AttributeChanged:Connect(function(p: string)
		if p == "MovementSpeed" then
			local movementSpeed = instance:GetAttribute("MovementSpeed") or 16
			object2.MovementSpeed = movementSpeed
			object2:Render()
		elseif p == "MovementStart" then
			object2.MovementStart = instance:GetAttribute("MovementStart")
		elseif p == "Died" then
			local died = instance:GetAttribute("Died") == true
			object2:Died(died)
		elseif p == "Shielded" then
			local shielded = instance:GetAttribute("Shielded") == true
			object2:SetShielded(shielded)
		end
	end)
	object2.Connections.AncestryChanged = instance.AncestryChanged:Connect(function(_, parent)
		if not parent then
			Enemies.Destroy(ID, object2.Far)
		end
	end)
	object2.Data = {
		Health = health,
		MaxHealth = maxHealth,
		EndPosition = endPosition,
		CurrentPosition = currentPosition
	}
	object2:LoadHUD(true)
	object2:Render()
	object2:SetShielded(instance:GetAttribute("Shielded") == true)
	object2:Died(instance:GetAttribute("Died") == true, true)
	v9[ID] = object2
	Mutations.Attach("Enemy", object2)
	return object2
end

function Enemies.Create(instance)
	if v10[instance] then
		return
	end

	v10[instance] = true
	local enemy2 = CreateEnemy(instance)
	v10[instance] = nil
	return enemy2
end

function Enemies.Destroy(p: string, flag: boolean?)
	local v12 = v9[p]

	if not v12 then
		return
	end

	v9[p] = nil
	v11[v12] = true
	v12:Destroy(flag)
	v11[v12] = nil
end

function Enemies.Get(p: string)
	return v9[p]
end

function Enemies.Damaged(value: string, value2: number, p: string?, flag: boolean?, p2: number?)
	if typeof(value) ~= "string" or typeof(value2) ~= "number" then
		return
	end

	local k = v9[value]
	local v12

	if k then
		v12 = k
	else
		for k2 in v11 do
			if k2.ID ~= value then
				continue
			end

			v12 = k2
			break
		end
	end

	if not v12 or v12.Destroyed then
		return
	end

	local v13 = p2 == module.Instance.UserId

	if v13 then
		v12.LastOwnHit = os.clock()
	end

	v12:ShowDamage(value2, p, flag, v13)
	v12:PlayHit(v13)

	if v13 then
		v12:LoadHighlight()
		v12:ResetHitHighlight()
		v12:ScheduleInteractRelease()
	elseif v12.Immortal then
		v12:ResetHitHighlight()
	end
end

function Enemies.DamagedBatch(items, items2, data)
	if typeof(items) ~= "table" then
		return
	end

	local damageSources = module.Shared.Enemies.DamageSources

	for _, item in items do
		if typeof(item) == "table" then
			Enemies.Damaged(item[1], item[2], damageSources[item[3]], item[4] == true, item[5])
		end
	end

	if typeof(items2) ~= "table" or typeof(data) ~= "table" then
		return
	end

	for _, item in items2 do
		if typeof(item) == "table" then
			module.Signal:FireSelf(
				"Rendering",
				"Combat",
				"Damage",
				item[1],
				item[2],
				data.MapName,
				data.Gamemode,
				data.SessionID,
				item[3]
			)
		end
	end
end

function Enemies.RefreshDrops()
	for _, v12 in v9 do
		if v12.Destroyed or not v12.HUD then
			continue
		end

		v12:LoadHUD(true)
	end
end

function Enemies.Recheck()
	for _, part in module.Services.CollectionService:GetTagged("Enemy") do
		if not part:IsA("BasePart") then
			continue
		end

		local enemyID = part:GetAttribute("EnemyID")
		local v12

		if enemyID ~= nil then
			v12 = v9[enemyID] or nil
		end

		if ShouldRender(part) then
			if not v12 then
				task.spawn(Enemies.Create, part)
			end
		elseif v12 and enemyID then
			Enemies.Destroy(enemyID, true)
		end
	end
end

local function StepEnemy(object2, cframe: CFrame?, flag: boolean)
	if cframe then
		object2:UpdateLOD(cframe)
	end

	if not flag then
		return
	end

	object2:Render()
end

local function RenderEnemy(state, cFrame: CFrame?)
	if state.Destroyed then
		return
	end

	state.UpdateCountdown -= 1
	local v12 = state.UpdateCountdown <= 0

	if not v12 and state.UpdateCountdown % 3 ~= 0 then
		return
	end

	local success, result = pcall(StepEnemy, state, cFrame, v12)

	if v12 then
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
	module:Debug((`[Enemies] Render failed for '{state.ID}': {result}`))
end

function Enemies.RenderAll()
	v3 = GetFloorInterval()
	local currentCamera = workspace.CurrentCamera
	local cFrame = currentCamera and currentCamera.CFrame

	for _, v12 in v9 do
		RenderEnemy(v12, cFrame)
	end

	for k in v11 do
		RenderEnemy(k, cFrame)
	end
end

function v8:LoadHUD(flag: boolean?)
	if not self.HUD then
		local vector2 = Vector3.new(0, enemy.StudsOffset.Y * self.ModelScale, 0)
		local uDim = UDim2.fromScale(enemy.Size.X.Scale * self.ModelScale, enemy.Size.Y.Scale * self.ModelScale)
		self.HUD = enemy:Clone()
		self.HUD.Size = uDim
		self.HUD.StudsOffset = vector2
		self.HUD.Main.Header.EnemyName.Text = self.Name
		self.HUD.Main.Header.Difficulty.Text = self.Difficulty
		self.HUD.Main.Header.Difficulty.Visible = self.StaticInfo == nil

		if not self.StaticInfo then
			self.HUD.Main.Header.Difficulty.TextColor3 = module.Utils.Colors:GetDifficultColor(self.Difficulty)
		end

		self.HUD.Parent = module.Instance.PlayerGui.Billboards
		self.HUD.Adornee = self.Head
		self.HUD:AddTag("AnimatedHUD")
		self.HealthAmount = self.Scope:Value(0)
		self.HealthAmountSpring = self.Scope:Spring(self.HealthAmount, 15, 1)
		self.Connections.HUDEnabled = self.HUD:GetPropertyChangedSignal("Enabled"):Connect(function()
			if self.HUD.Enabled and self.HealthDirty then
				self:RenderHealth()
			end

			self:RefreshDropTracks()
		end)
		self.Scope:Observer(self.HealthAmountSpring):onBind(function()
			self:RenderHealth()
		end)
	end

	if flag == true then
		local sortedDrops = GetSortedDrops(self.DropsFolder)
		self.DropTemplates = self.DropTemplates or {}
		self.DropTracks = self.DropTracks or {}
		local v13 = {}

		for k, v14 in sortedDrops do
			if k > 6 then
				break
			end

			v13[v14.ID] = true
			local clone = self.DropTemplates[v14.ID]

			if not clone then
				clone = HUD2.Drop:Clone()
				clone.Name = v14.ID
				self.DropTemplates[v14.ID] = clone
				clone.Main.UIGradient:SetAttribute("Rarity", v14.Info.Rarity or "Common")

				if v14.Info.Icon then
					clone.Main.Icon.Visible = true
					clone.Main.Viewport.Visible = false
					clone.Main.Icon.Image = v14.Info.Icon or ""
				else
					clone.Main.Icon.Visible = false
					clone.Main.Viewport.Visible = true
					module.Utils.Camera.ViewportCharacter({
						Viewport = clone.Main.Viewport,
						Animation = module.Utils.Characters.GetCharacterAnimation(v14.Name, "Idle"),
						Character = module.Utils.Characters.Get({
							Name = v14.Name,
							Shiny = v14.Shiny,
							RemoveHumanoidStates = true
						})
					})
				end

				clone.Parent = self.HUD.Main.Drops
				clone.Visible = true

				if not v14.Info.Icon then
					self.DropTracks[v14.ID] = GetDropTrack(clone.Main.Viewport)
				end
			end

			clone.Main.Chance.Text = not (v14.Chance >= 0.1) and "???" or `{module.Utils.Number:Round(v14.Chance)}%` or "???"
			clone.Main.Amount.Text = v14.Minimum == v14.Maximum and `{module.Utils.Number:Format(v14.Maximum)}x` or `{module.Utils.Number:Format(v14.Minimum)} - {module.Utils.Number:Format(v14.Maximum)}x`
			clone.LayoutOrder = k
		end

		for k, dropTemplate in self.DropTemplates do
			if v13[k] then
				continue
			end

			self.DropTemplates[k] = nil
			self.DropTracks[k] = nil
			dropTemplate:Destroy()
		end

		local showMore = self.HUD.Main.Drops:FindFirstChild("ShowMore")

		if not showMore then
			showMore = HUD2.ShowMore:Clone()
			showMore.Name = "ShowMore"
			showMore.LayoutOrder = 6
			module.Button:Create(showMore.Main, "Small"):BindFunction("Click", function()
				module.Signal:FireSelf(
					"Interface",
					"EnemyDrops",
					"Open",
					self.Name,
					self.Data.MaxHealth.Value,
					(GetSortedDrops(self.DropsFolder))
				)
			end)
			showMore.Parent = self.HUD.Main.Drops
			showMore.Visible = true
		end

		self.HUD.Main.Drops.Visible = #sortedDrops > 0
		showMore.Main.Title.Text = #sortedDrops > 6 and "+" .. #sortedDrops - 6 or "+"
		self:RefreshDropTracks()
	end

	self.HealthAmount:set(self.Data.Health.Value)
end

function v8:RenderHealth()
	if not self.HUD.Enabled then
		self.HealthDirty = true
		return
	end

	local healthAmountSpring = self.Scope.peek(self.HealthAmountSpring)

	if not healthAmountSpring then
		return
	end

	self.HealthDirty = false
	local maxHealthTextValue = self.Data.MaxHealth.Value
	local v12 = self.Immortal and 1 or healthAmountSpring / maxHealthTextValue
	local uIGradient = self.HUD.Main.Health.Bar.Slider.UIGradient

	if v12 == 1 then
		uIGradient.Transparency = numberSequence
	elseif v12 == 0 then
		uIGradient.Transparency = numberSequence2
	else
		uIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(v12, 0),
			NumberSequenceKeypoint.new(math.min(1, v12 + 0.1), 1),
			NumberSequenceKeypoint.new(1, 1)
		})
	end

	if self.Immortal then
		self.HUD.Main.Health.Value.Text = "[∞]"
		return
	end

	if self.MaxHealthTextValue ~= maxHealthTextValue then
		self.MaxHealthTextValue = maxHealthTextValue
		self.MaxHealthText = module.Utils.Number:Format(module.Utils.Number:Round(maxHealthTextValue))
	end

	self.HUD.Main.Health.Value.Text = "[" .. module.Utils.Number:Format(module.Utils.Number:Round(healthAmountSpring)) .. "/" .. self.MaxHealthText .. "]"
end

function v8:RefreshDropTracks()
	if not self.DropTracks then
		return
	end

	local enabled = self.HUD.Enabled

	for k, dropTrack in self.DropTracks do
		local dropTemplate = self.DropTemplates[k]
		local v12 = dropTemplate and GetDropTrack(dropTemplate.Main.Viewport, dropTrack)
		self.DropTracks[k] = v12

		if not v12 then
			continue
		end

		local track = v12.Track

		if enabled and not track.IsPlaying then
			track:Play()
		elseif not enabled and track.IsPlaying then
			track:Stop()
		end
	end
end

function v8:ShowDamage(p2: number, value: string?, flag: boolean?, flag2: boolean)
	if self.Destroyed or not self.HRP then
		return
	end

	local v12

	if flag then
		v12 = v.Critical
	else
		v12 = v[value or "Fighter"] or v.Fighter
	end

	Damage.PopUp(self.HRP.Position, -p2, v12, flag2)
end

function v8:PlayHit(isOwn: boolean)
	if self.Destroyed or not self.HRP then
		return
	end

	local now = os.clock()

	if not self.Far and now - self.LastFlinch >= 0.1 then
		self.LastFlinch = now
		local v12

		if #self.HitAnimations > 0 then
			v12 = self.HitAnimations[math.random(1, #self.HitAnimations)]
		else
			v12 = false
		end

		if v12 then
			v12:Play()
		end
	end

	if module.Data.Settings["Low Mode"] then
		return
	end

	local position = self.HRP.Position

	if not isOwn then
		if now - self.LastHitEffect < 0.1 or not Combat.IsNear(position) then
			return
		end
	end

	self.LastHitEffect = now
	EmitHitEffect(position, isOwn)
end

function v8:ResetHitHighlight()
	if self.InteractHighlightHitProgressSpring then
		self.InteractHighlightHitProgressSpring:setPosition(0)
	end

	if self.InteractHighlightTransparencySpring then
		self.InteractHighlightTransparencySpring:setPosition(0)
	end
end

function v8:IsEffectVisible()
	if os.clock() - self.LastOwnHit <= 3 then
		return true
	end

	for k in module.Utils.Enemies.GetFightersOnTarget(self.ID) do
		if IsOwnFighter(k) then
			return true
		end
	end

	return Combat.IsNear(self.HRP.Position)
end

function v8:ClearDie(flag: boolean?)
	if self.DieTween then
		self.DieTween:Cancel()
		self.DieTween = nil
	end

	if self.DieTask then
		task.cancel(self.DieTask)
		self.DieTask = nil
	end

	if not self.DieEffect then
		return
	end

	if flag then
		module.Utils.Particles:DisableAll(self.DieEffect)
		module.Services.Debris:AddItem(self.DieEffect, 3)
	else
		self.DieEffect:Destroy()
	end

	self.DieEffect = nil
end

function v8:Fade(flag: boolean, duration: number)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for _, fadeTween in self.FadeTweens do
		fadeTween:Cancel()
	end

	table.clear(self.FadeTweens)

	for _, descendant in self.Model:GetDescendants() do
		if not (descendant:IsA("BasePart") or descendant:IsA("Decal")) then
			continue
		end

		local originalTransparency = descendant:GetAttribute("OriginalTransparency")

		if originalTransparency == nil then
			originalTransparency = descendant.Transparency
			descendant:SetAttribute("OriginalTransparency", originalTransparency)
		end

		local transparency = flag and originalTransparency or 1

		if duration <= 0 then
			descendant.Transparency = transparency
		else
			local v13 = module.Services.TweenService:Create(descendant, tweenInfo, {
				Transparency = transparency
			})
			v13:Play()
			table.insert(self.FadeTweens, v13)
		end
	end
end

function v8:Died(flag: boolean, flag2: boolean?)
	if self.Destroyed then
		return
	end

	if self.StaticInfo then
		if self.StaticDied == flag then
			return
		end

		self.StaticDied = flag
		self.HUD:SetAttribute("Enabled", not flag and nil)
		self.ClickDetector.MaxActivationDistance = flag and 0 or 50

		if self.Interact and flag then
			self.Interact.Enabled = false
			self.InteractSize:set(0)
			self.InteractSizeSpring:setPosition(0)
		end

		if self.InteractHighlight and flag then
			self.InteractHighlight.Enabled = false
			self.InteractHighlightTransparency:set(1)
			self.InteractHighlightTransparencySpring:setPosition(1)
		end

		local v14 = flag and not flag2 and self:IsEffectVisible()
		local v15 = not v14 and 0 or self.StaticInfo.DeathDuration or 0
		self:Fade(not flag, v15)

		if v14 and not module.Data.Settings["Low Mode"] then
			local clone = die:Clone()
			clone.Motor6D:Destroy()
			local v16 = 0

			for _, descendant in clone:GetDescendants() do
				if descendant:IsA("BasePart") then
					descendant.Anchored = true
					descendant.CanCollide = false
					descendant.CanTouch = false
					descendant.CanQuery = false
				elseif descendant:IsA("ParticleEmitter") then
					v16 = math.max(v16, descendant.Lifetime.Max)
				end
			end

			clone:PivotTo(self.HRP.CFrame)
			clone.Parent = workspace.Cache
			module.Utils.Particles:Emit(clone)
			module.Services.Debris:AddItem(clone, v15 + v16 + 1)
			task.delay(v15, function()
				if clone.Parent then
					module.Utils.Particles:DisableAll(clone)
				end
			end)
		end
	else
		if self.CurrentDied == flag then
			return
		end

		self.CurrentDied = flag

		if flag2 then
			self.Offset.Value = not flag and createVector(0, 0, 0) or Vector3.new(0, 10 + self.MediumSize, 0) or createVector(
				0,
				0,
				0
			)
			self.HUD:SetAttribute("Enabled", not flag and nil)
			self:Fade(not flag, 0)
		else
			local isEffectVisible = self:IsEffectVisible()
			local v12 = isEffectVisible and not module.Data.Settings["Low Mode"]

			if flag then
				local length = self.DieAnimation.Length
				self.DieTween = module.Services.TweenService:Create(
					self.Offset,
					TweenInfo.new(length, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Value = Vector3.new(0, 10 + self.MediumSize, 0)
					}
				)
				self.DieTween:Play()
				self:Fade(false, not isEffectVisible and 0 or length)

				if v12 then
					self.DieEffect = die:Clone()
					self.DieEffect.Motor6D.Part0 = self.HRP
					self.DieEffect.Parent = workspace.Cache
					module.Utils.Particles:Emit(self.DieEffect)
					self.DieTask = task.delay(length, function()
						if not self.DieEffect then
							return
						end

						module.Utils.Particles:DisableAll(self.DieEffect)
					end)
				end

				self.DieAnimation:Play()
				self.HUD:SetAttribute("Enabled", false)
			else
				local length = self.RespawnAnimation.Length
				self:ClearDie()

				if v12 then
					local clone = respawn.Star:Clone()
					clone.Position = self.HRP.Position
					clone.Parent = workspace.Cache
					local clone2 = respawn.Land:Clone()
					clone2.Position = self.HRP.Position - self.Offset.Value - Vector3.new(0, self.MediumSize, 0)
					clone2.Parent = workspace.Cache
					module.Utils.Particles:Emit(clone)
					module.Services.Debris:AddItem(clone, 3)
					module.Utils.Particles:Emit(clone2)
					module.Services.Debris:AddItem(clone2, 3)
				end

				self.RespawnAnimation:Play()
				self.HUD:SetAttribute("Enabled", nil)
				self.Offset.Value = createVector(0, 0, 0)
				self.UpdateCountdown = 0
				self:Fade(true, not isEffectVisible and 0 or length)
			end
		end
	end
end

function v8:GetInteractScope()
	if not self.InteractScope then
		self.InteractScope = self.Scope:innerScope()
	end

	return self.InteractScope
end

function v8:LoadInteract()
	if self.Interact then
		return
	end

	local interactScope = self:GetInteractScope()
	self.Interact = enemyInteract:Clone()
	module.Button:Create(self.Interact.Attack, "Stuck"):BindFunction("Click", function()
		self:Clicked()
	end)
	module.Button:Create(self.Interact.Retreat, "Stuck"):BindFunction("Click", function()
		self:Clicked()
	end)
	self.Interact.Parent = module.Instance.PlayerGui.Billboards
	self.Interact.Adornee = self.HRP
	self.InteractSize = interactScope:Value(0)
	self.InteractSizeSpring = interactScope:Spring(self.InteractSize, 12.5, 1)
	interactScope:Observer(self.InteractSizeSpring):onBind(function()
		local interactSizeSpring = interactScope.peek(self.InteractSizeSpring)

		if not interactSizeSpring then
			return
		end

		self.Interact.Attack.Size = UDim2.fromScale(interactSizeSpring, 1)
		self.Interact.Retreat.Size = UDim2.fromScale(interactSizeSpring, 1)
		self.Interact.Enabled = interactSizeSpring > 0
	end)
end

function v8:LoadHighlight()
	if self.InteractHighlight then
		return
	end

	local interactScope = self:GetInteractScope()
	self.InteractHighlight = interactHighlight:Clone()
	self.InteractHighlight.Parent = self.Model
	self.InteractHighlightHitProgress = interactScope:Value(1)
	self.InteractHighlightHitProgressSpring = interactScope:Spring(self.InteractHighlightHitProgress, 5, 1)
	self.InteractHighlightHitProgressSpring:setPosition(1)
	self.InteractHighlightTransparency = interactScope:Value(1)
	self.InteractHighlightTransparencySpring = interactScope:Spring(self.InteractHighlightTransparency, 5, 1)
	interactScope:Observer(self.InteractHighlightHitProgressSpring):onBind(function()
		local interactHighlightHitProgressSpring = interactScope.peek(self.InteractHighlightHitProgressSpring)

		if not interactHighlightHitProgressSpring then
			return
		end

		self.InteractHighlight.FillColor = color:Lerp(color2, interactHighlightHitProgressSpring)
		self.InteractHighlight.OutlineColor = color:Lerp(color2, interactHighlightHitProgressSpring)
	end)
	interactScope:Observer(self.InteractHighlightTransparencySpring):onBind(function()
		local interactHighlightTransparencySpring = interactScope.peek(self.InteractHighlightTransparencySpring)

		if not interactHighlightTransparencySpring then
			return
		end

		self.InteractHighlight.OutlineTransparency = interactHighlightTransparencySpring
		self.InteractHighlight.FillTransparency = 0.75 + 0.25 * interactHighlightTransparencySpring
		self.InteractHighlight.Enabled = interactHighlightTransparencySpring < 1
	end)
end

function v8:ScheduleInteractRelease()
	self.InteractReleaseAt = os.clock() + 5

	if self.InteractReleaseTask then
		return
	end

	self.InteractReleaseTask = task.delay(5, function()
		local v12 = self.InteractReleaseAt - os.clock()

		while v12 > 0 do
			task.wait(v12)
			v12 = self.InteractReleaseAt - os.clock()
		end

		self.InteractReleaseTask = nil

		if self.IsHovered then
			return
		end

		self:ReleaseInteract()
	end)
end

function v8:ReleaseInteract()
	if self.InteractReleaseTask then
		task.cancel(self.InteractReleaseTask)
		self.InteractReleaseTask = nil
	end

	if self.InteractScope then
		self.InteractScope:doCleanup()
		self.InteractScope = nil
	end

	if self.Interact then
		self.Interact:Destroy()
		self.Interact = nil
	end

	if self.InteractHighlight then
		self.InteractHighlight:Destroy()
		self.InteractHighlight = nil
	end

	self.InteractSize = nil
	self.InteractSizeSpring = nil
	self.InteractHighlightHitProgress = nil
	self.InteractHighlightHitProgressSpring = nil
	self.InteractHighlightTransparency = nil
	self.InteractHighlightTransparencySpring = nil
end

function v8:Hovered(flag: boolean?)
	local availableFightersForTarget = module.Utils.PlayerStats.GetAvailableFightersForTarget(
		self.ID,
		module.Data,
		module.Instance
	)
	local v12

	if next(module.Data.Fighters.Equipped) and self.Instance:GetAttribute("Died") ~= true then
		v12 = not next(availableFightersForTarget) or flag
	else
		v12 = false
	end

	if v12 == nil then
		v12 = self.ReallyHovered == true
	end

	self.IsHovered = v12 == true
	v5[self.ID] = v12 == true or nil

	if self.IsHovered then
		self:LoadInteract()
		self:LoadHighlight()
	elseif self.Interact or self.InteractHighlight then
		self:ScheduleInteractRelease()
	end

	if self.Interact then
		if next(availableFightersForTarget) then
			self.Interact.Attack.Visible = true
			self.Interact.Retreat.Visible = false
		else
			self.Interact.Retreat.Visible = true
			self.Interact.Attack.Visible = false
		end

		self.InteractSize:set(v12 and 1 or 0)
	end

	if self.InteractHighlight then
		self.InteractHighlightTransparency:set(v12 and 0 or 1)
	end
end

function v8:Clicked()
	if not next(module.Data.Fighters.Equipped) then
		return
	end

	local availableFightersForTarget = module.Utils.PlayerStats.GetAvailableFightersForTarget(
		self.ID,
		module.Data,
		module.Instance
	)

	if next(availableFightersForTarget) then
		if module.Data.Settings["Send All Fighters"] then
			module.Signal:Invoke("General", "Combat", "FighterAttack", self.ID, availableFightersForTarget)
		else
			module.Signal:Invoke("General", "Combat", "FighterAttack", self.ID, { availableFightersForTarget[1] })
		end
	else
		module.Signal:Invoke("General", "Combat", "FighterRetreat")
	end

	self:Hovered()
end

function v8:SetShielded(flag: boolean)
	if flag then
		if self.Shield then
			return
		end

		local clone = shield:Clone()
		clone:ScaleTo(self.ModelScale)
		clone:PivotTo(CFrame.new(self.HRP.Position))

		for _, part in clone:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
		end

		clone.Parent = self.Model
		self.Shield = clone
		self.ShieldPosition = self.HRP.Position
	else
		if not self.Shield then
			return
		end

		self.Shield:Destroy()
		self.Shield = nil
		self.ShieldPosition = nil
	end
end

function v8:GetPosition()
	return module.Utils.Enemies.GetMovementCFrame(
		self.Data.CurrentPosition.Value,
		self.Data.EndPosition.Value,
		self.MovementStart,
		self.MovementSpeed
	)
end

function v8:GetLODDistance(cframe: CFrame)
	local vector2 = self:GetPosition().Position - cframe.Position
	local v12 = vector2:Dot(cframe.LookVector) < -10
	return vector2.Magnitude, v12
end

function v8:SetUpdateInterval(updateInterval: number)
	if self.UpdateInterval == updateInterval then
		return
	end

	local v12 = self.UpdateInterval == 1
	self.UpdateInterval = updateInterval

	if updateInterval == 1 == v12 then
		return
	end

	local responsiveness = updateInterval == 1 and 30 or 10
	self.PosAligner.Responsiveness = responsiveness
	self.RotAligner.Responsiveness = responsiveness
end

function v8:UpdateLOD(cframe: CFrame)
	local lODDistance, v12 = self:GetLODDistance(cframe)

	if self.Far then
		self.Far = lODDistance >= 140
	else
		self.Far = lODDistance > 150
	end

	local v13 = math.clamp((lODDistance - 60) / 90, 0, 1)
	local v14 = math.round((v3 - 1) * v13 + 1)

	if v12 then
		v14 = math.max(v14, (math.min(3, v3)))
	end

	self:SetUpdateInterval(v14)
end

function v8:PlayAnimation(currentAnimation: string)
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

function v8:Render()
	if self.StaticInfo then
		local position = self:GetPosition()

		if not self.PreDestroyed and position ~= self.LastPivot then
			self.LastPivot = position
			self.Model:PivotTo(position)
		end
	else
		local now = os.clock()
		local value = self.Data.EndPosition.Value
		local position = self:GetPosition()
		local grounded = GetGrounded(self.EndGround, value.Position, self.MediumSize, now)
		local grounded2 = GetGrounded(self.CurrentGround, position.Position, self.MediumSize, now)
		local v14 = grounded - grounded2
		local magnitude = v14.Magnitude
		local vector2

		if magnitude > 1 then
			local unit = v14.Unit
			vector2 = Vector3.new(unit.X, 0, unit.Z)
		else
			vector2 = value.LookVector
		end

		local cframe = CFrame.new(grounded2, grounded2 + vector2)
		local v15 = (self.HRP.Position - cframe.Position).Magnitude > 1
		local v16 = cframe * CFrame.new(self.Offset.Value)

		if v16 ~= self.LastAlign then
			if not module.Utils.Validator:ValidateCFrame(cframe) then
				return
			end

			self.LastAlign = v16
			self.RotAligner.CFrame = v16
			self.PosAligner.Position = v16.Position

			if (self.HRP.Position - cframe.Position).Magnitude >= 100 then
				self.Model:PivotTo(cframe)
			end
		end

		if self.Shield then
			local position2 = self.HRP.Position

			if position2 ~= self.ShieldPosition then
				self.ShieldPosition = position2
				self.Shield:PivotTo(CFrame.new(position2))
			end
		end

		local v17

		if magnitude >= 1 or v15 then
			v17 = self.MovementSpeed > 20 and "Run" or "Walk"
		else
			v17 = module.Utils.Enemies.IsTargetted(self.ID) and "CombatIdle" or "Idle"
		end

		self:PlayAnimation(v17)
	end
end

function v8:Destroy(flag: boolean?)
	if self.PreDestroyed then
		return
	end

	self.PreDestroyed = true
	Mutations.Detach("Enemy", self)

	if not flag then
		self:Died(true)
		task.wait(self.StaticInfo and self.StaticInfo.DeathDuration or self.DieAnimation.Length)
	end

	self.Destroyed = true
	object[self] = nil

	for _, connection in self.Connections do
		connection:Disconnect()
	end

	if not v9[self.ID] then
		v5[self.ID] = nil
	end

	table.clear(self.Connections)
	self:ReleaseInteract()
	self.Scope:doCleanup()
	self:ClearDie(not flag)

	if self.Shield then
		self.Shield:Destroy()
	end

	if self.HUD then
		self.HUD:Destroy()
	end

	if self.DropTemplates then
		table.clear(self.DropTemplates)
	end

	if self.DropTracks then
		table.clear(self.DropTracks)
	end

	table.clear(self.FadeTweens)

	if self.Model then
		if flag then
			self.Model:Destroy()
		else
			module.Services.Debris:AddItem(self.Model, 3)
		end
	end
end

module.Utils.Enemies.OnEnemyTargetChange(function(p: string, _: boolean, value: string)
	if string.sub(value, 1, #formatted) ~= formatted then
		return
	end

	local v12 = v9[p]

	if not v12 then
		return
	end

	v12:Hovered()
end)
module:OnDataChanged({ "Fighters", "Equipped" }, function()
	for k in v5 do
		local v12 = v9[k]

		if v12 then
			v12:Hovered()
		end
	end
end)
module.Utils.Instance:ObserveTaggedObject("Enemy", function(part)
	if not part:IsA("BasePart") then
		return
	end

	Enemies.Create(part)
end)
module:OnDataChanged({ "Maps" }, function()
	Enemies.Recheck()
	Enemies.RefreshDrops()
end)
module:OnDataChanged({ "Gamemode" }, Enemies.Recheck)
module:OnDataChanged({ "GamemodeSession" }, Enemies.Recheck)
module:OnDataChanged({ "Settings", "Low Mode" }, function()
	if not module.Data.Settings["Low Mode"] then
		return
	end

	ClearHitEffects() -- equivalent call inferred; original call site unknown
end)
module.Services.RunService.Heartbeat:Connect(function()
	local now = os.clock()

	if now - v2 < 0.03333333333333333 then
		return
	end

	v2 = now
	Enemies.RenderAll()
end)
module.Cache:Set({ "Enemies" }, v9)
return Enemies
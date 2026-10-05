local createVector = vector.create
local StarterGui = game:GetService("StarterGui")
local InteractionController = {}
require(StarterGui.TransformationHUD.BossBar.LocalScriptBossBar.Billboard)
require(game.ReplicatedStorage.NPCManager.Types)
local Config = require(game.ReplicatedStorage.NPCManager.NPC.Config)
require(game.ReplicatedStorage.NPCManager.State)
local NPCList = require(game.ReplicatedStorage.NPCManager.NPCList)
local GUI = script.Parent:WaitForChild("GUI")
local TweenService = game:GetService("TweenService")
InteractionController.__index = InteractionController
local localPlayer = game.Players.LocalPlayer

function InteractionController:UpdateEffect()
	local NPC = self.NPC
	local _instance = NPC._modelState._instance
	local _ = NPC._modelState._rootPart
	local _currentHumanoid = NPC._modelState._currentHumanoid
	local floorPos = _instance:GetAttribute("FloorPos")
	local floorNormal = _instance:GetAttribute("FloorNormal")
	local cFrame = CFrame.new(floorPos + floorNormal * 0.1, floorPos + floorNormal) * CFrame.Angles(
		-1.5707963267948966,
		0,
		0
	)

	if self.Aura then
		for _, descendant in pairs(self.Aura:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.CFrame = cFrame * (self.Aura.CFrame:inverse() * descendant.CFrame)

				if descendant.CFrame == descendant.CFrame then
					local _ = math.abs(descendant.CFrame.Y) > 50000
				end

				if _currentHumanoid and _currentHumanoid:IsA("Humanoid") or table.find(
					Config.NPC_LIMB_PARTS,
					descendant.Name
				) == nil then
					descendant.Anchored = true
				end

				descendant.CanQuery = false
				descendant.CanCollide = false
				descendant.CanTouch = false
			else
				if descendant:IsA("ParticleEmitter") then
					descendant.LockedToPart = true

					if _instance:GetAttribute("NoAura") then
						descendant.Enabled = false
					end
				end

				if descendant.Name == "EmitOnce" then
					descendant.Enabled = false
					local v2 = descendant
					_instance:GetAttributeChangedSignal("EmitIndex"):Connect(function()
						v2.TimeScale = 1
						task.spawn(function()
							v2:Emit(1)
							task.wait()
							v2.TimeScale = 0
						end)
					end)
					_instance:SetAttribute("EmitIndex", math.random(1, 100000000))
				elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
					if _instance:GetAttribute("NoAura") then
						descendant.Enabled = false
					end

					if descendant.Enabled then
						descendant:SetAttribute("EnableMe", true)

						if _instance:GetAttribute("DistanceCulled") then
							descendant.Enabled = false
						end
					end
				end

				if descendant:IsA("ParticleEmitter") and descendant.SpreadAngle.X == 0 and descendant.SpreadAngle.Y == 0 then
					descendant.SpreadAngle = Vector2.new(0.001, 0.001)
				end
			end
		end

		self.Aura.CFrame = cFrame

		if self.Aura.CFrame ~= self.Aura.CFrame or math.abs(self.Aura.CFrame.Y) > 50000 then
			warn("[REPORT THIS ERROR PLZ]", _instance and _instance:GetFullName())
		end
	end
end

function InteractionController.updateWatching(p, flag: boolean)
	local _loadedMaid = p.NPC._loadedMaid

	if not _loadedMaid then
		return
	end

	if not flag then
		_loadedMaid.WatchLock = nil
		return
	end

	local _instance = p.NPC._modelState._instance
	local _rootPart = p.NPC._modelState._rootPart

	if not _rootPart then
		return
	end

	local _ = p.NPC._modelState._currentHumanoid
	local v = true

	function _loadedMaid.WatchLock()
		v = false
	end

	_loadedMaid.WatchTask = task.defer(function()
		local cFrame = _rootPart.CFrame

		if _rootPart:GetAttribute("__OriginalCFrame") then
			cFrame = _rootPart:GetAttribute("__OriginalCFrame")
		else
			_rootPart:SetAttribute("__OriginalCFrame", cFrame)
		end

		if math.abs(cFrame.Y) > 500000 then
			print("fixed NaN npc?")
			cFrame = _rootPart:GetAttribute("__OriginalCFrame")
			_rootPart.CFrame = cFrame
		end

		local character = localPlayer.Character
		local v2 = 0.016666666666666666

		while true do
			local humanoidRootPart = v and not _instance:GetAttribute("Destroyed") and character and character:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				break
			end

			local position = humanoidRootPart.Position
			local v3 = math.clamp(-0.2 * (position - _rootPart.Position).Magnitude + 7, 1, 5)
			local lerped = _rootPart.CFrame:Lerp(
				CFrame.lookAt(_rootPart.Position, (Vector3.new(position.X, _rootPart.Position.Y, position.Z))),
				v3 * v2
			)

			if math.abs(lerped.Y) > 500000 then
				if math.abs(_rootPart.CFrame.Y) > 500000 then
					_rootPart.CFrame = _rootPart:GetAttribute("__OriginalCFrame")
				end

				break
			else
				_rootPart.CFrame = lerped
				v2 = task.wait()
			end
		end

		local lastTime = os.clock()

		while os.clock() - lastTime < 2 and not _instance:GetAttribute("Destroyed") do
			_rootPart.CFrame = _rootPart.CFrame:Lerp(
				CFrame.new(_rootPart.Position) * (cFrame - cFrame.Position),
				v2 * 2.5
			)
			v2 = task.wait()
		end

		if not _instance:GetAttribute("Destroyed") then
			local __OriginalCFrame = _rootPart:GetAttribute("__OriginalCFrame") or cFrame
			_rootPart.CFrame = CFrame.new(_rootPart.Position) * (__OriginalCFrame - __OriginalCFrame.Position)
			_rootPart:SetAttribute("__OriginalCFrame", nil)
		end
	end)
end

function InteractionController:_update()
	local _instance = self.NPC._modelState._instance

	for _, v in pairs(self._updateMaid) do
		if v.Tween then
			v.Task:Cancel()
		end
	end

	table.clear(self._updateMaid)
	local isLocked = self.Locks.Lock:IsLocked()
	local isLocked2 = self.Locks.Busy:IsLocked()
	local v = isLocked and true or isLocked2
	local floorPos = _instance:GetAttribute("FloorPos")
	local floorNormal = _instance:GetAttribute("FloorNormal")
	local cframe = CFrame.new(floorPos + floorNormal * 0.1, floorPos + floorNormal) * CFrame.Angles(
		-1.5707963267948966,
		0,
		0
	)

	if self.Aura then
		local aura = self.Aura

		if isLocked then
			cframe = CFrame.new(0, -workspace.FallenPartsDestroyHeight + 1, 0) or cframe
		end

		aura.CFrame = cframe

		if self.Aura.CFrame ~= self.Aura.CFrame or math.abs(self.Aura.CFrame.Y) > 50000 then
			print("ok2")
		end
	end

	if isLocked then
		self._needsRefresh = true
		self.Billboards.QuestBillboard.Enabled = false
		self.Billboards.NameBillboard.Enabled = false
		Config.Highlight.Adornee = nil
		self:setOut()
	elseif self._needsRefresh then
		self._needsRefresh = false
		self._entry.Refresh = true
	else
		self._entry.Refresh = false
		self.Billboards.QuestBillboard.Enabled = true
		self.Billboards.NameBillboard.Enabled = true

		if v then
			local tween = TweenService:Create(self.Billboards.TalkBillboard.TextLabel, TweenInfo.new(0.4), {
				Position = UDim2.new(0.1, 0, 0, -40),
				TextTransparency = 1,
				TextStrokeTransparency = 1
			})
			tween:Play()
			tween.Completed:Once(function(p)
				tween = nil

				if p == Enum.PlaybackState.Completed then
					self.Billboards.TalkBillboard.Enabled = false
				end
			end)
			table.insert(self._updateMaid, {
				Task = tween,
				Tween = true
			})
		else
			self.Billboards.TalkBillboard.Enabled = true
			local tween = TweenService:Create(self.Billboards.TalkBillboard.TextLabel, TweenInfo.new(0.4), {
				Position = UDim2.new(0.1, 0, 0, 0),
				TextTransparency = 0,
				TextStrokeTransparency = 0.3
			})
			tween:Play()
			table.insert(self._updateMaid, {
				Task = tween,
				Tween = true
			})
		end
	end
end

function InteractionController:_updateQuestTypeVisuals()
	local NPC = self.NPC
	local _instance = NPC._modelState._instance
	local _rootPart = self.NPC._modelState._rootPart
	local questInfo = NPC._npcInfo.QuestInfo

	if not questInfo then
		return
	end

	if questInfo.Type == 1 then
		self.Billboards.QuestBillboard.Size = UDim2.new(5, 20, 5, 20)
	elseif questInfo.Type == 2 then
		self.Billboards.QuestBillboard.Mark.Text = "$"
	elseif questInfo.Type == 5 then
		self.Billboards.QuestBillboard.Mark.Text = "!"
	else
		self.Billboards.QuestBillboard.Mark.Text = ""
	end

	if _instance:GetAttribute("NoAura") or NPC._configAttributes.NoAura then
		self.Billboards.QuestBillboard.Title.Text = ""
		self.Billboards.QuestBillboard.Mark.Text = ""
	end

	self.Billboards.QuestBillboard.MarkImage.Visible = questInfo.Type == 1
	self.Billboards.QuestBillboard.Mark.Visible = questInfo.Type ~= 1
	self.Billboards.QuestBillboard.Title.TextColor3 = questInfo.Color
	self.Billboards.QuestBillboard.Mark.TextColor3 = questInfo.Color
	self.Billboards.QuestBillboard.Title.Text = questInfo.Text

	if self.Aura then
		self.Aura:Destroy()
	end

	if game.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("NPCAura", 1) then
		self.Aura = game.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("NPCAura"):WaitForChild(questInfo.Text):Clone()
	end

	if not _instance:GetAttribute("NoRing") and not NPC._configAttributes.NoRing and self.Aura then
		self.Aura.Parent = _rootPart
	end

	if (_rootPart.Size.Z > 1.05 or _rootPart.Size.Z < 0.95) and self.Aura then
		local ResizeModel = require(game.ReplicatedStorage.Util.ResizeModel)
		ResizeModel(self.Aura, _rootPart.Size.Z, self.Aura.Position)
	end

	self:UpdateEffect()
end

function InteractionController:ChangeType(p: number)
	if not self.NPC._npcInfo.QuestInfo or self.NPC._npcInfo.QuestInfo.Type == p then
		return
	end

	for _, v in Config.QuestInfo do
		if v.Type ~= p then
			continue
		end

		self.NPC._npcInfo.QuestInfo = v
		self._entry.Info = v
		NPCList.List[self.NPC._npcInfo._name].QuestInfo = v
		self:_updateQuestTypeVisuals()
		break
	end
end

function InteractionController:new()
	local _rootPart = self._modelState._rootPart
	assert(_rootPart)
	local _instance = self._modelState._instance
	local head = self._modelState._instance:FindFirstChild("Head")
	local _currentHumanoid = self._modelState._currentHumanoid
	local _ = self._npcInfo
	assert(self._npcInfo.QuestInfo)
	assert(_currentHumanoid)
	local class = {}
	setmetatable(class, InteractionController)
	class.NPC = self
	class.Billboards = {}
	class.Locks = {}
	class.Billboards.TalkBillboard = GUI:WaitForChild("Talk"):Clone()
	class.Billboards.TalkBillboard.Parent = _rootPart

	repeat
		task.wait(0.1)
	until _instance:GetAttribute("FloorNormal") ~= nil

	local magnitude = (_rootPart.Position - head.Position).Magnitude
	class.Billboards.QuestBillboard = GUI:WaitForChild("QuestBBG"):Clone()
	class:_updateQuestTypeVisuals()
	class.Billboards.QuestBillboard.ExtentsOffsetWorldSpace = createVector(0, 1, 0) * magnitude
	class.Billboards.QuestBillboard.Parent = _rootPart
	local floorPos = _instance:GetAttribute("FloorPos")
	local floorNormal = _instance:GetAttribute("FloorNormal")
	local v = CFrame.new(floorPos + floorNormal * 0.1, floorPos + floorNormal) * CFrame.Angles(
		-1.5707963267948966,
		0,
		0
	)
	_instance:GetAttributeChangedSignal("FloorPos"):Connect(function()
		local floorPos2 = _instance:GetAttribute("FloorPos")
		local floorNormal2 = _instance:GetAttribute("FloorNormal")
		v = CFrame.new(floorPos2 + floorNormal2 * 0.1, floorPos2 + floorNormal2) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)
		class:UpdateEffect()
	end)
	class:UpdateEffect()
	_instance.PrimaryPart = _rootPart
	class.Billboards.NameBillboard = GUI:WaitForChild("NPCName"):Clone()

	if head.Transparency < 0.99 and not self._npcInfo.IgnoreName then
		class.Billboards.NameBillboard.NPC.Text = _instance:GetAttribute("DisplayName") or _instance.Name
		class.Billboards.NameBillboard.ExtentsOffsetWorldSpace = createVector(0, 1, 0) * magnitude
		class.Billboards.NameBillboard.Parent = _rootPart
	end

	_instance:GetAttributeChangedSignal("DisplayName"):Connect(function()
		class.Billboards.NameBillboard.NPC.Text = _instance:GetAttribute("DisplayName") or _instance.Name
	end)
	class.Billboards.TalkBillboard:WaitForChild("TextLabel")

	function class.setOut()
		class.Billboards.TalkBillboard.TextLabel.TextTransparency = 1
		class.Billboards.TalkBillboard.TextLabel.Position = UDim2.new(0.1, 0, 0, -40)
		class.Billboards.TalkBillboard.TextLabel.TextStrokeTransparency = 1
	end

	class:setOut()

	function class.setIn()
		class.Billboards.TalkBillboard.TextLabel.TextTransparency = 0
		class.Billboards.TalkBillboard.TextLabel.Position = UDim2.new(0.1, 0, 0, 0)
		class.Billboards.TalkBillboard.TextLabel.TextStrokeTransparency = 0
	end

	local locks = class.Locks
	local Lock = require(game.ReplicatedStorage.Modules.Util.Lock)
	locks.Lock = Lock.new(true)
	local locks2 = class.Locks
	local Lock2 = require(game.ReplicatedStorage.Modules.Util.Lock)
	locks2.Busy = Lock2.new(true)
	class.Locks.Busy:Lock("_General")
	class._updateMaid = {}
	class._needsRefresh = false
	class._entry = {
		Refresh = false,
		Model = _instance,
		Info = self._npcInfo.QuestInfo,
		Root = head,
		Object = self,
		DelayTimestamp = 0
	}
	class.Billboards.TalkBillboard.Enabled = false
	local _configAttributes = class.NPC._configAttributes

	if _configAttributes then
		local child = _configAttributes.TalkAdornee and _instance:FindFirstChild(_configAttributes.TalkAdornee)

		if child then
			class.Billboards.TalkBillboard.Adornee = child
		end

		local child2 = _configAttributes.TypeAdornee and _instance:FindFirstChild(_configAttributes.TypeAdornee)

		if child2 then
			class.Billboards.QuestBillboard.Adornee = child2
		end

		local child3 = _configAttributes.NameAdornee and _instance:FindFirstChild(_configAttributes.NameAdornee)

		if child3 then
			class.Billboards.NameBillboard.Adornee = child3
		end
	end

	local function updateLock(object, p: string, flag: boolean)
		local isLocked = object:IsLocked()
		local v2 = false

		if flag and not isLocked then
			object:Lock(assert(p))
			class:_update()
			v2 = true
		elseif not flag and isLocked then
			object:Unlock(assert(p))
			class:_update()
			v2 = true
		end

		if class._needsRefresh and not v2 then
			class:_update()
		end
	end

	_instance.Parent = game.ReplicatedStorage.NPCs
	class._entry.GUI = {
		BG = class.Billboards.TalkBillboard,
		InteractionLock = {
			Lock = function(self, p)
				local lock = class.Locks.Lock
				local v2

				if lock:IsLocked() then
					v2 = false
				else
					lock:Lock(assert(p))
					class:_update()
					v2 = true
				end

				if class._needsRefresh and not v2 then
					class:_update()
				end
			end,
			Unlock = function(self, p)
				local lock = class.Locks.Lock
				local v2

				if lock:IsLocked() then
					lock:Unlock(assert(p))
					class:_update()
					v2 = true
				else
					v2 = false
				end

				if class._needsRefresh and not v2 then
					class:_update()
				end
			end,
			Get = function()
				return class.Locks.Lock
			end
		},
		BusyLock = {
			Lock = function(self, p)
				local busy = class.Locks.Busy
				local v2

				if busy:IsLocked() then
					v2 = false
				else
					busy:Lock(assert(p))
					class:_update()
					v2 = true
				end

				if class._needsRefresh and not v2 then
					class:_update()
				end
			end,
			Unlock = function(self, p)
				local busy = class.Locks.Busy
				local v2

				if busy:IsLocked() then
					busy:Unlock(assert(p))
					class:_update()
					v2 = true
				else
					v2 = false
				end

				if class._needsRefresh and not v2 then
					class:_update()
				end
			end,
			Get = function()
				return class.Locks.Busy
			end
		}
	}
	_instance:SetAttribute("NPCLoaded", true)
	return class
end

return InteractionController
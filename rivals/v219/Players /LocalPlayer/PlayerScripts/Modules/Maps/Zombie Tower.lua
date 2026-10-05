local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local SoundLibrary = require(ReplicatedStorage.Modules.SoundLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local ClientMap = require(Players.LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientDuel.ClientMap)
local StaticViewModel = require(Players.LocalPlayer.PlayerScripts.Modules.StaticModel.StaticViewModel)
local chickenTrojanExplosionEffect = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("ChickenTrojanExplosionEffect")
local zombieTowerLadderGui = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("ZombieTowerLadderGui")
local v = {
	"rbxassetid://98587858115094",
	"rbxassetid://72483809453170",
	"rbxassetid://129922197154277",
	"rbxassetid://113975047764762",
	"rbxassetid://121368500414901"
}
local v2 = {
	"rbxassetid://116380542394210",
	"rbxassetid://125379277208360",
	"rbxassetid://96610433230092",
	"rbxassetid://122643453923681",
	"rbxassetid://94468135009167",
	"rbxassetid://133107467882960",
	"rbxassetid://122210005572726",
	"rbxassetid://102260065267741"
}
local v3 = {
	{ 0, 24 },
	{ 9.97, 24 },
	{ 10.53, 17 },
	{ 10.87, 17 },
	{ 11.62, 30 },
	{ 11.83, 30 },
	{ 12.55, 17 },
	{ 13.03, 30 },
	{ 16.52, 30 },
	{ 17.53, 10 },
	{ 19.12, 30, true },
	{ 22.9, 50 },
	{ 23.4, 20 },
	{ 24.58, 50 },
	{ 26.02, 35 }
}
local object = setmetatable({}, ClientMap)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientMap.new(...), object)
	self._floors_folder = self.Model:WaitForChild("Floors")
	self._cutscene_hash = 0
	self._cutscene_renderstep_id = nil
	self._cutscene_boss_animation = Instance.new("Animation")
	self._cutscene_camera_animation = Instance.new("Animation")
	self._cutscene_player_animations = {}
	self._cutscene_animation_tracks = {}
	self._cutscene_cleanup = {}
	self._cutscene_threads = {}
	self._cutscene_hidden_duelers = {}
	self._preloaded_sounds = SoundLibrary:PreloadSounds(v)
	self._spectating_thread = nil
	self._flashing_red_enemies_connection = nil
	self._active_enemy_humanoids = {}
	self._ladder_guide_bbg = zombieTowerLadderGui:Clone()
	self:_Init()
	return self
end

function object:GetScoreboardDisplay()
	local _GetCurrentFloor = self:_GetCurrentFloor()
	return "Zombie Tower" .. (_GetCurrentFloor and "   •   Floor " .. _GetCurrentFloor or "")
end

function object:ReplicateFromServer(p, ...)
	if p == "ChickenTrojanEffect" then
		if not self:IsRendered() then
			return
		end

		self:_ChickenTrojan(...)
	elseif p == "GiantChombieCutscene" then
		if not self:IsRendered() then
			return
		end

		self:_PlayCutscene(...)
	else
		if p ~= "FinishGiantChombieCutscene" then
			ClientMap.ReplicateFromServer(self, ...)
			return
		end

		if not self:IsRendered() then
			return
		end

		self:_StopCutscene()
	end
end

function object:Destroy()
	for _, _preloaded_sound in pairs(self._preloaded_sounds) do
		_preloaded_sound:Destroy()
	end

	if self._spectating_thread then
		task.cancel(self._spectating_thread)
		self._spectating_thread = nil
	end

	if self._flashing_red_enemies_connection then
		self._flashing_red_enemies_connection:Disconnect()
		self._flashing_red_enemies_connection = nil
	end

	self:_StopCutscene()
	ClientMap.Destroy(self)
end

function object:_UpdateSpectating()
	if self._flashing_red_enemies_connection then
		self._flashing_red_enemies_connection:Disconnect()
		self._flashing_red_enemies_connection = nil
	end

	if self._destroyed or not self.ClientDuel:Get("IsSpectating") then
		return
	end

	self._flashing_red_enemies_connection = RunService.RenderStepped:Connect(function()
		local v4 = math.max(0, (math.sin(3.141592653589793 * tick())))

		for k, _active_enemy_humanoid in pairs(self._active_enemy_humanoids) do
			if tick() < _active_enemy_humanoid.StartFlashingRed then
				continue
			end

			if not _active_enemy_humanoid.Highlight then
				_active_enemy_humanoid.Highlight = Instance.new("Highlight")
				_active_enemy_humanoid.Highlight.FillColor = Color3.fromRGB(255, 0, 0)
				_active_enemy_humanoid.Highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
				_active_enemy_humanoid.Highlight.Adornee = k.Parent
				_active_enemy_humanoid.Highlight.Name = "FlashingRed"
				_active_enemy_humanoid.Highlight.Parent = k
			end

			_active_enemy_humanoid.Highlight.OutlineTransparency = v4 * 1 + 0
			_active_enemy_humanoid.Highlight.FillTransparency = v4 * 0.125 + 0.875
		end
	end)
end

function object:_FloorAdded(instance)
	local mobGroups = instance:WaitForChild("MobGroups")

	local function humanoid_added(instance2)
		local v4 = {
			StartFlashingRed = 0,
			Highlight = nil
		}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function reset()
			v4.StartFlashingRed = tick() + 60

			if v4.Highlight then
				v4.Highlight:Destroy()
				v4.Highlight = nil
			end
		end

		instance2.HealthChanged:Connect(reset)
		reset() -- equivalent call inferred; original call site unknown
		self._active_enemy_humanoids[instance2] = v4
		instance2.Destroying:Connect(function()
			self._active_enemy_humanoids[instance2] = nil
		end)
	end

	local function object_value_added(instance2)
		local flag = false

		local function check()
			if flag or not instance2.Value then
				return
			end

			flag = true
			task.spawn(humanoid_added, instance2.Value)
		end

		instance2:GetPropertyChangedSignal("Value"):Connect(check)

		if not flag and instance2.Value then
			flag = true
			task.spawn(humanoid_added, instance2.Value)
		end
	end

	local function mob_group_added(instance2)
		local entityHumanoidObjectValues = instance2:WaitForChild("EntityHumanoidObjectValues", 3)

		if not entityHumanoidObjectValues then
			return
		end

		entityHumanoidObjectValues.ChildAdded:Connect(object_value_added)

		for _, child in pairs(entityHumanoidObjectValues:GetChildren()) do
			task.spawn(object_value_added, child)
		end
	end

	mobGroups.ChildAdded:Connect(mob_group_added)

	for _, child in pairs(mobGroups:GetChildren()) do
		task.spawn(mob_group_added, child)
	end

	if (tonumber(instance.Name) or 0) > 2 then
		task.delay(
			1,
			self.CreateSound,
			self,
			"rbxassetid://1843115730",
			2,
			1,
			instance:WaitForChild("Important"):WaitForChild("Entrance"),
			true,
			10,
			400,
			400
		)
	end
end

function object:_GetCurrentFloor()
	for _, child in pairs(self._floors_folder:GetChildren()) do
		local volume = child:FindFirstChild("Important") and child.Important:FindFirstChild("Volume")

		if volume and Utility:IsWithinPart(volume, workspace.CurrentCamera.CFrame.Position) then
			return (tonumber(child.Name))
		end
	end
end

function object:_ChickenTrojan(position, p, value)
	local v4 = tick() + p

	while tick() < v4 do
		local clone = chickenTrojanExplosionEffect:Clone()
		clone.CFrame = CFrame.new(position) + Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 12
		clone.Parent = workspace
		BetterDebris:AddItem(clone, 5)
		Utility:ScaleParticleEmitter(clone, 0.5 + 0.75 * math.random())
		Utility:PlayParticles(clone)
		self:CreateSound(
			"rbxassetid://97884024654711",
			0.875 + 0.25 * math.random(),
			1 + 0.25 * math.random(),
			clone,
			true,
			5
		)
		wait(value or 0.2)
	end
end

function object:_LoadAnimation(p2, p3, callback)
	if not p2 then
		return
	end

	local success, result = pcall(p2.LoadAnimation, p2, p3)

	if not success then
		warn("Animation " .. p3.AnimationId .. " failed to animate, error:", result)
		return
	end

	result:Play(0)
	table.insert(self._cutscene_animation_tracks, result)
	table.insert(self._cutscene_threads, task.spawn(callback, result))
end

function object:_StopCutscene()
	self._cutscene_hash += 1

	for _, _cutscene_animation_track in pairs(self._cutscene_animation_tracks) do
		_cutscene_animation_track:Stop(0)
		_cutscene_animation_track:Destroy()
	end

	for _, v4 in pairs(self._cutscene_cleanup) do
		v4:Destroy()
	end

	for _, _cutscene_thread in pairs(self._cutscene_threads) do
		pcall(task.cancel, _cutscene_thread)
	end

	for k in pairs(self._cutscene_hidden_duelers) do
		k:SetReplicate("IsHiddenByCutscene", nil)
	end

	self._cutscene_animation_tracks = {}
	self._cutscene_cleanup = {}
	self._cutscene_threads = {}

	if self._cutscene_renderstep_id then
		RunService:UnbindFromRenderStep(self._cutscene_renderstep_id)
		self._cutscene_renderstep_id = nil
	end
end

function object:_PlayCutscene(p, instance, p2)
	self:_StopCutscene()
	local animationController = instance:WaitForChild("CameraRig"):WaitForChild("AnimationController")
	self._cutscene_renderstep_id = "GiantChombie" .. HttpService:GenerateGUID(false)
	self._cutscene_hash += 1
	local _cutscene_hash = self._cutscene_hash
	local fieldOfView = v3[1][2]
	self:_LoadAnimation(p, self._cutscene_boss_animation, function(_)
		task.delay(23.1, Utility.PlayParticles, Utility, instance:WaitForChild("SlamParticles"))
		wait(1.25)
		self:CreateSound("rbxassetid://72483809453170", 0.35, 0.675, script, true, 10)
		wait(3.2)
		self:CreateSound("rbxassetid://72483809453170", 0.6, 0.7, script, true, 10)
		wait(2.15)
		self:CreateSound("rbxassetid://72483809453170", 0.65, 0.725, script, true, 10)
		wait(1.4)
		self:CreateSound("rbxassetid://72483809453170", 0.7, 0.75, script, true, 10)
		wait(1.5)
		self:CreateSound("rbxassetid://72483809453170", 0.75, 0.775, script, true, 10)
		wait(3.45)
		self:CreateSound("rbxassetid://72483809453170", 1.5, 0.8, script, true, 10)
		wait(2.3)
		self:CreateSound("rbxassetid://72483809453170", 0.3, 0.75, script, true, 10)
		wait(2)
		self:CreateSound("rbxassetid://72483809453170", 0.25, 1, script, true, 10)
		wait(3.85)
		self:CreateSound("rbxassetid://98587858115094", 1, 1, script, true, 10)
		wait(2)
		self:CreateSound(
			"rbxassetid://72483809453170",
			1.25 + 0.25 * math.random(),
			0.9 + 0.2 * math.random(),
			script,
			true,
			10
		)
		self:CreateSound(
			"rbxassetid://129922197154277",
			1.25 + 0.25 * math.random(),
			0.9 + 0.2 * math.random(),
			script,
			true,
			10
		)
		self:CreateSound(
			"rbxassetid://113975047764762",
			1.25 + 0.25 * math.random(),
			0.9 + 0.2 * math.random(),
			script,
			true,
			10
		)
		wait(1.8)
		self:CreateSound("rbxassetid://121368500414901", 1.5, 0.875, script, true, 10)
	end)
	self:_LoadAnimation(animationController, self._cutscene_camera_animation, function(_)
		local total = 0

		for k, list in pairs(v3) do
			local v5 = v3[math.max(1, k - 1)][2]
			local _, v6, v7 = table.unpack(list)
			local v8 = list[1] - total

			if v7 then
				total += wait(v8)
				fieldOfView = v6
			else
				local lastTime = tick()

				while tick() < lastTime + v8 do
					local v9

					if v8 == 0 then
						v9 = v6
					else
						v9 = v5 + (v6 - v5) * TweenService:GetValue(
							(tick() - lastTime) / v8,
							Enum.EasingStyle.Quad,
							Enum.EasingDirection.InOut
						)
					end

					fieldOfView = v9
					total += RunService.RenderStepped:Wait()

					if self._cutscene_hash ~= _cutscene_hash then
						return
					end
				end
			end
		end
	end)
	local cFrame = animationController.Parent.HumanoidRootPart.CFrame
	local duelers = {}

	for _, dueler in pairs(self.ClientDuel.Duelers) do
		if not dueler.ClientFighter then
			continue
		end

		dueler.ClientFighter:SetReplicate("IsHiddenByCutscene", true)
		self._cutscene_hidden_duelers[dueler.ClientFighter] = true

		if not dueler.ClientFighter:IsAlive() then
			continue
		end

		table.insert(duelers, dueler)

		if #duelers >= #v2 then
			break
		end
	end

	table.sort(duelers, function(a, b)
		return a.Player.UserId < b.Player.UserId
	end)
	local characterModelForCutscenes = {}

	for k, v5 in pairs(duelers) do
		local characterModelForCutscene = v5:GetCharacterModelForCutscene()
		characterModelForCutscene.Name = "CutscenePlayer" .. k
		characterModelForCutscene:SetPrimaryPartCFrame(cFrame)
		characterModelForCutscene.Parent = animationController.Parent.Parent
		table.insert(self._cutscene_cleanup, characterModelForCutscene)
		local viewModelDetails = v5.ClientFighter.EquippedItem and v5.ClientFighter.EquippedItem:GetViewModelDetails()
		local v6 = viewModelDetails and StaticViewModel.new(viewModelDetails.ViewModelName)

		if v6 and v6:HasGripAttachment() then
			v6:DeleteAnimationContextSubModels()
			v6:SetWrap(viewModelDetails.Wrap)
			v6:SetCharm(viewModelDetails.Charm)
			v6:ScaleTo(k == 1 and 1.5 or 1.25)
			v6:InitializeGrip()
			v6:SetParent(characterModelForCutscene)
			table.insert(self._cutscene_cleanup, v6)
			characterModelForCutscenes[v6] = characterModelForCutscene
		elseif v6 then
			v6:Destroy()
		end

		local v8 = k
		local success, result = pcall(function()
			local track = characterModelForCutscene.Humanoid:LoadAnimation(self._cutscene_player_animations[v8])
			track:Play(0)
			table.insert(self._cutscene_animation_tracks, track)
		end)

		if success then
			continue
		end

		warn("Player " .. k .. " failed to animate, error:", result)
		characterModelForCutscene.Parent = nil
	end

	local cam = animationController.Parent:FindFirstChild("Cam")
	RunService:BindToRenderStep(self._cutscene_renderstep_id, CameraController:GetRenderstepPriority() + 1, function(_)
		if not (cam and self.ClientDuel:Get("IsSpectating")) then
			return
		end

		UserInputService.MouseIconEnabled = true
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		workspace.CurrentCamera.FieldOfView = fieldOfView
		workspace.CurrentCamera.CFrame = cam.CFrame

		for k, v5 in pairs(characterModelForCutscenes) do
			k:GripPivotTo(v5)
		end
	end)
	wait(p2)
	self:_StopCutscene()
end

function object:_UpdateLadderGuide() end

function object:_UpdateLightingChange()
	local v4 = false

	for _, child in pairs(self.Model.BossFight.LightingParts:GetChildren()) do
		v4 = v4 or Utility:IsWithinPart(child, workspace.CurrentCamera.CFrame.Position)
	end

	local v5 = v4 and "Zombie Tower - FinalFloor" or nil

	if v5 ~= self:Get("LightingProfileOverride") then
		self:SetReplicate("LightingProfileOverride", v5)
	end
end

function object:_SetupLightingChange()
	if self._spectating_thread then
		task.cancel(self._spectating_thread)
		self._spectating_thread = nil
	end

	if not self.ClientDuel:Get("IsSpectating") then
		return
	end

	self._spectating_thread = task.spawn(function()
		while true do
			self:_UpdateLightingChange()
			self:_UpdateLadderGuide()
			wait(1)
		end
	end)
end

function object:_Setup()
	self._cutscene_boss_animation.AnimationId = "rbxassetid://80790358034810"
	self._cutscene_camera_animation.AnimationId = "rbxassetid://85660296117721"
	local v4 = { self._cutscene_boss_animation, self._cutscene_camera_animation }

	for _, animationId in pairs(v2) do
		local animation = Instance.new("Animation")
		animation.AnimationId = animationId
		table.insert(self._cutscene_player_animations, animation)
		table.insert(v4, animation)
	end

	task.spawn(pcall, ContentProvider.PreloadAsync, ContentProvider, v4)
end

function object:_Init()
	self._floors_folder.ChildAdded:Connect(function(child)
		self:_FloorAdded(child)
	end)
	table.insert(self._connections, self.ClientDuel:GetDataChangedSignal("IsSpectating"):Connect(function()
		task.spawn(self._SetupLightingChange, self)
		self:_UpdateSpectating()
	end))

	for _, child in pairs(self._floors_folder:GetChildren()) do
		task.spawn(self._FloorAdded, self, child)
	end

	self:_Setup()
	self:_UpdateSpectating()
	task.spawn(self._SetupLightingChange, self)
	self.ClientDuel:SetReplicate("DuelMusic", "ZombieTower")
end

return object
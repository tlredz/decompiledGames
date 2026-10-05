local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GameplayUtility = require(ReplicatedStorage.Modules.GameplayUtility)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Spring = require(ReplicatedStorage.Modules.Spring)
local Signal = require(ReplicatedStorage.Modules.Signal)
local portalKeybindGui = Players.LocalPlayer.PlayerScripts.UserInterface.PortalKeybindGui
local portals = Players.LocalPlayer.PlayerScripts.Assets.Misc.Portals
local Portal = {}
Portal.__index = Portal

function Portal.new(model)
	local self = setmetatable({}, Portal)
	self.FinishedGrowing = Signal.new()
	self.Model = model
	self.Hitbox = self.Model:WaitForChild("Hitbox")
	self.PortalNum = tonumber(self.Model.Name)
	self.Visual = self:_GetPortalTemplate():Clone()
	self.BigVisual = self.Visual:WaitForChild("Big")
	self.SmallVisual = self.Visual:WaitForChild("Small")
	self.Gui = portalKeybindGui:Clone()
	self._viewmodel_name = self.Model:GetAttribute("ViewModelName")
	self._owner_user_id = self.Model:GetAttribute("OwnerUserID")
	self._owner_team_id = self.Model:GetAttribute("OwnerTeamID")
	self._original_scale = self.Visual:GetScale()
	self._grow_start = nil
	self._spawn_delay = nil
	self._finished_growing = nil
	self._is_enabled = false
	self._established = false
	self._pivot_offset_spring = Spring.new(createVector(0, 0, 0), 0.5, 25)
	self._opened_hotel_door = false
	self:_Init()
	return self
end

function Portal:IsGrown()
	return self._finished_growing
end

function Portal.GetTeleportCFrame(p)
	local cFrame = p.Hitbox.CFrame
	local v = cFrame * CFrame.new(0, 0, -4)
	local raycastWhitelist = GameplayUtility:GetRaycastWhitelist(Players.LocalPlayer:GetAttribute("EnvironmentID"))
	local raycastResult = Utility:Raycast(
		cFrame.Position,
		v.Position,
		4,
		raycastWhitelist,
		Enum.RaycastFilterType.Include
	)
	return CFrame.new(raycastResult.Position) * v.Rotation
end

function Portal:UpdateVisuals(is_enabled, p)
	task.defer(function()
		local _finished_growing = is_enabled and self._finished_growing
		local bigVisual = self.BigVisual
		local v2

		if _finished_growing then
			v2 = self.Visual
		end

		self:_SafeParent(bigVisual, v2)
		local smallVisual = self.SmallVisual
		local v4

		if not _finished_growing then
			v4 = self.Visual
		end

		self:_SafeParent(smallVisual, v4)

		if _finished_growing and not self._opened_hotel_door and self._viewmodel_name == "Hotel Bell" then
			self._opened_hotel_door = true
			task.defer(function()
				self.BigVisual.Screen.SurfaceGui.MainFrame:TweenSize(UDim2.new(0.1, 0, 1, 0), "Out", "Quint", 0.5, true)
			end)
		end

		if p or _finished_growing and not (self._is_enabled or self._established) then
			self._established = true

			if self._viewmodel_name == "Hotel Bell" then
				task.delay(
					0.1 + 0.1 * math.random(),
					Utility.CreateSound,
					Utility,
					"rbxassetid://109072275653492",
					1,
					1.25 + 0.25 * math.random(),
					self.Hitbox,
					true,
					10
				)
				Utility:CreateSound("rbxassetid://119325209237441", 0.5, 1 + 0.1 * math.random(), self.Hitbox, true, 10)
			else
				Utility:CreateSound(
					"rbxassetid://119325209237441",
					0.75,
					1 + 0.1 * math.random(),
					self.Hitbox,
					true,
					10
				)
			end
		end

		self._is_enabled = is_enabled

		if not self._is_enabled then
			self:_ScaleTo(1)
		end
	end)
end

function Portal:Update(p)
	self:_Pivot()

	if self._viewmodel_name == "Hotel Bell" then
		self.BigVisual.Part.SurfaceGui1.CanvasGroup.Spin.Rotation += p * -90
		self.BigVisual.Part.SurfaceGui2.CanvasGroup.Spin.Rotation += p * -90
	end

	if not self._is_enabled or self._finished_growing then
		return
	end

	local v = self._spawn_delay <= 0 and 1 or math.clamp((tick() - self._grow_start) / self._spawn_delay, 0, 1)
	self:_ScaleTo((v * 0.75 + 0.25) * (v < 1 and 3 or 1))

	if v < 1 then
		return
	end

	self._finished_growing = true
	self.FinishedGrowing:Fire()
	local v2 = self._spawn_delay <= 0.01

	if not v2 then
		self._pivot_offset_spring.Value = createVector(0, 0, -3)
	end

	self:UpdateVisuals(self._is_enabled, not v2)
end

function Portal:Destroy()
	pcall(function()
		self.Model:Destroy()
	end)
	pcall(function()
		self.Visual:Destroy()
	end)
	self.FinishedGrowing:Destroy()
end

function Portal:_GetPortalTemplate()
	return (portals:FindFirstChild((self.Model:GetAttribute("ViewModelName"))) or portals.Default)[self.PortalNum]
end

function Portal:_Pivot()
	self.Visual:PivotTo(self.Model:GetPivot() * CFrame.new(self._pivot_offset_spring.Value))
end

function Portal:_SafeParent(p, parent)
	pcall(function()
		p.Parent = parent
	end)
end

function Portal:_ScaleTo(p)
	local parent = self.BigVisual.Parent
	local parent2 = self.SmallVisual.Parent
	self:_SafeParent(self.BigVisual, self.Visual)
	self:_SafeParent(self.SmallVisual, self.Visual)
	self.Visual:ScaleTo(self._original_scale * p)
	self:_SafeParent(self.BigVisual, parent)
	self:_SafeParent(self.SmallVisual, parent2)
end

function Portal:_InitializeGrowing()
	self._grow_start = tick()
	self._spawn_delay = self.Model:GetAttribute("SpawnDelay") or 0
	self._finished_growing = false
	self:UpdateVisuals(self._is_enabled)
end

function Portal:_Setup()
	local teamColor = DuelLibrary:GetTeamColor(self._owner_team_id, nil, "PadColor")

	for _, descendant in pairs(self.Visual:GetDescendants()) do
		if descendant:HasTag("ColorThis") then
			local colorThisMultiplier = descendant:GetAttribute("ColorThisMultiplier") or 1
			local color = Color3.new(
				teamColor.R * colorThisMultiplier,
				teamColor.G * colorThisMultiplier,
				teamColor.B * colorThisMultiplier
			)

			if descendant:IsA("BasePart") then
				descendant.Color = color
			elseif descendant:IsA("Frame") then
				descendant.BackgroundColor3 = color
			elseif descendant:IsA("ImageLabel") then
				descendant.ImageColor3 = color
			end
		end

		if not descendant:IsA("BasePart") then
			continue
		end

		descendant.CanCollide = false
		descendant.CanQuery = false
		descendant.CanTouch = false
	end

	self.Gui.Parent = self.Visual.Primary

	if self._owner_user_id == Players.LocalPlayer.UserId then
		self.Gui.CanvasGroup.Keybind:SetAttribute("InputName", self.PortalNum == 1 and "Shoot" or "Aim")
		self.Gui.CanvasGroup.Keybind:AddTag("UIKeybindContainer")
	end

	self.Visual.PrimaryPart = self.Visual.Primary
	self.BigVisual.WorldPivot = self.Visual.WorldPivot
	self.SmallVisual.WorldPivot = self.Visual.WorldPivot
	self.Visual.Parent = self.Model
	local createSound = Utility:CreateSound(
		"rbxassetid://114274252176516",
		0.5,
		0.95 + 0.1 * math.random(),
		self.Visual.Primary,
		true
	)
	createSound.Looped = true
end

function Portal:_Init()
	self.Model:GetAttributeChangedSignal("SpawnDelay"):Connect(function()
		self:_InitializeGrowing()
	end)
	self.Model:GetAttributeChangedSignal("RegrowHash"):Connect(function()
		self:_InitializeGrowing()
	end)
	self:_Setup()
	self:_Pivot()
	self:_InitializeGrowing()
end

return Portal
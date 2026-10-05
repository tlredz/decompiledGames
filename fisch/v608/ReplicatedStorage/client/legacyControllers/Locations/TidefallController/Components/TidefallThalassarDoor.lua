local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local Replion = require(packages.Replion)
local v = Component.new({
	Tag = "TidefallThalassarDoor",
	Ancestors = { Workspace }
})
local cframe = CFrame.new(2887.73242, -567.386963, 1304.59741, 0, 0, -1, 0, 1, 0, 1, 0, 0)
local cframe2 = CFrame.new(2887.73242, -529.060974, 1305.68445, 0, 0, -1, 0, 1, 0, 1, 0, 0)
local localPlayer = Players.LocalPlayer
local maid = Trove.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function getHeldToolName()
	local character = localPlayer.Character
	local tool = character and character:FindFirstChildWhichIsA("Tool")
	return tool and tool.Name or nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPrimaryPart(model)
	if model:IsA("Model") then
		return model.PrimaryPart
	end

	return nil
end

local function findPrompt(instance)
	local primaryPart = instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart")

	if not primaryPart then
		return nil
	end

	local tidefallThalassarDoorPrompt = primaryPart:FindFirstChild("TidefallThalassarDoorPrompt")

	if not (tidefallThalassarDoorPrompt and tidefallThalassarDoorPrompt:IsA("ProximityPrompt") and tidefallThalassarDoorPrompt) then
		tidefallThalassarDoorPrompt = nil
	end

	return tidefallThalassarDoorPrompt
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelTween(p)
	local _tween = p._tween

	if _tween then
		_tween:Cancel()
		_tween:Destroy()
		p._tween = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateAll()
	for _, v2 in v:GetAll() do
		v2:_apply()
	end
end

local function onCharacter(character)
	maid:Clean()
	maid:Add(character.ChildAdded:Connect(function(tool)
		if tool:IsA("Tool") then
			updateAll() -- equivalent call inferred; original call site unknown
		end
	end))
	maid:Add(character.ChildRemoved:Connect(function(tool)
		if tool:IsA("Tool") then
			updateAll() -- equivalent call inferred; original call site unknown
		end
	end))
	updateAll() -- equivalent call inferred; original call site unknown
end

function v:Construct()
	self.trove = Trove.new()
	local instance = self.Instance

	if not instance:IsA("Model") then
		warn("[ThalassarRuin] Door tag must be on a Model:", instance:GetFullName())
		return
	end

	self.model = instance
	local primaryPart = getPrimaryPart(instance) -- equivalent call inferred; original call site unknown
	self.primary = primaryPart

	if not self.primary then
		warn("[ThalassarRuin] Door model missing PrimaryPart:", instance:GetFullName())
		return
	end

	local primaryPart2 = instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart")
	local tidefallThalassarDoorPrompt

	if primaryPart2 then
		tidefallThalassarDoorPrompt = primaryPart2:FindFirstChild("TidefallThalassarDoorPrompt")

		if not (tidefallThalassarDoorPrompt and tidefallThalassarDoorPrompt:IsA("ProximityPrompt") and tidefallThalassarDoorPrompt) then
			tidefallThalassarDoorPrompt = nil
		end
	end

	self.prompt = tidefallThalassarDoorPrompt

	if not self.prompt then
		warn("[ThalassarRuin] Door missing prompt:", instance:GetFullName())
		return
	end

	self.replion = Replion.Client:WaitReplion("TidefallThalassarRuin")
	self._wasOpened = false
	self._tween = nil
end

function v:_tweenTo(cframe3: CFrame, p)
	if not self.primary then
		return
	end

	cancelTween(self) -- equivalent call inferred; original call site unknown
	self._tween = TweenService:Create(self.primary, p, {
		CFrame = cframe3
	})
	self._tween:Play()
end

function v:_apply()
	if not (self.replion and self.primary and self.prompt) then
		return
	end

	local v2 = self.replion:Get("Completed") == true
	local wasOpened = self.replion:Get("DoorOpened") == true
	local v4 = getHeldToolName() == "Trident Rod"
	self.prompt.Enabled = v2 and not wasOpened and v4

	if wasOpened ~= self._wasOpened then
		self._wasOpened = wasOpened

		if wasOpened then
			self:_tweenTo(cframe2, TweenInfo.new(9, Enum.EasingStyle.Quad, Enum.EasingDirection.In))

			if self.primary then
				self.primary.Door:Play()
				self.primary.Door2:Play()
				self.primary.Whisper:Play()
			end
		else
			self:_tweenTo(cframe, TweenInfo.new(15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
		end
	end
end

function v:Start()
	if not self.replion then
		return
	end

	self.trove:Add(self.replion:OnDataChange(function()
		self:_apply()
	end))
	self:_apply()

	if self.primary then
		local wasOpened = self.replion:Get("DoorOpened") == true
		self._wasOpened = wasOpened
		self.primary.CFrame = wasOpened and cframe2 or cframe
	end
end

function v.Stop(p)
	cancelTween(p) -- equivalent call inferred; original call site unknown
	p.trove:Clean()
end

localPlayer.CharacterAdded:Connect(onCharacter)

if localPlayer.Character then
	onCharacter(localPlayer.Character)
end

return v
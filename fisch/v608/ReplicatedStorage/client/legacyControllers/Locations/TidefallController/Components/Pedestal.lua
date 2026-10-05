local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local Replion = require(packages.Replion)
local v = Component.new({
	Tag = "TidefallThalassarPedestal",
	Ancestors = { Workspace }
})

local function hexToColor3(color: string)
	local v2 = color:gsub("#", "")

	if #v2 ~= 6 then
		return nil
	end

	local v3 = tonumber(v2:sub(1, 2), 16)
	local v4 = tonumber(v2:sub(3, 4), 16)
	local v5 = tonumber(v2:sub(5, 6), 16)

	if v3 and v4 and v5 then
		return Color3.fromRGB(v3, v4, v5)
	end

	return nil
end

local function getPedestalColor(instance)
	local color = instance:GetAttribute("Color")
	local v2 = typeof(color) == "string" and hexToColor3(color)

	if v2 then
		return v2
	end

	return Color3.fromRGB(117, 0, 0)
end

local function setLightEnabled(light, enabled: boolean)
	if not light then
		return
	end

	if light:IsA("PointLight") or light:IsA("SpotLight") or light:IsA("SurfaceLight") then
		light.Enabled = enabled
	end
end

local function getPedestalPart(folder)
	if folder:IsA("BasePart") then
		return folder
	end

	if not folder:IsA("Model") then
		return nil
	end

	if folder.PrimaryPart and folder.PrimaryPart:IsA("BasePart") then
		return folder.PrimaryPart
	end

	local union = folder:FindFirstChild("Union", true)

	if union and union:IsA("BasePart") then
		return union
	end

	for _, part in ipairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			return part
		end
	end

	return nil
end

local function findEffects(instance)
	local pedestalPart = getPedestalPart(instance)

	if not pedestalPart then
		return {
			part = nil,
			attachment = nil,
			light = nil,
			shine1 = nil,
			sparkles = nil,
			pointLight = nil,
			pointLightHuge = nil,
			turnOn = nil,
			doorReady = nil
		}
	end

	local attachment = pedestalPart:FindFirstChildWhichIsA("Attachment", true)
	local light = nil
	local shine = nil
	local sparkles2 = nil

	if attachment then
		light = attachment:FindFirstChild("Light") or light
		local shine1 = attachment:FindFirstChild("shine1")

		if shine1 and shine1:IsA("ParticleEmitter") then
			shine = shine1
		end

		local sparkles = attachment:FindFirstChild("sparkles")

		if sparkles and sparkles:IsA("ParticleEmitter") then
			sparkles2 = sparkles
		end
	end

	local pointLight = pedestalPart:FindFirstChildWhichIsA("PointLight", true)
	local pointLightHuge = nil
	local pointLight_Huge = pedestalPart:FindFirstChild("PointLight_Huge", true)

	if pointLight_Huge and pointLight_Huge:IsA("PointLight") then
		pointLightHuge = pointLight_Huge
	end

	local turnOn2 = nil
	local turnOn = pedestalPart:FindFirstChild("TurnOn", true)

	if turnOn and turnOn:IsA("Sound") then
		turnOn2 = turnOn
	end

	local doorReady2 = nil
	local doorReady = pedestalPart:FindFirstChild("DoorReady", true)

	if doorReady and doorReady:IsA("Sound") then
		doorReady2 = doorReady
	end

	return {
		part = pedestalPart,
		attachment = attachment,
		light = light,
		shine1 = shine,
		sparkles = sparkles2,
		pointLight = pointLight,
		pointLightHuge = pointLightHuge,
		turnOn = turnOn2,
		doorReady = doorReady2
	}
end

local function findOrWaitPrompt(instance, trove, fn)
	local tidefallThalassarPlacePrompt = instance:FindFirstChild("TidefallThalassarPlacePrompt", true)

	if tidefallThalassarPlacePrompt and tidefallThalassarPlacePrompt:IsA("ProximityPrompt") then
		fn(tidefallThalassarPlacePrompt)
	else
		trove:Add(instance.DescendantAdded:Connect(function(proximityPrompt)
			if proximityPrompt:IsA("ProximityPrompt") and proximityPrompt.Name == "TidefallThalassarPlacePrompt" then
				fn(proximityPrompt)
			end
		end))
	end
end

function v:Construct()
	self.trove = Trove.new()
	self.slotId = self.Instance:GetAttribute("SlotId")

	if typeof(self.slotId) ~= "string" or self.slotId == "" then
		warn("[ThalassarRuin] Pedestal missing SlotId:", self.Instance:GetFullName())
		return
	end

	self.replion = Replion.Client:WaitReplion("TidefallThalassarRuin")
	self.prompt = nil
	self.effects = findEffects(self.Instance)
	self._wasPlaced = false
	findOrWaitPrompt(self.Instance, self.trove, function(prompt)
		self.prompt = prompt
		self:_apply()
	end)
	self.trove:Add(self.Instance.DescendantAdded:Connect(function(instance)
		if self.effects.part or not instance:IsA("BasePart") then
			if self.effects.part and (instance:IsA("Attachment") or instance:IsA("ParticleEmitter") or instance:IsA("PointLight") or instance:IsA("Sound")) then
				self.effects = findEffects(self.Instance)
				self:_apply()
			end
		else
			self.effects = findEffects(self.Instance)
			self:_apply()
		end
	end))
	self.trove:Add(self.replion:OnDataChange(function()
		self:_apply()
	end))
	self:_apply()
end

function v:_playPlacedFx()
	local part = self.effects.part

	if not part then
		return
	end

	local color = self.Instance:GetAttribute("Color")
	local color2 = typeof(color) == "string" and hexToColor3(color) or Color3.fromRGB(117, 0, 0)
	part.Color = color2
	part.Material = Enum.Material.Neon
	local light = self.effects.light

	if light and (light:IsA("PointLight") or light:IsA("SpotLight") or light:IsA("SurfaceLight")) then
		light.Enabled = true
	end

	if self.effects.shine1 then
		self.effects.shine1:Emit(3)
	end

	if self.effects.sparkles then
		self.effects.sparkles:Emit(50)
	end

	if self.effects.pointLight then
		self.effects.pointLight.Enabled = true
	end

	if self.effects.pointLightHuge then
		self.effects.pointLightHuge.Enabled = true
	end

	if self.effects.turnOn then
		self.effects.turnOn:Play()
	end

	for _, part2 in ipairs(self.Instance:GetDescendants()) do
		if not (part2:IsA("BasePart") and part2.Name == "PlaneToChange") then
			continue
		end

		part2.Color = color2
		part2.Material = Enum.Material.Neon
	end
end

function v:_setIdleFx()
	local part = self.effects.part

	if not part then
		return
	end

	part.Color = Color3.fromRGB(81, 81, 81)
	part.Material = Enum.Material.Marble
	local light = self.effects.light

	if light and (light:IsA("PointLight") or light:IsA("SpotLight") or light:IsA("SurfaceLight")) then
		light.Enabled = false
	end

	if self.effects.pointLight then
		self.effects.pointLight.Enabled = false
	end

	if self.effects.pointLightHuge then
		self.effects.pointLightHuge.Enabled = false
	end

	for _, part2 in ipairs(self.Instance:GetDescendants()) do
		if not (part2:IsA("BasePart") and part2.Name == "PlaneToChange") then
			continue
		end

		part2.Color = Color3.fromRGB(81, 81, 81)
		part2.Material = Enum.Material.Marble
	end
end

function v:_apply()
	if not self.replion then
		return
	end

	if not self.effects.part then
		self.effects = findEffects(self.Instance)
	end

	local v2 = self.replion:Get("Completed") == true
	local wasPlaced = (self.replion:Get("Placed") or {})[self.slotId] == true

	if self.prompt then
		self.prompt.Enabled = not (v2 or wasPlaced)
	end

	if wasPlaced and not self._wasPlaced then
		self:_playPlacedFx()
	elseif not wasPlaced and self._wasPlaced then
		self:_setIdleFx()
	end

	self._wasPlaced = wasPlaced
end

function v.Start(_) end

function v.Stop(p)
	p.trove:Clean()
end

return v
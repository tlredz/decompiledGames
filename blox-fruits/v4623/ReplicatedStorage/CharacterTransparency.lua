local Util = require(game.ReplicatedStorage.Util)
local maid = Util.Maid
local Util2 = require(game.ReplicatedStorage.Util)
Util2 = Util2.Signal2
local TransformationAccessories = require(game.ReplicatedStorage.Util.TransformationAccessories)
local numberSequence = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.1), NumberSequenceKeypoint.new(1, 1.1) })
local v = {}
local v2 = {}
local CharacterTransparency = {}

for _, v3 in pairs({
	"Head",
	"UpperTorso",
	"RightUpperLeg",
	"RightUpperArm",
	"RightLowerLeg",
	"RightLowerArm",
	"RightHand",
	"RightFoot",
	"LowerTorso",
	"LeftUpperLeg",
	"LeftUpperArm",
	"LeftLowerLeg",
	"LeftLowerArm",
	"LeftHand",
	"LeftFoot"
}) do
	v[v3] = true
end

function CharacterTransparency.new(character)
	if v2[character] then
		return v2[character]
	end

	local object = setmetatable({}, {
		__index = CharacterTransparency
	})
	object.Character = character
	object.Player = game.Players:GetPlayerFromCharacter(character)
	object._Monitored = {}
	object._MonitoredMaidIds = {}
	object._Maid = maid.new()
	object._Stacks = {}
	object.Mode = 0
	v2[character] = object

	if object.Character:FindFirstChild("Humanoid") then
		object:GiveTask(object.Character.Humanoid.Died:Connect(function()
			object:Destroy()
		end))
		object:GiveTask(object.Character:GetPropertyChangedSignal("Parent"):Connect(function()
			if not object.Character.Parent then
				object:Destroy()
			end
		end))
	end

	local v3 = {}

	for _, tool in pairs(object.Character:GetChildren()) do
		if not (tool:IsA("Tool") and tool.ToolTip == "") then
			continue
		end

		for _, descendant in pairs(tool:GetDescendants()) do
			v3[descendant] = true
		end
	end

	for _, descendant in pairs(object.Character:GetDescendants()) do
		if not v3[descendant] then
			object:MonitorPart(descendant)
		end
	end

	object:GiveTask(object.Character.DescendantAdded:Connect(function(descendant)
		local parent = descendant.Parent

		while parent ~= object.Character do
			if parent:IsA("Tool") and parent.ToolTip == "" then
				return
			else
				parent = parent.Parent
			end
		end

		object:MonitorPart(descendant)
	end))
	return object
end

function CharacterTransparency:_UpdateState()
	local v3 = 0

	for _, _Stack in pairs(self._Stacks) do
		v3 = math.max(v3, _Stack.Mode)

		if v3 == 2 then
			break
		end
	end

	self:_SetVisible(v3)
end

function CharacterTransparency:AddStack(p, label, mode, expires)
	local manager = CharacterTransparency.new(p)
	local v4 = nil
	v4 = {
		Mode = mode,
		Label = label,
		Expires = expires,
		Destroyed = false,
		Destroy = function(self)
			if self.Destroyed then
				return
			end

			self.Destroyed = true

			for k, _Stack in pairs(self.Manager._Stacks) do
				if _Stack ~= v4 then
					continue
				end

				table.remove(self.Manager._Stacks, k)
				CharacterTransparency.new(p):_UpdateState()
			end
		end,
		Manager = manager
	}

	if expires then
		if expires > 1000000 then
			expires -= workspace:GetServerTimeNow()
		end

		task.delay(expires, v4.Destroy, v4)
	end

	table.insert(manager._Stacks, v4)
	manager:_UpdateState()
	return v4
end

function CharacterTransparency:ReplaceStack(p, p2, p3, p4)
	self:RemoveStack(p, p2, true)
	self:AddStack(p, p2, p3, p4)
end

function CharacterTransparency:RemoveStack(p, p2, p3)
	if not v2[p] then
		return
	end

	local v3 = CharacterTransparency.new(p)
	local _Stacks = {}

	for _, _Stack in pairs(v3._Stacks) do
		if _Stack.Label == p2 then
			_Stack.Destroyed = true
		else
			table.insert(_Stacks, _Stack)
		end
	end

	v3._Stacks = _Stacks

	if not p3 then
		v3:_UpdateState()
	end
end

function CharacterTransparency:_SetVisible(mode)
	self.Mode = mode

	for instance in self._Monitored do
		if instance:IsDescendantOf(game) then
			if not instance:GetAttribute("TransparencyBypass") then
				local trueTransparency = instance:GetAttribute("TrueTransparency")

				if self.Mode == 1 and instance:GetAttribute("PartType") == 1 or self.Mode == 2 then
					if instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("Texture") then
						trueTransparency = 1.1
					elseif instance:IsA("Light") then
						trueTransparency = Color3.fromRGB(0, 0, 0)
					else
						trueTransparency = numberSequence
					end
				end

				if instance:IsA("Light") then
					instance.Color = trueTransparency
				elseif typeof(instance.Transparency) == "number" then
					instance.Transparency = trueTransparency or 0
				else
					if typeof(trueTransparency) ~= "NumberSequence" then
						trueTransparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, trueTransparency or 0),
							NumberSequenceKeypoint.new(1, trueTransparency or 0)
						})
					end

					instance.Transparency = trueTransparency
				end
			end
		else
			self._Monitored[instance] = nil
			local _MonitoredMaidId = self._MonitoredMaidIds[instance]

			if _MonitoredMaidId then
				for _, v3 in _MonitoredMaidId do
					local connection = self._Maid[v3]

					if not connection then
						continue
					end

					if typeof(connection) == "RBXScriptConnection" then
						connection:Disconnect()
					elseif typeof(connection) == "function" then
						connection()
					end

					self._Maid[v3] = nil
				end

				self._MonitoredMaidIds[instance] = nil
			end
		end
	end
end

function CharacterTransparency:MonitorPart(instance)
	if instance.Parent == self.Character then
		local v3 = instance.Name:gsub("_.+$", "")

		if instance:IsA("BasePart") and (v[instance.Name] or v[v3]) or instance.ClassName == "Model" and instance:GetAttribute("IsWeapon") or instance:IsA("Humanoid") or instance:IsA("Accessory") or instance:IsA("Tool") or instance:GetAttribute("IsAccessory") or TransformationAccessories.isAccessoryModel(
			instance,
			self.Character
		) then
			instance:SetAttribute("PartType", 1)

			if instance.Name == "PhoenixBF" or instance.Name == "MagnetRig" or instance.Name == "YetiRig" or instance.Name == "TigerRig" or instance.Name == "Mammoth" or instance.Name == "Kitsune" or instance.Name == "TRex" or instance.Name == "WesternDragonRig" or instance.Name == "EasternBloxfruitsDragon" or instance.Name == "GasRig" then
				instance:SetAttribute("PartType", 2)
			end
		else
			instance:SetAttribute("PartType", 2)
		end

		if instance.Name == "Head" then
			local v4 = {
				Transparency = instance.Transparency,
				TrueTransparency = instance:GetAttribute("TrueTransparency")
			}
			instance:GetPropertyChangedSignal("Transparency"):Connect(function()
				v4.Transparency = instance.Transparency
			end)
			instance:GetAttributeChangedSignal("TrueTransparency"):Connect(function()
				v4.TrueTransparency = instance:GetAttribute("TrueTransparency")
			end)
		end
	elseif instance.Parent:GetAttribute("PartType") then
		instance:SetAttribute("PartType", instance.Parent:GetAttribute("PartType"))
	else
		instance:SetAttribute("PartType", 2)
	end

	local flag = false
	local v3 = {}

	if instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("Texture") then
		local threads = {}
		local _, v4 = self:GiveTask(instance:GetPropertyChangedSignal("Transparency"):Connect(function()
			if instance:GetAttribute("TransparencyBypass") then
				return
			end

			local transparency = instance.Transparency

			if threads and #threads > 0 then
				coroutine.running()
				table.insert(threads, coroutine.running())
				coroutine.yield()
			end

			if transparency < 1.09 then
				if not instance:GetAttribute("PartType") and instance.Name == "Handle" then
					local lastTime = os.clock()

					while not instance:GetAttribute("PartType") and os.clock() - lastTime < 0.2 do
						task.wait()
					end
				end

				if instance.Parent and (instance.Parent.Name == "Dragon" or instance.Parent.Name == "Rig" and instance.Parent.Parent and instance.Parent.Parent.Name:match("Dragon")) then
					instance:SetAttribute("TrueTransparency", 0)
				else
					instance:SetAttribute("TrueTransparency", transparency)
				end

				if instance.Name == "HumanoidRootPart" then
					instance:SetAttribute("TrueTransparency", 1)
				end

				if self.Mode == 1 and instance:GetAttribute("PartType") == 1 or self.Mode == 2 then
					instance.Transparency = 1.1
				end
			end

			if not threads then
				return
			end

			if threads and #threads > 0 then
				local v5 = threads[1]
				table.remove(threads, 1)
				coroutine.resume(v5)
			end
		end))
		local _, v5 = self:GiveTask(function()
			if threads then
				for _, v6 in pairs(threads) do
					task.cancel(v6)
				end
			end

			threads = nil
		end)
		table.insert(v3, v4)
		table.insert(v3, v5)

		if instance.Transparency < 1.09 and not instance:GetAttribute("TransparencyBypass") then
			if instance.Parent and (instance.Parent.Name == "Dragon" or instance.Parent.Name == "Rig" and instance.Parent.Parent and instance.Parent.Parent.Name:match("Dragon")) then
				instance:SetAttribute("TrueTransparency", 0)
			else
				instance:SetAttribute("TrueTransparency", instance.Transparency)
			end

			if instance.Name == "HumanoidRootPart" then
				instance:SetAttribute("TrueTransparency", 1)
			end

			if self.Mode == 1 and instance:GetAttribute("PartType") == 1 or self.Mode == 2 then
				instance.Transparency = 1.1
			end
		end

		flag = true
	elseif instance:IsA("Beam") or instance:IsA("ParticleEmitter") or instance:IsA("Trail") then
		local _, v4 = self:GiveTask(instance:GetPropertyChangedSignal("Transparency"):Connect(function()
			if instance.Transparency ~= numberSequence and not instance:GetAttribute("TransparencyBypass") then
				instance:SetAttribute("TrueTransparency", instance.Transparency)

				if self.Mode == 1 and instance:GetAttribute("PartType") == 1 or self.Mode == 2 then
					instance.Transparency = numberSequence
				end
			end
		end))
		table.insert(v3, v4)

		if instance.Transparency ~= numberSequence and not instance:GetAttribute("TransparencyBypass") then
			instance:SetAttribute("TrueTransparency", instance.Transparency)

			if self.Mode == 1 and instance:GetAttribute("PartType") == 1 or self.Mode == 2 then
				instance.Transparency = numberSequence
			end
		end

		flag = true
	elseif instance:IsA("Light") then
		local _, v4 = self:GiveTask(instance:GetPropertyChangedSignal("Color"):Connect(function()
			if instance.Color ~= Color3.fromRGB(0, 0, 0) and not instance:GetAttribute("TransparencyBypass") then
				instance:SetAttribute("TrueTransparency", instance.Color)

				if self.Mode == 1 and instance:GetAttribute("PartType") == 1 or self.Mode == 2 then
					instance.Color = Color3.fromRGB(0, 0, 0)
				end
			end
		end))
		table.insert(v3, v4)

		if instance.Color ~= Color3.fromRGB(0, 0, 0) and not instance:GetAttribute("TransparencyBypass") then
			instance:SetAttribute("TrueTransparency", instance.Color)

			if self.Mode == 1 and instance:GetAttribute("PartType") == 1 or self.Mode == 2 then
				instance.Color = Color3.fromRGB(0, 0, 0)
			end
		end

		flag = true
	end

	if flag then
		self._Monitored[instance] = true
		local _, v4 = self:GiveTask(instance.Destroying:Connect(function()
			self._Monitored[instance] = nil
			local _MonitoredMaidId = self._MonitoredMaidIds[instance]

			if _MonitoredMaidId then
				for _, v5 in _MonitoredMaidId do
					local connection = self._Maid[v5]

					if not connection then
						continue
					end

					if typeof(connection) == "RBXScriptConnection" then
						connection:Disconnect()
					elseif typeof(connection) == "function" then
						connection()
					end

					self._Maid[v5] = nil
				end

				self._MonitoredMaidIds[instance] = nil
			end
		end))
		table.insert(v3, v4)
		self._MonitoredMaidIds[instance] = v3
	end
end

function CharacterTransparency:Destroy()
	v2[self.Character] = nil
	self._Maid:DoCleaning()
end

function CharacterTransparency:GiveTask(p2)
	local _, v3 = self._Maid:GiveTask(p2)
	return p2, v3
end

game.Players.PlayerRemoving:Connect(function(player)
	for _, v3 in pairs(v2) do
		if v3.Player == player then
			v3:Destroy()
		end
	end
end)
game.ReplicatedStorage.Remotes.CharacterTransparency.OnClientEvent:Connect(function(p, p2, ...)
	local Global = require(game.ReplicatedStorage.Global)
	local encoded = Global.Encode(p)

	if p2 == "RemoveStack" then
		CharacterTransparency:RemoveStack(encoded, "Server_" .. ...)
	elseif p2 == "AddStack" then
		local v3, v4, v5 = ...
		CharacterTransparency:AddStack(encoded, "Server_" .. (v3 or math.random(1, 1000000)), v4, v5)
	elseif p2 == "ReplaceStack" then
		local v3, v4, v5 = ...
		CharacterTransparency:ReplaceStack(encoded, "Server_" .. (v3 or math.random(1, 1000000)), v4, v5)
	elseif p2 == "SetLocalTransparency" then
		local transparency = ...

		if encoded then
			encoded.Transparency = transparency

			if transparency == 1 then
				encoded.CanCollide = false
				encoded.CanQuery = false
				encoded.CanTouch = false
			end
		end
	end
end)
workspace.Characters.ChildAdded:Connect(function(child)
	local transparencyMode = child:GetAttribute("TransparencyMode")

	if transparencyMode then
		CharacterTransparency:ReplaceStack(child, "Server_ServerStat", transparencyMode)
	end
end)

for _, child in pairs(workspace.Characters:GetChildren()) do
	local transparencyMode = child:GetAttribute("TransparencyMode")

	if transparencyMode then
		CharacterTransparency:ReplaceStack(child, "Server_ServerStat", transparencyMode)
	end
end

local CollectionService = game:GetService("CollectionService")
CollectionService:GetInstanceAddedSignal("InvisEnemyRig"):Connect(function(p)
	CharacterTransparency:AddStack(p, "RigInvis", 1)
end)
local CollectionService2 = game:GetService("CollectionService")
CollectionService2:GetInstanceRemovedSignal("InvisEnemyRig"):Connect(function(p)
	CharacterTransparency:RemoveStack(p, "RigInvis")
end)
return CharacterTransparency
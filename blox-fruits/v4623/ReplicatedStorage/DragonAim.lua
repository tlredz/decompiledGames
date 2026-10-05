local v = 360
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
require(game.ReplicatedStorage.Util.Signal2)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local v2 = {}
local v3 = os.clock() + 0.02857142857142857

local function computeNeckRotation(cframe, target, p)
	local vectorToObjectSpace = cframe:VectorToObjectSpace(target - cframe.Position)
	local X = vectorToObjectSpace.X
	local Y = vectorToObjectSpace.Y
	local Z = vectorToObjectSpace.Z

	if p then
		local v4 = math.atan2(Y, (math.max(math.sqrt(X * X + Z * Z), 50)))
		local v5 = math.clamp(v4, -1.5707963267948966, 1.5707963267948966)
		return v5, v4 - v5
	else
		local v4 = -math.atan2(X, -Z)
		local v5 = math.clamp(v4, -1.5707963267948966, 1.5707963267948966)
		return v5, v4 - v5
	end
end

local class = {}
class.__index = class

function class.new(character, rig)
	if v2[rig] then
		return v2[rig]
	end

	local object = setmetatable({}, class)
	local localCharacter

	if isServer then
		localCharacter = false
	else
		localCharacter = character == game.Players.LocalPlayer.Character
	end

	object.LocalCharacter = localCharacter
	object.Character = character
	object.Player = game.Players:GetPlayerFromCharacter(character)
	object.Rig = rig
	object.Bones = {}

	for i = 9, 0, -1 do
		local child = rig:FindFirstChild("Neck" .. (i <= 0 and 10 or i), true)

		if not child then
			local descendantAddedConnection = nil
			local v5 = i
			local v6 = coroutine.running()
			descendantAddedConnection = rig.DescendantAdded:Connect(function(descendant)
				if descendant.Name == "Neck" .. (not (v5 > 0) and 10 or v5) then
					child = descendant
					descendantAddedConnection:Disconnect()
					coroutine.resume(v6)
				end
			end)
			coroutine.yield()
		end

		table.insert(object.Bones, child)
	end

	object.Maid = Maid.new()
	object.Root = rig:FindFirstChild("Controller", true)
	object.Head = rig:FindFirstChild("Head Controller", true)
	object.LastAngles = { 0, 0 }

	if not object.LocalCharacter then
		local child = script:WaitForChild(object.Character.Name, 5)

		if not child then
			return
		end

		object.Maid:GiveTask(child:GetAttributeChangedSignal("Target"):Connect(function()
			object:SetTarget(child:GetAttribute("Target"))
		end))
		object.Maid:GiveTask(child:GetAttributeChangedSignal("Enabled"):Connect(function()
			object:Toggle(child:GetAttribute("Enabled"))
		end))
		object.Maid:GiveTask(child.AncestryChanged:Connect(function(_, parent)
			if not parent then
				object.Maid:DoCleaning()
			end
		end))
		object:Update(child:GetAttribute("Target"))
		object:Toggle(child:GetAttribute("Enabled"))
	end

	object.Maid:GiveTask(rig.AncestryChanged:Connect(function(_, parent)
		if not parent then
			object.Maid:DoCleaning()
		end
	end))
	object.Maid:GiveTask(function()
		v2[rig] = nil
		object.Destroyed = true
	end)
	v2[rig] = object
	return object
end

function class:SetTarget(target)
	self.Target = target
end

function class:Toggle(enabled)
	if self.Destroyed then
		return
	end

	if self.Enabled ~= enabled then
		if enabled then
			self.LastAngles = { 0, 0 }
			self.Rig.Rig.HeadProxy.Weld.C0 = self.Rig.Rig.HeadProxy1.CFrame:ToObjectSpace(self.Head.TransformedWorldCFrame * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			) * CFrame.new(0, 0, -10))
		end

		self.Enabled = enabled

		if not enabled then
			self.Rig.Rig.HeadProxy.Weld.Part0 = self.Rig.Rig.HeadProxy1
			self.LastOn = os.clock()
			self.LastAngles = { 0, 0, self.LastAngles[3] }
		end
	end
end

function class:HasAnimation()
	return #self.Rig:FindFirstChild("Animator", true):GetPlayingAnimationTracks() > 0
end

function class:Update(p)
	if self.Destroyed or not self.Rig:FindFirstChild("Rig") then
		return
	end

	local bones = self.Bones
	local head = self.Head
	local root = self.Root
	local lastAngles = self.LastAngles

	local function AlignHead(list)
		local objectSpace = bones[#bones].TransformedWorldCFrame:ToObjectSpace(head.TransformedWorldCFrame)
		return {
			Set = function(self, p2)
				local inverse = (bones[#bones].TransformedWorldCFrame * objectSpace):ToObjectSpace(head.WorldCFrame):Inverse()

				if p2 then
					head.Transform = inverse * p2
				else
					head.Transform = inverse
				end
			end,
			Get = function()
				local v4

				if list then
					v4 = list[4]
				else
					v4 = bones[#bones].TransformedWorldCFrame
				end

				local inverse = (v4 * objectSpace):ToObjectSpace(head.WorldCFrame):Inverse()
				return head.WorldCFrame * inverse
			end
		}
	end

	if self.Enabled then
		if not self.Target then
			return
		end

		local v4 = v
		local v5 = not self.LocalCharacter and 100000 or v4

		if not self:HasAnimation() then
			for _, bone in pairs(bones) do
				bone.Transform = CFrame.new()
			end

			head.Transform = CFrame.new()
		end

		local v6 = {
			0,
			0,
			{},
			bones[#bones].TransformedWorldCFrame
		}

		for _, bone in pairs(bones) do
			table.insert(v6[3], bone.Transform)
		end

		local alignHead = AlignHead(v6)

		local function Update(p2, p3)
			for i = 2, 1, -1 do
				for _ = 1, p2 do
					local v8, _ = computeNeckRotation(
						alignHead:Get() * CFrame.Angles(-1.5707963267948966, 0, 0),
						self.Target,
						i == 2
					)
					local v9 = {
						math.clamp(lastAngles[i] - v5 * p, -90, 90),
						(math.clamp(lastAngles[i] + v5 * p, -90, 90))
					}
					local v10 = math.clamp(v6[i] + math.deg(v8), v9[1], v9[2])
					local v11 = math.rad(v10 - v6[i])

					if math.abs(v11) <= math.rad(p3) then
						break
					end

					v6[i] = v10
					local v12 = math.deg(v11)
					local transformedWorldCFrame = bones[1].Parent.TransformedWorldCFrame

					for i2 = 1, #bones do
						local bone = bones[i2]
						local v13 = v6[3][i2]
						local v14 = transformedWorldCFrame * bone.CFrame
						transformedWorldCFrame = v14 * v13

						if i == 1 and i2 <= 6 then
							local inverse = (CFrame.new(transformedWorldCFrame.Position) * CFrame.fromAxisAngle(
								root.TransformedWorldCFrame.UpVector,
								(math.rad(v12 / 6))
							) * transformedWorldCFrame.Rotation):ToObjectSpace(v14):Inverse()
							v6[3][i2] = inverse
							transformedWorldCFrame = v14 * inverse
						elseif i == 2 and i2 > 6 then
							local v15 = v6[3][i2] * CFrame.Angles(math.rad(v12 / (#bones - 6)), 0, 0)
							v6[3][i2] = v15
							transformedWorldCFrame = v14 * v15
						end

						if i2 == #bones then
							v6[4] = transformedWorldCFrame
						end
					end
				end
			end
		end

		Update(2, 2)
		Update(2, 0.5)
		Update(2, 0.01)
		self.LastAngles = { v6[1], v6[2], v6[3] }

		if isServer then
			local v8 = alignHead:Get()
			local headProxy = self.Rig.Rig.HeadProxy
			headProxy.Weld.C0 = self.Rig.Rig.HeadProxy1.CFrame:ToObjectSpace(v8 * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			) * CFrame.new(0, 0, -10))
			headProxy.Weld.C1 = CFrame.new()
		else
			for k, transform in pairs(v6[3]) do
				bones[k].Transform = transform
			end

			alignHead:Set()

			if not pcall(function()
				self.Rig.Rig.HeadProxy.Weld.C0 = self.Rig.Rig.HeadProxy1.CFrame:ToObjectSpace(head.TransformedWorldCFrame * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				) * CFrame.new(0, 0, -10))
				self.Rig.Rig.HeadProxy.Weld.C1 = CFrame.new()
			end) then
				print("LastUpdateWas", p)
				print(
					self.Rig.Rig:FindFirstChild("HeadProxy1"),
					self.Rig.Rig:FindFirstChild("HeadProxy"),
					head.TransformedWorldCFrame
				)
				error("HeadProxy missing error")
			end
		end
	else
		if self.LastOn then
			local v4 = math.min((os.clock() - self.LastOn) / 0.15, 1)

			if lastAngles[3] then
				local alignHead = AlignHead()

				for k, v6 in pairs(lastAngles[3]) do
					bones[k].Transform = v6:Lerp(bones[k].Transform, v4)
				end

				alignHead:Set()
			end

			if v4 >= 1 then
				self.LastAngles = { 0, 0 }
				self.Rig.Rig.HeadProxy.Weld.C0 = self.Rig.Rig.HeadProxy1.CFrame:ToObjectSpace(head.TransformedWorldCFrame * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				) * CFrame.new(0, 0, -10))
				self.LastOn = nil
			end
		end

		self.Rig.Rig.HeadProxy.Weld.C0 = self.Rig.Rig.HeadProxy1.CFrame:ToObjectSpace(head.TransformedWorldCFrame * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		) * CFrame.new(0, 0, -10))
	end
end

if isServer then
	local function playerAdded(player)
		local maid = Maid.new()

		local function characteradded(character)
			maid:DoCleaning()

			local function registerRig(instance)
				if instance.Name == "WesternDragonRig" then
					if not instance:WaitForChild("Rig"):GetAttribute("Loaded") then
						instance:WaitForChild("Rig"):GetAttributeChangedSignal("Loaded"):Wait()
					end

					if instance.Parent ~= character then
						return
					end

					local objectValue = script:FindFirstChild(character.Name)

					if objectValue and objectValue:IsA("ObjectValue") and objectValue.Value == instance then
						return
					end

					local objectValue2 = Instance.new("ObjectValue")
					objectValue2.Name = character.Name
					objectValue2.Value = instance
					objectValue2.Parent = script
					maid:GiveTask(objectValue2)
					instance.AncestryChanged:Connect(function(_, parent)
						if not parent then
							objectValue2:Destroy()
						end
					end)
				end
			end

			maid:GiveTask(character.ChildAdded:Connect(registerRig))
			local westernDragonRig = character:FindFirstChild("WesternDragonRig")

			if westernDragonRig then
				task.spawn(registerRig, westernDragonRig)
			end
		end

		local characterAddedConnection = player.CharacterAdded:Connect(characteradded)

		if player.Character then
			task.spawn(function()
				characteradded(player.Character)
			end)
		end

		local playerRemovingConnection = nil
		playerRemovingConnection = game.Players.PlayerRemoving:Connect(function(player2)
			if player2 == player then
				maid:DoCleaning()
				characterAddedConnection:Disconnect()
				playerRemovingConnection:Disconnect()
			end
		end)
	end

	game.Players.PlayerAdded:Connect(playerAdded)

	for _, v4 in pairs(game.Players:GetPlayers()) do
		task.spawn(playerAdded, v4)
	end

	script.RemoteEvent.OnServerEvent:Connect(function(player, target)
		if typeof(target) ~= "Vector3" and target ~= false then
			return
		end

		local child = player.Character:FindFirstChild("WesternDragonRig") and player.Character:FindFirstChild("HumanoidRootPart") and script:FindFirstChild(player.Character.Name)

		if child then
			if target == false then
				child:SetAttribute("Enabled", false)
			else
				child:SetAttribute("Target", target)
				child:SetAttribute("Enabled", true)
			end
		end
	end)
	local v4 = nil

	local function childAdded(instance)
		local v5 = class.new(instance.Value.Parent, instance.Value)

		if v5.LocalCharacter then
			v4 = v5
			return
		end

		instance:GetAttributeChangedSignal("Target"):Connect(function()
			v5:SetTarget(instance:GetAttribute("Target"))
		end)
		instance:GetAttributeChangedSignal("Enabled"):Connect(function()
			v5:Toggle(instance:GetAttribute("Enabled"))
		end)
	end

	script.ChildAdded:Connect(childAdded)

	for _, objectValue in pairs(script:GetChildren()) do
		if objectValue:IsA("ObjectValue") then
			task.spawn(childAdded, objectValue)
		end
	end

	local function pcall2(callback)
		callback()
	end

	task.spawn(function()
		local function Loop()
			while task.wait(0.016666666666666666) do
				for _, v5 in pairs(v2) do
					v5:Update(0.016666666666666666)
				end
			end
		end

		while task.wait() do
			Loop()
		end
	end)
	return function(player, p)
		script.RemoteEvent:FireClient(player, p)
	end
else
	local v4 = nil

	local function childAdded(objectValue)
		if not objectValue:IsA("ObjectValue") then
			return
		end

		while objectValue.Parent == script and not objectValue.Value do
			task.wait()
		end

		if objectValue.Parent ~= script or not objectValue.Value then
			return
		end

		local value = objectValue.Value
		local rig = value:WaitForChild("Rig", 5)

		if not rig then
			return
		end

		local WaitForExpectedDescendants = require(game.ReplicatedStorage.Util.WaitForExpectedDescendants)

		if not WaitForExpectedDescendants(rig, 5) then
			warn("Failed to wait for WesternDragonRig: 2")
			return
		end

		if objectValue.Parent ~= script or objectValue.Value ~= value or not value.Parent then
			return
		end

		local v5 = class.new(value.Parent, value)

		if not v5 then
			return
		end

		if v5.LocalCharacter then
			v4 = v5
			return
		end

		objectValue:GetAttributeChangedSignal("Target"):Connect(function()
			v5:SetTarget(objectValue:GetAttribute("Target"))
		end)
		objectValue:GetAttributeChangedSignal("Enabled"):Connect(function()
			v5:Toggle(objectValue:GetAttribute("Enabled"))
		end)
	end

	script.ChildAdded:Connect(childAdded)

	for _, objectValue in pairs(script:GetChildren()) do
		if objectValue:IsA("ObjectValue") then
			task.spawn(childAdded, objectValue)
		end
	end

	local Mouse = require(game.ReplicatedStorage.Mouse)
	local RunService2 = game:GetService("RunService")
	RunService2:BindToRenderStep("WesternDragonAiming", Enum.RenderPriority.First.Value, function(p)
		for _, v5 in pairs(v2) do
			if v5.LocalCharacter then
				v5:SetTarget(Mouse.Hit.Position)
				v5:Update(p)

				if v3 < os.clock() then
					if v5.Enabled or v5.LastOn then
						script.RemoteEvent:FireServer((v5.Head.TransformedWorldCFrame * CFrame.Angles(
							-1.5707963267948966,
							0,
							0
						) * CFrame.new(0, 0, -2000)).Position)
					else
						script.RemoteEvent:FireServer(false)
					end

					v3 = os.clock() + 0.02857142857142857
				end
			else
				v5:Update(p)
			end
		end
	end)
	script.RemoteEvent.OnClientEvent:Connect(function(p)
		if v4 then
			v4:Toggle(p)
		end
	end)
	local v5 = v
	return function(flag: boolean, p: number)
		v = p or v5

		if v4 then
			v4:Toggle(flag)
		end
	end
end
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Grinding = require(ReplicatedStorage.Modules.Client.Components.Interactions.Olympics.Grinding)
local v = Component.new({
	Tag = "GrindingRail"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._active = false
	self._currentDistance = 0
	self._reverse = false
	self._totalDistance = 0
	self._debounce = false
	self._speed = 0
end

function v:Start()
	local total = 0

	for _, part in self.Instance:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		total += part.Size.Z
		local v2 = part
		self._Janitor:Add(part.Touched:Connect(function(otherPart)
			if self._debounce then
				return
			end

			self._debounce = true
			self:FollowRail(v2, otherPart)
		end))
	end

	self._Janitor:Add(UserInputService.JumpRequest:Connect(function()
		self:StopGrinding()
	end))
	self._totalDistance = total
end

function v:FollowRail(instance, instance2)
	if self._active then
		return
	end

	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and instance2:IsDescendantOf(character)) then
		return
	end

	self._reverse = instance.CFrame.LookVector:Dot(humanoidRootPart.AssemblyLinearVelocity.Unit) < 0
	local v2 = humanoidRootPart.CFrame:ToObjectSpace(instance.CFrame) + Vector3.new(0, 0, instance.Size.Z / 2)
	self._currentDistance = self:_GetDistanceToPoint((tonumber(instance.Name))) + v2.Z
	self._speed = instance2.AssemblyLinearVelocity.Magnitude
	self._active = true
	character:AddTag("Grinding")
end

function v:RenderSteppedUpdate(p: number)
	if not self._active then
		return
	end

	local character = Players.LocalPlayer.Character

	if not (character and character:FindFirstChild("HumanoidRootPart")) then
		return
	end

	local total = 0
	local v2 = nil

	for i = 1, #self.Instance:GetChildren() do
		local v3

		if self._reverse then
			v3 = #self.Instance:GetChildren() - i + 1
		else
			v3 = i
		end

		local child = self.Instance:FindFirstChild(v3)

		if not child then
			continue
		end

		if total + child.Size.Z > self._currentDistance then
			v2 = child
			break
		else
			total += child.Size.Z
		end
	end

	if not v2 or self._totalDistance < total then
		self:StopGrinding()
		return
	end

	local v3 = self._currentDistance - total
	local v4 = v2.CFrame * CFrame.new(0, 2, -v3 + v2.Size.Z / 2)

	if self._reverse then
		v4 = v2.CFrame * CFrame.new(0, 2, v3 - v2.Size.Z / 2) * CFrame.Angles(0, 3.141592653589793, 0)
	end

	local v5 = Grinding:FromInstance(character)

	if v5 then
		v5:SetPoint(v4)
	end

	self._currentDistance += self._speed * p
end

function v:StopGrinding()
	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	self._active = false
	self._currentDistance = 0
	character:RemoveTag("Grinding")
	task.delay(1, function()
		self._debounce = false
	end)
end

function v:_GetDistanceToPoint(p2: number)
	local total = 0

	for i = 1, p2 - 1 do
		local v2, child

		if self._reverse then
			v2 = #self.Instance:GetChildren() - i + 1

			if v2 <= p2 then
				break
			end
		else
			v2 = i
		end

		child = self.Instance:FindFirstChild(v2)

		if child then
			total += child.Size.Z
		end
	end

	return total
end

function v:Stop()
	self._Janitor:Destroy()
end

return v
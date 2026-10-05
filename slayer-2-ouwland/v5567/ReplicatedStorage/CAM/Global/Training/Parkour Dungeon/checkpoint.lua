local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local class = {}
class.__index = class
local tweenInfo = TweenInfo.new(4)
local tweenInfo2 = TweenInfo.new(0.5)

function class:Reset(p2)
	if self.Checkpoint == nil then
		return
	end

	if self.Tweens then
		for _, tween in self.Tweens do
			tween:Cancel()
		end

		table.clear(self.Tweens)
	end

	if not p2 then
		return
	end

	local flagMesh = self.Checkpoint.Flag:FindFirstChild("FlagMesh")
	local start = self.Checkpoint:GetAttribute("Start")

	if flagMesh and start then
		flagMesh.CFrame = start
	end

	local touchPart = self.Checkpoint:FindFirstChild("TouchPart")
	local mainAt = touchPart and touchPart:FindFirstChild("MainAt")

	if mainAt then
		local mainAtStart = self.Checkpoint:GetAttribute("MainAtStart")

		if mainAtStart then
			mainAt.CFrame = mainAtStart
		end

		local beam = mainAt:FindFirstChild("Beam")

		if beam then
			beam.Width0 = self.Checkpoint:GetAttribute("BeamWidth0") or 0
			beam.Width1 = self.Checkpoint:GetAttribute("BeamWidth1") or 0
		end

		local beam1 = mainAt:FindFirstChild("Beam1")

		if beam1 then
			beam1.Width0 = self.Checkpoint:GetAttribute("Beam1Width0") or 0
			beam1.Width1 = self.Checkpoint:GetAttribute("Beam1Width1") or 0
		end
	end
end

function class:Destroy()
	self:Reset(true)

	if self.Connections then
		for _, connection in self.Connections do
			connection:Disconnect()
		end

		self.Connections = nil
	end

	self.Tweens = nil
	setmetatable(self, nil)
end

function class:Open()
	local function track(p2, p3)
		if self.Tweens then
			if self.Tweens[p2] then
				self.Tweens[p2]:Cancel()
			end

			self.Tweens[p2] = p3
		end

		return p3
	end

	local flagMesh = self.Checkpoint:WaitForChild("Flag"):WaitForChild("FlagMesh")
	local start = self.Checkpoint:GetAttribute("Start")

	if start == nil then
		start = flagMesh.CFrame
		self.Checkpoint:SetAttribute("Start", start)
	end

	local mainAt = self.Checkpoint:WaitForChild("TouchPart"):WaitForChild("MainAt")
	mainAt:WaitForChild("Beam")
	mainAt:WaitForChild("Beam1")

	if self.Checkpoint:GetAttribute("MainAtStart") == nil then
		self.Checkpoint:SetAttribute("MainAtStart", mainAt.CFrame)
		self.Checkpoint:SetAttribute("BeamWidth0", mainAt.Beam.Width0)
		self.Checkpoint:SetAttribute("BeamWidth1", mainAt.Beam.Width1)
		self.Checkpoint:SetAttribute("Beam1Width0", mainAt.Beam1.Width0)
		self.Checkpoint:SetAttribute("Beam1Width1", mainAt.Beam1.Width1)
	end

	local tween = TweenService:Create(flagMesh, tweenInfo, {
		CFrame = start * CFrame.new(0, 8, 0)
	})

	if self.Tweens then
		if self.Tweens.Flag then
			self.Tweens.Flag:Cancel()
		end

		self.Tweens.Flag = tween
	end

	tween:Play()
	local tween2 = TweenService:Create(mainAt.Beam, tweenInfo2, {
		Width0 = 3
	})

	if self.Tweens then
		if self.Tweens.BeamW0 then
			self.Tweens.BeamW0:Cancel()
		end

		self.Tweens.BeamW0 = tween2
	end

	tween2:Play()
	local tween3 = TweenService:Create(mainAt.Beam, tweenInfo2, {
		Width1 = 3
	})

	if self.Tweens then
		if self.Tweens.BeamW1 then
			self.Tweens.BeamW1:Cancel()
		end

		self.Tweens.BeamW1 = tween3
	end

	tween3:Play()
	local tween4 = TweenService:Create(mainAt.Beam1, tweenInfo2, {
		Width0 = 3
	})

	if self.Tweens then
		if self.Tweens.Beam1W0 then
			self.Tweens.Beam1W0:Cancel()
		end

		self.Tweens.Beam1W0 = tween4
	end

	tween4:Play()
	local tween5 = TweenService:Create(mainAt.Beam1, tweenInfo2, {
		Width1 = 3
	})

	if self.Tweens then
		if self.Tweens.Beam1W1 then
			self.Tweens.Beam1W1:Cancel()
		end

		self.Tweens.Beam1W1 = tween5
	end

	tween5:Play()
	local tween6 = TweenService:Create(mainAt, tweenInfo2, {
		CFrame = CFrame.new(1.15, 0, 0)
	})

	if self.Tweens then
		if self.Tweens.MainAt then
			self.Tweens.MainAt:Cancel()
		end

		self.Tweens.MainAt = tween6
	end

	tween6:Play()
end

return function(instance, instance2, maid)
	local object = setmetatable({
		Checkpoint = instance,
		Connections = {},
		Tweens = {}
	}, class)
	maid:Add(task.spawn(function()
		object:Open()
		local v = tonumber(string.match(instance.Name, "%d+"))

		if not v then
			return
		end

		local child = instance.Parent:FindFirstChild("Checkpoint" .. v + 1)

		if not child then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function bind(part)
			if not part:IsA("BasePart") then
				return
			end

			table.insert(object.Connections, part.Touched:Connect(function(otherPart)
				local localPlayer = Players.LocalPlayer
				local character = localPlayer and localPlayer.Character

				if not (character and otherPart:IsDescendantOf(character)) then
					return
				end

				local checkpoint = instance2:GetAttribute("Checkpoint") or 0

				if v + 1 <= checkpoint then
					return
				end

				instance2:SetAttribute("Checkpoint", v + 1)
				local clone = script.CheckpointEffect:Clone()
				clone.Parent = workspace.Debree
				clone:PivotTo(CFrame.new(part.Position) * CFrame.new(0, -0.45, 0))
				Ouwmit.Emit(clone)
				DebrisModule:AddItem(clone, 1.5)
				local clone2 = script.Parent.Sounds.PS2checkpoint:Clone()
				clone2.Parent = part
				clone2:Play()
				DebrisModule:AddItem(clone2, 0)
			end))
		end

		local touchPart = child:FindFirstChild("TouchPart")

		if touchPart and touchPart:IsA("BasePart") then
			table.insert(object.Connections, touchPart.Touched:Connect(function(otherPart)
				local localPlayer = Players.LocalPlayer
				local character = localPlayer and localPlayer.Character

				if not (character and otherPart:IsDescendantOf(character)) then
					return
				end

				local checkpoint = instance2:GetAttribute("Checkpoint") or 0

				if v + 1 <= checkpoint then
					return
				end

				instance2:SetAttribute("Checkpoint", v + 1)
				local clone = script.CheckpointEffect:Clone()
				clone.Parent = workspace.Debree
				clone:PivotTo(CFrame.new(touchPart.Position) * CFrame.new(0, -0.45, 0))
				Ouwmit.Emit(clone)
				DebrisModule:AddItem(clone, 1.5)
				local clone2 = script.Parent.Sounds.PS2checkpoint:Clone()
				clone2.Parent = touchPart
				clone2:Play()
				DebrisModule:AddItem(clone2, 0)
			end))
		end

		table.insert(object.Connections, child.ChildAdded:Connect(function(child2)
			if child2.Name == "TouchPart" then
				bind(child2) -- equivalent call inferred; original call site unknown
			end
		end))
	end))
	return object
end
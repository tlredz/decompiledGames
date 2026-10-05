local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Util"))
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local chestConfiguration = ReplicatedStorage:WaitForChild("ChestConfiguration")
local ChestTypes = require(chestConfiguration:WaitForChild("ChestTypes"))
local ChestSettings = require(chestConfiguration:WaitForChild("ChestSettings"))
require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Flags"))
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local v = {
	[0] = {
		ShowName = true,
		Chests = {
			"DiamondChest",
			"FragChest",
			"SilverChest",
			"GoldChest",
			"MirageChest"
		},
		ShowColor = true,
		DisplayDistance = ChestSettings.STREAM.DISTANCE * 0.33
	}
}
local ClientChest = {}
ClientChest.__index = ClientChest

function ClientChest.new(serverChest, modelSource, container)
	assert(serverChest, "[Chests] No adornee when creating new Chest")
	assert(modelSource, "[Chests] Nonexistent model when creating new Chest")
	assert(container, "[Chests] No container when creating new Chest")
	return (setmetatable({
		ServerChest = serverChest,
		ModelSource = modelSource,
		Container = container,
		Highlighter = nil,
		Flag = 0,
		CanCollect = false,
		Model = nil,
		Node = nil,
		AttributeConnection = nil,
		TouchConnection = nil,
		AncestryConnection = nil,
		Opened = false
	}, ClientChest))
end

function ClientChest:Destroy()
	if self.Node ~= nil then
		self.Node:Destroy()
		self.Node = nil
	end

	if self.Model ~= nil then
		self.Model:Destroy()
		self.Model = nil
	end

	if self.AttributeConnection ~= nil then
		self.AttributeConnection:Disconnect()
		self.AttributeConnection = nil
	end

	if self.AncestryConnection ~= nil then
		self.AncestryConnection:Disconnect()
		self.AncestryConnection = nil
	end

	if self.TouchConnection then
		self.TouchConnection:Disconnect()
		self.TouchConnection = nil
	end

	self:Reflect()
end

function ClientChest:Open(p, character)
	if self.TouchConnection ~= nil then
		self.TouchConnection:Disconnect()
		self.TouchConnection = nil
	end

	self.Opened = true

	if self.Model then
		local animationController = self.Model:FindFirstChild("AnimationController")

		if animationController then
			local playingAnimationTracks = animationController:GetPlayingAnimationTracks()

			if #playingAnimationTracks > 0 then
				for _, playingAnimationTrack in ipairs(playingAnimationTracks) do
					playingAnimationTrack:Stop()
				end
			end
		end
	end

	Effect.new("Chests.Open"):play({
		ID = ChestTypes[self.ServerChest.Name].Index,
		Model = self.Model,
		Velocity = p or nil,
		Character = character
	})
	task.delay(3, function()
		if self.CanCollect then
			self.Opened = false
			warn(
				"[Chests] Opened",
				self.ServerChest:GetFullName(),
				"at",
				self.ServerChest.Position,
				"but the server never confirmed the pickup; no reward was granted"
			)
			self:RemoveModel()

			if self.AttributeConnection then
				self:CreateModel()
			end
		else
			local bottomWood = self.Model and self.Model:FindFirstChild("BottomWood")

			if bottomWood then
				local destroyingConnection = nil
				destroyingConnection = bottomWood.Destroying:Connect(function()
					Effect.new("Chests.Despawn"):play({
						CFrame = bottomWood.CFrame
					})
					destroyingConnection:Disconnect()
				end)
			end

			self:RemoveModel()
		end
	end)
	self:Reflect()
end

function ClientChest:Reflect()
	if self.Highlighter then
		self.Highlighter()
	end
end

function ClientChest:Connect()
	if not self.AttributeConnection then
		local isDisabled = self.ServerChest:GetAttribute("IsDisabled")

		if isDisabled then
			if isDisabled == true then
				self.CanCollect = false
			end
		else
			self.CanCollect = true
			self:CreateModel()
		end

		self.AttributeConnection = self.ServerChest.AttributeChanged:Connect(function(_)
			local isDisabled2 = self.ServerChest:GetAttribute("IsDisabled")

			if isDisabled2 then
				if isDisabled2 == true then
					self.CanCollect = false

					if not self.Opened then
						self:Open()
					end
				end
			else
				self.CanCollect = true
				self.Flag = 1
				self:CreateModel()
			end
		end)
	end

	if self.Highlighter == nil then
		local v2 = nil
		local magnitude = 1e999

		function self.Highlighter()
			if self.CanCollect and not self.Opened and self.Model and self.AttributeConnection then
				local chestDiscovery = localPlayer:GetAttribute("ChestDiscovery")

				if chestDiscovery == nil then
					if v2 then
						v2:destroy()
						v2 = nil
					end
				else
					local v3 = v[chestDiscovery] or v[0]

					if table.find(v3.Chests, self.Model.Name) then
						if localPlayer.Character and localPlayer.Character.PrimaryPart then
							magnitude = (localPlayer.Character.PrimaryPart.Position - self.ServerChest.Position).Magnitude
						end

						if magnitude > v3.DisplayDistance and v2 then
							v2:destroy()
							v2 = nil
						elseif magnitude <= v3.DisplayDistance and not v2 then
							local chestType = ChestTypes[self.ServerChest.Name]

							if not chestType then
								warn((`No chest config found with name: {self.ServerChest.Name}`))
							end

							local Observation = require(game.ReplicatedStorage.ObservationManager.Observation)
							local model = Observation.model
							local model2 = self.Model
							local color

							if v3.ShowColor then
								color = chestType.Color
							end

							v2 = model(model2, {
								Color = color,
								DisplayName = not v3.ShowName and "" or chestType.DisplayName
							})
						end
					elseif v2 then
						v2:Destroy()
						v2 = nil
					end
				end
			elseif v2 then
				v2:destroy()
				v2 = nil
			end
		end

		self.Highlighter()
	end
end

function ClientChest:Disconnect()
	if self.AttributeConnection ~= nil then
		self.AttributeConnection:Disconnect()
		self.AttributeConnection = nil
	end

	self:Reflect()
end

function ClientChest:CreateModel()
	if not self.Model then
		self.Opened = false
		local clone = self.ModelSource:Clone()
		self.Model = clone
		clone.Parent = self.Container
		clone:PivotTo(self.ServerChest.CFrame * CFrame.new(0, -0.9, 0))
		local children = clone:GetChildren()

		for _, part in ipairs(children) do
			if not part:IsA("BasePart") then
				continue
			end

			part.Massless = true
			part.CollisionGroup = "Chest"
			part.CanCollide = false
		end

		local clone2 = script.PushBox:Clone()
		clone2.CFrame = clone.PrimaryPart.CFrame
		clone2.CollisionGroup = "Chest"
		clone2.Parent = clone
		local weld = Instance.new("Weld")
		weld.Part0 = clone2
		weld.Part1 = clone.PrimaryPart
		weld.Parent = clone2
		weld.C0 = CFrame.new(0, -0.8, 0)
		clone:FindFirstChild("AnimationController"):LoadAnimation(clone.ChestIdle):Play()

		if not self.TouchConnection then
			self.TouchConnection = clone2.Touched:Connect(function(otherPart)
				local character = localPlayer.Character

				if character and character.Parent == workspace:FindFirstChild("Characters") and otherPart.Parent == character then
					if character:GetExtentsSize().Magnitude > 200 then
						return
					end

					local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
					self:Open(
						humanoidRootPart and humanoidRootPart.Velocity.Unit * (100 + 49900 * math.min(
							1,
							humanoidRootPart.Velocity.Magnitude / 200
						)),
						humanoidRootPart and humanoidRootPart.Parent
					)
				end
			end)
		end

		local function updateAncestry(instance)
			if instance == game.ReplicatedStorage.Unloaded or not instance or instance:IsDescendantOf(game.ReplicatedStorage.Unloaded) then
				self.Model.Parent = game.ReplicatedStorage.Unloaded
			elseif instance == workspace.Map or instance:IsDescendantOf(workspace.Map) then
				self.Model.Parent = self.Container
			end
		end

		updateAncestry(self.ServerChest.Parent)

		if not self.AncestryConnection then
			self.AncestryConnection = self.ServerChest.AncestryChanged:Connect(function(_, parent)
				if not self.Model then
					return
				end

				updateAncestry(parent)
			end)
		end
	end

	self:Reflect()
end

function ClientChest:RemoveModel()
	if self.Model ~= nil then
		self.Model:Destroy()
		self.Model = nil
	end

	if self.TouchConnection ~= nil then
		self.TouchConnection:Disconnect()
		self.TouchConnection = nil
	end

	if self.AncestryConnection ~= nil then
		self.AncestryConnection:Disconnect()
		self.AncestryConnection = nil
	end

	self:Reflect()
end

return ClientChest
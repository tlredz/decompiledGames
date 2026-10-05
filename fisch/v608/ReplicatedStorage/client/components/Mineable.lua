local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local Net = require(packages.Net)
local fx = require(ReplicatedStorage.shared.modules.fx)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
local remoteEvent = Net:RemoteEvent("MiningService/UpdateMineableState", -1)
local v = Component.new({
	Tag = "Mineable"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function shake(part)
	task.delay(0.4, function()
		if not (part and part.Parent) then
			return
		end

		local cFrame = part.CFrame
		local vector = Vector3.new(
			(math.random() - 0.5) * 0.3,
			(math.random() - 0.5) * 0.3,
			(math.random() - 0.5) * 0.3
		)
		local hitParticles = part:FindFirstChild("HitParticles")

		if hitParticles then
			for _, child in hitParticles:GetChildren() do
				if child:IsA("ParticleEmitter") then
					child:Emit(child:GetAttribute("EmitCount") or child.Rate)
				elseif child:IsA("Sound") then
					fx:PlaySound(child, part)
				end
			end
		end

		local tween = TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = cFrame * CFrame.new(vector)
		})
		tween.Completed:Once(function()
			if part and part.Parent then
				part.CFrame = cFrame
			end

			tween:Destroy()
		end)
		tween:Play()
	end)
end

function v:UpdateVisible(enabled: boolean, flag: boolean)
	local localTransparencyModifier = enabled and 0 or 1

	if not (enabled or flag) then
		task.wait(0.4)
	end

	self.part.LocalTransparencyModifier = localTransparencyModifier

	if self.Instance:GetAttribute("HideParent") and self.Instance.Parent then
		for _, instance in self.Instance.Parent:QueryDescendants("BasePart, Decal, ParticleEmitter, Beam, Light") do
			if instance:IsA("Light") then
				instance.Enabled = enabled
			else
				instance.LocalTransparencyModifier = localTransparencyModifier

				if instance:IsA("BasePart") then
					if instance:GetAttribute("OriginalCanCollide") == nil then
						instance:SetAttribute("OriginalCanCollide", instance.CanCollide)
					end

					instance.CanCollide = instance:GetAttribute("OriginalCanCollide") and enabled
				end
			end
		end
	end

	local destroyParticles = not enabled and not flag and self.part:FindFirstChild("DestroyParticles")

	if destroyParticles then
		for _, child in destroyParticles:GetChildren() do
			if child:IsA("ParticleEmitter") then
				child:Emit(child:GetAttribute("EmitCount") or child.Rate)
				child.LocalTransparencyModifier = 0
			elseif child:IsA("Sound") then
				fx:PlaySound(child, self.part)
			end
		end
	end
end

function v:UpdateHealth(p: number?, flag: boolean)
	self:UpdateVisible(p == nil or p > 0, flag)

	if p ~= nil and p > 0 and not flag then
		shake(self.part) -- equivalent call inferred; original call site unknown
	end
end

function v:Construct()
	self.trove = Trove.new()
	self.part = self.Instance
	self.mineableType = self.part:GetAttribute("MineableType")
	self.mineableId = self.part:GetAttribute("MineableId")
	self.initialLoaded = false
end

function v:Start()
	playerDataReplicator:WaitForLoaded()

	if self.part:GetAttribute("PersistState") then
		self.trove:Add(playerDataReplicator:Observe({
			"Mineables",
			"Health",
			self.mineableType,
			self.mineableId
		}, function(p)
			self:UpdateHealth(p, not self.initialLoaded)
			self.initialLoaded = true
		end))
		return
	end

	self.initialLoaded = true
	self.trove:Add(remoteEvent.OnClientEvent:Connect(function(p: string, p2: number)
		if p ~= self.mineableId then
			return
		end

		self:UpdateHealth(p2, false)
	end))
end

function v.Stop(p)
	p.trove:Destroy()
end

return v
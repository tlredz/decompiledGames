local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
require(packages.Net)
local fx = require(ReplicatedStorage.shared.modules.fx)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
require(ReplicatedStorage.shared.utils.FischUtils)
local v = Component.new({
	Tag = "TidefallObelisk",
	Ancestors = { Workspace },
	Extensions = nil
})

function v:Construct()
	self.trove = Trove.new()
	self.id = self.Instance:GetAttribute("UID")
end

function v:Activate(flag: boolean)
	if self.active then
		return
	end

	self.active = true

	for _, child in self.Instance.Base:GetChildren() do
		if child:IsA("Beam") or child:IsA("Light") then
			child.Enabled = true
		elseif child:IsA("Sound") then
			child:Play()
		end
	end

	if flag then
		TweenService:Create(self.Instance.Chain, TweenInfo.new(2, Enum.EasingStyle.Linear), {
			LocalTransparencyModifier = 1
		}):Play()

		for _, child in self.Instance.Base.ActivateParticles:GetChildren() do
			if child:IsA("ParticleEmitter") then
				child:Emit(child.Rate)
			elseif child:IsA("BillboardGui") then
				child.Enabled = true
				child.FlashImg.ImageTransparency = 0
				TweenService:Create(child.FlashImg, TweenInfo.new(1, Enum.EasingStyle.Linear), {
					ImageTransparency = 1
				}):Play()
			end
		end

		fx:PlaySound(script.Activate1, self.Instance.PrimaryPart, false)
		fx:PlaySound(script.Activate2, self.Instance.PrimaryPart, false)
		task.wait(0.5)
	else
		self.Instance.Chain.LocalTransparencyModifier = 1
	end

	for _, part in self.Instance.Main:GetChildren() do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end

	local v2 = 0
	self.trove:Add(RunService.RenderStepped:Connect(function(dt)
		local primaryPart = self.Instance.PrimaryPart

		if not primaryPart then
			return
		end

		local magnitude = (workspace.CurrentCamera.CFrame.Position - primaryPart.Position).Magnitude

		if magnitude > 256 then
			return
		end

		local v3 = primaryPart:GetAttribute("OriginalCFrame") * CFrame.new(0, math.sin((time())) * 3 + 5, 0)
		local smoothDamp, v4 = TweenService:SmoothDamp(primaryPart.CFrame, v3, v2, 0.5, nil, dt)
		primaryPart.CFrame = smoothDamp
		v2 = v4
		self.Instance.Base.Glow2.LocalTransparencyModifier = 1 - math.clamp(magnitude / 64, 0, 1)
	end))
end

function v:Start()
	self.active = false
	self.trove:Add(playerDataReplicator:Observe({ "Tidefall", "Obelisks", "Activated" }, function(p, p2)
		if p and p[self.id] then
			self:Activate(p2 ~= nil)
		end
	end))
end

function v.Stop(p)
	p.trove:Clean()
end

task.spawn(function()
	playerDataReplicator:WaitForLoaded()
	playerDataReplicator:Observe({ "Tidefall", "Obelisks", "GateOpen" }, function(p, _)
		if p then
			local CollectionService = game:GetService("CollectionService")

			for _, v2 in CollectionService:GetTagged("TidefallGate") do
				v2:Destroy()
			end

			CollectionService:GetInstanceAddedSignal("TidefallGate"):Connect(function(instance)
				instance:Destroy()
			end)
		end
	end)
end)
return v
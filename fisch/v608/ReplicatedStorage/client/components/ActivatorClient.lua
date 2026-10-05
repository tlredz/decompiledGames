local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
game:GetService("TweenService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Net = require(packages:WaitForChild("Net"))
local Trove = require(packages:WaitForChild("Trove"))
local Component = require(packages:WaitForChild("Component"))
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local modules = ReplicatedStorage.shared.modules
local activators = require(modules:WaitForChild("library"):WaitForChild("activators"))
local mutations = require(modules:WaitForChild("fishing"):WaitForChild("mutations"))
local shared = ReplicatedStorage:WaitForChild("shared")
local assets = require(shared.utils.assets)
local localPlayer = Players.LocalPlayer
local _ = {
	Min = -1.5,
	Max = 1.5
}
TweenInfo.new(1, Enum.EasingStyle.Quint)
local remoteEvent = Net:RemoteEvent("ActivatorClientActive", -1)
local remoteEvent2 = Net:RemoteEvent("ActivatorClientDisable", -1)
local v = Component.new({
	Tag = "ActivatorClient"
})

local function GetCharacter(player)
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		return character, humanoidRootPart
	end
end

function v:RenderSteppedUpdate(p: number)
	local now = os.clock()

	if self.model then
		local cFrame = self.model.handle.CFrame
		self.model.handle.CFrame = cFrame * CFrame.new(0, math.cos((tick())) * 0.8 * p, 0) * CFrame.Angles(
			0,
			p * 0.2617993877991494,
			0
		)
	end

	self.lastCheck = self.lastCheck or now - 1

	if now - self.lastCheck < 1 then
		return
	end

	self.lastCheck = now
	local activator = activators[self.Instance.Name]
	local enabled = self.enabled ~= true

	if enabled == true then
		local character = localPlayer.Character
		local humanoidRootPart

		if character then
			humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				character = nil
				humanoidRootPart = nil
			end
		else
			character = nil
		end

		if character and (humanoidRootPart.Position - self.Instance.Root.Position).Magnitude <= 12 then
			local tool = character:FindFirstChildOfClass("Tool")

			if tool and table.find(activator.PlaceableItems, tool.Name) then
				if activator.SubValues then
					local itemFromLink = DataController.getItemFromLink(tool)

					for k, subValue in activator.SubValues do
						if not (not itemFromLink.sub[k] or subValue ~= itemFromLink.sub[k]) then
							continue
						end

						enabled = false
						break
					end
				end

				local _ = tool.Name
			else
				enabled = false
			end
		else
			enabled = false
		end
	end

	self.Instance.Root.Prompt.Enabled = enabled
	self.Instance.Root.Prompt.ObjectText = "Active"
end

function v:Toggle(enabled: boolean)
	if self.enabled == enabled then
		return
	end

	self.enabled = enabled

	for _, descendant in self.Instance:GetDescendants() do
		local activeEffect = descendant:GetAttribute("ActiveEffect")
		local activatedEffect = descendant:GetAttribute("ActivatedEffect")

		if descendant:IsA("PointLight") then
			if activatedEffect then
				descendant.Enabled = enabled
			end
		elseif descendant:IsA("Sound") then
			if enabled == true then
				descendant:Play()
			end
		elseif descendant:IsA("ParticleEmitter") then
			if enabled == true then
				if activeEffect and true == true then
					local emitCount = descendant:GetAttribute("EmitCount") or 1
					local emitDelay = descendant:GetAttribute("EmitDelay") or 0
					local v2 = descendant
					task.delay(emitDelay, function()
						v2:Emit(emitCount)
					end)
				elseif activatedEffect then
					descendant.Enabled = true
				end
			else
				descendant.Enabled = false
			end
		end
	end
end

function v:DestroyItem()
	if self.model then
		self.model:Destroy()
		self.model = nil
	end

	self.placedItem = nil
end

function v:BuildItem(p: string)
	local async = assets.getAsync("fish", p)
	local subValues = activators[self.Instance.Name].SubValues

	if async then
		self.model = async:Clone()
		self.model.Parent = self.Instance
		self.model.handle.Anchored = true

		if subValues and subValues.Mutation then
			mutations:MutateModel(self.model, subValues.Mutation, subValues)
		end

		for _, part in self.model:GetDescendants() do
			if not (part:IsA("BasePart") or part:IsA("MeshPart")) then
				continue
			end

			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
		end

		self.model.handle.CFrame = self.Instance.Root.CFrame * CFrame.new(0, 1, 0)
		self.direction = -1
		self.trove:Add(self.model)
	end
end

function v:Construct()
	self.trove = Trove.new()
	self.enabled = false
end

function v:Start()
	self.placedItem = self.Instance:GetAttribute("PlacedItem")

	if self.placedItem then
		self:BuildItem(self.placedItem)
	end

	local prompt = self.Instance.Root.Prompt
	self.trove:Add(prompt.Triggered:Connect(function()
		remoteEvent:FireServer(self.Instance.Name)
	end))
	self.trove:Add(remoteEvent.OnClientEvent:Connect(function(p: string, p2: string?)
		if p ~= self.Instance.Name then
			return
		end

		self:DestroyItem()

		if p2 then
			self:BuildItem(p2)
		end

		self:Toggle(true)
	end))
	self.trove:Add(remoteEvent2.OnClientEvent:Connect(function(p: string)
		if p ~= self.Instance.Name then
			return
		end

		self:DestroyItem()
		self:Toggle(false)
	end))
end

function v.Stop(p)
	p.trove:Destroy()
end

return v
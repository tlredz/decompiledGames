local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local Net = require(packages.Net)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local remoteFunction = Net:RemoteFunction("ItemCollectorCollect", -1)
local _ = Players.LocalPlayer
local v = Component.new({
	Tag = script.Name
})

function v.RenderSteppedUpdate(p, p2: number)
	if p.Instance:FindFirstChild("Builds") then
		p.Instance.Root.CFrame *= CFrame.Angles(0, math.rad(p2 * 10), 0)
	end
end

function v:Collect()
	for _, descendant in self.Instance:GetDescendants() do
		if descendant:IsA("Sound") then
			descendant:Play()
		elseif descendant:IsA("ParticleEmitter") then
			local emitCount = descendant:GetAttribute("EmitCount") or 1
			local emitDelay = descendant:GetAttribute("EmitDelay") or 0

			if emitDelay > 0 then
				local v2 = descendant
				local v3 = emitCount
				task.delay(emitDelay, function()
					v2:Emit(v3)
				end)
			else
				descendant:Emit(emitCount)
			end
		end
	end
end

function v:TogglePrompt(enabled: boolean)
	self.Instance.Root.Prompt.Enabled = enabled
end

function v:DestroyModel()
	local builds = self.Instance:FindFirstChild("Builds")

	if builds then
		builds:Destroy()
	end
end

function v:CheckIfHasItem(p: string, p2: string)
	if p2 ~= "Rod" then
		return true
	end

	local _, v2 = legacyLocalPlayerData.fetch()

	if v2.Data.NewFormat.rod[p] then
		return true
	end

	return false
end

function v:Construct()
	self.itemName = self.Instance:GetAttribute("ItemName")
	self.itemType = self.Instance:GetAttribute("ItemType")
	self.style = self.Instance:GetAttribute("Style") or "Default"
	self.trove = Trove.new()
end

function v:Start()
	if v:CheckIfHasItem(self.itemName, self.itemType) == true then
		self:DestroyModel()
		self:TogglePrompt(false)
	else
		self:TogglePrompt(true)
	end

	local prompt = self.Instance.Root.Prompt
	self.trove:Add(prompt.Triggered:Connect(function()
		if remoteFunction:InvokeServer(self.itemName) == true then
			self:Collect()
			self:DestroyModel()
			self:TogglePrompt(false)
		end
	end))
end

function v.Stop(p)
	p.trove:Destroy()
end

return v
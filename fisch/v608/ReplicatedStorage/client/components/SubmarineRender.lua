local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages.Component)
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local Timer = require(packages.Timer)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local legacyControllers = ReplicatedStorage.client.legacyControllers
local NotificationController = require(legacyControllers.NotificationController)
local localPlayer = Players.LocalPlayer
local submarine = legacyLocalPlayerData.fetch():WaitForChild("Cache"):WaitForChild("Submarine", 9000000000)
local crafted = submarine:WaitForChild("Crafted")
local skin = submarine:WaitForChild("Skin")
local v = {
	"Back Fins",
	"Submarine Top",
	"Metal Panels",
	"Side Fins",
	"Windows"
}
local remoteEvent = Net:RemoteEvent("SubmarineCraftService/PlacePart")
local v2 = Component.new({
	Tag = "SubmarineRender"
})

local function HasPartInHand()
	local character = localPlayer.Character

	if not character then
		return false
	end

	local tool = character:FindFirstChildOfClass("Tool")

	if not (tool and table.find(v, tool.Name) ~= nil == true) then
		return false
	end

	return not table.find(string.split(crafted.Value, "."), tool.Name)
end

function v2:RunVfx()
	local sound = self.Instance:WaitForChild("Hitbox"):WaitForChild("Sound")
	local particleEmitter = self.Instance:WaitForChild("Hitbox"):WaitForChild("ParticleEmitter")
	sound:Play()
	particleEmitter:Emit(35)
end

function v2:UpdateVisuals()
	local marianasVeilActive = workspace:GetAttribute("MarianasVeilActive") == true
	local v3 = string.split(crafted.Value, ".")
	local v4 = #v3 == #v

	if v4 then
		for _, folder in self.Instance:WaitForChild("Skins"):GetChildren() do
			for _, part in folder:GetDescendants() do
				if part:IsA("BasePart") then
					part.Transparency = skin.Value ~= folder.Name and 1 or part:GetAttribute("DefaultTransparency") or 0
				end
			end
		end

		local obsidianRockChances = workspace:FindFirstChild("ObsidianRockChances")

		if obsidianRockChances then
			obsidianRockChances:Destroy()
		end
	else
		for _, part in self.Instance:WaitForChild("Skins"):WaitForChild("Common"):GetDescendants() do
			if part:IsA("BasePart") then
				part.Transparency = table.find(v3, part.Name) == nil and 0.75 or part:GetAttribute("DefaultTransparency") or 0
			end
		end
	end

	local resources = self.Resources
	resources.Enabled = marianasVeilActive == true and (not v4 or false)

	if self.Resources.Enabled == true then
		local total = 0

		for _, frame in self.Resources.Main.List:GetChildren() do
			if not frame:IsA("Frame") then
				continue
			end

			local visible = table.find(v3, frame.Name) ~= nil
			frame.Checkmark.Visible = visible
			total += visible and 1 or 0
		end

		self.Resources.Main.Amount.Text = `{total}/{#v}`
	end
end

function v2:Construct()
	self.Trove = Trove.new()
	self.PlacePrompt = self.Instance:WaitForChild("Hitbox"):WaitForChild("Attachment"):WaitForChild("PlacePrompt")
	self.Resources = self.Instance:WaitForChild("Hitbox"):WaitForChild("Resources")
end

function v2:Start()
	local v3 = Timer.new(1)
	self.Trove:Add(v3.Tick:Connect(function()
		self.PlacePrompt.Enabled = HasPartInHand()
	end))
	self.Trove:Add(v3, "Destroy")
	v3:Start()
	self.Trove:Add(self.PlacePrompt.Triggered:Connect(function()
		remoteEvent:FireServer()
	end))
	self.Trove:Add(crafted.Changed:Connect(function()
		self:RunVfx()
		task.wait(1)

		if #string.split(crafted.Value, ".") == #v then
			NotificationController:Notify(
				"Maybe I should talk to <font color=\"rgb(255,0,0)\">Dr. Glimmerfin</font> now that the submarine is finished?!",
				10,
				"itemgetold"
			)
		end

		self:UpdateVisuals()
	end))
	self.Trove:Add(skin.Changed:Connect(function()
		self:UpdateVisuals()
	end))
	self.Trove:Add(workspace:GetAttributeChangedSignal("MarianasVeilActive"):Connect(function()
		self:UpdateVisuals()
	end))
	self:UpdateVisuals()
end

function v2.Stop(p)
	p.Trove:Destroy()
end

return v2
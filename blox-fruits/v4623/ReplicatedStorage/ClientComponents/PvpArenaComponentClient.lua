local RunService = game:GetService("RunService")

if RunService:IsServer() then
	return {}
end

local Component = require(game.ReplicatedStorage.Modules.Component)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local IrisLog = require(game.ReplicatedStorage.Util.IrisLog)
local pvpDirector = IrisLog.new("PvpDirector", 2, {
	Hidden = true
})
pvpDirector:getLogAppendWrapper(script, true)
pvpDirector:getLogPcallWrapper(script)
local v = Component.new({
	Tag = "PvpArena2v2",
	Ancestors = { workspace:FindFirstChild("PVPArenas") }
})
local _ = game.Players.LocalPlayer

local function setAttributeHandler(state, attributeName: string, fn)
	state.Maid:GiveTask(state.Instance:GetAttributeChangedSignal(attributeName):Connect(function()
		fn(state.Instance:GetAttribute(attributeName))
	end))
	fn(state.Instance:GetAttribute(attributeName))
end

function v:Start()
	self.Maid = Maid.new()
	self.AttachmentRootPart = self.Instance:WaitForChild("AttachmentRoot")
	self.AttachmentRoot = self.AttachmentRootPart:WaitForChild("Attachment")
	self.TeamAttachments = {}

	for _, child in self.AttachmentRoot:GetChildren() do
		table.insert(self.TeamAttachments, child)
	end

	self.RegistryPointsAttachment = self.AttachmentRootPart:WaitForChild("RegistryPoints")
	self.RegistryPoints = {}
	self.DecodedPlayers = nil
	local boundingBox, boundingSize = self.Instance:GetBoundingBox()
	self.BoundingCFrame = boundingBox
	self.BoundingSize = boundingSize
	self.BoundingMagnitude = self.BoundingSize.Magnitude * 1.2
	setAttributeHandler(self, "EncodedPlayerData", function(json)
		if not json then
			self.DecodedPlayers = nil
			return
		end

		local HttpService = game:GetService("HttpService")
		local jSONDecode = HttpService:JSONDecode(json)
		self.DecodedPlayers = {}

		for _, v3 in jSONDecode do
			local child = game.Players:FindFirstChild(v3.Name)

			if child then
				self.DecodedPlayers[child] = v3
			end
		end
	end)
end

function v.Stop(p)
	p.Maid:Destroy()
end

return v
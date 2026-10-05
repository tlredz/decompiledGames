local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Emit = require(ReplicatedStorage.UserGenerated.VFX.Emit)

local function PlayVFX(parent, cframe: CFrame, folder)
	local attachment = Instance.new("Attachment")
	attachment.CFrame = parent.CFrame:ToObjectSpace(cframe)

	for _, emitter in ipairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Parent = attachment
		end
	end

	if folder:IsA("ParticleEmitter") then
		folder.Parent = attachment
	else
		folder:Destroy()
	end

	attachment.Parent = parent
	Debris:AddItem(attachment, Emit(attachment))
end

return PlayVFX
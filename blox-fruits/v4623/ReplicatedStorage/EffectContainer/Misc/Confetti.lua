local Debris = require(game.ReplicatedStorage.Util.Debris)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local IndexUtil = require(game.ReplicatedStorage.Packages.IndexUtil)
local clones = {}
local v = false
return function()
	local clone = IndexUtil.matchPath("ReplicatedStorage/Assets/Particles/Confetti"):unwrap():Clone()
	assert(clone:IsA("BasePart"), (`bad basePart: "{clone.ClassName}"`))
	clone.Parent = workspace._WorldOrigin
	clone.CFrame = workspace.CurrentCamera.CFrame * CFrame.new(0, -2.5, -5)
	local attachment = clone:FindFirstChild("Attachment")
	assert(attachment, "bad attachment")

	for _, emitter in pairs(attachment:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(6)
		end
	end

	Debris:AddItem(clone, 4, function()
		local index = table.find(clones, clone)

		if index then
			table.remove(clones, index)
		end
	end)
	table.insert(clones, clone)

	if not v then
		v = true
		local RunService = game:GetService("RunService")
		RunService:BindToRenderStep("ConfettiFollow", Enum.RenderPriority.Camera.Value + 10, function()
			local flag = true

			for _, v2 in pairs(clones) do
				v2.CFrame = workspace.CurrentCamera.CFrame * CFrame.new(0, -2.5, -5)
				flag = false
			end

			if flag then
				v = false
				local RunService2 = game:GetService("RunService")
				RunService2:UnbindFromRenderStep("ConfettiFollow")
			end
		end)
	end

	Sound:Play("Horn", workspace.CurrentCamera.CFrame.p)
	Sound:Play("Confetti", workspace.CurrentCamera.CFrame.p)
end
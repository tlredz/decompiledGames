local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local TweenService = game:GetService("TweenService")

function BurnItem(instance)
	if instance:GetAttribute("Burning") then
		return
	end

	instance.Archivable = true
	local clone = instance:Clone()
	instance:SetAttribute("Burning", true)
	clone:SetAttribute("Destroyed", true)
	instance.Parent = game.ReplicatedStorage.TempStorage

	for k in pairs(clone:GetAttributes()) do
		clone:SetAttribute(k, nil)
	end

	clone:RemoveTag("Interaction")
	local tweenInfo = TweenInfo.new(0.5)

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Color = Color3.fromRGB(48, 48, 48)
			descendant.Anchored = false
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			TweenService:Create(descendant, tweenInfo, {
				Transparency = 1
			}):Play()
		elseif descendant:IsA("Decal") then
			TweenService:Create(descendant, tweenInfo, {
				Transparency = 1
			}):Play()
		end
	end

	local primaryPart = clone.PrimaryPart
	local v = nil

	if primaryPart then
		for _, child in pairs(game.ReplicatedStorage.Assets.Particles.FireParticles:GetChildren()) do
			local clone2 = child:Clone()
			clone2.Parent = primaryPart

			if clone2:IsA("Highlight") then
				v = clone2
				clone2.Adornee = clone
				TweenService:Create(v, tweenInfo, {
					FillTransparency = 1
				}):Play()
			elseif clone2:IsA("ParticleEmitter") then
				local v2 = clone2
				task.delay(0.5, function()
					v2.Enabled = false
				end)
			end
		end

		local attachment = Instance.new("Attachment", primaryPart)
		local linearVelocity = Instance.new("LinearVelocity")
		linearVelocity.Attachment0 = attachment
		linearVelocity.VectorVelocity = createVector(0, 3, 0)
		linearVelocity.MaxForce = 1e999
		linearVelocity.Parent = primaryPart
		local angularVelocity = Instance.new("AngularVelocity")
		angularVelocity.Attachment0 = attachment
		angularVelocity.MaxTorque = 1e999
		angularVelocity.Parent = primaryPart
	end

	task.delay(0.75, function()
		if v then
			v.Adornee = nil
			v:Destroy()
		end

		task.wait(4)
		clone:Destroy()
	end)
	clone.Parent = workspace.Particles
	return function()
		task.delay(1, function()
			if instance.Parent then
				instance:SetAttribute("Burning", nil)
				instance.Parent = workspace.Items
			end
		end)
	end
end

local LavaClient = {
	BurnItem = BurnItem
}
Client.Events.LavaBurnItem:Connect(BurnItem)

function LavaAdded(instance)
	if instance:GetAttribute("NoItemBurning") then
		return
	end

	instance.Touched:Connect(function(otherPart)
		local parent = otherPart.Parent

		if not parent or parent:HasTag("Obsidiron") or parent:GetAttribute("NotBurnable") then
			return
		end

		if instance:GetAttribute("Volcano") and (parent == localPlayer.Character or parent:GetAttribute("PlayerBody") == localPlayer.UserId) then
			print("is player body")
			BurnItem(parent)
			parent:Destroy()
			Client.Events.RequestLavaBurnItem:InvokeServer(parent, instance)
		else
			if parent:GetAttribute("NotAttackable") or not parent:GetAttribute("InteractedWith") or parent.Parent ~= workspace.Items and parent.Parent ~= workspace.Characters then
				return
			end

			local v = (parent:GetAttribute("Owner") == nil or parent:GetAttribute("Owner") == localPlayer.UserId) and parent:GetAttribute("Interaction") and BurnItem(parent)

			if v then
				if parent:GetAttribute("Owner") == localPlayer.UserId then
					Client.Sound.Play("BurnItem", {
						Volume = 0.4,
						Replicate = true,
						ReplicationProperties = {
							Instance = localPlayer.Character.Head,
							Volume = 0.3
						}
					})
				end

				local v2 = Client.Events.RequestLavaBurnItem:InvokeServer(parent, instance)

				if not (v2 and v2.Success) then
					v()
				end
			end
		end
	end)
end

function LavaClient.Init()
	Client.Utility.ForAllTagged("OnFirePart", LavaAdded)
end

return LavaClient
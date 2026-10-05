local Component = require(game.ReplicatedStorage.Modules.Component)
local v = Component.new({
	Tag = "ConsumableTool",
	Ancestors = { workspace, game.Players }
})
local v2 = {
	["Lava Potion"] = {
		IdleAnimation = "BigPotionIdle"
	},
	["Aggro Elixir"] = {
		IdleAnimation = "BigPotionIdle"
	},
	["Walter Walking"] = {
		IdleAnimation = "BigPotionIdle"
	},
	["Fragments Elixir"] = {
		IdleAnimation = "SmallPotionIdle"
	}
}

function v:Construct()
	self._Destroyed = false
end

function v:Start()
	local instance = self.Instance
	local activatedConnection = nil
	instance.Equipped:Connect(function()
		activatedConnection = instance.Activated:Connect(function()
			instance:FindFirstChild("ConsumeEvent"):InvokeServer("Display")
		end)
	end)
	instance.Unequipped:Connect(function()
		if activatedConnection and activatedConnection.Connected then
			activatedConnection:Disconnect()
			activatedConnection = nil
		end
	end)
	local consumable

	if instance:FindFirstChild("Consumable") then
		consumable = instance:FindFirstChild("Consumable") or instance
	else
		consumable = instance
	end

	local animationController = consumable:WaitForChild("AnimationController", 5)

	if self._Destroyed then
		return
	end

	local track = nil

	if animationController then
		local idleAnimation = v2[instance.Name] and v2[instance.Name].IdleAnimation
		local raw = nil
		local idle = consumable:FindFirstChild("Idle")

		if idle and idle:IsA("Animation") then
			raw = idle
		elseif idleAnimation then
			local Anims = require(game.ReplicatedStorage.Util.Anims)
			raw = Anims:GetRaw(idleAnimation)
		end

		if raw and raw.AnimationId == nil then
			warn((`{self.Instance.Name} missing AnimationId`))
		elseif raw then
			track = animationController:LoadAnimation(raw)
		end
	end

	if track then
		local function onAncestryChanged()
			if instance.Parent then
				if instance.Parent:IsA("Model") or instance.Parent == workspace then
					if track then
						track:Play()
					end
				elseif track then
					track:Stop()
				end
			elseif track then
				track:Stop()
			end
		end

		instance.AncestryChanged:Connect(onAncestryChanged)
		onAncestryChanged()
	end
end

function v:Stop()
	self._Destroyed = true
end

return v
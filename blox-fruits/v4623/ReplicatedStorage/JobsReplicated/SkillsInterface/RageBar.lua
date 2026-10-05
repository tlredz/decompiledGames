return function(p)
	local rage = p.Rage
	local mobileRage = game.Players.LocalPlayer.PlayerGui:WaitForChild("HUDNoInset", 999):WaitForChild("MobileRage")
	local MobileUIController = require(game.ReplicatedStorage.Controllers.UI.MobileUIController)
	local isNewUIEnabled = MobileUIController:IsNewUIEnabled()
	local connection = nil
	local activeSkillChangedConnection = nil
	local activeSkillStartChangedConnection = nil
	local activeSkillEndChangedConnection = nil
	local v = {
		ResizeBars = function()
			rage.Bar.Size = UDim2.fromScale(1, 0.2)
			mobileRage.Bar.Size = UDim2.fromScale(1, 0.3)
		end,
		SetVisible = function(flag: boolean?)
			mobileRage.Visible = flag and isNewUIEnabled or false
			rage.Visible = flag and not isNewUIEnabled or false
		end,
		Disconnect = function()
			if connection then
				connection:Disconnect()
				connection = nil
			end
		end,
		SetMoodLineEnabled = function(flag: boolean?)
			rage.Ticks.MoodLine.Visible = flag and not isNewUIEnabled or false
		end,
		SetTicksEnabled = function(flag: boolean?)
			for _, child in rage.Ticks:GetChildren() do
				child.Visible = flag or false
			end

			for _, child in mobileRage.Ticks:GetChildren() do
				child.Visible = flag or false
			end
		end,
		SetText = function(text: string)
			rage.Text = text
		end,
		SetColors = function(backgroundColor: Color3, color: Color3?)
			rage.TextColor3 = color or Color3.new(1, 1, 1)
			rage.Bar.BackgroundColor3 = backgroundColor
		end
	}

	function v.DisableAll()
		v.Disconnect()
		rage.Black.Trans.Visible = false
		mobileRage.Bar.Trans.Visible = false
		rage.Bar.UIGradient.Enabled = false
		mobileRage.Bar.UIGradient.Enabled = false
		v.SetTicksEnabled(true)
		v.SetMoodLineEnabled(false)
		rage.Visible = true
	end

	function v.SkillActivated(_) end

	function v.SyncToSkillActivated(instance)
		-- equivalent calls inferred from this helper; original call sites unknown
		local function onActiveSkillChanged(p2: string?)
			if p2 then
				rage.Fire:SetAttribute("ParticleEnabled", instance:GetAttribute("JobId"))
			else
				rage.Fire:SetAttribute("ParticleEnabled", nil)
			end
		end

		activeSkillChangedConnection = instance:GetAttributeChangedSignal("ActiveSkill"):Connect(function()
			if instance:GetAttribute("ActiveSkill") then
				onActiveSkillChanged(true) -- equivalent call inferred; original call site unknown
			else
				onActiveSkillChanged(false) -- equivalent call inferred; original call site unknown
			end
		end)

		if instance:GetAttribute("ActiveSkill") then
			onActiveSkillChanged(true) -- equivalent call inferred; original call site unknown
		else
			onActiveSkillChanged(false) -- equivalent call inferred; original call site unknown
		end

		activeSkillStartChangedConnection = instance:GetAttributeChangedSignal("ActiveSkillStart"):Connect(function()
			instance:GetAttribute("ActiveSkillStart")
		end)
		activeSkillEndChangedConnection = instance:GetAttributeChangedSignal("ActiveSkillEnd"):Connect(function()
			instance:GetAttribute("ActiveSkillEnd")
		end)
	end

	function v.ConnectUpdate(object, callback, p2)
		v.Disconnect()
		connection = object:Connect(function()
			local v2 = callback()

			if v2 then
				rage.Bar.Size = UDim2.new(v2 / 100, 0, 0.2, 0)
			end
		end)

		if p2 then
			rage.Bar.Size = UDim2.new(p2 / 100, 0, 0.2, 0)
		end
	end

	return v
end
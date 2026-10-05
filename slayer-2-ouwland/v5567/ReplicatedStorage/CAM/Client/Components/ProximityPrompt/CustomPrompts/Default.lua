require(game.ReplicatedStorage.Packages.faye)
local Config = require(script.Parent.Config)
local KeyHolder = require(script.KeyHolder)
local random = Random.new()
local Holder = require(script.Holder)
local HoldPress = require(script.Parent.HoldPress)
return function(parent, instance, p2, object)
	local function GetText()
		local actionText = instance.ActionText
		local objectText = instance.ObjectText

		if actionText ~= "" and objectText ~= "" then
			return {
				Primary = objectText,
				Secondary = actionText
			}
		end

		if actionText == "" then
			return objectText
		end

		return actionText
	end

	local v = {
		KeyHolder = {
			State = object:Value(1),
			Rotation = object:Value(0)
		},
		HolderStates = 0,
		Triggered = 0
	}
	local holderStates = {
		State = object:Value(1),
		Text = 0
	}
	local actionText = instance.ActionText
	local objectText = instance.ObjectText

	if actionText == "" or objectText == "" then
		if actionText ~= "" then
			objectText = actionText
		end
	else
		objectText = {
			Primary = objectText,
			Secondary = actionText
		}
	end

	holderStates.Text = object:Value(objectText)
	v.HolderStates = holderStates
	v.Triggered = object:Value(1)

	local function UpdateText()
		local text = v.HolderStates.Text
		local actionText2 = instance.ActionText
		local objectText2 = instance.ObjectText

		if actionText2 == "" or objectText2 == "" then
			if actionText2 ~= "" then
				objectText2 = actionText2
			end
		else
			objectText2 = {
				Primary = objectText2,
				Secondary = actionText2
			}
		end

		text:Set(objectText2)
	end

	object:Connect(instance:GetPropertyChangedSignal("ActionText"), UpdateText)
	object:Connect(instance:GetPropertyChangedSignal("ObjectText"), UpdateText)
	local coolDown = instance:GetAttribute("CoolDown") or Config.CoolDown
	object:Create("TextButton")({
		Parent = parent,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.8, 0.8),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		object:Create("UIListLayout")({
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0.025, 0)
		}),
		KeyHolder(object, v.KeyHolder, instance, p2, v.Triggered),
		Holder(
			object,
			v.HolderStates,
			instance,
			v.Triggered,
			instance:GetAttribute("ActionImage") or Config.ActionToImages[instance.ActionText]
		),
		InputBegan = HoldPress(object, instance)
	})
	local v3 = nil
	local v4 = false
	local v5 = 0
	local holdDuration = instance.HoldDuration

	local function stateManager()
		local v6 = 1
		local number = random:NextNumber(1, 999)
		v5 = number

		if v4 == true then
			object:Spawn(function()
				local lastTime = os.clock()

				while number == v5 do
					local v7 = math.clamp((os.clock() - lastTime) / holdDuration, 0, 1)
					v.KeyHolder.Rotation:Set(v7)

					if v7 >= 1 then
						break
					else
						task.wait()
					end
				end
			end)
			v6 = 2
		end

		v.HolderStates.State:Set(v6)
		v.KeyHolder.State:Set(v6)
	end

	object:Connect(instance.PromptButtonHoldBegan, function()
		if instance:GetAttribute("OnCooldown") then
			return
		end

		v4 = true
		v3 = Config.PlaySound(object, instance, "Hold", v3)
		stateManager()
	end)
	object:Connect(instance.PromptButtonHoldEnded, function()
		if not v4 then
			return
		end

		v4 = false

		if v.Triggered:Compare(1) then
			v3 = Config.PlaySound(object, instance, "NoneFromHold", v3)
		end

		task.wait()

		if not object.IsActive then
			return
		end

		stateManager()
	end)
	object:Connect(instance.Triggered, function()
		if not v.Triggered:Compare(1) then
			return
		end

		v3 = Config.PlaySound(object, instance, "Triggered", v3)
		v.Triggered:Set(2)
		instance:SetAttribute("OnCooldown", true)
		task.wait(coolDown)
		instance:SetAttribute("OnCooldown", nil)

		if not object.IsActive then
			return
		end

		if v.Triggered ~= nil and v.Triggered:Compare(2) then
			v.Triggered:Reset()
		end
	end)
	return function()
		if v3 and v3.Parent then
			object:Remove(v3)
			v3:Destroy()
			v3 = nil
		end

		v.Triggered:Set(3)
		task.wait(Config.CleanDelay)
	end
end
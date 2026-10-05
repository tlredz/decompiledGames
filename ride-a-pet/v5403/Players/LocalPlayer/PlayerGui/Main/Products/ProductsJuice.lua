local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIChoreo = require(ReplicatedStorage:WaitForChild("UIChoreo"))
local POSE = UIChoreo.POSE
local SWING = UIChoreo.SWING
local parent = script.Parent
local v = {
	Rays = {
		S = 0.3,
		Tune = { 1, 3.5 },
		PoseTune = { 1, 3 }
	},
	Title = {
		S = 1.7,
		R = -6,
		Tune = { 0.62, 5 },
		PoseTune = SWING
	},
	Egg = {
		S = 0,
		Tune = "Card",
		PoseTune = SWING
	},
	Tag = {
		S = 0.4,
		R = 8,
		Tune = "Card",
		PoseTune = SWING
	},
	Card = {
		R = -14,
		PoseTune = SWING
	},
	Buy = {
		S = 0,
		R = -10,
		Tune = "Card",
		PoseTune = SWING
	}
}
local holder = parent:WaitForChild("Holder")
holder:WaitForChild("DragonEgg"):WaitForChild("EggImage")
holder:WaitForChild("GiantEgg"):WaitForChild("EggImage")
local v2 = {
	x50DragonEgg = true,
	x50GiantEgg = true
}

local function cardsIn(list)
	return function(instance)
		local guiObjects = {}
		local holder2 = instance:FindFirstChild("Holder")

		if not holder2 then
			return guiObjects
		end

		for _, childName in ipairs(list) do
			local child = holder2:FindFirstChild(childName)

			if not child then
				continue
			end

			for _, guiObject in ipairs(child:GetChildren()) do
				if not (guiObject.Name == "PaddingFrame" and guiObject:IsA("GuiObject") and guiObject.Visible) then
					continue
				end

				for _, guiObject2 in ipairs(guiObject:GetChildren()) do
					if guiObject2:IsA("GuiObject") and guiObject2.Visible then
						table.insert(guiObjects, guiObject2)
					end
				end
			end
		end

		return guiObjects
	end
end

local function buttonsIn(list)
	return function(instance)
		local buttons = {}
		local holder2 = instance:FindFirstChild("Holder")
		local child = holder2 and holder2:FindFirstChild(list[1])
		local payments = child and child:FindFirstChild("Payments")

		if not payments then
			return buttons
		end

		for _, guiObject in ipairs(payments:GetChildren()) do
			if not (guiObject:IsA("GuiObject") and guiObject.Visible) then
				continue
			end

			for _, button in ipairs(guiObject:GetChildren()) do
				if not button:IsA("GuiButton") or not button.Visible or v2[button.Name] then
					continue
				end

				table.insert(buttons, button)
			end
		end

		table.sort(buttons, function(a, b)
			return a.AbsolutePosition.X < b.AbsolutePosition.X
		end)
		return buttons
	end
end

local v11 = { "DragonEgg" }
local v18 = { "GiantEgg" }
local v22 = { "Gamepasses" }
local v25 = { "Cash" }
UIChoreo.window(parent, {
	Parts = {
		{
			Get = "Header",
			Pose = POSE.Header,
			At = 0.05
		},
		{
			Get = "Holder.DragonEgg.Sunburst",
			Pose = v.Rays,
			At = 0.06
		},
		{
			Get = "Holder.DragonEgg.DragonEggText",
			Pose = v.Title,
			At = 0.08
		},
		{
			Get = "Holder.DragonEgg.EggImage",
			Pose = v.Egg,
			At = 0.12
		},
		{
			Get = "Holder.DragonEgg.InstantHatchText",
			Pose = v.Tag,
			At = 0.18
		},
		{
			Get = "Holder.DragonEgg.PetHolder/*",
			Pose = v.Card,
			At = 0.16,
			Step = 0.045,
			MaxTotal = 0.2,
			Order = "Grid",
			LowSkip = true
		},
		{
			Get = function(instance)
				local buttons = {}
				local holder2 = instance:FindFirstChild("Holder")
				local child = holder2 and holder2:FindFirstChild(v11[1])
				local payments = child and child:FindFirstChild("Payments")

				if not payments then
					return buttons
				end

				for _, guiObject in ipairs(payments:GetChildren()) do
					if not (guiObject:IsA("GuiObject") and guiObject.Visible) then
						continue
					end

					for _, button in ipairs(guiObject:GetChildren()) do
						if not button:IsA("GuiButton") or not button.Visible or v2[button.Name] then
							continue
						end

						table.insert(buttons, button)
					end
				end

				table.sort(buttons, function(a, b)
					return a.AbsolutePosition.X < b.AbsolutePosition.X
				end)
				return buttons
			end,
			Pose = v.Buy,
			At = 0.22,
			Step = 0.05,
			MaxTotal = 0.16,
			Fade = false,
			LowSkip = true
		},
		{
			Get = "Holder.GiantEgg.Sunburst",
			Pose = v.Rays,
			At = 0.16
		},
		{
			Get = "Holder.GiantEgg.GiantEggText",
			Pose = v.Title,
			At = 0.18
		},
		{
			Get = "Holder.GiantEgg.EggImage",
			Pose = v.Egg,
			At = 0.22
		},
		{
			Get = "Holder.GiantEgg.InstantHatchText",
			Pose = v.Tag,
			At = 0.28
		},
		{
			Get = "Holder.GiantEgg.Description",
			Pose = v.Tag,
			At = 0.3
		},
		{
			Get = function(instance)
				local buttons = {}
				local holder2 = instance:FindFirstChild("Holder")
				local child = holder2 and holder2:FindFirstChild(v18[1])
				local payments = child and child:FindFirstChild("Payments")

				if not payments then
					return buttons
				end

				for _, guiObject in ipairs(payments:GetChildren()) do
					if not (guiObject:IsA("GuiObject") and guiObject.Visible) then
						continue
					end

					for _, button in ipairs(guiObject:GetChildren()) do
						if not button:IsA("GuiButton") or not button.Visible or v2[button.Name] then
							continue
						end

						table.insert(buttons, button)
					end
				end

				table.sort(buttons, function(a, b)
					return a.AbsolutePosition.X < b.AbsolutePosition.X
				end)
				return buttons
			end,
			Pose = v.Buy,
			At = 0.32,
			Step = 0.05,
			MaxTotal = 0.16,
			Fade = false,
			LowSkip = true
		},
		{
			Get = "Holder.GiantEgg.OddsShower",
			Pose = POSE.Pop,
			At = 0.36
		},
		{
			Get = "Holder.Gamepasses.GamepassesText",
			Pose = v.Title,
			At = 0.3
		},
		{
			Get = function(instance)
				local guiObjects = {}
				local holder2 = instance:FindFirstChild("Holder")

				if not holder2 then
					return guiObjects
				end

				for _, childName in ipairs(v22) do
					local child = holder2:FindFirstChild(childName)

					if not child then
						continue
					end

					for _, guiObject in ipairs(child:GetChildren()) do
						if not (guiObject.Name == "PaddingFrame" and guiObject:IsA("GuiObject") and guiObject.Visible) then
							continue
						end

						for _, guiObject2 in ipairs(guiObject:GetChildren()) do
							if guiObject2:IsA("GuiObject") and guiObject2.Visible then
								table.insert(guiObjects, guiObject2)
							end
						end
					end
				end

				return guiObjects
			end,
			Pose = v.Card,
			At = 0.34,
			Step = 0.05,
			MaxTotal = 0.15,
			LowSkip = true
		},
		{
			Get = "Holder.Cash.CashLabel",
			Pose = v.Title,
			At = 0.38
		},
		{
			Get = function(instance)
				local guiObjects = {}
				local holder2 = instance:FindFirstChild("Holder")

				if not holder2 then
					return guiObjects
				end

				for _, childName in ipairs(v25) do
					local child = holder2:FindFirstChild(childName)

					if not child then
						continue
					end

					for _, guiObject in ipairs(child:GetChildren()) do
						if not (guiObject.Name == "PaddingFrame" and guiObject:IsA("GuiObject") and guiObject.Visible) then
							continue
						end

						for _, guiObject2 in ipairs(guiObject:GetChildren()) do
							if guiObject2:IsA("GuiObject") and guiObject2.Visible then
								table.insert(guiObjects, guiObject2)
							end
						end
					end
				end

				return guiObjects
			end,
			Pose = v.Card,
			At = 0.42,
			Step = 0.05,
			MaxTotal = 0.15,
			LowSkip = true
		},
		{
			Get = "Close",
			Pose = POSE.Close,
			At = 0.2
		},
		{
			Get = "Gift",
			Pose = POSE.Spin,
			At = 0.38
		}
	},
	CloseLead = 0.08,
	IdleAfter = 0.3
})
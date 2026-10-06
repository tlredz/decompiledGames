local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
game:GetService("StarterPlayer")
local Colors = require(ReplicatedStorage:WaitForChild("Omni"):WaitForChild("Utils"):WaitForChild("Colors"))
return table.freeze({
	DescFromPath = function(_, instance, value: string)
		if not (instance and instance:IsA("Instance")) or (not value or type(value) ~= "string") then
			return
		end

		for _, childName in string.split(value, ".") do
			if not instance then
				break
			end

			instance = instance:FindFirstChild(childName)
		end

		return instance
	end,
	ObserveObject = function(_, instance, onChanged)
		if not (instance and instance:IsA("Instance")) or (not onChanged or type(onChanged) ~= "function") then
			return
		end

		local v = {
			Connections = {},
			Destroy = function(p)
				for _, connection in p.Connections do
					connection:Disconnect()
				end

				table.clear(p.Connections)
			end
		}
		v.Connections.Changed = instance.Changed:Connect(onChanged)
		onChanged()
		return v
	end,
	ObserveObjectAttributes = function(_, instance, onAttributeChanged)
		if not (instance and instance:IsA("Instance")) or (not onAttributeChanged or type(onAttributeChanged) ~= "function") then
			return
		end

		local v = {
			Connections = {},
			Destroy = function(p)
				for _, connection in p.Connections do
					connection:Disconnect()
				end

				table.clear(p.Connections)
			end
		}
		v.Connections.Changed = instance.AttributeChanged:Connect(onAttributeChanged)
		onAttributeChanged()
		return v
	end,
	ObserveChilds = function(_, instance, onChildAdded)
		if not (instance and instance:IsA("Instance")) or (not onChildAdded or type(onChildAdded) ~= "function") then
			return
		end

		local v = {
			Connections = {},
			Destroy = function(p)
				for _, connection in p.Connections do
					connection:Disconnect()
				end

				table.clear(p.Connections)
			end
		}
		v.Connections.Added = instance.ChildAdded:Connect(onChildAdded)

		for _, child in instance:GetChildren() do
			onChildAdded(child)
		end

		return v
	end,
	ObserveDescendants = function(_, instance, onDescendantAdded)
		if not (instance and instance:IsA("Instance")) or (not onDescendantAdded or type(onDescendantAdded) ~= "function") then
			return
		end

		local v = {
			Connections = {},
			Destroy = function(p)
				for _, connection in p.Connections do
					connection:Disconnect()
				end

				table.clear(p.Connections)
			end
		}
		v.Connections.Added = instance.DescendantAdded:Connect(onDescendantAdded)

		for _, descendant in instance:GetDescendants() do
			onDescendantAdded(descendant)
		end

		return v
	end,
	ObserveTaggedObject = function(_, tag: string, callback)
		if not tag or type(tag) ~= "string" or (not callback or type(callback) ~= "function") then
			return
		end

		local v = {
			Connections = {},
			Destroy = function(p)
				for _, connection in p.Connections do
					connection:Disconnect()
				end

				table.clear(p.Connections)
			end
		}
		v.Connections.Changed = CollectionService:GetInstanceAddedSignal(tag):Connect(callback)

		for _, v2 in CollectionService:GetTagged(tag) do
			callback(v2)
		end

		return v
	end,
	SetupTemplateForRarity = function(_, frame, rarity: string?)
		if not (frame and frame:IsA("Frame")) then
			return
		end

		if rarity and type(rarity) == "string" then
			local rarityColor = Colors:GetRarityColor(rarity)

			if not rarityColor then
				return
			end

			local colorSequence = ColorSequence.new(rarityColor)

			if not colorSequence then
				return
			end

			frame.Background.UIGradient.Color = colorSequence
			frame.Background.Decoration.Stroke.UIGradient.Color = colorSequence
			frame.Background.Decoration.Shadow.UIGradient.Color = colorSequence
			frame.Background.Decoration.Texture.UIGradient.Color = colorSequence
			frame.Background.Decoration.InsideBorder.UIGradient.Color = colorSequence
			frame.Background.Decoration.Stroke.UIGradient:SetAttribute("Rarity", rarity)
		else
			local colorSequence = ColorSequence.new(Color3.new(1, 1, 1))
			frame.Background.UIGradient.Color = colorSequence
			frame.Background.Decoration.Stroke.UIGradient.Color = colorSequence
			frame.Background.Decoration.Shadow.UIGradient.Color = colorSequence
			frame.Background.Decoration.Texture.UIGradient.Color = colorSequence
			frame.Background.Decoration.InsideBorder.UIGradient.Color = colorSequence
			frame.Background.Decoration.Stroke.UIGradient:SetAttribute("Rarity", nil)
		end
	end,
	SetupTemplateForDifficulty = function(_, frame, value: string?)
		if not (frame and frame:IsA("Frame")) then
			return
		end

		if value and type(value) == "string" then
			local difficultColor = Colors:GetDifficultColor(value)

			if not difficultColor then
				return
			end

			if difficultColor == Color3.new(0, 0, 0) then
				difficultColor = Color3.new(1, 1, 1)
			end

			local colorSequence = ColorSequence.new(difficultColor)

			if not colorSequence then
				return
			end

			frame.Background.UIGradient.Color = colorSequence
			frame.Background.Decoration.Stroke.UIGradient.Color = colorSequence
			frame.Background.Decoration.Shadow.UIGradient.Color = colorSequence
			frame.Background.Decoration.Texture.UIGradient.Color = colorSequence
			frame.Background.Decoration.InsideBorder.UIGradient.Color = colorSequence
			frame.Background.Decoration.Stroke.UIGradient:SetAttribute("Rarity", nil)
		else
			local colorSequence = ColorSequence.new(Color3.new(1, 1, 1))
			frame.Background.UIGradient.Color = colorSequence
			frame.Background.Decoration.Stroke.UIGradient.Color = colorSequence
			frame.Background.Decoration.Shadow.UIGradient.Color = colorSequence
			frame.Background.Decoration.Texture.UIGradient.Color = colorSequence
			frame.Background.Decoration.InsideBorder.UIGradient.Color = colorSequence
			frame.Background.Decoration.Stroke.UIGradient:SetAttribute("Rarity", nil)
		end
	end,
	SetupTemplateForCompletion = function(_, frame, flag: boolean?)
		if not (frame and frame:IsA("Frame")) then
			return
		end

		if flag == true then
			local color = Color3.new(0, 1, 0)
			local colorSequence = ColorSequence.new(color)
			frame.Background.UIGradient.Color = colorSequence
			frame.Background.Decoration.Stroke.UIGradient.Color = colorSequence
			frame.Background.Decoration.Shadow.UIGradient.Color = colorSequence
			frame.Background.Decoration.Texture.UIGradient.Color = colorSequence
			frame.Background.Decoration.InsideBorder.UIGradient.Color = colorSequence
			frame.Background.Decoration.Stroke.UIGradient:SetAttribute("Rarity", nil)
		else
			local color = Color3.new(1, 0, 0)
			local colorSequence = ColorSequence.new(color)
			frame.Background.UIGradient.Color = colorSequence
			frame.Background.Decoration.Stroke.UIGradient.Color = colorSequence
			frame.Background.Decoration.Shadow.UIGradient.Color = colorSequence
			frame.Background.Decoration.Texture.UIGradient.Color = colorSequence
			frame.Background.Decoration.InsideBorder.UIGradient.Color = colorSequence
			frame.Background.Decoration.Stroke.UIGradient:SetAttribute("Rarity", nil)
		end
	end,
	AddEnum = function(_, instance, p: string, p2: string)
		if instance and instance:IsA("Instance") then
			instance:SetAttribute(`__Enum_{p}__`, p2)
		end
	end,
	GetEnum = function(_, instance, p: string)
		if instance and instance:IsA("Instance") then
			return instance:GetAttribute((`__Enum_{p}__`))
		end
	end
})
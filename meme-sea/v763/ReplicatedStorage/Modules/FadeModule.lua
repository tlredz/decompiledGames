local TweenService = game:GetService("TweenService")

local function GetProperty(instance)
	if instance:IsA("TextLabel") or instance:IsA("TextBox") or instance:IsA("TextButton") then
		return { "TextTransparency", "BackgroundTransparency" }
	end

	if instance:IsA("ViewportFrame") or instance:IsA("ImageButton") or instance:IsA("ImageLabel") then
		return { "ImageTransparency", "BackgroundTransparency" }
	end

	if instance:IsA("Frame") or instance:IsA("ScrollingFrame") then
		return { "BackgroundTransparency" }
	end

	if instance:IsA("UIStroke") then
		return { "Transparency" }
	end
end

local FadeModule = {}

function FadeModule.MiniFadeIn(instance, duration)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local children = instance:GetChildren()
	children[#children + 1] = instance
	table.insert(children, instance)

	for _, v in pairs(children) do
		local property = GetProperty(v)

		if not property then
			continue
		end

		local v3 = property[1]
		local v4 = property[2]

		if v3 and v[v3] then
			if not v:GetAttribute("DefaultTransparencyValue") then
				v:SetAttribute("DefaultTransparencyValue", v[v3])
				v[v3] = 1
			end

			TweenService:Create(v, tweenInfo, {
				[v3] = v:GetAttribute("DefaultTransparencyValue")
			}):Play()
		end

		if not (v4 and v[v4]) then
			continue
		end

		if not v:GetAttribute("DefaultTransparencyValue2") then
			v:SetAttribute("DefaultTransparencyValue2", v[v4])
			v[v4] = 1
		end

		TweenService:Create(v, tweenInfo, {
			[v4] = v:GetAttribute("DefaultTransparencyValue2")
		}):Play()
	end
end

function FadeModule.MiniFadeOut(folder, duration)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local descendants = folder:GetDescendants()
	descendants[#descendants + 1] = folder
	table.insert(descendants, folder)

	for _, descendant in pairs(descendants) do
		local property = GetProperty(descendant)

		if not property then
			continue
		end

		local v2 = property[1]
		local v3 = property[2]

		if v2 and descendant[v2] then
			if not descendant:GetAttribute("DefaultTransparencyValue") then
				descendant:SetAttribute("DefaultTransparencyValue", descendant[v2])
			end

			TweenService:Create(descendant, tweenInfo, {
				[v2] = 1
			}):Play()
		end

		if not (v3 and descendant[v3]) then
			continue
		end

		if not descendant:GetAttribute("DefaultTransparencyValue2") then
			descendant:SetAttribute("DefaultTransparencyValue2", descendant[v3])
		end

		TweenService:Create(descendant, tweenInfo, {
			[v3] = 1
		}):Play()
	end
end

function FadeModule.FadeIn(folder, duration)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local descendants = folder:GetDescendants()
	descendants[#descendants + 1] = folder
	table.insert(descendants, folder)

	for _, descendant in pairs(descendants) do
		local property = GetProperty(descendant)

		if not property then
			continue
		end

		local v2 = property[1]
		local v3 = property[2]

		if v2 and descendant[v2] then
			if not descendant:GetAttribute("DefaultTransparencyValue") then
				descendant:SetAttribute("DefaultTransparencyValue", descendant[v2])
				descendant[v2] = 1
			end

			TweenService:Create(descendant, tweenInfo, {
				[v2] = descendant:GetAttribute("DefaultTransparencyValue")
			}):Play()
		end

		if not (v3 and descendant[v3]) then
			continue
		end

		if not descendant:GetAttribute("DefaultTransparencyValue2") then
			descendant:SetAttribute("DefaultTransparencyValue2", descendant[v3])
			descendant[v3] = 1
		end

		TweenService:Create(descendant, tweenInfo, {
			[v3] = descendant:GetAttribute("DefaultTransparencyValue2")
		}):Play()
	end
end

function FadeModule.FadeOut(folder, duration)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local descendants = folder:GetDescendants()
	descendants[#descendants + 1] = folder
	table.insert(descendants, folder)

	for _, descendant in pairs(descendants) do
		local property = GetProperty(descendant)

		if not property then
			continue
		end

		local v2 = property[1]
		local v3 = property[2]

		if v2 and descendant[v2] then
			if not descendant:GetAttribute("DefaultTransparencyValue") then
				descendant:SetAttribute("DefaultTransparencyValue", descendant[v2])
			end

			TweenService:Create(descendant, tweenInfo, {
				[v2] = 1
			}):Play()
		end

		if not (v3 and descendant[v3]) then
			continue
		end

		if not descendant:GetAttribute("DefaultTransparencyValue2") then
			descendant:SetAttribute("DefaultTransparencyValue2", descendant[v3])
		end

		TweenService:Create(descendant, tweenInfo, {
			[v3] = 1
		}):Play()
	end
end

return FadeModule
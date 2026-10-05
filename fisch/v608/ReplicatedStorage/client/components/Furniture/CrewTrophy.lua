local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
game:GetService("Players")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local v = Component.new({
	Tag = "CrewTrophy"
})
local v2 = {
	{
		All = {
			TrophyCup = {
				Color = Color3.fromRGB(242, 173, 88)
			},
			TrophyBase = {
				Color = Color3.fromRGB(216, 155, 80)
			},
			TextSurface = {
				Color = Color3.fromRGB(242, 173, 88)
			},
			Rank = {
				TextColor3 = Color3.fromRGB(255, 164, 99)
			},
			Season = {
				TextColor3 = Color3.fromRGB(0, 0, 0)
			},
			Sparkles = {
				Color = ColorSequence.new(Color3.fromRGB(255, 188, 49)),
				Rate = 6
			}
		}
	},
	{
		All = {
			TrophyCup = {
				Color = Color3.fromRGB(242, 242, 242)
			},
			TrophyBase = {
				Color = Color3.fromRGB(172, 172, 172)
			},
			TextSurface = {
				Color = Color3.fromRGB(242, 242, 242)
			},
			Rank = {
				TextColor3 = Color3.fromRGB(96, 194, 255)
			},
			Season = {
				TextColor3 = Color3.fromRGB(0, 0, 0)
			},
			Sparkles = {
				Color = ColorSequence.new(Color3.fromRGB(144, 211, 255)),
				Rate = 5
			}
		}
	},
	{
		All = {
			TrophyCup = {
				Color = Color3.fromRGB(130, 108, 77)
			},
			TrophyBase = {
				Color = Color3.fromRGB(85, 65, 51)
			},
			TextSurface = {
				Color = Color3.fromRGB(136, 111, 83)
			},
			Rank = {
				TextColor3 = Color3.fromRGB(131, 84, 51)
			},
			Season = {
				TextColor3 = Color3.fromRGB(113, 113, 113)
			},
			Sparkles = {
				Color = ColorSequence.new(Color3.fromRGB(91, 67, 46)),
				Rate = 4
			}
		}
	},
	{
		All = {
			Rank = {
				TextColor3 = Color3.fromRGB(0, 0, 0)
			},
			Season = {
				TextColor3 = Color3.fromRGB(0, 0, 0)
			},
			Sparkles = {
				Rate = 0
			}
		},
		Catches = {
			TrophyCup = {
				Color = Color3.fromRGB(190, 99, 98)
			},
			TrophyBase = {
				Color = Color3.fromRGB(190, 99, 98)
			},
			TextSurface = {
				Color = Color3.fromRGB(255, 132, 132)
			}
		},
		Rarest = {
			TrophyCup = {
				Color = Color3.fromRGB(131, 164, 220)
			},
			TrophyBase = {
				Color = Color3.fromRGB(77, 102, 126)
			},
			TextSurface = {
				Color = Color3.fromRGB(144, 162, 235)
			}
		},
		Rating = {
			TrophyCup = {
				Color = Color3.fromRGB(242, 209, 91)
			},
			TrophyBase = {
				Color = Color3.fromRGB(188, 169, 72)
			},
			TextSurface = {
				Color = Color3.fromRGB(255, 215, 95)
			}
		},
		Weight = {
			TrophyCup = {
				Color = Color3.fromRGB(113, 175, 102)
			},
			TrophyBase = {
				Color = Color3.fromRGB(90, 138, 81)
			},
			TextSurface = {
				Color = Color3.fromRGB(122, 188, 109)
			}
		}
	}
}

function v:Construct()
	self.trove = Trove.new()
end

function v:Update()
	local trophyPlace = self.Instance:GetAttribute("TrophyPlace")
	local trophySeason = self.Instance:GetAttribute("TrophySeason")
	local trophyCategory = self.Instance:GetAttribute("TrophyCategory")

	if not (trophyPlace and trophySeason and trophyCategory) then
		return
	end

	local v3 = v2[trophyPlace] or v2[4]

	for _, instance in ipairs(self.Instance:QueryDescendants("BasePart, ParticleEmitter, TextLabel")) do
		local v4 = v3[trophyCategory]

		if v4 and v4[instance.Name] then
			for k, v5 in v4[instance.Name] do
				instance[k] = v5
			end
		end

		local all = v3.All

		if all and all[instance.Name] then
			for k, v5 in all[instance.Name] do
				instance[k] = v5
			end
		end

		if instance:IsA("TextLabel") then
			if instance.Name == "Rank" then
				instance.Text = `#{trophyPlace}`
			elseif instance.Name == "Season" then
				instance.Text = trophySeason
			end
		elseif instance:IsA("BasePart") and instance.Material ~= Enum.Material.Neon then
			local material

			if trophyPlace <= 3 then
				material = Enum.Material.Metal
			else
				material = Enum.Material.SmoothPlastic
			end

			instance.Material = material
		end
	end
end

function v:UpdateGuiTransparency()
	local textSurface = self.Instance:FindFirstChild("TextSurface")

	if not textSurface then
		return
	end

	local localTransparencyModifier = textSurface.LocalTransparencyModifier

	for _, v3 in textSurface:QueryDescendants("TextLabel") do
		if v3.Name == "Rank" then
			v3.TextTransparency = 0.35 + localTransparencyModifier * 0.65
		elseif v3.Name == "Season" then
			v3.TextTransparency = 0.6 + localTransparencyModifier * 0.4
		end
	end
end

function v:Start()
	self.trove:Connect(self.Instance:GetAttributeChangedSignal("TrophyPlace"), function()
		self:Update()
	end)
	self.trove:Connect(self.Instance:GetAttributeChangedSignal("TrophySeason"), function()
		self:Update()
	end)
	self.trove:Connect(self.Instance:GetAttributeChangedSignal("TrophyCategory"), function()
		self:Update()
	end)
	self:Update()
	self.trove:Add(task.spawn(function()
		local textSurface = self.Instance:WaitForChild("TextSurface", 30)

		if not textSurface then
			return
		end

		textSurface:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
			self:UpdateGuiTransparency()
		end)
		self:UpdateGuiTransparency()
	end))
end

function v.Stop(p)
	p.trove:Destroy()
end

return v
local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
game:GetService("Debris")
local Players = game:GetService("Players")
local isServer = RunService:IsServer()
local Network = require(ReplicatedStorage.SharedUtils.Network)
local SettingsFlags = require(ReplicatedStorage.SharedUtils.SettingsFlags)
local v = {
	Styles = {
		Research = true,
		Healing = true,
		Item = true,
		Tape = true,
		Machine = true,
		Target = true,
		Threat = true,
		Ally = true
	}
}

if isServer then
	function v:PlayHighlight(p, ...)
		Network:Post(p, "PlayHighlight", ...)
	end

	function v.BroadcastHighlight(_, ...)
		Network:FireAllClients("PlayHighlight", ...)
	end

	function v:ClearHighlight(p, p2: string)
		Network:Post(p, "ClearHighlight", p2)
	end

	function v.BroadcastClear(_, p: string)
		Network:FireAllClients("ClearHighlight", p)
	end

	return v
else
	local modules = ReplicatedStorage:WaitForChild("Modules")
	local myDataController = modules:FindFirstChild("MyDataController") or modules:FindFirstChild("ClientUI") and modules.ClientUI:WaitForChild("MyDataController")
	local module = myDataController and require(myDataController)
	local isStudio = RunService:IsStudio()
	local v2 = {}
	local priority2 = {
		VIEW_TARGET = 0,
		REMOTE_ABILITY = 1,
		TRINKET = 2,
		LOCAL_ABILITY = 3
	}
	v.Priority = priority2
	local v4 = {}
	local count = 0
	local object = setmetatable({}, {
		__mode = "k"
	})
	local object2 = setmetatable({}, {
		__mode = "k"
	})

	local function resolveHome(model)
		if model:IsA("Model") then
			return model
		end

		return model:FindFirstAncestorWhichIsA("Model") or model
	end

	local removeEntry

	local function reeval(p)
		local v5 = v4[p]

		if not v5 then
			return
		end

		local v6 = nil

		for _, v7 in ipairs(v5) do
			if not (not v6 or v7.priority > v6.priority or v7.priority == v6.priority and v7.seq > v6.seq) then
				continue
			end

			v6 = v7
		end

		local v7 = nil

		for _, v8 in ipairs(v5) do
			local enabled = v8 == v6
			local v10 = v8

			if v8.highlight and not pcall(function()
				v10.highlight.Enabled = enabled
				v10.highlight.Parent = enabled and v10.parent or nil
			end) then
				v7 = v7 or {}
				table.insert(v7, v8)
			end

			if v8.billboard then
				v8.billboard.Enabled = enabled
			end
		end

		if v7 then
			for _, v8 in ipairs(v7) do
				removeEntry(p, v8)
			end
		end
	end

	removeEntry = function(p, p2)
		if p2.highlight then
			object[p2.highlight] = nil
		end

		local v5 = v4[p]

		if not v5 then
			return
		end

		for i, v6 in ipairs(v5) do
			if v6 ~= p2 then
				continue
			end

			table.remove(v5, i)
			break
		end

		if #v5 == 0 then
			v4[p] = nil
		else
			reeval(p)
		end
	end

	local function registerEntry(instance, instance2, billboard, priority: number)
		count += 1
		local entry = {
			highlight = instance2,
			billboard = billboard,
			priority = priority,
			seq = count,
			parent = instance2.Parent
		}
		local v6 = v4[instance]

		if not v6 then
			v6 = {}
			v4[instance] = v6
		end

		if not object2[instance] then
			object2[instance] = true
			instance.Destroying:Once(function()
				local v7 = v4[instance]
				v4[instance] = nil

				if v7 then
					for _, v8 in ipairs(v7) do
						if v8.highlight then
							v8.highlight:Destroy()
						end
					end
				end
			end)
		end

		table.insert(v6, entry)
		object[instance2] = {
			home = instance,
			entry = entry
		}
		instance2.Destroying:Connect(function()
			removeEntry(instance, entry)
		end)
		reeval(instance)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function retireHighlight(instance)
		local v5 = object[instance]

		if v5 then
			removeEntry(v5.home, v5.entry)
		end

		instance:Destroy()
	end

	local v5 = {}

	for k in pairs(v.Styles) do
		table.insert(v5, k)
	end

	table.sort(v5)

	local function stringToColor3(value: string?)
		if type(value) ~= "string" then
			return nil
		end

		local parts = value:split(",")
		local v6 = tonumber(parts[1])
		local v7 = tonumber(parts[2])
		local v8 = tonumber(parts[3])

		if v6 and v7 and v8 then
			return Color3.fromRGB(v6, v7, v8)
		end

		return nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getSettings()
		if not SettingsFlags:IsEnabled("ColorSettings") then
			return nil
		end

		local v6 = module and module:getMyReplica()
		local settings = v6 and v6.Data and v6.Data.Settings
		return settings and settings.ColorSettings
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function highlightArrowsEnabled()
		local v6 = module and module:getMyReplica()
		local settings = v6 and v6.Data and v6.Data.Settings
		return not settings or SettingsFlags:GetEffective(settings.HighlightToggle, "HighlightToggle") ~= false
	end

	local function createBillboard(model, billboard, outlineColor: Color3)
		local GUI = ReplicatedStorage:FindFirstChild("GUI")
		local child = GUI and GUI:FindFirstChild(billboard.Template or "WarningIcon")

		if not child then
			return nil
		end

		local clone = child:Clone()
		clone.Enabled = true
		clone.Size = billboard.Size or UDim2.new(12, 0, 12, 0)

		if billboard.Adornee then
			clone.Adornee = billboard.Adornee
		end

		if billboard.ExtentsOffset then
			clone.ExtentsOffset = billboard.ExtentsOffset
		end

		if billboard.StudsOffset then
			clone.StudsOffset = billboard.StudsOffset
		elseif not billboard.Adornee and not billboard.ExtentsOffset and model:IsA("Model") then
			clone.StudsOffset = createVector(0, 5, 0)
		end

		if billboard.ExtentsOffsetWorldSpace then
			clone.ExtentsOffsetWorldSpace = billboard.ExtentsOffsetWorldSpace
		end

		local frame = clone:FindFirstChild("Frame")
		local textLabel = frame and frame:FindFirstChild("TextLabel")
		local imageLabel = frame and frame:FindFirstChild("ImageLabel")

		if textLabel then
			textLabel.Text = billboard.Label or ""

			if billboard.LabelSize then
				textLabel.Size = billboard.LabelSize
			end

			textLabel.TextColor3 = billboard.TextColor or billboard.IconColor or outlineColor
		end

		if imageLabel then
			imageLabel.ImageColor3 = billboard.IconColor or outlineColor

			if billboard.Image then
				imageLabel.Image = billboard.Image
			end

			if billboard.ImageScaleType then
				imageLabel.ScaleType = billboard.ImageScaleType
			end

			if billboard.ImageSize then
				imageLabel.Size = billboard.ImageSize
			end

			if billboard.ImagePosition then
				imageLabel.Position = billboard.ImagePosition
			end

			if billboard.ImageAnchorPoint then
				imageLabel.AnchorPoint = billboard.ImageAnchorPoint
			end
		end

		clone.Parent = model
		return clone
	end

	local function fadeBillboard(billboard, tweenInfo)
		local frame = billboard:FindFirstChild("Frame")

		if not frame then
			return
		end

		local textLabel = frame:FindFirstChild("TextLabel")
		local imageLabel = frame:FindFirstChild("ImageLabel")
		local uIStroke = textLabel and textLabel:FindFirstChild("UIStroke")

		if imageLabel then
			TweenService:Create(imageLabel, tweenInfo, {
				ImageTransparency = 1
			}):Play()
		end

		if textLabel then
			TweenService:Create(textLabel, tweenInfo, {
				TextTransparency = 1
			}):Play()
		end

		if uIStroke then
			TweenService:Create(uIStroke, tweenInfo, {
				Transparency = 1
			}):Play()
		end
	end

	function v:PlayHighlight(model, p: string, options, p2: string?)
		if v.Styles[p] then
			if not model then
				return
			end

			local v6 = options or {}
			local fillColor = v6.FillColor or Color3.new(1, 1, 1)
			local outlineColor = v6.OutlineColor or Color3.new(1, 1, 1)
			local settings = getSettings() -- equivalent call inferred; original call site unknown

			if isStudio and settings and settings[p .. "Theme"] == nil then
				warn(("[HighlightController] Style %q has no '%sTheme'/'%sColor' entry in PlayerSettings.ColorSettings — override will be ignored. Check for a typo."):format(
					p,
					p,
					p
				))
			end

			if settings and settings[p .. "Theme"] ~= nil and settings[p .. "Theme"] ~= true and settings and not v6.ForceColor then
				local v7 = stringToColor3(settings[p .. "Color"])

				if v7 then
					outlineColor = v7
					fillColor = outlineColor
					outlineColor = fillColor
				end
			end

			local highlight = Instance.new("Highlight")
			highlight.Name = p .. "Highlight"
			highlight.FillColor = fillColor
			highlight.FillTransparency = v6.FillTransparency or 1
			highlight.OutlineColor = outlineColor
			highlight.OutlineTransparency = v6.OutlineTransparency or 0
			highlight.DepthMode = v6.DepthMode or Enum.HighlightDepthMode.AlwaysOnTop
			highlight.Adornee = model
			highlight.Parent = model

			if p2 ~= nil then
				local v7 = v2[p2]

				if v7 then
					retireHighlight(v7) -- equivalent call inferred; original call site unknown
				end

				v2[p2] = highlight
				highlight.Destroying:Connect(function()
					if v2[p2] == highlight then
						v2[p2] = nil
					end
				end)
			end

			local billboard = v6.Billboard

			if billboard then
				billboard = highlightArrowsEnabled() and createBillboard(model, v6.Billboard, outlineColor)
			end

			if billboard then
				highlight.Destroying:Connect(function()
					if billboard.Parent then
						billboard:Destroy()
					end
				end)
			end

			local priority = v6.Priority

			if not priority then
				if v6.Origin == nil then
					priority = priority2.REMOTE_ABILITY
				else
					priority = v6.Origin == Players.LocalPlayer and priority2.LOCAL_ABILITY or priority2.REMOTE_ABILITY
				end
			end

			if not model:IsA("Model") then
				model = model:FindFirstAncestorWhichIsA("Model") or model
			end

			registerEntry(model, highlight, billboard or nil, priority)
			local decay = v6.Decay
			local opaqueDuration = v6.OpaqueDuration or 0

			if decay then
				task.delay(decay + 0.5, function()
					retireHighlight(highlight) -- equivalent call inferred; original call site unknown
				end)
				task.spawn(function()
					task.wait(opaqueDuration)
					local tweenInfo = TweenInfo.new(
						math.max(0, decay - opaqueDuration),
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.In
					)

					if highlight and highlight.Parent then
						TweenService:Create(highlight, tweenInfo, {
							FillTransparency = 1,
							OutlineTransparency = 1
						}):Play()
					end

					if billboard and billboard.Parent then
						fadeBillboard(billboard, tweenInfo)
					end
				end)
			end

			local pulseFade = v6.PulseFade

			if decay or not (pulseFade and pulseFade > 0) then
				return highlight, billboard
			end

			local pulseHold = v6.PulseHold or 0
			local pulseGap = v6.PulseGap or 0
			local fillTransparency = highlight.FillTransparency
			local outlineTransparency = highlight.OutlineTransparency
			local pulseFillTransparency = v6.PulseFillTransparency or 1
			local pulseOutlineTransparency = v6.PulseOutlineTransparency or 1
			local pulseSync = v6.PulseSync == true
			local pulseReverse = v6.PulseReverse == true
			local v8

			if pulseReverse then
				v8 = pulseFade * 2 or pulseFade
			else
				v8 = pulseFade
			end

			local v9 = pulseHold + v8 + pulseGap
			local v10

			if pulseReverse then
				v10 = TweenInfo.new(pulseFade, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true)
			else
				v10 = TweenInfo.new(pulseFade, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			end

			local tween = TweenService:Create(highlight, v10, {
				FillTransparency = pulseFillTransparency,
				OutlineTransparency = pulseOutlineTransparency
			})
			local flag = true
			highlight.Destroying:Connect(function()
				flag = false
				tween:Destroy()
			end)
			local v11 = pulseSync and v9 > 0
			task.spawn(function()
				local v12, now

				if v11 and pulseReverse then
					v12 = math.ceil(os.clock() / v9) * v9
					task.wait((math.max(0, v12 - os.clock())))

					if not flag then
						return
					end
				end

				while flag do
					tween:Cancel()
					highlight.FillTransparency = fillTransparency
					highlight.OutlineTransparency = outlineTransparency

					if pulseHold > 0 then
						task.wait(pulseHold)
					end

					if not flag then
						break
					end

					tween:Play()

					if v11 then
						now = os.clock()
						v12 = v12 and v12 + v9

						if not v12 or v12 <= now then
							v12 = now + (v9 - now % v9)

							if v12 - now < v8 then
								v12 += v9
							end
						end

						task.wait(v12 - now)
					else
						task.wait(v8 + pulseGap)
					end
				end
			end)
			return highlight, billboard
		elseif isStudio then
			warn(("[HighlightController] Unknown highlight style %q. Valid styles: %s"):format(
				tostring(p),
				table.concat(v5, ", ")
			))
		end
	end

	function v:ClearHighlight(p: string)
		local v6 = v2[p]
		v2[p] = nil

		if v6 then
			retireHighlight(v6) -- equivalent call inferred; original call site unknown
		end
	end

	Network:AddAction("PlayHighlight", function(...)
		v:PlayHighlight(...)
	end)
	Network:AddAction("ClearHighlight", function(p)
		v:ClearHighlight(p)
	end)
	return v
end
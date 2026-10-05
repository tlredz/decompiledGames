local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local t = require(ReplicatedStorage.Packages.t)
local Numbers = require(ReplicatedStorage.Shared.Utils.Numbers)
local addCommas = Numbers.AddCommas
local Hud = require(ReplicatedStorage.Client.Hud)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Save = require(ReplicatedStorage.Shared.Save)
local Preferences = require(ReplicatedStorage.Shared.Preferences)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local tweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local tweenInfo3 = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.InOut)
local tweenInfo4 = TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local v = 0
local now = 0
local total = 1
local v2 = nil
local v3 = nil
local v4 = 0
return {
	Start = function()
		local cashCollect = SoundService.CashCollect
		local moneyChange = ReplicatedStorage.Assets.MoneyChange
		local money = Hud.Get("Money")
		local every = Hud.Every("MoneyValue")

		local function playCashCollectSound()
			if not Preferences.IsOn("SFX") then
				return
			end

			if tick() - now > 2 or total >= 3 then
				total = 1
			end

			now = tick()
			cashCollect.TimePosition = 0
			cashCollect.PlaybackSpeed = total
			cashCollect:Play()
			total += 0.07
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function createMoneyChangeClone()
			local clone = moneyChange:Clone()
			local label = clone.Label
			local uIScale = clone.UIScale
			local uIStroke = label.UIStroke
			local more = label.More
			local less = label.Less
			local icon = clone.Icon
			label.TextTransparency = 1
			uIStroke.Transparency = 1
			uIScale.Scale = 0
			icon.ImageTransparency = 1
			return clone, label, uIScale, uIStroke, icon, more, less
		end

		local function getTransparencyProperty(instance)
			if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
				return "ImageTransparency"
			end

			if instance:IsA("TextLabel") or instance:IsA("TextButton") then
				return "TextTransparency"
			end

			if instance:IsA("UIStroke") then
				return "Transparency"
			end

			return nil
		end

		local function animateNotification(moneyChangeClone, p, p2, p3, list)
			TweenService:Create(p, tweenInfo2, {
				TextTransparency = 0.25
			}):Play()
			TweenService:Create(p3, tweenInfo2, {
				Transparency = 0.25
			}):Play()
			TweenService:Create(p2, tweenInfo3, {
				Scale = 1
			}):Play()

			for _, v5 in ipairs(list) do
				local transparencyProperty = getTransparencyProperty(v5)

				if not transparencyProperty then
					continue
				end

				if transparencyProperty == "ImageTransparency" then
					v5.ImageTransparency = 1
				elseif transparencyProperty == "TextTransparency" then
					v5.TextTransparency = 1
				elseif transparencyProperty == "Transparency" then
					v5.Transparency = 1
				end

				TweenService:Create(v5, tweenInfo2, {
					[transparencyProperty] = 0
				}):Play()
			end

			task.delay(1, function()
				TweenService:Create(p, tweenInfo4, {
					TextTransparency = 1
				}):Play()
				TweenService:Create(p3, tweenInfo4, {
					Transparency = 1
				}):Play()

				for _, v5 in ipairs(list) do
					local transparencyProperty = getTransparencyProperty(v5)

					if transparencyProperty then
						TweenService:Create(v5, tweenInfo4, {
							[transparencyProperty] = 1
						}):Play()
					end
				end

				Debris:AddItem(moneyChangeClone, 0.75)
			end)
		end

		local function spawnFloatingMoney(p: number, _: string?)
			local enabled = p < 0
			local moneyChangeClone, label, uIScale, uIStroke, icon, uIGradient, uIGradient2 = createMoneyChangeClone() -- equivalent call inferred; original call site unknown

			if uIGradient and uIGradient:IsA("UIGradient") then
				uIGradient.Enabled = not enabled
			end

			if uIGradient2 and uIGradient2:IsA("UIGradient") then
				uIGradient2.Enabled = enabled
			end

			label.Text = (enabled and "-" or "+") .. "$" .. Simple.FormatCompact(math.round((math.abs(p))), ".#")
			icon.Visible = false
			moneyChangeClone.ZIndex = 10
			moneyChangeClone.Parent = money
			animateNotification(moneyChangeClone, label, uIScale, uIStroke, {})
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function displayMoneyChange(amount: number, icon: string?, flag: boolean?)
			if amount == 0 then
				return
			end

			if amount > 0 and flag ~= false then
				playCashCollectSound()
			end

			spawnFloatingMoney(amount, icon)
		end

		local function updateMoneyLabels(text: string)
			t.strict(t.string)(text)

			for _, v5 in every do
				v5.Text = text
				local shadow = v5:FindFirstChild("Shadow")

				if shadow ~= nil then
					shadow.Text = text
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function formatMoneyText(p: number)
			if p > 99999 then
				return "$" .. Simple.FormatCompact(math.round(p), ".#")
			end

			return "$" .. addCommas((math.round(p)))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function cancelMoneyLabelTween()
			if v2 then
				v2:Cancel()
				v2 = nil
			end

			if v3 then
				v3:Destroy()
				v3 = nil
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setMoneyLabelValue(p: number)
			local text = formatMoneyText(p) -- equivalent call inferred; original call site unknown
			updateMoneyLabels(text)
		end

		local function tweenMoneyLabelValue(p: number, money2: number)
			cancelMoneyLabelTween() -- equivalent call inferred; original call site unknown
			local numberValue = Instance.new("NumberValue")
			numberValue.Value = p
			v3 = numberValue
			setMoneyLabelValue(p) -- equivalent call inferred; original call site unknown
			numberValue.Changed:Connect(setMoneyLabelValue)
			local tween = TweenService:Create(numberValue, tweenInfo, {
				Value = money2
			})
			v2 = tween
			tween.Completed:Once(function(p2)
				if v2 ~= tween then
					return
				end

				v2 = nil
				v3 = nil

				if p2 == Enum.PlaybackState.Completed then
					setMoneyLabelValue(money2) -- equivalent call inferred; original call site unknown
				end

				numberValue:Destroy()
			end)
			tween:Play()
		end

		local function updateMoney(p)
			local v5 = Save.Await()

			if not v5 then
				return
			end

			local money2 = v5.Money
			local forceUpdate = p and p.forceUpdate

			if money2 == v and not forceUpdate then
				return
			end

			if not forceUpdate and v < money2 then
				local v6

				if v3 then
					v6 = v3.Value
				else
					v6 = v
				end

				tweenMoneyLabelValue(v6, money2)
			else
				cancelMoneyLabelTween() -- equivalent call inferred; original call site unknown
				setMoneyLabelValue(money2) -- equivalent call inferred; original call site unknown
			end

			if not forceUpdate then
				local v6 = money2 - v

				if v6 > 0 and v4 > 0 then
					local v7 = math.min(v6, v4)
					v6 -= v7
					v4 -= v7
				end

				if v6 ~= 0 then
					local v7 = v6 > 0
					local v8 = not p or p.allowPositiveAnimation == nil or p.allowPositiveAnimation

					if (not v7 or v8) and v6 ~= 0 then
						if v6 > 0 then
							playCashCollectSound()
						end

						spawnFloatingMoney(v6, nil)
					end
				end
			end

			v = money2
		end

		Save.Loaded:Connect(function()
			updateMoney({
				forceUpdate = true
			})
		end)
		local frame = Hud.Frame("Treadmill")
		frame:GetPropertyChangedSignal("Visible"):Connect(function()
			if frame.Visible then
				updateMoney({
					forceUpdate = true
				})
			end
		end)
		updateMoney({
			forceUpdate = true
		})
		Save.Changed:Connect(function(p: string)
			if p == "Money" then
				updateMoney({
					allowPositiveAnimation = false
				})
			end
		end)
		Remotes.PenRoster.CoinsGathered.OnClientEvent:Connect(function(list, flag: boolean?)
			if not list or flag then
				return
			end

			local total2 = 0
			local v5 = false

			for _, v6 in ipairs(list) do
				if not (v6 and typeof(v6.amount) == "number") then
					continue
				end

				total2 += math.max(v6.amount, 0)
				local v7 = v6.playSound ~= false and not v5
				displayMoneyChange(v6.amount, v6.icon, v7) -- equivalent call inferred; original call site unknown

				if v6.amount > 0 and v7 then
					v5 = true
				end
			end

			if total2 > 0 then
				v4 += total2
			end
		end)
	end
}
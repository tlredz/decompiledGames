local TweenService = game:GetService("TweenService")
return {
	new = function(instance, callback)
		local adminPollUI = instance:WaitForChild("AdminPollUI")
		local container = adminPollUI:WaitForChild("Container")
		local poll = container:WaitForChild("Poll")
		local header = poll:WaitForChild("Header")
		local scope = header:WaitForChild("Scope")
		local timer = header:WaitForChild("Timer")
		local question = poll:WaitForChild("Question")
		local choices = poll:WaitForChild("Choices")
		local status = poll:WaitForChild("Status")
		local v = {}
		local v2 = nil
		local v3 = nil
		local v4 = false
		local error = nil
		local v5 = 0
		local choice = nil
		local v6 = {
			Gui = adminPollUI
		}
		local position = container.Position
		local v7 = false
		local v8 = nil
		local completedConnection = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function cancelTween()
			if completedConnection then
				completedConnection:Disconnect()
				completedConnection = nil
			end

			if v8 then
				v8:Cancel()
				v8 = nil
			end
		end

		local function hiddenPosition()
			return UDim2.new(position.X.Scale, position.X.Offset, -1 - container.Size.Y.Scale, 0)
		end

		local function setShown(p)
			if v7 == p then
				return
			end

			v7 = p
			cancelTween() -- equivalent call inferred; original call site unknown

			if p then
				if not container.Visible then
					container.Position = UDim2.new(position.X.Scale, position.X.Offset, -1 - container.Size.Y.Scale, 0)
				end

				container.Visible = true
			end

			local v9 = math.clamp(
				tonumber(container:GetAttribute(p and "SlideInSeconds" or "SlideOutSeconds")) or p and 0.35 or 0.25,
				0.05,
				2
			)
			local tween = TweenService:Create(
				container,
				TweenInfo.new(v9, Enum.EasingStyle.Quad, p and Enum.EasingDirection.Out or Enum.EasingDirection.In),
				{
					Position = p and position or UDim2.new(
						position.X.Scale,
						position.X.Offset,
						-1 - container.Size.Y.Scale,
						0
					)
				}
			)
			v8 = tween
			completedConnection = tween.Completed:Connect(function(p2)
				if v8 ~= tween then
					return
				end

				if completedConnection then
					completedConnection:Disconnect()
					completedConnection = nil
				end

				v8 = nil

				if p2 == Enum.PlaybackState.Completed then
					if not v7 then
						container.Visible = false
					end

					container.Position = position
				end
			end)
			tween:Play()
		end

		container.Destroying:Connect(cancelTween)
		container.Visible = false
		poll.Visible = true
		adminPollUI.Enabled = true

		for i = 1, 4 do
			local child = choices:WaitForChild("Choice" .. i)
			v[i] = {
				Button = child,
				Text = child:WaitForChild("Label"),
				Count = child:WaitForChild("Count"),
				Fill = child:WaitForChild("VotesFill"),
				Stroke = child:WaitForChild("SelectionStroke"),
				Winner = child:WaitForChild("WinnerStroke"),
				Hover = child.AutoButtonColor
			}
			local v9 = i
			child.Activated:Connect(function()
				local serverTimeNow = workspace:GetServerTimeNow()

				if not v2 or v3 == v9 or serverTimeNow < v5 or v2.EndsAt <= serverTimeNow then
					return
				end

				v5 = serverTimeNow + 1
				v3 = v9
				v4 = true
				error = nil
				v6.Tick(workspace:GetServerTimeNow())
				callback(v2.Id, v9)
			end)
		end

		function v6.Set(data, p)
			local v9 = v2 and data and v2.Id == data.Id
			v2 = data

			if v9 then
				if p then
					choice = p

					if not v4 then
						v3 = p
					end
				end
			else
				v3 = p
				choice = p
				v4 = false
				error = nil
				v5 = 0
			end

			setShown(data ~= nil and workspace:GetServerTimeNow() < data.EndsAt + (data.ResultSeconds or 4))

			if not data then
				return
			end

			scope.Text = data.Scope == "Global" and "GLOBAL POLL" or "SERVER POLL"
			question.Text = data.Question

			for k, v12 in v do
				v12.Button.Visible = data.Choices[k] ~= nil
				v12.Text.Text = data.Choices[k] or ""
			end

			v6.Tick(workspace:GetServerTimeNow())
		end

		function v6.Acknowledge(data)
			if not v2 or v2.Id ~= data.Id then
				return
			end

			if data.Choice then
				choice = data.Choice
			end

			if not data.KeepSelection then
				if not data.Sync then
					v4 = false
				end

				v3 = choice
				error = data.Error
			end

			v6.Tick(workspace:GetServerTimeNow())
		end

		function v6.Tick(p)
			if not v2 then
				return
			end

			if v2.EndsAt + (v2.ResultSeconds or 4) <= p then
				setShown(false)
				return
			end

			local v9 = v2.EndsAt <= p
			timer.Text = v9 and "CLOSED" or math.ceil(v2.EndsAt - p) .. "s"
			local total = 0
			local v10 = 0

			for _, count in v2.Counts do
				total += count
				v10 = math.max(v10, count)
			end

			for k, v11 in v do
				local v12 = v2.Counts[k] or 0
				local v13 = not (total > 0) and 0 or v12 / total or 0
				v11.Fill.Size = UDim2.fromScale(v13, 1)
				v11.Count.Text = ("%d votes  %d%%"):format(v12, (math.floor(v13 * 100 + 0.5))) .. (v3 == k and "  [YOU]" or "")
				local winner = v11.Winner
				local enabled

				if v9 then
					if v2.Scope == "Global" and v2.Final ~= true or v12 ~= v10 then
						enabled = false
					else
						enabled = v10 > 0
					end
				else
					enabled = v9
				end

				winner.Enabled = enabled
				local stroke = v11.Stroke
				stroke.Enabled = v3 == k and not v11.Winner.Enabled
				local button = v11.Button
				local active = not v9

				if active then
					if v3 == k then
						active = false
					else
						active = v5 <= p
					end
				end

				button.Active = active
				v11.Button.Selectable = v11.Button.Active
				v11.Button.AutoButtonColor = v11.Button.Active and v11.Hover
			end

			local v11

			if v9 then
				if v2.Scope == "Global" and v2.Final ~= true then
					v11 = v2.CountsDelayed and "Results delayed — totals are not final" or "Counting remaining votes..."
				else
					v11 = total == 0 and "No votes cast" or "Final results"
				end
			else
				v11 = error or v2.CountsDelayed and "Live totals delayed" or p < v5 and "Wait 1 second to change answer" or v4 and "Answer selected — syncing..." or v3 and "Answer recorded — you can change it" or "Choose an answer"
			end

			status.Text = ("%s  |  %d total votes"):format(v11, total)
		end

		return v6
	end
}
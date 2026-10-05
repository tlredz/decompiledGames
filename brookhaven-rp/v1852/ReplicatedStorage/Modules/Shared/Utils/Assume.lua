return {
	new = function(validationFunction)
		local class = {}
		local flag = false
		local v = false
		local lastTime = nil
		class.validationFunction = validationFunction
		class.validationResult = {}
		class.checkerFunction = nil
		class.onCorrect = {}
		class.onWrong = {}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function assertIsRunning()
			if flag then
				error("Assume is already running")
			end
		end

		function class.Check(p, checkerFunction)
			assertIsRunning() -- equivalent call inferred; original call site unknown
			class.checkerFunction = checkerFunction
			return p
		end

		function class:Then(callback)
			if not class:IsValidationFinished() then
				table.insert(class.onCorrect, callback)
				return self
			end

			if class.checkerFunction(class:Await()) == true then
				task.spawn(callback, class:Await())
			end
		end

		function class:Else(callback)
			if not class:IsValidationFinished() then
				table.insert(class.onWrong, callback)
				return self
			end

			if class.checkerFunction(class:Await()) == false then
				task.spawn(callback, class:Await())
			end
		end

		function class.ThenOrElse(_, callback)
			class:Then(callback)
			class:Else(callback)
		end

		function class.Run(data, callback)
			assertIsRunning() -- equivalent call inferred; original call site unknown
			flag = true

			if not class.checkerFunction then
				error("No checker function declared!")
			end

			if callback then
				callback()
			end

			task.spawn(function()
				class.validationResult = table.pack(data.validationFunction())
				v = true
				lastTime = tick()

				if class.checkerFunction(table.unpack(class.validationResult)) then
					for _, v2 in pairs(data.onCorrect) do
						v2(table.unpack(class.validationResult))
					end
				else
					for _, v2 in pairs(data.onWrong) do
						v2(table.unpack(class.validationResult))
					end
				end
			end)
			return data
		end

		function class:Await()
			if not flag then
				error("Assume is not yet running")
			end

			while not v do
				task.wait()
			end

			return table.unpack(class.validationResult)
		end

		function class:IsValidationFinished()
			return v
		end

		function class.GetValidationFinishTimeframe(_)
			if lastTime then
				return tick() - lastTime
			end

			return -1
		end

		function class.Destroy(_)
			class = nil
		end

		return class
	end
}
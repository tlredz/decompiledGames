local Math = {}

function Math.RoundToDecimalPlaces(_, p, p2)
	return math.floor(p * 10 ^ p2) / 10 ^ p2
end

function Math.GenerateMathQuestionAndChoices(_, value)
	print(value)
	local v = {
		easy = {
			ops = { "+", "-" },
			maxNum = 10,
			numOps = 1,
			maxMD = 10
		},
		hard = {
			ops = {
				"+",
				"-",
				"x",
				"/"
			},
			maxNum = 10,
			numOps = 2,
			maxMD = 9
		},
		extreme = {
			ops = {
				"+",
				"-",
				"x",
				"/"
			},
			maxNum = 10,
			numOps = { 3, 5 },
			maxMD = 9
		}
	}
	local v2 = v[value or "easy"] or v.easy
	local ops = v2.ops
	local maxNum = v2.maxNum
	local v3 = type(v2.numOps) == "table" and math.random(v2.numOps[1], v2.numOps[2]) or v2.numOps
	local maxMD = v2.maxMD

	-- equivalent calls inferred from this helper; original call sites unknown
	local function chooseOp()
		return ops[math.random(#ops)]
	end

	local function randInt(maxNum2)
		return math.random(1, maxNum2)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function table_find(list, p)
		for _, v4 in ipairs(list) do
			if v4 == p then
				return true
			end
		end

		return false
	end

	local function makeDivisor(p)
		if p <= 0 then
			return 1
		end

		local v4 = {}

		for i = 1, math.min(maxMD, p) do
			if p % i == 0 then
				table.insert(v4, i)
			end
		end

		return #v4 > 0 and v4[math.random(#v4)] or 1
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function calc(p, p2, p3)
		if p2 == "+" then
			return p + p3
		elseif p2 == "-" then
			return p - p3
		elseif p2 == "x" then
			return p * p3
		end

		if p3 == 0 or p % p3 ~= 0 then
			return nil
		end

		return p / p3
	end

	local count = 0
	local question = nil
	local correctAnswer = nil
	local choices = nil

	while count < 1000 do
		count += 1
		local v7 = { randInt(maxNum) }
		local v8 = {}

		for _ = 1, v3 do
			local op = chooseOp() -- equivalent call inferred; original call site unknown
			local v10

			if op == "x" then
				v10 = math.random(1, maxMD)
			elseif op == "/" then
				v10 = makeDivisor(v7[#v7])
			elseif op == "-" then
				local v11 = v7[#v7]
				v10 = math.random(1, v11)
			else
				v10 = math.random(1, maxNum)
			end

			table.insert(v8, op)
			table.insert(v7, v10)
		end

		local v9 = {}

		for i = 1, #v7 do
			table.insert(v9, (tostring(v7[i])))

			if i <= #v8 then
				table.insert(v9, " " .. v8[i] .. " ")
			end
		end

		question = table.concat(v9) .. " = ?"
		local clone = table.clone(v7)
		local clone2 = table.clone(v8)
		local v10 = 1
		local flag = true

		while v10 <= #clone2 do
			if clone2[v10] == "x" or clone2[v10] == "/" then
				local v14 = calc(clone[v10], clone2[v10], clone[v10 + 1]) -- equivalent call inferred; original call site unknown

				if v14 == nil then
					flag = false
					break
				end

				clone[v10] = v14
				table.remove(clone, v10 + 1)
				table.remove(clone2, v10)
				v10 -= 1
			end

			v10 += 1
		end

		if flag then
			local v11 = clone[1]

			for i = 1, #clone2 do
				local v14 = calc(v11, clone2[i], clone[i + 1]) -- equivalent call inferred; original call site unknown

				if v14 == nil then
					flag = false
					break
				else
					v11 = v14
				end
			end

			if flag and v11 >= 0 and v11 == math.floor(v11) then
				correctAnswer = v11
			else
				flag = false
			end
		end

		if not (flag and correctAnswer) then
			continue
		end

		choices = { (tostring(correctAnswer)) }
		local v11 = {
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8,
			9,
			10,
			15,
			20,
			25,
			30,
			50
		}

		for i = #v11, 2, -1 do
			local v12 = math.random(i)
			local v13 = v11[v12]
			local v14 = v11[i]
			v11[i] = v13
			v11[v12] = v14
		end

		local count2 = 0

		for _, v12 in ipairs(v11) do
			if count2 >= 3 then
				break
			end

			local v13 = correctAnswer + v12
			local v14 = correctAnswer - v12

			if v14 >= 0 then
				-- equivalent call inferred; original call site unknown
				if not table_find(choices, tostring(v14)) then
					table.insert(choices, (tostring(v14)))
					count2 += 1
				end
			end

			if not (count2 < 3) then
				continue
			end

			-- equivalent call inferred; original call site unknown
			if table_find(choices, tostring(v13)) then
				continue
			end

			table.insert(choices, (tostring(v13)))
			count2 += 1
		end

		local v12 = {
			correctAnswer * 2,
			math.floor(correctAnswer / 2),
			correctAnswer + 100,
			correctAnswer + 10
		}

		for _, v14 in ipairs(v12) do
			if #choices >= 4 then
				break
			end

			if not (v14 >= 0 and v14 == math.floor(v14)) then
				continue
			end

			-- equivalent call inferred; original call site unknown
			if not table_find(choices, tostring(v14)) then
				table.insert(choices, (tostring(v14)))
			end
		end

		while #choices < 4 do
			local v14 = math.random(0, correctAnswer + 50)

			-- equivalent call inferred; original call site unknown
			if not table_find(choices, tostring(v14)) then
				table.insert(choices, (tostring(v14)))
			end
		end

		for i = #choices, 2, -1 do
			local v14 = math.random(i)
			local v15 = choices[v14]
			local v16 = choices[i]
			choices[i] = v15
			choices[v14] = v16
		end

		break
	end

	if not (question and correctAnswer and choices) then
		question = "1 + 1 = ?"
		choices = {
			"2",
			"1",
			"3",
			"0"
		}
		correctAnswer = 2
	end

	return {
		Question = question,
		Choices = choices,
		CorrectAnswer = correctAnswer
	}
end

function Math.ConvertNumberIntoBinary(_, p)
	if p == 0 then
		return "0"
	end

	local v = ""

	while p > 0 do
		v = p % 2 .. v
		p = math.floor(p / 2)
	end

	return v
end

function Math.SumOfSequence(_, p, p2)
	if p == p2 then
		return 0
	end

	return (p2 - p + 1) / 2 * (p + p2)
end

return Math
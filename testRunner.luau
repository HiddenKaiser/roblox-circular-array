-- Author: HiddenKaiser
-- Date: 2025-05-05
-- Description: Runs test cases to verify the functionality of the circular array module.

local circularArray = require(script.Parent.circularArray) -- fix path if you want to test this

local _iHash, _iHashRev = circularArray._iHash, circularArray._iHashRev

-- run test cases to verify the functionality of the circular array
local function runTestCases()
    type TestCase = {
        Function: () -> any,
        Expected: any,
    }

    local TestCases : {TestCase} = {
        {
            Function = function()
                local arr = circularArray.create(5, 0)
                for i = 1, 5 do
                    circularArray.set(arr, i, i)
                end
                local results = {}
                for i = 1, 7 do
                    table.insert(results, circularArray.toArray(arr))
                    circularArray.shift1(arr)
                end
                return results
            end,
            Expected = {
                {1, 2, 3, 4, 5},
                {2, 3, 4, 5, 1},
                {3, 4, 5, 1, 2},
                {4, 5, 1, 2, 3},
                {5, 1, 2, 3, 4},
                {1, 2, 3, 4, 5},
                {2, 3, 4, 5, 1},
            },
        },

        {
            Function = function()
                local arr = circularArray.create(5, 0)
                for i = 1, 5 do
                    circularArray.set(arr, i, i)
                end
                local results = {}
                for i = 1, 7 do
                    table.insert(results, circularArray.toArray(arr))
                    circularArray.shift(arr, -1)
                end
                return results
            end,
            Expected = {
                {1, 2, 3, 4, 5},
                {5, 1, 2, 3, 4},
                {4, 5, 1, 2, 3},
                {3, 4, 5, 1, 2},
                {2, 3, 4, 5, 1},
                {1, 2, 3, 4, 5},
                {5, 1, 2, 3, 4},
            },
        },

        {
            Function = function()
                local arr = circularArray.create(6, 0)
                for i = 1, 6 do
                    circularArray.set(arr, i, i)
                end
                local results = {}
                for i = 1, 6 do
                    table.insert(results, circularArray.toArray(arr))
                    circularArray.shift(arr, -3)
                end
                circularArray.shift(arr, 3)
                circularArray.setStart(arr, arr[1]) -- test setStart
                local getTested = {}
                for i = 1, 6 do
                    getTested[i] = circularArray.get(arr, i)
                end
                table.insert(results, getTested)
                return results
            end,
            -- shifts by -3
            Expected = {
                {1, 2, 3, 4, 5, 6},
                {4, 5, 6, 1, 2, 3},
                {1, 2, 3, 4, 5, 6},
                {4, 5, 6, 1, 2, 3},
                {1, 2, 3, 4, 5, 6},
                {4, 5, 6, 1, 2, 3},
                {4, 5, 6, 1, 2, 3},
            },
        },

        {
            Function = function()
                local arr = circularArray.create(5, 0)
                for i = 1, 5 do
                    circularArray.set(arr, i, i)
                end
                local results = {}
                table.insert(results, circularArray.get(arr, 0)) -- should be 5, to wrap around
                return results
            end,
            Expected = {5},
        },

        { -- test _iHashRev
            Function = function()
                local arr = circularArray.create(5, 0)
                for i = 1, 5 do
                    circularArray.set(arr, i, i)
                end
                local results = {}
                for i = 1, 5 do
                    local rawi = circularArray._rawIndex(arr, i)
                    table.insert(results, _iHashRev(arr[1], arr[2], rawi))
                end
                return results
            end,
            Expected = {1, 2, 3, 4, 5},
        },

        {
            Function = function()
                -- test sorting
                local arr = circularArray.create(7, 0)
                for i = 7, 1, -1 do
                    circularArray.set(arr, i, math.random(1, 100))
                end
                local results = {}
                --print("unsorted", "{"..table.concat(circularArray.toArray(arr), ", ").."}")
                --print("arr", "{"..table.concat(arr, ", ", 3).."}")
                circularArray.sort(arr)
                --print("sorted", "{"..table.concat(circularArray.toArray(arr), ", ").."}")
                --print("arr", "{"..table.concat(arr, ", ", 3).."}")

                local function isSorted(arr: {any}): boolean
                    for i = 1, arr[2]-1 do
                        local a,b = circularArray.get(arr, i), circularArray.get(arr, i+1)
                        if a > b then
                            print("not sorted", a, b, " i=", i)
                            return false
                        end
                    end
                    return true
                end

                table.insert(results, isSorted(arr))
                return results
            end,
            Expected = {true},
        },

    }

    -- if subtable, then recurse, otherwise compare the values
    local function deepCompareTable(a: {any}, b: {any}, depth: string?): (boolean, string?, any?, any?)
        --if #a ~= #b then return false end
        for i, v in a do
            local curDepth: string = (depth or ".") .. `[{i}]`
            if type(a[i]) == "table" and type(b[i]) == "table" then
                local x, d, y, z = deepCompareTable(a[i], b[i], curDepth)
                if not x then
                    return false, d, y, z
                end
            elseif a[i] ~= b[i] then
                return false, curDepth, a[i], b[i]
            end
        end
        return true, nil, nil, nil
    end
    

    local testCasesPassed = 0
    for i, testCase in ipairs(TestCases) do
        local result = testCase.Function()
        local success, depth, expected, got = deepCompareTable(result, testCase.Expected)
        if not success then
            warn(`[circularArray.runTestCases] FAILED Test #{i} failed at {depth}. ({got}~={expected}). Got`, result, "expected", testCase.Expected)
        else
            testCasesPassed += 1
        end
    end

    local function roundToDecimal(num: number, decimal: number): number
        local mult: number = 10 ^ decimal
        return math.round(num * mult) / mult
    end

    -- Print the number and percent of test cases passed
    local n: number = #TestCases
    print(`[circularArray.runTestCases] Passed {testCasesPassed}/{n} test cases ({roundToDecimal((testCasesPassed / n) * 100, 3)}%)`)
    -- print number of test cases failed
    local nFailed = n - testCasesPassed
    if nFailed > 0 then
        warn(`[circularArray.runTestCases] Failed {nFailed}/{n} test cases ({roundToDecimal((nFailed / n) * 100, 3)}%)`)
    end
end

return runTestCases

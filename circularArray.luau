--!strict

-- Author: HiddenKaiser
-- Date: 2025-05-05
-- Name: circularArray.luau
-- Description: Implements a circular array data structure that allows for infinite looping of indices.

-- (s, n, x₁, x₂, ..., xn).   #arr => n+2
export type CircularArray = {any}

--[[
circularArray Module Documentation
----------------------------------

create(n: number?, initValue: any?) → CircularArray
    Creates a new circular array of size `n` (default 1), with all values initialized to `initValue` (optional).
    Internally prepends metadata: [startIndex, length, ...data].

get(arr: CircularArray, index: number) → any
    Returns the value at the logical index `index` in the circular array, wrapping around as needed.

set(arr: CircularArray, index: number, value: any)
    Sets the value at the logical index `index` in the circular array, wrapping around as needed.

getN(arr: CircularArray) → number
    Returns the number of elements in the circular array. I reccomend you just use arr[2] instead of this function.

insert(arr: CircularArray, index: number, value: any?)
    Inserts a value at the logical index. If only one argument is passed (value), it inserts at the end.

remove(arr: CircularArray, index: number) → any
    Removes and returns the value at the logical index in the circular array.

*popPushQueue(arr: CircularArray, value: any) → any
    pops the queue, and pushes the passed value
    takes out the first value of the array, and appends the passed value to the end of the array
    the queue is First-in, First-out (FIFO)
    > One of the most common and most *powerful* use cases for a circular array
    Returns the removed (first) element.

pop(arr: CircularArray) → any
    Removes and returns the last item in the circular array.

popFirst(arr: CircularArray) → any
    Removes and returns the first item in the circular array.

_rawIndex(arr: CircularArray, index: number) → number
    Returns the internal raw index corresponding to the logical index.
    Useful for debugging or low-level access.

find(arr: CircularArray, value: any) → number?
    Returns the logical index of the first occurrence of `value`, or nil if not found.

findRev(arr: CircularArray, value: any) → number?
    Returns the logical index of the last occurrence of `value`, or nil if not found.

setStart(arr: CircularArray, start: number)
    Sets the start index of the circular array to `start`. Wraps around automatically.

shift(arr: CircularArray, n: number)
    Shifts (rotates) the logical view of the array by `n` positions.

shift1(arr: CircularArray)
    Shorthand for shift by 1. Rotates the array forward one position.

toArray(circArr: CircularArray) → {any}
    Returns a standard Lua array containing the logical contents of the circular array.

sort(arr: CircularArray)
    Sorts the contents of the circular array in-place using quicksort.
    Resets the logical start index to 1 afterward.

--]]


local circularArray = {}

-- Index Hashing Function. Allows for infinite looping of array indices while remaining compatible with the CircularArray datatype
-- Returned value will always be between 3 and n+2.
@native
local function _iHash(s: number, n: number, i: number): number
    return (s + i - 2) % n + 3
end
circularArray._iHash = _iHash

-- takes in an ihask index, and returns the original index 1-n
local function _iHashRev(s: number, n: number, i: number): number
    return (i - 2 - s) % n + 1
end
circularArray._iHashRev = _iHashRev

function circularArray.create(n: number?, initValue: any?) : CircularArray
    local arr : CircularArray = table.create(n or 1, initValue)
    table.insert(arr, 1, n or 1) -- insert arr[2], # of elements
    table.insert(arr, 1, 1) -- insert arr[1], the start index
    return arr
end

-- pull from arr[3, ..n]. if start is 2, then .get(arr, 1) = arr[4]. Use modulo for wrapping around
function circularArray.get(arr: CircularArray, index: number): any
    local s: number, n: number = arr[1], arr[2]
    local i: number = _iHash(s, n, index)
    return arr[i]
end
function circularArray.set(arr: CircularArray, index: number, value: any)
    local s: number, n: number = arr[1], arr[2]
    local i: number = _iHash(s, n, index)
    arr[i] = value
end

function circularArray.insert(arr: CircularArray, index: any, value: any?)
    local s: number, n: number = arr[1], arr[2]
    if value == nil then
        value, index = index, n
    end -- function overloading
    local i = _iHash(s, n, index)
    table.insert(arr, i, value) -- insert the value at the specified circular index
    arr[2] += 1 -- increment size of array by 1
end

function circularArray.remove(arr: CircularArray, index: number): any
    local s: number, n: number = arr[1], arr[2]
    local i: number = _iHash(s, n, index)
    local value: any = arr[i] -- get the value at the specified circular index
    table.remove(arr, i) -- remove the value at the specified circular index
    arr[2] -= 1 -- decrement size of array by 1
    return value -- return the removed value
end

function circularArray.pop(arr: CircularArray): any
    return circularArray.remove(arr, 0) -- remove the last value of the array
end
function circularArray.popFirst(arr: CircularArray): any
    return circularArray.remove(arr, 1) -- remove the first value of the array
end


-- pops the queue, and pushes the passed value
-- takes out the first value of the array, and appends the passed value to the end of the array
-- the queue is First-in, First-out (FIFO)
-- one of the most common use cases for a circular array
function circularArray.popPushQueue(arr: CircularArray, value: any): any
    local s: number, n: number = arr[1], arr[2]
    local i: number = s % n + 3     -- calculate the circular index at i=1
    local firstValue: any = arr[i]  -- get the first value of the array
    arr[i] = value  -- set the first value to the passed value
    arr[1] += 1     -- increment the start index by 1 to shift the inserted value to the end of the array
    return firstValue
end


-- returns the result of _iHash on the array
function circularArray._rawIndex(arr: CircularArray, index: number): number
    return _iHash(arr[1], arr[2], index) -- return the circular index of the array
end

-- finds a value in the array and returns the circular index of the value, or nil if it does not exist
function circularArray.find(arr: CircularArray, value: any): number?
    if arr[2] == 0 then return nil end -- if the array is empty, return nil
    for i = 3, arr[2] + 2 do
        if arr[i] == value then
            return _iHashRev(arr[1], arr[2], i)
        end
    end
    return nil -- return -1 if the value is not found in the array
end

-- performs the find operation in reverse order, useful for performance
function circularArray.findRev(arr: CircularArray, value: any): number?
    if arr[2] == 0 then return nil end -- if the array is empty, return nil
    for i = arr[2] + 2, 3, -1 do
        if arr[i] == value then
            return _iHashRev(arr[1], arr[2], i)
        end
    end
    return nil -- return -1 if the value is not found in the array
end


-- sets the start index of the array to the passed value
function circularArray.setStart(arr: CircularArray, start: number)
    arr[1] = (start-1) % arr[2] + 1 -- arr[2] is the n value
end
-- shifts the array by n
function circularArray.shift(arr: CircularArray, n: number)
    arr[1] += n
end
-- shifts the array by 1
function circularArray.shift1(arr: CircularArray)
    arr[1] += 1
end

-- returns the size of the array
function circularArray.getN(arr: CircularArray): number
    return arr[2]
end

-- Returns the array as a normal array, compiled by 
function circularArray.toArray(circArr: CircularArray): {any}
    local n: number = circArr[2]
    if n <= 0 then return {} :: {any} end
    local arr: {any} = table.create(n, circArr[3]) -- alloc
    for i = 1, n do
        arr[i] = circularArray.get(circArr, i)
    end
    return arr
end


@native
local function _qs_partition(arr: {any}, low: number, high: number): number
    local pivot: any = arr[high] -- pivot element
    local i: number = low - 1 -- index of small
    for j = low, high-1 do
        if arr[j] <= pivot then
            i += 1 -- increment index of smaller element
            arr[i], arr[j] = arr[j], arr[i] -- swap elements
        end
    end
    arr[i+1], arr[high] = arr[high], arr[i+1] -- swap pivot with the element at index i+1
    return i + 1 -- return the index of the pivot element after partitioning
end

@native
local function _quicksort(arr: {any}, low: number, high: number)
    if low >= high then return end
    local pi: number = _qs_partition(arr, low, high) -- partition the array
    _quicksort(arr, low, pi - 1) -- sort the left half of the array
    _quicksort(arr, pi + 1, high) -- sort the right half of the array
end

-- performs quicksort on the array to sort it in-place
-- to improve performance, we will just sort arr[3, ..n+2] and set the start index to 1
function circularArray.sort(arr: CircularArray)
    local n: number = arr[2]
    if n <= 0 then return end -- if the array is empty, return nil
    _quicksort(arr, 3, n + 2) -- sort the array from index 3 to n+2 (the actual data)
    
    arr[1] = 1 -- set the start index to 1 after sorting
end


return circularArray

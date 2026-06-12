// Author: HiddenKaiser
// Date: 2025-05-05
// Name: circularArray.ts
// Description: Implements a circular array data structure that allows for infinite looping of indices.
// Caution: Less tested than the original Luau version

// (s, n, x₁, x₂, ..., xn).   #arr => n+2
type CircularArray<T extends defined = defined> = Array<T | number>;

type Sortable = string | number;

namespace circularArray {
	export type CircularArray<T extends defined = defined> = Array<T | number>;
}

const circularArray = {} as {
	_iHash: typeof _iHash;
	_iHashRev: typeof _iHashRev;
	create: typeof create;
	get: typeof get;
	set: typeof set;
	insert: typeof insert;
	remove: typeof remove;
	pop: typeof pop;
	popFirst: typeof popFirst;
	popPushQueue: typeof popPushQueue;
	_rawIndex: typeof _rawIndex;
	find: typeof find;
	findRev: typeof findRev;
	setStart: typeof setStart;
	shift: typeof shift;
	shift1: typeof shift1;
	getN: typeof getN;
	toArray: typeof toArray;
	sort: typeof sort;
};

function mod(x: number, n: number): number {
	return ((x % n) + n) % n;
}

// Index Hashing Function. Allows for infinite looping of array indices while remaining compatible with the CircularArray datatype
// Returned value will always be between 3 and n+2.
// roblox-ts note: TypeScript arrays are 0-indexed, so this returns 2 through n+1.
function _iHash(s: number, n: number, i: number): number {
	return mod(s + i - 2, n) + 2;
}
circularArray._iHash = _iHash;

// takes in an ihask index, and returns the original index 1-n
function _iHashRev(s: number, n: number, i: number): number {
	return mod(i - 1 - s, n) + 1;
}
circularArray._iHashRev = _iHashRev;

function create<T extends defined = defined>(n = 1, initValue?: T): CircularArray<T> {
	const arr = table.create(n, initValue) as CircularArray<T>;
	arr.unshift(n); // insert arr[2], # of elements
	arr.unshift(1); // insert arr[1], the start index
	return arr;
}
circularArray.create = create;

// pull from arr[3, ..n]. if start is 2, then .get(arr, 1) = arr[4]. Use modulo for wrapping around
function get<T extends defined = defined>(arr: CircularArray<T>, index: number): T {
	const s = arr[0] as number;
	const n = arr[1] as number;
	const i = _iHash(s, n, index);
	return arr[i] as T;
}
circularArray.get = get;

function set<T extends defined = defined>(arr: CircularArray<T>, index: number, value: T): void {
	const s = arr[0] as number;
	const n = arr[1] as number;
	const i = _iHash(s, n, index);
	arr[i] = value;
}
circularArray.set = set;

function insert<T extends defined = defined>(arr: CircularArray<T>, index: number, value: T): void;
function insert<T extends defined = defined>(arr: CircularArray<T>, value: T): void;
function insert<T extends defined = defined>(arr: CircularArray<T>, indexOrValue: number | T, value?: T): void {
	const s = arr[0] as number;
	const n = arr[1] as number;

	let index: number;
	let insertValue: T;

	if (value === undefined) {
		insertValue = indexOrValue as T;
		index = n;
	} else {
		index = indexOrValue as number;
		insertValue = value;
	} // function overloading

	const i = _iHash(s, n, index);
	arr.insert(i, insertValue); // insert the value at the specified circular index
	arr[1] = n + 1; // increment size of array by 1
}
circularArray.insert = insert;

function remove<T extends defined = defined>(arr: CircularArray<T>, index: number): T {
	const s = arr[0] as number;
	const n = arr[1] as number;
	const i = _iHash(s, n, index);
	const value = arr[i] as T; // get the value at the specified circular index
	arr.remove(i); // remove the value at the specified circular index
	arr[1] = n - 1; // decrement size of array by 1
	return value; // return the removed value
}
circularArray.remove = remove;

function pop<T extends defined = defined>(arr: CircularArray<T>): T {
	return remove(arr, 0); // remove the last value of the array
}
circularArray.pop = pop;

function popFirst<T extends defined = defined>(arr: CircularArray<T>): T {
	return remove(arr, 1); // remove the first value of the array
}
circularArray.popFirst = popFirst;

// pops the queue, and pushes the passed value
// takes out the first value of the array, and appends the passed value to the end of the array
// the queue is First-in, First-out (FIFO)
// one of the most common use cases for a circular array
function popPushQueue<T extends defined = defined>(arr: CircularArray<T>, value: T): T {
	const s = arr[0] as number;
	const n = arr[1] as number;
	const i = mod(s, n) + 2; // calculate the circular index at i=1
	const firstValue = arr[i] as T; // get the first value of the array
	arr[i] = value; // set the first value to the passed value
	arr[0] = s + 1; // increment the start index by 1 to shift the inserted value to the end of the array
	return firstValue;
}
circularArray.popPushQueue = popPushQueue;

// returns the result of _iHash on the array
function _rawIndex<T extends defined = defined>(arr: CircularArray<T>, index: number): number {
	return _iHash(arr[0] as number, arr[1] as number, index); // return the circular index of the array
}
circularArray._rawIndex = _rawIndex;

// finds a value in the array and returns the circular index of the value, or nil if it does not exist
function find<T extends defined = defined>(arr: CircularArray<T>, value: T): number | undefined {
	const n = arr[1] as number;
	if (n === 0) return undefined; // if the array is empty, return nil

	for (let i = 2; i <= n + 1; i++) {
		if ((arr[i] as T) === value) {
			return _iHashRev(arr[0] as number, n, i);
		}
	}

	return undefined; // return -1 if the value is not found in the array
}
circularArray.find = find;

// performs the find operation in reverse order, useful for performance
function findRev<T extends defined = defined>(arr: CircularArray<T>, value: T): number | undefined {
	const n = arr[1] as number;
	if (n === 0) return undefined; // if the array is empty, return nil

	for (let i = n + 1; i >= 2; i--) {
		if ((arr[i] as T) === value) {
			return _iHashRev(arr[0] as number, n, i);
		}
	}

	return undefined; // return -1 if the value is not found in the array
}
circularArray.findRev = findRev;

// sets the start index of the array to the passed value
function setStart<T extends defined = defined>(arr: CircularArray<T>, start: number): void {
	arr[0] = mod(start - 1, arr[1] as number) + 1; // arr[2] is the n value
}
circularArray.setStart = setStart;

// shifts the array by n
function shift<T extends defined = defined>(arr: CircularArray<T>, n: number): void {
	arr[0] = (arr[0] as number) + n;
}
circularArray.shift = shift;

// shifts the array by 1
function shift1<T extends defined = defined>(arr: CircularArray<T>): void {
	arr[0] = (arr[0] as number) + 1;
}
circularArray.shift1 = shift1;

// returns the size of the array
function getN<T extends defined = defined>(arr: CircularArray<T>): number {
	return arr[1] as number;
}
circularArray.getN = getN;

// Returns the array as a normal array, compiled by
function toArray<T extends defined = defined>(circArr: CircularArray<T>): Array<T> {
	const n = circArr[1] as number;
	if (n <= 0) return [];

	const arr = table.create(n, circArr[2] as T) as Array<T>; // alloc

	for (let i = 1; i <= n; i++) {
		arr[i - 1] = get(circArr, i);
	}

	return arr;
}
circularArray.toArray = toArray;

function _qs_partition<T extends Sortable>(arr: Array<T | number>, low: number, high: number): number {
	const pivot = arr[high] as T; // pivot element
	let i = low - 1; // index of small

	for (let j = low; j <= high - 1; j++) {
		if ((arr[j] as number) <= (pivot as number)) {
			i += 1; // increment index of smaller element

			const temp = arr[i];
			arr[i] = arr[j];
			arr[j] = temp; // swap elements
		}
	}

	const temp = arr[i + 1];
	arr[i + 1] = arr[high];
	arr[high] = temp; // swap pivot with the element at index i+1

	return i + 1; // return the index of the pivot element after partitioning
}

function _quicksort<T extends Sortable>(arr: Array<T | number>, low: number, high: number): void {
	if (low >= high) return;

	const pi = _qs_partition<T>(arr, low, high); // partition the array
	_quicksort<T>(arr, low, pi - 1); // sort the left half of the array
	_quicksort<T>(arr, pi + 1, high); // sort the right half of the array
}

// performs quicksort on the array to sort it in-place
// to improve performance, we will just sort arr[3, ..n+2] and set the start index to 1
function sort<T extends Sortable>(arr: CircularArray<T>): void {
	const n = arr[1] as number;
	if (n <= 0) return; // if the array is empty, return nil

	_quicksort<T>(arr, 2, n + 1); // sort the array from index 3 to n+2 (the actual data)

	arr[0] = 1; // set the start index to 1 after sorting
}
circularArray.sort = sort;

export = circularArray;

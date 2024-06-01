import Zip "lib";
// import D "mo:base/Debug";
import Nat "mo:base/Nat";
import Prim "mo:⛔";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";

actor {
	// let print = D.print;
	public query func prob(input: Text): async [(Nat8, Nat)]{
		Zip.calculateFrequencies(input)
	};

	public query func sort(arr: [Nat]): async [Nat]{
		Zip.quickSort<Nat>(arr, compare);
	};

	func compare(a: Nat, b: Nat): {#less; #equal; #greater}{
		if(a < b){return #less}
		else if(a == b) {return #equal}
		else{return #greater};
	};

	public query func subArray(arr : [Nat], end : Nat) :async  [Nat] {
        Prim.Array_tabulate<Nat>(end, func x = arr[x]);	
    };

	// public func quickSort(arr: [Nat]): async [Nat]{
		
	// };

	// func _quickSort(arr: [var Nat], cmp: (Nat, Nat) -> {#less; #equal; #greater}): [var Nat]{
	// 	let size = arr.size();
	// 	if(size <= 0) {
	// 		return arr
	// 	};
	// 	let lessNumbers = Buffer.fromArray<Nat>([]);
	// 	let greaterNumbers = Buffer.fromArray<Nat>([]);
	// 	let pivote = arr[size/2];
	// 	var index = 0;
	// 	while(index < size){
	// 		if (index != size/2){
	// 			if(cmp(arr[index], pivote) == #less){
	// 				lessNumbers.add(arr[index])
	// 			}
	// 			else {
	// 				greaterNumbers.add(arr[index])
	// 			}
	// 		};
	// 		index += 1;
	// 	};
	// 	index := 0;
	// 	for(left in _quickSort(lessNumbers, cmp).vals()){
	// 		arr[index] := left;
	// 		index += 1
	// 	};
	// 	arr[index] := pivote;
	// 	index += 1;
	// 	for(rigth in _quicksort(greaterNumbers, cmp).vals()){
	// 		arr[index]
	// 	}
 	// }
	

};

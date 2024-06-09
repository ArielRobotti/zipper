import Zip "lib";
// import D "mo:base/Debug";
import Nat "mo:base/Nat";
// import Prim "mo:⛔";
// import Debug "mo:base/Debug";
import Principal "mo:base/Principal";

actor {

	// public query func prob(input: Text): async [var (Nat8, Nat)]{
	// 	Zip.quickSort<(Nat8, Nat)>(Zip.calculateFrequencies(input), cmpProb)
	// };

	public query func sort(arr: [Nat]): async [Nat]{
		Zip.quickSort<Nat>(arr, compare);
	};

	// func cmpProb(a: (Nat8, Nat), b: (Nat8, Nat)): {#less; #equal; #greater}{
	// 	return if(a.1 < b.1){ 
	// 		#less
	// 	}
	// 	else {
	// 		#greater
	// 	}
	// };

	func compare(a: Nat, b: Nat): {#less; #equal; #greater}{
		if(a < b){return #less}
		else if(a == b) {return #equal}
		else{return #greater};
	};
	let myVar = "456sd";
	public shared ({caller}) func s(): async  Text{
		assert(not Principal.isAnonymous(caller));
		myVar
	};

	public query ({caller}) func q(): async Text{
		assert(not Principal.isAnonymous(caller));
		myVar
	};

	public func getCodes(input: Text): async [(Nat8, Text)]{
		Zip.getHuffmanCodes(input);
	}

};

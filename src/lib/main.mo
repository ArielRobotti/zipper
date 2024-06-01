import Zip "lib";
// import D "mo:base/Debug";
import Nat "mo:base/Nat";
import Prim "mo:⛔";
import Debug "mo:base/Debug";

actor {

	public query func prob(input: Text): async [(Nat8, Nat)]{
		Zip.quickSort<(Nat8, Nat)>(Zip.calculateFrequencies(input), cmpProb)
	};

	public query func sort(arr: [Nat]): async [Nat]{
		Zip.quickSort<Nat>(arr, compare);
	};

	func cmpProb(a: (Nat8, Nat), b: (Nat8, Nat)): {#less; #equal; #greater}{
		return if(a.1 < b.1){ 
			#less
		}
		else {
			#greater
		}
	};

	func compare(a: Nat, b: Nat): {#less; #equal; #greater}{
		if(a < b){return #less}
		else if(a == b) {return #equal}
		else{return #greater};
	};

};

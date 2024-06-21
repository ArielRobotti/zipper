import Zip "lib";
import Map "mo:map/Map";
import Types "types";

actor {
	public query func getCodes(input : Text) : async [(Nat8, { len : Nat; value : Nat })] {
		let zip = Zip.getCodes(input);
		let a = Map.toArray<Nat8, { len : Nat; value : Nat }>(zip.1);
		 a;
	};

	public func getSize(a : Text) : async Nat {
		a.size();
	};

	public func encode(string : Text) : async Nat{
		Zip.encodeText(string).len;
	};

	public query func encodeDecode(a: Text): async [Nat8] {
		let encoded = Zip.encodeText(a);
		let decoded = Zip.decode(encoded);

	}
};

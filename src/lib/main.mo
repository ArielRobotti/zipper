import Zip "lib";
import Map "mo:map/Map";

actor {
	public query func getCodes(input : Text) : async ([(Nat8, Text)], [(Nat8, { bits : Nat; value : Nat })]) {
		let zip = Zip.getCodes(input);
		let a = Map.toArray<Nat8, { bits : Nat; value : Nat }>(zip.1);
		let b = Map.toArray<Nat8, Text>(zip.0);
		(b, a);
	};

	public func getSize(a : Text) : async Nat {
		a.size();
	};

	public func encode(string : Text) : async /* [Nat8] */ Nat{
		await Zip.encodeText(string);
	};
};

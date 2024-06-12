import Zip "lib";
import Map "mo:map/Map";

actor {
	public query func getCodes(input: Text): async [(Nat8, Text)]{
		Map.toArray<Nat8, Text>(Zip.getCodes(input));
	};

	public func getSize(a: Text): async Nat{
		a.size();
	};

};

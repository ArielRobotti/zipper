import Zip "lib";
import Map "mo:map/Map";
import { nhash } "mo:map/Map";
import Types "types";

actor {
	type ZippedData = Types.ZippedData;
	type FileId = Nat;
	stable let dataStorage = Map.new<FileId, ZippedData>();

	stable var generateFileId = 0;

	public func zip(data : Text) : async Nat {
		let zipped = Zip.encodeText(data);
		generateFileId += 1;
		ignore Map.put<Nat, ZippedData>(dataStorage, nhash, generateFileId, zipped);
		generateFileId;
	};

	public func unZip(id : Nat) : async ?[Nat8] {
		let zipped = Map.get<Nat, ZippedData>(dataStorage, nhash, id);
		switch (zipped) {
			case (?file) {
				?Zip.unZip(file);
			};
			case null { null };
		};
	};
	type InfoFile = {
		numBitsOfData : Nat;
		map : [(Types.HCode, Nat8)];
	};

	public query func getInfoFile(id : Nat) : async ?InfoFile {
		let zipped = Map.get<Nat, ZippedData>(dataStorage, nhash, id);
		switch zipped {
			case (?file) {
				?{
					numBitsOfData = file.len;
					map = Map.toArray<Types.HCode, Nat8>(file.map)
				};
			};
			case null {null}
		};

	};
	public query func getDataCompress (id: Nat): async ?Nat {
		switch(Map.get<Nat, ZippedData>(dataStorage, nhash, id)){
			case null {null};
			case(?data) {
				?data.payLoad
			};
		}
	}

};

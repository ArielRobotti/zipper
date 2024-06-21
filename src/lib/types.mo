import Map "mo:map/Map";
import Prim "mo:⛔";

module {
    public type Order = { #less; #equal; #greater };
    public type Node<T> = {
        elements : [T];
        prob : Nat;
    };
    public func cmpNodes(a : Node<Any>, b : Node<Any>) : Order {
        if (a.prob < b.prob) { #less } else { #greater };
    };

    public type HCode = {
        len : Nat;
        value : Nat;
    };

    func hashHCode(code : HCode) : Nat32 {
        let v = 2 ** code.len + code.value;
        Prim.natToNat32(v);
    };
    func eqHCode(a : HCode, b : HCode) : Bool {
        (a.len == b.len and a.value == b.value);
    };

    public let hCodeHash = (hashHCode, eqHCode);

    public type ZippedData = {
        map : Map.Map<HCode, Nat8>;
        len: Nat; //bits
        payLoad : Nat;
    };
};

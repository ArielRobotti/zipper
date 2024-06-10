import Prim "mo:⛔";
import Map "mo:map/Map";
import Nat "mo:base/Nat";
import { n8hash; thash } "mo:map/Map";
import Set "mo:map/Set";
import Debug "mo:base/Debug";
// import Nat "mo:base/Nat";

module {
    let print = Debug.print;
    //Temporal complexity O(n)
    public func calculateFrequencies(input : Text) : [var (Nat8, Nat)] {
        let tempArrayMut : [var Nat] = Prim.Array_init<Nat>(256, 0);
        let nat8Array = Prim.blobToArray(Prim.encodeUtf8(input));
        var cont = 0;
        for (i in nat8Array.vals()) {
            let index = Prim.nat8ToNat(i);
            tempArrayMut[index] := tempArrayMut[index] +1;
            if (tempArrayMut[index] == 1) {
                cont += 1;
            };
        };
        var index = 0;
        let result = Prim.Array_init<(Nat8, Nat)>(cont, (0, 0));
        while (index < 256) {
            if (tempArrayMut[index] != 0) {
                result[cont -1] := (Prim.natToNat8(index), tempArrayMut[index]);
                cont -= 1;
            };
            index += 1;
        };
        result;
    };

    public func quickSort<T>(arr : [T], cmp : (T, T) -> { #less; #equal; #greater }) : [T] {
        let size = arr.size();
        if (size <= 1) { return arr };
        var arrayMut = Prim.Array_init<T>(size, arr[0]);
        var index = 0;
        while (index < size) {
            arrayMut[index] := arr[index];
            index += 1;
        };
        arrayMut := _quickSort<T>(arrayMut, cmp);
        Prim.Array_tabulate<T>(size, func x = arrayMut[x]);
    };

    func headArray<T>(arr : [var T], end : Nat) : [var T] {
        let result = Prim.Array_init<T>(end, arr[0]);
        var index = 0;
        while (index < end) {
            result[index] := arr[index];
            index += 1;
        };
        result;
    };

    // temporal complexity O(n * Log(n))
    func _quickSort<T>(arr : [var T], cmp : (T, T) -> { #less; #equal; #greater }) : [var T] {

        let size = arr.size();
        if (size <= 1) { return arr };
        var leftNumbers = Prim.Array_init<T>(size, arr[0]);
        var rigthNumbers = Prim.Array_init<T>(size, arr[0]);
        var countLeft = 0;
        var countRigth = 0;
        let pivote = arr[size / 2];
        var index = 0;
        while (index < size) {
            if (index != size / 2) {
                if (cmp(arr[index], pivote) == #less) {
                    leftNumbers[countLeft] := arr[index];
                    countLeft += 1;
                } else {
                    rigthNumbers[countRigth] := arr[index];
                    countRigth += 1;
                };
            };
            index += 1;
        };
        leftNumbers := headArray(leftNumbers, countLeft);
        rigthNumbers := headArray(rigthNumbers, countRigth);
        let result = Prim.Array_init<T>(size, arr[0]);
        index := 0;
        for (l in _quickSort(leftNumbers, cmp).vals()) {
            result[index] := l;
            index += 1;
        };
        result[index] := pivote;
        index += 1;
        for (r in _quickSort(rigthNumbers, cmp).vals()) {
            result[index] := r;
            index += 1;
        };
        result;
    };

    type Node<T> = {
        elements : [T];
        prob : Nat;
    };

    func headTail<T>(arr : [var T]) : (T, [var T]) {
        let size = arr.size();
        if (size < 2) { return (arr[0], [var]) };
        let head = arr[0];
        let tail = Prim.Array_init<T>(size - 1, arr[0]);
        var i = 1;
        while (i < size) {
            tail[i - 1] := arr[i];
            i += 1;
        };
        (head, tail);
    };

    func buildHuffmanTree<T>(arr : [var (T, Nat)], hashEq : (T -> Nat32, (T, T) -> Bool)) : Map.Map<T, Text> {
        //En el return, el Nat representa la codificacion binaria del simbolo expresada en sistema decimal
        var size = arr.size();

        let stringCode = Map.new<T, Text>();
        var nodes = Prim.Array_init<Node<T>>(size, { elements = [arr[0].0]; prob = arr[0].1 });
        var index = 0;
        while (index < size) {
            nodes[index] := { elements = [arr[index].0]; prob = arr[index].1 };
            index += 1;
        };

        while (nodes.size() > 1) {

            let (head, tail) = headTail<Node<T>>(nodes);
            let setElements = Set.new<T>();   
            let sumProb : Nat = head.prob + tail[0].prob;

            for (left : T in head.elements.vals()) {
                let codeUpdateString = switch (Map.get<T, Text>(stringCode, hashEq, left)) {
                    case null { "1" };
                    case (?code) { "1" #code };
                };
                ignore Map.put<T, Text>(stringCode, hashEq, left, codeUpdateString);
                ignore Set.put<T>(setElements, hashEq, left);
            };
            for (rigth : T in tail[0].elements.vals()) {
                let currentStringCode = switch (Map.get<T, Text>(stringCode, hashEq, rigth)) {
                    case null { "0" };
                    case (?code) { "0" # code };
                };
                ignore Map.put<T, Text>(stringCode, hashEq, rigth, currentStringCode);
                ignore Set.put<T>(setElements, hashEq, rigth);
            };

            // let newNode = { elements = Set.toArray<T>(setElements); prob = sumProb};
            // var i  = 1;
            // while(i < tail.size()){
            //     if( tail[i].prob < sumProb){
            //         tail[i - 1] := tail[i];
            //         i += 1;  
            //     }
            //     else {
            //         tail[i - 1] := newNode;
            //         i := tail.size();
            //     };

            // };
            // nodes := tail;

            tail[0] := {
                elements = Set.toArray<T>(setElements);
                prob = sumProb;
            };
            nodes := _quickSort<Node<T>>(tail, func(a, b) = if (a.prob < b.prob) { #less } else { #greater });
        };
        stringCode;
    };

    func cmpProb(a : (Nat8, Nat), b : (Nat8, Nat)) : { #less; #equal; #greater } {
        return if (a.1 < b.1) {
            #less;
        } else {
            #greater;
        };
    };

    public func getHuffmanCodes(string : Text) : [(Nat8, Text)] {
        let frec = calculateFrequencies(string);
        let sortedInput = _quickSort<(Nat8, Nat)>(frec, cmpProb);
        let map = buildHuffmanTree<Nat8>(sortedInput, n8hash);
        // for (c in Prim.blobToArray(Prim.encodeUtf8(string)).vals()){
        //     print(switch(Map.get<Nat8, Text>(map, n8hash, c)){case null{""}; case(?c){c}});
        // };
        Map.toArray<Nat8, Text>(map);
    };

};

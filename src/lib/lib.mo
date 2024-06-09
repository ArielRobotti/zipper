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
        while(index < 256){
            if (tempArrayMut[index] != 0) { 
                result[cont-1] := (Prim.natToNat8(index), tempArrayMut[index]);
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

    type Arista<T> = {
        elements : [T];
        prob : Nat;
     };

    func buildHuffmanTree<T>(arr : [var (T, Nat)], hashEq : (T -> Nat32, (T, T) -> Bool)) : Map.Map<T, Text> {
        //En el return, el Nat representa la codificacion binaria del simbolo expresada en sistema decimal
        var count = arr.size();
  
        let codesResult = Map.new<T, Nat>();
        let stringCode = Map.new<T, Text>();
        var aristas = Prim.Array_init<Arista<T>>(count, {elements = [arr[0].0]; prob=  arr[0].1});
        var index = 0;
        while (index < count){ 
            aristas[index] := {elements = [arr[index].0]; prob = arr[index].1};
            index += 1;
        };

        while (count > 1) {
            // var numElements = 0;
            print("Iteracion ---> " # Nat.toText(arr.size()- count));
            let sumProb : Nat = aristas[count -1].prob + aristas[count -2].prob;
            let setElements = Set.new<T>();

            for (left : T in aristas[count -1].elements.vals()) {
                let codeUpdate = switch (Map.get<T, Nat>(codesResult, hashEq, left)) {
                    case null { 1 };
                    case (?value) { value * 2 + 1 };
                };

                //////////////////////////////////////////////////////////////////////////
                let codeUpdateString = switch (Map.get<T,Text>(stringCode, hashEq, left)){
                    case null {"0"};
                    case (?code){"0" #code}
                };
                ignore Map.put<T, Text>(stringCode, hashEq, left, codeUpdateString);
                ////////////////////////////////////////////////////////////////////////////
                ignore Map.put<T, Nat>(codesResult, hashEq, left, codeUpdate);
                ignore Set.put<T>(setElements, hashEq, left);
                // numElements += 1;
            };

            for (rigth : T in aristas[count -2].elements.vals()) {
                let currentCode = switch (Map.get<T, Nat>(codesResult, hashEq, rigth)) {
                    case null { 0 };
                    case (?value) { value };
                };
                //////////////////////////////////////////////////////////////////////////////
                let currentStringCode = switch (Map.get<T,Text>(stringCode, hashEq, rigth)){
                    case null {"1"};
                    case (?code){"1" # code }
                };
                ignore Map.put<T, Text>(stringCode, hashEq, rigth, currentStringCode);
                //////////////////////////////////////////////////////////////////////////////

                ignore Map.put<T, Nat>(codesResult, hashEq, rigth, currentCode * 2);
                ignore Set.put<T>(setElements, hashEq, rigth);
                // numElements += 1;
            };
            aristas[count -2] := {elements = Set.toArray<T>(setElements); prob = sumProb};

            count -= 1;
            aristas := _quickSort<Arista<T>>(headArray(aristas, count: Nat), func (a,b) = if(b.prob < a.prob){#less} else {#greater});

            for(i in aristas.vals()){print("probs --> " # Nat.toText(i.prob))};

        };
        stringCode;
    };

    func cmpProb(a : (Nat8, Nat), b : (Nat8, Nat)) : { #less; #equal; #greater } {
        return if (b.1 < a.1) {
            #less;
        } else {
            #greater;
        };
    };

    func cmpAristas(a : Arista<Nat>, b : Arista<Nat>) : { #less; #equal; #greater } {
        return if (b.prob < a.prob) {
            #less;
        } else {
            #greater;
        };
    };


    public func getHuffmanCodes(string : Text) : [(Nat8, Text)] {
        let frec = calculateFrequencies(string);
        print("Primero: -> " # Nat.toText(frec[0].1));
        print("Ultimo: -> " # Nat.toText(frec[frec.size()-1].1));

        let sortedInput = _quickSort<(Nat8, Nat)>(frec, cmpProb);
        print("Primero: -> " # Nat.toText(sortedInput[0].1));
        print("Ultimo: -> " # Nat.toText(sortedInput[sortedInput.size()-1].1));

        Map.toArray<Nat8, Text>(buildHuffmanTree<Nat8>(sortedInput, n8hash));
        // Map.toArray<Nat8, Nat>(buildHuffmanTree<Nat8>(sortedInput, n8hash));
    };

};

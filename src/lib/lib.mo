import Prim "mo:⛔";
import Map "mo:map/Map";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import { n8hash; thash } "mo:map/Map";
import { print } "mo:base/Debug";
import Buffer "mo:base/Buffer";
import Types "types";
import { cmpNodes; hCodeHash } "types";

module {
    type Node<T> = Types.Node<T>;
    type Order = Types.Order;
    type HCode = Types.HCode;

    //Runtime: O(n)
    func calculateFrequencies(input : Blob) : [var Node<Nat8>] {
        let tempArrayMut : [var Nat] = Prim.Array_init<Nat>(256, 0);

        var cont = 0;
        for (i in Prim.blobToArray(input).vals()) {
            let index = Prim.nat8ToNat(i);
            tempArrayMut[index] := tempArrayMut[index] +1;
            if (tempArrayMut[index] == 1) {
                cont += 1;
            };
        };
        let result = Prim.Array_init<Node<Nat8>>(cont, { elements = [0]; prob = 0 });
        var index = 0;
        while (index < 256) {
            if (tempArrayMut[index] != 0) {
                result[cont -1] := {
                    elements = [Prim.natToNat8(index)];
                    prob = tempArrayMut[index];
                };
                cont -= 1;
            };
            index += 1;
        };
        result;
    };

    func sliceArray<T>(arr : [var T], end : Nat) : [var T] {
        let result = Prim.Array_init<T>(end, arr[0]);
        var index = 0;
        while (index < end) {
            result[index] := arr[index];
            index += 1;
        };
        result;
    };

    //Runtime: O(size * log(size))
    func quickSort<T>(arr : [var T], cmp : (T, T) -> Order) : [var T] {
        let size = arr.size();
        if (size <= 1) { return arr };
        var leftNumbers = Prim.Array_init<T>(size, arr[0]);
        var rigthNumbers = Prim.Array_init<T>(size, arr[0]);
        var countLeft = 0;
        var countRigth = 0;
        let pivot = arr[size / 2];
        var index = 0;
        while (index < size) {
            if (index != size / 2) {
                if (cmp(arr[index], pivot) == #less) {
                    leftNumbers[countLeft] := arr[index];
                    countLeft += 1;
                } else {
                    rigthNumbers[countRigth] := arr[index];
                    countRigth += 1;
                };
            };
            index += 1;
        };
        leftNumbers := sliceArray(leftNumbers, countLeft);
        rigthNumbers := sliceArray(rigthNumbers, countRigth);
        let result = Prim.Array_init<T>(size, arr[0]);
        index := 0;
        for (l in quickSort(leftNumbers, cmp).vals()) {
            result[index] := l;
            index += 1;
        };
        result[index] := pivot;
        index += 1;
        for (r in quickSort(rigthNumbers, cmp).vals()) {
            result[index] := r;
            index += 1;
        };
        result;
    };

    func splitHeadTail<T>(arr : [var T]) : (T, [var T]) {
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

    func mergeNodes<T>(a : Node<T>, b : Node<T>) : Node<T> {
        let newSize = a.elements.size() + b.elements.size();
        func fillArray(i : Nat) : T {
            if (i < a.elements.size()) { a.elements[i] } else {
                b.elements[i - a.elements.size()];
            };
        };
        let elements = Prim.Array_tabulate<T>(newSize, fillArray);
        let prob = a.prob + b.prob;
        { elements; prob };
    };

    func getHuffmanCodes<T>(arr : [var Node<T>], hashEq : (T -> Nat32, (T, T) -> Bool)) : (Map.Map<T, HCode>, Nat) {

        let codes = Map.new<T, HCode>();
        var nodes = arr;
        while (nodes.size() > 1) {
            let (head, tail) = splitHeadTail<Node<T>>(nodes);

            for (left : T in head.elements.vals()) {
                let code2Update : HCode = switch (Map.get<T, HCode>(codes, hashEq, left)) {
                    case null { { len = 1; value = 0 } };
                    case (?code) {
                        { len = code.len + 1; value = code.value };
                    };
                };
                ignore Map.put<T, HCode>(codes, hashEq, left, code2Update);
            };
            for (rigth : T in tail[0].elements.vals()) {

                let code2Update : HCode = switch (Map.get<T, HCode>(codes, hashEq, rigth)) {
                    case null { { len = 1; value = 1 } };
                    case (?code) {
                        {
                            len = code.len + 1;
                            value = 2 ** code.len + code.value;
                        };
                    };
                };
                ignore Map.put<T, HCode>(codes, hashEq, rigth, code2Update);
            };
            let newNode = mergeNodes<T>(head, tail[0]);
            /////////////////////// NewNode Insertion ////////////////////////////////////
            var i = 0;
            var currentSize = tail.size();
            while (i < currentSize) {
                if (i == (currentSize - 1 : Nat)) {
                    tail[i] := newNode;
                    i += 1;
                } else {
                    if (tail[i + 1].prob < newNode.prob) {
                        tail[i] := tail[i + 1];
                        i += 1;
                    } else {
                        tail[i] := newNode;
                        i := tail.size();
                    };
                };
            };
            //////////////////////////////////////////////////////////////////////////////////////
            nodes := tail;
        };
        ///////////////// Tamaño en bits de los datos al ser comprimidos  ////////////////////
        var sizeResult = 0;
        for (i in arr.vals()) {
            let sizeChar = switch (Map.get<T, HCode>(codes, hashEq, i.elements[0])) {
                case (?code) { code.len };
                case null { assert false; 0 };
            };
            sizeResult += (i.prob * sizeChar);
        };
        //////////////////////////////////////////////////////////////////////////////////////
        (codes, sizeResult);
    };

    func zip(input : Blob) : Types.ZippedData {
        let frec : [var Node<Nat8>] = calculateFrequencies(input);
        let sortedInput = quickSort<Node<Nat8>>(frec, cmpNodes);

        let (map, size) = getHuffmanCodes<Nat8>(sortedInput, n8hash);
        let dataResult = Prim.Array_init<Nat8>(size / 8 +1, 0);
        let nat8Array = Prim.blobToArray(input);
        var resultNat : Nat = 0;
        var bits = 0;
        for (l in nat8Array.vals()) {
            switch (Map.get<Nat8, HCode>(map, n8hash, l)) {
                case (?code) {
                    bits += code.len;
                    resultNat := resultNat * 2 ** (code.len) + code.value;
                };
                case null { assert false };
            };
        };
        let inversedMap = Map.new<HCode, Nat8>();
        for ((k, v) in Map.entries(map)) {
            ignore Map.put<HCode, Nat8>(inversedMap, hCodeHash, v, k);
        };
        { map = inversedMap; len = bits; payLoad = resultNat }

    };
    //////////////////// exceeded the instruction limit for single message execution  /////////////////
    public func unZip(input : Types.ZippedData) : [Nat8] {
        var bits = input.len;
        var data = input.payLoad;

        var minLenCode : Nat = 32;
        var maxLenCode : Nat = 0;
        let bufferResult = Buffer.fromArray<Nat8>([]);
        for (l in Map.keys<HCode, Nat8>(input.map)) {
            if (l.len < minLenCode) { minLenCode := l.len };
            if (l.len > maxLenCode) { maxLenCode := l.len };
        };
        var sizeCurrentCode = minLenCode;
        while (sizeCurrentCode <= maxLenCode and bits > 0) {
            let candidate = {
                len = sizeCurrentCode;
                value : Nat = data / 2 ** (bits - sizeCurrentCode);
            };
            switch (Map.get<HCode, Nat8>(input.map, hCodeHash, candidate)) {
                case null {
                    sizeCurrentCode += 1;
                };
                case (?code) {
                    bufferResult.add(code);
                    bits -= sizeCurrentCode;
                    data %= 2 ** bits;
                    sizeCurrentCode := minLenCode;
                };
            };
        };

        Buffer.toArray<Nat8>(bufferResult);
    };
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    public func getCodes(string : Text) : (Map.Map<Nat8, HCode>) {
        let frec : [var Node<Nat8>] = calculateFrequencies(Prim.encodeUtf8(string));
        let sortedInput = quickSort<Node<Nat8>>(frec, cmpNodes);
        (getHuffmanCodes<Nat8>(sortedInput, n8hash).0);

    };
    public func encodeText(string : Text) : Types.ZippedData {
        let nat8Array = Prim.encodeUtf8(string);

        zip(nat8Array);
    };

};

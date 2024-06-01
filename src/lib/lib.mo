import Prim "mo:⛔";
// import Debug "mo:base/Debug";
// import Nat "mo:base/Nat";

module {
    // let print = Debug.print;
    public func calculateFrequencies(input : Text) : [(Nat8, Nat)] {
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
        Prim.Array_tabulate<(Nat8, Nat)>(
            cont,
            func _ {
                while (tempArrayMut[index] == 0) {
                    index += 1;
                };
                index += 1;
                (Prim.natToNat8(index -1), tempArrayMut[(index - 1)]);
            },
        );
    };

    public func quickSort<T>(arr : [T], cmp : (T, T) -> { #less; #equal; #greater }) : [T] {
        let size = arr.size();
        var arrayMut = Prim.Array_init<T>(size, arr[0]);
        var index = 0;
        while (index < size) {
            arrayMut[index] := arr[index];
            index += 1;
        };
        arrayMut := _quickSort<T>(arrayMut, cmp);
        Prim.Array_tabulate<T>(size, func x = arrayMut[x]);
    };

    func subArrayMut<T>(arr : [var T], end : Nat) : [var T] {
        let result = Prim.Array_init<T>(end, arr[0]);
        var index = 0;
        while (index < end) {
            result[index] := arr[index];
            index += 1;
        };
        result;
    };

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
        leftNumbers := subArrayMut(leftNumbers, countLeft);
        rigthNumbers := subArrayMut(rigthNumbers, countRigth);
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
};

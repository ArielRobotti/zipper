

module {
    public type Order = {#less; #equal; #greater};
    public type Node<T> = {
        elements : [T];
        prob : Nat;
    };
    public func cmpNodes(a : Node<Any>, b : Node<Any>) : Order {
        if (a.prob < b.prob) { #less } else { #greater };
    };
}
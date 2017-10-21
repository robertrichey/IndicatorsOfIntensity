public class X {
    fun Y getY(int n) {
        Y y;
        
        n => y.value;
        return y;
    }
}

class Y {
    int value;
}

X x;

x.getY(5) @=> Y y;

<<< y.value >>>;
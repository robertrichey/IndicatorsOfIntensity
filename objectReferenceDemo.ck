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

x.getY(1) @=> Y a;
x.getY(2) @=> Y b;

<<< a.value, b.value >>>;

RideData.getGrains(25) @=> SampleGrains s;
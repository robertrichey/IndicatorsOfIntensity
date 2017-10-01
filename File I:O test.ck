FileIO file;
file.open("test.txt", FileIO.READ);

while (true) {
    file => int value;
    
    if (file.eof()) {
        break;
    }
    <<< value >>>;
    1::second => now;
}
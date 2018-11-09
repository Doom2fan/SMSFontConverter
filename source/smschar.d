module smschar;

private import core.exception;

/// Represents a 8x8 1bpp character
public struct SMSChar {
    /// The character's pixels
    protected byte [8] rows;

    /++
     + Gets a row of pixels.
    ++/
    public byte opIndex (size_t i) {
        if (i < 0 || i > 7)
            onRangeError ();

        return rows [i];
    }

    /++
     + Gets the pixel from the specified row and column.
    ++/
    public bool opIndex (size_t row, size_t col) {
        if (row < 0 || row > 7)
            onRangeError ();
        if (col < 0 || col > 7)
            onRangeError ();
        
        byte pixel = (rows [row] & cast (byte) (0x01 << (0x07 - col)));

        return pixel != 0;
    }

    /++
     + Sets a row of pixels.
    ++/
    public byte opIndexAssign (byte value, size_t i) {
        if (i < 0 || i > 7)
            onRangeError ();

        return rows [i] = value;
    }

    /++
     + Set the pixel at the specified row and column.
    ++/
    public bool opIndexAssign (bool value, size_t row, size_t col) {
        if (row < 0 || row > 7)
            onRangeError ();
        if (col < 0 || col > 7)
            onRangeError ();
        
        if (!value) {
            byte mask = cast (byte) ~(0x01 << (0x07 - col));
            rows [row] &= mask;
        } else {
            byte mask = cast (byte)  (0x01 << (0x07 - col));
            rows [row] |= mask;
        }

        return value;
    }
}
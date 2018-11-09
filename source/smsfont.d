module smsfont;

private import core.exception;
private import std.format : formattedWrite, format;
private import std.array : appender;
private import smschar;
private import charlist;

const string rowFormat = ".DB %%%.8b    ; Hex %.2Xh";

class SMSFont {
    protected SMSChar [charCount] chars;

    public static string charToIncl (SMSChar c) {
        auto app = appender!string;

        for (int i = 0; i < 8; i++)
            formattedWrite (app, "%s\n", c [i]);

        return app.data;
    }

    public string toIncl () {
        auto app = appender!string;

        for (int i = 0; i < charCount; i++) {
            formattedWrite (app, " ; Character 0x%.2X\n", charStart + i);

            for (int j = 0; j < 8; j++) {
                byte rowData = chars [i] [j];
                formattedWrite (app, rowFormat, rowData, rowData);
                app.put ("\n");
            }

            app.put ("\n\n");
        }

        return app.data;
    }

    /++
     + Gets the specified char.
    ++/
    public SMSChar opIndex (size_t i) {
        if (i < 0 || i > charCount)
            onRangeError ();

        return chars [i];
    }

    /++
     + Sets the specified char.
    ++/
    public SMSChar opIndexAssign (SMSChar value, size_t i) {
        if (i < 0 || i > charCount)
            onRangeError ();

        return chars [i] = value;
    }
}
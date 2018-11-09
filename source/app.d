import std.stdio;
import std.getopt;
import std.format : formattedWrite, format;
import std.array : appender;
import std.path : isValidPath, buildPath;
import std.file : exists, isDir, isFile, write;
import dlib.image;
import smschar;
import smsfont;
import charlist;

int main (string [] args) {
    string inputPath;
    string outputPath;

    try {
        auto helpInformation = getopt (
            args,
            std.getopt.config.required, "input|i",  &inputPath,
            std.getopt.config.required, "output|o", &outputPath
        );

        if (helpInformation.helpWanted) {
            defaultGetoptPrinter ("smsfontconverter: A program for generating Sega Master System fonts.", helpInformation.options);
            return 255;
        }
    } catch (GetOptException e) {
        writeln (e.message);
        return 255;
    }

    if (!isValidPath (inputPath)) {
        writefln ("Input path \"%s\" is invalid.", inputPath);
        return 1;
    } else if (!exists (inputPath)) {
        writefln ("Input path \"%s\" does not exist.", inputPath);
        return 2;
    } else if (!isDir (inputPath)) {
        writefln ("Input path \"%s\" is not a directory.", inputPath);
        return 2;
    }

    if (!isValidPath (outputPath)) {
        writefln ("Output path \"%s\" is invalid.", outputPath);
        return 1;
    } if (exists (outputPath)) {
        writefln ("Output file \"%s\" already exists.", outputPath);
        return 2;
    }

    auto fnt = new SMSFont ();
    for (int i = charStart; i <= charEnd; i++) {
        string charPath = buildPath (inputPath, format ("%.2X.png", i));

        if (!exists (charPath) || !isFile (charPath)) {
            writefln ("Missing glyph 0x%.2X (\"%s\").", i, smsChars [i - charStart]);
            continue;
        }

        SuperImage img;
        try {
            img = loadPNG (charPath);
        } catch (Exception e) {
            writefln ("Error loading glyph 0x%.2X (\"%s\").", i, smsChars [i]);
            return 3;
        }

        if (img is null) {
            writefln ("Error loading glyph 0x%.2X (\"%s\").", i, smsChars [i]);
            return 3;
        }

        if (img.width != 8 || img.height != 8) {
            writefln ("Malformed glyph 0x%.2X (\"%s\"). Glyphs must be 8x8.", i, smsChars [i]);
            return 3;
        }

        auto c = SMSChar ();
        for (int x = 0; x < 8; x++) {
            for (int y = 0; y < 8; y++) {
                const Color4f blackC4F = Color4f (0, 0, 0, 1);
                const Color4f whiteC4F = Color4f (1, 1, 1, 1);

                bool pixel = false;
                auto color = img [x, y];
                if      (color == blackC4F) pixel = false;
                else if (color == whiteC4F) pixel = true;
                else {
                    writefln ("Malformed glyph 0x%.2X (\"%s\"). Glyphs must be only contain the colors 0x000000 and 0xFFFFFF.", i, smsChars [i]);
                    return 3;
                }

                c [y, x] = pixel;
            }
        }

        fnt [i - charStart] = c;
    }

    write (outputPath, fnt.toIncl ());

    return 0;
}

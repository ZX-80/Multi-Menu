#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""Convert CP437 compatible ttf fonts into dasm bitmaps"""

from PIL import Image, ImageDraw, ImageFont

FONT_NAME = "Mx437_EverexME_5x8.ttf"
FONT_SIZE = 8
ROWS = 4
COLUMNS = 256 // ROWS

ibm437_to_str = {
    0x00: "Null",
    0x01: "Smiling Face",
    0x02: "Smiling Face, Reverse Image",
    0x03: "Heart Suit Symbol",
    0x04: "Diamond Suit Symbol",
    0x05: "Club Suit Symbol",
    0x06: "Spade Suit Symbol",
    0x07: "Bullet",
    0x08: "Bullet, Reverse Image",
    0x09: "Open Circle",
    0x0a: "Open Circle, Reverse Image",
    0x0b: "Male Symbol",
    0x0c: "Female Symbol",
    0x0d: "Musical Note",
    0x0e: "Two Musical Notes",
    0x0f: "Sun Symbol",
    0x10: "Forward Arrow Indicator",
    0x11: "Back Arrow Indicator",
    0x12: "Up-Down Arrow",
    0x13: "Double Exclamation Points",
    0x14: "Paragraph Symbol (USA)",
    0x15: "Section Symbol (USA)/Paragraph Symbol (Europe)",
    0x16: "Solid Horizontal Rectangle",
    0x17: "Up-Down Arrow, Perpendicular",
    0x18: "Up Arrow",
    0x19: "Down Arrow",
    0x1a: "Right Arrow",
    0x1b: "Left Arrow",
    0x1c: "Right Angle Symbol",
    0x1d: "Left-Right Arrow",
    0x1e: "Solid Triangle",
    0x1f: "Solid Triangle, Inverted",
    0x20: "Space",
    0x21: "Exclamation Point",
    0x22: "Quotation Marks",
    0x23: "Number Sign",
    0x24: "Dollar Sign",
    0x25: "Percent Sign",
    0x26: "Ampersand",
    0x27: "Apostrophe",
    0x28: "Left Parenthesis",
    0x29: "Right Parenthesis",
    0x2a: "Asterisk",
    0x2b: "Plus Sign",
    0x2c: "Comma",
    0x2d: "Hyphen/Minus Sign",
    0x2e: "Period/Full Stop",
    0x2f: "Slash",
    0x30: "Zero",
    0x31: "One",
    0x32: "Two",
    0x33: "Three",
    0x34: "Four",
    0x35: "Five",
    0x36: "Six",
    0x37: "Seven",
    0x38: "Eight",
    0x39: "Nine",
    0x3a: "Colon",
    0x3b: "Semicolon",
    0x3c: "Less Than Sign/Greater Than Sign (Arabic)",
    0x3d: "Equal Sign",
    0x3e: "Greater Than Sign/Less Than Sign (Arabic)",
    0x3f: "Question Mark",
    0x40: "At Sign",
    0x41: "A Capital",
    0x42: "B Capital",
    0x43: "C Capital",
    0x44: "D Capital",
    0x45: "E Capital",
    0x46: "F Capital",
    0x47: "G Capital",
    0x48: "H Capital",
    0x49: "I Capital",
    0x4a: "J Capital",
    0x4b: "K Capital",
    0x4c: "L Capital",
    0x4d: "M Capital",
    0x4e: "N Capital",
    0x4f: "O Capital",
    0x50: "P Capital",
    0x51: "Q Capital",
    0x52: "R Capital",
    0x53: "S Capital",
    0x54: "T Capital",
    0x55: "U Capital",
    0x56: "V Capital",
    0x57: "W Capital",
    0x58: "X Capital",
    0x59: "Y Capital",
    0x5a: "Z Capital",
    0x5b: "Left Bracket",
    0x5c: "Backslash",
    0x5d: "Right Bracket",
    0x5e: "Circumflex Accent",
    0x5f: "Underline/Continuous Underscore",
    0x60: "Grave Accent",
    0x61: "a Small",
    0x62: "b Small",
    0x63: "c Small",
    0x64: "d Small",
    0x65: "e Small",
    0x66: "f Small",
    0x67: "g Small",
    0x68: "h Small",
    0x69: "i Small",
    0x6a: "j Small",
    0x6b: "k Small",
    0x6c: "l Small",
    0x6d: "m Small",
    0x6e: "n Small",
    0x6f: "o Small",
    0x70: "p Small",
    0x71: "q Small",
    0x72: "r Small",
    0x73: "s Small",
    0x74: "t Small",
    0x75: "u Small",
    0x76: "v Small",
    0x77: "w Small",
    0x78: "x Small",
    0x79: "y Small",
    0x7a: "z Small",
    0x7b: "Left Brace",
    0x7c: "Vertical Line/Logical OR",
    0x7d: "Right Brace",
    0x7e: "Tilde Accent",
    0x7f: "Small House",
    0x80: "C Cedilla Capital",
    0x81: "u Diaeresis Small",
    0x82: "e Acute Small",
    0x83: "a Circumflex Small",
    0x84: "a Diaeresis Small",
    0x85: "a Grave Small",
    0x86: "a Overcircle Small",
    0x87: "c Cedilla Small",
    0x88: "e Circumflex Small",
    0x89: "e Diaeresis Small",
    0x8a: "e Grave Small",
    0x8b: "i Diaeresis Small",
    0x8c: "i Circumflex Small",
    0x8d: "i Grave Small",
    0x8e: "A Diaeresis Capital",
    0x8f: "A Overcircle Capital",
    0x90: "E Acute Capital",
    0x91: "ae Diphthong Small",
    0x92: "ae Diphthong Capital",
    0x93: "o Circumflex Small",
    0x94: "o Diaeresis Small",
    0x95: "o Grave Small",
    0x96: "u Circumflex Small",
    0x97: "u Grave Small",
    0x98: "y Diaeresis Small",
    0x99: "O Diaeresis Capital",
    0x9a: "U Diaeresis Capital",
    0x9b: "Cent Sign",
    0x9c: "Pound Sterling Sign",
    0x9d: "Yen Sign",
    0x9e: "Peseta Sign",
    0x9f: "Florin Sign",
    0xa0: "a Acute Small",
    0xa1: "i Acute Small",
    0xa2: "o Acute Small",
    0xa3: "u Acute Small",
    0xa4: "n Tilde Small",
    0xa5: "N Tilde Capital",
    0xa6: "Ordinal Indicator, Feminine",
    0xa7: "Ordinal Indicator, Masculine",
    0xa8: "Question Mark, Inverted",
    0xa9: "Start of Line Symbol",
    0xaa: "Logical NOT/End Of Line Symbol",
    0xab: "One Half",
    0xac: "One Quarter",
    0xad: "Exclamation Point, Inverted",
    0xae: "Left Angle Quotes",
    0xaf: "Right Angle Quotes",
    0xb0: "Fill Character, Light",
    0xb1: "Fill Character, Medium",
    0xb2: "Fill Character, Heavy",
    0xb3: "Center Box Bar Vertical",
    0xb4: "Right Middle Box Side",
    0xb5: "Right Box Side Double to Single",
    0xb6: "Right Box Side Single To Double",
    0xb7: "Upper Right Box Corner Single To Double",
    0xb8: "Upper Right Box Corner Double To Single",
    0xb9: "Right Box Side Double",
    0xba: "Center Box Bar Vertical Double",
    0xbb: "Upper Right Box Corner Double",
    0xbc: "Lower Right Box Corner Double",
    0xbd: "Lower Right Box Corner Single To Double",
    0xbe: "Lower Right Box Corner Double To Single",
    0xbf: "Upper Right Box Corner",
    0xc0: "Lower Left Box Corner",
    0xc1: "Middle Box Bottom",
    0xc2: "Middle Box Top",
    0xc3: "Left Middle Box Side",
    0xc4: "Center Box Bar Horizontal",
    0xc5: "Box Intersection",
    0xc6: "Left Box Side Single to Double",
    0xc7: "Left Box Side Double To Single",
    0xc8: "Lower Left Box Corner Double",
    0xc9: "Upper Left Box Corner Double",
    0xca: "Middle Box Bottom Double",
    0xcb: "Middle Box Top Double",
    0xcc: "Left Box Side Double",
    0xcd: "Center Box Bar Horizontal Double",
    0xce: "Box Intersection Double",
    0xcf: "Middle Box Bottom Single To Double",
    0xd0: "Middle Box Bottom Double To Single",
    0xd1: "Middle Box Top Double To Single",
    0xd2: "Middle Box Top Single To Double",
    0xd3: "Lower Left Box Corner Double To Single",
    0xd4: "Lower Left Box Corner Single To Double",
    0xd5: "Upper Left Box Corner Single To Double",
    0xd6: "Upper Left Box Corner Double To Single",
    0xd7: "Box Intersection Single To Double",
    0xd8: "Box Intersection Double To Single",
    0xd9: "Lower Right Box Corner",
    0xda: "Upper Left Box Corner",
    0xdb: "Solid Fill Character",
    0xdc: "Solid Fill Character, Bottom Half",
    0xdd: "Solid Fill Character, Left Half",
    0xde: "Solid Fill Character, Right Half",
    0xdf: "Solid Fill Character, Top Half",
    0xe0: "Alpha Small",
    0xe1: "Sharp s Small",
    0xe2: "Gamma Capital",
    0xe3: "Pi Small",
    0xe4: "Sigma Capital",
    0xe5: "Sigma Small",
    0xe6: "Mu Small",
    0xe7: "Tau Small",
    0xe8: "Phi Capital",
    0xe9: "Theta Capital",
    0xea: "Omega Capital",
    0xeb: "Delta Small",
    0xec: "Infinity Symbol",
    0xed: "Phi Small (Closed Form)",
    0xee: "Epsilon Small",
    0xef: "Intersection Symbol/Logical Product Symbol",
    0xf0: "Identity Symbol",
    0xf1: "Plus or Minus Sign",
    0xf2: "Greater Than Or Equal Sign/Less Than Or Equal Sign (Arabic)",
    0xf3: "Less Than Or Equal Sign/Greater Than Or Equal Sign (Arabic)",
    0xf4: "Upper Integral Symbol Section",
    0xf5: "Lower Integral Symbol Section",
    0xf6: "Divide Sign",
    0xf7: "Nearly Equals Symbol",
    0xf8: "Degree Symbol",
    0xf9: "Product Dot",
    0xfa: "Middle Dot",
    0xfb: "Radical Symbol",
    0xfc: "n Small Superscript",
    0xfd: "Two Superscript",
    0xfe: "Solid Square/Histogram/Square Bullet",
    0xff: "Required Space",
}

ibm437_to_unicode = lambda byt: byt.translate({
    0x00: "\u0000",0x01: "\u263A",0x02: "\u263B",0x03: "\u2665",0x04: "\u2666",0x05: "\u2663",0x06: "\u2660",0x07: "\u2022",
    0x08: "\u25D8",0x09: "\u25CB",0x0a: "\u25D9",0x0b: "\u2642",0x0c: "\u2640",0x0d: "\u266A",0x0e: "\u266B",0x0f: "\u263C",
    0x10: "\u25BA",0x11: "\u25C4",0x12: "\u2195",0x13: "\u203C",0x14: "\u00B6",0x15: "\u00A7",0x16: "\u25AC",0x17: "\u21A8",
    0x18: "\u2191",0x19: "\u2193",0x1a: "\u2192",0x1b: "\u2190",0x1c: "\u221F",0x1d: "\u2194",0x1e: "\u25B2",0x1f: "\u25BC",
    0x20: "\u0020",0x21: "\u0021",0x22: "\u0022",0x23: "\u0023",0x24: "\u0024",0x25: "\u0025",0x26: "\u0026",0x27: "\u0027",
    0x28: "\u0028",0x29: "\u0029",0x2a: "\u002a",0x2b: "\u002b",0x2c: "\u002c",0x2d: "\u002d",0x2e: "\u002e",0x2f: "\u002f",
    0x30: "\u0030",0x31: "\u0031",0x32: "\u0032",0x33: "\u0033",0x34: "\u0034",0x35: "\u0035",0x36: "\u0036",0x37: "\u0037",
    0x38: "\u0038",0x39: "\u0039",0x3a: "\u003a",0x3b: "\u003b",0x3c: "\u003c",0x3d: "\u003d",0x3e: "\u003e",0x3f: "\u003f",
    0x40: "\u0040",0x41: "\u0041",0x42: "\u0042",0x43: "\u0043",0x44: "\u0044",0x45: "\u0045",0x46: "\u0046",0x47: "\u0047",
    0x48: "\u0048",0x49: "\u0049",0x4a: "\u004a",0x4b: "\u004b",0x4c: "\u004c",0x4d: "\u004d",0x4e: "\u004e",0x4f: "\u004f",
    0x50: "\u0050",0x51: "\u0051",0x52: "\u0052",0x53: "\u0053",0x54: "\u0054",0x55: "\u0055",0x56: "\u0056",0x57: "\u0057",
    0x58: "\u0058",0x59: "\u0059",0x5a: "\u005a",0x5b: "\u005b",0x5c: "\u005c",0x5d: "\u005d",0x5e: "\u005e",0x5f: "\u005f",
    0x60: "\u0060",0x61: "\u0061",0x62: "\u0062",0x63: "\u0063",0x64: "\u0064",0x65: "\u0065",0x66: "\u0066",0x67: "\u0067",
    0x68: "\u0068",0x69: "\u0069",0x6a: "\u006a",0x6b: "\u006b",0x6c: "\u006c",0x6d: "\u006d",0x6e: "\u006e",0x6f: "\u006f",
    0x70: "\u0070",0x71: "\u0071",0x72: "\u0072",0x73: "\u0073",0x74: "\u0074",0x75: "\u0075",0x76: "\u0076",0x77: "\u0077",
    0x78: "\u0078",0x79: "\u0079",0x7a: "\u007a",0x7b: "\u007b",0x7c: "\u007c",0x7d: "\u007d",0x7e: "\u007e",0x7f: "\u2302",
    0x80: "\u00c7",0x81: "\u00fc",0x82: "\u00e9",0x83: "\u00e2",0x84: "\u00e4",0x85: "\u00e0",0x86: "\u00e5",0x87: "\u00e7",
    0x88: "\u00ea",0x89: "\u00eb",0x8a: "\u00e8",0x8b: "\u00ef",0x8c: "\u00ee",0x8d: "\u00ec",0x8e: "\u00c4",0x8f: "\u00c5",
    0x90: "\u00c9",0x91: "\u00e6",0x92: "\u00c6",0x93: "\u00f4",0x94: "\u00f6",0x95: "\u00f2",0x96: "\u00fb",0x97: "\u00f9",
    0x98: "\u00ff",0x99: "\u00d6",0x9a: "\u00dc",0x9b: "\u00a2",0x9c: "\u00a3",0x9d: "\u00a5",0x9e: "\u20a7",0x9f: "\u0192",
    0xa0: "\u00e1",0xa1: "\u00ed",0xa2: "\u00f3",0xa3: "\u00fa",0xa4: "\u00f1",0xa5: "\u00d1",0xa6: "\u00aa",0xa7: "\u00ba",
    0xa8: "\u00bf",0xa9: "\u2310",0xaa: "\u00ac",0xab: "\u00bd",0xac: "\u00bc",0xad: "\u00a1",0xae: "\u00ab",0xaf: "\u00bb",
    0xb0: "\u2591",0xb1: "\u2592",0xb2: "\u2593",0xb3: "\u2502",0xb4: "\u2524",0xb5: "\u2561",0xb6: "\u2562",0xb7: "\u2556",
    0xb8: "\u2555",0xb9: "\u2563",0xba: "\u2551",0xbb: "\u2557",0xbc: "\u255d",0xbd: "\u255c",0xbe: "\u255b",0xbf: "\u2510",
    0xc0: "\u2514",0xc1: "\u2534",0xc2: "\u252c",0xc3: "\u251c",0xc4: "\u2500",0xc5: "\u253c",0xc6: "\u255e",0xc7: "\u255f",
    0xc8: "\u255a",0xc9: "\u2554",0xca: "\u2569",0xcb: "\u2566",0xcc: "\u2560",0xcd: "\u2550",0xce: "\u256c",0xcf: "\u2567",
    0xd0: "\u2568",0xd1: "\u2564",0xd2: "\u2565",0xd3: "\u2559",0xd4: "\u2558",0xd5: "\u2552",0xd6: "\u2553",0xd7: "\u256b",
    0xd8: "\u256a",0xd9: "\u2518",0xda: "\u250c",0xdb: "\u2588",0xdc: "\u2584",0xdd: "\u258c",0xde: "\u2590",0xdf: "\u2580",
    0xe0: "\u03b1",0xe1: "\u00df",0xe2: "\u0393",0xe3: "\u03c0",0xe4: "\u03a3",0xe5: "\u03c3",0xe6: "\u00b5",0xe7: "\u03c4",
    0xe8: "\u03a6",0xe9: "\u0398",0xea: "\u03a9",0xeb: "\u03b4",0xec: "\u221e",0xed: "\u03c6",0xee: "\u03b5",0xef: "\u2229",
    0xf0: "\u2261",0xf1: "\u00b1",0xf2: "\u2265",0xf3: "\u2264",0xf4: "\u2320",0xf5: "\u2321",0xf6: "\u00f7",0xf7: "\u2248",
    0xf8: "\u00b0",0xf9: "\u2219",0xfa: "\u00b7",0xfb: "\u221a",0xfc: "\u207f",0xfd: "\u00b2",0xfe: "\u25a0",0xff: "\u00a0",
})

def draw_bitmap(font: ImageFont.FreeTypeFont, rows: int, columns: int) -> Image:
    """Create a bitmap of 256 font characters of size (columns * font_width, rows * font_height) pixels"""
    class FakeBitmap:
        def load(self):
            pass
    bitmap = FakeBitmap()
    for row in range(rows):
        text = "".join(ibm437_to_unicode(chr(i + columns * row)) for i in range(columns))
        mask, _ = font.getmask2(text, "L")
        bitmap.im = mask
        if row == 0:
            width_image, height_row = mask.size
            image = Image.new("1", (width_image, height_row * rows), "black")
            draw = ImageDraw.Draw(image)
        draw.bitmap((0, height_row * row), bitmap, "white")
    return image

def map_char_to_bytes(image: Image, font_width: int, font_height: int, columns: int) -> dict[str, bytes]:
    """Convert the image bitmap into a series of bytes for each character"""
    char_map = {}
    for y in range(0, image.size[1], font_height):
        for x in range(0, image.size[0], font_width):
            index = (x // font_width) + (columns * (y // font_height))
            # NOTE: characters need to be mirrored both horizontally and
            # vertically, as they are mirrored again when drawn
            char_map[chr(index)] = image.crop((x, y, x + font_width, y + font_height)).rotate(180).tobytes()
    return char_map

def generate_font_file(font: ImageFont.FreeTypeFont, char_map: dict[str, bytes], font_width: int, font_height: int) -> None:
    """Generate the font file to be imported in dasm"""
    with open("font.asm", "w", encoding="utf-8") as out_fp:
        out_fp.write(f"; Based on {font.getname()[0]} (no changes were made)\n")
        out_fp.write("; From the Ultimate Oldschool PC Font Pack\n")
        out_fp.write("; License: http://creativecommons.org/licenses/by-sa/4.0/\n")
        out_fp.write("; Code page 437 compatible\n")
        out_fp.write(f"\nfont_width = {font_width}\nfont_height = {font_height}\n\n")
        for char_i in list(range(0x80, 0x100)) + list(range(0, 0x80)):
            if char_i == 0:
                out_fp.write(f"bitmapFont:{'':28};    Must be in the middle, as offsets are signed\n")
            out_fp.write("    db " + ",".join(f"${data:02X}" for data in char_map[chr(char_i)])) # db $00,$00,$50,$A8,$A8,$50,$00,$00
            out_fp.write(f" ; {char_i:2X} {ibm437_to_str[char_i]} ({ibm437_to_unicode(chr(char_i))})\n") # ; 21 Exclamation Point (!)

if __name__ == "__main__":
    font = ImageFont.truetype(FONT_NAME, FONT_SIZE, encoding="utf-8")
    image = draw_bitmap(font, ROWS, COLUMNS)
    image.save(f"{FONT_NAME}.png")
    font_width, font_height = image.size[0]//COLUMNS, image.size[1]//ROWS
    char_map = map_char_to_bytes(image, font_width, font_height, COLUMNS)
    generate_font_file(font, char_map, font_width, font_height)
    print(f"Font: {font.getname()[0]} [Actual {font_width}x{font_height}]", )
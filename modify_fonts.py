from fontTools.ttLib import TTFont
import os

def modify_font_name(font_path, new_family_name, new_subfamily_name, new_full_name, new_ps_name, output_path):
    if not os.path.exists(font_path):
        print(f"Error: File not found: {font_path}")
        return

    font = TTFont(font_path)
    name_table = font['name']
    
    # Helper to set name record
    def set_name(name_id, string_val):
        # We iterate over all records and update those that match the name_id
        # This handles different platforms/encodings (Mac, Windows, etc.)
        # Ideally we should be more precise, but replacing all occurrences of ID is a common strategy for simple renaming.
        # However, it's better to remove existing and add new ones or carefully update.
        # For simplicity and robustness in this context, we'll iterate and update.
        
        found = False
        for record in name_table.names:
            if record.nameID == name_id:
                # Keep the encoding/platform as is, just change the string
                record.string = string_val
                found = True
        
        if not found:
            # If not found, we might want to add it, but for standard IDs (1,2,4,6) they should exist.
            # If they don't, adding them correctly requires specifying platform/encoding.
            # Let's assume standard fonts have them.
            print(f"Warning: NameID {name_id} not found in {font_path}")

    print(f"Modifying {font_path}...")
    
    # 1: Family Name
    set_name(1, new_family_name)
    # 2: Subfamily Name
    set_name(2, new_subfamily_name)
    # 4: Full Name
    set_name(4, new_full_name)
    # 6: PostScript Name (Must be ASCII, no spaces usually)
    set_name(6, new_ps_name)
    # 16: Typographic Family (Preferred Family) - often same as Family for simple fonts, or main family
    set_name(16, new_family_name)
    # 17: Typographic Subfamily (Preferred Subfamily)
    set_name(17, new_subfamily_name)

    font.save(output_path)
    print(f"Saved to {output_path}")

def main():
    # Configuration
    fonts_to_modify = [
        {
            "path": "HuatKimHang.ttf",
            "family": "HuatKimHang",
            "subfamily": "Regular",
            "full": "HuatKimHang",
            "ps": "HuatKimHang-Regular",
            "output": "HuatKimHang_Mod.ttf"
        },
        {
            "path": "HuatKimHang Bold.ttf",
            "family": "HuatKimHang",
            "subfamily": "Bold",
            "full": "HuatKimHang Bold",
            "ps": "HuatKimHang-Bold",
            "output": "HuatKimHang_Bold_Mod.ttf"
        }
    ]

    for config in fonts_to_modify:
        modify_font_name(
            config["path"],
            config["family"],
            config["subfamily"],
            config["full"],
            config["ps"],
            config["output"]
        )

if __name__ == "__main__":
    main()

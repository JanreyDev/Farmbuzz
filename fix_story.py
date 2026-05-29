with open('app/lib/features/home/presentation/home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Remove duplicate imports at line ~4821
# They appear as:
# import 'dart:io';
# import 'package:flutter/rendering.dart';
# import 'package:path_provider/path_provider.dart';
# 
# class _TextStoryEditorSheet
# We only want to keep: class _TextStoryEditorSheet

import re

# Remove the stray import block that was injected after the last class closing brace
# Pattern: newline + 3 import statements + newlines + class declaration
content = re.sub(
    r"\nimport 'dart:io';\nimport 'package:flutter/rendering\.dart';\nimport 'package:path_provider/path_provider\.dart';\n\nclass _TextStoryEditorSheet",
    "\n\nclass _TextStoryEditorSheet",
    content
)

# Add path_provider import at top if missing
if "package:path_provider/path_provider.dart" not in content:
    content = content.replace(
        "import 'dart:io';",
        "import 'dart:io';\nimport 'package:path_provider/path_provider.dart';",
        1
    )
    print("Added path_provider import at top")
else:
    print("path_provider already present")

# Fix deprecated Matrix4 methods - find the exact lines and replace
content = content.replace(
    "..translate(_offset.dx, _offset.dy)\n              ..scale(_scale)\n              ..rotateZ(_rotation)",
    "..translateByDouble(_offset.dx, _offset.dy, 0.0)\n              ..scaleByDouble(_scale)\n              ..rotateZ(_rotation)"
)

with open('app/lib/features/home/presentation/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Done")

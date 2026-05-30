import sys

content = open('app/lib/features/home/presentation/my_farm_dashboard_screen.dart').read()
content = content.replace("import 'dart:io';\n", '')
content = content.replace("const SizedBox(width: 6),", "SizedBox(width: 6),")
open('app/lib/features/home/presentation/my_farm_dashboard_screen.dart', 'w').write(content)
print('Fixed!')

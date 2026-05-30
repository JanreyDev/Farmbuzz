import sys

def modify_home_screen(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Replace const Column( with Column( for cases wrapping _HomeHeader
    content = content.replace("return const Column(\n          children: [\n             _HomeHeader", "return Column(\n          children: [\n             _HomeHeader")
    content = content.replace("return const Column(\n          children: [\n            _HomeHeader", "return Column(\n          children: [\n            _HomeHeader")

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

modify_home_screen('app/lib/features/home/presentation/home_screen.dart')
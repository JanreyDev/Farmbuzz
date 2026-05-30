import sys

def modify_home_screen(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Replace remaining _HomeHeader() usage in _HomeScreenState
    content = content.replace(" _HomeHeader()", " _HomeHeader(unreadMessages: _unreadMessages, unreadNotifications: _unreadNotifications)")

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

modify_home_screen('app/lib/features/home/presentation/home_screen.dart')
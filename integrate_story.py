import sys

with open('app/lib/features/home/presentation/home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

if "import 'widgets/story_viewer_screen.dart';" not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'widgets/story_viewer_screen.dart';", 1)

# Modify _StoryCard constructor
target_constructor = '''class _StoryCard extends StatelessWidget {
  const _StoryCard({
    required this.name,
    required this.time,
    required this.imageUrl,
    required this.avatarUrl,
    required this.textContent,
  });'''

replacement_constructor = '''class _StoryCard extends StatelessWidget {
  const _StoryCard({
    required this.name,
    required this.time,
    required this.imageUrl,
    required this.avatarUrl,
    required this.textContent,
    this.onTap,
  });

  final VoidCallback? onTap;'''

if target_constructor in content:
    content = content.replace(target_constructor, replacement_constructor)
else:
    print('Could not find _StoryCard constructor')

# Wrap _StoryCard with GestureDetector
target_build = '''    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration('''

replacement_build = '''    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration('''

if target_build in content:
    content = content.replace(target_build, replacement_build)
    
    end_target = '''            ],
          ),
        ],
      ),
    );
  }
}'''

    end_replacement = '''            ],
          ),
        ],
      ),
    ));
  }
}'''
    if end_target in content:
        content = content.replace(end_target, end_replacement)
    else:
        print('Could not find end of _StoryCard build')
else:
    print('Could not find _StoryCard build start')

# Replace map with List.generate
target_map = '''            ...stories.map(
              (story) => _StoryCard(
                name: story.name,
                time: story.timeAgo,
                imageUrl: story.imageUrl,
                avatarUrl: story.avatarUrl,
                textContent: story.textContent,
              ),
            ),'''

replacement_map = '''            ...List.generate(
              stories.length,
              (index) {
                final story = stories[index];
                return _StoryCard(
                  name: story.name,
                  time: story.timeAgo,
                  imageUrl: story.imageUrl,
                  avatarUrl: story.avatarUrl,
                  textContent: story.textContent,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StoryViewerScreen(
                          stories: stories,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                );
              },
            ),'''

if target_map in content:
    content = content.replace(target_map, replacement_map)
else:
    print('Could not find stories map')


with open('app/lib/features/home/presentation/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print('Done integrating StoryViewerScreen')

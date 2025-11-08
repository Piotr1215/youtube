#!/usr/bin/env python3
"""
YouTube Metadata Generator
Extracts metadata from presentation.md files and generates YouTube-ready metadata.txt
"""

import argparse
import re
import yaml
from pathlib import Path
from typing import List, Dict, Set
from datetime import datetime


class YouTubeMetadataGenerator:
    """Generate YouTube metadata from presentation markdown files"""

    # YouTube limits
    MAX_TITLE_LENGTH = 100
    MAX_DESCRIPTION_LENGTH = 5000
    MAX_TAGS = 500  # 500 character limit for all tags combined

    def __init__(self, folder_path: str):
        self.folder = Path(folder_path)
        self.presentation_file = self.folder / "presentation.md"
        self.output_file = self.folder / "youtube_metadata.txt"

        if not self.presentation_file.exists():
            raise FileNotFoundError(f"No presentation.md found in {folder_path}")

        with open(self.presentation_file, 'r', encoding='utf-8') as f:
            self.content = f.read()

    def extract_title(self) -> str:
        """Extract title from frontmatter or first # heading"""
        # Try frontmatter first
        frontmatter_match = re.match(r'^---\n(.*?)\n---', self.content, re.DOTALL)
        if frontmatter_match:
            try:
                metadata = yaml.safe_load(frontmatter_match.group(1))
                if 'title' in metadata:
                    title = metadata['title']
                    return title[:self.MAX_TITLE_LENGTH]
            except yaml.YAMLError:
                pass

        # Try first # heading
        heading_match = re.search(r'^# (.+?)(?:\n|$)', self.content, re.MULTILINE)
        if heading_match:
            title = heading_match.group(1).strip()
            # Clean up emoji and special formatting
            title = re.sub(r'[🎵🚀🎬👋]', '', title).strip()
            return title[:self.MAX_TITLE_LENGTH]

        return "Untitled Video"

    def extract_description(self) -> str:
        """Generate description from presentation outline/sections"""
        description_parts = []

        # Find all ## level headings (main sections)
        sections = re.findall(r'^## (.+?)$', self.content, re.MULTILINE)

        # Filter out common sections we don't want in description
        exclude_sections = {'Demo Time!', 'Demo Time', "That's All Folks!",
                          "That's All Folks", 'Resources', 'Introduction'}

        sections = [s.strip() for s in sections if s.strip() not in exclude_sections]

        if sections:
            description_parts.append("In this video, we cover:\n")
            for i, section in enumerate(sections[:10], 1):  # Limit to 10 sections
                # Clean emoji and special chars
                section = re.sub(r'[🎵🚀🎬👋💡🔄☁️✓✗]', '', section).strip()
                description_parts.append(f"• {section}")

        description = "\n".join(description_parts)

        # Ensure we don't exceed YouTube's limit
        if len(description) > self.MAX_DESCRIPTION_LENGTH:
            description = description[:self.MAX_DESCRIPTION_LENGTH-3] + "..."

        return description

    def extract_tags(self) -> List[str]:
        """Extract tags from bold terms, code blocks, and key terms"""
        tags = set()

        # Extract from **bold** text
        bold_terms = re.findall(r'\*\*([^*]+)\*\*', self.content)
        for term in bold_terms:
            # Clean and validate
            clean_term = re.sub(r'[:]', '', term).strip()
            if 3 <= len(clean_term) <= 30:  # YouTube tag length limits
                tags.add(clean_term.lower())

        # Extract code block languages
        code_langs = re.findall(r'```(\w+)', self.content)
        for lang in code_langs:
            if lang not in ['bash', 'exec', 'exec_replace', 'render']:
                tags.add(lang.lower())

        # Extract common tools mentioned
        tools = ['docker', 'kubernetes', 'k8s', 'tmux', 'vim', 'nvim', 'neovim',
                'git', 'github', 'ci/cd', 'devops', 'linux', 'terminal', 'cli',
                'python', 'latex', 'yaml', 'markdown', 'automation', 'pipeline']

        content_lower = self.content.lower()
        for tool in tools:
            if tool in content_lower:
                tags.add(tool)

        # Convert to list and ensure character limit
        tag_list = sorted(list(tags))[:30]  # Limit number of tags

        # Ensure total character count doesn't exceed limit
        total_chars = sum(len(tag) for tag in tag_list) + len(tag_list) * 2  # account for ", "
        while total_chars > self.MAX_TAGS and tag_list:
            tag_list.pop()
            total_chars = sum(len(tag) for tag in tag_list) + len(tag_list) * 2

        return tag_list

    def extract_timestamps(self) -> List[Dict[str, str]]:
        """Generate timestamps from slide headings for YouTube chapters"""
        timestamps = []

        # Find all ## headings with their positions
        pattern = r'^## (.+?)$'
        matches = list(re.finditer(pattern, self.content, re.MULTILINE))

        # Estimate time per slide (adjustable based on presentation style)
        # Average: 2-3 minutes per section
        base_time = 0
        time_per_section = 150  # 2.5 minutes in seconds

        for i, match in enumerate(matches):
            section_title = match.group(1).strip()

            # Clean emoji and special chars
            section_title = re.sub(r'[🎵🚀🎬👋💡🔄☁️✓✗]', '', section_title).strip()

            # Skip intro/outro if they're typical
            if section_title in ["Demo Time!", "Demo Time", "That's All Folks!",
                                "That's All Folks"]:
                continue

            # Calculate timestamp
            minutes = base_time // 60
            seconds = base_time % 60
            timestamp = f"{minutes:02d}:{seconds:02d}"

            timestamps.append({
                'time': timestamp,
                'title': section_title
            })

            base_time += time_per_section

        # Always add intro at 00:00 if not present
        if not timestamps or timestamps[0]['time'] != "00:00":
            title = self.extract_title()
            timestamps.insert(0, {'time': '00:00', 'title': f'Intro - {title}'})

        return timestamps[:15]  # Limit to 15 chapters

    def extract_resources(self) -> List[str]:
        """Extract URLs from presentation"""
        urls = set()

        # Find URLs in markdown links [text](url)
        markdown_links = re.findall(r'\[([^\]]+)\]\(([^)]+)\)', self.content)
        for text, url in markdown_links:
            if url.startswith('http'):
                urls.add(url)

        # Find standalone URLs
        standalone_urls = re.findall(r'(?:^|\s)(https?://[^\s<>"\'\)]+)', self.content)
        urls.update(standalone_urls)

        # Find URLs in Resources section
        resources_section = re.search(r'## Resources.*?(?=##|$)', self.content, re.DOTALL)
        if resources_section:
            section_text = resources_section.group(0)
            # Extract from bullet points or table cells
            lines = section_text.split('\n')
            for line in lines:
                # Look for domain patterns
                domains = re.findall(r'(?:github\.com|docs\.|\.org|\.net|cloudrumble\.net)[^\s,)]*', line)
                for domain in domains:
                    if not domain.startswith('http'):
                        urls.add(f'https://{domain}')

        return sorted(list(urls))[:20]  # Limit to 20 URLs

    def generate_metadata(self) -> str:
        """Generate complete YouTube metadata"""
        title = self.extract_title()
        description = self.extract_description()
        tags = self.extract_tags()
        timestamps = self.extract_timestamps()
        resources = self.extract_resources()

        # Build metadata text
        lines = []
        lines.append("=" * 80)
        lines.append("YOUTUBE VIDEO METADATA")
        lines.append("=" * 80)
        lines.append("")

        # Title
        lines.append("TITLE:")
        lines.append(f"{title}")
        lines.append(f"({len(title)}/{self.MAX_TITLE_LENGTH} characters)")
        lines.append("")

        # Description
        lines.append("DESCRIPTION:")
        lines.append(description)
        lines.append("")
        if resources:
            lines.append("Links & Resources:")
            for url in resources:
                lines.append(f"• {url}")
            lines.append("")
        lines.append(f"({len(description)}/{self.MAX_DESCRIPTION_LENGTH} characters)")
        lines.append("")

        # Tags
        lines.append("TAGS:")
        tag_string = ", ".join(tags)
        lines.append(tag_string)
        lines.append(f"({len(tags)} tags, {len(tag_string)} characters)")
        lines.append("")

        # Timestamps/Chapters
        lines.append("TIMESTAMPS (YouTube Chapters):")
        lines.append("Copy and paste into video description:")
        lines.append("")
        for ts in timestamps:
            lines.append(f"{ts['time']} - {ts['title']}")
        lines.append("")

        # Metadata
        lines.append("=" * 80)
        lines.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        lines.append(f"Source: {self.presentation_file}")
        lines.append("=" * 80)

        return "\n".join(lines)

    def save_metadata(self):
        """Generate and save metadata to file"""
        metadata = self.generate_metadata()

        with open(self.output_file, 'w', encoding='utf-8') as f:
            f.write(metadata)

        print(f"✓ Generated: {self.output_file}")
        print(f"  Title: {self.extract_title()}")
        print(f"  Tags: {len(self.extract_tags())}")
        print(f"  Chapters: {len(self.extract_timestamps())}")
        print(f"  Resources: {len(self.extract_resources())}")

        return self.output_file


def main():
    parser = argparse.ArgumentParser(
        description='Generate YouTube metadata from presentation.md files'
    )
    parser.add_argument(
        'folder',
        help='Folder containing presentation.md file'
    )
    parser.add_argument(
        '--preview',
        action='store_true',
        help='Preview metadata without saving'
    )

    args = parser.parse_args()

    try:
        generator = YouTubeMetadataGenerator(args.folder)

        if args.preview:
            print(generator.generate_metadata())
        else:
            generator.save_metadata()

    except Exception as e:
        print(f"Error: {e}")
        return 1

    return 0


if __name__ == '__main__':
    exit(main())

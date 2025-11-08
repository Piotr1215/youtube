# YouTube Metadata Generator

Automatically extract YouTube-ready metadata from your presentation.md files.

## Features

- **Title Extraction**: From frontmatter or first `#` heading (max 100 chars)
- **Auto-Generated Description**: From presentation sections and outline
- **Smart Tag Extraction**: From **bold terms**, code blocks, and mentioned tools
- **YouTube Chapters**: Auto-generated timestamps from section headings
- **Resource Links**: Extracted URLs for video description

## Quick Start

### Generate metadata for one video:

```bash
just generate-metadata cv-pipeline
```

or with Python directly:

```bash
python3 generate_youtube_metadata.py cv-pipeline
```

### Generate metadata for all videos:

```bash
just metadata-all
```

### Preview without saving:

```bash
python3 generate_youtube_metadata.py cv-pipeline --preview
```

## Output Format

The generator creates a `youtube_metadata.txt` file in each video folder with:

```
================================================================================
YOUTUBE VIDEO METADATA
================================================================================

TITLE:
[Your video title]
(XX/100 characters)

DESCRIPTION:
In this video, we cover:
• [Topic 1]
• [Topic 2]
• [Topic 3]

Links & Resources:
• [URL 1]
• [URL 2]

(XXX/5000 characters)

TAGS:
tag1, tag2, tag3, tag4, tag5
(X tags, XXX characters)

TIMESTAMPS (YouTube Chapters):
Copy and paste into video description:

00:00 - Intro - [Title]
02:30 - [Section 1]
05:00 - [Section 2]
07:30 - [Section 3]

================================================================================
Generated: YYYY-MM-DD HH:MM:SS
Source: path/to/presentation.md
================================================================================
```

## How It Works

### 1. Title Extraction Priority

1. **Frontmatter** (YAML header):
   ```yaml
   ---
   title: My Awesome Video
   ---
   ```

2. **First Heading**:
   ```markdown
   # My Awesome Video
   ```

### 2. Description Generation

Extracts all `##` level section headings (excluding common sections like "Demo Time", "Resources", etc.)

### 3. Tag Extraction

- **Bold terms**: Extracts text from `**bold**` markdown
- **Code languages**: From code fence declarations (```python, ```bash, etc.)
- **Tool mentions**: Detects common tools (docker, kubernetes, vim, git, etc.)
- Character limit: 500 chars total across all tags

### 4. Timestamp Generation

- One chapter per `##` heading
- Default: 2.5 minutes per section
- First timestamp always `00:00` (required for YouTube chapters)
- Limit: 15 chapters max

### 5. Resource Extraction

- Markdown links: `[text](url)`
- Standalone URLs in Resources section
- Domain patterns: github.com, docs., .org, .net

## YouTube Requirements

### Chapters/Timestamps

✅ **Required for YouTube Chapters:**
- First timestamp must be `00:00`
- Minimum 3 chapters
- Each chapter at least 10 seconds long
- Add timestamps to video description

### Title Best Practices

- Max 100 characters
- Front-load keywords
- Use title case
- Avoid ALL CAPS (except acronyms)
- Be clear and engaging

### Description Best Practices

- Max 5000 characters
- Front-load important info
- Include timestamps for chapters
- Add resource links
- Include calls-to-action (like, subscribe, etc.)

### Tags Best Practices

- Max 500 characters total
- Use specific, relevant tags
- Include keyword variations
- Mix broad and specific tags
- Avoid misleading tags

## Example Workflow

1. **Create presentation**:
   ```bash
   just start my-video "My Amazing Topic"
   cd my-video
   # Edit presentation.md
   ```

2. **Generate metadata**:
   ```bash
   just generate-metadata my-video
   ```

3. **Review and customize**:
   ```bash
   cat my-video/youtube_metadata.txt
   # Edit if needed
   ```

4. **Upload to YouTube**:
   - Copy title from metadata file
   - Copy description with chapters
   - Copy tags (remove commas for YouTube UI)

## Customization Tips

### Improve Tag Extraction

Add more **bold terms** in your presentation for better tag extraction:

```markdown
## Introduction to **Docker**

We'll explore **containerization** using **Docker** and **Kubernetes**.
```

### Better Timestamps

Organize your presentation with clear `##` section headings:

```markdown
## Section Title

Content here...

<!-- end_slide -->

## Next Section

More content...
```

### Resource Links

Add a Resources section with links:

```markdown
## Resources

- GitHub: github.com/yourproject
- Docs: docs.yourproject.org
- Blog: yourblog.com
```

## Troubleshooting

### No metadata generated

**Problem**: Script doesn't find presentation.md

**Solution**: Ensure `presentation.md` exists in the folder:
```bash
ls my-video/presentation.md
```

### Wrong title extracted

**Problem**: Title is not what you expected

**Solutions**:
1. Add frontmatter with title:
   ```yaml
   ---
   title: Your Title Here
   ---
   ```
2. Or ensure first `#` heading is your title

### Missing tags

**Problem**: Not enough tags generated

**Solutions**:
1. Add more **bold** terms in your content
2. Use code blocks with language specifiers
3. Mention tools/technologies explicitly

### Timestamps don't match video

**Problem**: Generated timestamps assume 2.5 min per section

**Solution**: Manually adjust timestamps in the generated file before copying to YouTube

## Files

- `generate_youtube_metadata.py` - Main generator script
- `templates/youtube_metadata_template.txt` - Output format template
- `templates/README_METADATA.md` - This documentation

## See Also

- [YouTube Help - Add chapters to your videos](https://support.google.com/youtube/answer/9884579)
- [YouTube Best Practices](https://www.youtube.com/creators/)

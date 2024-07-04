#!/usr/bin/env node

const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');
const axios = require('axios');
const { Command } = require('commander');
const program = new Command();

program
  .name('mediummd')
  .description('Convert Medium blogs to markdown and clean up markdown.')
  .version('1.0.0')
  .argument('<url>', 'Medium blog URL to convert to Markdown')
  .action(async (url) => {
    async function downloadImage(url, filepath) {
      console.log(`Downloading image from ${url} to ${filepath}`);
      const response = await axios({
        url,
        responseType: 'stream',
      });
      return new Promise((resolve, reject) => {
        response.data
          .pipe(fs.createWriteStream(filepath))
          .on('finish', () => {
            console.log(`Image downloaded to ${filepath}`);
            resolve();
          })
          .on('error', e => {
            console.error(`Error downloading image: ${e.message}`);
            reject(e);
          });
      });
    }

    console.log(`Navigating to ${url}`);

    const browser = await puppeteer.launch();
    const page = await browser.newPage();
    await page.goto(url, {
      waitUntil: 'networkidle2',
    });

    const content = await page.evaluate(() => {
      const article = document.querySelector('article');
      return article ? article.innerHTML : '';
    });
    const $ = require('cheerio').load(content);

    // Create _media directory if it doesn't exist
    const mediaDir = path.resolve(process.cwd(), '_media');
    if (!fs.existsSync(mediaDir)) {
      fs.mkdirSync(mediaDir);
    }
    console.log(`Created media directory at ${mediaDir}`);

    // Generate a random number to prepend to all image filenames
    const randomPrefix = Math.floor(Math.random() * 1000000);
    console.log(`Using random prefix: ${randomPrefix}`);

    // Download images and update src attributes
    const imgPromises = [];
    $('img').each((i, img) => {
      const src = $(img).attr('src');
      if (src) {
        const imgName = `${randomPrefix}_image${i}.jpg`;
        const imgPath = path.join(mediaDir, imgName);
        console.log(`Found image: ${src}, saving as ${imgPath}`);
        imgPromises.push(downloadImage(src, imgPath));
        $(img).attr('src', `_media/${imgName}`);
        $(img).removeAttr('class width height');
      } else {
        console.log(`No src attribute found for image ${i}`);
      }
    });

    await Promise.all(imgPromises);

    const updatedHtml = `<html><body>${$.html()}</body></html>`;
    const outputHtmlPath = path.join(process.cwd(), 'blog.html');
    fs.writeFileSync(outputHtmlPath, updatedHtml);
    console.log(`Updated HTML written to ${outputHtmlPath}`);

    await browser.close();

    // Convert HTML to Markdown using the Lua filter
    const { exec } = require('child_process');
    const outputMdPath = path.join(process.cwd(), 'blog.md');
    exec(`pandoc --from html --to gfm -o ${outputMdPath} ${outputHtmlPath}`, (error, stdout, stderr) => {
      if (error) {
        console.error(`Error converting HTML to Markdown: ${error.message}`);
        return;
      }
      if (stderr) {
        console.error(`pandoc stderr: ${stderr}`);
        return;
      }
      console.log('HTML successfully converted to Markdown.');

      // Cleanup script starts here
      const filePath = outputMdPath;
      const tempFilePath = path.join(process.cwd(), 'temp_blog.md');

      function removeTagsKeepContent(data, tag) {
        const tagPattern = new RegExp(`<${tag}[^>]*>`, 'g');
        const closingTagPattern = new RegExp(`</${tag}>`, 'g');
        return data.replace(tagPattern, '').replace(closingTagPattern, '');
      }

      // Function to clean up the artifacts in code blocks and add bash syntax highlighting
      function cleanCodeBlocks(data) {
        return data.replace(/```[\s\S]*?```/g, match => {
          // Remove any unwanted characters after the initial backticks and add bash for syntax highlighting
          return match.replace(/```[^`\n]*\n/, '```bash\n');
        });
      }

      // Function to remove angle brackets around URLs
      function removeAngleBracketsAroundURLs(data) {
        return data.replace(/<https?:\/\/[^>]+>/g, match => {
          // Remove the angle brackets around the URL
          return match.slice(1, -1);
        });
      }

      // Function to remove everything between the last header and the line that contains only the word "Share"
      function removeContentAfterLastHeader(data) {
        const lines = data.split('\n');
        let lastHeaderIndex = -1;
        let shareLineIndex = -1;

        // Find the last header and the "Share" line
        for (let i = 0; i < lines.length; i++) {
          if (lines[i].startsWith('#')) {
            lastHeaderIndex = i;
          }
          if (lines[i].trim() === 'Share') {
            shareLineIndex = i;
            break;
          }
        }

        // If both the last header and "Share" line are found, remove the content in between and the "Share" line itself
        if (lastHeaderIndex !== -1 && shareLineIndex !== -1 && shareLineIndex > lastHeaderIndex) {
          return lines.slice(0, lastHeaderIndex + 1).concat(lines.slice(shareLineIndex + 1)).join('\n');
        }

        return data;
      }
      // Function to remove unnecessary empty lines
      function removeUnnecessaryEmptyLines(data) {
        return data.replace(/\n{2,}/g, '\n\n');
      }

      fs.readFile(filePath, 'utf8', (err, data) => {
        if (err) {
          console.error(`Error reading the file: ${err.message}`);
          return;
        }

        // Remove div and span tags but keep the content inside
        let cleanedData = removeTagsKeepContent(data, 'div');
        cleanedData = removeTagsKeepContent(cleanedData, 'span');

        // Clean up the artifacts in code blocks and add bash syntax highlighting
        cleanedData = cleanCodeBlocks(cleanedData);

        // Remove angle brackets around URLs
        cleanedData = removeAngleBracketsAroundURLs(cleanedData);

        // Remove content after the last header and before the "Share" line
        cleanedData = removeContentAfterLastHeader(cleanedData);

        // Remove unnecessary empty lines
        cleanedData = removeUnnecessaryEmptyLines(cleanedData);
        fs.writeFile(tempFilePath, cleanedData, 'utf8', (err) => {
          if (err) {
            console.error(`Error writing to the temporary file: ${err.message}`);
            return;
          }

          // Rename the temporary file to the original file
          fs.rename(tempFilePath, filePath, (err) => {
            if (err) {
              console.error(`Error renaming the temporary file: ${err.message}`);
              return;
            }
            console.log('Markdown file cleaned successfully!');

            // Remove the temporary HTML file
            fs.unlink(outputHtmlPath, (err) => {
              if (err) {
                console.error(`Error deleting the temporary HTML file: ${err.message}`);
                return;
              }
              console.log('Temporary HTML file deleted successfully!');
            });
          });
        });
      });
    });
  });

program.parse(process.argv);

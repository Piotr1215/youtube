#!/bin/bash
# Script to check if presentation renders properly

echo "Checking presentation syntax..."
presenterm --check presentation.md 2>&1

echo -e "\nCounting slides..."
grep -c "<!-- end_slide -->" presentation.md

echo -e "\nPresentation is ready to run with:"
echo "presenterm presentation.md"
echo "or"
echo "presenterm --present presentation.md"
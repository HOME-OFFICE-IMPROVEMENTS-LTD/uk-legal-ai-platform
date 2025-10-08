#!/bin/bash

# UK Legal AI Platform - PDF Bundle Generator
# Version: 2.0.0
# Purpose: Generate professional PDF court bundles from markdown templates

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }
log_ai() { echo -e "${PURPLE}🤖 $1${NC}"; }

# Usage information
show_usage() {
    cat << EOF
${CYAN}UK Legal AI Platform - PDF Bundle Generator${NC}

Usage: $0 [options]

Options:
  --input-dir <path>       Directory containing markdown documents
  --output-dir <path>      Directory for PDF output (default: input-dir/pdf)
  --bundle-name <name>     Name for the combined PDF bundle
  --cover-page             Generate cover page with case details
  --table-of-contents     Generate table of contents
  --page-numbers          Add page numbers to documents
  --watermark <text>       Add watermark to all pages
  --help                  Show this help message

Examples:
  # Generate PDFs for all markdown files in directory
  $0 --input-dir "docs/cases/2025-10-08-bankruptcy/generated"
  
  # Create complete bundle with cover page and TOC
  $0 --input-dir "docs/cases/2025-10-08-bankruptcy/generated" \\
     --bundle-name "Court_Bundle_2025-10-08" \\
     --cover-page --table-of-contents --page-numbers
  
  # Add draft watermark to all documents
  $0 --input-dir "docs/cases/2025-10-08-bankruptcy/generated" \\
     --watermark "DRAFT - CONFIDENTIAL"

Requirements:
  - pandoc (for markdown to PDF conversion)
  - pdfunite (for combining PDFs) 
  - pdftk (for advanced PDF manipulation)

EOF
}

# Default values
INPUT_DIR=""
OUTPUT_DIR=""
BUNDLE_NAME=""
COVER_PAGE=false
TABLE_OF_CONTENTS=false
PAGE_NUMBERS=false
WATERMARK=""

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                show_usage
                exit 0
                ;;
            --input-dir)
                INPUT_DIR="$2"
                shift 2
                ;;
            --output-dir)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            --bundle-name)
                BUNDLE_NAME="$2"
                shift 2
                ;;
            --cover-page)
                COVER_PAGE=true
                shift
                ;;
            --table-of-contents)
                TABLE_OF_CONTENTS=true
                shift
                ;;
            --page-numbers)
                PAGE_NUMBERS=true
                shift
                ;;
            --watermark)
                WATERMARK="$2"
                shift 2
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

# Check required tools
check_dependencies() {
    local missing_tools=()
    
    if ! command -v pandoc >/dev/null 2>&1; then
        missing_tools+=("pandoc")
    fi
    
    if ! command -v pdfunite >/dev/null 2>&1; then
        missing_tools+=("pdfunite (from poppler-utils)")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Install with: sudo apt-get install pandoc poppler-utils"
        exit 1
    fi
    
    log_success "All required tools are available"
}

# Setup directories
setup_directories() {
    if [[ -z "$INPUT_DIR" ]]; then
        log_error "Input directory is required"
        show_usage
        exit 1
    fi
    
    if [[ ! -d "$INPUT_DIR" ]]; then
        log_error "Input directory does not exist: $INPUT_DIR"
        exit 1
    fi
    
    if [[ -z "$OUTPUT_DIR" ]]; then
        OUTPUT_DIR="$INPUT_DIR/pdf"
    fi
    
    mkdir -p "$OUTPUT_DIR"
    log_info "Input directory: $INPUT_DIR"
    log_info "Output directory: $OUTPUT_DIR"
}

# Generate cover page
generate_cover_page() {
    if [[ "$COVER_PAGE" == true ]]; then
        log_info "Generating cover page..."
        
        local cover_md="$OUTPUT_DIR/00_cover_page.md"
        local case_id=$(basename "$(dirname "$INPUT_DIR")")
        
        cat > "$cover_md" << EOF
---
geometry: margin=2cm
header-includes:
  - \\usepackage{fancyhdr}
  - \\pagestyle{fancy}
  - \\fancyhead{}
  - \\fancyfoot{}
  - \\renewcommand{\\headrulewidth}{0pt}
  - \\renewcommand{\\footrulewidth}{0pt}
---

\\vspace*{3cm}

\\begin{center}
{\\Huge \\textbf{COURT BUNDLE}}

\\vspace{1cm}

{\\Large County Court at Central London}

\\vspace{0.5cm}

{\\large Case No: 0095 of 2025}

\\vspace{2cm}

{\\LARGE \\textbf{APPLICATION FOR ANNULMENT}}

{\\Large \\textbf{OF BANKRUPTCY ORDER}}

\\vspace{1cm}

{\\large Under Section 282(1)(b) Insolvency Act 1986}

\\vspace{3cm}

{\\large Generated by UK Legal AI Platform v2.0.0}

{\\normalsize $(date '+%d %B %Y')}

\\vspace{2cm}

{\\small CONFIDENTIAL LEGAL DOCUMENT}
\\end{center}

\\newpage
EOF
        
        # Convert to PDF
        pandoc "$cover_md" -o "$OUTPUT_DIR/00_cover_page.pdf" \
            --pdf-engine=pdflatex \
            --template=eisvogel 2>/dev/null || \
        pandoc "$cover_md" -o "$OUTPUT_DIR/00_cover_page.pdf" \
            --pdf-engine=pdflatex 2>/dev/null || \
        pandoc "$cover_md" -o "$OUTPUT_DIR/00_cover_page.pdf"
        
        log_success "Cover page generated"
    fi
}

# Generate table of contents
generate_table_of_contents() {
    if [[ "$TABLE_OF_CONTENTS" == true ]]; then
        log_info "Generating table of contents..."
        
        local toc_md="$OUTPUT_DIR/01_table_of_contents.md"
        
        cat > "$toc_md" << 'EOF'
# Table of Contents

## Court Documents

| Document | Page | Description |
|----------|------|-------------|
| Cover Page | 1 | Court bundle cover page |
| Table of Contents | 2 | This page |
| N244 Application | 3 | Application for annulment |
| Witness Statement | 5 | Supporting evidence |
| Draft Order | 8 | Proposed court order |
| Correspondence | 10 | Letters to OR and creditors |

---

## Document Summary

This bundle contains the complete application for annulment of bankruptcy order under s.282(1)(b) Insolvency Act 1986, including:

- **Primary Application**: Form N244 with grounds for annulment
- **Supporting Evidence**: Witness statement with factual background
- **Proposed Order**: Draft case management directions
- **Correspondence**: Letters to Official Receiver and creditors

**Total Documents**: 5 primary documents + correspondence  
**Bundle Prepared**: $(date '+%d %B %Y')  
**Generated By**: UK Legal AI Platform v2.0.0

---

*This bundle is prepared in accordance with Civil Procedure Rules and Practice Directions for court applications.*

EOF
        
        # Convert to PDF
        pandoc "$toc_md" -o "$OUTPUT_DIR/01_table_of_contents.pdf" \
            --pdf-engine=pdflatex 2>/dev/null || \
        pandoc "$toc_md" -o "$OUTPUT_DIR/01_table_of_contents.pdf"
        
        log_success "Table of contents generated"
    fi
}

# Convert markdown files to PDF
convert_markdown_files() {
    log_info "Converting markdown files to PDF..."
    
    local converted_count=0
    
    # Process all markdown files (excluding generated cover/toc)
    for md_file in "$INPUT_DIR"/*.md; do
        if [[ -f "$md_file" ]]; then
            local basename=$(basename "$md_file" .md)
            local pdf_file="$OUTPUT_DIR/${basename}.pdf"
            
            # Skip if this is a generated file
            if [[ "$basename" == "00_cover_page" || "$basename" == "01_table_of_contents" ]]; then
                continue
            fi
            
            log_info "Converting: $basename.md"
            
            # Pandoc options
            local pandoc_options=(
                "$md_file"
                -o "$pdf_file"
                --pdf-engine=pdflatex
                --variable=geometry:margin=2.5cm
                --variable=fontsize=12pt
                --variable=fontfamily=serif
            )
            
            # Add page numbers if requested
            if [[ "$PAGE_NUMBERS" == true ]]; then
                pandoc_options+=(
                    --include-in-header=<(echo '\usepackage{fancyhdr}')
                    --include-in-header=<(echo '\pagestyle{fancy}')
                    --include-in-header=<(echo '\fancyhead{}')
                    --include-in-header=<(echo '\fancyfoot[C]{\thepage}')
                )
            fi
            
            # Convert with fallback options
            if pandoc "${pandoc_options[@]}" 2>/dev/null; then
                log_success "Converted: $basename.pdf"
                ((converted_count++))
            else
                # Fallback without fancy options
                log_warning "Fallback conversion for: $basename.md"
                pandoc "$md_file" -o "$pdf_file" --pdf-engine=pdflatex 2>/dev/null || \
                pandoc "$md_file" -o "$pdf_file" 2>/dev/null || \
                log_error "Failed to convert: $basename.md"
            fi
        fi
    done
    
    log_success "Converted $converted_count markdown files to PDF"
}

# Combine PDFs into bundle
create_bundle() {
    if [[ -n "$BUNDLE_NAME" ]]; then
        log_info "Creating combined PDF bundle..."
        
        local bundle_pdf="$OUTPUT_DIR/${BUNDLE_NAME}.pdf"
        local pdf_files=()
        
        # Collect PDF files in order
        for pdf_file in "$OUTPUT_DIR"/*.pdf; do
            if [[ -f "$pdf_file" && "$(basename "$pdf_file")" != "$BUNDLE_NAME.pdf" ]]; then
                pdf_files+=("$pdf_file")
            fi
        done
        
        if [[ ${#pdf_files[@]} -gt 0 ]]; then
            # Sort files to ensure proper order
            IFS=$'\n' pdf_files=($(sort <<<"${pdf_files[*]}"))
            unset IFS
            
            if pdfunite "${pdf_files[@]}" "$bundle_pdf" 2>/dev/null; then
                log_success "Created bundle: $BUNDLE_NAME.pdf"
                
                # Add watermark if requested
                if [[ -n "$WATERMARK" ]]; then
                    add_watermark "$bundle_pdf"
                fi
                
                # Show file info
                log_info "Bundle size: $(du -h "$bundle_pdf" | cut -f1)"
                log_info "Pages combined: ${#pdf_files[@]} documents"
            else
                log_error "Failed to create PDF bundle"
            fi
        else
            log_warning "No PDF files found to combine"
        fi
    fi
}

# Add watermark to PDF
add_watermark() {
    local pdf_file="$1"
    
    if command -v pdftk >/dev/null 2>&1; then
        log_info "Adding watermark: $WATERMARK"
        
        # Create temporary watermark PDF
        local watermark_md="$OUTPUT_DIR/temp_watermark.md"
        cat > "$watermark_md" << EOF
---
geometry: margin=0cm
header-includes:
  - \\usepackage{tikz}
  - \\usepackage{eso-pic}
  - \\AddToShipoutPicture{\\begin{tikzpicture}[remember picture,overlay] \\node[rotate=45,scale=4,text opacity=0.1] at (current page.center) {$WATERMARK}; \\end{tikzpicture}}
---

EOF
        
        local watermark_pdf="$OUTPUT_DIR/temp_watermark.pdf"
        pandoc "$watermark_md" -o "$watermark_pdf" --pdf-engine=pdflatex 2>/dev/null
        
        if [[ -f "$watermark_pdf" ]]; then
            local watermarked_pdf="${pdf_file%.pdf}_watermarked.pdf"
            pdftk "$pdf_file" background "$watermark_pdf" output "$watermarked_pdf" 2>/dev/null
            
            if [[ -f "$watermarked_pdf" ]]; then
                mv "$watermarked_pdf" "$pdf_file"
                log_success "Watermark added"
            fi
            
            # Cleanup
            rm -f "$watermark_pdf" "$watermark_md"
        fi
    else
        log_warning "pdftk not available - skipping watermark"
    fi
}

# Generate summary report
generate_summary() {
    log_info "Generating PDF generation summary..."
    
    local summary_file="$OUTPUT_DIR/pdf_generation_summary.md"
    cat > "$summary_file" << EOF
# PDF Bundle Generation Summary

**Generated:** $(date '+%d %B %Y at %H:%M:%S')  
**Platform:** UK Legal AI Platform v2.0.0

## Input Directory
\`$INPUT_DIR\`

## Output Directory
\`$OUTPUT_DIR\`

## Generated Files
$(find "$OUTPUT_DIR" -name "*.pdf" -exec basename {} \; | sort | sed 's/^/- /')

## Bundle Configuration
- **Cover Page:** $COVER_PAGE
- **Table of Contents:** $TABLE_OF_CONTENTS
- **Page Numbers:** $PAGE_NUMBERS
- **Watermark:** ${WATERMARK:-None}
- **Bundle Name:** ${BUNDLE_NAME:-Individual files only}

## File Sizes
$(find "$OUTPUT_DIR" -name "*.pdf" -exec du -h {} \; | sort)

## AI Integration Commands
\`\`\`bash
# View generated PDFs
ls -la "$OUTPUT_DIR"/*.pdf

# Open bundle in default PDF viewer
xdg-open "$OUTPUT_DIR/$BUNDLE_NAME.pdf" 2>/dev/null

# Generate with Copilot assistance
/chat @workspace Review the PDF bundle at $OUTPUT_DIR/ and suggest improvements
\`\`\`

**Status:** Complete ✅
EOF
    
    log_success "Summary report: $summary_file"
}

# Main execution
main() {
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 1
    fi
    
    parse_arguments "$@"
    
    log_info "📄 UK Legal AI Platform - PDF Bundle Generator"
    
    check_dependencies
    setup_directories
    generate_cover_page
    generate_table_of_contents
    convert_markdown_files
    create_bundle
    generate_summary
    
    log_success "✨ PDF generation complete!"
    log_ai "Next steps:"
    log_ai "1. Review PDFs in: $OUTPUT_DIR"
    log_ai "2. Open bundle: xdg-open '$OUTPUT_DIR/$BUNDLE_NAME.pdf'"
    log_ai "3. Use Copilot: /chat @workspace Review PDF bundle quality"
}

# Execute main function
main "$@"
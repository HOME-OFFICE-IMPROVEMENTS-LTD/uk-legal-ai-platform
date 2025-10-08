#!/bin/bash

# UK Legal AI Platform - Template Generator
# Version: 2.0.0
# Purpose: Generate legal documents from templates with AI assistance

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
TEMPLATES_DIR="$PROJECT_ROOT/templates"
OUTPUT_DIR="$PROJECT_ROOT/docs/generated"
CONFIG_DIR="$PROJECT_ROOT/config"

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
${CYAN}UK Legal AI Platform - Template Generator${NC}

Usage: $0 <template_type> [options]

Template Types:
  n244                  Generate N244 Application Form
  witness_statement     Generate Witness Statement
  draft_order          Generate Draft Court Order
  letter_or            Generate Letter to Official Receiver
  letter_creditor      Generate Letter to Creditors
  checklist            Generate Action Checklist
  bundle               Generate Complete Court Bundle

Options:
  --case-id <id>           Case identifier (default: auto-generated)
  --court <name>           Court name
  --case-number <num>      Case number
  --debtor <name>          Debtor full name
  --witness <name>         Witness name
  --bankruptcy-date <date> Bankruptcy order date
  --hearing-date <date>    Court hearing date
  --variables-file <path>  JSON file with case variables
  --output-dir <path>      Custom output directory
  --format <type>          Output format: md, pdf, docx (default: md)
  --ai-enhance             Use AI to enhance generated content
  --validate               Validate generated documents
  --help                   Show this help message

Examples:
  # Generate N244 application with basic details
  $0 n244 --court "County Court at Central London" --case-number "0095 of 2025"
  
  # Generate witness statement with AI enhancement
  $0 witness_statement --witness "John Smith" --ai-enhance
  
  # Generate complete court bundle from variables file
  $0 bundle --variables-file "config/cases/2025-10-08-bankruptcy-vars.json"
  
  # Generate all documents for a case
  $0 bundle --case-id "2025-10-08-bankruptcy" --validate

AI Integration:
  This tool integrates with GitHub Copilot and Codex for:
  - Content enhancement and legal language optimization
  - Automatic deadline calculation
  - Template validation and compliance checking
  - Multi-format document generation

EOF
}

# Default values
TEMPLATE_TYPE=""
CASE_ID=""
COURT_NAME=""
CASE_NUMBER=""
DEBTOR_NAME=""
WITNESS_NAME=""
BANKRUPTCY_DATE=""
HEARING_DATE=""
VARIABLES_FILE=""
OUTPUT_FORMAT="md"
AI_ENHANCE=false
VALIDATE=false
CUSTOM_OUTPUT_DIR=""

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                show_usage
                exit 0
                ;;
            --case-id)
                CASE_ID="$2"
                shift 2
                ;;
            --court)
                COURT_NAME="$2"
                shift 2
                ;;
            --case-number)
                CASE_NUMBER="$2"
                shift 2
                ;;
            --debtor)
                DEBTOR_NAME="$2"
                shift 2
                ;;
            --witness)
                WITNESS_NAME="$2"
                shift 2
                ;;
            --bankruptcy-date)
                BANKRUPTCY_DATE="$2"
                shift 2
                ;;
            --hearing-date)
                HEARING_DATE="$2"
                shift 2
                ;;
            --variables-file)
                VARIABLES_FILE="$2"
                shift 2
                ;;
            --output-dir)
                CUSTOM_OUTPUT_DIR="$2"
                shift 2
                ;;
            --format)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            --ai-enhance)
                AI_ENHANCE=true
                shift
                ;;
            --validate)
                VALIDATE=true
                shift
                ;;
            n244|witness_statement|draft_order|letter_or|letter_creditor|checklist|bundle)
                TEMPLATE_TYPE="$1"
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

# Load variables from JSON file
load_variables() {
    if [[ -n "$VARIABLES_FILE" && -f "$VARIABLES_FILE" ]]; then
        log_info "Loading variables from $VARIABLES_FILE"
        
        # Extract variables using jq if available
        if command -v jq >/dev/null 2>&1; then
            CASE_ID="${CASE_ID:-$(jq -r '.case_id // empty' "$VARIABLES_FILE")}"
            COURT_NAME="${COURT_NAME:-$(jq -r '.court_name // empty' "$VARIABLES_FILE")}"
            CASE_NUMBER="${CASE_NUMBER:-$(jq -r '.case_number // empty' "$VARIABLES_FILE")}"
            DEBTOR_NAME="${DEBTOR_NAME:-$(jq -r '.debtor_name // empty' "$VARIABLES_FILE")}"
            WITNESS_NAME="${WITNESS_NAME:-$(jq -r '.witness_name // empty' "$VARIABLES_FILE")}"
            BANKRUPTCY_DATE="${BANKRUPTCY_DATE:-$(jq -r '.bankruptcy_date // empty' "$VARIABLES_FILE")}"
            HEARING_DATE="${HEARING_DATE:-$(jq -r '.hearing_date // empty' "$VARIABLES_FILE")}"
        else
            log_warning "jq not found. Install jq for JSON variable loading."
        fi
    fi
}

# Generate case ID if not provided
generate_case_id() {
    if [[ -z "$CASE_ID" ]]; then
        CASE_ID="$(date +%Y-%m-%d)-$(echo "$DEBTOR_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')"
        log_info "Generated case ID: $CASE_ID"
    fi
}

# Create output directory
setup_output_dir() {
    if [[ -n "$CUSTOM_OUTPUT_DIR" ]]; then
        OUTPUT_DIR="$CUSTOM_OUTPUT_DIR"
    else
        OUTPUT_DIR="$PROJECT_ROOT/docs/cases/$CASE_ID/generated"
    fi
    
    mkdir -p "$OUTPUT_DIR"
    log_info "Output directory: $OUTPUT_DIR"
}

# Template substitution function
substitute_variables() {
    local template_file="$1"
    local output_file="$2"
    
    log_info "Processing template: $(basename "$template_file")"
    
    # Copy template to output
    cp "$template_file" "$output_file"
    
    # Perform substitutions
    local substitutions=(
        "s/\[CASE_ID\]/$CASE_ID/g"
        "s/\[COURT_NAME\]/$COURT_NAME/g"
        "s/\[CASE_NUMBER\]/$CASE_NUMBER/g"
        "s/\[DEBTOR_FULL_NAME\]/$DEBTOR_NAME/g"
        "s/\[DEBTOR_NAME\]/$DEBTOR_NAME/g"
        "s/\[WITNESS_NAME\]/$WITNESS_NAME/g"
        "s/\[BANKRUPTCY_DATE\]/$BANKRUPTCY_DATE/g"
        "s/\[HEARING_DATE\]/$HEARING_DATE/g"
        "s/\[FILING_DATE\]/$(date +%d\ %B\ %Y)/g"
        "s/\[STATEMENT_DATE\]/$(date +%d\ %B\ %Y)/g"
        "s/\[SIGNATURE_DATE\]/$(date +%d\ %B\ %Y)/g"
        "s/\[LETTER_DATE\]/$(date +%d\ %B\ %Y)/g"
        "s/\[ORDER_DATE\]/$(date +%d\ %B\ %Y)/g"
    )
    
    for substitution in "${substitutions[@]}"; do
        sed -i "$substitution" "$output_file"
    done
    
    log_success "Generated: $(basename "$output_file")"
}

# AI enhancement function
enhance_with_ai() {
    local file="$1"
    
    if [[ "$AI_ENHANCE" == true ]]; then
        log_ai "Enhancing document with AI assistance..."
        
        # Create AI prompt for enhancement
        cat > "${file}.ai_prompt" << EOF
Please review and enhance this legal document:
- Improve legal language and terminology
- Ensure professional tone and structure
- Check for completeness and clarity
- Maintain all placeholder variables intact
- Suggest any missing elements

Document to enhance:
$(cat "$file")
EOF
        
        log_ai "AI prompt created: ${file}.ai_prompt"
        log_ai "Run: /chat @workspace Please enhance the document at ${file}.ai_prompt"
    fi
}

# Document validation
validate_document() {
    local file="$1"
    local doc_type="$2"
    
    if [[ "$VALIDATE" == true ]]; then
        log_info "Validating $doc_type document..."
        
        local issues=0
        
        # Check for unreplaced placeholders
        if grep -q "\[.*\]" "$file"; then
            log_warning "Unreplaced placeholders found in $file:"
            grep -o "\[.*\]" "$file" | sort | uniq
            ((issues++))
        fi
        
        # Check for required sections based on document type
        case "$doc_type" in
            "n244")
                grep -q "Application for:" "$file" || { log_warning "Missing 'Application for:' section"; ((issues++)); }
                ;;
            "witness_statement")
                grep -q "Statement of Truth" "$file" || { log_warning "Missing 'Statement of Truth' section"; ((issues++)); }
                ;;
            "draft_order")
                grep -q "Orders" "$file" || { log_warning "Missing 'Orders' section"; ((issues++)); }
                ;;
        esac
        
        if [[ $issues -eq 0 ]]; then
            log_success "Document validation passed"
        else
            log_warning "Document validation found $issues issues"
        fi
    fi
}

# Generate N244 Application
generate_n244() {
    log_info "Generating N244 Application Form..."
    
    local template="$TEMPLATES_DIR/court/n244_template.md"
    local output="$OUTPUT_DIR/n244_application.md"
    
    # Create template if it doesn't exist
    if [[ ! -f "$template" ]]; then
        mkdir -p "$(dirname "$template")"
        cat > "$template" << 'EOF'
# Application Notice (Form N244)
**Court:** [COURT_NAME]
**Case Number:** [CASE_NUMBER]
**Date Filed:** [FILING_DATE]

**In the matter of:** [DEBTOR_FULL_NAME]
**Bankruptcy Order dated:** [BANKRUPTCY_DATE]

## Application Details
- **Application for:** Annulment of bankruptcy order under s.282(1)(b) Insolvency Act 1986
- **Fee paid:** £155
- **Evidence attached:** Witness statement and draft order

## Grounds for Application
The applicant seeks annulment on the basis that all bankruptcy debts and expenses can be paid in full from available funds.

## Evidence in Support
1. Witness statement of [WITNESS_NAME] dated [STATEMENT_DATE]
2. Draft order with case management directions
3. Financial evidence demonstrating ability to pay all debts

## Prayer
The applicant respectfully requests that the Court:
1. Grant case management directions for the invitation of proofs of debt
2. List the application for hearing
3. Upon hearing, grant annulment of the bankruptcy order

**Dated:** [FILING_DATE]
**Applicant:** [DEBTOR_FULL_NAME]
EOF
    fi
    
    substitute_variables "$template" "$output"
    enhance_with_ai "$output"
    validate_document "$output" "n244"
}

# Generate Witness Statement
generate_witness_statement() {
    log_info "Generating Witness Statement..."
    
    local template="$TEMPLATES_DIR/court/witness_statement_template.md"
    local output="$OUTPUT_DIR/witness_statement.md"
    
    # Use existing template or create new one
    if [[ ! -f "$template" ]]; then
        # Copy from existing witness statement template
        local existing_template="$PROJECT_ROOT/templates/legal/WitnessStatement_Template.md"
        if [[ -f "$existing_template" ]]; then
            cp "$existing_template" "$template"
        fi
    fi
    
    substitute_variables "$template" "$output"
    enhance_with_ai "$output"
    validate_document "$output" "witness_statement"
}

# Generate Draft Order
generate_draft_order() {
    log_info "Generating Draft Court Order..."
    
    local template="$TEMPLATES_DIR/court/draft_order_template.md"
    local output="$OUTPUT_DIR/draft_order.md"
    
    # Use existing template or create new one
    if [[ ! -f "$template" ]]; then
        local existing_template="$PROJECT_ROOT/templates/legal/DraftOrder_Annulment_s282b.md"
        if [[ -f "$existing_template" ]]; then
            cp "$existing_template" "$template"
        fi
    fi
    
    substitute_variables "$template" "$output"
    enhance_with_ai "$output"
    validate_document "$output" "draft_order"
}

# Generate Letters
generate_letter() {
    local letter_type="$1"
    log_info "Generating $letter_type letter..."
    
    local template="$TEMPLATES_DIR/correspondence/${letter_type}_template.md"
    local output="$OUTPUT_DIR/${letter_type}.md"
    
    # Create basic letter template if it doesn't exist
    if [[ ! -f "$template" ]]; then
        mkdir -p "$(dirname "$template")"
        cat > "$template" << EOF
# Letter to ${letter_type//_/ }
**Date:** [LETTER_DATE]
**Our Ref:** [CASE_ID]

**To:** [RECIPIENT]
**Re:** [DEBTOR_FULL_NAME] - Bankruptcy No. [CASE_NUMBER]

Dear Sir/Madam,

[LETTER_CONTENT]

Yours faithfully,

[SENDER_NAME]
[SENDER_TITLE]
EOF
    fi
    
    substitute_variables "$template" "$output"
    enhance_with_ai "$output"
    validate_document "$output" "letter"
}

# Generate Complete Bundle
generate_bundle() {
    log_info "Generating Complete Court Bundle..."
    
    generate_n244
    generate_witness_statement
    generate_draft_order
    generate_letter "official_receiver"
    generate_letter "creditors"
    
    # Create bundle index
    local index="$OUTPUT_DIR/bundle_index.md"
    cat > "$index" << EOF
# Court Bundle Index
**Case:** [CASE_ID]
**Generated:** $(date '+%d %B %Y at %H:%M')

## Documents
1. **N244 Application Form** - n244_application.md
2. **Witness Statement** - witness_statement.md
3. **Draft Order** - draft_order.md
4. **Letter to Official Receiver** - official_receiver.md
5. **Letter to Creditors** - creditors.md

## AI Enhancement
Run the following commands for AI-assisted improvements:

\`\`\`bash
# Enhance all documents
for file in *.md; do
    /chat @workspace Please review and enhance the legal document at $OUTPUT_DIR/\$file
done

# Generate PDF bundle
./scripts/ai-integration/generate_pdf_bundle.sh --input-dir "$OUTPUT_DIR"
\`\`\`

**Bundle Status:** Generated - Ready for AI Enhancement
EOF
    
    substitute_variables "$index" "$index"
    log_success "Complete court bundle generated in $OUTPUT_DIR"
}

# Main execution
main() {
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 1
    fi
    
    parse_arguments "$@"
    
    if [[ -z "$TEMPLATE_TYPE" ]]; then
        log_error "Template type is required"
        show_usage
        exit 1
    fi
    
    load_variables
    generate_case_id
    setup_output_dir
    
    log_info "🏛️  UK Legal AI Platform - Template Generator"
    log_info "Template Type: $TEMPLATE_TYPE"
    log_info "Case ID: $CASE_ID"
    
    case "$TEMPLATE_TYPE" in
        "n244")
            generate_n244
            ;;
        "witness_statement")
            generate_witness_statement
            ;;
        "draft_order")
            generate_draft_order
            ;;
        "letter_or")
            generate_letter "official_receiver"
            ;;
        "letter_creditor")
            generate_letter "creditors"
            ;;
        "checklist")
            log_info "Checklist generation not yet implemented"
            ;;
        "bundle")
            generate_bundle
            ;;
        *)
            log_error "Unknown template type: $TEMPLATE_TYPE"
            exit 1
            ;;
    esac
    
    log_success "✨ Template generation complete!"
    log_ai "Next steps:"
    log_ai "1. Review generated documents in: $OUTPUT_DIR"
    log_ai "2. Use Copilot to enhance content: /chat @workspace Review documents in $OUTPUT_DIR"
    log_ai "3. Generate PDFs: ./scripts/ai-integration/generate_pdf_bundle.sh"
    log_ai "4. Validate compliance: ./scripts/quality/validate_documents.sh"
}

# Execute main function
main "$@"
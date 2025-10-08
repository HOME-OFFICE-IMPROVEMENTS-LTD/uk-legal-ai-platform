#!/usr/bin/env bash
# Enhanced Legal Document Splitter with AI Integration
# Processes large legal documents into manageable, queryable sections
set -euo pipefail

# Configuration
readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Default configuration (can be overridden)
SRC="${1:-docs/chats/gpt5-legal-research/2025-10-08-bankruptcy-discussion.md}"
CASE_ID="${2:-2025-10-08-bankruptcy}"
OUTDIR="docs/cases/$CASE_ID"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}ℹ️  $*${NC}"; }
log_success() { echo -e "${GREEN}✅ $*${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $*${NC}"; }
log_error() { echo -e "${RED}❌ $*${NC}" >&2; }

# Validate inputs
validate_inputs() {
    if [[ ! -f "$SRC" ]]; then
        log_error "Source file not found: $SRC"
        exit 1
    fi
    
    if [[ ! -d "$REPO_ROOT" ]]; then
        log_error "Repository root not found: $REPO_ROOT"
        exit 1
    fi
}

# Create metadata for the split
create_metadata() {
    local total_lines original_size timestamp
    total_lines=$(wc -l < "$SRC")
    original_size=$(du -h "$SRC" | cut -f1)
    timestamp=$(date '+%Y-%m-%d %H:%M:%S %Z')
    
    log_info "Creating metadata for $total_lines lines ($original_size)"
    
    # Create case metadata
    cat > "$OUTDIR/case-metadata.json" << EOF
{
  "case_id": "$CASE_ID",
  "original_file": "$SRC",
  "split_timestamp": "$timestamp",
  "total_lines": $total_lines,
  "file_size": "$original_size",
  "split_method": "content-aware-sectioning",
  "script_version": "$SCRIPT_VERSION",
  "sections": {
    "01-initial-situation": {
      "lines": "1-4000",
      "focus": "Overview, debt analysis, initial legal position",
      "ai_tags": ["debt-analysis", "initial-assessment", "financial-position"]
    },
    "02-process-proceedings": {
      "lines": "4001-8000", 
      "focus": "Bankruptcy proceedings, legal process, court interactions",
      "ai_tags": ["bankruptcy-process", "court-proceedings", "legal-procedure"]
    },
    "03-annulment-options": {
      "lines": "8001-12000",
      "focus": "Annulment procedures, s.282(1)(b) requirements, options analysis",
      "ai_tags": ["annulment", "section-282", "legal-options", "strategy"]
    },
    "04-strategy-next-steps": {
      "lines": "12001-end",
      "focus": "Strategic recommendations, action plans, next steps",
      "ai_tags": ["strategy", "action-plan", "next-steps", "implementation"]
    }
  }
}
EOF
}

# Create AI integration configuration
create_ai_config() {
    log_info "Creating AI assistant configuration"
    
    mkdir -p "$REPO_ROOT/config/ai-prompts"
    
    cat > "$REPO_ROOT/config/ai-prompts/legal-document-analysis.json" << 'EOF'
{
  "prompts": {
    "summarize_section": "Analyze this legal document section and create a structured summary with: 1) Key legal points, 2) Action items, 3) Deadlines/timelines, 4) Risk factors, 5) Strategic considerations. Focus on actionable insights.",
    "extract_templates": "From this legal document section, identify reusable templates, standard procedures, and generalizable forms that could be used for similar cases. Output as structured markdown.",
    "generate_checklist": "Create a detailed checklist from this legal document section for case management. Include deadlines, required documents, procedural steps, and compliance requirements.",
    "identify_precedents": "Extract legal precedents, case references, statutory provisions, and procedural rules mentioned in this section. Format as a structured knowledge base entry."
  },
  "output_formats": {
    "summary": "markdown with structured headings",
    "checklist": "checkbox list with deadlines and priorities",
    "templates": "markdown templates with [PLACEHOLDER] variables",
    "knowledge_base": "structured JSON with categories and tags"
  }
}
EOF
}

# Enhanced splitting with content awareness
split_document() {
    local section_files=()
    
    log_info "Splitting document into content-aware sections..."
    
    mkdir -p "$OUTDIR"/{evidence,correspondence,filings,ai-analysis}
    
    # Section 1: Initial Situation and Debts (enhanced)
    {
        cat << 'HEADER1'
# Initial Situation and Debts Analysis

**Case Reference:** [CASE_ID]  
**Section:** 1 of 4  
**Focus:** Overview, debt analysis, initial legal position  
**AI Tags:** `debt-analysis` `initial-assessment` `financial-position`

---

## 📋 AI Assistant Usage
```bash
# Generate summary
./scripts/ai-integration/analyze_section.sh 01-initial-situation "summarize_section"

# Extract templates  
./scripts/ai-integration/analyze_section.sh 01-initial-situation "extract_templates"

# Create checklist
./scripts/ai-integration/analyze_section.sh 01-initial-situation "generate_checklist"
```

---

HEADER1
        sed -n '1,4000p' "$SRC"
    } > "$OUTDIR/01-initial-situation-and-debts.md"
    section_files+=("01-initial-situation-and-debts.md")
    
    # Section 2: Process and Proceedings (enhanced)
    {
        cat << 'HEADER2'
# Process and Proceedings

**Case Reference:** [CASE_ID]  
**Section:** 2 of 4  
**Focus:** Bankruptcy proceedings, legal process, court interactions  
**AI Tags:** `bankruptcy-process` `court-proceedings` `legal-procedure`

---

## 📋 AI Assistant Usage
```bash
# Analyze proceedings
./scripts/ai-integration/analyze_section.sh 02-process-proceedings "summarize_section"

# Extract court templates
./scripts/ai-integration/analyze_section.sh 02-process-proceedings "extract_templates"
```

---

HEADER2
        sed -n '4001,8000p' "$SRC"
    } > "$OUTDIR/02-process-and-proceedings.md"
    section_files+=("02-process-and-proceedings.md")
    
    # Section 3: Annulment Options (enhanced)
    {
        cat << 'HEADER3'
# Annulment Options and Procedure

**Case Reference:** [CASE_ID]  
**Section:** 3 of 4  
**Focus:** Annulment procedures, s.282(1)(b) requirements, options analysis  
**AI Tags:** `annulment` `section-282` `legal-options` `strategy`

---

## 📋 AI Assistant Usage
```bash
# Analyze annulment options
./scripts/ai-integration/analyze_section.sh 03-annulment-options "summarize_section"

# Generate s.282(1)(b) checklist
./scripts/ai-integration/analyze_section.sh 03-annulment-options "generate_checklist"
```

---

HEADER3
        sed -n '8001,12000p' "$SRC"
    } > "$OUTDIR/03-annulment-options-and-procedure.md"
    section_files+=("03-annulment-options-and-procedure.md")
    
    # Section 4: Strategy and Next Steps (enhanced)
    {
        cat << 'HEADER4'
# Strategy and Next Steps

**Case Reference:** [CASE_ID]  
**Section:** 4 of 4  
**Focus:** Strategic recommendations, action plans, next steps  
**AI Tags:** `strategy` `action-plan` `next-steps` `implementation`

---

## 📋 AI Assistant Usage
```bash
# Generate action plan
./scripts/ai-integration/analyze_section.sh 04-strategy-next-steps "summarize_section"

# Create implementation checklist
./scripts/ai-integration/analyze_section.sh 04-strategy-next-steps "generate_checklist"
```

---

HEADER4
        sed -n '12001,$p' "$SRC"
    } > "$OUTDIR/04-strategy-and-next-steps.md"
    section_files+=("04-strategy-and-next-steps.md")
    
    echo "${section_files[@]}"
}

# Create comprehensive case index
create_case_index() {
    local section_files=("$@")
    
    log_info "Creating comprehensive case index"
    
    cat > "$OUTDIR/README.md" << EOF
# UK Legal AI Platform - Case Study
## Bankruptcy Annulment Case: $CASE_ID

**🎯 Purpose:** Real-world legal case serving as foundation for AI-assisted legal platform development.

### 📁 File Structure

#### Core Documents
$(for file in "${section_files[@]}"; do
    lines=$(wc -l < "$OUTDIR/$file")
    echo "- **$file** ($lines lines) - $(grep "Focus:" "$OUTDIR/$file" | cut -d: -f2-)"
done)

#### Supporting Directories
- **evidence/** - Case evidence and supporting documents
- **correspondence/** - Email chains and communication records  
- **filings/** - Court filings and formal submissions
- **ai-analysis/** - AI-generated summaries and analysis

### 🤖 AI Integration Points

#### Quick Analysis Commands
\`\`\`bash
# Analyze all sections
for section in 01-initial-situation 02-process-proceedings 03-annulment-options 04-strategy-next-steps; do
    ./scripts/ai-integration/analyze_section.sh \$section summarize_section
done

# Generate comprehensive checklist
./scripts/ai-integration/generate_case_checklist.sh $CASE_ID

# Create template library from case
./scripts/ai-integration/extract_templates.sh $CASE_ID
\`\`\`

#### Copilot Chat Prompts
\`\`\`
/chat @workspace Analyze docs/cases/$CASE_ID/01-initial-situation-and-debts.md and extract key debt figures, creditor details, and financial position into a structured summary.

/chat @workspace From docs/cases/$CASE_ID/03-annulment-options-and-procedure.md, create a step-by-step s.282(1)(b) annulment checklist with deadlines and required documents.

/chat @workspace Using all sections in docs/cases/$CASE_ID/, generate reusable templates for bankruptcy annulment applications.
\`\`\`

### 📊 Case Metrics
- **Original File:** $(basename "$SRC") ($(wc -l < "$SRC") lines)
- **Split Date:** $(date '+%Y-%m-%d %H:%M:%S')
- **Platform Version:** $SCRIPT_VERSION
- **AI Ready:** ✅ Configured for Codex/Copilot integration

### 🚀 Next Steps
1. Use AI assistants to generate summaries for each section
2. Extract reusable templates and procedures  
3. Build generalized workflows for future bankruptcy cases
4. Expand platform to other legal areas (tenancy, litigation, etc.)

---
*This case study demonstrates real-world application of AI-assisted legal document processing and workflow automation.*
EOF
}

# Create AI integration scripts
create_ai_scripts() {
    log_info "Creating AI integration scripts"
    
    mkdir -p "$REPO_ROOT/scripts/ai-integration"
    
    # Section analyzer script
    cat > "$REPO_ROOT/scripts/ai-integration/analyze_section.sh" << 'EOF'
#!/usr/bin/env bash
# AI Section Analyzer - Integrates with Copilot/Codex for legal document analysis
set -euo pipefail

SECTION="${1:-}"
ANALYSIS_TYPE="${2:-summarize_section}"
CASE_DIR="docs/cases/2025-10-08-bankruptcy"

if [[ -z "$SECTION" ]]; then
    echo "Usage: $0 <section-name> [analysis-type]"
    echo "Sections: 01-initial-situation, 02-process-proceedings, 03-annulment-options, 04-strategy-next-steps"
    echo "Analysis: summarize_section, extract_templates, generate_checklist, identify_precedents"
    exit 1
fi

SECTION_FILE="$CASE_DIR/${SECTION}-*.md"
OUTPUT_DIR="$CASE_DIR/ai-analysis"
mkdir -p "$OUTPUT_DIR"

echo "🤖 AI Analysis: $ANALYSIS_TYPE on $SECTION"
echo "📄 Input: $SECTION_FILE"
echo "📂 Output: $OUTPUT_DIR/${SECTION}-${ANALYSIS_TYPE}.md"
echo ""
echo "💡 Copy this prompt into Copilot Chat:"
echo "----------------------------------------"

case "$ANALYSIS_TYPE" in
    "summarize_section")
        echo "/chat @workspace Analyze $SECTION_FILE and create a structured summary with: 1) Key legal points, 2) Action items, 3) Deadlines/timelines, 4) Risk factors, 5) Strategic considerations. Output to $OUTPUT_DIR/${SECTION}-summary.md"
        ;;
    "extract_templates")
        echo "/chat @workspace From $SECTION_FILE, identify reusable templates, standard procedures, and generalizable forms. Create markdown templates with [PLACEHOLDER] variables. Output to $OUTPUT_DIR/${SECTION}-templates.md"
        ;;
    "generate_checklist")
        echo "/chat @workspace Create a detailed checklist from $SECTION_FILE for case management. Include deadlines, required documents, procedural steps. Output to $OUTPUT_DIR/${SECTION}-checklist.md"
        ;;
    "identify_precedents")
        echo "/chat @workspace Extract legal precedents, case references, statutory provisions from $SECTION_FILE. Format as structured knowledge base. Output to $OUTPUT_DIR/${SECTION}-precedents.md"
        ;;
esac

echo "----------------------------------------"
EOF
    chmod +x "$REPO_ROOT/scripts/ai-integration/analyze_section.sh"
}

# Main execution
main() {
    log_info "🏗️  UK Legal AI Platform - Enhanced Document Processor v$SCRIPT_VERSION"
    log_info "Building comprehensive legal platform using real bankruptcy case"
    echo
    
    validate_inputs
    create_metadata
    create_ai_config
    
    section_files=($(split_document))
    create_case_index "${section_files[@]}"
    create_ai_scripts
    
    log_success "📊 Split Analysis Complete:"
    echo
    for file in "${section_files[@]}"; do
        if [[ -f "$OUTDIR/$file" ]]; then
            lines=$(wc -l < "$OUTDIR/$file")
            size=$(du -h "$OUTDIR/$file" | cut -f1)
            echo "   📄 $file: $lines lines ($size)"
        fi
    done
    
    echo
    log_success "🎯 Platform Structure Ready:"
    echo "   📁 Case files: $OUTDIR/"
    echo "   🤖 AI config: config/ai-prompts/"
    echo "   🔧 AI tools: scripts/ai-integration/"
    echo
    log_info "🚀 Next Steps:"
    echo "   1. Run AI analysis: ./scripts/ai-integration/analyze_section.sh 01-initial-situation"
    echo "   2. Generate templates: Use Copilot Chat with provided prompts"
    echo "   3. Build workflows: Expand to other legal areas"
    echo
    log_success "✨ UK Legal AI Platform foundation complete!"
}

# Execute main function
main "$@"
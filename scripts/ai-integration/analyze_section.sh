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

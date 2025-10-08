# UK Legal AI Platform — Court Document Templates
**Platform Version:** 2.0.0  
**Template System:** AI-Powered Generation

---

## 📋 **N244 Application Form Template**

### Headers & Case Details
```markdown
# Application Notice (Form N244)
**Court:** [COURT_NAME]
**Case Number:** [CASE_NUMBER]
**Date Filed:** [FILING_DATE]

**In the matter of:** [DEBTOR_FULL_NAME]  
**Bankruptcy Order dated:** [BANKRUPTCY_DATE]

### Application Details
- **Application for:** Annulment of bankruptcy order under s.282(1)(b) Insolvency Act 1986
- **Fee paid:** £155
- **Evidence attached:** Witness statement and draft order
```

### AI Integration Points
```bash
# Generate N244 application
./scripts/ai-integration/generate_template.sh n244 \
  --court="[COURT_NAME]" \
  --case-number="[CASE_NUMBER]" \
  --debtor="[DEBTOR_FULL_NAME]" \
  --bankruptcy-date="[BANKRUPTCY_DATE]"

# Copilot assistance
/chat @workspace Generate N244 application for bankruptcy annulment with the following details: [CASE_VARIABLES]
```

---

## ⚖️ **Witness Statement Template**

### Structure & Content
```markdown
# Witness Statement
**Court:** [COURT_NAME]  
**Case No:** [CASE_NUMBER]  
**Witness:** [WITNESS_NAME]  
**Date:** [STATEMENT_DATE]

## Personal Details
1. I am [WITNESS_NAME] of [WITNESS_ADDRESS].
2. I am [RELATIONSHIP_TO_DEBTOR] to the debtor in this matter.
3. I make this statement in support of the application for annulment.

## Factual Background
4. The debtor was made bankrupt on [BANKRUPTCY_DATE] on a petition by [PETITIONING_CREDITOR].
5. The total amount of the bankruptcy debts is approximately £[TOTAL_DEBT_AMOUNT].
6. Since the bankruptcy order, [COOPERATION_DETAILS].

## Financial Position
7. The debtor's assets include [ASSET_DETAILS].
8. Funding for the annulment is available from [FUNDING_SOURCE].
9. All known creditors will be paid in full from [PAYMENT_SOURCE].

## Supporting Evidence
10. I exhibit the following documents marked "[EXHIBIT_REFERENCE]":
    - [DOCUMENT_LIST]

## Statement of Truth
I believe that the facts stated in this witness statement are true.

**Signed:** ________________  
**Date:** [SIGNATURE_DATE]  
**[WITNESS_NAME]**
```

### AI Generation Commands
```bash
# Generate witness statement
./scripts/ai-integration/generate_template.sh witness_statement \
  --witness="[WITNESS_NAME]" \
  --address="[WITNESS_ADDRESS]" \
  --relationship="[RELATIONSHIP_TO_DEBTOR]" \
  --case-details="[CASE_SUMMARY]"

# Extract key facts for statement
./scripts/ai-integration/analyze_section.sh 01-initial-situation extract_witness_facts

# Copilot drafting assistance
/chat @workspace Draft a witness statement for bankruptcy annulment based on the case files in docs/cases/2025-10-08-bankruptcy/
```

---

## 📄 **Draft Court Order Template**

### Order Structure
```markdown
# Draft Order
**Court:** [COURT_NAME]  
**Case No:** [CASE_NUMBER]  
**Date:** [HEARING_DATE]

**Before:** [JUDGE_NAME]

**Between:**
**[DEBTOR_FULL_NAME]** — Applicant  
**-and-**  
**[PETITIONING_CREDITOR]** — Respondent

## Recitals
A. The Court made a bankruptcy order against the applicant on [BANKRUPTCY_DATE].
B. The applicant seeks annulment under s.282(1)(b) Insolvency Act 1986.
C. The applicant has paid or proposes to pay all bankruptcy debts and expenses.

## Orders
1. **Case Management Directions:**
   - The Official Receiver shall invite proofs of debt by [PROOFS_DEADLINE].
   - The applicant shall serve the application bundle by [SERVICE_DEADLINE].
   - The Official Receiver shall file a report by [OR_REPORT_DEADLINE].

2. **Hearing:**
   - The application be listed for hearing on [HEARING_DATE] at [HEARING_TIME].
   - Time estimate: [HEARING_DURATION].

3. **Costs:**
   - Costs reserved to the hearing judge.

**Dated:** [ORDER_DATE]  
**[JUDGE_NAME]**  
**[COURT_NAME]**
```

### AI Automation
```bash
# Generate draft order
./scripts/ai-integration/generate_template.sh draft_order \
  --court="[COURT_NAME]" \
  --judge="[JUDGE_NAME]" \
  --hearing-date="[HEARING_DATE]" \
  --deadlines="[DEADLINE_SCHEDULE]"

# Calculate standard deadlines
./scripts/ai-integration/calculate_deadlines.sh \
  --hearing-date="[HEARING_DATE]" \
  --type="bankruptcy_annulment"
```

---

## 💌 **Letter Templates**

### Letter to Official Receiver
```markdown
# Letter to Official Receiver
**Date:** [LETTER_DATE]  
**Our Ref:** [OUR_REFERENCE]  
**Your Ref:** [OR_REFERENCE]

**To:** Official Receiver  
**Re:** [DEBTOR_FULL_NAME] - Bankruptcy No. [CASE_NUMBER]

Dear Sir/Madam,

## Annulment Application Notice
We write to notify you of our client's application for annulment under s.282(1)(b) Insolvency Act 1986.

## Court Directions Required
We respectfully request that you:
1. **Invite proofs of debt** from all known creditors by [PROOFS_DEADLINE]
2. **Prepare a report** for the court by [OR_REPORT_DEADLINE]
3. **Confirm your position** on the annulment application

## Cooperation Commitment
Our client remains committed to:
- Full cooperation with your office
- Timely remittance of post-order rental income
- Provision of all requested information and documentation

## Contact Details
Please direct all correspondence to [CONTACT_DETAILS].

Yours faithfully,

**[SENDER_NAME]**  
**[SENDER_TITLE]**
```

### Letter to Creditors
```markdown
# Letter to Creditors
**Date:** [LETTER_DATE]  
**Our Ref:** [OUR_REFERENCE]

**To:** [CREDITOR_NAME]  
**Re:** [DEBTOR_FULL_NAME] - Proposed Payment in Full

Dear [CREDITOR_TITLE],

## Bankruptcy Annulment Proposal
Following the bankruptcy order dated [BANKRUPTCY_DATE], our client proposes to pay all creditors in full to secure annulment under s.282(1)(b).

## Your Claim
Based on our records, your claim is approximately £[CREDITOR_AMOUNT]. Please confirm:
1. **Exact amount** owing as at [BANKRUPTCY_DATE]
2. **Account details** for payment
3. **Supporting documentation** (statements, agreements, etc.)

## Timeline
We aim to complete all payments by [PAYMENT_DEADLINE] to enable the court hearing on [HEARING_DATE].

## Contact
Please respond by [RESPONSE_DEADLINE] to [CONTACT_DETAILS].

Yours sincerely,

**[SENDER_NAME]**
```

---

## 📋 **Action Checklists**

### Pre-Application Checklist
```markdown
## Pre-Application Tasks
- [ ] **Gather creditor details** — Complete list with amounts
- [ ] **Confirm funding** — Third-party availability confirmed
- [ ] **Calculate total costs** — Court fees + debts + OR charges
- [ ] **Prepare evidence** — Supporting documentation ready
- [ ] **Draft documents** — Application, witness statement, order

## Filing Requirements
- [ ] **Form N244** — Completed and signed
- [ ] **Court fee** — £155 paid
- [ ] **Witness statement** — Sworn and exhibited
- [ ] **Draft order** — Prepared for court
- [ ] **Service** — Copies to all parties
```

### AI Generation
```bash
# Generate personalized checklist
./scripts/ai-integration/generate_checklist.sh \
  --case-type="bankruptcy_annulment" \
  --phase="pre_application" \
  --case-vars="[CASE_VARIABLES]"

# Progress tracking
./scripts/ai-integration/track_progress.sh \
  --checklist-file="checklists/[CASE_ID]_checklist.md" \
  --update-item="court_fee_paid"
```

---

## 🤖 **AI Workflow Integration**

### Copilot Prompts
```markdown
## Document Generation
/chat @workspace Generate a complete court bundle for bankruptcy annulment using the templates in templates/court/ and case data from docs/cases/2025-10-08-bankruptcy/

## Deadline Management
/chat @workspace Create a timeline with all deadlines for bankruptcy annulment application, working backwards from hearing date [HEARING_DATE]

## Evidence Review
/chat @workspace Review the witness statement draft and suggest improvements based on similar cases in the knowledge base

## Cost Calculation
/chat @workspace Calculate total costs for bankruptcy annulment including court fees, OR charges, and creditor payments based on case data
```

### Automation Scripts
```bash
# Complete document package
./scripts/ai-integration/generate_court_bundle.sh \
  --case-id="2025-10-08-bankruptcy" \
  --hearing-date="2025-11-15" \
  --output-dir="docs/cases/2025-10-08-bankruptcy/court-bundle/"

# Variables substitution
./scripts/ai-integration/populate_templates.sh \
  --template-dir="templates/court/" \
  --variables-file="config/cases/2025-10-08-bankruptcy-vars.json" \
  --output-dir="docs/cases/2025-10-08-bankruptcy/generated/"

# Quality check
./scripts/ai-integration/validate_documents.sh \
  --bundle-dir="docs/cases/2025-10-08-bankruptcy/court-bundle/" \
  --checklist="checklists/court_bundle_requirements.json"
```

---

## 📊 **Template Performance Metrics**

### Generation Speed
- **Simple letter:** <30 seconds
- **Court application:** <2 minutes  
- **Complete bundle:** <5 minutes
- **Multi-case batch:** <15 minutes

### Accuracy Targets
- **Variable substitution:** 99.9% accuracy
- **Format compliance:** Court rules compliant
- **Content completeness:** All required sections
- **Legal accuracy:** Human review required

### Quality Assurance
```bash
# Automated validation
./scripts/quality/validate_template.sh \
  --template="templates/court/n244_application.md" \
  --schema="schemas/court_documents.json"

# Legal compliance check
./scripts/quality/legal_compliance.sh \
  --document="generated/n244_application.pdf" \
  --court-rules="county_court_rules_2024"
```

**💡 This template system demonstrates how AI can dramatically accelerate legal document preparation while maintaining professional standards and court compliance.**
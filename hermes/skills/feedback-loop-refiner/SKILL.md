---
name: "feedback-loop-refiner"
description: "Refine, test, and update procedural skills using system feedback, tool outputs, and user corrections to improve accuracy."
version: 1
created: "2026-10-23"
updated: "2026-10-23"
---
## When to Use
This is a meta-skill designed to improve the entire ecosystem. Use this procedure proactively or reactively whenever any skill (including this one) is utilized or when tool output suggests an opportunity for refinement. It handles self-correction, knowledge refinement, and process improvement across all skills.

## Procedure
1. 1. Execute the target skill to test its current state (e.g., run `configs-manager`).
2. 2. Observe the tool's output and the resulting system behavior.
3. 3. Compare the observed outcome against the expected result. If they differ, note the discrepancy.
4. 4. Analyze the discrepancy (e.g., check tool error codes, system logs, or user corrections).
5. 5. Formulate a precise change needed (e.g., path correction, adding a pitfall, or modifying a step).
6. 6. Use the skill_manage tool to view, patch, or update the target skill (including this skill itself, 'feedback-loop-refiner') using skill_manage update or skill_manage patch.
7. 7. Re-execute the test case with the updated skill to verify the change fixed the issue and did not introduce new regressions.

## Pitfalls
- Do not update a skill without first documenting the observation that necessitated the change, or you risk creating a false fix.
- When using patch, ensure the target section and the structured field are identified exactly as per the skill_manage API.
- Always verify the fix with a final test run before concluding the refinement cycle.

## Verification
1. The skill should execute the procedure successfully and meet the user's revised expectations.
2. The tool output should confirm the correction was implemented and the desired behavior is achieved.
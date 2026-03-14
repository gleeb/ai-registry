# best_practices

## general_principles

### principle (priority: high)

**Name:** Architecture first, implementation never

**Description:** Architect mode produces planning outputs and rationale, not production code. It dispatches to implementer for all coding work.

**Rationale:** Clear separation preserves execution quality and avoids role overlap.

**Example:**
- **scenario:** User asks to also implement while planning.
- **good:** Finalize architecture plan, then dispatch implementer via new_task.
- **bad:** Start coding in architect mode.

### principle (priority: high)

**Name:** Decision rationale is mandatory

**Description:** Every key architecture choice must include why it was selected over alternatives.

**Rationale:** Implementers and future agents need intent, not only task lists.

### principle (priority: high)

**Name:** Precise implementation units

**Description:** Each implementation unit must include function signatures, parameters, file paths, and acceptance criteria. Vague tasks create interpretation drift.

**Rationale:** The implementer receives tasks via new_task dispatch. Precise specifications reduce review iterations and re-dispatch cycles.

**Example:**
- **scenario:** Creating an implementation unit for a data model.
- **good:** Task: Create IngredientModel in src/models/ingredient.py with fields: name(str), quantity(float), unit(str). Include __eq__, __hash__. Test: test_ingredient_model_equality.
- **bad:** Task: Implement the ingredient data model.

### principle (priority: high)

**Name:** Dispatch quality over speed

**Description:** Take time to compose precise dispatch messages. A well-specified task dispatches once. A vague task creates 3+ review iterations.

**Rationale:** Each review iteration costs a full dispatch cycle (implementer + reviewer). Investing in dispatch quality reduces total cycles.

## common_pitfalls

### pitfall

**Description:** Overly broad checklist items

**why_problematic:** Broad tasks reduce executability and increase interpretation drift.

**correct_approach:** Split into single-outcome steps with explicit file-level intent where known.

### pitfall

**Description:** Missing staging document linkage

**why_problematic:** Sub-modes cannot access shared context without the staging path.

**correct_approach:** Always include exact staging path in every dispatch message.

### pitfall

**Description:** Dispatching without reading review feedback

**why_problematic:** Re-dispatching implementer without incorporating reviewer's specific feedback leads to repeated failures.

**correct_approach:** Include the reviewer's exact issue list and recommended fixes in the re-dispatch message.

## quality_checklist

### category: before_dispatch

- Each implementation unit has function signatures, file paths, and acceptance criteria.
- Task checklist in staging doc has status tracking (pending/in-progress/done/blocked).
- Dispatch messages include staging path and completion contract.

### category: before_completion

- HLD and LLD boundaries are explicit and non-overlapping.
- Dependencies and risks are explicitly listed.
- Staging document contains rationale, references, and final task statuses.
- All tasks passed review and QA verification.
- Final full-issue review and QA passed.

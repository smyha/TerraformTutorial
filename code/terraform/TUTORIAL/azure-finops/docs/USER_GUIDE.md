# FinOps User Guide

## For Finance Teams

### Looking at Costs
You don't need access to the Azure Portal to see costs. We have enabled **Cost Exports** to a storage account.
1. Access the Storage Account `stfinopsexport`.
2. Open the `costs` container.
3. Download the CSV/Parquet files or connect PowerBI to this source.

### Budget Alerts
You will receive emails when spending hits 50%, 80%, and 100% of the forecast.
*   **Action**: Contact the Engineering lead listed in the Alert email.

## For Engineering Teams

### Tagging Rules
Every resource MUST have a `CostCenter` and `Owner` tag.
*   **Why**: If you don't tag it, Finance can't pay for it.
*   **Error**: `Policy 'finops-required-tags' denied deployment`.
*   **Fix**: Add the tags to your Terraform resource.

### Auto-Shutdown
Dev resources stop at 7 PM.
*   **Override**: Add the tag `Schedule: Bypass` to keep a VM running overnight (requires VP approval).

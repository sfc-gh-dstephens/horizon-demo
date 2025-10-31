Act as a Snowflake Solution Engineer building a demo for data governance, focusing on automated discovery, classification, and secure data access policies.

**GOAL:** Create a complete, self-contained **Snowflake Snowsight Notebook** demo that uses SQL to walk a user through an end-to-end data governance workflow.

**CONSTRAINTS:**
1.  **Format:** The entire solution must be presented as a single, fully commented **Snowsight Notebook** structure (using SQL code blocks).
2.  **Setup:** Include a clear setup section at the start to create necessary roles, a warehouse, and mock raw data. We need to set up a database where governance objects live, a database where we can manually identify data, and a database that we will use the auto classification on. We need data that is based on PII, PCI, and PAN compliance.

**REQUIRED DEMO SECTIONS & FEATURES:**

### 1. Discovery & Classification
* **Feature:** Demonstrate **Automatic Classification**
* **Scenario:** Scan a mock database that holds PII/PCI and PAN data, which is used in downstream processes to show tag propogation.

### 2. Classify & Govern
* **Feature 1:** Set up **Data Quality Monitoring** using data metric functions here: https://docs.snowflake.com/en/user-guide/data-quality-system-dmfs and custom data metric functions: https://docs.snowflake.com/en/user-guide/data-quality-custom-dmfs
* **Feature 2:** Manually **Tagging** a column and showing **Tag Propagation** from a raw table to a secure view.
* **Feature 3:** Define a **Contact** associated with the sensitive data domain (e.g., a data steward).

### 3. Obfuscation & Secure Access
* **Feature 1 (Row-Level Security):** Implement an **aggregation/projection policy** using a **Row Access Policy** (RAP) to ensure users with a 'Limited' role can only see aggregated data (e.g., total sales) and are blocked from seeing individual customer rows.
* **Feature 2 (Column-Level Security):** Implement a **Column Masking Policy** (DCM) to dynamically mask sensitive columns (like email) for a 'Limited' role but reveal the full value for an 'Analyst' role.
* **Feature 3 (Aggregation Policy):** Implement an **Aggretation Policy** as shown here: https://docs.snowflake.com/en/user-guide/aggregation-policies
* **Feature 4 (Projection Policy):** Implement a **Projection Policy** as shown here: https://docs.snowflake.com/en/user-guide/projection-policies

**FINAL REQUEST:** Ensure the flow is logical, starting from raw data creation and ending with queries that demonstrate the security policies are enforced correctly for different user roles.
[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/NhtMdX3c)
## Requirements for Group Project (25%)
[Read the instruction](https://github.com/STTPK3123-A252/class-activity-sqm/blob/main/GroupProject.md)

## Group Info:
1. Matric Number & Name & Photo & Phone Number
1. Mention who the leader is.
1. Mention your previous group.
1. Other related info (if any)

<table>
  <tr>
    <td><b>No.</b></td>
    <td><b>Photo</b></td>
    <td><b>Name</b></td>
    <td><b>Matric Number</b></td>
    <td><b>Phone Number</b></td>
  </tr>
  <tr>
    <td>1</td>
    <td><img src="https://github.com/user-attachments/assets/9d3e6310-d902-41de-9b8e-ab46c8745712"
 width="160" height="240"></td>
    <td>Khor Ken Joo</td>
    <td>299843</td>
    <td>+6010-830 8896</td>
  </tr>
  <tr>
    <td>2</td>
    <td><img src="https://github.com/user-attachments/assets/2beb78c3-c0e5-4620-b0fc-1d5274f15dac"
 width="160" height="240"></td>
    <td>Andrew Looi Szu Kit</td>
    <td>299412</td>
    <td>+6017-244 6292</td>
  </tr>
  <tr>
    <td>3</td>
    <td><img src="https://github.com/user-attachments/assets/72cd0f3f-be62-42ca-9b8b-b2d703635726"
 width="160" height="240"></td>
    <td>Eric Lee Shen Yi</td>
    <td>299300</td>
    <td>+6011-3671 6188</td>
  </tr>
  <tr>
    <td>4</td>
    <td><img src="https://github.com/user-attachments/assets/279c39d7-d6ac-42e5-bcb7-582b63d9e43d"
 width="160" height="240"></td>
    <td>Tan Hou Ren</td>
    <td>301235</td>
    <td>+6011-1322 7627</td>
  </tr>
</table>
## Title 

## Introduction

## Related Work (selected article)
https://dl-acm-org.eserv.uum.edu.my/doi/10.1145/3508397.3564840 

## Methodology (from paper + adaptation)
### 1. Analysis of the Research Methodology
The selected research paper essentially ran an experiment: it compared a standard Agile project against an "enhanced" Agile project that used specific software quality characteristics as key performance indicators (KPIs). 

The core steps were:
* Defining software quality goals using the ISO/IEC 25010 model *before* starting development.
* Mapping specific automated tests in the CI/CD pipeline to those quality goals. For example, mapping unit tests to "Functional Suitability".
* Continuously tracking test results and comparing them with past builds to catch any drop in quality.

For the tool stack, Jenkins served as the CI server. The automated testing included Visual Studio for static analysis and unit testing, JMeter for API performance tests, and Ranorex for End-to-End (E2E) scenario testing. The metrics tracked mainly included test pass rates, bug rates, and processing time.

### 2. Adaptation of the Methodology
The core philosophy of the paper—building a "Test Pyramid" and mapping tests to specific quality characteristics—is retained, but the tools are swapped out to fit the actual project stack.

* **Reused Components:**
  * **The Quality Mapping:** Pipeline stages are still linked to specific quality sub-characteristics (e.g., API tests = Performance Efficiency).
  * **API Testing:** Just like the paper, **JMeter** is used to track performance data and ensure the system doesn't slow down between builds.

* **Modified Components:**
  * **E2E Testing:** While the researchers used Ranorex, it is replaced with **Cypress** to handle the UI and scenario testing. 
  * **Development & Unit Tests:** **Visual Studio (VS)** serves as the main environment for coding and unit testing, which aligns with the early stages of the paper's pipeline.
  * **Deployment (CD):** The paper discusses deployment abstractly to ensure "ease of installation". This is made concrete by setting up a live deployment pipeline to **Digital Ocean**, which specifically tests the "Portability" and "Installability" of the system.

### 3. Implementing DevOps Practices
Here is how this methodology translates into the actual project workflow:

* **CI/CD Pipeline:** **GitHub Actions** is utilized to automatically trigger builds and tests whenever code is pushed.
* **The Test Pyramid:**
  * *Base (Unit Testing in VS):* Runs first to check baseline "Functional Suitability".
  * *Middle (API Testing via JMeter):* Runs next to check "Performance Efficiency" and measure processing time.
  * *Top (E2E Testing via Cypress):* Runs last to validate the user flow and check "Usability".
* **Code Quality:** Coding rules are enforced early in VS to keep the codebase clean and improve "Maintainability".
* **Deployment:** Once all tests pass, GitHub Actions automatically deploys the application to a **Digital Ocean** droplet so the project is live. 

### 4. Data Collection
To validate the pipeline and compare results with the paper's findings, the following data will be collected:
* Build success and failure rates from GitHub Actions.
* Test pass/fail rates from Visual Studio and Cypress.
* Processing time and performance metrics captured by JMeter.
* The frequency of successful deployments to Digital Ocean.

## Implementation (DevOps pipeline)

## Results & Analysis

## Comparison with paper

## Conclusion

## Presentation (max 15 minutes including product demo)
Example: show your implemented tool, metric dashboard, or test results.

## References (Not less than 20)


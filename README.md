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
The research paper we based our approach on essentially ran an experiment: they compared a standard Agile project against an "enhanced" Agile project that used specific software quality characteristics as key performance indicators (KPIs).

Their core steps were:
* Defining software quality goals using the ISO/IEC 25010 model *before* starting development.
* Mapping specific automated tests in the CI/CD pipeline to those quality goals. For example, mapping unit tests to "Functional Suitability".
* Continuously tracking test results and comparing them with past builds to catch any drop in quality.

For their tool stack, they used Jenkins as their CI server. Their automated testing included Visual Studio for static analysis and unit testing, JMeter for API performance tests , and Ranorex for End-to-End (E2E) scenario testing. They mainly tracked metrics like test pass rates, bug rates, and processing time.

### 2. How We Are Adapting the Methodology
We are keeping the core philosophy of the paper—building a "Test Pyramid" and mapping our tests to specific quality characteristics but we are swapping out the tools to fit our actual project stack.

* **What We Are Reusing:**
  * **The Quality Mapping:** We are still linking our pipeline stages to specific quality sub-characteristics (e.g., API tests = Performance Efficiency).
  * **API Testing:** Just like the paper, we will use **JMeter** to track performance data and make sure our system doesn't slow down between builds.

* **What We Are Modifying:**
  * **E2E Testing:** The researchers used Ranorex, but we are replacing it with **Cypress** to handle our UI and scenario testing. 
  * **Development & Unit Tests:** We are using **Visual Studio (VS)** as our main environment for coding and unit testing, which aligns with the early stages of the paper's pipeline.
  * **Deployment (CD):** The paper talks about deployment a bit abstractly to ensure "ease of installation". We are making this concrete by setting up a live deployment pipeline to **Digital Ocean**, which specifically tests the "Portability" and "Installability" of our system.

### 3. Implementing DevOps Practices
Here is how this methodology translates into our actual project workflow:

* **CI/CD Pipeline:** We are using **GitHub Actions** to automatically trigger our builds and tests whenever code is pushed.
* **Our Test Pyramid:**
  * *Base (Unit Testing in VS):* Runs first to check baseline "Functional Suitability".
  * *Middle (API Testing via JMeter):* Runs next to check "Performance Efficiency" and measure processing time.
  * *Top (E2E Testing via Cypress):* Runs last to validate the user flow and check "Usability".
* **Code Quality:** We are enforcing coding rules early in VS to keep the codebase clean and improve "Maintainability".
* **Deployment:** Once all tests pass, GitHub Actions will automatically deploy our application to a **Digital Ocean** droplet so the project is live. 

### 4. Data Collection
To prove our pipeline works and to compare our results with the paper's findings, we will be collecting:
* Build success and failure rates from GitHub Actions.
* Test pass/fail rates from Visual Studio and Cypress.
* Processing time and performance metrics captured by JMeter.
* How frequently we successfully deploy to Digital Ocean.
## Implementation (DevOps pipeline)

## Results & Analysis

## Comparison with paper

## Conclusion

## Presentation (max 15 minutes including product demo)
Example: show your implemented tool, metric dashboard, or test results.

## References (Not less than 20)


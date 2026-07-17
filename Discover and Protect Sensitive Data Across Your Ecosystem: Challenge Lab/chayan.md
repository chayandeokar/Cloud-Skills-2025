
# Discover and Protect Sensitive Data Across Your Ecosystem: Challenge Lab || [GSP522](https://www.cloudskillsboost.google/focuses/109502?parent=catalog) ||


* Go to **Sensitive Data Protection** from [here](https://console.cloud.google.com/security/sensitive-data-protection/create/discoveryConfiguration;source=DATA_PROFILE_COVERAGE_DASHBOARD;discoveryType=4?project=)

 ### Run the following Commands in CloudShell

```
curl -LO https://raw.githubusercontent.com/chayandeokar/Cloud-Skills-2025/refs/heads/master/Discover%20and%20Protect%20Sensitive%20Data%20Across%20Your%20Ecosystem%3A%20Challenge%20Lab/chayan.sh
sudo chmod +x chayan.sh
./chayan.sh
```

```
# Redefine original function to inspect and deidentify output with Sensitive Data Protection
import google.cloud.dlp  
from typing import List 

def deidentify_with_replace_infotype(
    project: str, item: str, info_types: List[str]
) -> None:
    """Uses the Data Loss Prevention API to deidentify sensitive data in a
    string by replacing it with the info type.
    Args:
        project: The Google Cloud project id to use as a parent resource.
        item: The string to deidentify (will be treated as text).
        info_types: A list of strings representing info types to look for.
            A full list of info type categories can be fetched from the API.
    Returns:
        None; the response from the API is printed to the terminal.
    """

    # Instantiate a client
    dlp = google.cloud.dlp_v2.DlpServiceClient()

    # Convert the project id into a full resource id.
    parent = f"projects/{PROJECT_ID}"

    # Construct inspect configuration dictionary
    inspect_config = {"info_types": [{"name": info_type} for info_type in info_types]}

    # Construct deidentify configuration dictionary
    deidentify_config = {
        "info_type_transformations": {
            "transformations": [
                {"primitive_transformation": {"replace_with_info_type_config": {}}}
            ]
        }
    }

    # Call the API for deidentify
    response = dlp.deidentify_content(
        request={
            "parent": parent,
            "deidentify_config": deidentify_config,
            "inspect_config": inspect_config,
            "item": {"value": item},
        }
    )

    return_payload = response.item.value
    
    # Add conditional return to block responses containing US Vehicle Identification Numbers (VIN)
    info_types = ["DOCUMENT_TYPE/R&D/SOURCE_CODE"]
    inspect_config = {"info_types": [{"name": info_type} for info_type in info_types]}

    response = dlp.inspect_content(
        request={
            "parent": parent,
            "inspect_config": inspect_config,
            "item": {"value": item},
        }
    )

    if response.result.findings:
        for finding in response.result.findings:
            if finding.info_type.name == "DOCUMENT_TYPE/R&D/SOURCE_CODE":
                return_payload = '[Blocked due to category: Source Code]'
                
    # Print results
    print(return_payload)
    
```

```
# Create prompt that generates an example response with US Vehicle Identification Number (VIN)
prompt = "Is 4Y1SL65848Z411439 an example of a US Vehicle Identification Number (VIN)?"

# Run model with prompt
# Name the output as response_vin
response_vin = model.generate_content(prompt)

# Print response without blocking it (VIN provided)
print(response_vin.text)

# Block model response that includes US Vehicle Identification Number (VIN)
deidentify_with_replace_infotype(
    project=PROJECT_ID,
    item=response_vin.text,
    info_types=["US_VEHICLE_IDENTIFICATION_NUMBER"]
)
```







 ### Run the following Commands in  Notebook Terminal

```
rm deidentify-model-response-challenge-lab-v1.0.0.ipynb

curl -LO https://raw.githubusercontent.com/chayandeokar/Cloud-Skills-2025/refs/heads/master/Discover%20and%20Protect%20Sensitive%20Data%20Across%20Your%20Ecosystem%3A%20Challenge%20Lab/deidentify-model-response-challenge-lab-v1.0.0.ipynb
```
### Congratulations !!!!

<div style="text-align: center; display: flex; flex-direction: column; align-items: center; gap: 20px;">
  <p>Connect with fellow cloud enthusiasts, ask questions, and share your learning journey.</p>  
</div>


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
    """
    # Instantiate a client
    dlp = google.cloud.dlp_v2.DlpServiceClient()

    # Convert the project id into a full resource id.
    parent = f"projects/{project}"

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
    # We add US_VEHICLE_IDENTIFICATION_NUMBER to the inspection list
    check_types = ["DOCUMENT_TYPE/R&D/SOURCE_CODE", "US_VEHICLE_IDENTIFICATION_NUMBER"]
    inspect_config_block = {"info_types": [{"name": t} for t in check_types]}

    response_inspect = dlp.inspect_content(
        request={
            "parent": parent,
            "inspect_config": inspect_config_block,
            "item": {"value": item},
        }
    )

    if response_inspect.result.findings:
        for finding in response_inspect.result.findings:
            if finding.info_type.name == "DOCUMENT_TYPE/R&D/SOURCE_CODE":
                return_payload = '[Blocked due to category: Source Code]'
            elif finding.info_type.name == "US_VEHICLE_IDENTIFICATION_NUMBER":
                return_payload = '[Blocked due to category: US VIN]'
                
    # Print results
    print(return_payload)
    
```

```
prompt = "Is 4Y1SL65848Z411439 an example of a US Vehicle Identification Number (VIN)?"

# Run model with prompt setting the temperature to 0
from google.genai import types
response_vin = client.models.generate_content(
    model=model,
    contents=prompt,
    config=types.GenerateContentConfig(
        temperature=0.0,
    ),
)

print("Original Response:")
print(response_vin.text)

print("\n--- Running DLP Block Guard ---")

deidentify_with_replace_infotype(
    project=PROJECT_ID, 
    item=response_vin.text, 
    info_types=["US_VEHICLE_IDENTIFICATION_NUMBER"]
)
```


### Congratulations !!!!

<div style="text-align: center; display: flex; flex-direction: column; align-items: center; gap: 20px;">
  <p>Connect with fellow cloud enthusiasts, ask questions, and share your learning journey.</p>  
</div>

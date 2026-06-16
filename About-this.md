# Magento Misconfiguration Scanner

A lightweight Bash-based Magento security misconfiguration scanner designed for authorized security assessments and pre-production validation.

## Features

* Detects common Magento misconfigurations
* Identifies sensitive file exposures
* Checks setup/install page exposure
* Detects GraphQL accessibility
* Identifies Git repository disclosures
* Detects Cloudflare/WAF protection pages
* Generates CSV reports
* Saves HTTP responses for evidence collection

## Requirements

* Bash
* curl
* grep
* sed
* wc

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/magento-misconfig-scanner.git
cd magento-misconfig-scanner

chmod +x magento_misconfig_scanner.sh
```

## Usage

```bash
./magento_misconfig_scanner.sh
```

Enter the Magento URL when prompted:

```text
https://example.com
```

The scanner generates:

* CSV report containing findings
* Response directory with collected evidence

## Example Output

```text
[200] /.env                                    CRITICAL - Configuration Exposure
[403] /composer.json                           Protected
[404] /setup/                                  Not Found
```

## Output Files

```text
report_YYYYMMDD_HHMMSS.csv
responses_YYYYMMDD_HHMMSS/
```

## Severity Definitions

| Severity | Description                               |
| -------- | ----------------------------------------- |
| CRITICAL | Sensitive data exposure                   |
| HIGH     | Administrative functionality exposed      |
| MEDIUM   | Features requiring further review         |
| INFO     | Accessible resources requiring validation |

## Disclaimer

This tool is intended solely for authorized security assessments. Users are responsible for obtaining appropriate authorization before scanning any systems.

The authors assume no liability for misuse or damage caused by this tool.

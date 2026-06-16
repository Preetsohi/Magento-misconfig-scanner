```bash
#!/bin/bash

clear
echo "==============================================="
echo " Magento Misconfiguration Scanner v1.0"
echo "==============================================="
echo ""

read -rp "Enter Magento URL to scan (e.g., https://example.com): " TARGET

TARGET=$(echo "$TARGET" | sed 's:/*$::')

if ! [[ "$TARGET" =~ ^https?:// ]]; then
    echo "[!] Invalid URL. Include http:// or https://"
    exit 1
fi

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT="report_${TIMESTAMP}.csv"
RESP_DIR="responses_${TIMESTAMP}"

mkdir -p "$RESP_DIR"

USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36"

URLS=(
"/admin"
"/backend"
"/.env"
"/app/etc/env.php"
"/app/etc/local.xml"
"/composer.json"
"/composer.lock"
"/phpinfo.php"
"/info.php"
"/README.md"
"/.git/config"
"/setup/"
"/install/"
"/var/log/system.log"
"/var/log/exception.log"
"/var/report/"
"/backup.sql"
"/database.sql"
"/rest/V1/store/storeConfigs"
"/rest/V1/integration/admin/token"
"/graphql"
"/soap/?wsdl"
"/vendor/"
"/app/code/"
"/cron.php"
"/health_check.php"
)

echo '"URL","Status","Finding","Response_Size"' > "$REPORT"

echo ""
echo "[+] Starting scan against: $TARGET"
echo ""

for path in "${URLS[@]}"; do

    URL="${TARGET}${path}"

    SAFE_NAME=$(echo "$path" | sed 's|^/||' | tr '/?&=' '_')

    [[ -z "$SAFE_NAME" ]] && SAFE_NAME="root"

    BODY="${RESP_DIR}/${SAFE_NAME}.txt"

    STATUS=$(curl -k -s -L \
        -A "$USER_AGENT" \
        -o "$BODY" \
        -w "%{http_code}" \
        --connect-timeout 10 \
        --max-time 30 \
        "$URL")

    SIZE=$(wc -c < "$BODY")

    FINDING=""

    if grep -qiE "Just a moment|Enable JavaScript and cookies to continue|cf_chl_opt" "$BODY"; then

        FINDING="Cloudflare/WAF Protection"

    elif [[ "$STATUS" == "200" ]]; then

        case "$path" in

            *.env*|*/env.php*|*/local.xml)
                FINDING="CRITICAL - Configuration Exposure"
                ;;

            *.sql)
                FINDING="CRITICAL - Database Backup Exposure"
                ;;

            */.git*)
                FINDING="CRITICAL - Git Repository Exposure"
                ;;

            */graphql)
                FINDING="MEDIUM - GraphQL Accessible"
                ;;

            */integration/admin/token)
                FINDING="MEDIUM - Admin Token Endpoint Accessible"
                ;;

            */setup/*|*/install*)
                FINDING="HIGH - Setup Accessible"
                ;;

            *)
                FINDING="INFO - Accessible Resource"
                ;;
        esac

    elif [[ "$STATUS" == "403" ]]; then
        FINDING="Protected"

    elif [[ "$STATUS" == "404" ]]; then
        FINDING="Not Found"

    else
        FINDING="Review Required"
    fi

    printf "[%s] %-50s %s\n" "$STATUS" "$path" "$FINDING"

    echo "\"$URL\",\"$STATUS\",\"$FINDING\",\"$SIZE\"" >> "$REPORT"

done

echo ""
echo "[+] Scan Complete"
echo "[+] Report: $REPORT"
echo "[+] Responses: $RESP_DIR"

echo ""
echo "[+] Potential Findings"

grep -E 'CRITICAL|HIGH|MEDIUM' "$REPORT"

echo ""
echo "[+] Done"
```

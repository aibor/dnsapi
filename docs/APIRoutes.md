# DNSAPI API Routes
## Intro
These routes can be used for automated interaction.
See the model documentation for available resource attributes.
### Example:
      curl https://dns.example.com/records.json       \
        --user username:pw                            \ 
        -H "Content-Type: application/json"           \
        -X POST                                       \
        -d '{"record": {                              \
          "domain_id": "<DOMAIN-ID>",                 \
          "name": "<RECORD-NAME>",                    \
          "type": "TXT",                              \
          "content": "<RECORD-CONTENT>"               \
        }}'
## Domains

    POST	/domains/:id/parse
    PUT	/domains/:id/secure
    GET	/domains
    POST	/domains
    GET	/domains/:id
    PATCH	/domains/:id
    PUT	/domains/:id
    DELETE	/domains/:id

## Domainmetadata

    POST	/domainmetadata
    GET	/domainmetadata/:id
    PATCH	/domainmetadata/:id
    PUT	/domainmetadata/:id
    DELETE	/domainmetadata/:id

## Records

    PUT	/records/:id/generate_token
    POST	/records
    GET	/records/:id
    PATCH	/records/:id
    PUT	/records/:id
    DELETE	/records/:id

## Cryptokeys

    POST	/cryptokeys
    GET	/cryptokeys/:id
    PATCH	/cryptokeys/:id
    PUT	/cryptokeys/:id
    DELETE	/cryptokeys/:id

## Users

    GET	/users
    POST	/users
    GET	/users/:id
    PATCH	/users/:id
    PUT	/users/:id
    DELETE	/users/:id


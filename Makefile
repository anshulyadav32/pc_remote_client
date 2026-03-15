WEB_BUILD_DIR=build/web
AZ_APP_NAME?=
AZ_RESOURCE_GROUP?=

.PHONY: web-build deploy-cloudflare deploy-netlify deploy-azure azure-token

web-build:
	HOME=$(PWD)/.dart_tool flutter build web --release --base-href /
	cp web/_redirects $(WEB_BUILD_DIR)/_redirects
	cp web/staticwebapp.config.json $(WEB_BUILD_DIR)/staticwebapp.config.json

deploy-cloudflare: web-build
	wrangler pages deploy $(WEB_BUILD_DIR) --project-name pcremote

deploy-netlify: web-build
	netlify deploy --prod --dir $(WEB_BUILD_DIR)

deploy-azure: web-build
	swa deploy $(WEB_BUILD_DIR) --env production

azure-token:
	az staticwebapp secrets list --name $(AZ_APP_NAME) --resource-group $(AZ_RESOURCE_GROUP) --query "properties.apiKey" -o tsv

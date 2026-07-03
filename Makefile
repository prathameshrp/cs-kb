# Makefile for CS Library (Jekyll Site)

.PHONY: serve update build deploy clean install

# Serve the site locally with livereload
serve:
	bundle exec jekyll serve --livereload --incremental

# Update the notes submodule to the latest commit of your vault
update:
	git -c protocol.file.allow=always submodule update --remote --merge

# Build the site locally
build:
	bundle exec jekyll build

# Install bundler dependencies
install:
	bundle install

# Commit and push changes to trigger GitHub Actions deploy
deploy:
	git add .
	@read -p "Enter commit message (default: 'Update library'): " msg; \
	msg=$${msg:-"Update library"}; \
	git commit -m "$$msg"
	git push origin master || git push origin main

# Clean up jekyll build cache and _site output
clean:
	rm -rf _site .jekyll-cache .jekyll-metadata

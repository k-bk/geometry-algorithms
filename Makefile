PACKAGES := UI.lua v2.lua graph.lua
PACKAGES := $(PACKAGES:%=lib/%)

define update
@./update_package.sh "karolBak/love2d-ui/v1.2" "UI.lua"
@./update_package.sh "karolBak/love2d-graphs/master/" "v2.lua"
@./update_package.sh "karolBak/love2d-graphs/master/" "graph.lua"
endef

run: love $(PACKAGES)
	./love .

love:
	wget -L -O love https://bitbucket.org/rude/love/downloads/love-11.3-x86_64.AppImage
	chmod +x love

$(PACKAGES):
	$(update)

update:
	$(update)

.PHONY: run update
